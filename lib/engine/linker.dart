import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../data/database.dart';
import 'extractor.dart';
import 'topic_utils.dart';

class LinkOutcome {
  const LinkOutcome({
    required this.threadId,
    required this.state,
    required this.score,
    required this.reasons,
    this.suggestedThreadId,
  });

  final int? threadId;
  final String state; // linked | suggested | standalone | new_thread
  final double score;
  final List<String> reasons;
  final int? suggestedThreadId;
}

class ThreadLinker {
  ThreadLinker(this.db);

  final MemoryDatabase db;

  static const _activeWindowMs = 14 * 24 * 60 * 60 * 1000;
  static const _closeInTimeMs = 90 * 60 * 1000;
  static const _orderPaymentWindowMs = 10 * 60 * 1000;
  static const _meetingNearbyMs = 30 * 60 * 1000;
  static const _meetingFollowupMs = 3 * 60 * 60 * 1000;

  static const _threadableClasses = {
    'conversation',
    'call',
    'email',
    'calendar',
    'transaction',
    'order',
  };

  Future<LinkOutcome> linkSignal({
    required SignalRow sig,
    required ExtractionResult extraction,
  }) async {
    if (!sig.kept) {
      return const LinkOutcome(
        threadId: null,
        state: 'standalone',
        score: 0,
        reasons: [],
      );
    }

    final extras = _parseMap(sig.extrasJson);
    final isMeetingInstance =
        sig.source == 'calendar' && extras['isInvite'] != true;

    // 1. Calendar meeting instance always owns a meeting thread and pulls in
    // nearby guest messages / overlapping call notifications / voice notes.
    if (isMeetingInstance) {
      final meetingThreadId = await _createThreadForSignal(
        sig: sig,
        extraction: extraction,
        kindOverride: 'meeting',
        titleOverride: sig.title.isNotEmpty ? sig.title : 'Meeting',
      );
      await _backfillMeetingThread(meetingThreadId, sig, extras);
      return LinkOutcome(
        threadId: meetingThreadId,
        state: 'new_thread',
        score: 1.0,
        reasons: const ['calendar_instance'],
      );
    }

    // 2. Check existing active threads within the last 14 days.
    final minLastAt = sig.occurredAt - _activeWindowMs;
    final candidates = await (db.select(db.memoryThread)
          ..where((t) => t.lastAt.isBiggerOrEqualValue(minLastAt))
          ..orderBy([(t) => OrderingTerm.desc(t.lastAt)]))
        .get();

    // Pre-check special meeting attachment first.
    final meetingHit = await _findMatchingMeetingThread(sig, candidates);
    if (meetingHit != null) {
      final (meetingThread, reasons) = meetingHit;
      await _attachToThread(
        thread: meetingThread,
        sig: sig,
        extraction: extraction,
        reasons: reasons,
        score: 1.0,
      );
      return LinkOutcome(
        threadId: meetingThread.id,
        state: 'linked',
        score: 1.0,
        reasons: reasons,
      );
    }

    ThreadRow? bestThread;
    var bestScore = 0.0;
    var bestReasons = <String>[];
    var bestHasRef = false;

    for (final thread in candidates) {
      if (thread.kind == 'meeting') continue;
      if (await _isRejectedPair(thread.id, sig.id)) continue;

      final eval = await _scoreAgainstThread(
        thread: thread,
        sig: sig,
        extraction: extraction,
      );
      if (eval.score > bestScore) {
        bestScore = eval.score;
        bestThread = thread;
        bestReasons = eval.reasons;
        bestHasRef = eval.hasReference;
      }
    }

    // 3. Decide: link (>= 0.8 & (2+ reasons or reference)), suggest (0.3..0.79), or new/standalone.
    final meetsAutoLink =
        bestThread != null &&
        bestScore >= 0.8 &&
        (bestReasons.length >= 2 || bestHasRef);

    if (meetsAutoLink) {
      await _attachToThread(
        thread: bestThread,
        sig: sig,
        extraction: extraction,
        reasons: bestReasons,
        score: bestScore,
      );
      return LinkOutcome(
        threadId: bestThread.id,
        state: 'linked',
        score: bestScore,
        reasons: bestReasons,
      );
    }

    int? suggestedId;
    if (bestThread != null && bestScore >= 0.3) {
      final pendingCount = await _countPendingSuggestions();
      if (pendingCount < 3 && !await _hasLinkPair(bestThread.id, sig.id)) {
        await db.into(db.signalLink).insert(
          SignalLinkCompanion.insert(
            threadId: bestThread.id,
            signalId: sig.id,
            reasonsJson: Value(jsonEncode(bestReasons)),
            score: Value(bestScore),
            state: const Value('suggested'),
            decidedBy: const Value('rule'),
          ),
        );
        suggestedId = bestThread.id;
      }
    }

    if (!_threadableClasses.contains(sig.signalClass)) {
      return LinkOutcome(
        threadId: null,
        state: suggestedId != null ? 'suggested' : 'standalone',
        score: bestScore,
        reasons: bestReasons,
        suggestedThreadId: suggestedId,
      );
    }

    // Create a standalone thread for this signal (still keeping suggestion link if any).
    final newThreadId = await _createThreadForSignal(
      sig: sig,
      extraction: extraction,
    );
    return LinkOutcome(
      threadId: newThreadId,
      state: suggestedId != null ? 'suggested' : 'new_thread',
      score: bestScore,
      reasons: bestReasons,
      suggestedThreadId: suggestedId,
    );
  }

