import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memoryos/engine/intent_detector.dart';
import 'package:memoryos/engine/rules_loader.dart';

void main() {
  late IntentDetector detector;
  final refDay = DateTime(2026, 11, 27, 10, 14); // Friday 27 November 2026

  setUpAll(() {
    final rules = EngineRules.loadFromDirectory('assets/rules');
    detector = IntentDetector(rules.intents);
  });

  test('evaluates 30+ intent fixtures across English, Bangla, and Banglish', () {
    final raw = File('test/fixtures/intent/intent_fixtures.json').readAsStringSync();
    final fixtures = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    expect(fixtures.length, greaterThanOrEqualTo(30));

    final langCounts = <String, int>{};
    for (final f in fixtures) {
      final lang = f['lang'] as String;
      langCounts[lang] = (langCounts[lang] ?? 0) + 1;

      final res = detector.detect(
        text: f['text'] as String,
        referenceTime: refDay,
        isSelf: f['isSelf'] == true,
      );

      expect(res.type, f['expectType'], reason: 'Fixture ${f['id']} type');
      expect(
        res.confidence,
        greaterThanOrEqualTo((f['expectMinConf'] as num).toDouble()),
        reason: 'Fixture ${f['id']} confidence',
      );
      if (f['expectDueDay'] != null) {
        expect(res.dueAt, isNotNull, reason: 'Fixture ${f['id']} dueAt');
        expect(
          DateFormat('yyyy-MM-dd').format(res.dueAt!),
          f['expectDueDay'],
          reason: 'Fixture ${f['id']} dueAt date',
        );
      }
    }

    expect(langCounts['en'], greaterThanOrEqualTo(10));
    expect(langCounts['banglish'], greaterThanOrEqualTo(10));
    expect(langCounts['bangla'], greaterThanOrEqualTo(10));
  });

  test('calendar invites always produce plan with 0.9 confidence', () {
    final res = detector.detect(
      text: 'Quote review',
      referenceTime: refDay,
      isCalendarInvite: true,
      explicitDueAt: DateTime(2026, 12, 3, 15, 0),
    );
    expect(res.type, 'plan');
    expect(res.confidence, 0.9);
    expect(res.dueAt, DateTime(2026, 12, 3, 15, 0));
  });

  test('weak question without cue stays below 0.7 and does not open a loop', () {
    final res = detector.detect(
      text: 'Really?',
      referenceTime: refDay,
    );
    expect(res.confidence, lessThan(0.7));
    expect(res.canCreateOpenLoop, isFalse);
  });
}
