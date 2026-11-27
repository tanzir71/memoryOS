import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import '../data/database.dart';
import 'history_importer.dart';

const String drainInboxTaskName = 'com.memoryos.memoryos.drain_inbox';
const String drainInboxUniqueName = 'memoryos_periodic_drain';

@pragma('vm:entry-point')
void memoryWorkmanagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final db = await MemoryDatabase.openDefault();
      try {
        final coordinator = HistoryImportCoordinator(db: db);
        if (task == historyImportTaskName) {
          await coordinator.runFullHistoryImport();
        } else {
          await coordinator.runIncrementalPoll();
        }
        await db.purgeExpiredDeleted();
      } finally {
        await db.close();
      }
      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> initializeBackgroundWorker() async {
  if (!Platform.isAndroid) return;
  try {
    await Workmanager().initialize(memoryWorkmanagerDispatcher);
    await Workmanager().registerPeriodicTask(
      drainInboxUniqueName,
      drainInboxTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (_) {
    // Non-fatal in headless or test environments.
  }
}
