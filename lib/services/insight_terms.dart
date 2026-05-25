import '../models/memory_node.dart';
import 'capture_metadata.dart';

class InsightTerm {
  const InsightTerm({
    required this.label,
    required this.normalized,
    required this.score,
    required this.documentCount,
    required this.occurrenceCount,
    this.rarityScore = 0,
    this.sourceWeight = 0,
    this.eventWeight = 0,
    this.category = 'general',
  });

  final String label;
  final String normalized;
  final double score;
  final int documentCount;
  final int occurrenceCount;
  final double rarityScore;
  final double sourceWeight;
  final double eventWeight;
  final String category;
}

class _CandidateStats {
  _CandidateStats(
    this.label,
    this.tokenCount,
    this.baseBoost,
    this.category,
    this.sourceWeight,
    this.eventWeight,
  );

  final String label;
  final int tokenCount;
  double baseBoost;
  String category;
  double sourceWeight;
  double eventWeight;
  final Set<int> documentIndexes = {};
  int occurrenceCount = 0;

  void absorb(_ExtractedCandidate candidate) {
    if (candidate.baseBoost > baseBoost) {
      baseBoost = candidate.baseBoost;
      category = candidate.category;
    }
    if (candidate.sourceWeight > sourceWeight) {
      sourceWeight = candidate.sourceWeight;
    }
    if (candidate.eventWeight > eventWeight) {
      eventWeight = candidate.eventWeight;
    }
  }
}

final _urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
final _tokenRegex = RegExp(r"[A-Za-z][A-Za-z0-9]*(?:[-'][A-Za-z0-9]+)?");

const _brandLabels = {
  'gmail': 'Gmail',
  'youtube': 'YouTube',
  'whatsapp': 'WhatsApp',
  'messenger': 'Messenger',
  'messages': 'Messages',
  'memoryos': 'MemoryOS',
  'slack': 'Slack',
  'teams': 'Teams',
  'chrome': 'Chrome',
  'instagram': 'Instagram',
  'facebook': 'Facebook',
};

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
  'about',
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
  'your',
  'here',
  'without',
};

const _boilerplateWords = {
  'active',
  'android',
  'app',
  'apps',
  'capture',
  'captured',
  'clipboard',
  'com',
  'completed',
  'context',
  'data',
  'device',
  'done',
  'duration',
  'enclave',
  'file',
  'google',
  'info',
  'listening',
  'local',
  'location',
  'memoryos',
  'net',
  'node',
  'notification',
  'notifications',
  'org',
  'passive',
  'package',
  'photo',
  'phone',
  'pixel',
  'play',
  'read',
  'received',
  'record',
  'recorded',
  'saved',
  'screenshot',
  'session',
  'service',
  'services',
  'source',
  'stream',
  'system',
  'systemui',
  'text',
  'update',
  'visited',
};

const _genericNounWords = {
  'battery',
  'log',
  'logs',
  'summary',
  'alert',
  'alerts',
  'offer',
  'offers',
  'sale',
  'status',
  'reminder',
  'complete',
  'event',
  'events',
  'message',
  'messages',
};

const _genericVerbWords = {
  'check',
  'discuss',
  'discussed',
  'find',
  'going',
  'keep',
  'look',
  'make',
  'need',
  'needs',
  'ready',
  'review',
  'send',
  'sent',
  'share',
  'shared',
  'show',
  'take',
  'want',
  'wants',
};

