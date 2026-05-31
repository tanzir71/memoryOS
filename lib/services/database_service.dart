import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/memory_node.dart';
import 'capture_metadata.dart';
import 'app_category_registry.dart';
import 'insight_index_service.dart';
import 'memory_node_visibility.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static String _databaseName = 'memoryos.db';
  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  DatabaseService._init();

  Stream<void> get changes => _changesController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<void> resetForTesting({String? databaseName}) async {
    final current = _database;
    _database = null;
    if (current != null) {
      await current.close();
    }
    if (databaseName != null) {
      _databaseName = databaseName;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await deleteDatabase(path);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      if (await _tableExists(db, 'memory_nodes')) {
        await _addColumnIfMissing(db, 'memory_nodes', 'deleted_at TEXT');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await _createIndexes(db);
        await InsightIndexService.instance.createSchema(db);
        return;
      }
      await db.execute('DROP TABLE IF EXISTS memory_nodes');
      await db.execute('DROP TABLE IF EXISTS settings');
      await _createDB(db, newVersion);
      return;
    }
    if (oldVersion < 6) {
      await _addColumnIfMissing(db, 'memory_nodes', 'deleted_at TEXT');
    }
    if (oldVersion < 7) {
      await _createIndexes(db);
    }
    if (oldVersion < 8) {
      await InsightIndexService.instance.createSchema(db);
    }
  }

  Future _createDB(Database db, int version) async {
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

    await _createIndexes(db);
    await InsightIndexService.instance.createSchema(db);

    // Pre-populate with beautiful high-fidelity mock data from the Stitch screens!
    await _prepopulateData(db);
  }

  // Settings Helper Functions
  Future<void> saveSetting(String key, String value) async {
    try {
      final db = await instance.database;
      await db.insert('settings', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      // Fallback silently if database is not initialized (e.g. in widget/unit tests)
    }
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
    } catch (_) {
      // Return null if table/key/database doesn't exist
    }
    return null;
  }

  Future<AppCategoryRegistry> loadAppCategoryRegistry() async {
    final value = await getSetting(AppCategoryRegistry.settingsKey);
    final registry = AppCategoryRegistry.fromSettingsValue(value);
    AppCategoryRegistry.active = registry;
    return registry;
  }

  Future<void> saveAppCategoryRegistry(AppCategoryRegistry registry) async {
    await saveSetting(
      AppCategoryRegistry.settingsKey,
      registry.toSettingsValue(),
    );
    AppCategoryRegistry.active = registry;
    try {
      final db = await instance.database;
      await InsightIndexService.instance.markRegistryChanged(db);
    } catch (_) {
      // Keep widget/unit tests without a database factory lightweight.
    }
    _emitChange();
  }

  // Auto-classify trail based on keywords
  static String classifyTrail(String title, String content) {
    final text = '$title $content'.toLowerCase();
    if (text.contains('tax') ||
        text.contains('insurance') ||
        text.contains('brac') ||
        text.contains('policy') ||
        text.contains('invoice') ||
        text.contains('receipt')) {
      return 'tax';
    }
    if (text.contains('solar') ||
        text.contains('battery') ||
        text.contains('inverter') ||
        text.contains('anode') ||
        text.contains('efficiency') ||
        text.contains('nanotube') ||
        text.contains('cabling') ||
        text.contains('lab')) {
      return 'project_memory';
    }
    if (text.contains('health') ||
        text.contains('medical') ||
        text.contains('exercise') ||
        text.contains('run') ||
        text.contains('gym') ||
        text.contains('doctor') ||
        text.contains('hospital') ||
        text.contains('workout')) {
      return 'health';
    }
    if (text.contains('brother') ||
        text.contains('mom') ||
        text.contains('dad') ||
        text.contains('wife') ||
        text.contains('shared') ||
        text.contains('quote') ||
        text.contains('whatsapp') ||
        text.contains('family')) {
      return 'relationship_memory';
    }
    if (text.contains('work') ||
        text.contains('office') ||
        text.contains('meeting') ||
        text.contains('journal') ||
        text.contains('task') ||
        text.contains('client')) {
      return 'work';
    }
    return 'none';
  }

  Future<int> insertNode(MemoryNode node) async {
    final db = await instance.database;
    if (node.source == 'notification') {
      await loadAppCategoryRegistry();
      if (isDeniedNotificationRecord(
        source: node.source,
        metadata: node.metadata,
      )) {
        return 0;
      }
    }

    // Auto-classify if trail is 'none' or empty
    String trail = node.trail;
    if (trail == 'none' || trail.isEmpty) {
      trail = classifyTrail(node.title, node.content);
    }

    final updatedNode = node.copyWith(trail: trail);
    final id = await db.insert('memory_nodes', updatedNode.toMap());
    _emitChange();
    return id;
  }

  Future<int> updateNode(MemoryNode node) async {
    if (node.id == null) {
      throw ArgumentError('Cannot update a memory node without an id.');
    }

    final db = await instance.database;
    final trail = node.trail == 'none' || node.trail.isEmpty
        ? classifyTrail(node.title, node.content)
        : node.trail;
    final count = await db.update(
      'memory_nodes',
      node.copyWith(trail: trail).toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [node.id],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, [node.id!]);
      _emitChange();
    }
    return count;
  }

  Future<List<MemoryNode>> fetchAllNodes() async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'deleted_at IS NULL',
      orderBy: 'timestamp DESC',
    );
    return filterVisibleMemoryNodes(
      result.map((json) => MemoryNode.fromMap(json)),
    );
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
      where: 'deleted_at IS NULL AND timestamp BETWEEN ? AND ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'timestamp DESC',
    );
    return filterVisibleMemoryNodes(
      result.map((json) => MemoryNode.fromMap(json)),
    );
  }

  Future<List<MemoryNode>> fetchNodesByTrail(String trail) async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'deleted_at IS NULL AND trail = ?',
      whereArgs: [trail],
      orderBy: 'timestamp DESC',
    );
    return filterVisibleMemoryNodes(
      result.map((json) => MemoryNode.fromMap(json)),
    );
  }

  Future<List<MemoryNode>> searchNodes(String query) async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'deleted_at IS NULL AND (title LIKE ? OR content LIKE ?)',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );
    return filterVisibleMemoryNodes(
      result.map((json) => MemoryNode.fromMap(json)),
    );
  }

  Future<List<String>> getDynamicThreads() async {
    return fetchDynamicInsightThreads();
  }

  Future<void> ensureInsightIndexFresh() async {
    await loadAppCategoryRegistry();
    final db = await instance.database;
    await InsightIndexService.instance.ensureFresh(db);
  }

  Future<InsightSnapshot> fetchInsightSnapshot({
    required InsightTimeRange range,
    String selectedKeyword = 'All',
    int limit = 6,
  }) async {
    await loadAppCategoryRegistry();
    final db = await instance.database;
    return InsightIndexService.instance.fetchSnapshot(
      db,
      range: range,
      selectedKeyword: selectedKeyword,
      limit: limit,
    );
  }

  Future<List<String>> fetchDynamicInsightThreads({int limit = 6}) async {
    await loadAppCategoryRegistry();
    final db = await instance.database;
    return InsightIndexService.instance.fetchDynamicThreads(db, limit: limit);
  }

  // Fetch nodes matching the app-first dynamic group, with noun fallback.
  Future<List<MemoryNode>> fetchNodesByDynamicThread(String keyword) async {
    return fetchNodesForInsightGroup(keyword);
  }

  Future<List<MemoryNode>> fetchNodesForInsightGroup(
    String label, {
    InsightTimeRange? range,
    int limit = 100,
    int offset = 0,
  }) async {
    await loadAppCategoryRegistry();
    final db = await instance.database;
    return InsightIndexService.instance.fetchNodesForGroup(
      db,
      label,
      range: range,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> deleteNode(int id) async {
    return softDeleteNode(id);
  }

  Future<int> softDeleteNode(int id) async {
    final db = await instance.database;
    final count = await db.update(
      'memory_nodes',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, [id]);
      _emitChange();
    }
    return count;
  }

  Future<int> softDeleteNodesByDate(DateTime date) async {
    final db = await instance.database;
    final affectedIds = await _idsWhere(
      db,
      'timestamp >= ? AND timestamp < ? AND deleted_at IS NULL',
      [_startOfDayIso(date), _startOfNextDayIso(date)],
    );
    final count = await db.update(
      'memory_nodes',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'timestamp >= ? AND timestamp < ? AND deleted_at IS NULL',
      whereArgs: [_startOfDayIso(date), _startOfNextDayIso(date)],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, affectedIds);
      _emitChange();
    }
    return count;
  }

  Future<int> restoreNode(int id) async {
    final db = await instance.database;
    final count = await db.update(
      'memory_nodes',
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, [id]);
      _emitChange();
    }
    return count;
  }

  Future<int> permanentlyDeleteNode(int id) async {
    final db = await instance.database;
    final count = await db.delete(
      'memory_nodes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, [id]);
      _emitChange();
    }
    return count;
  }

  Future<int> permanentlyDeleteDeletedNodesByDate(DateTime date) async {
    final db = await instance.database;
    final affectedIds = await _idsWhere(
      db,
      'deleted_at IS NOT NULL AND timestamp >= ? AND timestamp < ?',
      [_startOfDayIso(date), _startOfNextDayIso(date)],
    );
    final count = await db.delete(
      'memory_nodes',
      where: 'deleted_at IS NOT NULL AND timestamp >= ? AND timestamp < ?',
      whereArgs: [_startOfDayIso(date), _startOfNextDayIso(date)],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, affectedIds);
      _emitChange();
    }
    return count;
  }

  Future<int> permanentlyDeleteAllDeletedNodes() async {
    final db = await instance.database;
    final affectedIds = await _idsWhere(db, 'deleted_at IS NOT NULL', []);
    final count = await db.delete(
      'memory_nodes',
      where: 'deleted_at IS NOT NULL',
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, affectedIds);
      _emitChange();
    }
    return count;
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
    final affectedIds = await _idsWhere(
      db,
      'deleted_at IS NOT NULL AND deleted_at <= ?',
      [cutoff],
    );
    final count = await db.delete(
      'memory_nodes',
      where: 'deleted_at IS NOT NULL AND deleted_at <= ?',
      whereArgs: [cutoff],
    );
    if (count > 0) {
      await InsightIndexService.instance.removeNodes(db, affectedIds);
    }
    return count;
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('memory_nodes');
    await InsightIndexService.instance.clear(db);
    _emitChange();
  }

  Future<void> _prepopulateData(Database db) async {
    // Database is empty at first for real-world contextual recording
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

  Future<bool> _tableExists(Database db, String table) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );
    return rows.isNotEmpty;
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_memory_nodes_timestamp
      ON memory_nodes(timestamp DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_memory_nodes_trail_timestamp
      ON memory_nodes(trail, timestamp DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_memory_nodes_source_timestamp
      ON memory_nodes(source, timestamp DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_memory_nodes_deleted_at
      ON memory_nodes(deleted_at)
    ''');
  }

  Future<List<int>> _idsWhere(
    Database db,
    String where,
    List<Object?> whereArgs,
  ) async {
    final rows = await db.query(
      'memory_nodes',
      columns: ['id'],
      where: where,
      whereArgs: whereArgs,
    );
    return rows.map((row) => row['id']).whereType<int>().toList();
  }

  void _emitChange() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  String _startOfDayIso(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  String _startOfNextDayIso(DateTime date) {
    return DateTime(date.year, date.month, date.day + 1).toIso8601String();
  }
}
