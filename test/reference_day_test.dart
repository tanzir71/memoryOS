import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memoryos/data/database.dart';
import 'package:memoryos/engine/pipeline.dart';
import 'package:memoryos/engine/rules_loader.dart';
import 'package:memoryos/engine/thread_actions.dart';

Future<void> seedReferenceDay(SignalPipeline pipeline) async {
  final raw = File('test/fixtures/day_2026_11_27.json').readAsStringSync();
  final doc = jsonDecode(raw) as Map<String, dynamic>;

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
    final extras = Map<String, dynamic>.from(
      (em['extras'] as Map<String, dynamic>?) ?? const {},
    );
    if (extras['eventStartAt'] is String) {
      extras['eventStartAt'] =
          DateTime.parse(extras['eventStartAt'] as String).millisecondsSinceEpoch;
    }
    if (extras['eventEndAt'] is String) {
      extras['eventEndAt'] =
          DateTime.parse(extras['eventEndAt'] as String).millisecondsSinceEpoch;
    }
    await pipeline.processEvent(
      RawPipelineEvent(
        source: em['source'] as String,
        pkg: em['pkg'] as String? ?? '',
        channel: em['channel'] as String? ?? '',
        category: em['category'] as String? ?? '',
        flags: (em['flags'] as num?)?.toInt() ?? 0,
        importance: (em['importance'] as num?)?.toInt() ?? 3,
        title: em['title'] as String? ?? '',
        body: em['body'] as String? ?? '',
        occurredAt:
            DateTime.parse(em['occurredAt'] as String).millisecondsSinceEpoch,
        endedAt: em['endedAt'] != null
            ? DateTime.parse(em['endedAt'] as String).millisecondsSinceEpoch
            : null,
        isConversation: em['isConversation'] == true,
        extras: extras,
      ),
    );
  }

  // Spread 60 promo, status and progress noise notifications through the day.
  final noiseCount = (doc['noiseCount'] as num).toInt();
  final startOfDay = DateTime(2026, 11, 27, 8, 0);
  for (var i = 0; i < noiseCount; i++) {
    final ts = startOfDay.add(Duration(minutes: i * 10)).millisecondsSinceEpoch;
    if (i % 3 == 0) {
      await pipeline.processEvent(
        RawPipelineEvent(
          source: 'notification',
          pkg: 'com.daraz.android',
          channel: 'promotions',
          category: 'promo',
          title: 'Flash sale #$i',
          body: '50% off! Shop now with code SAVE50.',
          occurredAt: ts,
        ),
      );
    } else if (i % 3 == 1) {
      await pipeline.processEvent(
        RawPipelineEvent(
          source: 'notification',
          pkg: 'com.android.systemui',
          category: 'status',
          flags: 2,
          importance: 2,
          title: 'Charging',
          body: '${20 + (i % 75)}% charged',
          occurredAt: ts,
        ),
      );
    } else {
      await pipeline.processEvent(
        RawPipelineEvent(
          source: 'notification',
          pkg: 'com.android.vending',
          category: 'progress',
          flags: 2,
          importance: 2,
          isProgressTick: true,
          title: 'Updating apps',
          body: '${10 + (i % 80)}% downloaded',
          occurredAt: ts,
        ),
      );
    }
  }
}

