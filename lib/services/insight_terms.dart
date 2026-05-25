import '../models/memory_node.dart';
import 'app_category_registry.dart';
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

class InsightGroup {
  const InsightGroup({
    required this.label,
    required this.normalized,
    required this.category,
    required this.score,
    required this.count,
    this.packageHints = const {},
  });

  final String label;
  final String normalized;
  final String category;
  final double score;
  final int count;
  final Set<String> packageHints;
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

class _GroupStats {
  _GroupStats(this.label, this.category);

  String label;
  String category;
  final Set<int> documentIndexes = {};
  final Set<String> packageHints = {};
  double score = 0;

  void absorb({
    required int documentIndex,
    required double score,
    required Iterable<String> hints,
    required String category,
    required String label,
  }) {
    documentIndexes.add(documentIndex);
    packageHints.addAll(
      hints
          .map(normalizeInsightTerm)
          .where((hint) => hint.isNotEmpty && !_isSuppressedAppLabel(hint)),
    );
    if (score > this.score) {
      this.score = score;
      this.category = category;
      this.label = label;
    } else {
      this.score += score * 0.15;
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
  'can',
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
  'you',
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
  'cache',
  'cached',
  'clipboard',
  'com',
  'completed',
  'context',
  'data',
  'default',
  'device',
  'directory',
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
  'null',
  'notification',
  'notifications',
  'org',
  'passive',
  'package',
  'path',
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
  'temp',
  'text',
  'tmp',
  'unknown',
  'update',
  'user',
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

List<InsightGroup> extractInsightGroups(
  List<MemoryNode> nodes, {
  int limit = 6,
}) {
  if (nodes.isEmpty) return [];

  final registry = AppCategoryRegistry.active;
  final groups = <String, _GroupStats>{};

  for (var index = 0; index < nodes.length; index += 1) {
    final candidate = _appGroupCandidate(nodes[index], registry);
    if (candidate == null) continue;

    final normalized = normalizeInsightTerm(candidate.label);
    if (normalized.isEmpty || _isSuppressedAppLabel(normalized)) continue;

    final stats = groups.putIfAbsent(
      normalized,
      () => _GroupStats(candidate.label, candidate.category),
    );
    stats.absorb(
      documentIndex: index,
      score: candidate.score,
      hints: candidate.packageHints,
      category: candidate.category,
      label: candidate.label,
    );
  }

  if (groups.isEmpty) {
    return extractInsightTerms(nodes, limit: limit)
        .map(
          (term) => InsightGroup(
            label: term.label,
            normalized: term.normalized,
            category: 'topic',
            score: term.score,
            count: term.documentCount,
            packageHints: const {},
          ),
        )
        .toList();
  }

  final sorted =
      groups.entries.map((entry) {
        final stats = entry.value;
        return InsightGroup(
          label: stats.label,
          normalized: entry.key,
          category: stats.category,
          score: stats.score + (stats.documentIndexes.length * 4),
          count: stats.documentIndexes.length,
          packageHints: stats.packageHints,
        );
      }).toList()..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        final countCompare = b.count.compareTo(a.count);
        if (countCompare != 0) return countCompare;
        return a.label.compareTo(b.label);
      });

  return sorted.take(limit).toList();
}

InsightGroup insightGroupFromLabel(String label) {
  final registry = AppCategoryRegistry.active;
  final normalized = normalizeInsightTerm(label);
  final hints = _aliasesForGroupLabel(label, registry);
  final category = _categoryForGroupLabel(label, registry);
  return InsightGroup(
    label: registry.displayLabelForAlias(label),
    normalized: normalized,
    category: category ?? 'topic',
    score: 0,
    count: 0,
    packageHints: hints,
  );
}

bool nodeMatchesInsightGroup(MemoryNode node, InsightGroup group) {
  if (group.category == 'topic') {
    return nodeMatchesInsightTerm(node, insightTermFromLabel(group.label));
  }

  final packageName = normalizeInsightTerm(
    node.metadata['packageName']?.toString() ?? '',
  );
  final appName = normalizeInsightTerm(
    node.metadata['appName']?.toString() ?? '',
  );
  final reason = normalizeInsightTerm(
    node.metadata['importanceReason']?.toString() ?? '',
  );
  final title = normalizeInsightTerm(node.title);
  final registry = AppCategoryRegistry.active;
  final displayName = normalizeInsightTerm(
    registry.displayNameFor(
      packageName: node.metadata['packageName']?.toString() ?? '',
      appName: node.metadata['appName']?.toString() ?? '',
    ),
  );

  final directValues = {
    appName,
    displayName,
  }.where((value) => value.isNotEmpty).toSet();
  if (directValues.contains(group.normalized)) return true;

  for (final hint in group.packageHints) {
    final normalizedHint = normalizeInsightTerm(hint);
    if (normalizedHint.isEmpty) continue;
    if (packageName == normalizedHint ||
        packageName.contains(normalizedHint) ||
        appName == normalizedHint ||
        displayName == normalizedHint) {
      return true;
    }
  }

  if (title.startsWith('${group.normalized} ') ||
      title.startsWith('${group.normalized}:') ||
      reason.contains(group.normalized)) {
    return true;
  }

  return false;
}

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
  for (final key in const [
    'appName',
    'importanceReason',
    'conversationSender',
    'conversationSnippet',
    'registryCategory',
  ]) {
    final value = node.metadata[key];
    if (value is String && value.trim().isNotEmpty) {
      final normalized = normalizeInsightTerm(value);
      if (normalized.isNotEmpty &&
          !normalized
              .split(RegExp(r'\s+'))
              .every((part) => _boilerplateWords.contains(part))) {
        values.add(value);
      }
    }
  }
  return values.join(' ');
}

_AppGroupCandidate? _appGroupCandidate(
  MemoryNode node,
  AppCategoryRegistry registry,
) {
  final packageName = node.metadata['packageName']?.toString().trim() ?? '';
  final appName = node.metadata['appName']?.toString().trim() ?? '';
  if (packageName.isEmpty && appName.isEmpty) return null;

  if (registry.isDenied(packageName: packageName, appName: appName)) {
    return null;
  }

  final category =
      _metadataCategory(node) ??
      registry
          .firstMatch(packageName: packageName, appName: appName)
          ?.storageKey;
  final combinedText = '$packageName $appName ${node.title} ${node.content}'
      .toLowerCase();
  if ((category == AppCategory.food.storageKey ||
          category == AppCategory.grocery.storageKey) &&
      !_foodOrGrocerySignal.hasMatch(combinedText)) {
    return null;
  }
  if (category == AppCategory.fitness.storageKey &&
      !_fitnessSignal.hasMatch(combinedText)) {
    return null;
  }

  final label = _appLabelForNode(
    packageName: packageName,
    appName: appName,
    registry: registry,
  );
  final normalizedLabel = normalizeInsightTerm(label);
  if (normalizedLabel.isEmpty || _isSuppressedAppLabel(normalizedLabel)) {
    return null;
  }

  final effectiveCategory = category ?? 'app';
  final score =
      _groupCategoryWeight(effectiveCategory) +
      _groupImportanceWeight(node) +
      (node.source == 'notification' ? 6 : 0);
  return _AppGroupCandidate(
    label: label,
    category: effectiveCategory,
    score: score,
    packageHints: {
      packageName,
      appName,
      label,
      ..._aliasesForGroupLabel(label, registry),
    },
  );
}

String _appLabelForNode({
  required String packageName,
  required String appName,
  required AppCategoryRegistry registry,
}) {
  if (appName.isNotEmpty) {
    final label = registry.displayLabelForAlias(appName);
    if (label.trim().isNotEmpty) return label;
  }
  final packageLabel = registry.displayLabelForAlias(packageName);
  if (packageLabel.trim().isNotEmpty) return packageLabel;
  return registry.displayNameFor(packageName: packageName, appName: appName);
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

Set<String> _aliasesForGroupLabel(String label, AppCategoryRegistry registry) {
  final normalizedLabel = normalizeInsightTerm(label);
  final aliases = <String>{normalizedLabel};
  for (final category in AppCategory.values) {
    for (final alias in registry.aliasesFor(category)) {
      final aliasLabel = normalizeInsightTerm(
        registry.displayLabelForAlias(alias),
      );
      final normalizedAlias = normalizeInsightTerm(alias);
      if (aliasLabel == normalizedLabel || normalizedAlias == normalizedLabel) {
        aliases.add(alias);
      }
    }
  }
  return aliases;
}

String? _categoryForGroupLabel(String label, AppCategoryRegistry registry) {
  final normalizedLabel = normalizeInsightTerm(label);
  for (final category in AppCategory.values) {
    for (final alias in registry.aliasesFor(category)) {
      final aliasLabel = normalizeInsightTerm(
        registry.displayLabelForAlias(alias),
      );
      final normalizedAlias = normalizeInsightTerm(alias);
      if (aliasLabel == normalizedLabel || normalizedAlias == normalizedLabel) {
        return category.storageKey;
      }
    }
  }
  return null;
}

double _groupCategoryWeight(String category) {
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

double _groupImportanceWeight(MemoryNode node) {
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

bool _isSuppressedAppLabel(String normalized) {
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

final _foodOrGrocerySignal = RegExp(
  r'\b(order|ordered|delivery|delivered|arriving|pickup|picked up|receipt|'
  r'cart|checkout|paid|payment|rider|driver|prepared|preparing|on the way|'
  r'grocery|groceries|meal|lunch|dinner|breakfast|restaurant)\b',
);

final _fitnessSignal = RegExp(
  r'\b(workout|exercise|fitness|gym|steps|heart rate|run|ran|walk|walking|'
  r'cycling|ride|sleep|activity|calories burned|active minutes|distance|km|'
  r'miles|pace|training|session)\b',
);

class _AppGroupCandidate {
  const _AppGroupCandidate({
    required this.label,
    required this.category,
    required this.score,
    required this.packageHints,
  });

  final String label;
  final String category;
  final double score;
  final Set<String> packageHints;
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
  final metadataSender = node.metadata['conversationSender']?.toString().trim();
  final metadataSnippet = node.metadata['conversationSnippet']
      ?.toString()
      .trim();

  if (metadataSender != null &&
      metadataSender.isNotEmpty &&
      _isMeaningfulToken(metadataSender)) {
    yield _ExtractedCandidate(
      metadataSender,
      1,
      34,
      'message_sender',
      sourceWeight,
      eventWeight == 0 ? 18 : eventWeight,
    );
  }

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

  if (metadataSnippet != null && metadataSnippet.isNotEmpty) {
    final snippetTokens = _tokenRegex
        .allMatches(metadataSnippet)
        .map((match) => match.group(0)!)
        .where(_isMeaningfulToken)
        .take(4)
        .toList();
    for (var start = 0; start < snippetTokens.length - 1; start += 1) {
      final phrase = snippetTokens.sublist(start, start + 2);
      if (phrase.any(
        (token) => _genericVerbWords.contains(token.toLowerCase()),
      )) {
        continue;
      }
      yield _ExtractedCandidate(
        _formatLabel(phrase),
        2,
        12,
        'conversation_phrase',
        sourceWeight,
        eventWeight == 0 ? 10 : eventWeight,
      );
      break;
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
