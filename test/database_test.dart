import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/data/database.dart';

void main() {
  late MemoryDatabase db;

  setUp(() {
    db = MemoryDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  test('inserts and queries every table plus FTS5 search index', () async {
    final personId = await db.into(db.person).insert(
      PersonCompanion.insert(
        displayName: 'Nabila Rahman',
        contactLookupKey: const Value('lookup-1'),
      ),
    );
    await db.into(db.personHandle).insert(
      PersonHandleCompanion.insert(
        personId: personId,
        type: 'phone',
        value: '+8801711000001',
        app: const Value('phone'),
      ),
    );

    final signalId = await db.into(db.signal).insert(
      SignalCompanion.insert(
        inboxId: const Value(10),
        source: 'notification',
        pkg: const Value('com.whatsapp'),
        kind: const Value('chat'),
        sbnKey: const Value('0|com.whatsapp|1|null|1000'),
        title: const Value('Nabila Rahman'),
        body: const Value('Can you send the revised quote today?'),
        occurredAt: 1795752840000,
        personId: Value(personId),
        signalClass: const Value('conversation'),
        kept: const Value(true),
      ),
    );

    final entityId = await db.into(db.entity).insert(
      EntityCompanion.insert(
        type: 'topic',
        canonicalValue: 'website quote',
        display: 'Website quote',
      ),
    );
    await db.into(db.signalEntity).insert(
      SignalEntityCompanion.insert(
        signalId: signalId,
        entityId: entityId,
        role: const Value('subject'),
      ),
    );

    final intentId = await db.into(db.signalIntent).insert(
      SignalIntentCompanion.insert(
        signalId: signalId,
        type: 'asks_you',
        content: 'Send the revised quote',
        dueAt: const Value(1795780000000),
        confidence: const Value(0.9),
      ),
    );

    final threadId = await db.into(db.memoryThread).insert(
      MemoryThreadCompanion.insert(
        title: 'Website quote',
        kind: const Value('conversation'),
        personId: Value(personId),
        startedAt: 1795752840000,
        lastAt: 1795752840000,
      ),
    );
    await db.into(db.threadSignal).insert(
      ThreadSignalCompanion.insert(threadId: threadId, signalId: signalId),
    );
    await db.into(db.signalLink).insert(
      SignalLinkCompanion.insert(
        threadId: threadId,
        signalId: signalId,
        reasonsJson: const Value('["same_person","same_subject"]'),
        score: const Value(0.8),
        state: const Value('linked'),
      ),
    );
    await db.into(db.openLoop).insert(
      OpenLoopCompanion.insert(
        threadId: threadId,
        intentId: Value(intentId),
        owner: 'me',
        title: 'Send the revised quote',
        dueAt: const Value(1795780000000),
      ),
    );

    final seriesId = await db.into(db.series).insert(
      SeriesCompanion.insert(
        family: 'sms',
        kind: 'recharge',
        counterpartKey: 'gp',
        title: 'Mobile recharge',
        cycleJson: const Value('{"days":30}'),
        certainty: const Value('learned'),
        decision: const Value('show'),
        lastEventAt: 1793200000000,
        nextFrom: const Value(1795792000000),
        nextTo: const Value(1795964800000),
      ),
    );
    await db.into(db.seriesSignal).insert(
      SeriesSignalCompanion.insert(seriesId: seriesId, signalId: signalId),
    );
    await db.into(db.feedback).insert(
      FeedbackCompanion.insert(
        targetType: 'series',
        targetId: seriesId,
        action: 'show',
        at: 1795752900000,
      ),
    );
    await db.into(db.suppressRule).insert(
      SuppressRuleCompanion.insert(
        family: 'chat',
        kind: 'group_chat',
        counterpartKey: const Value('noisy-group'),
      ),
    );
    await db.into(db.appRule).insert(
      AppRuleCompanion.insert(
        pkg: 'com.whatsapp',
        appClass: const Value('conversation'),
        keepPolicy: const Value('keep'),
        userSet: const Value(true),
      ),
    );
    await db.into(db.channelScore).insert(
      ChannelScoreCompanion.insert(
        pkg: 'com.shop.app',
        channel: 'promos',
        score: const Value(-6),
      ),
    );
    await db.setSetting('onboarding_done', 'true');
    await db.into(db.daySummary).insert(
      DaySummaryCompanion.insert(
        date: '2026-11-27',
        headline: const Value('A client morning, a design sync.'),
        factsJson: const Value('{"conversations":3}'),
        setAsideCount: const Value(60),
      ),
    );

    await db.upsertSearchEntry(
      targetType: 'thread',
      targetId: threadId,
      title: 'Website quote',
      body: 'Can you send the revised quote today?',
      people: 'Nabila Rahman',
      entities: 'Website quote',
    );

    expect(await db.select(db.person).get(), hasLength(1));
    expect(await db.select(db.personHandle).get(), hasLength(1));
    expect(await db.select(db.signal).get(), hasLength(1));
    expect(await db.select(db.entity).get(), hasLength(1));
    expect(await db.select(db.signalEntity).get(), hasLength(1));
    expect(await db.select(db.signalIntent).get(), hasLength(1));
    expect(await db.select(db.memoryThread).get(), hasLength(1));
    expect(await db.select(db.threadSignal).get(), hasLength(1));
    expect(await db.select(db.signalLink).get(), hasLength(1));
    expect(await db.select(db.openLoop).get(), hasLength(1));
    expect(await db.select(db.series).get(), hasLength(1));
    expect(await db.select(db.seriesSignal).get(), hasLength(1));
    expect(await db.select(db.feedback).get(), hasLength(1));
    expect(await db.select(db.suppressRule).get(), hasLength(1));
    expect(await db.select(db.appRule).get(), hasLength(1));
    expect(await db.select(db.channelScore).get(), hasLength(1));
    expect(await db.getSetting('onboarding_done'), 'true');
    expect(await db.select(db.daySummary).get(), hasLength(1));

    final hits = await db.searchFts('Nabila quote');
    expect(hits, hasLength(1));
    expect(hits.single.targetType, 'thread');
    expect(hits.single.targetId, threadId);
  });

  test('enforces unique indexes on entity and person_handle', () async {
    final pId = await db
        .into(db.person)
        .insert(PersonCompanion.insert(displayName: 'Imran'));
    await db.into(db.personHandle).insert(
      PersonHandleCompanion.insert(
        personId: pId,
        type: 'email',
        value: 'imran@example.com',
      ),
    );
    expect(
      () => db.into(db.personHandle).insert(
        PersonHandleCompanion.insert(
          personId: pId,
          type: 'email',
          value: 'imran@example.com',
        ),
      ),
      throwsException,
    );

    await db.into(db.entity).insert(
      EntityCompanion.insert(
        type: 'merchant',
        canonicalValue: 'daraz',
        display: 'Daraz',
      ),
    );
    expect(
      () => db.into(db.entity).insert(
        EntityCompanion.insert(
          type: 'merchant',
          canonicalValue: 'daraz',
          display: 'Daraz BD',
        ),
      ),
      throwsException,
    );
  });
}
