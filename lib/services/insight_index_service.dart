import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/memory_node.dart';
import 'app_category_registry.dart';
import 'insight_aggregator.dart';
import 'insight_terms.dart';
import 'memory_node_visibility.dart';

class InsightTimeRange {
  const InsightTimeRange._({this.start, this.endExclusive});

  factory InsightTimeRange.last24Hours({DateTime? now}) {
    final anchor = now ?? DateTime.now();
    return InsightTimeRange._(
      start: anchor.subtract(const Duration(hours: 24)),
      endExclusive: anchor.add(const Duration(microseconds: 1)),
    );
  }

  factory InsightTimeRange.last7Days({DateTime? now}) {
    final anchor = now ?? DateTime.now();
    return InsightTimeRange._(
      start: anchor.subtract(const Duration(days: 7)),
      endExclusive: anchor.add(const Duration(microseconds: 1)),
    );
  }

  factory InsightTimeRange.allTime() => const InsightTimeRange._();

  factory InsightTimeRange.custom(DateTime? start, DateTime? endExclusive) {
    return InsightTimeRange._(start: start, endExclusive: endExclusive);
  }

  final DateTime? start;
  final DateTime? endExclusive;
}

class InsightItem {
  const InsightItem({
    required this.keyword,
    required this.count,
    required this.sources,
    required this.latestTimestamp,
    required this.summary,
  });

  final String keyword;
  final int count;
  final List<String> sources;
  final DateTime latestTimestamp;
  final String summary;
}

class InsightSnapshot {
  const InsightSnapshot({
    required this.filters,
    required this.items,
    required this.isIndexing,
    required this.indexedNodeCount,
    required this.totalNodeCount,
  });

  final List<String> filters;
  final List<InsightItem> items;
  final bool isIndexing;
  final int indexedNodeCount;
  final int totalNodeCount;
}

class InsightIndexService {
  InsightIndexService._();

  static final InsightIndexService instance = InsightIndexService._();
  static const int algorithmVersion = 1;
  static int debugRawNodeLoads = 0;