List<InsightTerm> extractInsightTerms(List<MemoryNode> nodes, {int limit = 6}) {
  if (nodes.isEmpty) return [];

  final candidates = <String, _CandidateStats>{};

  for (var index = 0; index < nodes.length; index += 1) {
    final node = nodes[index];
    final text = '${node.title} ${node.content} ${_metadataText(node)}';
    final emittedInDocument = <String>{};

    for (final candidate in _extractCandidates(node, text)) {
      final normalized = normalizeInsightTerm(candidate.label);
      if (normalized.isEmpty) continue;

      final stats = candidates.putIfAbsent(
        normalized,
        () => _CandidateStats(
          candidate.label,
          candidate.tokenCount,
          candidate.baseBoost,
          candidate.category,
          candidate.sourceWeight,
          candidate.eventWeight,
        ),
      );
      stats.absorb(candidate);
      stats.occurrenceCount += 1;
      if (emittedInDocument.add(normalized)) {
        stats.documentIndexes.add(index);
      }
    }
  }

  final terms =
      candidates.entries
          .where((entry) {
            final stats = entry.value;
            if (stats.tokenCount == 1) return true;
            if (stats.baseBoost >= 8 || stats.eventWeight >= 12) return true;
            return stats.occurrenceCount > 1 ||
                stats.documentIndexes.length > 1 ||
                nodes.length == 1;
          })
          .map((entry) {
            final stats = entry.value;
            final rarityScore =
                ((nodes.length - stats.documentIndexes.length) /
                    nodes.length.clamp(1, nodes.length)) *
                3.0;
            final phraseBoost = stats.tokenCount > 1
                ? stats.tokenCount * 5.0
                : 0.0;
            final score =
                (stats.occurrenceCount * 0.3) +
                (stats.documentIndexes.length * 0.5) +
                rarityScore +
                phraseBoost +
                stats.baseBoost +
                stats.sourceWeight +
                stats.eventWeight;
            return InsightTerm(
              label: stats.label,
              normalized: entry.key,
              score: score,
              documentCount: stats.documentIndexes.length,
              occurrenceCount: stats.occurrenceCount,
              rarityScore: rarityScore,
              sourceWeight: stats.sourceWeight,
              eventWeight: stats.eventWeight,
              category: stats.category,
            );
          })
          .toList()
        ..sort((a, b) {
          final scoreCompare = b.score.compareTo(a.score);
          if (scoreCompare != 0) return scoreCompare;
          final documentCompare = b.documentCount.compareTo(a.documentCount);
          if (documentCompare != 0) return documentCompare;
          final occurrenceCompare = b.occurrenceCount.compareTo(
            a.occurrenceCount,
          );
          if (occurrenceCompare != 0) return occurrenceCompare;
          return a.label.compareTo(b.label);
        });

  return terms.take(limit).toList();
}

InsightTerm insightTermFromLabel(String label) {
  return InsightTerm(
    label: _formatLabel(label.split(RegExp(r'\s+'))),
    normalized: normalizeInsightTerm(label),
    score: 0,
    documentCount: 0,
    occurrenceCount: 0,
    category: 'manual',
  );
}

bool nodeMatchesInsightTerm(MemoryNode node, InsightTerm term) {
  final normalized = term.normalized.trim();
  if (normalized.isEmpty) return false;

  final haystack = normalizeInsightTerm(
    '${node.title} ${node.content} ${_metadataText(node)}',
  );
  return ' $haystack '.contains(' $normalized ');
}

String normalizeInsightTerm(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9]+"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _metadataText(MemoryNode node) {
  final values = <String>[];
  for (final entry in node.metadata.entries) {
    final value = entry.value;
    if (value is String && value.trim().isNotEmpty) {
      values.add(value);
    }
  }
  return values.join(' ');
}

