const requiredDailyLocationSamples = 6;
const locationSampleInterval = Duration(
  hours: Duration.hoursPerDay ~/ requiredDailyLocationSamples,
);

DateTime nextLocationSampleAfter(DateTime lastSampleAt) {
  return lastSampleAt.add(locationSampleInterval);
}