  Future<_ScoreEval> _scoreAgainstThread({
    required ThreadRow thread,
    required SignalRow sig,
    required ExtractionResult extraction,
  }) async {
    final reasons = <String>[];
    var score = 0.0;
    var hasRef = false;

    final threadSignals = await _signalsForThread(thread.id);
    if (threadSignals.isEmpty) {
      return const _ScoreEval(score: 0, reasons: [], hasReference: false);
    }

    // Check order <-> payment cross-link special case (1% amount + merchant token within 10 min).
    if (_isOrderPaymentPair(thread, sig, threadSignals, extraction)) {
      return const _ScoreEval(
        score: 1.0,
        reasons: ['same_reference', 'order_payment_match'],
        hasReference: true,
      );
    }

    // Same reference: order_id, trx_id, tracking_no, Re: subject chain, meeting link.
    if (_sharesHardReference(thread, sig, threadSignals, extraction)) {
      score += 1.0;
      reasons.add('same_reference');
      hasRef = true;
    }

    // Same person (+0.5).
    final samePerson =
        sig.personId != null &&
        (thread.personId == sig.personId ||
            threadSignals.any((ts) => ts.personId == sig.personId));
    if (samePerson) {
      score += 0.5;
      reasons.add('same_person');
    }

    // Same subject (+0.3): shared topic word or entity.
    final sigTokens = extractTopicTokens('${sig.title} ${sig.body}');
    final threadTokens = <String>{
      ...extractTopicTokens(thread.title),
      for (final ts in threadSignals)
        ...extractTopicTokens('${ts.title} ${ts.body}'),
    };
    final sameSubject =
        sigTokens.isNotEmpty && sigTokens.intersection(threadTokens).isNotEmpty;
    if (sameSubject) {
      score += 0.3;
      reasons.add('same_subject');
    }

    // Close in time (+0.3): within 90 minutes of thread's last_at.
    // Only count close_in_time when compatible channel/person/order context exists,
    // so unrelated events 20 minutes apart don't accidentally accrue stray score alone.
    final within90m = (sig.occurredAt - thread.lastAt).abs() <= _closeInTimeMs;
    if (within90m && (samePerson || _sameMerchantContext(threadSignals, sig, extraction))) {
      score += 0.3;
      reasons.add('close_in_time');
    }

    // Same chat conversation (+0.3).
    final sameChat =
        sig.pkg.isNotEmpty &&
        sig.signalClass == 'conversation' &&
        samePerson &&
        threadSignals.any(
          (ts) => ts.pkg == sig.pkg && ts.signalClass == 'conversation',
        );
    if (sameChat) {
      score += 0.3;
      reasons.add('same_conversation');
    }

    return _ScoreEval(score: score, reasons: reasons, hasReference: hasRef);
  }

