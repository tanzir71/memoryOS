import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/capture/capture_dedupe.dart';

void main() {
  group('normalizePhoneNumber', () {
    test('normalises Bangladesh local numbers to +880', () {
      expect(normalizePhoneNumber('01711-000001'), '+8801711000001');
      expect(normalizePhoneNumber('8801711000001'), '+8801711000001');
      expect(normalizePhoneNumber('+880 1711 000001'), '+8801711000001');
      expect(normalizePhoneNumber('008801711000001'), '+8801711000001');
    });

    test('preserves alphanumeric sender IDs', () {
      expect(normalizePhoneNumber('bKash'), 'bkash');
      expect(normalizePhoneNumber('GP'), 'gp');
    });
  });

  group('SMS vs SMS notification dedupe', () {
    test('matches same normalised address, within 60 s, same body hash', () {
      const sms = SmsRecord(
        address: '+8801711000001',
        body: 'Recharge of Tk 499 successful.  30 GB, valid for 30 days.',
        occurredAt: 1795750000000,
      );
      const notif = NotificationRecord(
        pkg: 'com.google.android.apps.messaging',
        category: 'msg',
        title: '01711-000001',
        text: 'Recharge of Tk 499 successful. 30 GB, valid for 30 days.',
        postedAt: 1795750025000,
      );
      expect(
        isDuplicateSmsNotification(sms: sms, notification: notif),
        isTrue,
      );
    });

    test('does not match if more than 60 s apart', () {
      const sms = SmsRecord(
        address: '01711000001',
        body: 'See you at 5',
        occurredAt: 1795750000000,
      );
      const notif = NotificationRecord(
        pkg: 'com.google.android.apps.messaging',
        category: 'msg',
        title: '01711000001',
        text: 'See you at 5',
        postedAt: 1795750090000,
      );
      expect(
        isDuplicateSmsNotification(sms: sms, notification: notif),
        isFalse,
      );
    });

    test('does not match if body differs', () {
      const sms = SmsRecord(
        address: 'bKash',
        body: 'You have received Tk 1,200.00',
        occurredAt: 1795750000000,
      );
      const notif = NotificationRecord(
        pkg: 'com.google.android.apps.messaging',
        category: 'msg',
        title: 'bKash',
        text: 'You have sent Tk 1,200.00',
        postedAt: 1795750005000,
      );
      expect(
        isDuplicateSmsNotification(sms: sms, notification: notif),
        isFalse,
      );
    });
  });

  group('Call notification vs call-log dedupe', () {
    test('drops call notification overlapping call-log row', () {
      const call = CallLogRecord(
        number: '01711000001',
        cachedName: 'Nabila Rahman',
        callType: 'outgoing',
        startedAt: 1795753860000,
        durationSec: 720,
      );
      const notif = NotificationRecord(
        pkg: 'com.google.android.dialer',
        category: 'call',
        title: 'Nabila Rahman',
        text: 'Ongoing call',
        postedAt: 1795753865000,
        removedAt: 1795754580000,
      );
      expect(
        isOverlappingCallNotification(call: call, notification: notif),
        isTrue,
      );
      expect(callDurationSecondsFromNotification(notif), 715);
    });

    test('tolerates missing removedAt on call notification', () {
      const call = CallLogRecord(
        number: '01711000002',
        cachedName: 'Imran Hossain',
        callType: 'missed',
        startedAt: 1795776120000,
        durationSec: 0,
      );
      const notif = NotificationRecord(
        pkg: 'com.google.android.dialer',
        category: 'missed_call',
        title: 'Imran Hossain',
        text: 'Missed call',
        postedAt: 1795776125000,
        removedAt: null,
      );
      expect(
        isOverlappingCallNotification(call: call, notification: notif),
        isTrue,
      );
      expect(callDurationSecondsFromNotification(notif), isNull);
    });

    test('keeps WhatsApp call notification when no phone call-log overlaps', () {
      const call = CallLogRecord(
        number: '01711000001',
        cachedName: 'Nabila Rahman',
        callType: 'outgoing',
        startedAt: 1795753860000,
        durationSec: 720,
      );
      const whatsappMissed = NotificationRecord(
        pkg: 'com.whatsapp',
        category: 'missed_call',
        title: 'Nabila Rahman',
        text: 'Missed voice call',
        postedAt: 1795752720000,
      );
      expect(
        isOverlappingCallNotification(call: call, notification: whatsappMissed),
        isFalse,
      );
    });
  });

  group('Chat extras parser', () {
    test('extracts messages and inline replies when present', () {
      const extras =
          '{"messages":[{"sender":"Nabila","text":"Can you send it?","time":100,"isSelf":false}],'
          '"remoteInputHistory":["I will send it tonight"]}';
      final msgs = extractChatMessagesFromExtras(
        extras,
        fallbackSender: 'Nabila',
        fallbackText: 'Can you send it?',
        fallbackTime: 100,
      );
      expect(msgs, hasLength(2));
      expect(msgs[0].isSelf, isFalse);
      expect(msgs[1].isSelf, isTrue);
      expect(msgs[1].text, 'I will send it tonight');
    });

    test('tolerates missing messages and remoteInputHistory', () {
      final msgs = extractChatMessagesFromExtras(
        '{}',
        fallbackSender: 'Sadia',
        fallbackText: 'Running 5 late',
        fallbackTime: 200,
      );
      expect(msgs, hasLength(1));
      expect(msgs.single.sender, 'Sadia');
      expect(msgs.single.isSelf, isFalse);
    });
  });
}
