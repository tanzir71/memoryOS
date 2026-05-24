import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/models/memory_node.dart';

void main() {
  test('memory node maps deletedAt for recoverable deleted memories', () {
    final deletedAt = DateTime(2026, 5, 24, 14, 30);
    final node = MemoryNode(
      id: 7,
      timestamp: DateTime(2026, 5, 24, 12),
      title: 'Corrected memory',
      content: 'Updated details',
      source: 'notification',
      metadata: const {'packageName': 'gmail'},
      trail: 'work',
      deletedAt: deletedAt,
    );

    final map = node.toMap();
    expect(map['deleted_at'], deletedAt.toIso8601String());

    final restored = MemoryNode.fromMap(map);
    expect(restored.deletedAt, deletedAt);
  });

  test('copyWith can clear deletedAt when restoring a memory', () {
    final node = MemoryNode(
      timestamp: DateTime(2026, 5, 24, 12),
      title: 'Deleted memory',
      content: 'Recover me',
      source: 'reading',
      metadata: const {},
      trail: 'none',
      deletedAt: DateTime(2026, 5, 24, 13),
    );

    final restored = node.copyWith(deletedAt: null, clearDeletedAt: true);

    expect(restored.deletedAt, isNull);
  });
}
