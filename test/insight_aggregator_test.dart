import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/services/insight_aggregator.dart';

void main() {
  MemoryNode node({
    required String title,
    required String content,
    String source = 'notification',
    DateTime? timestamp,
  }) {
    return MemoryNode(
      id: title.hashCode,
      timestamp: timestamp ?? DateTime(2026, 5, 24, 8),
      title: title,
      content: content,
      source: source,
      metadata: const {},
      trail: 'none',
    );
  }

  test('extractFrequentInsightKeywords ranks repeated meaningful nouns', () {
    final keywords = extractFrequentInsightKeywords([
      node(title: 'Gmail update', content: 'Gmail invoice from Lameh'),
      node(title: 'YouTube saved', content: 'YouTube design video'),
      node(title: 'Gmail reminder', content: 'Gmail receipt ready'),
    ]);

    expect(keywords.first, 'Gmail');
    expect(keywords, contains('YouTube'));
  });

  test('extractFrequentInsightKeywords prefers repeated noun phrases', () {
    final keywords = extractFrequentInsightKeywords([
      node(
        title: 'Solar battery anodes',
        content: 'Discussed solar battery anodes efficiency with NMC lab',
      ),
      node(
        title: 'Anode review',
        content: 'Solar battery anodes need another NMC lab review',
      ),
      node(title: 'Battery reminder', content: 'Battery logs are ready'),
    ]);

    expect(keywords.first, 'Solar Battery Anodes');
  });

  test('buildAggregatedInsights groups memories by selected keyword', () {
    final insights = buildAggregatedInsights([
      node(title: 'Gmail update', content: 'Gmail invoice from Lameh'),
      node(title: 'Gmail reminder', content: 'Gmail receipt ready'),
      node(title: 'YouTube saved', content: 'YouTube design video'),
    ], selectedKeyword: 'Gmail');

    expect(insights, hasLength(1));
    expect(insights.single.keyword, 'Gmail');
    expect(insights.single.count, 2);
    expect(insights.single.summary, contains('2 memories'));
  });

  test('buildAggregatedInsights includes source breakdown and related context', () {
    final insights = buildAggregatedInsights([
      node(
        title: 'Solar battery anodes',
        content: 'Discussed solar battery anodes efficiency with NMC lab',
        source: 'voice_note',
        timestamp: DateTime(2026, 5, 24, 8),
      ),
      node(
        title: 'Anode review',
        content: 'Solar battery anodes need another NMC lab review',
        source: 'notification',
        timestamp: DateTime(2026, 5, 24, 10),
      ),
    ], selectedKeyword: 'Solar Battery Anodes');

    expect(insights, hasLength(1));
    expect(insights.single.summary, contains('2 memories'));
    expect(insights.single.summary, contains('notifications'));
    expect(insights.single.summary, contains('voice'));
    expect(insights.single.summary, contains('Related context'));
    expect(insights.single.summary, contains('Latest note: Anode review'));
  });

  test('buildAggregatedInsights explains priority notification context', () {
    final insights = buildAggregatedInsights([
      node(
        title: 'Weather summary',
        content: 'Heavy rain expected around 6 PM.',
        source: 'notification',
        timestamp: DateTime(2026, 5, 24, 10),
      ).copyWith(
        metadata: const {
          'importanceTier': 'high',
          'importanceReason': 'Weather summary',
          'isPriorityEvent': true,
        },
      ),
    ], selectedKeyword: 'Weather Summary');

    expect(insights, hasLength(1));
    expect(insights.single.summary, contains('Priority event'));
    expect(insights.single.summary, contains('Weather summary'));
  });
}
