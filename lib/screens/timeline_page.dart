import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/memory_node.dart';
import '../services/capture_metadata.dart';
import '../services/database_service.dart';
import '../services/capture_service.dart';
import '../services/location_metadata.dart';
import '../theme/app_theme.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  DateTime _selectedDate = DateTime.now();
  List<MemoryNode> _nodes = [];
  bool _isLoading = true;
  int? _activeNodeId;

  // Recording State
  bool _isRecording = false;
  String _recordingTime = "00:00";
  Timer? _recordingTimer;
  Timer? _refreshTimer;
  int _secondsRecorded = 0;
  final TextEditingController _voiceTitleController = TextEditingController();

  // Audio Playback State
  AudioPlayer? _audioPlayer;
  int? _playingNodeId;
  bool _isPlaying = false;

  // Permission Statuses for Stream Setup Onboarding Guide
  Map<String, bool> _permissionsGranted = {
    'voice_note': true,
    'location': true,
    'calendar': true,
    'notification': true,
    'photo': true,
    'bluetooth': true,
    'reading': true,
    'background_listening': true,
    'battery_optimization': true,
  };
  bool _showPermissionsBanner = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Bind playback state listeners
    _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed || state == PlayerState.stopped) {
            _playingNodeId = null;
            _isPlaying = false;
          }
        });
      }
    });

    _loadNodes();
    _checkAllPermissions();
    _requestNotificationPermissionOnStartup();

    // Refresh timeline nodes when returning to this page
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && !_isRecording) {
        _loadNodes();
        _checkAllPermissions();
      }
    });
  }

  Future<void> _requestNotificationPermissionOnStartup() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
          _checkAllPermissions();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _recordingTimer?.cancel();
    _voiceTitleController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _loadNodes() async {
    try {
      final nodes = await DatabaseService.instance.fetchNodesByDate(
        _selectedDate,
      );
      if (mounted) {
        setState(() {
          _nodes = nodes;
          _isLoading = false;
          // Set first node as active by default if none selected
          if (_activeNodeId == null && nodes.isNotEmpty) {
            _activeNodeId = nodes.first.id;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  EdgeInsets _modalPadding(BuildContext context) {
    final media = MediaQuery.of(context);
    return EdgeInsets.only(
      top: 24,
      left: 24,
      right: 24,
      bottom: media.viewInsets.bottom + media.padding.bottom + 32,
    );
  }

  Future<bool> _softDeleteNode(MemoryNode node) async {
    if (node.id == null) return false;

    try {
      await DatabaseService.instance.deleteNode(node.id!);
      if (!mounted) return true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Memory moved to Deleted Memories.'),
          backgroundColor: AppTheme.primary,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              await DatabaseService.instance.restoreNode(node.id!);
              await _loadNodes();
            },
          ),
        ),
      );
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting node: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return false;
    }
  }

  void _openEditNodeSheet(MemoryNode node) {
    final titleCtrl = TextEditingController(text: node.title);
    final contentCtrl = TextEditingController(text: node.content);
    final metadataCtrl = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(node.metadata),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: _modalPadding(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Edit Memory Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct the stored title, notes, or metadata when a captured event needs cleanup.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: metadataCtrl,
                    maxLines: 6,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Metadata JSON',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final content = contentCtrl.text.trim();
                      if (title.isEmpty || content.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Title and details are required.'),
                          ),
                        );
                        return;
                      }

                      Map<String, dynamic> metadata;
                      try {
                        final decoded = jsonDecode(metadataCtrl.text);
                        if (decoded is! Map) {
                          throw const FormatException(
                            'Metadata must be a JSON object.',
                          );
                        }
                        metadata = decoded.map(
                          (key, value) => MapEntry(key.toString(), value),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Metadata JSON is invalid: $e'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                        return;
                      }

                      await DatabaseService.instance.updateNode(
                        node.copyWith(
                          title: title,
                          content: content,
                          metadata: metadata,
                        ),
                      );
                      if (!mounted || !context.mounted) return;
                      Navigator.pop(context);
                      await _loadNodes();
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Memory details updated.'),
                          backgroundColor: AppTheme.contextGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Corrections'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      titleCtrl.dispose();
      contentCtrl.dispose();
      metadataCtrl.dispose();
    });
  }

  Future<void> _openDeletedMemoriesSheet() async {
    var deletedNodes = await DatabaseService.instance.fetchDeletedNodes();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.78,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: _modalPadding(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Deleted Memories',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recover deleted memories here. Items older than 30 days are permanently removed automatically.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (deletedNodes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No deleted memories to recover.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: deletedNodes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final deleted = deletedNodes[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDim,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.04),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          deleted.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          deleted.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Restore',
                                    icon: const Icon(Icons.restore),
                                    color: AppTheme.primary,
                                    onPressed: () async {
                                      await DatabaseService.instance
                                          .restoreNode(deleted.id!);
                                      setModalState(() {
                                        deletedNodes = deletedNodes
                                            .where(
                                              (node) => node.id != deleted.id,
                                            )
                                            .toList();
                                      });
                                      await _loadNodes();
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Delete forever',
                                    icon: const Icon(Icons.delete_forever),
                                    color: AppTheme.error,
                                    onPressed: () async {
                                      await DatabaseService.instance
                                          .permanentlyDeleteNode(deleted.id!);
                                      setModalState(() {
                                        deletedNodes = deletedNodes
                                            .where(
                                              (node) => node.id != deleted.id,
                                            )
                                            .toList();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _isLoading = true;
      _activeNodeId = null;
    });
    _loadNodes();
  }

  Future<void> _checkAllPermissions() async {
    final mic = await CaptureService.instance.checkPermission('voice_note');
    final loc = await CaptureService.instance.checkPermission('location');
    final cal = await CaptureService.instance.checkPermission('calendar');
    final notif = await CaptureService.instance.checkPermission('notification');
    final photo = await CaptureService.instance.checkPermission('photo');
    final bluetooth = await CaptureService.instance.checkPermission(
      'bluetooth',
    );
    final reading = await CaptureService.instance.checkPermission('reading');
    final bgListening = await CaptureService.instance.checkPermission(
      'background_listening',
    );
    final batteryOpt = await CaptureService.instance.checkPermission(
      'battery_optimization',
    );

    if (mounted) {
      setState(() {
        _permissionsGranted = {
          'voice_note': mic,
          'location': loc,
          'calendar': cal,
          'notification': notif,
          'photo': photo,
          'bluetooth': bluetooth,
          'reading': reading,
          'background_listening': bgListening,
          'battery_optimization': batteryOpt,
        };
        // Show banner if any permission is missing
        _showPermissionsBanner =
            !mic ||
            !loc ||
            !cal ||
            !notif ||
            !photo ||
            !bluetooth ||
            !reading ||
            !bgListening ||
            !batteryOpt;
      });
    }
  }

  void _openPermissionsGuideSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: _modalPadding(context),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'On-Device Stream Setup',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configure required local stream components below. Data is kept 100% locally encrypted and isolated.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildPermissionRow(
                        'voice_note',
                        'Microphone Audio',
                        'Used to record audio voice notes and local transcribers.',
                        Icons.mic,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'location',
                        'Location Stream',
                        'Collects privacy-first coarse anonymized location coordinates.',
                        Icons.location_on,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'calendar',
                        'Calendar Schedules',
                        'Parses upcoming local device events and meeting timelines.',
                        Icons.calendar_today,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'notification',
                        'Notifications Interception',
                        'Requires "Notification Access" permission in Android settings to capture alerts.',
                        Icons.notifications,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'photo',
                        'Storage / Photo Gallery',
                        'Scans files, tax receipts, and photos for local OCR indexers.',
                        Icons.photo_library,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'bluetooth',
                        'Bluetooth Scan',
                        'Detects paired Bluetooth devices to reconstruct surrounding context.',
                        Icons.bluetooth,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'reading',
                        'Clipboard Snippets',
                        'Enables reading from clipboard to save snippets as "reading" entries.',
                        Icons.content_paste,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'background_listening',
                        'Persistent Background Activity',
                        'Allows stream monitoring and notifications history to run in the background.',
                        Icons.battery_saver,
                        setModalState,
                      ),
                      _buildPermissionRow(
                        'battery_optimization',
                        'Battery Optimization Exemption',
                        'Aggressive OS battery optimization kills offline streams. Set to Unrestricted.',
                        Icons.battery_charging_full,
                        setModalState,
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _checkAllPermissions();
                        },
                        child: const Text(
                          'Save & Done',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionRow(
    String source,
    String title,
    String subtitle,
    IconData icon,
    void Function(void Function()) setModalState,
  ) {
    final isGranted = _permissionsGranted[source] ?? false;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGranted
                  ? AppTheme.primary.withOpacity(0.08)
                  : AppTheme.surfaceDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isGranted ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: isGranted
                  ? AppTheme.contextGreenContainer
                  : AppTheme.primary.withOpacity(0.08),
              foregroundColor: isGranted
                  ? AppTheme.contextGreen
                  : AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: isGranted
                ? null
                : () async {
                    final granted = await CaptureService.instance
                        .requestPermission(source);
                    setModalState(() {
                      _permissionsGranted[source] = granted;
                      _showPermissionsBanner = !_permissionsGranted.values
                          .every((v) => v);
                    });
                    _checkAllPermissions();

                    if (source == 'background_listening' &&
                        Platform.isAndroid) {
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) {
                          _showSamsungBatteryGuideSheet();
                        }
                      });
                    }
                  },
            child: Text(
              isGranted ? 'Enabled' : 'Allow',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showSamsungBatteryGuideSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.contextAmber,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Samsung/One UI Exemption',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Samsung devices (like your Galaxy S24 Ultra) enforce extremely aggressive battery management. To prevent the passive listening service from being killed when you swipe the app closed, you must configure MemoryOS as "Unrestricted".',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 Quick Steps:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStepRow('1', 'Tap "Open App Info" below.'),
                    _buildStepRow('2', 'Scroll down and tap "Battery".'),
                    _buildStepRow('3', 'Select "Unrestricted".'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await CaptureService.instance.openBatterySettings();
                      },
                      child: const Text(
                        'Open App Info',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
            ),
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsBanner() {
    if (!_showPermissionsBanner) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Permissions Onboarding Setup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'For everyday context reconstruction, MemoryOS runs strictly offline and needs native device streams. Some permissions are not yet configured.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _openPermissionsGuideSheet,
            icon: const Icon(Icons.settings, size: 16),
            label: const Text(
              'Configure Stream Permissions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openIngestSheet() {
    final TextEditingController contentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ingest Local Memory Node',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type whatever is on your mind. MemoryOS will automatically analyze it and save it locally.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: contentCtrl,
                      maxLines: 4,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Write your memory details...',
                        hintText:
                            'e.g. Discussed NMC solar battery anodes efficiency with brother today...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final content = contentCtrl.text.trim();
                        if (content.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please write some details first.'),
                            ),
                          );
                          return;
                        }

                        // Auto extract title (first 5 words or first 40 chars)
                        final words = content.split(RegExp(r'\s+'));
                        final title = words.length > 5
                            ? '${words.take(5).join(' ')}...'
                            : content;

                        final node = MemoryNode(
                          timestamp: DateTime.now(),
                          title: title,
                          content: content,
                          source: 'document',
                          metadata: {
                            'isManual': true,
                            'characterCount': content.length,
                          },
                          trail: DatabaseService.classifyTrail(title, content),
                        );

                        await DatabaseService.instance.insertNode(node);
                        Navigator.pop(context);
                        _loadNodes();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saved to secure enclave: "$title"'),
                            backgroundColor: AppTheme.contextGreen,
                          ),
                        );
                      },
                      child: const Text(
                        'Save Memory Node',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Voice recording bottom sheet
  void _openRecordingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: _modalPadding(context),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isRecording
                            ? 'Listening Passively'
                            : 'Record Local Voice Note',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRecording
                            ? 'Capturing audio in a hardware-encrypted local enclave'
                            : 'Voice inputs are transcribed on-device and kept strictly offline',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Waveform/Pulse Indicator
                      if (_isRecording)
                        SizedBox(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(12, (index) {
                              // Simple mock dynamic audio bars
                              final isCenter = index > 3 && index < 8;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: 6,
                                height: isCenter ? 50.0 : 25.0,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(
                                    isCenter ? 1.0 : 0.4,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        )
                      else
                        const Icon(
                          Icons.mic_none,
                          size: 64,
                          color: AppTheme.outlineVariant,
                        ),

                      const SizedBox(height: 16),
                      Text(
                        _recordingTime,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (!_isRecording) ...[
                        // Input title before starting
                        TextField(
                          controller: _voiceTitleController,
                          decoration: InputDecoration(
                            labelText: 'Memory Context Title',
                            hintText: 'e.g., Inverter breaker issue',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Start Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () async {
                            final granted = await CaptureService.instance
                                .requestPermission('voice_note');
                            if (granted) {
                              setModalState(() {
                                _isRecording = true;
                                _secondsRecorded = 0;
                                _recordingTime = "00:00";
                              });
                              await CaptureService.instance.startRecording();
                              _startRecordingTimer(setModalState);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Microphone permission required.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic),
                              SizedBox(width: 8),
                              Text('Initialize Enclave Mic'),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Stop & Ingest Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () async {
                            _recordingTimer?.cancel();
                            final title = _voiceTitleController.text.trim();
                            final node = await CaptureService.instance
                                .stopRecording(title);

                            setState(() {
                              _isRecording = false;
                            });
                            _voiceTitleController.clear();
                            Navigator.pop(context);

                            if (node != null) {
                              _loadNodes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Transcribed offline: "${node.title}"',
                                  ),
                                  backgroundColor: AppTheme.contextGreen,
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop),
                              SizedBox(width: 8),
                              Text('Stop & Ingest Memory'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startRecordingTimer(void Function(void Function()) setModalState) {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setModalState(() {
        _secondsRecorded++;
        final minutesStr = (_secondsRecorded ~/ 60).toString().padLeft(2, '0');
        final secondsStr = (_secondsRecorded % 60).toString().padLeft(2, '0');
        _recordingTime = "$minutesStr:$secondsStr";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = List.generate(
      7,
      (index) => DateTime.now().subtract(Duration(days: index)),
    );

    return Stack(
      children: [
        // Main Timeline Feed
        RefreshIndicator(
          onRefresh: _loadNodes,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.only(
              top: 100,
              bottom: 120,
              left: 16,
              right: 16,
            ),
            children: [
              // Sticky Date Header Mock
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(_selectedDate),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.history,
                          size: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SYNCHRONIZED VIA LOCAL NODE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Deleted Memories',
                          onPressed: _openDeletedMemoriesSheet,
                          icon: const Icon(
                            Icons.restore_from_trash,
                            size: 18,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Setup Guide Banner
              _buildPermissionsBanner(),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 64.0),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (_nodes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 48,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No passive recordings gathered for this day.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Timeline List
                Stack(
                  children: [
                    // Vertical Timeline Axis Thread
                    Positioned(
                      left: 19,
                      top: 16,
                      bottom: 16,
                      child: Container(
                        width: 2,
                        color: AppTheme.outlineVariant,
                      ),
                    ),

                    // Render Nodes
                    Column(
                      children: _nodes
                          .map((node) => _buildTimelineItem(node))
                          .toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Floating Horizontal Date Header Slider
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: AppTheme.background.withOpacity(0.9),
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected = DateUtils.isSameDay(date, _selectedDate);

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('E').format(date).toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => _onDateSelected(date),
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.outlineVariant.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // FAB Actions
        Positioned(
          bottom: 24,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Manual Ingest Real Node (Sleek Circle Container)
              GestureDetector(
                onTap: _openIngestSheet,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 10),

              // Global Capture Voice Note (Sleek Circle Container)
              GestureDetector(
                onTap: _openRecordingSheet,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1C132B),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x44503C76),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(MemoryNode node) {
    final theme = Theme.of(context);
    final isActive = _activeNodeId == node.id;
    final timeStr = DateFormat('hh:mm a').format(node.timestamp);

    IconData sourceIcon = Icons.article;
    Color sourceColor = AppTheme.primary;

    switch (node.source) {
      case 'voice_note':
        sourceIcon = Icons.mic;
        sourceColor = AppTheme.primary;
        break;
      case 'location':
        sourceIcon = Icons.gps_fixed;
        sourceColor = AppTheme.contextAmberLight;
        break;
      case 'calendar':
        sourceIcon = Icons.calendar_today;
        sourceColor = AppTheme.primary;
        break;
      case 'notification':
        sourceIcon = Icons.notifications;
        sourceColor = AppTheme.outline;
        break;
      case 'reading':
        sourceIcon = Icons.article;
        sourceColor = AppTheme.primary;
        break;
      case 'share':
        sourceIcon = Icons.share;
        sourceColor = AppTheme.primary;
        break;
      case 'photo':
        sourceIcon = Icons.photo_camera;
        sourceColor = AppTheme.primary;
        break;
    }

    final dismissKey = ValueKey(
      'memory-${node.id ?? node.timestamp.toIso8601String()}',
    );

    return Dismissible(
      key: dismissKey,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _softDeleteNode(node),
      onDismissed: (_) {
        setState(() {
          _nodes.removeWhere((item) => item.id == node.id);
          if (_activeNodeId == node.id) {
            _activeNodeId = null;
          }
        });
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Node Bubble
            GestureDetector(
              onTap: () {
                setState(() {
                  _activeNodeId = node.id;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.outlineVariant,
                    width: isActive ? 3 : 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.15),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  sourceIcon,
                  size: 16,
                  color: isActive
                      ? AppTheme.primary
                      : AppTheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Timeline Content Card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeNodeId = node.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.04),
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isActive
                            ? Colors.black.withOpacity(0.06)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: isActive ? 16 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Top Subtitle
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeStr,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(sourceIcon, size: 16, color: sourceColor),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _openEditNodeSheet(node),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: AppTheme.onSurfaceVariant
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Specific layouts per source
                      _buildCardBody(node),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody(MemoryNode node) {
    final theme = Theme.of(context);
    switch (node.source) {
      case 'notification':
        final packageName =
            node.metadata['packageName'] as String? ?? 'unknown';
        final channelId = node.metadata['channelId'] as String? ?? 'default';

        String appName = 'System';
        String notifTitle = node.title;
        if (node.title.contains(':')) {
          final parts = node.title.split(':');
          appName = parts[0].trim();
          notifTitle = parts.sublist(1).join(':').trim();
        } else {
          appName = node.title;
        }

        IconData appIcon = Icons.notifications_none_outlined;
        Color appColor = AppTheme.primary;
        if (packageName.contains('whatsapp')) {
          appIcon = Icons.chat_bubble_outline;
          appColor = const Color(0xFF25D366);
        } else if (packageName.contains('gmail') ||
            packageName.contains('email')) {
          appIcon = Icons.email_outlined;
          appColor = const Color(0xFFEA4335);
        } else if (packageName.contains('systemui')) {
          appIcon = Icons.android_outlined;
          appColor = const Color(0xFF3DDC84);
        } else if (packageName.contains('facebook') ||
            packageName.contains('messenger')) {
          appIcon = Icons.message_outlined;
          appColor = const Color(0xFF1877F2);
        } else if (packageName.contains('instagram')) {
          appIcon = Icons.camera_alt_outlined;
          appColor = const Color(0xFFE1306C);
        } else if (packageName.contains('slack')) {
          appIcon = Icons.workspaces_outlined;
          appColor = const Color(0xFF4A154B);
        } else if (packageName.contains('teams')) {
          appIcon = Icons.groups_outlined;
          appColor = const Color(0xFF464EB8);
        } else if (packageName.contains('youtube')) {
          appIcon = Icons.play_circle_outline;
          appColor = const Color(0xFFFF0000);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: appColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(appIcon, size: 16, color: appColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            appName,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: appColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (channelId != 'default')
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.onSurfaceVariant.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                channelId.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 7,
                                  color: AppTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notifTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                node.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );

      case 'voice_note':
        final durationText = node.metadata['duration'] ?? '0:00';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Waveform representation
              Row(
                children: [
                  IconButton(
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      (_playingNodeId == node.id && _isPlaying)
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppTheme.primary,
                    ),
                    onPressed: () async {
                      final filePath = node.metadata['filePath'];
                      final isFallback =
                          node.metadata['isFallback'] == true ||
                          filePath == null ||
                          filePath == 'enclave_buffer';

                      if (isFallback) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Audio playback not supported for mock/simulated notes.',
                            ),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                        return;
                      }

                      try {
                        if (_playingNodeId == node.id) {
                          if (_isPlaying) {
                            await _audioPlayer?.pause();
                          } else {
                            await _audioPlayer?.resume();
                          }
                        } else {
                          await _audioPlayer?.stop();
                          setState(() {
                            _playingNodeId = node.id;
                            _isPlaying = true;
                          });
                          await _audioPlayer?.play(DeviceFileSource(filePath));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error playing audio: $e'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(15, (index) {
                          final h = (index % 3 + 1) * 4.0;
                          final isCurrentPlayingNode =
                              _playingNodeId == node.id && _isPlaying;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 2,
                            height: isCurrentPlayingNode ? h * 1.5 : h,
                            decoration: BoxDecoration(
                              color: isCurrentPlayingNode
                                  ? AppTheme.primary
                                  : AppTheme.primary.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(durationText, style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                ),
                child: Text(
                  '"${node.content}"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'location':
        final details = buildLocationDetailRows(node.metadata);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDim,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: details.isEmpty
                  ? Text(
                      'No location metadata available.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: details.map((detail) {
                        return Container(
                          width: 128,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.04),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                detail.value,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );

      case 'share':
        final recipient = node.metadata['recipient'] ?? 'Brother';
        final platform = node.metadata['platform'] ?? 'WhatsApp';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar mockup
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      recipient[0],
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.03),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"${node.content}"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.forum,
                                size: 12,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(platform, style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'photo':
        final fileName = buildScreenshotSummary(node.metadata);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Screenshot file',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          fileName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'reading':
      default:
        final domain = node.metadata['domain'] ?? 'Web Clip';
        final tags = node.metadata['tags'] as List<dynamic>? ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[$domain] ${node.title}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                node.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.05),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
    }
  }
}
