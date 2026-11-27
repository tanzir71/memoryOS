import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/engine/rules_loader.dart';
import 'package:memoryos/engine/triage.dart';

void main() {
  late EngineRules rules;
  late TriageEngine engine;

  setUpAll(() {
    rules = EngineRules.loadFromDirectory('assets/rules');
    engine = TriageEngine(rules);
  });

  test('evaluates all 60+ notification and SMS triage fixtures', () {
    final raw = File('test/fixtures/triage/triage_fixtures.json').readAsStringSync();
    final fixtures = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    expect(fixtures.length, greaterThanOrEqualTo(60));

    final seenClasses = <String>{};
    for (final f in fixtures) {
      final result = engine.evaluate(
        TriageInput(
          source: f['source'] as String,
          pkg: f['pkg'] as String? ?? '',
          channel: f['channel'] as String? ?? '',
          category: f['category'] as String? ?? '',
          flags: (f['flags'] as num?)?.toInt() ?? 0,
          importance: (f['importance'] as num?)?.toInt() ?? 3,
          title: f['title'] as String? ?? '',
          body: f['body'] as String? ?? '',
          postedAt: 1795752840000,
          redacted: f['redacted'] == true,
          isConversation: f['isConversation'] == true,
          isProgressTick: f['isProgressTick'] == true,
          userKeepOverride: f['userKeepOverride'] as String?,
          channelScore: (f['channelScore'] as num?)?.toInt() ?? 0,
        ),
      );
      seenClasses.add(result.signalClass);
      expect(
        result.signalClass,
        f['expectClass'],
        reason: 'Fixture ${f['id']} class mismatch',
      );
      expect(
        result.kept,
        f['expectKept'],
        reason: 'Fixture ${f['id']} kept mismatch (reason: ${result.reason})',
      );
      if (f['expectRedacted'] == true) {
        expect(result.redacted, isTrue, reason: 'Fixture ${f['id']} should redact');
        expect(result.body, isEmpty, reason: 'Fixture ${f['id']} body must be empty');
        expect(result.title, startsWith('sensitive event from '));
      }
    }

    // All 11 classes covered.
    expect(
      seenClasses,
      containsAll([
        'conversation',
        'call',
        'email',
        'calendar',
        'transaction',
        'order',
        'travel',
        'media',
        'system',
        'promo',
        'otp',
      ]),
    );
  });

  test('updates per-channel score on click and fast cancel', () {
    expect(
      TriageEngine.updateChannelScore(
        currentScore: 0,
        postedAt: 1000,
        removedAt: 6000,
        removalReason: reasonClick,
      ),
      1,
    );
    expect(
      TriageEngine.updateChannelScore(
        currentScore: 0,
        postedAt: 1000,
        removedAt: 5000,
        removalReason: reasonCancel,
      ),
      -1,
    );
    // Cancel after 10 seconds does not penalise.
    expect(
      TriageEngine.updateChannelScore(
        currentScore: 0,
        postedAt: 1000,
        removedAt: 25000,
        removalReason: reasonCancel,
      ),
      0,
    );
  });
}
