import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/engine/extractor.dart';
import 'package:memoryos/engine/rules_loader.dart';

void main() {
  late EngineRules rules;
  late ExtractionEngine extractor;

  setUpAll(() {
    rules = EngineRules.loadFromDirectory('assets/rules');
    extractor = ExtractionEngine(rules);
  });

  test('all 10 sender packs are marked verified: false and have >= 5 fixtures each', () {
    expect(rules.senders, hasLength(10));
    for (final pack in rules.senders) {
      expect(pack.verified, isFalse, reason: '${pack.name} must be verified: false');
    }

    final raw = File('test/fixtures/extract/extract_fixtures.json').readAsStringSync();
    final fixtures = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    final countsPerPack = <String, int>{};

    for (final f in fixtures) {
      final res = extractor.extract(
        pkg: f['pkg'] as String? ?? '',
        senderAddress: f['address'] as String? ?? '',
        title: f['title'] as String? ?? '',
        body: f['body'] as String? ?? '',
      );
      final expectedPack = f['expectPack'] as String;
      countsPerPack[expectedPack] = (countsPerPack[expectedPack] ?? 0) + 1;

      expect(res.matchedPack, expectedPack, reason: 'Fixture ${f['id']} pack');
      expect(res.kind, f['expectKind'], reason: 'Fixture ${f['id']} kind');
      final expectFields = (f['expectFields'] as Map<String, dynamic>?) ?? const {};
      for (final entry in expectFields.entries) {
        expect(
          res.fields[entry.key],
          entry.value,
          reason: 'Fixture ${f['id']} field ${entry.key}',
        );
      }
    }

    for (final pack in rules.senders) {
      expect(
        countsPerPack[pack.name] ?? 0,
        greaterThanOrEqualTo(5),
        reason: 'Pack ${pack.name} needs at least 5 fixtures',
      );
    }
  });

  test('generic fallbacks extract money, dates, validity, order and tracking ids', () {
    final res = extractor.extract(
      pkg: '',
      senderAddress: 'UnknownShop',
      title: 'UnknownShop',
      body: 'Order #ORD99102 total ৳2,450 due 30 Nov, tracking #TRK771122, valid for 30 days.',
      signalClass: 'order',
    );
    expect(res.matchedPack, isNull);
    expect(res.unparsedTransactional, isTrue);
    expect(res.fields['amount'], '2,450');
    expect(res.fields['order_id'], 'ORD99102');
    expect(res.fields['tracking_no'], 'TRK771122');
    expect(res.fields['valid_days'], '30');
    expect(res.fields['date'], '30 Nov');
  });
}
