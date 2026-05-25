import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/capture_interval_policy.dart';

void main() {
  test('uses balanced default intervals for UI and passive checks', () {
    expect(uiRefreshInterval, const Duration(seconds: 30));
    expect(
      batteryOptimizationCheckInterval,
      const Duration(seconds: 60),
    );
    expect(clipboardScanInterval, const Duration(seconds: 30));
    expect(clipboardScanMaxInterval, const Duration(minutes: 2));
    expect(screenshotScanInterval, const Duration(seconds: 60));
    expect(screenshotScanMaxInterval, const Duration(minutes: 5));
  });

  test('clipboard backoff grows after repeated idle scans', () {
    final backoff = AdaptiveIntervalBackoff(
      initialInterval: clipboardScanInterval,
      maxInterval: clipboardScanMaxInterval,
      idleScansBeforeBackoff: 2,
    );

    expect(backoff.currentInterval, const Duration(seconds: 30));

    backoff.recordNoChange();
    expect(backoff.currentInterval, const Duration(seconds: 30));

    backoff.recordNoChange();
    expect(backoff.currentInterval, const Duration(seconds: 60));

    backoff.recordNoChange();
    backoff.recordNoChange();
    expect(backoff.currentInterval, const Duration(minutes: 2));

    backoff.recordNoChange();
    backoff.recordNoChange();
    expect(backoff.currentInterval, const Duration(minutes: 2));
  });

  test('adaptive backoff resets after a capture', () {
    final backoff = AdaptiveIntervalBackoff(
      initialInterval: clipboardScanInterval,
      maxInterval: clipboardScanMaxInterval,
      idleScansBeforeBackoff: 1,
    );

    backoff.recordNoChange();
    expect(backoff.currentInterval, const Duration(seconds: 60));

    backoff.recordCapture();
    expect(backoff.currentInterval, const Duration(seconds: 30));
  });
}
