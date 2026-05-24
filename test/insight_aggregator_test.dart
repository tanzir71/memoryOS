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

  test('extractFrequentInsightKeywords ranks repeated meaningful words', () {
    final keywords = extractFrequentInsightKeywords([
      node(title: 'Gmail update', content: 'Gmail invoice from Lameh'),
      node(title: 'YouTube saved', content: 'YouTube design video'),
      node(title: 'Gmail reminder', content: 'Gmail receipt ready'),
    ]);

    expect(keywords.first, 'Gmail');
    expect(keywords, contains('YouTube'));
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
}