  bool _isOrderPaymentPair(
    ThreadRow thread,
    SignalRow sig,
    List<SignalRow> threadSignals,
    ExtractionResult extraction,
  ) {
    final isSigPayment =
        sig.signalClass == 'transaction' || extraction.kind == 'payment';
    final isSigOrder =
        sig.signalClass == 'order' ||
        (extraction.kind?.startsWith('order_') ?? false);

    if (!isSigPayment && !isSigOrder) return false;
    if (thread.kind != 'order' && thread.kind != 'payment') return false;

    final sigAmount = extraction.amountValue;
    final sigMerchant = extraction.fields['merchant'] ?? sig.title;
    if (sigAmount == null || sigMerchant.isEmpty) return false;

    for (final ts in threadSignals) {
      if ((sig.occurredAt - ts.occurredAt).abs() > _orderPaymentWindowMs) {
        continue;
      }
      final tsExtras = _parseMap(ts.extrasJson);
      final tsAmount = double.tryParse(
        (tsExtras['amount']?.toString() ?? '').replaceAll(',', ''),
      );
      final tsMerchant =
          tsExtras['merchant']?.toString() ?? '${ts.title} ${ts.body}';
      if (tsAmount != null &&
          amountsMatchWithinOnePercent(sigAmount, tsAmount) &&
          shareMerchantToken(sigMerchant, tsMerchant)) {
        return true;
      }
    }
    return false;
  }

  bool _sameMerchantContext(
    List<SignalRow> threadSignals,
    SignalRow sig,
    ExtractionResult extraction,
  ) {
    final sigMerchant = extraction.fields['merchant'] ?? '';
    if (sigMerchant.isEmpty) return false;
    for (final ts in threadSignals) {
      final tsExtras = _parseMap(ts.extrasJson);
      final tsMerchant = tsExtras['merchant']?.toString() ?? ts.title;
      if (shareMerchantToken(sigMerchant, tsMerchant)) return true;
    }
    return false;
  }

