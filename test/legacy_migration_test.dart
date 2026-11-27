import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/data/database.dart';
import 'package:memoryos/data/legacy_migration.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq;

void main() {
  test('migrates every seeded legacy row without data loss and renames file', () async {
    final tempDir = await Directory.systemTemp.createTemp('memoryos_mig_');
    final legacyFile = File(p.join(tempDir.path, 'memoryos.db'));
    final targetDb = MemoryDatabase.inMemory();

    try {
      final legacy = sq.sqlite3.open(legacyFile.path);
      legacy.execute('''
        CREATE TABLE memory_nodes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          source TEXT NOT NULL,
          metadata TEXT NOT NULL,
          trail TEXT NOT NULL,
          is_starred INTEGER NOT NULL DEFAULT 0,
          deleted_at TEXT
        );
      ''');
      legacy.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        );
      ''');

      legacy.execute('''
        INSERT INTO memory_nodes (timestamp, title, content, source, metadata, trail, is_starred, deleted_at)
        VALUES
          ('2026-11-26T09:15:00.000', 'WhatsApp: Nabila', 'See you tomorrow', 'notification', '{"packageName":"com.whatsapp","notificationKey":"0|com.whatsapp|1"}', 'none', 0, NULL),
          ('2026-11-26T12:00:00.000', 'Quick voice note', '', 'voice_note', '{"duration":"00:42"}', 'none', 0, NULL),
          ('2026-11-25T18:30:00.000', 'Deleted note', 'Old text', 'document', '{}', 'none', 0, '2026-11-26T10:00:00.000');
      ''');
      legacy.execute('''
        INSERT INTO settings (key, value) VALUES ('toggle_notification', 'true');
      ''');
      legacy.dispose();

      final result = await migrateLegacyDatabase(
        legacyFile: legacyFile,
        targetDb: targetDb,
      );

      expect(result.migratedSignals, 3);
      expect(result.migratedSettings, 1);
      expect(await legacyFile.exists(), isFalse);
      expect(result.renamedPath, isNotNull);
      expect(await File(result.renamedPath!).exists(), isTrue);

      final signals = await targetDb.select(targetDb.signal).get();
      expect(signals, hasLength(3));
      expect(signals[0].source, 'notification');
      expect(signals[0].pkg, 'com.whatsapp');
      expect(signals[0].sbnKey, '0|com.whatsapp|1');
      expect(signals[1].source, 'voice');
      expect(signals[2].deletedAt, isNotNull);
      expect(await targetDb.getSetting('toggle_notification'), 'true');
    } finally {
      await targetDb.close();
      await tempDir.delete(recursive: true);
    }
  });
}
