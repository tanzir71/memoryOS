import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/capture_metadata.dart';

void main() {
  test('extractScreenshotFileName prefers explicit fileName metadata', () {
    expect(
      extractScreenshotFileName({
        'fileName': 'Screenshot_20260524_071617.jpg',
        'filePath': '/storage/emulated/0/DCIM/Screenshots/ignored.png',
      }),
      'Screenshot_20260524_071617.jpg',
    );
  });

  test('extractScreenshotFileName falls back to the path basename', () {
    expect(
      extractScreenshotFileName({
        'filePath':
            '/storage/emulated/0/Pictures/Screenshots/Screenshot_20260524_071617.jpg',
      }),
      'Screenshot_20260524_071617.jpg',
    );
  });

  test('buildScreenshotSummary uses only the filename', () {
    expect(
      buildScreenshotSummary({
        'fileName': 'Screenshot_20260524_071617.jpg',
        'fileSize': '1.5 MB',
        'ocrText': 'fake ocr',
      }),
      'Screenshot_20260524_071617.jpg',
    );
  });

  test('detects notification removal records', () {
    expect(isNotificationRemovalRecord('notification_removed'), isTrue);
    expect(isNotificationRemovalRecord('notification'), isFalse);
  });

  test('detects screenshot file records without hiding regular photos', () {
    expect(
      isScreenshotFileRecord(
        source: 'photo',
        metadata: {
          'fileName': 'Screenshot_20260524_071617.jpg',
          'isScreenshot': true,
        },
      ),
      isTrue,
    );

    expect(
      isScreenshotFileRecord(
        source: 'photo',
        metadata: {'fileName': 'IMG_20260524_071617.jpg'},
      ),
      isFalse,
    );
  });

  test('keeps screenshot display metadata to filename only', () {
    expect(
      visibleMetadataForNode(
        source: 'photo',
        metadata: {
          'fileName': 'Screenshot_20260524_071617.jpg',
          'filePath': '/storage/emulated/0/DCIM/Screenshots/Screenshot.jpg',
          'fileSize': '0.0 KB',
          'isScreenshot': true,
        },
      ),
      {'fileName': 'Screenshot_20260524_071617.jpg'},
    );
  });

  test(
    'detects System UI screenshot notifications as duplicate capture noise',
    () {
      expect(
        isScreenshotCaptureNotification(
          packageName: 'com.android.systemui',
          channelId: 'screenshot',
          title: 'Screenshot captured',
          content: 'Tap to view your screenshot.',
        ),
        isTrue,
      );

      expect(
        isScreenshotCaptureNotification(
          packageName: 'com.google.android.gm',
          channelId: 'mail',
          title: 'Inbox update',
          content: 'Your weekly summary is ready.',
        ),
        isFalse,
      );
    },
  );

  test(
    'detects Samsung capture screenshot notifications as duplicate capture noise',
    () {
      expect(
        isScreenshotCaptureNotification(
          packageName: 'com.samsung.android.app.smartcapture',
          channelId: 'SAMSUNG_CAPTURE',
          title: 'Samsung capture',
          content: 'Screenshot saved\nTap here to see your screenshot.',
        ),
        isTrue,
      );
    },
  );

  test(
    'detects screenshot notification records without hiding real photos',
    () {
      expect(
        isScreenshotCaptureNotificationRecord(
          source: 'notification',
          metadata: {
            'packageName': 'com.samsung.android.app.smartcapture',
            'channelId': 'SAMSUNG_CAPTURE',
          },
          title: 'Samsung capture',
          content: 'Screenshot saved',
        ),
        isTrue,
      );

      expect(
        isScreenshotCaptureNotificationRecord(
          source: 'photo',
          metadata: {'fileName': 'Screenshot_20260524.png'},
          title: 'Screenshot captured',
          content: 'A new screenshot was saved.',
        ),
        isFalse,
      );
    },
  );

  test('builds stable dedupe keys for ongoing notifications', () {
    final firstKey = ongoingNotificationDedupeKey(
      source: 'notification',
      title: '[Ongoing] System UI: Charging',
      metadata: {
        'isOngoing': true,
        'notificationKey': '0|com.android.systemui|100|battery|1000',
        'packageName': 'com.android.systemui',
        'channelId': 'BATTERY',
      },
    );
    final secondKey = ongoingNotificationDedupeKey(
      source: 'notification',
      title: '[Ongoing] System UI: Charging',
      metadata: {
        'isOngoing': true,
        'notificationKey': '0|com.android.systemui|100|battery|1000',
        'packageName': 'com.android.systemui',
        'channelId': 'BATTERY',
      },
    );

    expect(firstKey, isNotNull);
    expect(firstKey, secondKey);
  });

  test('falls back to package channel and title for ongoing dedupe', () {
    expect(
      ongoingNotificationDedupeKey(
        source: 'notification',
        title: '[Ongoing] System UI: Charging',
        metadata: {
          'isOngoing': true,
          'packageName': 'com.android.systemui',
          'channelId': 'BATTERY',
        },
      ),
      'ongoing:com.android.systemui:battery:[ongoing] system ui: charging',
    );
  });

  test('detects obvious marketing notification patterns', () {
    expect(
      isMarketingNotification(
        packageName: 'com.shop.app',
        channelId: 'promotions',
        title: 'Flash sale ends tonight',
        content: 'Get 50% off. Use code SAVE50 before midnight.',
      ),
      isTrue,
    );

    expect(
      isMarketingNotification(
        packageName: 'com.delivery.app',
        channelId: 'offers',
        title: 'Limited time offer',
        content: 'Free delivery on your next order. Shop now.',
      ),
      isTrue,
    );

    expect(
      isMarketingNotification(
        packageName: 'com.google.android.gm',
        channelId: 'mail',
        title: 'Project offer review',
        content: 'Can you review the employment offer draft today?',
      ),
      isFalse,
    );
  });

  test('builds short-window dedupe keys for similar status notifications', () {
    final firstKey = shortWindowNotificationDedupeKey(
      source: 'notification',
      title: 'System UI: Bluetooth connected',
      content: 'Galaxy Buds2 connected at 7:16 AM',
      metadata: {
        'packageName': 'com.android.systemui',
        'channelId': 'bluetooth',
      },
    );
    final secondKey = shortWindowNotificationDedupeKey(
      source: 'notification',
      title: 'System UI: Bluetooth connected',
      content: 'Galaxy Buds2 connected at 7:17 AM',
      metadata: {
        'packageName': 'com.android.systemui',
        'channelId': 'bluetooth',
      },
    );
    final disconnectedKey = shortWindowNotificationDedupeKey(
      source: 'notification',
      title: 'System UI: Bluetooth disconnected',
      content: 'Galaxy Buds2 disconnected at 7:18 AM',
      metadata: {
        'packageName': 'com.android.systemui',
        'channelId': 'bluetooth',
      },
    );

    expect(firstKey, secondKey);
    expect(firstKey, isNot(disconnectedKey));
  });
}
