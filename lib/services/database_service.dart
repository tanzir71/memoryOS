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

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS memory_nodes');
      await db.execute('DROP TABLE IF EXISTS settings');
      await _createDB(db, newVersion);
    } else if (oldVersion < 6) {
      await _addColumnIfMissing(db, 'memory_nodes', 'deleted_at TEXT');
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
    // Auto-classify if trail is 'none' or empty
    String trail = node.trail;
    if (trail == 'none' || trail.isEmpty) {
      trail = classifyTrail(node.title, node.content);
    }

    final updatedNode = node.copyWith(trail: trail);
    return await db.insert('memory_nodes', updatedNode.toMap());
  }

  Future<int> updateNode(MemoryNode node) async {
    if (node.id == null) {
      throw ArgumentError('Cannot update a memory node without an id.');
    }

    final db = await instance.database;
    final trail = node.trail == 'none' || node.trail.isEmpty
        ? classifyTrail(node.title, node.content)
        : node.trail;
    return await db.update(
      'memory_nodes',
      node.copyWith(trail: trail).toMap()..remove('id'),
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

  Future<List<MemoryNode>> fetchNodesByTrail(String trail) async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'trail = ?',
      whereArgs: [trail],
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

  Future<List<String>> getDynamicThreads() async {
    final nodes = await fetchAllNodes();
    if (nodes.isEmpty) {
      return [];
    }

    final stopWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'to',
      'of',
      'in',
      'for',
      'with',
      'on',
      'at',
      'by',
      'from',
      'is',
      'was',
      'were',
      'are',
      'have',
      'has',
      'had',
      'this',
      'that',
      'these',
      'those',
      'read',
      'note',
      'recorded',
      'completed',
      'visited',
      'about',
      'issue',
      'system',
      'been',
      'what',
      'where',
      'when',
      'who',
      'how',
      'why',
      'will',
      'would',
      'could',
      'should',
      'received',
      'sent',
      'shared',
      'duration',
      'active',
      'session',
      'your',
      'then',
      'than',
      'them',
      'their',
      'there',
      'they',
      'just',
      'more',
      'some',
      'only',
      'other',
      'into',
      'over',
      'also',
      'after',
      'before',
      'each',
      'many',
      'very',
      'such',
      'much',
      'same',
      'both',
      'through',
      'under',
      'between',
      'during',
      'saved',
      'done',
      'going',
      'make',
      'check',
      'take',
      'find',
      'look',
      'view',
      'seen',
      'show',
      'keep',
      'need',
      'want',
      'does',
      'file',
      'data',
      'text',
      'info',
      'here',
      'without',
    };

    final Map<String, int> counts = {};
    // Extract alphanumeric words with length >= 3
    final RegExp wordRegex = RegExp(r'\b[A-Za-z]{3,}\b');

    for (final node in nodes) {
      final combinedText = '${node.title} ${node.content}';
      final matches = wordRegex.allMatches(combinedText);
      for (final match in matches) {
        final rawWord = match.group(0)!;
        final lower = rawWord.toLowerCase();
        if (stopWords.contains(lower)) continue;

        // Standardize word title-casing to look clean and group proper nouns correctly
        String formatted = rawWord;
        if (rawWord[0] == rawWord[0].toUpperCase()) {
          formatted = rawWord;
        } else {
          formatted = rawWord[0].toUpperCase() + rawWord.substring(1);
        }

        counts[formatted] = (counts[formatted] ?? 0) + 1;
      }
    }

    // Sort by count descending
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Gather unique top popular words (which are primarily nouns)
    return sorted.map((e) => e.key).take(6).toList();
  }

  // Fetch nodes containing the dynamic noun keyword in their content or title
  Future<List<MemoryNode>> fetchNodesByDynamicThread(String keyword) async {
    final db = await instance.database;
    await purgeExpiredDeletedNodes();
    final result = await db.query(
      'memory_nodes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'timestamp DESC',
    );
    return _visibleNodes(result.map((json) => MemoryNode.fromMap(json)));
  }

  Future<int> deleteNode(int id) async {
    return softDeleteNode(id);
  }

  Future<int> softDeleteNode(int id) async {
    final db = await instance.database;
    return await db.update(
      'memory_nodes',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreNode(int id) async {
    final db = await instance.database;
    return await db.update(
      'memory_nodes',
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> permanentlyDeleteNode(int id) async {
    final db = await instance.database;
    return await db.delete('memory_nodes', where: 'id = ?', whereArgs: [id]);
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
    return await db.delete(
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
      if (node.deletedAt != null) {
        return false;
      }

      if (isMarketingNotificationRecord(
        source: node.source,
        metadata: node.metadata,
        title: node.title,
        content: node.content,
      )) {
        return false;
      }

      if (isNotificationRemovalRecord(node.source)) {
        return false;
      }
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
}
