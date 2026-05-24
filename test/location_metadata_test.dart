import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/services/location_metadata.dart';

void main() {
  test(
    'location detail rows show raw coordinate data without fake map labels',
    () {
      final details = buildLocationDetailRows({
        'locationName': 'Device location',
        'latitude': '23.7806',
        'longitude': '90.2794',
        'accuracyMeters': 42.2,
        'provider': 'network',
        'locationEvent': 'scheduled_4h_sample',
        'sampleIntervalHours': 4,
      });

      expect(details, contains(const LocationDetail('Latitude', '23.7806')));
      expect(details, contains(const LocationDetail('Longitude', '90.2794')));
      expect(details, contains(const LocationDetail('Provider', 'network')));
      expect(details, contains(const LocationDetail('Accuracy', '42.2 m')));
      expect(
        details,
        contains(const LocationDetail('Event', 'scheduled_4h_sample')),
      );
      expect(
        details,
        contains(const LocationDetail('Interval', 'Every 4 hours')),
      );
      expect(
        details.any((detail) => detail.value == 'Device location'),
        isFalse,
      );
    },
  );

  test('cell tower fallback details include fallback-specific metadata', () {
    final details = buildLocationDetailRows({
      'provider': 'cell_tower',
      'locationEvent': 'startup_sample_cell_tower',
      'fallbackReason': 'device_location_unavailable',
      'cellTechnology': 'Lte',
      'cellCount': 3,
      'isRegisteredCell': true,
    });

    expect(details, contains(const LocationDetail('Provider', 'cell_tower')));
    expect(
      details,
      contains(const LocationDetail('Fallback', 'device_location_unavailable')),
    );
    expect(details, contains(const LocationDetail('Cell technology', 'Lte')));
    expect(details, contains(const LocationDetail('Cell count', '3')));
    expect(details, contains(const LocationDetail('Registered cell', 'Yes')));
  });

  test('location detail rows accept archive-style coordinate aliases', () {
    final details = buildLocationDetailRows({
      'coords': {'lat': 23.7806, 'lng': 90.2794},
      'accuracy': 18,
      'locationProvider': 'gps',
      'event': 'startup_sample',
    });

    expect(details, contains(const LocationDetail('Latitude', '23.7806')));
    expect(details, contains(const LocationDetail('Longitude', '90.2794')));
    expect(details, contains(const LocationDetail('Provider', 'gps')));
    expect(details, contains(const LocationDetail('Accuracy', '18 m')));
    expect(details, contains(const LocationDetail('Event', 'startup_sample')));
  });
}
