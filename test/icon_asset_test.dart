import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android app and notification icons use the solid gem geometry', () {
    final appIcon = File(
      'android/app/src/main/res/drawable/ic_memory_os_gem.xml',
    ).readAsStringSync();
    final notificationIcon = File(
      'android/app/src/main/res/drawable/ic_memory_os_notification.xml',
    ).readAsStringSync();

    const solidGemPath = 'M32,4 L60,32 L32,60 L4,32 Z';

    expect(appIcon, contains('android:fillColor="#FF000000"'));
    expect(appIcon, contains('android:pathData="$solidGemPath"'));
    expect(appIcon, isNot(contains('M32,18')));

    expect(notificationIcon, contains('android:fillColor="#FFFFFFFF"'));
    expect(notificationIcon, contains('android:pathData="$solidGemPath"'));
    expect(notificationIcon, isNot(contains('fillType="evenOdd"')));
    expect(notificationIcon, isNot(contains('M32,18')));
  });
}
