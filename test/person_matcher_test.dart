import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/data/database.dart';
import 'package:memoryos/engine/person_matcher.dart';
import 'package:memoryos/engine/rules_loader.dart';
import 'package:memoryos/engine/unparsed_exporter.dart';

void main() {
  late MemoryDatabase db;
  late PersonMatcher matcher;

  setUp(() {
    db = MemoryDatabase.inMemory();
    matcher = PersonMatcher(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('matches contact by phone, chat name, email sender name, and email', () async {
    final nabilaId = await matcher.upsertContact(
      displayName: 'Nabila Rahman',
      lookupKey: 'k-nabila',
      phones: ['01711-000001'],
      emails: ['nabila@client.co'],
    );

    expect(
      await matcher.matchOrCreate(const PersonCandidate(phone: '+8801711000001')),
      nabilaId,
    );
    expect(
      await matcher.matchOrCreate(
        const PersonCandidate(chatName: 'Nabila Rahman', app: 'com.whatsapp'),
      ),
      nabilaId,
    );
    expect(
      await matcher.matchOrCreate(
        const PersonCandidate(emailSenderName: 'Nabila Rahman', app: 'com.google.android.gm'),
      ),
      nabilaId,
    );
    expect(
      await matcher.matchOrCreate(const PersonCandidate(email: 'NABILA@client.co')),
      nabilaId,
    );
  });

  test('merges provisional person into contact later, never merges two contacts', () async {
    final provisionalId = await matcher.matchOrCreate(
      const PersonCandidate(chatName: 'Imran Hossain', app: 'com.whatsapp'),
    );
    expect(provisionalId, isNotNull);

    await db.into(db.signal).insert(
      SignalCompanion.insert(
        source: 'notification',
        title: const Value('Imran Hossain'),
        occurredAt: 1000,
        personId: Value(provisionalId),
      ),
    );

    final contactId = await matcher.upsertContact(
      displayName: 'Imran Hossain',
      lookupKey: 'k-imran',
      phones: ['01711000002'],
    );

    // Signal was reassigned to contact and provisional row deleted.
    final people = await db.select(db.person).get();
    expect(people, hasLength(1));
    expect(people.single.id, contactId);
    final sig = await db.select(db.signal).getSingle();
    expect(sig.personId, contactId);

    // Adding a second distinct contact sharing a phone does NOT merge the two contacts.
    final secondContact = await matcher.upsertContact(
      displayName: 'Imran Work',
      lookupKey: 'k-imran-work',
      phones: ['01711000002'],
    );
    expect(secondContact, isNot(contactId));
    expect(await db.select(db.person).get(), hasLength(2));
  });

  test('exports unparsed transactional samples to JSON file', () async {
    final rules = EngineRules.loadFromDirectory('assets/rules');
    await db.into(db.signal).insert(
      SignalCompanion.insert(
        source: 'sms',
        title: const Value('LocalISP'),
        body: const Value('Monthly charge Tk 900 processed for Nov.'),
        occurredAt: 1795750000000,
        signalClass: const Value('transaction'),
      ),
    );
    await db.into(db.signal).insert(
      SignalCompanion.insert(
        source: 'sms',
        title: const Value('bKash'),
        body: const Value('Payment of Tk 1,250 to Daraz is successful. TrxID XY99887766'),
        occurredAt: 1795750100000,
        signalClass: const Value('transaction'),
      ),
    );

    final tempDir = await Directory.systemTemp.createTemp('memoryos_unparsed_');
    try {
      final result = await exportUnparsedTransactionalSamples(
        db: db,
        rules: rules,
        outputDir: tempDir,
      );
      expect(result.sampleCount, 1);
      final parsed = jsonDecode(await File(result.filePath).readAsString()) as Map<String, dynamic>;
      expect(parsed['count'], 1);
      expect((parsed['samples'] as List).first['title'], 'LocalISP');
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
