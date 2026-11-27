import 'dart:convert';
import 'package:drift/drift.dart';
import '../data/database.dart';

class StrengthUpdateResult {
  const StrengthUpdateResult({
    required this.newStrength,
    required this.movedToQuiet,
    this.notice,
  });

  final double newStrength;
  final bool movedToQuiet;
  final String? notice;
}

/// Manages user decisions (`show`, `quiet`, `drop`), 2-drop kind suppression,
/// ranked New proposal queue (max 4), implicit strength adjustments, user
/// cycle overrides, and 90-day pattern check-ins per `03-engines.md` section 8.
class FeedbackEngine {
  FeedbackEngine(this.db);

  final MemoryDatabase db;

  static const _checkInKey = 'last_pattern_checkin_at';
  static const _ninetyDaysMs = 90 * 24 * 60 * 60 * 1000;

  /// Returns at most 4 undecided, unsuppressed series ranked:
  /// money due first -> people -> calendar -> email -> chat.
  Future<List<SeriesRow>> getNewProposals({int limit = 4}) async {
    final undecided = await (db.select(db.series)
          ..where((t) => t.decision.equals('undecided') & t.tracking.equals(true)))
        .get();
    final suppressions = await db.select(db.suppressRule).get();

    final eligible = undecided.where((s) {
      return !suppressions.any(
        (r) =>
            r.family == s.family &&
            r.kind == s.kind &&
            (r.counterpartKey == null || r.counterpartKey == s.counterpartKey),
      );
    }).toList();

    eligible.sort((a, b) {
      final rankCmp = _proposalRank(a).compareTo(_proposalRank(b));
      if (rankCmp != 0) return rankCmp;
      final aNext = a.nextFrom ?? 1 << 62;
      final bNext = b.nextFrom ?? 1 << 62;
      return aNext.compareTo(bNext);
    });

    return eligible.take(limit).toList();
  }

  int _proposalRank(SeriesRow s) => switch (s.family) {
    'sms' => 0,
    'order' => 1,
    'call' => 2,
    'calendar' => 3,
    'email' => 4,
    'chat' => 5,
    _ => 6,
  };

  Future<void> setDecision({
    required int seriesId,
    required String decision, // show | quiet | drop
    DateTime? now,
  }) async {
    final s = await (db.select(db.series)..where((t) => t.id.equals(seriesId)))
        .getSingleOrNull();
    if (s == null) return;
    final atMs = (now ?? DateTime.now()).millisecondsSinceEpoch;

    await (db.update(db.series)..where((t) => t.id.equals(seriesId))).write(
      SeriesCompanion(
        decision: Value(decision),
        tracking: Value(decision != 'drop'),
      ),
    );
    await db.into(db.feedback).insert(
      FeedbackCompanion.insert(
        targetType: 'series',
        targetId: seriesId,
        action: decision,
        at: atMs,
      ),
    );

    if (decision == 'drop') {
      await db.into(db.suppressRule).insert(
        SuppressRuleCompanion.insert(
          family: s.family,
          kind: s.kind,
          counterpartKey: Value(s.counterpartKey),
          reason: const Value('user_drop'),
        ),
      );

      // Two drops with the same (family, kind) add a kind-wide suppress rule.
      final droppedSameKind = await (db.select(db.suppressRule)
            ..where(
              (t) =>
                  t.family.equals(s.family) &
                  t.kind.equals(s.kind) &
                  t.counterpartKey.isNotNull(),
            ))
          .get();
      final distinctCounterparts = droppedSameKind
          .map((r) => r.counterpartKey)
          .whereType<String>()
          .toSet();
      if (distinctCounterparts.length >= 2) {
        final alreadyKindWide = await (db.select(db.suppressRule)
              ..where(
                (t) =>
                    t.family.equals(s.family) &
                    t.kind.equals(s.kind) &
                    t.counterpartKey.isNull(),
              ))
            .get();
        if (alreadyKindWide.isEmpty) {
          await db.into(db.suppressRule).insert(
            SuppressRuleCompanion.insert(
              family: s.family,
              kind: s.kind,
              counterpartKey: const Value(null),
              reason: const Value('two_drops_same_kind'),
            ),
          );
        }
      }
    }
  }

  /// Adjusts implicit strength:
  /// opened +1, reminder_acted +2, reminder_dismissed -1, shown_30d_unused -1.
  /// Strength below -3 moves a shown series to quiet and returns a one-time notice.
  Future<StrengthUpdateResult> recordImplicitSignal({
    required int seriesId,
    required String action,
    DateTime? now,
  }) async {
    final s = await (db.select(db.series)..where((t) => t.id.equals(seriesId)))
        .getSingle();
    final delta = switch (action) {
      'opened' => 1.0,
      'reminder_acted' => 2.0,
      'reminder_dismissed' => -1.0,
      'shown_30d_unused' => -1.0,
      _ => 0.0,
    };
    final nextStrength = s.strength + delta;
    final shouldQuiet = s.decision == 'show' && nextStrength < -3.0;

    await (db.update(db.series)..where((t) => t.id.equals(seriesId))).write(
      SeriesCompanion(
        strength: Value(nextStrength),
        decision: shouldQuiet ? const Value('quiet') : const Value.absent(),
      ),
    );
    await db.into(db.feedback).insert(
      FeedbackCompanion.insert(
        targetType: 'series',
        targetId: seriesId,
        action: action,
        at: (now ?? DateTime.now()).millisecondsSinceEpoch,
      ),
    );

    return StrengthUpdateResult(
      newStrength: nextStrength,
      movedToQuiet: shouldQuiet,
      notice: shouldQuiet
          ? 'Moved "${s.title}" to Track quietly because it was dismissed or unused.'
          : null,
    );
  }

  /// Sets a user-defined interval in days that is never overwritten by rebuilds.
  Future<void> setUserCycle({
    required int seriesId,
    required int intervalDays,
  }) async {
    final s = await (db.select(db.series)..where((t) => t.id.equals(seriesId)))
        .getSingle();
    final cycle = _parseMap(s.cycleJson);
    cycle['user_fixed'] = true;
    cycle['interval_days'] = intervalDays;
    cycle['mode'] = 'user_fixed';
    cycle['basis'] = 'Set by you: every $intervalDays days.';

    final nextMs = s.lastEventAt + intervalDays * 24 * 60 * 60 * 1000;
    await (db.update(db.series)..where((t) => t.id.equals(seriesId))).write(
      SeriesCompanion(
        cycleJson: Value(jsonEncode(cycle)),
        certainty: const Value('stated'),
        nextFrom: Value(nextMs),
        nextTo: Value(nextMs),
      ),
    );
  }

  Future<bool> isCheckInDue(DateTime now) async {
    final shown = await (db.select(db.series)
          ..where((t) => t.decision.equals('show')))
        .get();
    if (shown.isEmpty) return false;
    final raw = await db.getSetting(_checkInKey);
    final last = int.tryParse(raw ?? '');
    if (last == null) return false;
    return (now.millisecondsSinceEpoch - last) >= _ninetyDaysMs;
  }

  Future<void> recordCheckIn(DateTime now) async {
    await db.setSetting(_checkInKey, now.millisecondsSinceEpoch.toString());
  }

  Map<String, dynamic> _parseMap(String raw) {
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : const {};
    } catch (_) {
      return const {};
    }
  }
}
