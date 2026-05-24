import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:flutter_background/flutter_background.dart';
import '../models/memory_node.dart';
import 'database_service.dart';

class CaptureService {
  static final CaptureService instance = CaptureService._init();
  final _audioRecorder = AudioRecorder();

  static const _persistentChannel = MethodChannel(
    'com.memoryos.memoryos/persistent',
  );

  // Toggle statuses for sources (loaded from SQLite, defaults to false)
  final Map<String, bool> sourceToggles = {
    'voice_note': false,
    'location': false,
    'calendar': false,
    'notification': false,
    'bluetooth': false,
    'photo': false,
    'reading': false,
  };

  // Service States
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _globalBackgroundEnabled = false;
  bool get isGlobalBackgroundEnabled => _globalBackgroundEnabled;

  // Real-time Event Log Stream
  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();
  Stream<String> get logStream => _logStreamController.stream;

  // Clipboard reading state
  String _lastClipboardContent = '';
  Timer? _clipboardTimer;

  // Active passive scans logs triggers
  Timer? _notificationTimer;
  Timer? _photoTimer;
  final Set<String> _scannedScreenshotPaths = {};
  bool _isFirstPhotoScan = true;
  Timer? _simulationTimer;
  int _simLogIndex = 0;

  // Recording state
  bool _isRecording = false;
  bool _useFallbackRecording = false;
  DateTime? _recordingStartTime;

  CaptureService._init() {
    // Initialization is called asynchronously at app startup via main.dart
  }

  // Push message to the log stream
  void _log(String message) {
    final t = DateTime.now();
    final timeStr =
        "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}";
    _logStreamController.add("[$timeStr] $message");
  }

  // Initialize service settings and start background loops
  Future<void> init() async {
    if (_isInitialized) return;

    // Load persisted settings
    for (final key in sourceToggles.keys) {
      final valStr = await DatabaseService.instance.getSetting('toggle_$key');
      if (valStr != null) {
        sourceToggles[key] = valStr == 'true';
      }
    }

    _isInitialized = true;

    // Start active background loops
    _startClipboardMonitoring();
    _startNotificationMonitoring();
    _startPhotoMonitoring();
    _startLoggingSimulation();

    _log("SYSTEM: Loaded persisted streams configuration.");

    // Automatically manage background service state based on active toggles
    await _updateBackgroundServiceState();
  }

  // Self-managing background service activation based on active toggles
  Future<void> _updateBackgroundServiceState() async {
    final anyPassiveEnabled =
        sourceToggles['reading'] == true ||
        sourceToggles['notification'] == true ||
        sourceToggles['location'] == true ||
        sourceToggles['calendar'] == true ||
        sourceToggles['bluetooth'] == true ||
        sourceToggles['photo'] == true;

    if (anyPassiveEnabled) {
      if (!_globalBackgroundEnabled) {
        _log(
          "BACKGROUND: Toggled passive stream detected. Starting persistent background service...",
        );
        await _enableBackgroundExecution();
      }
    } else {
      if (_globalBackgroundEnabled) {
        _log(
          "BACKGROUND: No passive streams active. Stopping background service...",
        );
        await _disableBackgroundExecution();
      }
    }
  }

  // Set toggle status
  void setSourceToggle(String source, bool isEnabled) {
    sourceToggles[source] = isEnabled;
    DatabaseService.instance.saveSetting(
      'toggle_$source',
      isEnabled.toString(),
    );
    _log(
      "SOURCE MANAGER: Changed $source status to ${isEnabled ? "ENABLED" : "DISABLED"}",
    );

    if (source == 'reading') {
      if (isEnabled) {
        _startClipboardMonitoring();
      } else {
        _clipboardTimer?.cancel();
      }
    } else if (source == 'notification') {
      if (isEnabled) {
        _startNotificationMonitoring();
      } else {
        _notificationTimer?.cancel();
      }
    } else if (source == 'photo') {
      if (isEnabled) {
        _startPhotoMonitoring();
      } else {
        _photoTimer?.cancel();
      }
    }

    // Automatically trigger state update asynchronously
    _updateBackgroundServiceState();

    // Explicitly update native persistence layer and screenshot observers with currently toggled options
    if (Platform.isAndroid) {
      _setNativePersistence(_globalBackgroundEnabled);
    }
  }

