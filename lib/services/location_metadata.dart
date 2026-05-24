class LocationDetail {
  const LocationDetail(this.label, this.value);

  final String label;
  final String value;

  @override
  bool operator ==(Object other) {
    return other is LocationDetail &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(label, value);
}

List<LocationDetail> buildLocationDetailRows(Map<String, dynamic> metadata) {
  final details = <LocationDetail>[];

  void add(String label, Object? value, {String suffix = ''}) {
    if (value == null) return;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return;
    details.add(LocationDetail(label, '$text$suffix'));
  }

  add('Latitude', _firstMetadataValue(metadata, const ['latitude', 'lat']));
  add(
    'Longitude',
    _firstMetadataValue(metadata, const ['longitude', 'lng', 'lon']),
  );
  add(
    'Provider',
    _firstMetadataValue(metadata, const ['provider', 'locationProvider']),
  );
  add(
    'Accuracy',
    _firstMetadataValue(metadata, const ['accuracyMeters', 'accuracy']),
    suffix: ' m',
  );
  add('Event', _firstMetadataValue(metadata, const ['locationEvent', 'event']));

  final interval = _firstMetadataValue(metadata, const ['sampleIntervalHours']);
  if (interval != null && interval.toString().trim().isNotEmpty) {
    details.add(LocationDetail('Interval', 'Every $interval hours'));
  }

  add('Fallback', _firstMetadataValue(metadata, const ['fallbackReason']));
  add(
    'Cell technology',
    _firstMetadataValue(metadata, const ['cellTechnology']),
  );
  add('Cell count', _firstMetadataValue(metadata, const ['cellCount']));

  final isRegistered = _firstMetadataValue(metadata, const [
    'isRegisteredCell',
  ]);
  if (isRegistered != null) {
    details.add(
      LocationDetail('Registered cell', isRegistered == true ? 'Yes' : 'No'),
    );
  }

  return details;
}

Object? _firstMetadataValue(Map<String, dynamic> metadata, List<String> keys) {
  for (final key in keys) {
    final value = _lookupCaseInsensitive(metadata, key);
    if (value != null) return value;
  }

  for (final nestedKey in const ['coordinates', 'coords', 'location']) {
    final nested = _lookupCaseInsensitive(metadata, nestedKey);
    if (nested is Map) {
      final nestedMap = nested.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      for (final key in keys) {
        final value = _lookupCaseInsensitive(nestedMap, key);
        if (value != null) return value;
      }
    }
  }

  return null;
}

Object? _lookupCaseInsensitive(Map<String, dynamic> metadata, String key) {
  if (metadata.containsKey(key)) return metadata[key];
  final lowerKey = key.toLowerCase();
  for (final entry in metadata.entries) {
    if (entry.key.toLowerCase() == lowerKey) {
      return entry.value;
    }
  }
  return null;
}
