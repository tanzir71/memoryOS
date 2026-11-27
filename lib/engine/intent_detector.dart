import 'rules_loader.dart';

class DetectedIntent {
  const DetectedIntent({
    required this.type,
    required this.text,
    required this.confidence,
    this.dueAt,
    this.matchedCue,
  });

  final String type; // asks_you | you_said | plan | confirms | fyi
  final String text;
  final double confidence;
  final DateTime? dueAt;
  final String? matchedCue;

  bool get canCreateOpenLoop =>
      confidence >= 0.7 && (type == 'asks_you' || type == 'you_said');
}

class IntentDetector {
  IntentDetector(this.rules);

  final IntentRules rules;

  static const _months = {
    'jan': 1, 'january': 1,
    'feb': 2, 'february': 2,
    'mar': 3, 'march': 3,
    'apr': 4, 'april': 4,
    'may': 5,
    'jun': 6, 'june': 6,
    'jul': 7, 'july': 7,
    'aug': 8, 'august': 8,
    'sep': 9, 'sept': 9, 'september': 9,
    'oct': 10, 'october': 10,
    'nov': 11, 'november': 11,
    'dec': 12, 'december': 12,
  };

  static const _weekdays = {
    'monday': DateTime.monday,
    'mon': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'tue': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'wed': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'thu': DateTime.thursday,
    'friday': DateTime.friday,
    'fri': DateTime.friday,
    'saturday': DateTime.saturday,
    'sat': DateTime.saturday,
    'sunday': DateTime.sunday,
    'sun': DateTime.sunday,
  };

  DetectedIntent detect({
    required String text,
    required DateTime referenceTime,
    bool isSelf = false,
    bool isCalendarInvite = false,
    DateTime? explicitDueAt,
  }) {
    final trimmed = text.trim();
    if (isCalendarInvite) {
      return DetectedIntent(
        type: 'plan',
        text: trimmed,
        confidence: 0.9,
        dueAt: explicitDueAt ?? resolveDueDate(trimmed, referenceTime),
        matchedCue: 'calendar_invite',
      );
    }
    if (trimmed.isEmpty) {
      return const DetectedIntent(type: 'fyi', text: '', confidence: 0.4);
    }

    final lower = trimmed.toLowerCase();
    final dueAt = explicitDueAt ?? resolveDueDate(trimmed, referenceTime);
    final hasDate = dueAt != null;

    if (isSelf) {
      final youSaidCue = _findCue(lower, rules.youSaid);
      if (youSaidCue != null) {
        return DetectedIntent(
          type: 'you_said',
          text: trimmed,
          confidence: hasDate ? 0.9 : 0.7,
          dueAt: dueAt,
          matchedCue: youSaidCue,
        );
      }
      final confirmCue = _findCue(lower, rules.confirms);
      if (confirmCue != null) {
        return DetectedIntent(
          type: 'confirms',
          text: trimmed,
          confidence: 0.7,
          matchedCue: confirmCue,
        );
      }
      final planCue = _findCue(lower, rules.plan);
      if (planCue != null && hasDate) {
        return DetectedIntent(
          type: 'plan',
          text: trimmed,
          confidence: 0.9,
          dueAt: dueAt,
          matchedCue: planCue,
        );
      }
      final askCue = _findCue(lower, rules.asksYou);
      if (askCue != null || trimmed.endsWith('?')) {
        return DetectedIntent(
          type: 'asks_you',
          text: trimmed,
          confidence: askCue != null ? (hasDate ? 0.9 : 0.7) : 0.4,
          dueAt: dueAt,
          matchedCue: askCue ?? '?',
        );
      }
      return DetectedIntent(type: 'fyi', text: trimmed, confidence: 0.4, dueAt: dueAt);
    }

    // Incoming text from someone else.
    final askCue = _findCue(lower, rules.asksYou);
    if (askCue != null) {
      return DetectedIntent(
        type: 'asks_you',
        text: trimmed,
        confidence: hasDate ? 0.9 : 0.7,
        dueAt: dueAt,
        matchedCue: askCue,
      );
    }

    final planCue = _findCue(lower, rules.plan);
    if (planCue != null && hasDate) {
      return DetectedIntent(
        type: 'plan',
        text: trimmed,
        confidence: 0.9,
        dueAt: dueAt,
        matchedCue: planCue,
      );
    }

    final confirmCue = _findCue(lower, rules.confirms);
    if (confirmCue != null) {
      return DetectedIntent(
        type: 'confirms',
        text: trimmed,
        confidence: 0.7,
        matchedCue: confirmCue,
      );
    }

    if (planCue != null) {
      return DetectedIntent(
        type: 'plan',
        text: trimmed,
        confidence: 0.7,
        dueAt: dueAt,
        matchedCue: planCue,
      );
    }

    if (trimmed.endsWith('?')) {
      return DetectedIntent(
        type: 'asks_you',
        text: trimmed,
        confidence: hasDate ? 0.7 : 0.4,
        dueAt: dueAt,
        matchedCue: '?',
      );
    }

    return DetectedIntent(
      type: 'fyi',
      text: trimmed,
      confidence: 0.4,
      dueAt: dueAt,
    );
  }