Iterable<_ExtractedCandidate> _extractCandidates(
  MemoryNode node,
  String text,
) sync* {
  yield* _extractPriorityCandidates(node, text);

  final sourceWeight = _sourceWeight(node.source);
  final eventWeight = _eventWeight(node);

  final titleTokens = _tokenRegex
      .allMatches(node.title)
      .map((match) => match.group(0)!)
      .where(_isMeaningfulToken)
      .take(3)
      .toList();
  if (titleTokens.length >= 2 &&
      !titleTokens
          .map((token) => token.toLowerCase())
          .any(_genericNounWords.contains)) {
    yield _ExtractedCandidate(
      _formatLabel(titleTokens.take(2).toList()),
      2,
      9,
      'phrase',
      sourceWeight,
      eventWeight,
    );
  }

  for (final urlMatch in _urlRegex.allMatches(text)) {
    final url = urlMatch.group(0);
    if (url == null) continue;
    final host = Uri.tryParse(url)?.host.replaceFirst(RegExp(r'^www\.'), '');
    if (host != null && host.isNotEmpty) {
      yield _ExtractedCandidate(
        host,
        1,
        8,
        'domain',
        sourceWeight,
        eventWeight,
      );
    }
  }

  final tokens = _tokenRegex
      .allMatches(text)
      .map((match) => match.group(0)!)
      .toList();
  final meaningful = tokens.where(_isMeaningfulToken).toList();

  for (final token in meaningful) {
    final lower = token.toLowerCase();
    final isKnownBrand = _brandLabels.containsKey(lower);
    final isAcronym = token.length > 1 && token == token.toUpperCase();
    final isProper = token[0] == token[0].toUpperCase();
    final isGeneric = _genericNounWords.contains(lower);
    final boost = isKnownBrand
        ? 10.0
        : isProper
        ? 8.0
        : isAcronym
        ? 7.0
        : isGeneric
        ? -6.0
        : 0.0;
    final category = isKnownBrand
        ? 'app'
        : isProper || isAcronym
        ? 'proper_noun'
        : isGeneric
        ? 'generic'
        : 'noun';
    yield _ExtractedCandidate(
      _formatLabel([token]),
      1,
      boost,
      category,
      sourceWeight,
      eventWeight,
    );
  }

  for (var start = 0; start < meaningful.length; start += 1) {
    for (var length = 2; length <= 3; length += 1) {
      final end = start + length;
      if (end > meaningful.length) continue;
      final slice = meaningful.sublist(start, end);
      if (slice.any(
        (token) => _genericVerbWords.contains(token.toLowerCase()),
      )) {
        continue;
      }
      final lowerSlice = slice.map((token) => token.toLowerCase()).toList();
      final hasGeneric = lowerSlice.any(_genericNounWords.contains);
      yield _ExtractedCandidate(
        _formatLabel(slice),
        length,
        hasGeneric ? -2.0 : 3.0,
        'phrase',
        sourceWeight,
        eventWeight,
      );
    }
  }
}

Iterable<_ExtractedCandidate> _extractPriorityCandidates(
  MemoryNode node,
  String text,
) sync* {
  final sourceWeight = _sourceWeight(node.source);
  final eventWeight = _eventWeight(node);
  final lowerText = text.toLowerCase();
  final importanceReason = node.metadata['importanceReason']?.toString() ?? '';
  final packageName = node.metadata['packageName']?.toString() ?? '';
  final titleLower = node.title.toLowerCase();

  if (_looksLikeWeatherText(lowerText) ||
      importanceReason.toLowerCase().contains('weather')) {
    yield _ExtractedCandidate(
      'Weather Summary',
      2,
      26,
      'weather',
      sourceWeight,
      eventWeight == 0 ? 18 : eventWeight,
    );
  }

  final sender = _messageSenderLabel(node.title, packageName);
  if (sender != null && _isMeaningfulToken(sender)) {
    yield _ExtractedCandidate(
      sender,
      1,
      28,
      'message_sender',
      sourceWeight,
      eventWeight == 0 ? 16 : eventWeight,
    );
  }

  if (_looksLikeEventText(lowerText)) {
    yield _ExtractedCandidate(
      'Calendar Event',
      2,
      18,
      'event',
      sourceWeight,
      eventWeight == 0 ? 12 : eventWeight,
    );
  }

  if (_looksLikeSecurityText(lowerText)) {
    yield _ExtractedCandidate(
      'Security Alert',
      2,
      22,
      'security',
      sourceWeight,
      eventWeight == 0 ? 18 : eventWeight,
    );
  }

  if (titleLower.startsWith('gmail:') || packageName.contains('gmail')) {
    final sender = _afterColon(node.title);
    if (sender != null && _isMeaningfulToken(sender)) {
      yield _ExtractedCandidate(
        sender,
        1,
        24,
        'email_sender',
        sourceWeight,
        eventWeight == 0 ? 8 : eventWeight,
      );
    }
  }
}

