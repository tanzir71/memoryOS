import 'package:drift/drift.dart';
import '../data/database.dart';

/// User-driven thread and link actions: accept/reject link check, split signal
/// out, rename thread (sticky via `userEdited = true`), and merge threads.
class ThreadActions {
  ThreadActions(this.db);

  final MemoryDatabase db;

  Future<void> acceptSuggestedLink(int linkId) async {
    final link = await (db.select(db.signalLink)
          ..where((t) => t.id.equals(linkId)))
        .getSingleOrNull();
    if (link == null) return;

    await (db.update(db.signalLink)..where((t) => t.id.equals(linkId))).write(
      const SignalLinkCompanion(
        state: Value('linked'),
        decidedBy: Value('user'),
      ),
    );
    await db.into(db.threadSignal).insertOnConflictUpdate(
      ThreadSignalCompanion.insert(
        threadId: link.threadId,
        signalId: link.signalId,
      ),
    );
    await db.into(db.feedback).insert(
      FeedbackCompanion.insert(
        targetType: 'link',
        targetId: linkId,
        action: 'accept',
        at: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> rejectSuggestedLink(int linkId) async {
    await (db.update(db.signalLink)..where((t) => t.id.equals(linkId))).write(
      const SignalLinkCompanion(
        state: Value('rejected'),
        decidedBy: Value('user'),
      ),
    );
    await db.into(db.feedback).insert(
      FeedbackCompanion.insert(
        targetType: 'link',
        targetId: linkId,
        action: 'reject',
        at: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<int> splitSignalOut({
    required int threadId,
    required int signalId,
  }) async {
    await (db.delete(db.threadSignal)
          ..where(
            (t) => t.threadId.equals(threadId) & t.signalId.equals(signalId),
          ))
        .go();

    final existingLinks = await (db.select(db.signalLink)
          ..where(
            (t) => t.threadId.equals(threadId) & t.signalId.equals(signalId),
          ))
        .get();
    if (existingLinks.isEmpty) {
      await db.into(db.signalLink).insert(
        SignalLinkCompanion.insert(
          threadId: threadId,
          signalId: signalId,
          reasonsJson: const Value('[]'),
          score: const Value(0.0),
          state: const Value('rejected'),
          decidedBy: const Value('user'),
        ),
      );
    } else {
      for (final l in existingLinks) {
        await (db.update(db.signalLink)..where((t) => t.id.equals(l.id))).write(
          const SignalLinkCompanion(
            state: Value('rejected'),
            decidedBy: Value('user'),
          ),
        );
      }
    }

    await db.into(db.feedback).insert(
      FeedbackCompanion.insert(
        targetType: 'link',
        targetId: signalId,
        action: 'split',
        at: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    final sig = await (db.select(db.signal)
          ..where((t) => t.id.equals(signalId)))
        .getSingle();
    final newThreadId = await db.into(db.memoryThread).insert(
      MemoryThreadCompanion.insert(
        title: sig.title.isNotEmpty ? sig.title : 'Thread',
        kind: Value(_kindFor(sig.signalClass)),
        personId: Value(sig.personId),
        startedAt: sig.occurredAt,
        lastAt: sig.endedAt ?? sig.occurredAt,
      ),
    );
    await db.into(db.threadSignal).insert(
      ThreadSignalCompanion.insert(threadId: newThreadId, signalId: signalId),
    );
    return newThreadId;
  }

  Future<void> renameThread(int threadId, String newTitle) async {
    await (db.update(db.memoryThread)..where((t) => t.id.equals(threadId)))
        .write(
          MemoryThreadCompanion(
            title: Value(newTitle.trim()),
            userEdited: const Value(true),
          ),
        );
  }

  Future<void> mergeThreads({
    required int sourceThreadId,
    required int targetThreadId,
  }) async {
    if (sourceThreadId == targetThreadId) return;
    final rows = await (db.select(db.threadSignal)
          ..where((t) => t.threadId.equals(sourceThreadId)))
        .get();
    for (final r in rows) {
      await db.into(db.threadSignal).insertOnConflictUpdate(
        ThreadSignalCompanion.insert(
          threadId: targetThreadId,
          signalId: r.signalId,
        ),
      );
    }
    await (db.update(db.openLoop)
          ..where((t) => t.threadId.equals(sourceThreadId)))
        .write(OpenLoopCompanion(threadId: Value(targetThreadId)));
    await (db.delete(db.memoryThread)
          ..where((t) => t.id.equals(sourceThreadId)))
        .go();
  }

  Future<void> deleteThread(int threadId) async {
    await (db.delete(db.memoryThread)..where((t) => t.id.equals(threadId)))
        .go();
  }

  String _kindFor(String cls) => switch (cls) {
    'order' => 'order',
    'transaction' => 'payment',
    'calendar' => 'meeting',
    'conversation' || 'call' || 'email' => 'conversation',
    _ => 'other',
  };
}
