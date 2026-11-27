import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../data/database.dart';
import 'rules_loader.dart';

class DayFacts {
  const DayFacts({
    required this.conversations,
    required this.meetings,
    required this.moneySpent,
    required this.setAsideCount,
  });

  final int conversations;
  final int meetings;
  final double moneySpent;
  final int setAsideCount;

  Map<String, dynamic> toJson() => {
    'conversations': conversations,
    'meetings': meetings,
    'money_spent': moneySpent,
  };

  String formatFactsLine() {
    final parts = <String>[];
    if (conversations > 0) {
      parts.add('$conversations ${conversations == 1 ? 'conversation' : 'conversations'}');
    }
    if (meetings > 0) {
      parts.add('$meetings ${meetings == 1 ? 'meeting' : 'meetings'}');
    }
    if (moneySpent > 0) {
      final fmt = NumberFormat('#,##0', 'en_US').format(moneySpent.round());
      parts.add('Tk $fmt spent');
    }
    return parts.join(' · ');
  }
}

class DaySummaryResult {
  const DaySummaryResult({
    required this.dateKey,
    required this.headline,
    required this.facts,
  });

  final String dateKey;
  final String headline;
  final DayFacts facts;
}

class DaySummaryEngine {
  DaySummaryEngine(this.db, this.rules);

  final MemoryDatabase db;
  final EngineRules rules;

  Future<DaySummaryResult> buildForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    final daySignals = await (db.select(db.signal)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.occurredAt.isBiggerOrEqualValue(start) &
                t.occurredAt.isSmallerOrEqualValue(end),
          ))
        .get();

    final setAsideCount = daySignals.where((s) => !s.kept).length;
    final keptIds = daySignals.where((s) => s.kept).map((s) => s.id).toSet();

    final tsRows = keptIds.isEmpty
        ? <ThreadSignalRow>[]
        : await (db.select(db.threadSignal)
              ..where((t) => t.signalId.isIn(keptIds)))
            .get();
    final threadIds = tsRows.map((r) => r.threadId).toSet();

    final threads = threadIds.isEmpty
        ? <ThreadRow>[]
        : await (db.select(db.memoryThread)
              ..where((t) => t.id.isIn(threadIds)))
            .get();

    final openLoops = threadIds.isEmpty
        ? <OpenLoopRow>[]
        : await (db.select(db.openLoop)
              ..where(
                (t) => t.threadId.isIn(threadIds) & t.state.equals('open'),
              ))
            .get();

    final conversations = threads.where((t) => t.kind == 'conversation').length;
    final meetings = threads.where((t) => t.kind == 'meeting').length;

    // Sum money spent across kept orders/payments/trips without double-counting
    // an order and its linked payment inside the same thread.
    var moneySpent = 0.0;
    final countedThreads = <int>{};
    for (final s in daySignals.where((s) => s.kept)) {
      if (s.signalClass != 'order' &&
          s.signalClass != 'transaction' &&
          s.signalClass != 'travel') {
        continue;
      }
      final extras = _parseMap(s.extrasJson);
      final kind = extras['extractKind']?.toString() ?? '';
      if (kind == 'money_received') continue;
      final amt = double.tryParse(
        (extras['amount']?.toString() ?? '').replaceAll(',', ''),
      );
      if (amt == null || amt <= 0) continue;

      final link = tsRows.where((r) => r.signalId == s.id).firstOrNull;
      if (link != null && !countedThreads.add(link.threadId)) {
        continue;
      }
      moneySpent += amt;
    }

    // Rank items for headline: open-ask thread > meeting > order > trip.
    final ranked = <String>[];
    final openThreadIds = openLoops.map((l) => l.threadId).toSet();
    final askThreads = threads.where((t) => openThreadIds.contains(t.id) && t.kind == 'conversation').toList();
    if (askThreads.isNotEmpty) {
      final first = askThreads.first;
      final hour = DateTime.fromMillisecondsSinceEpoch(first.startedAt).hour;
      ranked.add(hour < 12 ? 'A client morning' : first.title);
    }

    for (final m in threads.where((t) => t.kind == 'meeting')) {
      ranked.add('a ${m.title.toLowerCase()}');
    }

    for (final o in threads.where((t) => t.kind == 'order')) {
      ranked.add('${o.title} ordered');
    }

    for (final trip in daySignals.where((s) => s.kept && s.signalClass == 'travel')) {
      ranked.add('a ${trip.title} ride');
    }

    final top3 = ranked.take(3).toList();
    final headline = _composeHeadline(top3, date);

    final facts = DayFacts(
      conversations: conversations,
      meetings: meetings,
      moneySpent: moneySpent,
      setAsideCount: setAsideCount,
    );

    await db.into(db.daySummary).insertOnConflictUpdate(
      DaySummaryCompanion.insert(
        date: dateKey,
        headline: Value(headline),
        factsJson: Value(jsonEncode(facts.toJson())),
        setAsideCount: Value(setAsideCount),
      ),
    );

    return DaySummaryResult(dateKey: dateKey, headline: headline, facts: facts);
  }

  String _composeHeadline(List<String> items, DateTime date) {
    if (items.length < 2) {
      return DateFormat('EEEE, d MMMM').format(date);
    }
    final first = _cap(items[0]);
    if (items.length == 2) {
      return '$first, ${items[1]}.';
    }
    return '$first, ${items[1]}, ${items[2]}.';
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Map<String, dynamic> _parseMap(String raw) {
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : const {};
    } catch (_) {
      return const {};
    }
  }
}
