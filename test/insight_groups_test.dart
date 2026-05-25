import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/services/insight_terms.dart';

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
      timestamp: timestamp ?? DateTime(2026, 5, 24, 8),
      title: title,
      content: content,
      source: source,
      metadata: metadata,
      trail: 'none',
    );
  }

  test('extractInsightGroups ranks apps before generic repeated nouns', () {
    final groups = extractInsightGroups([
      for (var i = 0; i < 7; i += 1)
        node(
          title: 'Android Google battery update',
          content: 'Battery notification update from Android system.',
          metadata: const {
            'packageName': 'com.android.systemui',
            'appName': 'System UI',
          },
        ),
      node(
        title: 'WhatsApp: Farhan',
        content: 'Farhan: Can you review the invoice?',
        metadata: const {
          'packageName': 'com.whatsapp',
          'appName': 'WhatsApp',
          'importanceTier': 'high',
          'importanceReason': 'Conversation from WhatsApp',
          'registryCategory': 'messaging',
          'conversationSender': 'Farhan',
        },
      ),
      node(
        title: 'Gmail: Nadia',
        content: 'Proposal notes are ready.',
        metadata: const {
          'packageName': 'com.google.android.gm',
          'appName': 'Gmail',
          'registryCategory': 'email',
          'conversationSender': 'Nadia',
        },
      ),
      node(
        title: 'Slack: Maya',
        content: 'Maya: Standup note is ready.',
        metadata: const {
          'packageName': 'com.slack',
          'appName': 'Slack',
          'registryCategory': 'messaging',
          'conversationSender': 'Maya',
        },
      ),
      node(
        title: 'Foodpanda order',
        content: 'Lunch order delivered.',
        metadata: const {
          'packageName': 'com.global.foodpanda.android',
          'appName': 'Foodpanda',
        },
      ),
      node(
        title: 'Chaldal receipt',
        content: 'Grocery receipt for spinach and oats.',
        metadata: const {
          'packageName': 'com.chaldal.poached',
          'appName': 'Chaldal',
        },
      ),
      node(
        title: 'Strava workout',
        content: 'Workout complete: 5 km run.',
        metadata: const {'packageName': 'com.strava', 'appName': 'Strava'},
      ),
    ], limit: 6);

    final labels = groups.map((group) => group.label).toList();

    expect(labels, containsAll(['WhatsApp', 'Gmail', 'Slack']));
    expect(labels, contains(anyOf('Foodpanda', 'Chaldal', 'Strava')));
    expect(labels, isNot(contains('Android')));
    expect(labels, isNot(contains('Google')));
    expect(labels, isNot(contains('Battery')));
    expect(labels, isNot(contains('System UI')));
  });

  test('nodeMatchesInsightGroup matches app names and package fragments', () {
    final group = const InsightGroup(
      label: 'WhatsApp',
      normalized: 'whatsapp',
      category: 'messaging',
      score: 1,
      count: 1,
      packageHints: {'com.whatsapp', 'whatsapp'},
    );

    expect(
      nodeMatchesInsightGroup(
        node(
          title: 'WhatsApp: Farhan',
          content: 'Can you review this?',
          metadata: const {'packageName': 'com.whatsapp'},
        ),
        group,
      ),
      isTrue,
    );
    expect(
      nodeMatchesInsightGroup(
        node(
          title: 'Mail update',
          content: 'A WhatsApp logo was mentioned in text only.',
          metadata: const {'packageName': 'com.google.android.gm'},
        ),
        group,
      ),
      isFalse,
    );
  });

  test(
    'extractInsightGroups falls back to useful noun topics without app metadata',
    () {
      final groups = extractInsightGroups([
        node(
          title: 'Garden planning',
          content: 'Discussed compost schedule and balcony herbs.',
          source: 'voice_note',
        ),
      ]);

      expect(groups.map((group) => group.label), contains('Garden Planning'));
      expect(groups, isNotEmpty);
      expect(groups.every((group) => group.category == 'topic'), isTrue);
    },
  );
}
