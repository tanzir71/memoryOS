import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/services/app_category_registry.dart';
import 'package:memoryos/services/health_timeline.dart';

void main() {
  MemoryNode node({
    required String title,
    required String content,
    String source = 'notification',
    Map<String, dynamic> metadata = const {},
    DateTime? timestamp,
  }) {
    return MemoryNode(
      id: title.hashCode,
      timestamp: timestamp ?? DateTime(2026, 5, 25, 9),
      title: title,
      content: content,
      source: source,
      metadata: metadata,
      trail: 'none',
    );
  }

  test(
    'identifies food grocery and fitness notifications as health events',
    () {
      final events = filterHealthTimelineEvents([
        node(
          title: 'Foodpanda: Lunch delivered',
          content: 'Your salad bowl order has arrived.',
          metadata: const {'packageName': 'com.global.foodpanda.android'},
        ),
        node(
          title: 'Instacart: Grocery receipt',
          content: 'Milk, spinach, eggs and oats were purchased.',
          metadata: const {'packageName': 'com.instacart.client'},
        ),
        node(
          title: 'Samsung Health',
          content: 'Workout complete: 42 minutes and 430 calories.',
          metadata: const {'packageName': 'com.sec.android.app.shealth'},
        ),
        node(
          title: 'WhatsApp: Farhan',
          content: 'Can you review the inverter quote?',
          metadata: const {'packageName': 'com.whatsapp'},
        ),
      ]);

      expect(events.map((event) => event.title), [
        'Foodpanda: Lunch delivered',
        'Instacart: Grocery receipt',
        'Samsung Health',
      ]);
    },
  );

  test('builds a health report with grouped event details', () {
    final report = buildHealthTimelineReport([
      node(
        title: 'Grocery receipt',
        content: 'Spinach and oats purchased.',
        metadata: const {'packageName': 'com.instacart.client'},
      ),
      node(
        title: 'Workout complete',
        content: 'Ran 5 km.',
        metadata: const {'packageName': 'com.strava'},
      ),
    ], generatedAt: DateTime(2026, 5, 25, 10));

    expect(report, contains('# Health Timeline Report'));
    expect(report, contains('Generated: 2026-05-25 10:00'));
    expect(report, contains('## Grocery'));
    expect(report, contains('## Fitness'));
    expect(report, contains('Spinach and oats purchased.'));
    expect(report, contains('Ran 5 km.'));
  });

  test('does not tag non-health apps even when text contains health words', () {
    final events = filterHealthTimelineEvents([
      node(
        title: 'YouTube: Healthy meal prep',
        content: 'Watch a video about food, activity and calories.',
        metadata: const {'packageName': 'com.google.android.youtube'},
      ),
      node(
        title: 'Truecaller: Phone activity',
        content: 'Caller ID activity for Food Court.',
        metadata: const {'packageName': 'com.truecaller'},
      ),
      node(
        title: 'Phone',
        content: 'Missed call from Health Clinic.',
        metadata: const {'packageName': 'com.samsung.android.dialer'},
      ),
      node(
        title: 'Battery Life',
        content: 'Battery health and activity summary.',
        metadata: const {'packageName': 'com.digibites.accubattery'},
      ),
      node(
        title: 'System UI',
        content: 'Background activity from food app.',
        metadata: const {'packageName': 'com.android.systemui'},
      ),
    ]);

    expect(events, isEmpty);
  });

  test('uses user-added app aliases for local food apps', () {
    final registry = const AppCategoryRegistry().copyWithUserAlias(
      AppCategory.food,
      'com.local.tiffinbox',
    );

    final events = filterHealthTimelineEvents([
      node(
        title: 'TiffinBox',
        content: 'Lunch order delivered with rice and dal.',
        metadata: const {'packageName': 'com.local.tiffinbox'},
      ),
    ], registry: registry);

    expect(events.single.title, 'TiffinBox');
  });

  test('user deny aliases keep matching apps out of health events', () {
    final registry = const AppCategoryRegistry().copyWithDeniedAlias(
      'com.global.foodpanda.android',
    );

    final events = filterHealthTimelineEvents([
      node(
        title: 'Foodpanda: Lunch delivered',
        content: 'Your salad bowl order has arrived.',
        metadata: const {'packageName': 'com.global.foodpanda.android'},
      ),
    ], registry: registry);

    expect(events, isEmpty);
  });
}
