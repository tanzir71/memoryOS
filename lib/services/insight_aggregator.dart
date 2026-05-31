import '../models/memory_node.dart';
import 'insight_terms.dart';

class AggregatedInsight {
  const AggregatedInsight({
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

List<String> extractFrequentInsightKeywords(
  List<MemoryNode> nodes, {
  int limit = 6,
}) {
  return extractInsightGroups(
    nodes,
    limit: limit,
  ).map((group) => group.label).toList();
}

List<AggregatedInsight> buildAggregatedInsights(
  List<MemoryNode> nodes, {
  String selectedKeyword = 'All',
  int limit = 6,
}) {
  if (nodes.isEmpty) return [];

  final groups = selectedKeyword == 'All'
      ? extractInsightGroups(nodes, limit: limit)
      : [insightGroupFromLabel(selectedKeyword)];

  final insights = <AggregatedInsight>[];
  for (final group in groups) {
    final matchingNodes = nodes
        .where((node) => nodeMatchesInsightGroup(node, group))
        .toList();

    if (matchingNodes.isEmpty) continue;

    matchingNodes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final latest = matchingNodes.first;
    final sources = matchingNodes.expand(_sourceLabelsForNode).toSet().toList()
      ..sort();

    insights.add(
      AggregatedInsight(
        keyword: group.label,
        count: matchingNodes.length,
        sources: sources,
        latestTimestamp: latest.timestamp,
        summary: _buildSummary(
          group: group,
          matchingNodes: matchingNodes,
          sources: sources,
          latest: latest,
        ),
      ),
    );
  }

  return insights;
}

String _buildSummary({
  required InsightGroup group,
  required List<MemoryNode> matchingNodes,
  required List<String> sources,
  required MemoryNode latest,
}) {
  final relatedTerms = extractInsightTerms(matchingNodes, limit: 5)
      .where((term) => term.normalized != group.normalized)
      .map((term) => term.label)
      .take(3)
      .toList();
  final countLabel =
      '${matchingNodes.length} ${matchingNodes.length == 1 ? "memory" : "memories"}';
  final sourceLabel = sources.length == 1
      ? 'from ${sources.single}'
      : 'across ${_joinHuman(sources)}';
  final isAppGroup = group.category != 'topic';
  final buffer = StringBuffer(
    isAppGroup
        ? '$countLabel from ${group.label} via ${_joinHuman(sources)}. '
        : '$countLabel about ${group.label} $sourceLabel. ',
  );

  final priorityNode = matchingNodes.cast<MemoryNode?>().firstWhere(
    (node) =>
        node != null &&
        (node.metadata['isPriorityEvent'] == true ||
            node.metadata['isPriorityEvent']?.toString().toLowerCase() ==
                'true' ||
            node.metadata['importanceTier']?.toString().toLowerCase() ==
                'high'),
    orElse: () => null,
  );
  if (priorityNode != null) {
    final reason = priorityNode.metadata['importanceReason']?.toString();
    final sender = priorityNode.metadata['conversationSender']?.toString();
    final snippet = priorityNode.metadata['conversationSnippet']?.toString();
    final isConversation =
        reason != null &&
        RegExp(
          r'\b(conversation|email context)\b',
          caseSensitive: false,
        ).hasMatch(reason);
    if (isConversation) {
      buffer.write(
        '$reason${sender == null || sender.isEmpty ? "" : ": $sender"}. ',
      );
      if (snippet != null && snippet.isNotEmpty) {
        buffer.write('Latest snippet: $snippet. ');
      }
    } else {
      buffer.write(
        'Priority event${reason == null || reason.isEmpty ? "" : ": $reason"}. ',
      );
    }
  }

  if (relatedTerms.isNotEmpty) {
    buffer.write('Related context: ${relatedTerms.join(", ")}. ');
  }
  buffer.write('Latest note: ${latest.title}.');
  return buffer.toString();
}

String _joinHuman(List<String> values) {
  if (values.length <= 1) return values.join();
  if (values.length == 2) return '${values.first} and ${values.last}';
  return '${values.take(values.length - 1).join(", ")}, and ${values.last}';
}

String insightSourceLabel(String source) {
  switch (source) {
    case 'voice_note':
      return 'voice';
    case 'photo':
      return 'screenshots';
    case 'notification':
      return 'notifications';
    case 'location':
      return 'location';
    case 'calendar':
      return 'calendar';
    case 'bluetooth':
      return 'bluetooth';
    case 'reading':
      return 'reading';
    default:
      return source.replaceAll('_', ' ');
  }
}

Iterable<String> _sourceLabelsForNode(MemoryNode node) sync* {
  yield insightSourceLabel(node.source);
  final category = node.metadata['registryCategory']?.toString().trim();
  if (category != null && category.isNotEmpty) {
    yield category;
  }
}

List<String> sourceLabelsForInsightNode(MemoryNode node) {
  return _sourceLabelsForNode(node).toSet().toList()..sort();
}
