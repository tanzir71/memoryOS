import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/memory_node.dart';
import 'capture_metadata.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memoryos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS memory_nodes');
      await db.execute('DROP TABLE IF EXISTS settings');
      await _createDB(db, newVersion);
    } else if (oldVersion < 6) {
      await _addColumnIfMissing(db, 'memory_nodes', 'deleted_at TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
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
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveSetting(String key, String value) async {
    try {
      final db = await instance.database;
      await db.insert('settings', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<String?> getSetting(String key) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return maps.first['value'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<int> insertNode(MemoryNode node) async {
    final db = await instance.database;
    return db.insert('memory_nodes', node.toMap());
  }

  Future<int> updateNode(MemoryNode node) async {
    if (node.id == null) {
      throw ArgumentError('Cannot update a record without an id.');
    }

    final db = await instance.database;
    return db.update(
      'memory_nodes',
      node.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [node.id],
    );
  }

  Future<List<MemoryNode>> fetchAllNodes() async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query('memory_nodes', orderBy: 'timestamp DESC');
    return _visibleNodes(result.map((json) => MemoryNode.fromMap(json)));
  }

  Future<List<MemoryNode>> fetchNodesByDate(DateTime date) async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.query(
      'memory_nodes',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'timestamp DESC',
    );
    return _visibleNodes(result.map((json) => MemoryNode.fromMap(json)));
  }

  Future<List<MemoryNode>> searchNodes(String query) async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );
    return _visibleNodes(result.map((json) => MemoryNode.fromMap(json)));
  }

  Future<int> deleteNode(int id) async => softDeleteNode(id);

  Future<int> softDeleteNode(int id) async {
    final db = await instance.database;
    return db.update(
      'memory_nodes',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreNode(int id) async {
    final db = await instance.database;
    return db.update(
      'memory_nodes',
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> permanentlyDeleteNode(int id) async {
    final db = await instance.database;
    return db.delete('memory_nodes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MemoryNode>> fetchDeletedNodes() async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return result.map((json) => MemoryNode.fromMap(json)).toList();
  }

  Future<int> purgeExpiredDeletedNodes() async {
    final db = await instance.database;
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    return db.delete(
      'memory_nodes',
      where: 'deleted_at IS NOT NULL AND deleted_at <= ?',
      whereArgs: [cutoff],
    );
  }

  List<MemoryNode> _visibleNodes(Iterable<MemoryNode> nodes) {
    final seenScreenshotFiles = <String>{};
    final seenOngoingNotifications = <String>{};
    final recentSimilarNotifications = <String, DateTime>{};
    return nodes.where((node) {
      if (node.deletedAt != null) return false;

      if (isMarketingNotificationRecord(
        source: node.source,
        metadata: node.metadata,
        title: node.title,
        content: node.content,
      )) {
        return false;
      }

      if (isNotificationRemovalRecord(node.source)) return false;

      if (isScreenshotFileRecord(
        source: node.source,
        metadata: node.metadata,
      )) {
        final fileName = extractScreenshotFileName(
          node.metadata,
        )?.toLowerCase();
        if (fileName != null && !seenScreenshotFiles.add(fileName)) {
          return false;
        }
      }

      final ongoingKey = ongoingNotificationDedupeKey(
        source: node.source,
        title: node.title,
        metadata: node.metadata,
      );
      if (ongoingKey != null && !seenOngoingNotifications.add(ongoingKey)) {
        return false;
      }

      final shortWindowKey = shortWindowNotificationDedupeKey(
        source: node.source,
        title: node.title,
        content: node.content,
        metadata: node.metadata,
      );
      if (shortWindowKey != null) {
        final latestSeen = recentSimilarNotifications[shortWindowKey];
        if (latestSeen != null &&
            latestSeen.difference(node.timestamp).abs() <=
                const Duration(minutes: 5)) {
          return false;
        }
        recentSimilarNotifications[shortWindowKey] = node.timestamp;
      }

      return !isScreenshotCaptureNotificationRecord(
        source: node.source,
        metadata: node.metadata,
        title: node.title,
        content: node.content,
      );
    }).toList();
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('memory_nodes');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((column) => column['name'] == columnName);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
    }
  }
}
