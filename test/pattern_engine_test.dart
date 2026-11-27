import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memoryos/data/database.dart';
import 'package:memoryos/engine/feedback_engine.dart';
import 'package:memoryos/engine/pattern_engine.dart';
import 'package:memoryos/engine/pipeline.dart';
import 'package:memoryos/engine/rules_loader.dart';

Future<DateTime> seedReferenceHistory(SignalPipeline pipeline) async {
  final raw = File('test/fixtures/history.json').readAsStringSync();
  final doc = jsonDecode(raw) as Map<String, dynamic>;
  final refDate = DateTime.parse(doc['referenceDate'] as String);

  for (final c in (doc['contacts'] as List<dynamic>)) {
    final cm = c as Map<String, dynamic>;
    await pipeline.personMatcher.upsertContact(
      displayName: cm['displayName'] as String,
      lookupKey: cm['lookupKey'] as String,
      phones: (cm['phones'] as List<dynamic>).cast<String>(),
      emails: (cm['emails'] as List<dynamic>).cast<String>(),
    );
  }

  for (final e in (doc['events'] as List<dynamic>)) {
    final em = e as Map<String, dynamic>;
    await pipeline.processEvent(
      RawPipelineEvent(
        source: em['source'] as String,
        pkg: em['pkg'] as String? ?? '',
        category: em['category'] as String? ?? '',
        title: em['title'] as String? ?? '',
        body: em['body'] as String? ?? '',
        occurredAt:
            DateTime.parse(em['occurredAt'] as String).millisecondsSinceEpoch,
        endedAt: em['endedAt'] != null
            ? DateTime.parse(em['endedAt'] as String).millisecondsSinceEpoch
            : null,
        extras: Map<String, dynamic>.from(
          (em['extras'] as Map<String, dynamic>?) ?? const {},
        ),
      ),
    );
  }

  // Noisy WhatsApp group: 60 messages/day for 30 days and 0 asks_you.
  final days = (doc['noisyGroupDays'] as num).toInt();
  final perDay = (doc['noisyGroupMessagesPerDay'] as num).toInt();
  for (var d = days; d >= 1; d--) {
    final ts = refDate.subtract(Duration(days: d)).millisecondsSinceEpoch;
    await pipeline.processEvent(
      RawPipelineEvent(
        source: 'notification',
        pkg: 'com.whatsapp',
        category: 'msg',
        importance: 4,
        isConversation: true,
        title: 'College Batch 2016',
        body: 'Good morning everyone!',
        occurredAt: ts,
        extras: {
          'isGroup': true,
          'conversationTitle': 'College Batch 2016',
          'dailyMessageCount': perDay,
        },
      ),
    );
  }

  return refDate;
}

