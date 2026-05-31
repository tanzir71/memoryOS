import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/services/app_category_registry.dart';
import 'package:memoryos/services/database_service.dart';
import 'package:memoryos/services/insight_aggregator.dart';
import 'package:memoryos/services/insight_index_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late String databaseName;

  MemoryNode node({
    required String title,
    required String content,
    String source = 'notification',
    Map<String, dynamic> metadata = const {},
    DateTime? timestamp,
  }) {
    return MemoryNode(
      timestamp: timestamp ?? DateTime(2026, 5, 24, 8),
      title: title,
      content: content,
      source: source,
      metadata: metadata,
      trail: 'none',
    );
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseName =
        'memoryos_insight_index_${DateTime.now().microsecondsSinceEpoch}.db';
    await DatabaseService.instance.resetForTesting(databaseName: databaseName);
    AppCategoryRegistry.active = const AppCategoryRegistry();
  });

  tearDown(() async {
    await DatabaseService.instance.resetForTesting(databaseName: databaseName);
    AppCategoryRegistry.active = const AppCategoryRegistry();
  });

  test('snapshot filters and items match current live aggregation', () async {
    final nodes = [
      node(
        title: 'Gmail: Nadia',
        content: 'Nadia proposal invoice is ready.',
        metadata: const {
          'packageName': 'com.google.android.gm',
          'appName': 'Gmail',
          'registryCategory': 'email',
          'conversationSender': 'Nadia',
        },
        timestamp: DateTime(2026, 5, 24, 8),
      ),
      node(
        title: 'Gmail: Lameh',
        content: 'Lameh receipt arrived for the proposal.',
        metadata: const {
          'packageName': 'com.google.android.gm',
          'appName': 'Gmail',
          'registryCategory': 'email',
          'conversationSender': 'Lameh',
        },
        timestamp: DateTime(2026, 5, 24, 9),
      ),
      node(
        title: 'YouTube saved',
        content: 'YouTube design video context.',
        metadata: const {
          'packageName': 'com.google.android.youtube',
          'appName': 'YouTube',
        },
        timestamp: DateTime(2026, 5, 24, 10),
      ),
    ];
    for (final memory in nodes) {
      await DatabaseService.instance.insertNode(memory);
    }

    final snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
      selectedKeyword: 'Gmail',
    );
    final live = buildAggregatedInsights(nodes, selectedKeyword: 'Gmail');

    expect(snapshot.filters, containsAll(['All', 'Gmail']));
    expect(snapshot.items, hasLength(live.length));
    expect(snapshot.items.single.keyword, live.single.keyword);
    expect(snapshot.items.single.count, live.single.count);
    expect(snapshot.items.single.sources, live.single.sources);
    expect(snapshot.items.single.summary, live.single.summary);
    expect(snapshot.indexedNodeCount, 3);
    expect(snapshot.totalNodeCount, 3);
  });

  test('insert delete restore and clear keep exact snapshot counts', () async {
    final firstId = await DatabaseService.instance.insertNode(
      node(
        title: 'Slack: Maya',
        content: 'Maya shared the standup note.',
        metadata: const {
          'packageName': 'com.slack',
          'appName': 'Slack',
          'registryCategory': 'messaging',
          'conversationSender': 'Maya',
        },
      ),
    );
    await DatabaseService.instance.insertNode(
      node(
        title: 'Slack: Omar',
        content: 'Omar asked about the dashboard.',
        metadata: const {
          'packageName': 'com.slack',
          'appName': 'Slack',
          'registryCategory': 'messaging',
          'conversationSender': 'Omar',
        },
      ),
    );

    var snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
      selectedKeyword: 'Slack',
    );
    expect(snapshot.items.single.count, 2);

    await DatabaseService.instance.softDeleteNode(firstId);
    snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
      selectedKeyword: 'Slack',
    );
    expect(snapshot.items.single.count, 1);

    await DatabaseService.instance.restoreNode(firstId);
    snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
      selectedKeyword: 'Slack',
    );
    expect(snapshot.items.single.count, 2);

    await DatabaseService.instance.clearDatabase();
    snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
    );
    expect(snapshot.items, isEmpty);
    expect(snapshot.filters, ['All']);
  });

  test('raw native-style inserts are indexed by freshness check', () async {
    final db = await DatabaseService.instance.database;
    await db.insert('memory_nodes', {
      'timestamp': DateTime(2026, 5, 24, 11).toIso8601String(),
      'title': 'WhatsApp: Farhan',
      'content': 'Farhan asked for the invoice review.',
      'source': 'notification',
      'metadata': jsonEncode({
        'packageName': 'com.whatsapp',
        'appName': 'WhatsApp',
        'registryCategory': 'messaging',
        'conversationSender': 'Farhan',
      }),
      'trail': 'none',
      'is_starred': 0,
      'deleted_at': null,
    });

    await DatabaseService.instance.ensureInsightIndexFresh();
    final snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
      selectedKeyword: 'WhatsApp',
    );

    expect(snapshot.items.single.keyword, 'WhatsApp');
    expect(snapshot.items.single.count, 1);
    expect(snapshot.indexedNodeCount, 1);
  });

  test('registry changes invalidate and rebuild indexed app groups', () async {
    await DatabaseService.instance.insertNode(
      node(
        title: 'TiffinBox delivery',
        content: 'Lunch delivery arrived.',
        metadata: const {
          'packageName': 'com.local.tiffinbox',
          'appName': 'TiffinBox',
        },
      ),
    );

    await DatabaseService.instance.saveAppCategoryRegistry(
      const AppCategoryRegistry().copyWithUserAlias(
        AppCategory.food,
        'com.local.tiffinbox',
      ),
    );
    var snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
    );
    expect(snapshot.filters, contains('Tiffinbox'));

    await DatabaseService.instance.saveAppCategoryRegistry(
      const AppCategoryRegistry().copyWithDeniedAlias('com.local.tiffinbox'),
    );
    snapshot = await DatabaseService.instance.fetchInsightSnapshot(
      range: InsightTimeRange.allTime(),
    );
    expect(snapshot.filters, isNot(contains('Tiffinbox')));
    expect(snapshot.items, isEmpty);
  });

  test(
    'time ranges restrict snapshots without scanning all raw nodes',
    () async {
      await DatabaseService.instance.insertNode(
        node(
          title: 'Old Gmail',
          content: 'Gmail receipt from last year.',
          metadata: const {
            'packageName': 'com.google.android.gm',
            'appName': 'Gmail',
            'registryCategory': 'email',
          },
          timestamp: DateTime(2025, 5, 24, 8),
        ),
      );
      await DatabaseService.instance.insertNode(
        node(
          title: 'Recent Gmail',
          content: 'Gmail proposal arrived today.',
          metadata: const {
            'packageName': 'com.google.android.gm',
            'appName': 'Gmail',
            'registryCategory': 'email',
          },
          timestamp: DateTime(2026, 5, 24, 8),
        ),
      );

      final recent = await DatabaseService.instance.fetchInsightSnapshot(
        range: InsightTimeRange.custom(
          DateTime(2026, 5, 23),
          DateTime(2026, 5, 25),
        ),
        selectedKeyword: 'Gmail',
      );
      final allTime = await DatabaseService.instance.fetchInsightSnapshot(
        range: InsightTimeRange.allTime(),
        selectedKeyword: 'Gmail',
      );

      expect(recent.items.single.count, 1);
      expect(allTime.items.single.count, 2);
    },
  );

  test(
    'large all-time snapshot is served from rollups',
    () async {
      const nodeCount = 1000;
      final db = await DatabaseService.instance.database;
      final batch = db.batch();
      for (var i = 0; i < nodeCount; i += 1) {
        batch.insert('memory_nodes', {
          'timestamp': DateTime(
            2026,
            1,
            1,
          ).add(Duration(hours: i)).toIso8601String(),
          'title': 'Gmail: Person $i',
          'content': 'Proposal update $i',
          'source': 'notification',
          'metadata': jsonEncode({
            'packageName': 'com.google.android.gm',
            'appName': 'Gmail',
            'registryCategory': 'email',
          }),
          'trail': 'none',
          'is_starred': 0,
          'deleted_at': null,
        });
      }
      await batch.commit(noResult: true);

      await DatabaseService.instance.ensureInsightIndexFresh();
      final before = InsightIndexService.debugRawNodeLoads;
      final snapshot = await DatabaseService.instance.fetchInsightSnapshot(
        range: InsightTimeRange.allTime(),
        selectedKeyword: 'Gmail',
      );

      expect(snapshot.items.single.count, nodeCount);
      expect(InsightIndexService.debugRawNodeLoads, before);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