void main() {
  late MemoryDatabase db;
  late EngineRules rules;
  late SignalPipeline pipeline;

  setUp(() {
    db = MemoryDatabase.inMemory();
    rules = EngineRules.loadFromDirectory('assets/rules');
    pipeline = SignalPipeline(db: db, rules: rules);
  });

  tearDown(() async {
    await db.close();
  });

  test('reference day 2026-11-27 produces exact expected threads, links, loops, and summary', () async {
    await seedReferenceDay(pipeline);

    // Evaluate time-based rules at 20:00 (> 3 hours after 16:42 missed call from Imran).
    await pipeline.openLoops.evaluateTimeRules(DateTime(2026, 11, 27, 20, 0));

    final threads = await db.select(db.memoryThread).get();

    // 1. Thread "Website quote" with 5 signals & reasons same_person, same_subject, close_in_time.
    final quoteThread = threads.firstWhere((t) => t.title == 'Website quote');
    final quoteSigs = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(quoteThread.id)))
        .get();
    expect(quoteSigs, hasLength(5));

    final quoteLinks = await (db.select(db.signalLink)
          ..where(
            (t) => t.threadId.equals(quoteThread.id) & t.state.equals('linked'),
          ))
        .get();
    final allReasons = quoteLinks
        .expand((l) => (jsonDecode(l.reasonsJson) as List).cast<String>())
        .toSet();
    expect(allReasons, containsAll(['same_person', 'same_subject', 'close_in_time']));

    // Open loop "Send the revised quote", owner me, due today (2026-11-27).
    final quoteLoops = await (db.select(db.openLoop)
          ..where((t) => t.threadId.equals(quoteThread.id) & t.state.equals('open')))
        .get();
    expect(quoteLoops, hasLength(1));
    expect(quoteLoops.single.owner, 'me');
    expect(quoteLoops.single.title, 'Send the revised quote');
    expect(
      DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(quoteLoops.single.dueAt!),
      ),
      '2026-11-27',
    );

    // Plan intent for Thu 3 December exists in the thread.
    final quoteSigIds = quoteSigs.map((e) => e.signalId).toList();
    final quoteIntents = await (db.select(db.signalIntent)
          ..where((t) => t.signalId.isIn(quoteSigIds) & t.type.equals('plan')))
        .get();
    expect(quoteIntents, isNotEmpty);
    expect(
      DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(quoteIntents.first.dueAt!),
      ),
      '2026-12-03',
    );

    // 2. Thread "Design sync" with calendar + Meet call + Sadia's message + Imran's email (4 signals).
    final designThread = threads.firstWhere((t) => t.title == 'Design sync');
    expect(designThread.kind, 'meeting');
    final designSigs = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(designThread.id)))
        .get();
    expect(designSigs, hasLength(4));

    // 3. Sadia's "Quote template v3" is suggested for "Website quote", NOT linked.
    final sadiaEmail = await (db.select(db.signal)
          ..where((t) => t.body.like('%Quote template v3%')))
        .getSingle();
    final sadiaSuggested = await (db.select(db.signalLink)
          ..where(
            (t) =>
                t.threadId.equals(quoteThread.id) &
                t.signalId.equals(sadiaEmail.id),
          ))
        .getSingle();
    expect(sadiaSuggested.state, 'suggested');
    expect(quoteSigIds, isNot(contains(sadiaEmail.id)));

    // 4. Order thread for USB-C charger with bKash payment linked.
    final chargerThread = threads.firstWhere((t) => t.title == 'USB-C charger');
    final chargerSigs = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(chargerThread.id)))
        .get();
    expect(chargerSigs, hasLength(2));

    // 5. Open loop "Call Imran back" after 3 hours.
    final allOpenLoops = await (db.select(db.openLoop)
          ..where((t) => t.state.equals('open')))
        .get();
    expect(
      allOpenLoops.any((l) => l.title == 'Call Imran back' && l.owner == 'me'),
      isTrue,
    );

    // 6. Foodpanda order loop closed because delivery arrived.
    final fpThread = threads.firstWhere((t) => t.title == 'Kacchi Bhai');
    final fpOpen = await (db.select(db.openLoop)
          ..where((t) => t.threadId.equals(fpThread.id) & t.state.equals('open')))
        .get();
    expect(fpOpen, isEmpty);

    // 7. All 60 noise notifications are set aside.
    final summary = await pipeline.daySummary.buildForDate(DateTime(2026, 11, 27));
    expect(summary.facts.setAsideCount, 60);
    expect(summary.facts.meetings, 1);
    expect(summary.facts.moneySpent, 1730); // 480 + 1250 without double-counting bKash
    expect(summary.headline, isNotEmpty);
  });

  test('user actions: reject link, split signal, rename sticky, loop closing rules', () async {
    await seedReferenceDay(pipeline);
    final actions = ThreadActions(db);

    // Reject suggested link -> marked rejected & user decided, feedback logged.
    final suggested = await (db.select(db.signalLink)
          ..where((t) => t.state.equals('suggested')))
        .getSingle();
    await actions.rejectSuggestedLink(suggested.id);
    final afterReject = await (db.select(db.signalLink)
          ..where((t) => t.id.equals(suggested.id)))
        .getSingle();
    expect(afterReject.state, 'rejected');
    expect(afterReject.decidedBy, 'user');

    // Rename thread -> userEdited = true, never overwritten by new email.
    final quoteThread = (await db.select(db.memoryThread).get())
        .firstWhere((t) => t.title == 'Website quote');
    await actions.renameThread(quoteThread.id, 'Client redesign quote');
    final renamed = await (db.select(db.memoryThread)
          ..where((t) => t.id.equals(quoteThread.id)))
        .getSingle();
    expect(renamed.title, 'Client redesign quote');
    expect(renamed.userEdited, isTrue);

    // Confirm message from Nabila closes the open loop in that thread.
    await pipeline.processEvent(
      RawPipelineEvent(
        source: 'notification',
        pkg: 'com.whatsapp',
        category: 'msg',
        importance: 4,
        isConversation: true,
        title: 'Nabila Rahman',
        body: 'Got it, thanks for the website quote!',
        occurredAt: DateTime(2026, 11, 27, 12, 0).millisecondsSinceEpoch,
      ),
    );
    final loopsAfterConfirm = await (db.select(db.openLoop)
          ..where((t) => t.threadId.equals(quoteThread.id) & t.state.equals('open')))
        .get();
    expect(loopsAfterConfirm, isEmpty);

    // Title stayed renamed despite new linked signal.
    final stillRenamed = await (db.select(db.memoryThread)
          ..where((t) => t.id.equals(quoteThread.id)))
        .getSingle();
    expect(stillRenamed.title, 'Client redesign quote');

    // Split signal out detaches and creates its own thread.
    final sigsBefore = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(quoteThread.id)))
        .get();
    final splitThreadId = await actions.splitSignalOut(
      threadId: quoteThread.id,
      signalId: sigsBefore.last.signalId,
    );
    expect(splitThreadId, isNot(quoteThread.id));
    final sigsAfter = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(quoteThread.id)))
        .get();
    expect(sigsAfter.length, sigsBefore.length - 1);
  });

  test('day summary with fewer than 2 items shows date only', () async {
    final summary = await pipeline.daySummary.buildForDate(DateTime(2026, 11, 20));
    expect(summary.headline, 'Friday, 20 November');
  });
}