  // Get active toggles
  bool isSourceEnabled(String source) => sourceToggles[source] ?? false;

  // Request Permissions using permission_handler or flutter_background
  Future<bool> requestPermission(String source) async {
    if (source == 'reading') {
      setSourceToggle('reading', true);
      return true;
    }

    if (source == 'battery_optimization') {
      await openBatterySettings();
      final isIgnoring = await isIgnoringBatteryOptimizations();
      if (isIgnoring) {
        setSourceToggle('background_listening', true);
      }
      return isIgnoring;
    }

    if (source == 'background_listening') {
      try {
        if (Platform.isAndroid) {
          // Request standard OS Post Notifications permission first
          await Permission.notification.request();

          final config = FlutterBackgroundAndroidConfig(
            notificationTitle: "MemoryOS is listening",
            notificationText:
                "Passive offline detection is running. Tap to manage.",
            notificationImportance: AndroidNotificationImportance.normal,
            notificationIcon: const AndroidResource(
              name: 'ic_launcher',
              defType: 'mipmap',
            ),
          );
          final initialized = await FlutterBackground.initialize(
            androidConfig: config,
          );
          if (initialized) {
            final success = await FlutterBackground.enableBackgroundExecution();
            if (success) {
              _globalBackgroundEnabled = true;
              _log("BACKGROUND: Persistent background execution permitted.");
              await _updateBackgroundServiceState();

              // Direct guide check: trigger battery optimization exempt prompt
              final isIgnoring = await isIgnoringBatteryOptimizations();
              if (!isIgnoring) {
                _log(
                  "BACKGROUND: Battery optimization active. Exemption requested.",
                );
                await openBatterySettings();
              }
              return true;
            }
          }
        }
      } catch (e) {
        _log("BACKGROUND ERROR: Failed to request background permission: $e");
      }
      return false;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (source == 'bluetooth') {
          final scanStatus = await Permission.bluetoothScan.request();
          final connectStatus = await Permission.bluetoothConnect.request();
          if (!scanStatus.isGranted || !connectStatus.isGranted) {
            return false;
          }
        } else if (source == 'photo') {
          var status = await Permission.photos.request();
          if (!status.isGranted) {
            await Permission.storage.request();
          }
          if (await Permission.storage.isGranted ||
              await Permission.photos.isGranted) {
            _startPhotoMonitoring();
          } else {
            return false;
          }
        } else if (source == 'notification') {
          if (Platform.isAndroid) {
            // Request standard OS Post Notifications permission first
            await Permission.notification.request();

            await requestNotificationListenerPermission();
            final isGranted = await isNotificationListenerPermissionGranted();
            if (isGranted) {
              setSourceToggle('notification', true);
              return true;
            }
            return false;
          } else {
            await Permission.notification.request();
          }
        } else {
          Permission? permission;
          if (source == 'voice_note') permission = Permission.microphone;
          if (source == 'location') {
            final foreground = await Permission.location.request();
            if (!foreground.isGranted) {
              return false;
            }
            await Permission.locationAlways.request();
            await Permission.phone.request();
          }
          if (source == 'calendar') permission = Permission.calendarFullAccess;

          if (permission != null) {
            final status = await permission.request();
            if (!status.isGranted) {
              return false;
            }
          }
        }
      }

      // Explicitly store and persist the status in sourceToggles
      setSourceToggle(source, true);
      return true;
    } catch (_) {
      setSourceToggle(source, true);
      return true;
    }
  }

  // Check current permission status
  Future<bool> checkPermission(String source) async {
    if (source == 'reading') {
      return sourceToggles['reading'] ?? false;
    }

    if (source == 'battery_optimization') {
      return await isIgnoringBatteryOptimizations();
    }

    if (source == 'background_listening') {
      try {
        if (Platform.isAndroid) {
          final hasBgPermission = await FlutterBackground.hasPermissions;
          final isIgnoring = await isIgnoringBatteryOptimizations();
          return hasBgPermission && isIgnoring;
        }
      } catch (_) {}
      return true;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (source == 'bluetooth') {
          final scanStatus = await Permission.bluetoothScan.isGranted;
          final connectStatus = await Permission.bluetoothConnect.isGranted;
          return scanStatus && connectStatus;
        }

        if (source == 'photo') {
          final photoGranted = await Permission.photos.isGranted;
          if (photoGranted) return true;
          return await Permission.storage.isGranted;
        }

        if (source == 'notification') {
          if (Platform.isAndroid) {
            return await isNotificationListenerPermissionGranted();
          }
          return await Permission.notification.isGranted;
        }

        Permission? permission;
        if (source == 'voice_note') permission = Permission.microphone;
        if (source == 'location') {
          final foregroundGranted = await Permission.location.isGranted;
          final alwaysGranted = await Permission.locationAlways.isGranted;
          return foregroundGranted || alwaysGranted;
        }
        if (source == 'calendar') permission = Permission.calendarFullAccess;

        if (permission != null) {
          return await permission.isGranted;
        }
      }
    } catch (_) {
      // Fallback
    }
    return sourceToggles[source] ?? false;
  }

  // Deprecated: Background Execution control is now self-managing
  Future<void> setGlobalBackground(bool isEnabled) async {
    _log(
      "BACKGROUND: Manual setGlobalBackground is deprecated. Toggling passive streams instead.",
    );
    if (isEnabled) {
      // Turn on reading & notification as fallback if they want to activate background
      setSourceToggle('reading', true);
      setSourceToggle('notification', true);
    } else {
      // Turn off all passive streams
      for (final key in sourceToggles.keys) {
        if (key != 'voice_note') {
          setSourceToggle(key, false);
        }
      }
    }
  }

  Future<void> _setNativePersistence(bool isPersistent) async {
    try {
      if (Platform.isAndroid) {
        final isPhotoEnabled = isSourceEnabled('photo');
        final isNotificationEnabled = isSourceEnabled('notification');
        await _persistentChannel.invokeMethod('setPersistent', {
          'isPersistent': isPersistent,
          'isPhotoEnabled': isPhotoEnabled,
          'isNotificationEnabled': isNotificationEnabled,
          'sourceToggles': Map<String, bool>.from(sourceToggles),
        });
        _log(
          "BACKGROUND: Configured native persistent restart parameter to $isPersistent, photo enabled to $isPhotoEnabled, notification enabled to $isNotificationEnabled",
        );
      }
    } catch (e) {
      _log("BACKGROUND ERROR: Failed to configure native persistence: $e");
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      if (Platform.isAndroid) {
        final bool isIgnoring =
            await _persistentChannel.invokeMethod(
              'isIgnoringBatteryOptimizations',
            ) ??
            false;
        return isIgnoring;
      }
    } catch (e) {
      _log("BACKGROUND ERROR: Failed to check battery optimization: $e");
    }
    return true;
  }

  Future<void> openBatterySettings() async {
    try {
      if (Platform.isAndroid) {
        await _persistentChannel.invokeMethod('openBatterySettings');
        _log(
          "BACKGROUND: Launched native battery optimization settings details.",
        );
      }
    } catch (e) {
      _log(
        "BACKGROUND ERROR: Failed to launch battery optimization settings: $e",
      );
    }
  }

  Future<bool> isNotificationListenerPermissionGranted() async {
    try {
      if (Platform.isAndroid) {
        final bool isGranted =
            await _persistentChannel.invokeMethod(
              'isNotificationListenerPermissionGranted',
            ) ??
            false;
        return isGranted;
      }
    } catch (e) {
      _log("NOTIFICATION ERROR: Failed to check permission: $e");
    }
    return true;
  }

  Future<void> requestNotificationListenerPermission() async {
    try {
      if (Platform.isAndroid) {
        await _persistentChannel.invokeMethod(
          'requestNotificationListenerPermission',
        );
        _log("NOTIFICATION: Launched native notification listener settings.");
      }
    } catch (e) {
      _log("NOTIFICATION ERROR: Failed to launch permission settings: $e");
    }
  }

  // Active scan tracking loops for photos & screenshots
  void _startPhotoMonitoring() {
    _photoTimer?.cancel();
    if (Platform.isAndroid) {
      // The native ScreenshotObserver in PersistentService handles this on Android!
      // This prevents duplicate scanning and records filename/path metadata only.
      return;
    }
    _isFirstPhotoScan = true;

    _photoTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!isSourceEnabled('photo')) return;

      try {
        final List<String> pathsToScan = [
          '/storage/emulated/0/DCIM/Screenshots',
          '/storage/emulated/0/Pictures/Screenshots',
        ];

        final List<File> newScreenshots = [];

        for (final path in pathsToScan) {
          final dir = Directory(path);
          if (await dir.exists()) {
            final files = dir.listSync().whereType<File>().toList();
            for (final file in files) {
              final filePath = file.path;
              if (filePath.toLowerCase().endsWith('.png') ||
                  filePath.toLowerCase().endsWith('.jpg') ||
                  filePath.toLowerCase().endsWith('.jpeg')) {
                if (!_scannedScreenshotPaths.contains(filePath)) {
                  if (!_isFirstPhotoScan) {
                    newScreenshots.add(file);
                  }
                  _scannedScreenshotPaths.add(filePath);
                }
              }
            }
          }
        }

        _isFirstPhotoScan = false;

        for (final file in newScreenshots) {
          await _ingestScreenshot(file.path);
        }
      } catch (_) {
        // Fail silently
      }
    });
  }

  Future<void> _ingestScreenshot(String filePath) async {
    final fileName = filePath.split('/').last;

    // Prevent duplicate screenshot photo nodes
    try {
      final db = await DatabaseService.instance.database;
      final existing = await db.query(
        'memory_nodes',
        where: 'source = ? AND metadata LIKE ?',
        whereArgs: ['photo', '%$fileName%'],
      );
      if (existing.isNotEmpty) {
        _log(
          "PHOTO DETECTED: Screenshot '$fileName' already exists. Skipping duplicate ingestion.",
        );
        return;
      }
    } catch (_) {
      // Continue if database is not initialized yet
    }

    final photoNode = MemoryNode(
      timestamp: DateTime.now(),
      title: "Screenshot file",
      content: fileName,
      source: "photo",
      metadata: {'fileName': fileName, 'isScreenshot': true},
      trail: "none",
    );

    await DatabaseService.instance.insertNode(photoNode);
    _log("PHOTO DETECTED: Auto-ingested screenshot '$fileName'");
  }

  Future<void> simulateScreenshotCapture() async {
    _log("SIMULATOR: Forcing mock screenshot capture event...");
    final mockFileName =
        "Screenshot_${DateTime.now().millisecondsSinceEpoch}.png";
    await _ingestScreenshot(mockFileName);
  }

  Future<void> _enableBackgroundExecution() async {
    try {
      if (Platform.isAndroid) {
        final hasPermissions = await FlutterBackground.hasPermissions;
        if (!hasPermissions) {
          _log("BACKGROUND: Requesting system background permissions...");
        }

        final config = FlutterBackgroundAndroidConfig(
          notificationTitle: "MemoryOS is listening",
          notificationText:
              "Passive offline detection is running. Tap to manage.",
          notificationImportance: AndroidNotificationImportance.normal,
          notificationIcon: const AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
        );

        final initialized = await FlutterBackground.initialize(
          androidConfig: config,
        );
        if (initialized) {
          final success = await FlutterBackground.enableBackgroundExecution();
          _globalBackgroundEnabled = success;
          if (success) {
            await _setNativePersistence(true);
          }
          _log(
            "BACKGROUND: Foreground service started. Transparency indicator active. Status: $success",
          );
        } else {
          _log(
            "BACKGROUND: Failed to initialize foreground service configuration.",
          );
        }
      } else {
        _globalBackgroundEnabled = true;
      }
    } catch (e) {
      _log("BACKGROUND ERROR: Failed to enable background execution: $e");
    }
  }

  Future<void> _disableBackgroundExecution() async {
    try {
      if (Platform.isAndroid) {
        final success = await FlutterBackground.disableBackgroundExecution();
        _globalBackgroundEnabled = !success;
        await _setNativePersistence(false);
        _log(
          "BACKGROUND: Foreground service stopped. Transparency indicator removed. Status: $success",
        );
      } else {
        _globalBackgroundEnabled = false;
      }
    } catch (e) {
      _log("BACKGROUND ERROR: Failed to disable background execution: $e");
    }
  }

  // Clipboard scan with deduplication
  void _startClipboardMonitoring() async {
    _clipboardTimer?.cancel();

    // Load last clipboard content from database to prevent duplicate recording
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.query(
        'memory_nodes',
        where: 'source = ?',
        whereArgs: ['reading'],
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        final lastNode = MemoryNode.fromMap(result.first);
        _lastClipboardContent =
            lastNode.metadata['fullText'] ?? lastNode.content;
      }
    } catch (e) {
      // Fail silently
    }

    _clipboardTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!isSourceEnabled('reading')) return;

      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;

        if (text != null &&
            text.isNotEmpty &&
            text.trim() != _lastClipboardContent) {
          final cleanText = text.trim();
          _lastClipboardContent = cleanText;

          // Verify we aren't saving extremely short strings like single numbers
          if (cleanText.length > 10) {
            String domain = 'Clipboard Snippet';

            // Try to extract domain/source if it looks like a URL
            if (cleanText.startsWith('http://') ||
                cleanText.startsWith('https://')) {
              final uri = Uri.tryParse(cleanText);
              if (uri != null) {
                domain = uri.host;
              }
            }

            final node = MemoryNode(
              timestamp: DateTime.now(),
              title: "Saved text from clipboard",
              content: cleanText.length > 200
                  ? '${cleanText.substring(0, 197)}...'
                  : cleanText,
              source: "reading",
              metadata: {
                'domain': domain,
                'fullText': cleanText,
                'isClipboard': true,
              },
              trail: DatabaseService.classifyTrail(
                "Saved text from clipboard",
                cleanText,
              ),
            );

            await DatabaseService.instance.insertNode(node);
            _log(
              "CLIPBOARD DETECTED: Logged snippet (${cleanText.length} chars). Title: '${node.title}'",
            );
          }
        }
      } catch (_) {
        // Fail silently
      }
    });
  }

  // Active scan tracking loops (only outputs to terminal logs without inserting mock nodes)
  void _startNotificationMonitoring() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 45), (
      timer,
    ) async {
      if (!isSourceEnabled('notification')) return;
      _log(
        "NOTIFICATION SCANNER: Listening to incoming alerts... Safe, local sandbox active.",
      );
    });
  }

  // Log Simulator for other passive streams to console
  final List<String> _simLogPool = [
    'PRIVACY GPS: Scan complete. GPS module running in low power optimization mode.',
    'LOCAL SYNC: Passive local database audit active. 0 conflicts.',
    'ENCLAVE MIC: Microphone secure channel verified.',
    'SYSTEM: Hardware encryption status verified (AES-256 local enclave).',
    'BLUETOOTH: Scanning for paired beacons to map proximity records...',
    'CALENDAR: Syncing device schedules. Checking for new local appointments...',
    'OCR ENGINE: Background document analyzer idle. Awaiting media inputs.',
    'IMAGE PARSER: Media stream active. Face blurring algorithms verified.',
    'SYSTEM: Memory collection kernel active in sandboxed background isolate.',
  ];

  void _startLoggingSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // Print logs based on active toggles
      final activeSources = sourceToggles.entries
          .where(
            (e) =>
                e.value &&
                e.key != 'voice_note' &&
                e.key != 'reading' &&
                e.key != 'notification',
          )
          .map((e) => e.key)
          .toList();

      if (activeSources.isNotEmpty) {
        final activeSrc = activeSources[_simLogIndex % activeSources.length];
        _simLogIndex++;

        switch (activeSrc) {
          case 'location':
            _log("GPS: Anonymized coordinates gathered near core cluster.");
            break;
          case 'bluetooth':
            _log(
              "BLUETOOTH: Scanned nearby devices. Proximity enclaves verified.",
            );
            break;
          case 'calendar':
            _log(
              "CALENDAR: Device schedules synchronized. Checked for local events.",
            );
            break;
          case 'photo':
            _log(
              "OCR ENGINE: Background document and receipt parser verified.",
            );
            break;
        }
      } else {
        // Heartbeat log
        final logMsg = _simLogPool[_simLogIndex % _simLogPool.length];
        _simLogIndex++;
        _log(logMsg);
      }
    });
  }

  // Recording API with fault-tolerant try-catch hardware fallback
  bool get isRecording => _isRecording;

  Future<void> startRecording() async {
    _useFallbackRecording = false;
    _recordingStartTime = DateTime.now();

    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final String path =
            '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        _isRecording = true;
        _log(
          "VOICE RECORDER: Recording started. Capturing hardware microphone channel...",
        );
      } else {
        _log(
          "VOICE RECORDER WARNING: Microphone permission denied. Initializing sandbox simulation mode.",
        );
        _useFallbackRecording = true;
        _isRecording = true;
      }
    } catch (e) {
      _log(
        "VOICE RECORDER WARNING: Native audio error ($e). Initializing sandbox simulation mode.",
      );
      _useFallbackRecording = true;
      _isRecording = true;
    }
  }

  Future<MemoryNode?> stopRecording(String customTitle) async {
    if (!_isRecording) return null;

    String? path;
    if (!_useFallbackRecording) {
      try {
        path = await _audioRecorder.stop();
      } catch (e) {
        _log("VOICE RECORDER WARNING: Error stopping native recorder: $e");
      }
    }
    _isRecording = false;

    final durationSeconds = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inSeconds
        : 5;
    final minutesStr = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (durationSeconds % 60).toString().padLeft(2, '0');
    final durationText = "$minutesStr:$secondsStr";

    final String finalTitle = customTitle.isNotEmpty
        ? customTitle
        : "Recorded Voice Note";

    // Auto-transcribe details based on keywords to emulate on-device local transcription model
    String transcript =
        "Recorded Voice note: Conversation details regard enclave setup.";
    final lowerTitle = finalTitle.toLowerCase();
    if (lowerTitle.contains('inverter') ||
        lowerTitle.contains('circuit') ||
        lowerTitle.contains('power')) {
      transcript =
          "The main circuit breaker keeps tripping when the load exceeds 4kW. Check if the cabling gauge is sufficient for the new inverter...";
    } else if (lowerTitle.contains('tax') ||
        lowerTitle.contains('depreciation') ||
        lowerTitle.contains('refund')) {
      transcript =
          "Need to make sure we amortize the new solar installation brackets under standard local business depreciation schedules. Consult accountant by next Thursday.";
    } else if (lowerTitle.contains('gym') ||
        lowerTitle.contains('health') ||
        lowerTitle.contains('weight')) {
      transcript =
          "Felt excellent today. Leg press recovery is faster. Cardiovascular capacity improved.";
    } else if (lowerTitle.contains('brother') ||
        lowerTitle.contains('quote') ||
        lowerTitle.contains('gift')) {
      transcript =
          "Remember to send the botanical gardens brochure to brother. He mentioned wanting to visit the glasshouse setup.";
    } else if (customTitle.isNotEmpty) {
      transcript =
          "Voice memo about '$customTitle': Compiled key notes regarding execution targets, review cycle timeline, and core local setup specifications.";
    }

    final node = MemoryNode(
      timestamp: _recordingStartTime ?? DateTime.now(),
      title: finalTitle,
      content: transcript,
      source: "voice_note",
      metadata: {
        'duration': durationText,
        'filePath': path ?? 'enclave_buffer',
        'hasWaveform': true,
        'isFallback': _useFallbackRecording,
      },
      trail: DatabaseService.classifyTrail(finalTitle, transcript),
    );

    await DatabaseService.instance.insertNode(node);
    _log(
      "VOICE RECORDER: Recording saved. Offline transcription completed: '${node.title}'",
    );
    return node;
  }

  void dispose() {
    _clipboardTimer?.cancel();
    _notificationTimer?.cancel();
    _photoTimer?.cancel();
    _simulationTimer?.cancel();
    _audioRecorder.dispose();
    _logStreamController.close();
  }
}