  static const _metaAlgorithmKey = 'algorithm_version';
  static const _metaRegistryHashKey = 'registry_hash';

  Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS insight_index_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS insight_node_index (
        node_id INTEGER PRIMARY KEY,
        timestamp TEXT NOT NULL,
        bucket_start TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        source TEXT NOT NULL,
        metadata TEXT NOT NULL,
        trail TEXT NOT NULL,
        is_starred INTEGER NOT NULL DEFAULT 0,
        deleted_at TEXT,
        is_visible INTEGER NOT NULL,
        registry_hash TEXT NOT NULL,
        algorithm_version INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS insight_term_index (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        node_id INTEGER NOT NULL,
        bucket_start TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        kind TEXT NOT NULL,
        label TEXT NOT NULL,
        normalized TEXT NOT NULL,
        category TEXT NOT NULL,
        score REAL NOT NULL,
        sources_json TEXT NOT NULL,
        registry_hash TEXT NOT NULL,
        algorithm_version INTEGER NOT NULL,
        UNIQUE(node_id, kind, normalized, registry_hash, algorithm_version)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS insight_bucket_rollups (
        bucket_start TEXT NOT NULL,
        kind TEXT NOT NULL,
        normalized TEXT NOT NULL,
        label TEXT NOT NULL,
        category TEXT NOT NULL,
        count INTEGER NOT NULL,
        score REAL NOT NULL,
        latest_timestamp TEXT NOT NULL,
        latest_node_id INTEGER,
        sources_json TEXT NOT NULL,
        registry_hash TEXT NOT NULL,
        algorithm_version INTEGER NOT NULL,
        PRIMARY KEY (
          bucket_start,
          kind,
          normalized,
          registry_hash,
          algorithm_version
        )
      )
    ''');
    await _createIndexes(db);
  }

  Future<void> ensureFresh(Database db, {int batchSize = 250}) async {
    await createSchema(db);
    final registryHash = currentRegistryHash;
    if (!await _hasCurrentMeta(db, registryHash)) {
      await rebuild(db);
      return;
    }

    await db.delete(
      'insight_node_index',
      where:
          'algorithm_version != ? OR registry_hash != ? OR node_id NOT IN '
          '(SELECT id FROM memory_nodes)',
      whereArgs: [algorithmVersion, registryHash],
    );
    await db.delete(
      'insight_term_index',
      where:
          'algorithm_version != ? OR registry_hash != ? OR node_id NOT IN '
          '(SELECT id FROM memory_nodes)',
      whereArgs: [algorithmVersion, registryHash],
    );

    var indexedAnyRows = false;
    while (true) {
      final rows = await _loadUnindexedRows(db, registryHash, batchSize);
      if (rows.isEmpty) break;
      await _indexRows(db, rows, registryHash, rebuildRollups: false);
      indexedAnyRows = true;
      await Future<void>.delayed(Duration.zero);
    }
    if (indexedAnyRows) {
      await _rebuildAllRollups(db, registryHash);
    }
  }

  Future<void> rebuild(Database db, {int batchSize = 250}) async {
    await createSchema(db);
    final registryHash = currentRegistryHash;
    await db.transaction((txn) async {
      await txn.delete('insight_bucket_rollups');
      await txn.delete('insight_term_index');
      await txn.delete('insight_node_index');
      await _setCurrentMeta(txn, registryHash);
    });

    var offset = 0;
    var indexedAnyRows = false;
    while (true) {
      final rows = await _loadRows(db, limit: batchSize, offset: offset);
      if (rows.isEmpty) break;
      final nodes = rows.map(MemoryNode.fromMap).toList();
      final visibleIds = filterVisibleMemoryNodes(
        nodes,
      ).map((node) => node.id).whereType<int>().toSet();
      await _indexRows(
        db,
        rows,
        registryHash,
        visibleIdsOverride: visibleIds,
        rebuildRollups: false,
      );
      indexedAnyRows = true;
      offset += rows.length;
      await Future<void>.delayed(Duration.zero);
    }
    if (indexedAnyRows) {
      await _rebuildAllRollups(db, registryHash);
    }
  }

  Future<void> indexNode(Database db, int nodeId) async {
    await createSchema(db);
    final registryHash = currentRegistryHash;
    if (!await _hasCurrentMeta(db, registryHash)) {
      await rebuild(db);
      return;
    }
    final rows = await _loadRowsByIds(db, [nodeId]);
    await _indexRows(db, rows, registryHash);
  }

  Future<void> indexNodes(Database db, Iterable<int> nodeIds) async {
    final ids = nodeIds.toSet();
    if (ids.isEmpty) return;
    await createSchema(db);
    final registryHash = currentRegistryHash;
    if (!await _hasCurrentMeta(db, registryHash)) {
      await rebuild(db);
      return;
    }
    final rows = await _loadRowsByIds(db, ids);
    await _indexRows(db, rows, registryHash, explicitIds: ids);
  }

  Future<void> removeNodes(Database db, Iterable<int> nodeIds) async {
    final ids = nodeIds.toSet();
    if (ids.isEmpty) return;
    await createSchema(db);
    final registryHash = currentRegistryHash;
    final oldBuckets = await _bucketsForNodes(db, ids);
    final placeholders = List.filled(ids.length, '?').join(', ');
    await db.transaction((txn) async {
      await txn.delete(
        'insight_term_index',
        where: 'node_id IN ($placeholders)',
        whereArgs: ids.toList(),
      );
      await txn.delete(
        'insight_node_index',
        where: 'node_id IN ($placeholders)',
        whereArgs: ids.toList(),
      );
      await _rebuildRollupsForBuckets(txn, oldBuckets, registryHash);
    });
  }

  Future<void> clear(Database db) async {
    await createSchema(db);
    await db.transaction((txn) async {
      await txn.delete('insight_bucket_rollups');
      await txn.delete('insight_term_index');
      await txn.delete('insight_node_index');
      await _setCurrentMeta(txn, currentRegistryHash);
    });
  }

  Future<void> markRegistryChanged(Database db) async {
    await createSchema(db);
    await db.delete(
      'insight_index_meta',
      where: 'key IN (?, ?)',
      whereArgs: [_metaAlgorithmKey, _metaRegistryHashKey],
    );
  }

  Future<InsightSnapshot> fetchSnapshot(
    Database db, {
    required InsightTimeRange range,
    String selectedKeyword = 'All',
    int limit = 6,
  }) async {
    await ensureFresh(db);
    final registryHash = currentRegistryHash;
    final kind = await _preferredKind(db, range, registryHash);
    final topTerms = await _topTerms(
      db,
      kind: kind,
      range: range,
      registryHash: registryHash,
      limit: limit,
    );
    final filters = ['All', ...topTerms.map((term) => term.label)];
    final effectiveSelected = filters.contains(selectedKeyword)
        ? selectedKeyword
        : 'All';
    final selectedTerms = effectiveSelected == 'All'
        ? topTerms
        : await _termsForLabel(
            db,
            kind: kind,
            label: effectiveSelected,
            range: range,
            registryHash: registryHash,
          );

    final items = <InsightItem>[];
    for (final term in selectedTerms.take(limit)) {
      final nodes = await _nodesForTerm(
        db,
        kind: term.kind,
        normalized: term.normalized,
        range: range,
        registryHash: registryHash,
      );
      if (nodes.isEmpty) continue;
      if (nodes.length > 200) {
        items.add(_largeGroupItem(term, nodes));
        continue;
      }
      final aggregated = buildAggregatedInsights(
        nodes,
        selectedKeyword: term.label,
        limit: 1,
      );
      if (aggregated.isNotEmpty) {
        final insight = aggregated.first;
        items.add(
          InsightItem(
            keyword: insight.keyword,
            count: insight.count,
            sources: insight.sources,
            latestTimestamp: insight.latestTimestamp,
            summary: insight.summary,
          ),
        );
      } else {
        items.add(_fallbackItem(term, nodes));
      }
    }

    return InsightSnapshot(
      filters: filters,
      items: items,
      isIndexing: false,
      indexedNodeCount: await _indexedNodeCount(db, registryHash),
      totalNodeCount: await _totalNodeCount(db),
    );
  }

  Future<List<String>> fetchDynamicThreads(Database db, {int limit = 6}) async {
    final snapshot = await fetchSnapshot(
      db,
      range: InsightTimeRange.allTime(),
      limit: limit,
    );
    return snapshot.filters.skip(1).toList();
  }

  Future<List<MemoryNode>> fetchNodesForGroup(
    Database db,
    String label, {
    InsightTimeRange? range,
    int limit = 100,
    int offset = 0,
  }) async {
    await ensureFresh(db);
    final registryHash = currentRegistryHash;
    final effectiveRange = range ?? InsightTimeRange.allTime();
    final kind = await _preferredKind(db, effectiveRange, registryHash);
    final normalized = normalizeInsightTerm(label);
    return _nodesForTerm(
      db,
      kind: kind,
      normalized: normalized,
      range: effectiveRange,
      registryHash: registryHash,
      limit: limit,
      offset: offset,
    );
  }

  String get currentRegistryHash {
    final payload = jsonEncode(AppCategoryRegistry.active.toJson());
    var hash = 0x811c9dc5;
    for (final unit in payload.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<void> _createIndexes(DatabaseExecutor db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_node_time_visible
      ON insight_node_index(is_visible, timestamp DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_node_bucket
      ON insight_node_index(bucket_start)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_node_registry_version
      ON insight_node_index(registry_hash, algorithm_version)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_term_node
      ON insight_term_index(node_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_term_lookup
      ON insight_term_index(kind, normalized, timestamp DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_term_bucket
      ON insight_term_index(bucket_start, kind, normalized)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_term_registry_version
      ON insight_term_index(registry_hash, algorithm_version)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_insight_rollup_lookup
      ON insight_bucket_rollups(kind, normalized, bucket_start)
    ''');
  }

