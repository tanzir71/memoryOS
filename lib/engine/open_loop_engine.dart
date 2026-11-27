import 'dart:convert';
import 'package:drift/drift.dart';
import '../data/database.dart';
import 'extractor.dart';
import 'intent_detector.dart';
import 'topic_utils.dart';

/// Creates and closes open loops per `03-engines.md` section 6.
class OpenLoopEngine {
  OpenLoopEngine(this.db);

  final MemoryDatabase db;

  static const _missedCallDelayMs = 3 * 60 * 60 * 1000;
  static const _quietTimeoutMs = 14 * 24 * 60 * 60 * 1000;

  Future<void> processSignal({
    required SignalRow sig,
    required int? threadId,
    required ExtractionResult extraction,
    required List<(int intentId, DetectedIntent intent, bool isSelf)> intents,
  }) async {
    if (threadId == null) return;

    // 1. Handle intents (asks_you, you_said, confirms).
    for (final (intentId, intent, isSelf) in intents) {
      if (intent.type == 'confirms' && intent.confidence >= 0.7) {
        await _closeLoopsInThread(threadId, closedBy: 'confirm');
        continue;
      }

      if (!intent.canCreateOpenLoop) continue;

      final owner = isSelf
          ? (intent.type == 'asks_you' ? 'them' : 'me')
          : 'me';
      final title = formatOpenLoopTitle(intent.text);

      final existing = await (db.select(db.openLoop)
            ..where(
              (t) =>
                  t.threadId.equals(threadId) &
                  t.owner.equals(owner) &
                  t.state.equals('open'),
            ))
          .get();
      if (existing.isEmpty) {
        await db.into(db.openLoop).insert(
          OpenLoopCompanion.insert(
            threadId: threadId,
            intentId: Value(intentId),
            owner: owner,
            title: title,
            dueAt: Value(intent.dueAt?.millisecondsSinceEpoch),
          ),
        );
      }
    }

    // 2. Order placed/shipped -> open loop owned by 'them'; delivered -> close it.
    if (extraction.kind == 'order_placed' || extraction.kind == 'order_shipped') {
      final merchant = extraction.fields['merchant'] ?? sig.title;
      final existing = await (db.select(db.openLoop)
            ..where(
              (t) => t.threadId.equals(threadId) & t.state.equals('open'),
            ))
          .get();
      if (existing.isEmpty) {
        await db.into(db.openLoop).insert(
          OpenLoopCompanion.insert(
            threadId: threadId,
            owner: 'them',
            title: 'Waiting on $merchant',
          ),
        );
      }
    } else if (extraction.kind == 'order_delivered') {
      await _closeLoopsInThread(threadId, closedBy: 'confirm');
    }

    // 3. Returning a call closes any "Call <Name> back" loop for that person.
    if (sig.signalClass == 'call' && sig.personId != null) {
      final extras = _parseMap(sig.extrasJson);
      final callType = (extras['callType']?.toString() ?? sig.kind).toLowerCase();
      if (callType == 'outgoing' || callType == 'incoming') {
        await _closeMissedCallLoopsForPerson(sig.personId!);
      }
    }
  }

  /// Evaluates time-based open-loop rules:
  /// - Missed calls not returned within 3 hours -> open loop "Call <Name> back"
  /// - Planned meetings that have now occurred -> close matching loops
  /// - Loops older than 14 days -> close quietly with timeout
  Future<void> evaluateTimeRules(DateTime now) async {
    final nowMs = now.millisecondsSinceEpoch;

    // 1. Missed calls older than 3 hours without a subsequent non-missed call to/from same person.
    final allCalls = await (db.select(db.signal)
          ..where((t) => t.signalClass.equals('call') & t.kept.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();

    for (final call in allCalls) {
      final extras = _parseMap(call.extrasJson);
      final callType = (extras['callType']?.toString() ?? call.kind).toLowerCase();
      if (callType != 'missed' && callType != 'missed_call') continue;
      if (nowMs - call.occurredAt < _missedCallDelayMs) continue;

      final returned = allCalls.any((other) {
        if (other.id == call.id || other.occurredAt <= call.occurredAt) {
          return false;
        }
        final otherExtras = _parseMap(other.extrasJson);
        final otherType = (otherExtras['callType']?.toString() ?? other.kind).toLowerCase();
        if (otherType == 'missed' || otherType == 'missed_call') return false;
        return (call.personId != null && other.personId == call.personId) ||
            (call.title.isNotEmpty &&
                other.title.toLowerCase() == call.title.toLowerCase());
      });
      if (returned) continue;

      final threadLink = await (db.select(db.threadSignal)
            ..where((t) => t.signalId.equals(call.id)))
          .getSingleOrNull();
      if (threadLink == null) continue;

      final existing = await (db.select(db.openLoop)
            ..where(
              (t) =>
                  t.threadId.equals(threadLink.threadId) &
                  t.title.like('Call % back'),
            ))
          .get();
      if (existing.isNotEmpty) continue;

      String name = call.title;
      if (call.personId != null) {
        final p = await (db.select(db.person)
              ..where((t) => t.id.equals(call.personId!)))
            .getSingleOrNull();
        if (p != null) {
          name = p.displayName.split(' ').first;
        }
      }
      await db.into(db.openLoop).insert(
        OpenLoopCompanion.insert(
          threadId: threadLink.threadId,
          owner: 'me',
          title: 'Call $name back',
        ),
      );
    }

    // 2. Close loops whose planned meeting has already passed.
    final meetings = await (db.select(db.memoryThread)
          ..where((t) => t.kind.equals('meeting')))
        .get();
    for (final m in meetings) {
      if (m.lastAt < nowMs) {
        await _closeLoopsInThread(m.id, closedBy: 'meeting');
      }
    }

    // 3. Quietly close open loops older than 14 days.
    final openLoops = await (db.select(db.openLoop)
          ..where((t) => t.state.equals('open')))
        .get();
    for (final loop in openLoops) {
      final thread = await (db.select(db.memoryThread)
            ..where((t) => t.id.equals(loop.threadId)))
          .getSingleOrNull();
      final ageAnchor = loop.dueAt ?? thread?.lastAt ?? nowMs;
      if (nowMs - ageAnchor > _quietTimeoutMs) {
        await (db.update(db.openLoop)..where((t) => t.id.equals(loop.id)))
            .write(
              const OpenLoopCompanion(
                state: Value('done'),
                closedBy: Value('timeout'),
              ),
            );
      }
    }
  }

  Future<void> markDone(int loopId) async {
    await (db.update(db.openLoop)..where((t) => t.id.equals(loopId))).write(
      const OpenLoopCompanion(
        state: Value('done'),
        closedBy: Value('user'),
      ),
    );
  }

  Future<void> _closeLoopsInThread(
    int threadId, {
    required String closedBy,
  }) async {
    await (db.update(db.openLoop)
          ..where(
            (t) => t.threadId.equals(threadId) & t.state.equals('open'),
          ))
        .write(
          OpenLoopCompanion(
            state: const Value('done'),
            closedBy: Value(closedBy),
          ),
        );
  }

  Future<void> _closeMissedCallLoopsForPerson(int personId) async {
    final threads = await (db.select(db.memoryThread)
          ..where((t) => t.personId.equals(personId)))
        .get();
    for (final t in threads) {
      await (db.update(db.openLoop)
            ..where(
              (l) =>
                  l.threadId.equals(t.id) &
                  l.state.equals('open') &
                  l.title.like('Call % back'),
            ))
          .write(
            const OpenLoopCompanion(
              state: Value('done'),
              closedBy: Value('confirm'),
            ),
          );
    }
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
