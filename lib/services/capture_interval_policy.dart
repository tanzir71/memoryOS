const uiRefreshInterval = Duration(seconds: 30);
const batteryOptimizationCheckInterval = Duration(seconds: 60);
const clipboardScanInterval = Duration(seconds: 30);
const clipboardScanMaxInterval = Duration(minutes: 2);
const screenshotScanInterval = Duration(seconds: 60);
const screenshotScanMaxInterval = Duration(minutes: 5);

class AdaptiveIntervalBackoff {
  AdaptiveIntervalBackoff({
    required this.initialInterval,
    required this.maxInterval,
    this.idleScansBeforeBackoff = 3,
  }) : _currentInterval = initialInterval;

  final Duration initialInterval;
  final Duration maxInterval;
  final int idleScansBeforeBackoff;

  Duration _currentInterval;
  int _idleScanCount = 0;

  Duration get currentInterval => _currentInterval;

  void recordNoChange() {
    _idleScanCount += 1;
    if (_idleScanCount < idleScansBeforeBackoff) return;

    _idleScanCount = 0;
    final nextMilliseconds = _currentInterval.inMilliseconds * 2;
    _currentInterval = Duration(
      milliseconds: nextMilliseconds.clamp(
        initialInterval.inMilliseconds,
        maxInterval.inMilliseconds,
      ).toInt(),
    );
  }

  void recordCapture() {
    _idleScanCount = 0;
    _currentInterval = initialInterval;
  }
}