  bool _sharesHardReference(
    ThreadRow thread,
    SignalRow sig,
    List<SignalRow> threadSignals,
    ExtractionResult extraction,
  ) {
    final sigRefs = <String>{
      if (extraction.fields['order_id'] != null)
        'order:${extraction.fields['order_id']!.toUpperCase()}',
      if (extraction.fields['trx_id'] != null)
        'trx:${extraction.fields['trx_id']!.toUpperCase()}',
      if (extraction.fields['tracking_no'] != null)
        'trk:${extraction.fields['tracking_no']!.toUpperCase()}',
    };

    for (final ts in threadSignals) {
      final tsExtras = _parseMap(ts.extrasJson);
      for (final key in ['order_id', 'trx_id', 'tracking_no']) {
        final v = tsExtras[key]?.toString().toUpperCase();
        if (v != null && v.isNotEmpty) {
          final prefix = key == 'order_id'
              ? 'order:'
              : key == 'trx_id'
                  ? 'trx:'
                  : 'trk:';
          if (sigRefs.contains('$prefix$v')) return true;
        }
      }
      // Same order merchant within 2 hours (e.g. Foodpanda placed -> delivered).
      if (sig.signalClass == 'order' &&
          ts.signalClass == 'order' &&
          (sig.occurredAt - ts.occurredAt).abs() <= 2 * 60 * 60 * 1000) {
        final m1 = extraction.fields['merchant'] ?? sig.title;
        final m2 = tsExtras['merchant']?.toString() ?? ts.title;
        if (shareMerchantToken(m1, m2)) return true;
      }
    }

    // "Re:" subject chain with matching email subject or thread topic.
    if (sig.signalClass == 'email' &&
        (isReplySubject(sig.body) || isReplySubject(sig.title))) {
      final cleaned = stripReplyPrefix(
        sig.body.isNotEmpty ? sig.body.split('\n').first : sig.title,
      ).toLowerCase();
      final threadTitleTokens = extractTopicTokens(thread.title);
      final cleanedTokens = extractTopicTokens(cleaned);
      if (threadTitleTokens.isNotEmpty &&
          cleanedTokens.intersection(threadTitleTokens).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<(ThreadRow, List<String>)?> _findMatchingMeetingThread(
    SignalRow sig,
    List<ThreadRow> candidates,
  ) async {
    final meetingThreads = candidates.where((t) => t.kind == 'meeting');
    for (final mt in meetingThreads) {
      final mtSignals = await _signalsForThread(mt.id);
      final calSig = mtSignals.where((s) => s.source == 'calendar').firstOrNull;
      if (calSig == null) continue;

      final start = calSig.occurredAt;
      final end = calSig.endedAt ?? (start + 30 * 60 * 1000);
      final calExtras = _parseMap(calSig.extrasJson);
      final guestIds = (calExtras['guestPersonIds'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toSet();
      final guestNames = (calExtras['guestNames'] as List<dynamic>? ?? const [])
          .map((e) => e.toString().toLowerCase())
          .toSet();

      final isGuest = (sig.personId != null && guestIds.contains(sig.personId)) ||
          guestNames.any((g) => g.isNotEmpty && sig.title.toLowerCase().contains(g));

      // Overlapping call notification (Meet/Zoom/Teams).
      if (sig.signalClass == 'call' &&
          sig.source == 'notification' &&
          _isMeetingCallApp(sig.pkg)) {
        final sigEnd = sig.endedAt ?? sig.occurredAt;
        if (sig.occurredAt <= end + 15 * 60 * 1000 &&
            sigEnd >= start - 15 * 60 * 1000) {
          return (mt, ['same_reference', 'meeting_call_overlap']);
        }
      }

      // Voice note recorded during the meeting.
      if (sig.source == 'voice' &&
          sig.occurredAt >= start - 5 * 60 * 1000 &&
          sig.occurredAt <= end + 5 * 60 * 1000) {
        return (mt, ['meeting_voice_note', 'close_in_time']);
      }

      // Chat message from a guest within 30 minutes either side.
      if (sig.signalClass == 'conversation' &&
          isGuest &&
          sig.occurredAt >= start - _meetingNearbyMs &&
          sig.occurredAt <= end + _meetingNearbyMs) {
        return (mt, ['meeting_guest', 'close_in_time']);
      }

      // Email from a guest within 3 hours sharing a subject word with meeting title.
      if (sig.signalClass == 'email' &&
          isGuest &&
          sig.occurredAt >= start &&
          sig.occurredAt <= end + _meetingFollowupMs) {
        final mtTokens = extractTopicTokens(mt.title);
        final sigTokens = extractTopicTokens('${sig.title} ${sig.body}');
        if (mtTokens.intersection(sigTokens).isNotEmpty) {
          return (mt, ['meeting_guest', 'same_subject']);
        }
      }
    }
    return null;
  }

  Future<void> _backfillMeetingThread(
    int meetingThreadId,
    SignalRow calSig,
    Map<String, dynamic> calExtras,
  ) async {
    final start = calSig.occurredAt;
    final end = calSig.endedAt ?? (start + 30 * 60 * 1000);
    final guestIds = (calExtras['guestPersonIds'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();
    final guestNames = (calExtras['guestNames'] as List<dynamic>? ?? const [])
        .map((e) => e.toString().toLowerCase())
        .toSet();

    final nearby = await (db.select(db.signal)
          ..where(
            (t) =>
                t.kept.equals(true) &
                t.occurredAt.isBiggerOrEqualValue(start - _meetingNearbyMs) &
                t.occurredAt.isSmallerOrEqualValue(end + _meetingNearbyMs),
          ))
        .get();

    for (final s in nearby) {
      if (s.id == calSig.id) continue;
      final isGuest = (s.personId != null && guestIds.contains(s.personId)) ||
          guestNames.any((g) => g.isNotEmpty && s.title.toLowerCase().contains(g));
      final isNearbyGuestChat = s.signalClass == 'conversation' && isGuest;
      final isVoiceDuring = s.source == 'voice' && s.occurredAt >= start && s.occurredAt <= end;
      if (!isNearbyGuestChat && !isVoiceDuring) continue;

      // Move signal from its temporary solo thread into the meeting thread.
      final existingThreads = await (db.select(db.threadSignal)
            ..where((t) => t.signalId.equals(s.id)))
          .get();
      for (final ts in existingThreads) {
        if (ts.threadId == meetingThreadId) continue;
        final siblings = await (db.select(db.threadSignal)
              ..where((t) => t.threadId.equals(ts.threadId)))
            .get();
        await (db.delete(db.threadSignal)
              ..where(
                (t) => t.threadId.equals(ts.threadId) & t.signalId.equals(s.id),
              ))
            .go();
        if (siblings.length <= 1) {
          await (db.delete(db.memoryThread)
                ..where((t) => t.id.equals(ts.threadId)))
              .go();
        }
      }
      await db.into(db.threadSignal).insertOnConflictUpdate(
        ThreadSignalCompanion.insert(threadId: meetingThreadId, signalId: s.id),
      );
      await db.into(db.signalLink).insert(
        SignalLinkCompanion.insert(
          threadId: meetingThreadId,
          signalId: s.id,
          reasonsJson: Value(jsonEncode(isVoiceDuring ? ['meeting_voice_note'] : ['meeting_guest', 'close_in_time'])),
          score: const Value(1.0),
          state: const Value('linked'),
          decidedBy: const Value('rule'),
        ),
      );
    }
  }

  Future<int> _createThreadForSignal({
    required SignalRow sig,
    required ExtractionResult extraction,
    String? kindOverride,
    String? titleOverride,
  }) async {
    final kind = kindOverride ?? _threadKindForSignal(sig);
    final title = titleOverride ?? await _computeInitialTitle(sig, extraction, kind);
    final threadId = await db.into(db.memoryThread).insert(
      MemoryThreadCompanion.insert(
        title: title,
        kind: Value(kind),
        personId: Value(sig.personId),
        startedAt: sig.occurredAt,
        lastAt: sig.endedAt ?? sig.occurredAt,
      ),
    );
    await db.into(db.threadSignal).insert(
      ThreadSignalCompanion.insert(threadId: threadId, signalId: sig.id),
    );
    await _indexThreadFts(threadId);
    return threadId;
  }

  Future<void> _attachToThread({
    required ThreadRow thread,
    required SignalRow sig,
    required ExtractionResult extraction,
    required List<String> reasons,
    required double score,
  }) async {
    await db.into(db.threadSignal).insertOnConflictUpdate(
      ThreadSignalCompanion.insert(threadId: thread.id, signalId: sig.id),
    );
    await db.into(db.signalLink).insert(
      SignalLinkCompanion.insert(
        threadId: thread.id,
        signalId: sig.id,
        reasonsJson: Value(jsonEncode(reasons)),
        score: Value(score),
        state: const Value('linked'),
        decidedBy: const Value('rule'),
      ),
    );

    final nextStart = sig.occurredAt < thread.startedAt ? sig.occurredAt : thread.startedAt;
    final sigEnd = sig.endedAt ?? sig.occurredAt;
    final nextLast = sigEnd > thread.lastAt ? sigEnd : thread.lastAt;

    String? refinedTitle;
    if (!thread.userEdited && thread.kind == 'conversation') {
      if (sig.signalClass == 'email') {
        final subjectLine = sig.body.isNotEmpty ? sig.body.split('\n').first : sig.title;
        refinedTitle = extractTopicPhrase(subjectLine);
      }
    }

    await (db.update(db.memoryThread)..where((t) => t.id.equals(thread.id)))
        .write(
          MemoryThreadCompanion(
            startedAt: Value(nextStart),
            lastAt: Value(nextLast),
            title: refinedTitle != null ? Value(refinedTitle) : const Value.absent(),
          ),
        );
    await _indexThreadFts(thread.id);
  }

  Future<String> _computeInitialTitle(
    SignalRow sig,
    ExtractionResult extraction,
    String kind,
  ) async {
    if (kind == 'order' || kind == 'payment') {
      if (extraction.fields['item'] != null) return extraction.fields['item']!;
      if (extraction.fields['merchant'] != null) {
        return extraction.fields['merchant']!;
      }
      return sig.title.isNotEmpty ? sig.title : 'Order';
    }
    if (kind == 'meeting') {
      return sig.title.isNotEmpty ? sig.title : 'Meeting';
    }
    if (sig.signalClass == 'email') {
      final subject = sig.body.isNotEmpty ? sig.body.split('\n').first : sig.title;
      final phrase = extractTopicPhrase(subject);
      if (phrase != null) return phrase;
    }
    if (sig.personId != null) {
      final p = await (db.select(db.person)
            ..where((t) => t.id.equals(sig.personId!)))
          .getSingleOrNull();
      if (p != null) {
        final dateStr = DateFormat('d MMM').format(
          DateTime.fromMillisecondsSinceEpoch(sig.occurredAt),
        );
        return '${p.displayName}, $dateStr';
      }
    }
    return sig.title.isNotEmpty ? sig.title : 'Thread';
  }

  String _threadKindForSignal(SignalRow sig) => switch (sig.signalClass) {
    'order' => 'order',
    'transaction' => 'payment',
    'calendar' => 'meeting',
    'conversation' || 'call' || 'email' => 'conversation',
    _ => 'other',
  };

  bool _isMeetingCallApp(String pkg) {
    final lower = pkg.toLowerCase();
    return lower.contains('tachyon') ||
        lower.contains('meetings') ||
        lower.contains('zoom') ||
        lower.contains('teams');
  }

  Future<List<SignalRow>> _signalsForThread(int threadId) async {
    final links = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(threadId)))
        .get();
    if (links.isEmpty) return const [];
    final ids = links.map((l) => l.signalId).toList();
    return (db.select(db.signal)..where((t) => t.id.isIn(ids))).get();
  }

  Future<bool> _isRejectedPair(int threadId, int signalId) async {
    final row = await (db.select(db.signalLink)
          ..where(
            (t) =>
                t.threadId.equals(threadId) &
                t.signalId.equals(signalId) &
                t.state.equals('rejected'),
          ))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasLinkPair(int threadId, int signalId) async {
    final row = await (db.select(db.signalLink)
          ..where(
            (t) => t.threadId.equals(threadId) & t.signalId.equals(signalId),
          ))
        .getSingleOrNull();
    return row != null;
  }

  Future<int> _countPendingSuggestions() async {
    final rows = await (db.select(db.signalLink)
          ..where((t) => t.state.equals('suggested')))
        .get();
    return rows.length;
  }

  Future<void> _indexThreadFts(int threadId) async {
    final thread = await (db.select(db.memoryThread)
          ..where((t) => t.id.equals(threadId)))
        .getSingleOrNull();
    if (thread == null) return;
    final sigs = await _signalsForThread(threadId);
    final body = sigs.map((s) => '${s.title} ${s.body}').join(' ');
    String people = '';
    if (thread.personId != null) {
      final p = await (db.select(db.person)
            ..where((t) => t.id.equals(thread.personId!)))
          .getSingleOrNull();
      if (p != null) people = p.displayName;
    }
    await db.upsertSearchEntry(
      targetType: 'thread',
      targetId: threadId,
      title: thread.title,
      body: body,
      people: people,
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

class _ScoreEval {
  const _ScoreEval({
    required this.score,
    required this.reasons,
    required this.hasReference,
  });

  final double score;
  final List<String> reasons;
  final bool hasReference;
}
