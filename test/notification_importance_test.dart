import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/capture_metadata.dart';

void main() {
  test('weather summaries rank as high-priority events', () {
    final importance = classifyNotificationImportance(
      packageName: 'com.google.android.googlequicksearchbox',
      channelId: 'weather',
      title: 'Weather summary',
      content: 'Heavy rain expected around 6 PM. Carry an umbrella.',
    );

    expect(importance.tier, NotificationImportanceTier.high);
    expect(importance.isPriorityEvent, isTrue);
    expect(importance.reason, contains('Weather'));
  });

  test('direct messaging apps rank as high priority', () {
    for (final packageName in const [
      'com.whatsapp',
      'com.facebook.orca',
      'com.google.android.apps.messaging',
      'com.slack',
      'com.microsoft.teams',
    ]) {
      final importance = classifyNotificationImportance(
        packageName: packageName,
        channelId: 'messages',
        title: 'Tanzir',
        content: 'Can you review the handoff before 5?',
      );

      expect(
        importance.tier,
        NotificationImportanceTier.high,
        reason: packageName,
      );
      expect(importance.isPriorityEvent, isTrue, reason: packageName);
    }
  });

  test('human project email ranks at least medium priority', () {
    final importance = classifyNotificationImportance(
      packageName: 'com.google.android.gm',
      channelId: 'mail',
      title: 'Nadia',
      content: 'Project offer review is ready for the Helios client call.',
    );

    expect(
      importance.tier.index,
      lessThanOrEqualTo(NotificationImportanceTier.medium.index),
    );
    expect(importance.reason, contains('Email'));
  });

  test('promotions suppress while status notifications stay low', () {
    final promo = classifyNotificationImportance(
      packageName: 'com.shop.app',
      channelId: 'promotions',
      title: 'Flash sale ends tonight',
      content: 'Get 50% off. Use code SAVE50 before midnight.',
    );
    final status = classifyNotificationImportance(
      packageName: 'com.android.systemui',
      channelId: 'battery',
      title: 'Charging',
      content: 'Battery charging: 85%',
      isOngoing: true,
    );

    expect(promo.tier, NotificationImportanceTier.suppress);
    expect(status.tier, NotificationImportanceTier.low);
    expect(status.isPriorityEvent, isFalse);
  });
}
