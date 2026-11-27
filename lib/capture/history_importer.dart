import 'dart:io';
import 'package:workmanager/workmanager.dart';
import '../data/database.dart';
import 'capture_api.g.dart';
import 'inbox_drainer.dart';

const String historyImportTaskName = 'com.memoryos.memoryos.history_import';
const String historyImportUniqueName = 'memoryos_first_history_import';

class HistoryImportSummary {
  const HistoryImportSummary({
    required this.smsImported,
    required this.callsImported,
    required this.contactsImported,
    required this.calendarImported,
    required this.drainedSignals,
  });

  final int smsImported;
  final int callsImported;
  final int contactsImported;
  final int calendarImported;
  final int drainedSignals;
}

class HistoryImportCoordinator {
  HistoryImportCoordinator({
    required this.db,
    CaptureHostApi? hostApi,
    InboxDrainer? drainer,
  }) : _hostApi = hostApi ?? CaptureHostApi(),
       _drainer = drainer ?? InboxDrainer(db: db, hostApi: hostApi);

  final MemoryDatabase db;
  final CaptureHostApi _hostApi;
  final InboxDrainer _drainer;

  static const _lastSmsKey = 'last_sms_import_at';
  static const _lastCallKey = 'last_call_import_at';

  Future<HistoryImportSummary> runIncrementalPoll({DateTime? now}) async {
    if (!Platform.isAndroid) {
      return const HistoryImportSummary(
        smsImported: 0,
        callsImported: 0,
        contactsImported: 0,
        calendarImported: 0,
        drainedSignals: 0,
      );
    }
    final current = now ?? DateTime.now();
    final lastSms = int.tryParse(await db.getSetting(_lastSmsKey) ?? '') ?? 0;
    final lastCall = int.tryParse(await db.getSetting(_lastCallKey) ?? '') ?? 0;

    final smsRes = await _hostApi.importSmsInbox(lastSms);
    if (smsRes.completed && smsRes.error == null) {
      await db.setSetting(_lastSmsKey, current.millisecondsSinceEpoch.toString());
    }

    final callRes = await _hostApi.importCallLog(lastCall);
    if (callRes.completed && callRes.error == null) {
      await db.setSetting(_lastCallKey, current.millisecondsSinceEpoch.toString());
    }

    final fromCal = current.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    final toCal = current.add(const Duration(days: 30)).millisecondsSinceEpoch;
    final calRes = await _hostApi.importCalendarInstances(fromCal, toCal);

    final drained = await _drainer.drainAll();

    return HistoryImportSummary(
      smsImported: smsRes.importedCount,
      callsImported: callRes.importedCount,
      contactsImported: 0,
      calendarImported: calRes.importedCount,
      drainedSignals: drained,
    );
  }

  Future<HistoryImportSummary> runFullHistoryImport({
    bool includeSms = true,
    bool includeCalls = true,
    bool includeContacts = true,
    bool includeCalendar = true,
    void Function(ImportProgress progress)? onProgress,
    DateTime? now,
  }) async {
    if (!Platform.isAndroid) {
      return const HistoryImportSummary(
        smsImported: 0,
        callsImported: 0,
        contactsImported: 0,
        calendarImported: 0,
        drainedSignals: 0,
      );
    }
    final current = now ?? DateTime.now();
    var smsCount = 0;
    var callCount = 0;
    var contactsCount = 0;
    var calCount = 0;

    if (includeContacts) {
      final res = await _hostApi.importContacts();
      contactsCount = res.importedCount;
      onProgress?.call(res);
    }

    if (includeSms) {
      final res = await _hostApi.importSmsInbox(0);
      smsCount = res.importedCount;
      if (res.completed && res.error == null) {
        await db.setSetting(_lastSmsKey, current.millisecondsSinceEpoch.toString());
      }
      onProgress?.call(res);
    }

    if (includeCalls) {
      final res = await _hostApi.importCallLog(0);
      callCount = res.importedCount;
      if (res.completed && res.error == null) {
        await db.setSetting(_lastCallKey, current.millisecondsSinceEpoch.toString());
      }
      onProgress?.call(res);
    }

    if (includeCalendar) {
      final fromCal = current.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
      final toCal = current.add(const Duration(days: 30)).millisecondsSinceEpoch;
      final res = await _hostApi.importCalendarInstances(fromCal, toCal);
      calCount = res.importedCount;
      onProgress?.call(res);
    }

    final drained = await _drainer.drainAll();
    await db.setSetting(
      'history_import_completed_at',
      current.millisecondsSinceEpoch.toString(),
    );

    return HistoryImportSummary(
      smsImported: smsCount,
      callsImported: callCount,
      contactsImported: contactsCount,
      calendarImported: calCount,
      drainedSignals: drained,
    );
  }

  static Future<void> scheduleBackgroundHistoryImport({
    bool requireCharging = false,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await Workmanager().registerOneOffTask(
        historyImportUniqueName,
        historyImportTaskName,
        constraints: Constraints(requiresCharging: requireCharging),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    } catch (_) {
      // Non-fatal outside Android runtime.
    }
  }
}
