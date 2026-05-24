import '../models/memory_node.dart';

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

const _stopWords = {
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

final _wordRegex = RegExp(r'\b[A-Za-z]{3,}\b');

List<String> extractFrequentInsightKeywords(
  List<MemoryNode> nodes, {
  int limit = 6,
}) {
  final counts = <String, int>{};

  for (final node in nodes) {
    final text = '${node.title} ${node.content}';
    for (final match in _wordRegex.allMatches(text)) {
      final rawWord = match.group(0)!;
      final lower = rawWord.toLowerCase();
      if (_stopWords.contains(lower)) continue;

      final formatted = rawWord[0].toUpperCase() + rawWord.substring(1);
      counts[formatted] = (counts[formatted] ?? 0) + 1;
    }
  }

  final sorted = counts.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });

  return sorted.map((entry) => entry.key).take(limit).toList();
}

List<AggregatedInsight> buildAggregatedInsights(
  List<MemoryNode> nodes, {
  String selectedKeyword = 'All',
  int limit = 6,
}) {
  if (nodes.isEmpty) return [];

  final keywords = selectedKeyword == 'All'
      ? extractFrequentInsightKeywords(nodes, limit: limit)
      : [selectedKeyword];

  final insights = <AggregatedInsight>[];
  for (final keyword in keywords) {
    final matchingNodes = nodes.where((node) {
      final haystack = '${node.title} ${node.content}'.toLowerCase();
      return haystack.contains(keyword.toLowerCase());
    }).toList();

    if (matchingNodes.isEmpty) continue;

    matchingNodes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final latest = matchingNodes.first;
    final sources =
        matchingNodes.map((node) => _sourceLabel(node.source)).toSet().toList()
          ..sort();

    insights.add(
      AggregatedInsight(
        keyword: keyword,
        count: matchingNodes.length,
        sources: sources,
        latestTimestamp: latest.timestamp,
        summary:
            '${matchingNodes.length} ${matchingNodes.length == 1 ? "memory" : "memories"} mention $keyword across ${sources.join(", ")}. Latest: ${latest.title}.',
      ),
    );
  }

  return insights;
}

String _sourceLabel(String source) {
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
