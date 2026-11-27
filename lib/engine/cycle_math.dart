import 'rules_loader.dart';

class ComputedCycle {
  const ComputedCycle({
    required this.certainty, // stated | learned | guess
    required this.cycleData,
    required this.nextFrom,
    required this.nextTo,
    required this.basisLabel,
  });

  final String certainty;
  final Map<String, dynamic> cycleData;
  final int? nextFrom;
  final int? nextTo;
  final String basisLabel;
}

class CycleMath {
  static const _dayMs = 24 * 60 * 60 * 1000;

  static double median(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2.0;
  }

  static double mad(List<double> values, double med) {
    if (values.isEmpty) return 0;
    final absDevs = values.map((v) => (v - med).abs()).toList();
    return median(absDevs);
  }

  static DateTime? parseExplicitDate(String? raw, DateTime ref) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final slash = RegExp(r'^(\d{1,2})[/\-](\d{1,2})[/\-](\d{2,4})$').firstMatch(s);
    if (slash != null) {
      final d = int.parse(slash.group(1)!);
      final m = int.parse(slash.group(2)!);
      var y = int.parse(slash.group(3)!);
      if (y < 100) y += 2000;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d, 9, 0);
      }
    }
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    final word = RegExp(r'^(\d{1,2})\s+([A-Za-z]{3})[A-Za-z]*(?:\s+(\d{4}))?$').firstMatch(s);
    if (word != null) {
      final d = int.parse(word.group(1)!);
      final m = months[word.group(2)!.toLowerCase()];
      if (m != null) {
        final y = word.group(3) != null ? int.parse(word.group(3)!) : ref.year;
        return DateTime(y, m, d, 9, 0);
      }
    }
    return null;
  }

  /// Computes cycle in strict priority order from `03-engines.md`:
  /// 1. Explicit stated date/rrule (`due_date`, `valid_until`, `rrule`) -> `stated`
  /// 2. Learned from >= 3 events (consistent median/MAD, monthly anchor, or weekly anchor) -> `learned`
  /// 3. Single/2-event stated `valid_days` -> `stated`
  /// 4. Guess from `priors.json` -> `guess`
  static ComputedCycle? compute({
    required String kind,
    required List<int> timestampsMs,
    required Map<String, PriorSpec> priors,
    String? dueDateRaw,
    String? validUntilRaw,
    int? validDays,
    String? rrule,
    DateTime? now,
  }) {
    if (timestampsMs.isEmpty) return null;
    final sorted = List<int>.from(timestampsMs)..sort();
    final lastMs = sorted.last;
    final lastDt = DateTime.fromMillisecondsSinceEpoch(lastMs);
    final ref = now ?? lastDt;

    // 1a. Explicit due_date or valid_until -> Stated.
    final explicitTarget = parseExplicitDate(dueDateRaw ?? validUntilRaw, lastDt);
    if (explicitTarget != null) {
      final ms = explicitTarget.millisecondsSinceEpoch;
      return ComputedCycle(
        certainty: 'stated',
        cycleData: {
          'mode': 'stated_date',
          'due_date': dueDateRaw ?? validUntilRaw,
        },
        nextFrom: ms,
        nextTo: ms,
        basisLabel: dueDateRaw != null
            ? 'Due date is in the SMS.'
            : 'Expiry date is in the message.',
      );
    }

    // 1b. Calendar RRULE -> Stated.
    if (rrule != null && rrule.trim().isNotEmpty) {
      final intervalDays = rrule.toUpperCase().contains('MONTHLY')
          ? 30
          : rrule.toUpperCase().contains('DAILY')
              ? 1
              : 7;
      var next = lastDt.add(Duration(days: intervalDays));
      while (next.isBefore(ref)) {
        next = next.add(Duration(days: intervalDays));
      }
      final ms = next.millisecondsSinceEpoch;
      return ComputedCycle(
        certainty: 'stated',
        cycleData: {
          'mode': 'rrule',
          'rrule': rrule,
          'interval_days': intervalDays,
        },
        nextFrom: ms,
        nextTo: ms,
        basisLabel: 'Repeats on your calendar.',
      );
    }

    // 2. Learned from 3+ events.
    if (sorted.length >= 3) {
      final dts = sorted.map(DateTime.fromMillisecondsSinceEpoch).toList();
      final gapsDays = <double>[];
      for (var i = 1; i < sorted.length; i++) {
        gapsDays.add((sorted[i] - sorted[i - 1]) / _dayMs);
      }
      final m = median(gapsDays);
      final d = mad(gapsDays, m);

      // 2a. Monthly day-of-month anchor (day varies by <= 2 across >= 3 events, median ~28-31d).
      final doms = dts.map((dt) => dt.day).toList();
      final minDom = doms.reduce((a, b) => a < b ? a : b);
      final maxDom = doms.reduce((a, b) => a > b ? a : b);
      if (m >= 26 && m <= 34 && (maxDom - minDom) <= 2) {
        final anchorDay = median(doms.map((e) => e.toDouble()).toList()).round();
        final nextMonth = DateTime(
          lastDt.year,
          lastDt.month + 1,
          anchorDay.clamp(1, 28),
          lastDt.hour,
          lastDt.minute,
        );
        final marginMs = _dayMs;
        return ComputedCycle(
          certainty: 'learned',
          cycleData: {
            'mode': 'monthly_anchor',
            'anchor_day': anchorDay,
            'interval_days': 30,
            'count': sorted.length,
            'median_days': m,
            'mad_days': d,
          },
          nextFrom: nextMonth.millisecondsSinceEpoch - marginMs,
          nextTo: nextMonth.millisecondsSinceEpoch + marginMs,
          basisLabel: 'Around the ${_ordinal(anchorDay)} of every month, ${sorted.length} times.',
        );
      }

      // 2b. Weekly anchor: same weekday holds in >= 4 of the last 6 weeks.
      final weekly = _detectWeeklyAnchor(dts, ref);
      if (weekly != null) return weekly;

      // 2c. Regular interval: MAD <= 0.2 * median.
      if (m >= 1 && d <= 0.2 * m) {
        final roundedDays = m.round();
        final marginDays = (1.5 * d) < 1.0 ? 1.0 : (1.5 * d);
        final centerMs = lastMs + (m * _dayMs).round();
        final marginMs = (marginDays * _dayMs).round();
        return ComputedCycle(
          certainty: 'learned',
          cycleData: {
            'mode': 'interval',
            'interval_days': roundedDays,
            'median_days': m,
            'mad_days': d,
            'margin_days': marginDays.round(),
            'count': sorted.length,
          },
          nextFrom: centerMs - marginMs,
          nextTo: centerMs + marginMs,
          basisLabel: 'Every $roundedDays days, ${sorted.length} times running',
        );
      }
    }

    // 3. Single or two events with stated valid_days -> Stated.
    if (validDays != null && validDays > 0) {
      final nextMs = lastMs + validDays * _dayMs;
      return ComputedCycle(
        certainty: 'stated',
        cycleData: {
          'mode': 'valid_days',
          'interval_days': validDays,
        },
        nextFrom: nextMs,
        nextTo: nextMs,
        basisLabel: 'Valid for $validDays days.',
      );
    }

    // 4. Guess from priors.json (only for kinds with a prior).
    final prior = priors[kind];
    if (prior != null) {
      final center = prior.monthly
          ? DateTime(lastDt.year, lastDt.month + 1, lastDt.day.clamp(1, 28), 9, 0)
          : lastDt.add(Duration(days: prior.days));
      const marginMs = 2 * _dayMs;
      return ComputedCycle(
        certainty: 'guess',
        cycleData: {
          'mode': 'prior',
          'interval_days': prior.days,
          'count': sorted.length,
        },
        nextFrom: center.millisecondsSinceEpoch - marginMs,
        nextTo: center.millisecondsSinceEpoch + marginMs,
        basisLabel: sorted.length == 1
            ? 'Seen once, estimated from usual ${prior.days}-day cycle'
            : 'Seen ${sorted.length} times, estimated cycle',
      );
    }

    return null;
  }

  static ComputedCycle? _detectWeeklyAnchor(List<DateTime> dts, DateTime ref) {
    final sixWeeksAgo = ref.subtract(const Duration(days: 45));
    final recent = dts.where((dt) => !dt.isBefore(sixWeeksAgo)).toList();
    if (recent.length < 4) return null;

    final byWeekday = <int, Set<int>>{};
    final timesByWeekday = <int, List<DateTime>>{};
    for (final dt in recent) {
      final weekBucket = dt.millisecondsSinceEpoch ~/ (7 * _dayMs);
      byWeekday.putIfAbsent(dt.weekday, () => <int>{}).add(weekBucket);
      timesByWeekday.putIfAbsent(dt.weekday, () => <DateTime>[]).add(dt);
    }

    int? bestWeekday;
    var bestWeeks = 0;
    for (final entry in byWeekday.entries) {
      if (entry.value.length > bestWeeks) {
        bestWeeks = entry.value.length;
        bestWeekday = entry.key;
      }
    }
    if (bestWeekday == null || bestWeeks < 4) return null;

    final matching = timesByWeekday[bestWeekday]!;
    final avgMinutes = matching
            .map((d) => d.hour * 60 + d.minute)
            .reduce((a, b) => a + b) ~/
        matching.length;
    final avgHour = avgMinutes ~/ 60;
    final avgMin = avgMinutes % 60;

    // Next occurrence of bestWeekday at avgHour:avgMin on or after ref.
    var delta = (bestWeekday - ref.weekday) % 7;
    var next = DateTime(ref.year, ref.month, ref.day, avgHour, avgMin)
        .add(Duration(days: delta));
    if (next.isBefore(ref)) {
      next = next.add(const Duration(days: 7));
    }
    const hourMargin = 60 * 60 * 1000;
    return ComputedCycle(
      certainty: 'learned',
      cycleData: {
        'mode': 'weekly_anchor',
        'weekday': bestWeekday,
        'hour': avgHour,
        'minute': avgMin,
        'interval_days': 7,
        'weeks_matched': bestWeeks,
      },
      nextFrom: next.millisecondsSinceEpoch - hourMargin,
      nextTo: next.millisecondsSinceEpoch + hourMargin,
      basisLabel: '$bestWeeks of the last 6 ${_weekdayName(bestWeekday)}s',
    );
  }

  /// Evaluates series state given `nowMs`, `nextFrom`, `nextTo`, and `intervalDays`.
  static String evaluateState({
    required int nowMs,
    required int? nextFrom,
    required int? nextTo,
    required int intervalDays,
  }) {
    if (nextFrom == null || nextTo == null) return 'expected';
    const graceMs = _dayMs;
    final cycleMs = (intervalDays > 0 ? intervalDays : 30) * _dayMs;

    if (nowMs < nextFrom) return 'expected';
    if (nowMs <= nextTo) return 'due';
    if (nowMs <= nextTo + graceMs) return 'due';
    // Two misses in a row -> dormant.
    if (nowMs > nextTo + cycleMs + graceMs) return 'dormant';
    return 'late';
  }

  static String _weekdayName(int wd) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][wd - 1];

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}
