import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/capture_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const recordChannel = MethodChannel('com.llfbandit.record/messages');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(recordChannel, (_) async => null);
  });

  test('notification capture alone does not enable native persistence', () async {
    final service = CaptureService.instance;
    service.sourceToggles.updateAll((_, _) => false);

    service.setSourceToggle('notification', true);
    await Future<void>.delayed(Duration.zero);

    expect(service.isGlobalBackgroundEnabled, isFalse);
  });
}
