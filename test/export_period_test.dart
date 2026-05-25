import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/services/export_period.dart';

void main() {
  MemoryNode node(String title, DateTime timestamp, {DateTime? deletedAt}) {
    return MemoryNode(
      timestamp: timestamp,
      title: title,
      content: title,
      source: 'notification',
      metadata: const {},
      trail: 'none',
      deletedAt: deletedAt,
    );
  }

  group('ExportPeriod', () {
    test('this week starts on Monday and ends the next Monday', () {
      final now = DateTime(2026, 5, 27, 15, 30);
      final range = ExportPeriod.thisWeek.rangeFor(now);

      expect(range.start, DateTime(2026, 5, 25));
      expect(range.endExclusive, DateTime(2026, 6, 1));
      expect(range.contains(DateTime(2026, 5, 25, 0, 1)), isTrue);
      expect(range.contains(DateTime(2026, 5, 24, 23, 59)), isFalse);
    });

    test('this month covers the current calendar month', () {
      final now = DateTime(2026, 5, 27, 15, 30);
      final range = ExportPeriod.thisMonth.rangeFor(now);

      expect(range.start, DateTime(2026, 5));
      expect(range.endExclusive, DateTime(2026, 6));
      expect(range.contains(DateTime(2026, 5, 1)), isTrue);
      expect(range.contains(DateTime(2026, 6, 1)), isFalse);
    });

    test('last month covers the previous calendar month', () {
      final now = DateTime(2026, 1, 10, 12);
      final range = ExportPeriod.lastMonth.rangeFor(now);

      expect(range.start, DateTime(2025, 12));
      expect(range.endExclusive, DateTime(2026, 1));
      expect(range.contains(DateTime(2025, 12, 31, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 1, 1)), isFalse);
    });

    test(
      'rolling periods start the requested number of months or years back',
      () {
        final now = DateTime(2026, 5, 27, 15, 30);

        expect(
          ExportPeriod.last3Months.rangeFor(now).start,
          DateTime(2026, 2, 27, 15, 30),
        );
        expect(
          ExportPeriod.last6Months.rangeFor(now).start,
          DateTime(2025, 11, 27, 15, 30),
        );
        expect(
          ExportPeriod.lastYear.rangeFor(now).start,
          DateTime(2025, 5, 27, 15, 30),
        );
      },
    );

    test('all time includes visible nodes and excludes deleted nodes', () {
      final now = DateTime(2026, 5, 27, 15, 30);
      final filtered = ExportPeriod.allTime.filterNodes([
        node('old', DateTime(2020, 1, 1)),
        node('current', DateTime(2026, 5, 27)),
        node(
          'deleted',
          DateTime(2026, 5, 26),
          deletedAt: DateTime(2026, 5, 27),
        ),
      ], now: now);

      expect(filtered.map((node) => node.title), ['old', 'current']);
    });
  });
}
