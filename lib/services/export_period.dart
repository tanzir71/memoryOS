import '../models/memory_node.dart';

class ExportPeriodRange {
  const ExportPeriodRange({this.start, this.endExclusive});

  final DateTime? start;
  final DateTime? endExclusive;

  bool contains(DateTime value) {
    final afterStart =
        start == null ||
        value.isAtSameMomentAs(start!) ||
        value.isAfter(start!);
    final beforeEnd = endExclusive == null || value.isBefore(endExclusive!);
    return afterStart && beforeEnd;
  }
}

enum ExportPeriod {
  thisWeek('This week', 'this-week'),
  thisMonth('This month', 'this-month'),
  lastMonth('Last month', 'last-month'),
  last3Months('Last 3 months', 'last-3-months'),
  last6Months('Last 6 months', 'last-6-months'),
  lastYear('Last year', 'last-year'),
  allTime('All time', 'all-time');

  const ExportPeriod(this.label, this.filenameSlug);

  final String label;
  final String filenameSlug;

  ExportPeriodRange rangeFor(DateTime now) {
    switch (this) {
      case ExportPeriod.thisWeek:
        final today = DateTime(now.year, now.month, now.day);
        final monday = today.subtract(Duration(days: today.weekday - 1));
        return ExportPeriodRange(
          start: monday,
          endExclusive: monday.add(const Duration(days: 7)),
        );
      case ExportPeriod.thisMonth:
        return ExportPeriodRange(
          start: DateTime(now.year, now.month),
          endExclusive: DateTime(now.year, now.month + 1),
        );
      case ExportPeriod.lastMonth:
        return ExportPeriodRange(
          start: DateTime(now.year, now.month - 1),
          endExclusive: DateTime(now.year, now.month),
        );
      case ExportPeriod.last3Months:
        return ExportPeriodRange(
          start: _subtractMonths(now, 3),
          endExclusive: now.add(const Duration(microseconds: 1)),
        );
      case ExportPeriod.last6Months:
        return ExportPeriodRange(
          start: _subtractMonths(now, 6),
          endExclusive: now.add(const Duration(microseconds: 1)),
        );
      case ExportPeriod.lastYear:
        return ExportPeriodRange(
          start: DateTime(
            now.year - 1,
            now.month,
            now.day,
            now.hour,
            now.minute,
            now.second,
            now.millisecond,
            now.microsecond,
          ),
          endExclusive: now.add(const Duration(microseconds: 1)),
        );
      case ExportPeriod.allTime:
        return const ExportPeriodRange();
    }
  }

  List<MemoryNode> filterNodes(Iterable<MemoryNode> nodes, {DateTime? now}) {
    final range = rangeFor(now ?? DateTime.now());
    return nodes
        .where(
          (node) => node.deletedAt == null && range.contains(node.timestamp),
        )
        .toList();
  }
}

DateTime _subtractMonths(DateTime value, int months) {
  return DateTime(
    value.year,
    value.month - months,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}
