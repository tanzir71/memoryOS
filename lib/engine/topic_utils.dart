const _stopWords = {
  'the', 'a', 'an', 'and', 'or', 'but', 'to', 'of', 'in', 'for', 'with',
  'on', 'at', 'by', 'from', 'is', 'was', 'were', 'are', 'be', 'been', 'have',
  'has', 'had', 'do', 'does', 'did', 'this', 'that', 'these', 'those', 'it',
  'its', 'my', 'your', 'our', 'their', 'me', 'you', 'us', 'them', 'can',
  'could', 'would', 'should', 'will', 'shall', 'please', 'need', 'send',
  'sent', 'today', 'tomorrow', 'before', 'after', 'about', 're', 'fwd', 'fw',
  'subject', 'call', 'missed', 'voice', 'outgoing', 'incoming', 'phone',
  'message', 'email', 'notes', 'order', 'placed', 'confirmed',
  'delivered', 'payment', 'paid', 'successful', 'running', 'late', 'start',
  'without', 'scope', 'changes', 'revised', 'updated', 'final', 'draft',
  'v1', 'v2', 'v3', 'thursday', 'friday', 'monday', 'tuesday', 'wednesday',
  'saturday', 'sunday', 'tk', 'bdt', 'fee', 'balance', 'trxid', 'min', 'mins',
};

String stripReplyPrefix(String subject) {
  return subject
      .replaceAll(RegExp(r'^\s*(?:re|fwd|fw)\s*:\s*', caseSensitive: false), '')
      .trim();
}

bool isReplySubject(String subject) {
  return RegExp(r'^\s*re\s*:', caseSensitive: false).hasMatch(subject);
}

Set<String> extractTopicTokens(String text) {
  final cleaned = stripReplyPrefix(text).toLowerCase();
  final matches = RegExp(r'[a-z][a-z0-9\-]{2,}').allMatches(cleaned);
  final tokens = <String>{};
  for (final m in matches) {
    final word = m.group(0)!;
    if (!_stopWords.contains(word)) {
      tokens.add(word);
    }
  }
  return tokens;
}

/// Extracts a clean, concise phrase (e.g. "Website quote") from email subject
/// or shared text for thread naming.
String? extractTopicPhrase(String subject) {
  final stripped = stripReplyPrefix(subject);
  if (stripped.isEmpty) return null;
  final firstClause = stripped.split(RegExp(r'[,;\-\|]')).first.trim();
  if (firstClause.length >= 3 && firstClause.length <= 42) {
    return firstClause;
  }
  return null;
}

/// Converts a raw ask sentence like "Can you send the revised quote today?
/// Need it before Thursday." into a concise imperative loop title:
/// "Send the revised quote".
String formatOpenLoopTitle(String rawText) {
  var text = rawText.trim();
  if (text.isEmpty) return 'Follow up';
  // Take first sentence.
  text = text.split(RegExp(r'[?!.\n]')).first.trim();
  // Strip polite leading prefixes.
  text = text.replaceFirst(
    RegExp(
      r'^(?:can you|could you|would you|please|kindly|need you to|remember to|don.?t forget to|i.?ll|i will|ami)\s+',
      caseSensitive: false,
    ),
    '',
  );
  // Strip trailing temporal adverbs.
  text = text.replaceFirst(
    RegExp(
      r'\s+(?:today|tonight|tomorrow|asap|please|now|before\s+\w+)$',
      caseSensitive: false,
    ),
    '',
  ).trim();
  if (text.isEmpty) return rawText.trim();
  return text[0].toUpperCase() + text.substring(1);
}

bool amountsMatchWithinOnePercent(double a, double b) {
  if (a <= 0 || b <= 0) return false;
  final diff = (a - b).abs();
  final base = a > b ? a : b;
  return (diff / base) <= 0.01;
}

bool shareMerchantToken(String a, String b) {
  final ta = extractTopicTokens(a);
  final tb = extractTopicTokens(b);
  if (ta.isNotEmpty && tb.isNotEmpty && ta.intersection(tb).isNotEmpty) {
    return true;
  }
  final al = a.trim().toLowerCase();
  final bl = b.trim().toLowerCase();
  return al.isNotEmpty && bl.isNotEmpty && (al.contains(bl) || bl.contains(al));
}