  Future<bool> _hasCurrentMeta(Database db, String registryHash) async {
    final rows = await db.query('insight_index_meta');
    final values = {
      for (final row in rows) row['key'] as String: row['value'] as String,
    };
    return values[_metaAlgorithmKey] == algorithmVersion.toString() &&
        values[_metaRegistryHashKey] == registryHash;
  }

  Future<void> _setCurrentMeta(DatabaseExecutor db, String registryHash) async {
    await db.insert('insight_index_meta', {
      'key': _metaAlgorithmKey,
      'value': algorithmVersion.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('insight_index_meta', {
      'key': _metaRegistryHashKey,
      'value': registryHash,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> _loadRows(
    Database db, {
    required int limit,
    required int offset,
  }) async {
    final rows = await db.query(
      'memory_nodes',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    debugRawNodeLoads += rows.length;
    return rows;
  }

  Future<List<Map<String, Object?>>> _loadRowsByIds(
    Database db,
    Iterable<int> ids,
  ) async {
    final idList = ids.toList();
    if (idList.isEmpty) return [];
    final placeholders = List.filled(idList.length, '?').join(', ');
    final rows = await db.query(
      'memory_nodes',
      where: 'id IN ($placeholders)',
      whereArgs: idList,
      orderBy: 'timestamp DESC',
    );
    debugRawNodeLoads += rows.length;
    return rows;
  }

  Future<List<Map<String, Object?>>> _loadUnindexedRows(
    Database db,
    String registryHash,
    int limit,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT m.*
      FROM memory_nodes m
      LEFT JOIN insight_node_index i
        ON i.node_id = m.id
       AND i.registry_hash = ?
       AND i.algorithm_version = ?
      WHERE i.node_id IS NULL
      ORDER BY m.timestamp DESC
      LIMIT ?
      ''',
      [registryHash, algorithmVersion, limit],
    );
    debugRawNodeLoads += rows.length;
    return rows;
  }

  Future<void> _indexRows(
    Database db,
    List<Map<String, Object?>> rows,
    String registryHash, {
    Set<int>? visibleIdsOverride,
    Set<int>? explicitIds,
    bool rebuildRollups = true,
  }) async {
    final ids = {
      ...rows.map((row) => row['id']).whereType<int>(),
      ...?explicitIds,
    };
    final oldBuckets = await _bucketsForNodes(db, ids);
    final newBuckets = <String>{};

    await db.transaction((txn) async {
      final batch = txn.batch();
      if (ids.isNotEmpty) {
        final placeholders = List.filled(ids.length, '?').join(', ');
        batch.delete(
          'insight_term_index',
          where: 'node_id IN ($placeholders)',
          whereArgs: ids.toList(),
        );
        batch.delete(
          'insight_node_index',
          where: 'node_id IN ($placeholders)',
          whereArgs: ids.toList(),
        );
      }

      for (final row in rows) {
        final node = MemoryNode.fromMap(row);
        final nodeId = node.id;
        if (nodeId == null) continue;
        final visible =
            visibleIdsOverride?.contains(nodeId) ??
            isIndividuallyVisibleMemoryNode(node);
        final bucketStart = _bucketStart(node.timestamp);
        newBuckets.add(bucketStart);
        _queueNodeIndex(
          batch,
          node,
          bucketStart: bucketStart,
          isVisible: visible,
          registryHash: registryHash,
        );
        if (!visible) continue;
        _queueTerms(batch, node, bucketStart, registryHash);
      }
      await batch.commit(noResult: true);

      if (rebuildRollups) {
        await _rebuildRollupsForBuckets(txn, {
          ...oldBuckets,
          ...newBuckets,
        }, registryHash);
      }
    });
  }

  void _queueNodeIndex(
    Batch batch,
    MemoryNode node, {
    required String bucketStart,
    required bool isVisible,
    required String registryHash,
  }) {
    batch.insert('insight_node_index', {
      'node_id': node.id,
      'timestamp': node.timestamp.toIso8601String(),
      'bucket_start': bucketStart,
      'title': node.title,
      'content': node.content,
      'source': node.source,
      'metadata': jsonEncode(node.metadata),
      'trail': node.trail,
      'is_starred': node.isStarred ? 1 : 0,
      'deleted_at': node.deletedAt?.toIso8601String(),
      'is_visible': isVisible ? 1 : 0,
      'registry_hash': registryHash,
      'algorithm_version': algorithmVersion,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void _queueTerms(
    Batch batch,
    MemoryNode node,
    String bucketStart,
    String registryHash,
  ) {
    final sourcesJson = jsonEncode(sourceLabelsForInsightNode(node));
    final hasAppIdentity =
        (node.metadata['packageName']?.toString().trim().isNotEmpty ?? false) ||
        (node.metadata['appName']?.toString().trim().isNotEmpty ?? false);
    if (hasAppIdentity) {
      final group = _fastAppGroupForNode(node);
      if (group != null) {
        _queueTerm(
          batch,
          node: node,
          bucketStart: bucketStart,
          kind: 'group',
          label: group.label,
          normalized: group.normalized,
          category: group.category,
          score: group.score,
          sourcesJson: sourcesJson,
          registryHash: registryHash,
        );
        return;
      }
    }

    for (final term in extractInsightTerms([node], limit: 12)) {
      _queueTerm(
        batch,
        node: node,
        bucketStart: bucketStart,
        kind: 'topic',
        label: term.label,
        normalized: term.normalized,
        category: term.category,
        score: term.score,
        sourcesJson: sourcesJson,
        registryHash: registryHash,
      );
    }
  }

  _IndexedAppGroup? _fastAppGroupForNode(MemoryNode node) {
    final registry = AppCategoryRegistry.active;
    final packageName = node.metadata['packageName']?.toString().trim() ?? '';
    final appName = node.metadata['appName']?.toString().trim() ?? '';
    if (packageName.isEmpty && appName.isEmpty) return null;
    if (registry.isDenied(packageName: packageName, appName: appName)) {
      return null;
    }

    final label = appName.isNotEmpty
        ? registry.displayLabelForAlias(appName)
        : registry.displayLabelForAlias(packageName);
    final fallbackLabel = label.trim().isEmpty
        ? registry.displayNameFor(packageName: packageName, appName: appName)
        : label;
    final normalized = normalizeInsightTerm(fallbackLabel);
    if (normalized.isEmpty || _isSuppressedIndexedAppLabel(normalized)) {
      return null;
    }

    final category =
        _metadataCategory(node) ??
        registry
            .firstMatch(packageName: packageName, appName: appName)
            ?.storageKey ??
        'app';
    final score =
        _indexedCategoryWeight(category) +
        _indexedImportanceWeight(node) +
        (node.source == 'notification' ? 6 : 0) +
        4;
    return _IndexedAppGroup(
      label: fallbackLabel,
      normalized: normalized,
      category: category,
      score: score,
    );
  }

  String? _metadataCategory(MemoryNode node) {
    final raw = node.metadata['registryCategory']?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.toLowerCase();
    for (final category in AppCategory.values) {
      if (category.storageKey == normalized) return normalized;
    }
    return null;
  }

  double _indexedCategoryWeight(String category) {
    switch (category) {
      case 'messaging':
        return 120;
      case 'email':
        return 115;
      case 'food':
      case 'grocery':
      case 'fitness':
        return 100;
      default:
        return 70;
    }
  }

  double _indexedImportanceWeight(MemoryNode node) {
    final tier = node.metadata['importanceTier']?.toString().toLowerCase();
    if (tier == 'high') return 24;
    if (tier == 'medium') return 8;
    if (tier == 'low') return -4;
    if (node.metadata['isPriorityEvent'] == true ||
        node.metadata['isPriorityEvent']?.toString().toLowerCase() == 'true') {
      return 14;
    }
    return 0;
  }

  bool _isSuppressedIndexedAppLabel(String normalized) {
    return const {
      'android',
      'android system',
      'system',
      'system ui',
      'google',
      'google play services',
      'battery',
      'battery life',
      'phone',
      'dialer',
      'device',
      'user',
      'cache',
      'null',
      'default',
      'unknown',
    }.contains(normalized);
  }

  void _queueTerm(
    Batch batch, {
    required MemoryNode node,
    required String bucketStart,
    required String kind,
    required String label,
    required String normalized,
    required String category,
    required double score,
    required String sourcesJson,
    required String registryHash,
  }) {
    batch.insert('insight_term_index', {
      'node_id': node.id,
      'bucket_start': bucketStart,
      'timestamp': node.timestamp.toIso8601String(),
      'kind': kind,
      'label': label,
      'normalized': normalized,
      'category': category,
      'score': score,
      'sources_json': sourcesJson,
      'registry_hash': registryHash,
      'algorithm_version': algorithmVersion,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Set<String>> _bucketsForNodes(
    Database db,
    Iterable<int> nodeIds,
  ) async {
    final ids = nodeIds.toSet();
    if (ids.isEmpty) return {};
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await db.query(
      'insight_term_index',
      distinct: true,
      columns: ['bucket_start'],
      where: 'node_id IN ($placeholders)',
      whereArgs: ids.toList(),
    );
    return rows
        .map((row) => row['bucket_start']?.toString() ?? '')
        .where((bucket) => bucket.isNotEmpty)
        .toSet();
  }

  Future<void> _rebuildRollupsForBuckets(
    DatabaseExecutor db,
    Set<String> buckets,
    String registryHash,
  ) async {
    for (final bucket in buckets) {
      await db.delete(
        'insight_bucket_rollups',
        where:
            'bucket_start = ? AND registry_hash = ? AND algorithm_version = ?',
        whereArgs: [bucket, registryHash, algorithmVersion],
      );
      await db.rawInsert(
        '''
        INSERT OR REPLACE INTO insight_bucket_rollups (
          bucket_start,
          kind,
          normalized,
          label,
          category,
          count,
          score,
          latest_timestamp,
          latest_node_id,
          sources_json,
          registry_hash,
          algorithm_version
        )
        SELECT
          bucket_start,
          kind,
          normalized,
          MAX(label),
          MAX(category),
          COUNT(DISTINCT node_id),
          SUM(score),
          MAX(timestamp),
          NULL,
          '[]',
          registry_hash,
          algorithm_version
        FROM insight_term_index
        WHERE bucket_start = ?
          AND registry_hash = ?
          AND algorithm_version = ?
        GROUP BY bucket_start, kind, normalized, registry_hash, algorithm_version
        ''',
        [bucket, registryHash, algorithmVersion],
      );
    }
  }

  Future<void> _rebuildAllRollups(Database db, String registryHash) async {
    await db.transaction((txn) async {
      await txn.delete(
        'insight_bucket_rollups',
        where: 'registry_hash = ? AND algorithm_version = ?',
        whereArgs: [registryHash, algorithmVersion],
      );
      await txn.rawInsert(
        '''
        INSERT OR REPLACE INTO insight_bucket_rollups (
          bucket_start,
          kind,
          normalized,
          label,
          category,
          count,
          score,
          latest_timestamp,
          latest_node_id,
          sources_json,
          registry_hash,
          algorithm_version
        )
        SELECT
          bucket_start,
          kind,
          normalized,
          MAX(label),
          MAX(category),
          COUNT(DISTINCT node_id),
          SUM(score),
          MAX(timestamp),
          NULL,
          '[]',
          registry_hash,
          algorithm_version
        FROM insight_term_index
        WHERE registry_hash = ?
          AND algorithm_version = ?
        GROUP BY bucket_start, kind, normalized, registry_hash, algorithm_version
        ''',
        [registryHash, algorithmVersion],
      );
    });
  }

  Future<String> _preferredKind(
    Database db,
    InsightTimeRange range,
    String registryHash,
  ) async {
    final groupCount = await _termCount(
      db,
      kind: 'group',
      range: range,
      registryHash: registryHash,
    );
    return groupCount > 0 ? 'group' : 'topic';
  }

  Future<int> _termCount(
    Database db, {
    required String kind,
    required InsightTimeRange range,
    required String registryHash,
  }) async {
    final where = StringBuffer(
      't.kind = ? AND t.registry_hash = ? AND t.algorithm_version = ? '
      'AND n.is_visible = 1',
    );
    final args = <Object?>[kind, registryHash, algorithmVersion];
    _appendRangeWhere(where, args, range, prefix: 'n.');
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM insight_term_index t
      INNER JOIN insight_node_index n ON n.node_id = t.node_id
      WHERE $where
      ''', args);
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<List<_TermRollup>> _topTerms(
    Database db, {
    required String kind,
    required InsightTimeRange range,
    required String registryHash,
    required int limit,
  }) async {
    final where = StringBuffer(
      't.kind = ? AND t.registry_hash = ? AND t.algorithm_version = ? '
      'AND n.is_visible = 1',
    );
    final args = <Object?>[kind, registryHash, algorithmVersion];
    _appendRangeWhere(where, args, range, prefix: 'n.');
    args.add(limit);
    final rows = await db.rawQuery('''
      SELECT
        t.kind AS kind,
        t.normalized AS normalized,
        MAX(t.label) AS label,
        MAX(t.category) AS category,
        COUNT(DISTINCT t.node_id) AS count,
        SUM(t.score) + (COUNT(DISTINCT t.node_id) * 4.0) AS rank_score,
        MAX(t.timestamp) AS latest_timestamp
      FROM insight_term_index t
      INNER JOIN insight_node_index n ON n.node_id = t.node_id
      WHERE $where
      GROUP BY t.kind, t.normalized
      ORDER BY rank_score DESC, count DESC, label ASC
      LIMIT ?
      ''', args);
    return rows.map(_TermRollup.fromRow).toList();
  }

  Future<List<_TermRollup>> _termsForLabel(
    Database db, {
    required String kind,
    required String label,
    required InsightTimeRange range,
    required String registryHash,
  }) async {
    final normalized = normalizeInsightTerm(label);
    final where = StringBuffer(
      't.kind = ? AND t.normalized = ? AND t.registry_hash = ? '
      'AND t.algorithm_version = ? AND n.is_visible = 1',
    );
    final args = <Object?>[kind, normalized, registryHash, algorithmVersion];
    _appendRangeWhere(where, args, range, prefix: 'n.');
    final rows = await db.rawQuery('''
      SELECT
        t.kind AS kind,
        t.normalized AS normalized,
        MAX(t.label) AS label,
        MAX(t.category) AS category,
        COUNT(DISTINCT t.node_id) AS count,
        SUM(t.score) AS rank_score,
        MAX(t.timestamp) AS latest_timestamp
      FROM insight_term_index t
      INNER JOIN insight_node_index n ON n.node_id = t.node_id
      WHERE $where
      GROUP BY t.kind, t.normalized
      ''', args);
    return rows.map(_TermRollup.fromRow).toList();
  }

  Future<List<MemoryNode>> _nodesForTerm(
    Database db, {
    required String kind,
    required String normalized,
    required InsightTimeRange range,
    required String registryHash,
    int? limit,
    int offset = 0,
  }) async {
    final where = StringBuffer(
      't.kind = ? AND t.normalized = ? AND t.registry_hash = ? '
      'AND t.algorithm_version = ? AND n.is_visible = 1',
    );
    final args = <Object?>[kind, normalized, registryHash, algorithmVersion];
    _appendRangeWhere(where, args, range, prefix: 'n.');
    final limitClause = limit == null ? '' : 'LIMIT ? OFFSET ?';
    if (limit != null) {
      args
        ..add(limit)
        ..add(offset);
    }
    final rows = await db.rawQuery('''
      SELECT n.*
      FROM insight_node_index n
      INNER JOIN insight_term_index t ON t.node_id = n.node_id
      WHERE $where
      ORDER BY n.timestamp DESC
      $limitClause
      ''', args);
    return rows.map(_nodeFromIndexRow).toList();
  }

  InsightItem _fallbackItem(_TermRollup term, List<MemoryNode> nodes) {
    final sources = nodes.expand(sourceLabelsForInsightNode).toSet().toList()
      ..sort();
    return InsightItem(
      keyword: term.label,
      count: nodes.length,
      sources: sources,
      latestTimestamp: nodes.first.timestamp,
      summary:
          '${nodes.length} ${nodes.length == 1 ? "memory" : "memories"} '
          'about ${term.label}. Latest note: ${nodes.first.title}.',
    );
  }

  InsightItem _largeGroupItem(_TermRollup term, List<MemoryNode> nodes) {
    final sources = nodes.expand(sourceLabelsForInsightNode).toSet().toList()
      ..sort();
    final latest = nodes.first;
    final countLabel = '${nodes.length} memories';
    final sourceLabel = sources.length == 1
        ? 'from ${sources.single}'
        : 'across ${_joinHuman(sources)}';
    final isAppGroup = term.kind == 'group' && term.category != 'topic';
    return InsightItem(
      keyword: term.label,
      count: nodes.length,
      sources: sources,
      latestTimestamp: latest.timestamp,
      summary: isAppGroup
          ? '$countLabel from ${term.label} via ${_joinHuman(sources)}. '
                'Latest note: ${latest.title}.'
          : '$countLabel about ${term.label} $sourceLabel. '
                'Latest note: ${latest.title}.',
    );
  }

  Future<int> _indexedNodeCount(Database db, String registryHash) async {
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM insight_node_index
      WHERE registry_hash = ? AND algorithm_version = ?
      ''',
      [registryHash, algorithmVersion],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> _totalNodeCount(Database db) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM memory_nodes',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  void _appendRangeWhere(
    StringBuffer where,
    List<Object?> args,
    InsightTimeRange range, {
    required String prefix,
  }) {
    if (range.start != null) {
      where.write(' AND ${prefix}timestamp >= ?');
      args.add(range.start!.toIso8601String());
    }
    if (range.endExclusive != null) {
      where.write(' AND ${prefix}timestamp < ?');
      args.add(range.endExclusive!.toIso8601String());
    }
  }

  MemoryNode _nodeFromIndexRow(Map<String, Object?> row) {
    return MemoryNode.fromMap({
      'id': row['node_id'],
      'timestamp': row['timestamp'],
      'title': row['title'],
      'content': row['content'],
      'source': row['source'],
      'metadata': row['metadata'],
      'trail': row['trail'],
      'is_starred': row['is_starred'],
      'deleted_at': row['deleted_at'],
    });
  }

  String _bucketStart(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
    ).toIso8601String();
  }

  String _joinHuman(List<String> values) {
    if (values.length <= 1) return values.join();
    if (values.length == 2) return '${values.first} and ${values.last}';
    return '${values.take(values.length - 1).join(", ")}, and ${values.last}';
  }
}

class _TermRollup {
  const _TermRollup({
    required this.kind,
    required this.normalized,
    required this.label,
    required this.category,
    required this.count,
    required this.rankScore,
    required this.latestTimestamp,
  });

  final String kind;
  final String normalized;
  final String label;
  final String category;
  final int count;
  final double rankScore;
  final DateTime latestTimestamp;

  factory _TermRollup.fromRow(Map<String, Object?> row) {
    return _TermRollup(
      kind: row['kind'] as String,
      normalized: row['normalized'] as String,
      label: row['label'] as String,
      category: row['category'] as String,
      count: row['count'] as int,
      rankScore: (row['rank_score'] as num).toDouble(),
      latestTimestamp: DateTime.parse(row['latest_timestamp'] as String),
    );
  }
}

class _IndexedAppGroup {
  const _IndexedAppGroup({
    required this.label,
    required this.normalized,
    required this.category,
    required this.score,
  });

  final String label;
  final String normalized;
  final String category;
  final double score;
}
