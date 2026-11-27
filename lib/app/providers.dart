import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../capture/inbox_drainer.dart';
import '../data/database.dart';

final databaseProvider = Provider<MemoryDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden at root.');
});

final inboxDrainerProvider = Provider<InboxDrainer>((ref) {
  return InboxDrainer(db: ref.watch(databaseProvider));
});

final keptSignalsProvider = StreamProvider<List<SignalRow>>((ref) {
  return ref.watch(databaseProvider).watchKeptSignals();
});

final pausedUntilProvider = StreamProvider<DateTime?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.setting)
        ..where((t) => t.key.equals('capture_paused_until')))
      .watchSingleOrNull()
      .map((row) {
        final ms = int.tryParse(row?.value ?? '');
        if (ms == null || ms <= 0) return null;
        final dt = DateTime.fromMillisecondsSinceEpoch(ms);
        return dt.isAfter(DateTime.now()) ? dt : null;
      });
});
