import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/capture/capture_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/memoryos/memoryos/CaptureApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.memoryos.memoryos'),
  ),
)
class RawInboxItem {
  RawInboxItem({
    required this.id,
    required this.source,
    required this.pkg,
    required this.channel,
    required this.category,
    required this.flags,
    required this.importance,
    required this.sbnKey,
    required this.groupKey,
    required this.isConversation,
    required this.isGroup,
    required this.title,
    required this.text,
    required this.bigText,
    required this.peopleJson,
    required this.extrasJson,
    required this.postedAt,
    this.removedAt,
    this.removalReason,
    required this.redacted,
  });

  int id;
  String source;
  String pkg;
  String channel;
  String category;
  int flags;
  int importance;
  String sbnKey;
  String groupKey;
  bool isConversation;
  bool isGroup;
  String title;
  String text;
  String bigText;
  String peopleJson;
  String extrasJson;
  int postedAt;
  int? removedAt;
  int? removalReason;
  bool redacted;
}

class PermissionSnapshot {
  PermissionSnapshot({
    required this.notificationAccess,
    required this.sms,
    required this.callLog,
    required this.contacts,
    required this.calendar,
    required this.microphone,
    required this.bluetooth,
    required this.ignoringBatteryOptimizations,
  });

  bool notificationAccess;
  bool sms;
  bool callLog;
  bool contacts;
  bool calendar;
  bool microphone;
  bool bluetooth;
  bool ignoringBatteryOptimizations;
}

class ImportProgress {
  ImportProgress({
    required this.source,
    required this.importedCount,
    required this.totalCount,
    required this.completed,
    this.error,
  });

  String source;
  int importedCount;
  int totalCount;
  bool completed;
  String? error;
}

@HostApi()
abstract class CaptureHostApi {
  List<RawInboxItem> drainInbox(int afterId, int limit);
  void ackInbox(int upToId);
  PermissionSnapshot checkPermissions();
  void openNotificationListenerSettings();
  void openAppInfoSettings();
  void openBatterySettings();
  void setCapturePausedUntil(int epochMs);
  int getCapturePausedUntil();
  void setSourceEnabled(String source, bool enabled);
  void updateStatusSummary(int threadsToday, int setAsideToday);
  ImportProgress importSmsInbox(int afterEpochMs);
  ImportProgress importCallLog(int afterEpochMs);
  ImportProgress importContacts();
  ImportProgress importCalendarInstances(int fromEpochMs, int toEpochMs);
}
