import 'dart:io';
import 'package:drift/drift.dart';
import '../data/database.dart';
import 'capture_api.g.dart';

typedef SignalProcessor = Future<void> Function(RawInboxItem item, int signalId);

/// Drains unconsumed rows from Android's `inbox.db` via Pigeon and writes
/// normalised `signal` rows into Drift's `memory.db`, then acknowledges them.
class InboxDrainer {
  InboxDrainer({
    required this.db,
    CaptureHostApi? hostApi,
    this.onSignalInserted,
  }) : _hostApi = hostApi ?? CaptureHostApi();

  final MemoryDatabase db;
  final CaptureHostApi _hostApi;
  final SignalProcessor? onSignalInserted;

  static const _lastIdKey = 'last_inbox_id';

  Future<int> drainAll({int batchSize = 200}) async {
    if (!Platform.isAndroid) return 0;
    final stored = await db.getSetting(_lastIdKey);
    var afterId = int.tryParse(stored ?? '') ?? 0;
    var total = 0;

    while (true) {
      final batch = await _hostApi.drainInbox(afterId, batchSize);
      if (batch.isEmpty) break;

      var maxId = afterId;
      for (final item in batch) {
        if (item.id > maxId) maxId = item.id;
        await ingestItem(item);
        total++;
      }

      await _hostApi.ackInbox(maxId);
      await db.setSetting(_lastIdKey, maxId.toString());
      afterId = maxId;

      if (batch.length < batchSize) break;
    }

    return total;
  }

  Future<int> ingestItem(RawInboxItem item) async {
    final body = item.bigText.isNotEmpty ? item.bigText : item.text;
    final signalId = await db.into(db.signal).insert(
      SignalCompanion.insert(
        inboxId: Value(item.id),
        source: item.source,
        pkg: Value(item.pkg),
        kind: Value(item.category.isNotEmpty ? item.category : item.source),
        sbnKey: Value(item.sbnKey.isEmpty ? null : item.sbnKey),
        title: Value(item.title),
        body: Value(body),
        occurredAt: item.postedAt,
        endedAt: Value(item.removedAt),
        signalClass: Value(_defaultClassFor(item.source)),
        kept: const Value(true),
        redacted: Value(item.redacted),
        extrasJson: Value(item.extrasJson),
      ),
    );

    await db.upsertSearchEntry(
      targetType: 'signal',
      targetId: signalId,
      title: item.title,
      body: body,
    );

    if (onSignalInserted != null) {
      await onSignalInserted!(item, signalId);
    }

    return signalId;
  }

  String _defaultClassFor(String source) => switch (source) {
    'sms' => 'conversation',
    'call' => 'call',
    'calendar' => 'calendar',
    _ => 'system',
  };
}
