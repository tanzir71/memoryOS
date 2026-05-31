import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android app icon is layered while notification icon stays solid', () {
    final appIcon = File(
      'android/app/src/main/res/drawable/ic_memory_os_gem.xml',
    ).readAsStringSync();
    final notificationIcon = File(
      'android/app/src/main/res/drawable/ic_memory_os_notification.xml',
    ).readAsStringSync();

    const solidGemPath = 'M32,4 L60,32 L32,60 L4,32 Z';
    const innerGemPath = 'M32,18 L46,32 L32,46 L18,32 Z';
    const centerGemPath = 'M32,27 L37,32 L32,37 L27,32 Z';

    expect(appIcon, contains('android:fillColor="#FF000000"'));
    expect(appIcon, contains('android:pathData="$solidGemPath"'));
    expect(appIcon, contains('android:fillColor="#FFFFFFFF"'));
    expect(appIcon, contains('android:pathData="$innerGemPath"'));
    expect(appIcon, contains('android:pathData="$centerGemPath"'));

    expect(notificationIcon, contains('android:fillColor="#FFFFFFFF"'));
    expect(notificationIcon, contains('android:pathData="$solidGemPath"'));
    expect(notificationIcon, isNot(contains('fillType="evenOdd"')));
    expect(notificationIcon, isNot(contains(innerGemPath)));
    expect(notificationIcon, isNot(contains(centerGemPath)));
  });
}