bool _isMeaningfulToken(String token) {
  final lower = token.toLowerCase();
  if (lower.length < 3) return false;
  if (_stopWords.contains(lower)) return false;
  if (_boilerplateWords.contains(lower)) return false;
  if (_genericVerbWords.contains(lower)) return false;
  return true;
}

String _formatLabel(List<String> tokens) {
  return tokens
      .map((token) {
        final lower = token.toLowerCase();
        final brand = _brandLabels[lower];
        if (brand != null) return brand;
        if (token.length > 1 && token == token.toUpperCase()) return token;
        if (token.contains('.')) return token.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

double _sourceWeight(String source) {
  switch (source) {
    case 'notification':
      return 2;
    case 'voice_note':
      return 3;
    case 'calendar':
      return 4;
    default:
      return 0;
  }
}

double _eventWeight(MemoryNode node) {
  final tier = node.metadata['importanceTier']?.toString().toLowerCase();
  switch (tier) {
    case 'high':
      return 22;
    case 'medium':
      return 0;
    case 'low':
      return -2;
    case 'suppress':
      return -20;
  }
  if (node.metadata['isPriorityEvent'] == true ||
      node.metadata['isPriorityEvent']?.toString().toLowerCase() == 'true') {
    return 14;
  }
  if (node.source == 'notification') {
    final importance = classifyNotificationImportance(
      packageName: node.metadata['packageName']?.toString() ?? '',
      channelId: node.metadata['channelId']?.toString() ?? '',
      title: node.title,
      content: node.content,
      category: node.metadata['category']?.toString() ?? '',
      isOngoing:
          node.metadata['isOngoing'] == true ||
          node.metadata['isOngoing']?.toString().toLowerCase() == 'true',
    );
    switch (importance.tier) {
      case NotificationImportanceTier.high:
        return 20;
      case NotificationImportanceTier.medium:
        return 0;
      case NotificationImportanceTier.low:
        return -2;
      case NotificationImportanceTier.suppress:
        return -20;
    }
  }
  return 0;
}

String? _messageSenderLabel(String title, String packageName) {
  final lower = '$title $packageName'.toLowerCase();
  final isMessageApp =
      lower.contains('whatsapp') ||
      lower.contains('orca') ||
      lower.contains('messages') ||
      lower.contains('messenger') ||
      lower.contains('slack') ||
      lower.contains('teams') ||
      lower.contains('telegram') ||
      lower.contains('signal');
  if (!isMessageApp) return null;
  return _afterColon(title) ?? title.split(RegExp(r'\s+')).first;
}

String? _afterColon(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final label = parts.sublist(1).join(':').trim();
  if (label.isEmpty) return null;
  final tokens = label
      .split(RegExp(r'\s+'))
      .map((token) => token.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '').trim())
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return null;

  const honorifics = {'dr', 'mr', 'mrs', 'ms', 'miss', 'prof', 'professor'};
  if (tokens.length > 1 && honorifics.contains(tokens.first.toLowerCase())) {
    return tokens[1];
  }
  return tokens.first;
}

bool _looksLikeWeatherText(String text) {
  return RegExp(
    r'\b(weather|forecast|rain|storm|thunder|temperature|humid|humidity|'
    r'wind|umbrella|heatwave|cyclone|flood|air quality|aqi)\b',
  ).hasMatch(text);
}

bool _looksLikeEventText(String text) {
  return RegExp(
    r'\b(calendar|meeting|event|appointment|starts in|call at|deadline|'
    r'due today|due tomorrow)\b',
  ).hasMatch(text);
}

bool _looksLikeSecurityText(String text) {
  return RegExp(
    r'\b(otp|one time password|verification code|security alert|login|'
    r'sign-in|signin|password|2fa|two-factor|account alert)\b',
  ).hasMatch(text);
}

class _ExtractedCandidate {
  const _ExtractedCandidate(
    this.label,
    this.tokenCount,
    this.baseBoost,
    this.category,
    this.sourceWeight,
    this.eventWeight,
  );

  final String label;
  final int tokenCount;
  final double baseBoost;
  final String category;
  final double sourceWeight;
  final double eventWeight;
}
