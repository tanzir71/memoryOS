import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq;
import 'database.dart';

class LegacyMigrationResult {
  const LegacyMigrationResult({
    required this.migratedSignals,
    required this.migratedSettings,
    required this.renamedPath,
  });

  final int migratedSignals;
  final int migratedSettings;
  final String? renamedPath;
}

/// Copies every row of `memory_nodes` and `settings` from legacy `memoryos.db`
/// into `MemoryDatabase` without deleting user data, then renames `memoryos.db`
/// to `memoryos.legacy.db`.
Future<LegacyMigrationResult> migrateLegacyDatabase({
  required File legacyFile,
  required MemoryDatabase targetDb,
}) async {
  if (!await legacyFile.exists()) {
    return const LegacyMigrationResult(
      migratedSignals: 0,
      migratedSettings: 0,
      renamedPath: null,
    );
  }

  var signalCount = 0;
  var settingsCount = 0;

  final legacy = sq.sqlite3.open(legacyFile.path, mode: sq.OpenMode.readOnly);
  try {
    final tables = legacy
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r['name'] as String)
        .toSet();

    if (tables.contains('memory_nodes')) {
      final rows = legacy.select('SELECT * FROM memory_nodes ORDER BY id ASC');
      for (final row in rows) {
        final tsText = row['timestamp']?.toString() ?? '';
        final occurredAt =
            DateTime.tryParse(tsText)?.millisecondsSinceEpoch ?? 0;
        final deletedAtText = row['deleted_at']?.toString();
        final deletedAt = deletedAtText == null || deletedAtText.isEmpty
            ? null
            : DateTime.tryParse(deletedAtText)?.millisecondsSinceEpoch;
        final source = row['source']?.toString() ?? 'note';
        final title = row['title']?.toString() ?? '';
        final content = row['content']?.toString() ?? '';
        final metaRaw = row['metadata']?.toString() ?? '{}';
        var pkg = '';
        String? sbnKey;
        try {
          final parsed = jsonDecode(metaRaw);
          if (parsed is Map) {
            pkg = parsed['packageName']?.toString() ?? '';
            final key = parsed['notificationKey']?.toString();
            if (key != null && key.isNotEmpty) {
              sbnKey = key;
            }
          }
        } catch (_) {}

        final signalId = await targetDb.into(targetDb.signal).insert(
          SignalCompanion.insert(
            source: _mapLegacySource(source),
            pkg: Value(pkg),
            kind: Value(source),
            sbnKey: Value(sbnKey),
            title: Value(title),
            body: Value(content),
            occurredAt: occurredAt,
            signalClass: Value(_mapLegacyClass(source)),
            kept: const Value(true),
            redacted: const Value(false),
            extrasJson: Value(metaRaw),
            deletedAt: Value(deletedAt),
          ),
        );
        await targetDb.upsertSearchEntry(
          targetType: 'signal',
          targetId: signalId,
          title: title,
          body: content,
        );
        signalCount++;
      }
    }

    if (tables.contains('settings')) {
      final rows = legacy.select('SELECT key, value FROM settings');
      for (final row in rows) {
        final key = row['key']?.toString();
        final val = row['value']?.toString();
        if (key != null && val != null) {
          await targetDb.setSetting(key, val);
          settingsCount++;
        }
      }
    }
  } finally {
    legacy.dispose();
  }

  final renamedPath = p.join(legacyFile.parent.path, 'memoryos.legacy.db');
  if (await File(renamedPath).exists()) {
    final backupPath = p.join(
      legacyFile.parent.path,
      'memoryos.legacy.${DateTime.now().millisecondsSinceEpoch}.db',
    );
    await legacyFile.rename(backupPath);
    return LegacyMigrationResult(
      migratedSignals: signalCount,
      migratedSettings: settingsCount,
      renamedPath: backupPath,
    );
  }
  await legacyFile.rename(renamedPath);
  return LegacyMigrationResult(
    migratedSignals: signalCount,
    migratedSettings: settingsCount,
    renamedPath: renamedPath,
  );
}

String _mapLegacySource(String source) => switch (source) {
  'notification' => 'notification',
  'bluetooth' => 'bluetooth',
  'calendar' => 'calendar',
  'voice_note' => 'voice',
  'photo' => 'screenshot',
  _ => 'note',
};

String _mapLegacyClass(String source) => switch (source) {
  'calendar' => 'calendar',
  'voice_note' => 'conversation',
  _ => 'system',
};