void main() {
  late MemoryDatabase db;
  late EngineRules rules;
  late SignalPipeline pipeline;
  late PatternEngine patterns;
  late FeedbackEngine feedback;

  setUp(() {
    db = MemoryDatabase.inMemory();
    rules = EngineRules.loadFromDirectory('assets/rules');
    pipeline = SignalPipeline(db: db, rules: rules);
    patterns = PatternEngine(db, rules);
    feedback = FeedbackEngine(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('reference history produces all 6 expected predictions', () async {
    final refDate = await seedReferenceHistory(pipeline);
    await patterns.rebuildAll(now: refDate);

    final all = await db.select(db.series).get();

    // 1. Mobile recharge: learned, next 28 Nov ± 1 day.
    final recharge = all.firstWhere((s) => s.family == 'sms' && s.kind == 'recharge');
    expect(recharge.certainty, 'learned');
    final rMid = DateTime.fromMillisecondsSinceEpoch(
      ((recharge.nextFrom! + recharge.nextTo!) ~/ 2),
    );
    expect(DateFormat('yyyy-MM-dd').format(rMid), '2026-11-28');
    final marginDays = (recharge.nextTo! - recharge.nextFrom!) / (2 * 24 * 60 * 60 * 1000);
    expect(marginDays, closeTo(1.0, 0.1));

    // 2. Internet bill: stated, 30 Nov.
    final bill = all.firstWhere((s) => s.family == 'sms' && s.kind == 'internet_bill');
    expect(bill.certainty, 'stated');
    expect(
      DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(bill.nextFrom!)),
      '2026-11-30',
    );
    expect(bill.nextFrom, bill.nextTo);

    // 3. Gas cylinder: guess, about 2 Dec.
    final gas = all.firstWhere((s) => s.family == 'order' && s.kind == 'gas_cylinder');
    expect(gas.certainty, 'guess');
    final gasMid = DateTime.fromMillisecondsSinceEpoch(
      ((gas.nextFrom! + gas.nextTo!) ~/ 2),
    );
    expect(DateFormat('yyyy-MM-dd').format(gasMid), '2026-12-02');

    // 4. bKash Send Money on 5th of 6 months: learned, monthly anchor, next 5 Dec.
    final rent = all.firstWhere((s) => s.family == 'sms' && s.kind == 'rent');
    expect(rent.certainty, 'learned');
    final rentCycle = jsonDecode(rent.cycleJson) as Map<String, dynamic>;
    expect(rentCycle['mode'], 'monthly_anchor');
    expect(rentCycle['anchor_day'], 5);
    final rentMid = DateTime.fromMillisecondsSinceEpoch(
      ((rent.nextFrom! + rent.nextTo!) ~/ 2),
    );
    expect(DateFormat('yyyy-MM-dd').format(rentMid), '2026-12-05');

    // 5. Outgoing calls to Ammu: learned, weekly anchor, Friday about 21:00.
    final ammu = all.firstWhere((s) => s.family == 'call' && s.title.contains('Ammu'));
    expect(ammu.certainty, 'learned');
    final ammuCycle = jsonDecode(ammu.cycleJson) as Map<String, dynamic>;
    expect(ammuCycle['mode'], 'weekly_anchor');
    expect(ammuCycle['weekday'], DateTime.friday);
    expect((ammuCycle['hour'] as num).toInt(), inInclusiveRange(20, 21));

    // 6. Noisy WhatsApp group: proposed with Suggested: drop.
    final group = all.firstWhere((s) => s.family == 'chat' && s.kind == 'group_chat');
    final groupCycle = jsonDecode(group.cycleJson) as Map<String, dynamic>;
    expect(groupCycle['suggested_drop'], isTrue);
    expect(group.decision, 'undecided');

    // Proposal queue returns at most 4 ranked money-due first.
    final proposals = await feedback.getNewProposals();
    expect(proposals, hasLength(4));
    expect(proposals.first.family, 'sms');
  });

  test('two drops of one kind stop future proposals of that kind', () async {
    final s1 = await db.into(db.series).insert(
      SeriesCompanion.insert(
        family: 'chat',
        kind: 'group_chat',
        counterpartKey: 'group-a',
        title: 'Group A',
        lastEventAt: 1000,
      ),
    );
    final s2 = await db.into(db.series).insert(
      SeriesCompanion.insert(
        family: 'chat',
        kind: 'group_chat',
        counterpartKey: 'group-b',
        title: 'Group B',
        lastEventAt: 1000,
      ),
    );
    await db.into(db.series).insert(
      SeriesCompanion.insert(
        family: 'chat',
        kind: 'group_chat',
        counterpartKey: 'group-c',
        title: 'Group C',
        lastEventAt: 1000,
      ),
    );

    await feedback.setDecision(seriesId: s1, decision: 'drop');
    // After 1 drop, Group C is still proposed.
    var proposals = await feedback.getNewProposals();
    expect(proposals.any((p) => p.counterpartKey == 'group-c'), isTrue);

    // After 2 drops of (chat, group_chat), kind-wide suppress rule stops Group C.
    await feedback.setDecision(seriesId: s2, decision: 'drop');
    proposals = await feedback.getNewProposals();
    expect(proposals.any((p) => p.counterpartKey == 'group-c'), isFalse);
  });

  test('late detection, dormant after 2 misses, implicit demotion, user cycle, 90-day check-in, newsletters', () async {
    final refDate = await seedReferenceHistory(pipeline);
    // Add a newsletter email -> created as quiet automatically.
    await pipeline.processEvent(
      RawPipelineEvent(
        source: 'notification',
        pkg: 'com.google.android.gm',
        category: 'email',
        title: 'Weekly Digest',
        body: 'Tech Newsletter #42\nTop stories this week',
        occurredAt: refDate.millisecondsSinceEpoch,
      ),
    );
    await patterns.rebuildAll(now: refDate);

    final newsletter = (await db.select(db.series).get())
        .where((s) => s.family == 'email' && s.kind == 'newsletter')
        .toList();
    // Single newsletter without prior won't predict unless 3+ or stated; verify proposals never include quiet newsletters.
    expect(newsletter.every((n) => n.decision == 'quiet'), isTrue);

    final bill = (await db.select(db.series).get())
        .firstWhere((s) => s.kind == 'internet_bill');
    await feedback.setDecision(seriesId: bill.id, decision: 'show', now: refDate);

    // On 2 Dec (2 days after 30 Nov due date -> past 1-day grace): state becomes late & open loop created.
    await patterns.evaluateStates(DateTime(2026, 12, 2, 12, 0));
    final lateBill = await (db.select(db.series)..where((t) => t.id.equals(bill.id))).getSingle();
    expect(lateBill.state, 'late');
    final lateLoops = await (db.select(db.openLoop)
          ..where((t) => t.title.like('%usually done by now%')))
        .get();
    expect(lateLoops, isNotEmpty);

    // After 2 full missed cycles (Jan 10): state becomes dormant.
    await patterns.evaluateStates(DateTime(2027, 1, 10, 12, 0));
    final dormantBill = await (db.select(db.series)..where((t) => t.id.equals(bill.id))).getSingle();
    expect(dormantBill.state, 'dormant');

    // Implicit strength below -3 moves shown series to quiet with notice.
    await feedback.recordImplicitSignal(seriesId: bill.id, action: 'reminder_dismissed');
    await feedback.recordImplicitSignal(seriesId: bill.id, action: 'reminder_dismissed');
    await feedback.recordImplicitSignal(seriesId: bill.id, action: 'reminder_dismissed');
    final fourth = await feedback.recordImplicitSignal(seriesId: bill.id, action: 'shown_30d_unused');
    expect(fourth.movedToQuiet, isTrue);
    expect(fourth.notice, isNotNull);

    // User-set cycle is never overwritten by rebuildAll.
    await feedback.setUserCycle(seriesId: bill.id, intervalDays: 14);
    await patterns.rebuildAll(now: refDate);
    final fixedBill = await (db.select(db.series)..where((t) => t.id.equals(bill.id))).getSingle();
    final fixedCycle = jsonDecode(fixedBill.cycleJson) as Map<String, dynamic>;
    expect(fixedCycle['user_fixed'], isTrue);
    expect(fixedCycle['interval_days'], 14);

    // 90-day check-in check.
    final recharge = (await db.select(db.series).get())
        .firstWhere((s) => s.kind == 'recharge');
    await feedback.setDecision(seriesId: recharge.id, decision: 'show', now: refDate);
    await feedback.recordCheckIn(refDate);
    expect(await feedback.isCheckInDue(refDate.add(const Duration(days: 30))), isFalse);
    expect(await feedback.isCheckInDue(refDate.add(const Duration(days: 91))), isTrue);
  });
}
