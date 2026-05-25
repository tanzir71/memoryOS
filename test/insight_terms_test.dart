import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/services/insight_terms.dart';

void main() {
  MemoryNode node({
    required String title,
    required String content,
    String source = 'notification',
    Map<String, dynamic> metadata = const {},
    DateTime? timestamp,
  }) {
    return MemoryNode(
      id: title.hashCode,
      timestamp: timestamp ?? DateTime(2026, 5, 24, 8),
      title: title,
      content: content,
      source: source,
      metadata: metadata,
      trail: 'none',
    );
  }

  test('ranks meaningful multi-word noun phrases before generic words', () {
    final terms = extractInsightTerms([
      node(
        title: 'Solar battery anodes',
        content: 'Discussed solar battery anodes efficiency with NMC lab.',
      ),
      node(
        title: 'Solar battery anodes follow up',
        content: 'NMC lab wants another review of the solar battery anodes.',
      ),
      node(
        title: 'Battery reminder',
        content: 'Check battery logs after the lab call.',
      ),
    ]);

    expect(terms.first.label, 'Solar Battery Anodes');
    expect(terms.map((term) => term.label), contains('NMC Lab'));
  });

  test(
    'keeps proper nouns and app names while suppressing MemoryOS boilerplate',
    () {
      final terms = extractInsightTerms([
        node(
          title: 'Gmail: Lameh invoice',
          content:
              'MemoryOS system recorded notification from Gmail about Lameh.',
        ),
        node(
          title: 'YouTube saved',
          content: 'Passive enclave saved YouTube design video context.',
        ),
      ]);

      final labels = terms.map((term) => term.label).toList();
      expect(labels, contains('Gmail'));
      expect(labels, contains('Lameh'));
      expect(labels, contains('YouTube'));
      expect(labels, isNot(contains('MemoryOS System')));
      expect(labels, isNot(contains('Passive Enclave')));
    },
  );

  test('matches insight terms on word boundaries only', () {
    final gmail = const InsightTerm(
      label: 'Mail',
      normalized: 'mail',
      score: 1,
      documentCount: 1,
      occurrenceCount: 1,
    );

    expect(
      nodeMatchesInsightTerm(
        node(title: 'Gmail update', content: 'Invoice arrived'),
        gmail,
      ),
      isFalse,
    );
    expect(
      nodeMatchesInsightTerm(
        node(title: 'Mail update', content: 'Invoice arrived'),
        gmail,
      ),
      isTrue,
    );
  });

  test('rare unique events outrank repeated generic nouns', () {
    final nodes = [
      for (var i = 0; i < 8; i += 1)
        node(
          title: 'System update',
          content: 'Battery logs update complete for device status.',
        ),
      node(
        title: 'Weather summary',
        content: 'Heavy rain expected near Gulshan around 6 PM.',
        source: 'notification',
      ),
    ];

    final terms = extractInsightTerms(nodes);

    expect(terms.first.label, anyOf('Weather Summary', 'Gulshan'));
    expect(terms.first.category, anyOf('weather', 'proper_noun'));
    expect(terms.take(3).map((term) => term.label), isNot(contains('Battery')));
  });

  test('message senders outrank repeated common notification words', () {
    final terms = extractInsightTerms([
      for (var i = 0; i < 5; i += 1)
        node(
          title: 'Notification update',
          content: 'Summary update from device logs.',
        ),
      node(
        title: 'WhatsApp: Farhan',
        content: 'Farhan: Can you review the inverter quote tonight?',
        source: 'notification',
      ),
    ]);

    expect(terms.first.label, 'Farhan');
    expect(terms.first.category, 'message_sender');
  });

  test('fallback still returns useful terms without priority signals', () {
    final terms = extractInsightTerms([
      node(
        title: 'Garden planning',
        content: 'Discussed compost schedule and balcony herbs.',
        source: 'voice_note',
      ),
    ]);

    expect(terms.map((term) => term.label), contains('Garden Planning'));
    expect(terms, isNotEmpty);
  });

  test(
    'messaging and uncommon nouns outrank android google platform noise',
    () {
      final terms = extractInsightTerms([
        for (var i = 0; i < 8; i += 1)
          node(
            title: 'Android Google notification',
            content: 'Android Google system update notification ready.',
            metadata: const {'packageName': 'com.android.systemui'},
          ),
        node(
          title: 'WhatsApp: Meher',
          content: 'Meher asked about the nutrition plan.',
          metadata: const {'packageName': 'com.whatsapp'},
        ),
        node(
          title: 'Gmail: Dr Rahman',
          content: 'Bloodwork follow-up appointment details are attached.',
          metadata: const {'packageName': 'com.google.android.gm'},
        ),
        node(
          title: 'Messenger: Ayesha',
          content: 'Ayesha shared the grocery list.',
          metadata: const {'packageName': 'com.facebook.orca'},
        ),
      ]);

      final topLabels = terms.take(5).map((term) => term.label).toList();

      expect(topLabels, contains('Meher'));
      expect(topLabels, contains('Rahman'));
      expect(topLabels, contains('Ayesha'));
      expect(topLabels, isNot(contains('Android')));
      expect(topLabels, isNot(contains('Google')));
    },
  );
}