  String? _findCue(String lowerText, List<String> cues) {
    for (final cue in cues) {
      if (cue.isEmpty) continue;
      final isAsciiWord = RegExp(r'^[a-z0-9\s]+$').hasMatch(cue);
      if (isAsciiWord) {
        final pattern = RegExp(r'(?:^|\b)' + RegExp.escape(cue) + r'(?:\b|$)');
        if (pattern.hasMatch(lowerText)) return cue;
      } else if (lowerText.contains(cue)) {
        return cue;
      }
    }
    return null;
  }

  /// Resolves relative and explicit date/time phrases in English, Bangla,
  /// and Banglish into a concrete `DateTime`.
  DateTime? resolveDueDate(String text, DateTime ref) {
    final lower = text.toLowerCase();

    // 1. Explicit dd/mm/yyyy or dd-mm-yyyy.
    final slash = RegExp(r'\b(\d{1,2})[/\-](\d{1,2})[/\-](\d{2,4})\b').firstMatch(lower);
    if (slash != null) {
      final d = int.parse(slash.group(1)!);
      final m = int.parse(slash.group(2)!);
      var y = int.parse(slash.group(3)!);
      if (y < 100) y += 2000;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d, 18, 0);
      }
    }

    // 2. "30 Nov" or "3 December".
    final dayMonth = RegExp(
      r'\b(\d{1,2})\s+(jan|january|feb|february|mar|march|apr|april|may|jun|june|jul|july|aug|august|sep|sept|september|oct|october|nov|november|dec|december)(?:\s+(\d{4}))?\b',
    ).firstMatch(lower);
    if (dayMonth != null) {
      final d = int.parse(dayMonth.group(1)!);
      final m = _months[dayMonth.group(2)!]!;
      var y = dayMonth.group(3) != null ? int.parse(dayMonth.group(3)!) : ref.year;
      var candidate = DateTime(y, m, d, 18, 0);
      if (dayMonth.group(3) == null && candidate.isBefore(DateTime(ref.year, ref.month, ref.day))) {
        candidate = DateTime(y + 1, m, d, 18, 0);
      }
      return candidate;
    }

    // 3. Today / ajke / আজকে.
    if (RegExp(r'\b(?:today|tonight|ajke|aaj)\b').hasMatch(lower) ||
        lower.contains('আজ') ||
        lower.contains('আজকে')) {
      return DateTime(ref.year, ref.month, ref.day, 18, 0);
    }

    // 4. Tomorrow morning: "kal shokale" / "কাল সকালে" / "tomorrow morning".
    if (lower.contains('kal shokale') ||
        lower.contains('kal sokale') ||
        lower.contains('tomorrow morning') ||
        lower.contains('কাল সকালে')) {
      final tmr = ref.add(const Duration(days: 1));
      return DateTime(tmr.year, tmr.month, tmr.day, 9, 0);
    }

    // 5. Tomorrow / kal / আগামীকাল / কাল.
    if (RegExp(r'\b(?:tomorrow|kal|agamilkal)\b').hasMatch(lower) ||
        lower.contains('আগামীকাল') ||
        lower.contains('কাল')) {
      final tmr = ref.add(const Duration(days: 1));
      return DateTime(tmr.year, tmr.month, tmr.day, 18, 0);
    }

    // 6. Weekday ("before Thursday", "on Friday", "Thursday 3 pm").
    final wdMatch = RegExp(
      r'\b(before\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun)\b',
    ).firstMatch(lower);
    if (wdMatch != null) {
      final targetWd = _weekdays[wdMatch.group(2)!]!;
      var delta = (targetWd - ref.weekday) % 7;
      if (delta <= 0) delta += 7;
      final target = ref.add(Duration(days: delta));
      return DateTime(target.year, target.month, target.day, 18, 0);
    }

    // 7. Explicit time only ("at 5 pm", "15:00").
    final timeMatch = RegExp(r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b').firstMatch(lower);
    if (timeMatch != null) {
      var hour = int.parse(timeMatch.group(1)!);
      final min = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      final meridiem = timeMatch.group(3)!;
      if (meridiem == 'pm' && hour < 12) hour += 12;
      if (meridiem == 'am' && hour == 12) hour = 0;
      return DateTime(ref.year, ref.month, ref.day, hour, min);
    }

    return null;
  }
}
