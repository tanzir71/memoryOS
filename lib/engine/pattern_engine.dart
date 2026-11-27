import 'dart:convert';
import 'package:drift/drift.dart';
import '../data/database.dart';
import 'cycle_math.dart';
import 'rules_loader.dart';

class PatternEngine {
  PatternEngine(this.db, this.rules);

  final MemoryDatabase db;
  final EngineRules rules;

  /// Rebuilds all series from stored kept signals (used after history import)
  /// while preserving user decisions, suppressions, and user-fixed cycles.
  Future<void> rebuildAll({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final signals = await (db.select(db.signal)
          ..where((t) => t.deletedAt.isNull() & t.kept.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();

    final buckets = <String, _SeriesBucket>{};
    for (final sig in signals) {
      final key = await _classifyForSeries(sig);
      if (key == null) continue;
      buckets.putIfAbsent(key.compositeKey, () => _SeriesBucket(key)).signals.add(sig);
    }

    for (final bucket in buckets.values) {
      await _upsertBucket(bucket, current);
    }

    await evaluateStates(current);
  }

  /// Incrementally updates or creates the series for a newly processed signal.
  Future<void> updateForSignal(SignalRow sig, {DateTime? now}) async {
    if (!sig.kept || sig.deletedAt != null) return;
    final key = await _classifyForSeries(sig);
    if (key == null) return;

    final existing = await (db.select(db.series)
          ..where(
            (t) =>
                t.family.equals(key.family) &
                t.kind.equals(key.kind) &
                t.counterpartKey.equals(key.counterpartKey),
          ))
        .getSingleOrNull();

    final allBucketSignals = <SignalRow>[sig];
    if (existing != null) {
      final links = await (db.select(db.seriesSignal)
            ..where((t) => t.seriesId.equals(existing.id)))
          .get();
      final ids = links.map((l) => l.signalId).where((id) => id != sig.id).toList();
      if (ids.isNotEmpty) {
        allBucketSignals.addAll(
          await (db.select(db.signal)..where((t) => t.id.isIn(ids))).get(),
        );
      }
      allBucketSignals.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    }

    final bucket = _SeriesBucket(key)..signals.addAll(allBucketSignals);
    await _upsertBucket(bucket, now ?? DateTime.now());
  }

  /// Evaluates expected / due / late / dormant states and creates late open loops.
  Future<void> evaluateStates(DateTime now) async {
    final nowMs = now.millisecondsSinceEpoch;
    final all = await (db.select(db.series)
          ..where((t) => t.tracking.equals(true)))
        .get();

    for (final s in all) {
      final cycle = _parseMap(s.cycleJson);
      final intervalDays = (cycle['interval_days'] as num?)?.toInt() ?? 30;
      final nextState = CycleMath.evaluateState(
        nowMs: nowMs,
        nextFrom: s.nextFrom,
        nextTo: s.nextTo,
        intervalDays: intervalDays,
      );
      if (nextState != s.state) {
        await (db.update(db.series)..where((t) => t.id.equals(s.id))).write(
          SeriesCompanion(state: Value(nextState)),
        );
      }

      if (nextState == 'late' && (s.decision == 'show' || s.decision == 'quiet')) {
        await _ensureLateOpenLoop(s);
      }
    }
  }

  Future<void> _upsertBucket(_SeriesBucket bucket, DateTime now) async {
    final key = bucket.key;
    final sigs = bucket.signals;
    if (sigs.isEmpty) return;

    // Check suppress rules (exact counterpart OR kind-wide).
    final suppressed = await _isSuppressed(key.family, key.kind, key.counterpartKey);

    final existing = await (db.select(db.series)
          ..where(
            (t) =>
                t.family.equals(key.family) &
                t.kind.equals(key.kind) &
                t.counterpartKey.equals(key.counterpartKey),
          ))
        .getSingleOrNull();

    // Respect user-fixed cycles: never overwrite cycleJson/nextFrom/nextTo!
    final existingCycle = existing != null ? _parseMap(existing.cycleJson) : const <String, dynamic>{};
    if (existing != null && existingCycle['user_fixed'] == true) {
      final intervalDays = (existingCycle['interval_days'] as num?)?.toInt() ?? 30;
      final lastMs = sigs.last.occurredAt;
      final nextMs = lastMs + intervalDays * 24 * 60 * 60 * 1000;
      await (db.update(db.series)..where((t) => t.id.equals(existing.id))).write(
        SeriesCompanion(
          lastEventAt: Value(lastMs),
          nextFrom: Value(nextMs),
          nextTo: Value(nextMs),
          state: const Value('expected'),
        ),
      );
      await _linkSignals(existing.id, sigs);
      return;
    }

    // Special case: noisy chat group -> "Suggested: drop" if heavy volume & 0 asks for 30 days.
    if (key.family == 'chat' && key.kind == 'group_chat') {
      final groupResult = await _evaluateChatGroup(sigs);
      if (groupResult == null) return;
      final decision = existing?.decision ?? (suppressed ? 'drop' : 'undecided');
      final tracking = existing?.tracking ?? !suppressed;
      final seriesId = await _saveSeries(
        existing: existing,
        key: key,
        title: key.title,
        cycleJson: jsonEncode(groupResult),
        certainty: 'learned',
        decision: decision,
        tracking: tracking,
        lastEventAt: sigs.last.occurredAt,
        nextFrom: null,
        nextTo: null,
        state: 'expected',
      );
      await _linkSignals(seriesId, sigs);
      return;
    }

    // Filter amount outliers (> 25% away from median) for financial series.
    final filteredSigs = _filterByAmountBand(sigs);
    final latestExtras = _parseMap(filteredSigs.last.extrasJson);
    final computed = CycleMath.compute(
      kind: key.kind,
      timestampsMs: filteredSigs.map((s) => s.occurredAt).toList(),
      priors: rules.priors,
      dueDateRaw: latestExtras['due_date']?.toString(),
      validUntilRaw: latestExtras['valid_until']?.toString(),
      validDays: int.tryParse(latestExtras['valid_days']?.toString() ?? ''),
      rrule: latestExtras['rrule']?.toString(),
      now: now,
    );
    if (computed == null) return;

    final cycleData = Map<String, dynamic>.from(computed.cycleData);
    cycleData['basis'] = computed.basisLabel;

    // Usual amount for financial series.
    final amounts = filteredSigs
        .map((s) => double.tryParse((_parseMap(s.extrasJson)['amount']?.toString() ?? '').replaceAll(',', '')))
        .whereType<double>()
        .toList();
    if (amounts.isNotEmpty) {
      cycleData['usual_amount'] = CycleMath.median(amounts);
    }

    // Calendar join/leave overrun learning.
    if (key.family == 'calendar') {
      final overrun = await _computeMeetingOverrun(filteredSigs);
      if (overrun != null) cycleData.addAll(overrun);
    }

    // Newsletters are created as quiet and never proposed.
    final isNewsletter = key.family == 'email' && key.kind == 'newsletter';
    final initialDecision = suppressed
        ? 'drop'
        : isNewsletter
            ? 'quiet'
            : 'undecided';
    final decision = existing?.decision ?? initialDecision;
    final tracking = existing?.tracking ?? !suppressed;

    final intervalDays = (cycleData['interval_days'] as num?)?.toInt() ?? 30;
    final state = CycleMath.evaluateState(
      nowMs: now.millisecondsSinceEpoch,
      nextFrom: computed.nextFrom,
      nextTo: computed.nextTo,
      intervalDays: intervalDays,
    );

    final seriesId = await _saveSeries(
      existing: existing,
      key: key,
      title: key.title,
      cycleJson: jsonEncode(cycleData),
      certainty: computed.certainty,
      decision: decision,
      tracking: tracking,
      lastEventAt: filteredSigs.last.occurredAt,
      nextFrom: computed.nextFrom,
      nextTo: computed.nextTo,
      state: state,
    );
    await _linkSignals(seriesId, filteredSigs);
  }

  Future<int> _saveSeries({
    required SeriesRow? existing,
    required _SeriesKey key,
    required String title,
    required String cycleJson,
    required String certainty,
    required String decision,
    required bool tracking,
    required int lastEventAt,
    required int? nextFrom,
    required int? nextTo,
    required String state,
  }) async {
    if (existing != null) {
      await (db.update(db.series)..where((t) => t.id.equals(existing.id))).write(
        SeriesCompanion(
          title: Value(title),
          cycleJson: Value(cycleJson),
          certainty: Value(certainty),
          lastEventAt: Value(lastEventAt),
          nextFrom: Value(nextFrom),
          nextTo: Value(nextTo),
          state: Value(state),
        ),
      );
      return existing.id;
    }
    return db.into(db.series).insert(
      SeriesCompanion.insert(
        family: key.family,
        kind: key.kind,
        counterpartKey: key.counterpartKey,
        title: title,
        cycleJson: Value(cycleJson),
        certainty: Value(certainty),
        decision: Value(decision),
        tracking: Value(tracking),
        lastEventAt: lastEventAt,
        nextFrom: Value(nextFrom),
        nextTo: Value(nextTo),
        state: Value(state),
      ),
    );
  }

  Future<void> _linkSignals(int seriesId, List<SignalRow> sigs) async {
    for (final s in sigs) {
      await db.into(db.seriesSignal).insertOnConflictUpdate(
        SeriesSignalCompanion.insert(seriesId: seriesId, signalId: s.id),
      );
    }
  }

  Future<_SeriesKey?> _classifyForSeries(SignalRow sig) async {
    final extras = _parseMap(sig.extrasJson);
    final extractKind = extras['extractKind']?.toString() ?? '';

    // SMS / financial transactions.
    if (sig.signalClass == 'transaction' || sig.source == 'sms') {
      if (extractKind == 'recharge' || extractKind == 'pack_expiry') {
        final op = sig.title.isNotEmpty ? sig.title : 'Mobile';
        return _SeriesKey(
          family: 'sms',
          kind: extractKind,
          counterpartKey: op.toLowerCase(),
          title: 'Mobile recharge',
        );
      }
      if (extractKind == 'internet_bill' ||
          extractKind == 'utility_bill' ||
          extractKind == 'card_bill') {
        final provider = sig.title.isNotEmpty ? sig.title : 'Bill';
        final label = extractKind == 'internet_bill'
            ? 'Internet bill'
            : extractKind == 'card_bill'
                ? 'Card bill'
                : '$provider bill';
        return _SeriesKey(
          family: 'sms',
          kind: extractKind,
          counterpartKey: provider.toLowerCase(),
          title: label,
        );
      }
      if (extractKind == 'send_money' || extractKind == 'money_received') {
        final cp = extras['counterparty']?.toString() ?? sig.title;
        if (cp.isEmpty) return null;
        return _SeriesKey(
          family: 'sms',
          kind: extractKind == 'send_money' ? 'rent' : 'money_received',
          counterpartKey: cp.toLowerCase(),
          title: extractKind == 'send_money' ? 'Transfer to $cp' : 'From $cp',
        );
      }
    }

    // Order family (including gas cylinder / grocery reorder).
    if (sig.signalClass == 'order') {
      final combined = '${sig.title} ${sig.body}'.toLowerCase();
      if (combined.contains('gas cylinder') || combined.contains('lpg')) {
        return const _SeriesKey(
          family: 'order',
          kind: 'gas_cylinder',
          counterpartKey: 'gas_cylinder',
          title: 'Gas cylinder',
        );
      }
      if (combined.contains('grocer') || combined.contains('chaldal') || combined.contains('shwapno')) {
        return _SeriesKey(
          family: 'order',
          kind: 'grocery_reorder',
          counterpartKey: (extras['merchant']?.toString() ?? sig.title).toLowerCase(),
          title: 'Grocery order',
        );
      }
      final merchant = extras['merchant']?.toString() ?? sig.title;
      final item = extras['item']?.toString() ?? '';
      if (merchant.isNotEmpty && item.isNotEmpty) {
        return _SeriesKey(
          family: 'order',
          kind: 'reorder',
          counterpartKey: '${merchant.toLowerCase()}::${item.toLowerCase()}',
          title: item,
        );
      }
    }

    // Call family: outgoing/incoming calls per person.
    if (sig.signalClass == 'call') {
      final callType = (extras['callType']?.toString() ?? sig.kind).toLowerCase();
      if (callType == 'missed' || callType == 'missed_call') return null;
      String name = sig.title;
      String cpKey = sig.personId != null ? 'person:${sig.personId}' : sig.title.toLowerCase();
      if (sig.personId != null) {
        final p = await (db.select(db.person)..where((t) => t.id.equals(sig.personId!))).getSingleOrNull();
        if (p != null) name = p.displayName;
      }
      if (name.isEmpty) return null;
      return _SeriesKey(
        family: 'call',
        kind: 'regular_call',
        counterpartKey: cpKey,
        title: 'Call with $name',
      );
    }

    // Calendar family: recurring events.
    if (sig.source == 'calendar' && (extras['rrule']?.toString().isNotEmpty ?? false)) {
      return _SeriesKey(
        family: 'calendar',
        kind: 'recurring_meeting',
        counterpartKey: sig.title.toLowerCase(),
        title: sig.title,
      );
    }

    // Email family: sender + subject with numbers & dates stripped.
    if (sig.signalClass == 'email') {
      final subject = sig.body.split('\n').first;
      final lower = subject.toLowerCase();
      final isNewsletter = lower.contains('newsletter') || lower.contains('digest') || lower.contains('unsubscribe');
      final isPeriodic = isNewsletter ||
          lower.contains('invoice') ||
          lower.contains('renewal') ||
          lower.contains('statement') ||
          lower.contains('weekly report');
      if (!isPeriodic) return null;
      final stripped = subject
          .toLowerCase()
          .replaceAll(RegExp(r'\b\d+[/-]\d+[/-]\d+\b|\b\d+\b'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      return _SeriesKey(
        family: 'email',
        kind: isNewsletter ? 'newsletter' : 'periodic_email',
        counterpartKey: '${sig.title.toLowerCase()}::$stripped',
        title: subject.trim(),
      );
    }

    // Chat group family.
    if (sig.signalClass == 'conversation' && extras['isGroup'] == true) {
      final groupName = extras['conversationTitle']?.toString() ?? sig.title;
      if (groupName.isEmpty) return null;
      return _SeriesKey(
        family: 'chat',
        kind: 'group_chat',
        counterpartKey: '${sig.pkg}::${groupName.toLowerCase()}',
        title: groupName,
      );
    }

    return null;
  }

  Future<Map<String, dynamic>?> _evaluateChatGroup(List<SignalRow> sigs) async {
    final ids = sigs.map((s) => s.id).toList();
    final asks = await (db.select(db.signalIntent)
          ..where((t) => t.signalId.isIn(ids) & t.type.equals('asks_you')))
        .get();
    var totalMessages = 0;
    var spanDays = 1;
    for (final s in sigs) {
      final ex = _parseMap(s.extrasJson);
      totalMessages += (ex['dailyMessageCount'] as num?)?.toInt() ?? 1;
    }
    if (sigs.length >= 2) {
      spanDays = ((sigs.last.occurredAt - sigs.first.occurredAt) / (24 * 60 * 60 * 1000)).round().clamp(1, 365);
    }
    final avgPerDay = totalMessages / spanDays;
    if (spanDays >= 25 && avgPerDay >= 20 && asks.isEmpty) {
      return {
        'mode': 'noisy_group',
        'suggested_drop': true,
        'messages_per_day': avgPerDay.round(),
        'days_observed': spanDays,
        'asks_count': 0,
        'basis': '${avgPerDay.round()} messages/day for $spanDays days, no asks.',
      };
    }
    return null;
  }

  Future<Map<String, dynamic>?> _computeMeetingOverrun(List<SignalRow> calSigs) async {
    final overruns = <int>[];
    for (final cal in calSigs) {
      if (cal.endedAt == null) continue;
      final ts = await (db.select(db.threadSignal)..where((t) => t.signalId.equals(cal.id))).getSingleOrNull();
      if (ts == null) continue;
      final siblings = await (db.select(db.threadSignal)..where((t) => t.threadId.equals(ts.threadId))).get();
      final sibSigs = await (db.select(db.signal)..where((t) => t.id.isIn(siblings.map((e) => e.signalId)))).get();
      for (final other in sibSigs) {
        if (other.signalClass == 'call' && other.endedAt != null) {
          final diffMin = ((other.endedAt! - cal.endedAt!) / 60000).round();
          if (diffMin > 0) overruns.add(diffMin);
        }
      }
    }
    if (overruns.isEmpty) return null;
    final avgOver = overruns.reduce((a, b) => a + b) ~/ overruns.length;
    return {'usually_runs_long_min': avgOver};
  }

  List<SignalRow> _filterByAmountBand(List<SignalRow> sigs) {
    final parsed = <(SignalRow, double?)>[];
    final amounts = <double>[];
    for (final s in sigs) {
      final raw = _parseMap(s.extrasJson)['amount']?.toString();
      final amt = raw == null ? null : double.tryParse(raw.replaceAll(',', ''));
      parsed.add((s, amt));
      if (amt != null && amt > 0) amounts.add(amt);
    }
    if (amounts.length < 3) return sigs;
    final med = CycleMath.median(amounts);
    final kept = parsed
        .where((e) => e.$2 == null || ((e.$2! - med).abs() / med) <= 0.25)
        .map((e) => e.$1)
        .toList();
    return kept.isEmpty ? sigs : kept;
  }

  Future<bool> _isSuppressed(String family, String kind, String cpKey) async {
    final rules = await (db.select(db.suppressRule)
          ..where((t) => t.family.equals(family) & t.kind.equals(kind)))
        .get();
    return rules.any((r) => r.counterpartKey == null || r.counterpartKey == cpKey);
  }

  Future<void> _ensureLateOpenLoop(SeriesRow s) async {
    final title = '${s.title}: usually done by now';
    final existing = await (db.select(db.openLoop)
          ..where((t) => t.title.equals(title) & t.state.equals('open')))
        .get();
    if (existing.isNotEmpty) return;

    // Attach to latest signal's thread or create a lightweight thread for the late reminder.
    final latestLink = await (db.select(db.seriesSignal)
          ..where((t) => t.seriesId.equals(s.id)))
        .get();
    int? threadId;
    if (latestLink.isNotEmpty) {
      final ts = await (db.select(db.threadSignal)
            ..where((t) => t.signalId.equals(latestLink.last.signalId)))
          .getSingleOrNull();
      threadId = ts?.threadId;
    }
    threadId ??= await db.into(db.memoryThread).insert(
      MemoryThreadCompanion.insert(
        title: s.title,
        kind: const Value('payment'),
        startedAt: s.lastEventAt,
        lastAt: s.lastEventAt,
      ),
    );
    await db.into(db.openLoop).insert(
      OpenLoopCompanion.insert(
        threadId: threadId,
        owner: 'me',
        title: title,
        dueAt: Value(s.nextTo),
      ),
    );
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

class _SeriesKey {
  const _SeriesKey({
    required this.family,
    required this.kind,
    required this.counterpartKey,
    required this.title,
  });

  final String family;
  final String kind;
  final String counterpartKey;
  final String title;

  String get compositeKey => '$family::$kind::$counterpartKey';
}

class _SeriesBucket {
  _SeriesBucket(this.key);

  final _SeriesKey key;
  final List<SignalRow> signals = [];
}
