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

  final Map<String, bool> sourceToggles = {
    'voice_note': false,
    'location': false,
    'notification': false,
    'bluetooth': false,
    'photo': false,
  };

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _globalBackgroundEnabled = false;
  bool get isGlobalBackgroundEnabled => _globalBackgroundEnabled;

  bool _isRecording = false;
  DateTime? _recordingStartTime;

  CaptureService._init();

  Future<void> init() async {
    if (_isInitialized) return;

    for (final key in sourceToggles.keys) {
      final valStr = await DatabaseService.instance.getSetting('toggle_$key');
      if (valStr != null) {
        sourceToggles[key] = valStr == 'true';
      }
    }

    _isInitialized = true;
    await _updateBackgroundServiceState();
  }

  Future<void> _updateBackgroundServiceState() async {
    final anyPassiveEnabled =
        sourceToggles['notification'] == true ||
        sourceToggles['location'] == true ||
        sourceToggles['bluetooth'] == true ||
        sourceToggles['photo'] == true;

    if (anyPassiveEnabled) {
      if (!_globalBackgroundEnabled) {
        await _enableBackgroundExecution();
      }
    } else if (_globalBackgroundEnabled) {
      await _disableBackgroundExecution();
    }
  }

  void setSourceToggle(String source, bool isEnabled) {
    sourceToggles[source] = isEnabled;
    DatabaseService.instance.saveSetting(
      'toggle_$source',
      isEnabled.toString(),
    );

    _updateBackgroundServiceState();

    if (Platform.isAndroid) {
      _setNativePersistence(_globalBackgroundEnabled);
    }
  }

  bool isSourceEnabled(String source) => sourceToggles[source] ?? false;

  Future<bool> requestPermission(String source) async {
    if (source == 'battery_optimization') {
      await openBatterySettings();
      return isIgnoringBatteryOptimizations();
    }

    if (source == 'background_listening') {
      try {
        if (Platform.isAndroid) {
          await Permission.notification.request();
          final config = FlutterBackgroundAndroidConfig(
            notificationTitle: 'MemoryOS is listening',
            notificationText: 'Capture is running locally. Tap to manage.',
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
              await _updateBackgroundServiceState();
              if (!await isIgnoringBatteryOptimizations()) {
                await openBatterySettings();
              }
              return true;
            }
          }
        }
      } catch (_) {}
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
          final status = await Permission.photos.request();
          if (!status.isGranted) {
            await Permission.storage.request();
          }
          if (!await Permission.storage.isGranted &&
              !await Permission.photos.isGranted) {
            return false;
          }
        } else if (source == 'notification') {
          if (Platform.isAndroid) {
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
        } else if (source == 'voice_note') {
          final status = await Permission.microphone.request();
          if (!status.isGranted) return false;
        } else if (source == 'location') {
          final foreground = await Permission.location.request();
          if (!foreground.isGranted) return false;
          await Permission.locationAlways.request();
        }
      }

      setSourceToggle(source, true);
      return true;
    } catch (_) {
      setSourceToggle(source, true);
      return true;
    }
  }

  Future<bool> checkPermission(String source) async {
    if (source == 'battery_optimization') {
      return isIgnoringBatteryOptimizations();
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
          return await Permission.bluetoothScan.isGranted &&
              await Permission.bluetoothConnect.isGranted;
        }
        if (source == 'photo') {
          if (await Permission.photos.isGranted) return true;
          return await Permission.storage.isGranted;
        }
        if (source == 'notification') {
          if (Platform.isAndroid) {
            return await isNotificationListenerPermissionGranted();
          }
          return await Permission.notification.isGranted;
        }
        if (source == 'voice_note') {
          return await Permission.microphone.isGranted;
        }
        if (source == 'location') {
          return await Permission.location.isGranted ||
              await Permission.locationAlways.isGranted;
        }
      }
    } catch (_) {}
    return sourceToggles[source] ?? false;
  }

  Future<void> _setNativePersistence(bool isPersistent) async {
    try {
      if (Platform.isAndroid) {
        await _persistentChannel.invokeMethod('setPersistent', {
          'isPersistent': isPersistent,
          'isPhotoEnabled': isSourceEnabled('photo'),
          'isNotificationEnabled': isSourceEnabled('notification'),
          'sourceToggles': Map<String, bool>.from(sourceToggles),
        });
      }
    } catch (_) {}
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      if (Platform.isAndroid) {
        return await _persistentChannel.invokeMethod(
              'isIgnoringBatteryOptimizations',
            ) ??
            false;
      }
    } catch (_) {}
    return true;
  }

  Future<void> openBatterySettings() async {
    try {
      if (Platform.isAndroid) {
        await _persistentChannel.invokeMethod('openBatterySettings');
      }
    } catch (_) {}
  }

  Future<bool> isNotificationListenerPermissionGranted() async {
    try {
      if (Platform.isAndroid) {
        return await _persistentChannel.invokeMethod(
              'isNotificationListenerPermissionGranted',
            ) ??
            false;
      }
    } catch (_) {}
    return true;
  }

  Future<void> requestNotificationListenerPermission() async {
    try {
      if (Platform.isAndroid) {
        await _persistentChannel.invokeMethod(
          'requestNotificationListenerPermission',
        );
      }
    } catch (_) {}
  }

  Future<void> _enableBackgroundExecution() async {
    try {
      if (Platform.isAndroid) {
        final config = FlutterBackgroundAndroidConfig(
          notificationTitle: 'MemoryOS is listening',
          notificationText: 'Capture is running locally. Tap to manage.',
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
        }
      } else {
        _globalBackgroundEnabled = true;
      }
    } catch (_) {}
  }

  Future<void> _disableBackgroundExecution() async {
    try {
      if (Platform.isAndroid) {
        final success = await FlutterBackground.disableBackgroundExecution();
        _globalBackgroundEnabled = !success;
        await _setNativePersistence(false);
      } else {
        _globalBackgroundEnabled = false;
      }
    } catch (_) {}
  }

  bool get isRecording => _isRecording;

  Future<bool> startRecording() async {
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
        return true;
      }
    } catch (_) {}
    _isRecording = false;
    return false;
  }

  Future<MemoryNode?> stopRecording(String customTitle) async {
    if (!_isRecording) return null;

    String? path;
    try {
      path = await _audioRecorder.stop();
    } catch (_) {}
    _isRecording = false;

    final durationSeconds = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inSeconds
        : 0;
    final minutesStr = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (durationSeconds % 60).toString().padLeft(2, '0');
    final durationText = '$minutesStr:$secondsStr';

    final String finalTitle = customTitle.isNotEmpty
        ? customTitle
        : 'Voice note';

    final node = MemoryNode(
      timestamp: _recordingStartTime ?? DateTime.now(),
      title: finalTitle,
      content: '',
      source: 'voice_note',
      metadata: {
        'duration': durationText,
        'durationSeconds': durationSeconds,
        'filePath': ?path,
      },
      trail: 'none',
    );

    await DatabaseService.instance.insertNode(node);
    return node;
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
