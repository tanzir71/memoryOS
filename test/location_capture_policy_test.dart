import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/location_capture_policy.dart';

void main() {
  test('location sampling runs six times per day at equal intervals', () {
    expect(requiredDailyLocationSamples, 6);
    expect(locationSampleInterval, const Duration(hours: 4));
  });

  test('nextLocationSampleAfter advances by the fixed interval', () {
    final lastSample = DateTime(2026, 5, 24, 8);

    expect(nextLocationSampleAfter(lastSample), DateTime(2026, 5, 24, 12));
  });
}
