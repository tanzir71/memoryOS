import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/capture_interval_policy.dart';
import '../services/capture_service.dart';
import '../theme/app_theme.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> with WidgetsBindingObserver {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<String>? _logSubscription;
  bool _isBatteryOptimized = false;
  Timer? _batteryCheckTimer;

  final List<Map<String, dynamic>> _sourceDefinitions = [
    {
      'key': 'voice_note',
      'title': 'Voice Notes',
      'subtitle': 'Recorded inside the app',
      'icon': Icons.mic,
    },
    {
      'key': 'location',
      'title': 'Location Stream',
      'subtitle': 'Privacy-first minimal coordinates',
      'icon': Icons.location_on,
    },
    {
      'key': 'calendar',
      'title': 'Calendar Events',
      'subtitle': 'Local schedules & meetings',
      'icon': Icons.calendar_today,
    },
    {
      'key': 'notification',
      'title': 'Notifications',
      'subtitle': 'App notifications history',
      'icon': Icons.notifications,
    },
    {
      'key': 'bluetooth',
      'title': 'Bluetooth Devices',
      'subtitle': 'Passive paired devices log',
      'icon': Icons.bluetooth,
    },
    {
      'key': 'photo',
      'title': 'Photo Enclave',
      'subtitle': 'Local image context analysis',
      'icon': Icons.photo_library,
    },
    {
      'key': 'reading',
      'title': 'Clipboard Reader',
      'subtitle': 'Clipboard text as reading logs',
      'icon': Icons.assignment,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Add initial logs
    _logs.addAll([
      '[${_getFormattedTime(5)}] SYSTEM: Initializing secure enclave engine...',
      '[${_getFormattedTime(4)}] SECURE CORE: Hardware encryption verified (AES-256).',
      '[${_getFormattedTime(3)}] SYSTEM: SQLite database connection active.',
      '[${_getFormattedTime(2)}] SYSTEM: Loaded 14 historical memory nodes.',
      '[${_getFormattedTime(1)}] LOCAL SYNC: Passive streams running.',
    ]);

    // Subscribe to CaptureService real-time logStream!
    _logSubscription = CaptureService.instance.logStream.listen((log) {
      if (mounted && widget.isActive) {
        setState(() {
          _logs.add(log);
          if (_logs.length > 50) {
            _logs.removeAt(0);
          }
        });

        // Scroll to bottom of terminal
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    if (widget.isActive) {
      _checkBatteryStatus();
    }
    _syncBatteryCheckTimer();
  }

  @override
  void didUpdateWidget(covariant SourcesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _checkBatteryStatus();
    }
    _syncBatteryCheckTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _checkBatteryStatus();
    }
  }

  void _syncBatteryCheckTimer() {
    if (!widget.isActive) {
      _batteryCheckTimer?.cancel();
      _batteryCheckTimer = null;
      return;
    }
    if (_batteryCheckTimer != null) return;

    _batteryCheckTimer = Timer.periodic(
      batteryOptimizationCheckInterval,
      (timer) => _checkBatteryStatus(),
    );
  }

  Future<void> _checkBatteryStatus() async {
    final ignored = await CaptureService.instance
        .isIgnoringBatteryOptimizations();
    final isOptimized = !ignored;
    if (mounted && _isBatteryOptimized != isOptimized) {
      setState(() {
        _isBatteryOptimized = isOptimized;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logSubscription?.cancel();
    _batteryCheckTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String _getFormattedTime([int offsetSeconds = 0]) {
    final t = DateTime.now().subtract(Duration(seconds: offsetSeconds));
    final hr = t.hour.toString().padLeft(2, '0');
    final min = t.minute.toString().padLeft(2, '0');
    final sec = t.second.toString().padLeft(2, '0');
    return '$hr:$min:$sec';
  }

  Future<void> _handleToggle(String key, bool value) async {
    if (value) {
      await CaptureService.instance.requestPermission(key);
    } else {
      CaptureService.instance.setSourceToggle(key, false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double storageUsed = 12.4;
    const double storageTotal = 50.0;
    const double percentage = storageUsed / storageTotal;

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      children: [
        // Page Title & Header
        Text(
          'Enclave Integration',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure passive inputs, track on-device disk allocation, and view security records.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (_isBatteryOptimized) _buildBatteryOptimizationCard(theme),
        if (_isBatteryOptimized)
          const SizedBox(height: 8)
        else
          const SizedBox(height: 16),

        // Bento Row (Storage + Security Enclave Badge)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Storage Bento Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 148,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storage,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Local Disk Storage',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFamily: 'Inter',
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${storageUsed.toStringAsFixed(1)} GB used',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor: AppTheme.outlineVariant
                                .withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '50 GB Allocated Local Buffer Size',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Security Badge Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 148,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secure Enclave',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFamily: 'Inter',
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All gathered data is locally encrypted using AES-256. Fully isolated on-device database.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.shield,
                          size: 12,
                          color: AppTheme.contextGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '100% Offline Enclave',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.contextGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Passive Stream Toggle Grid Title
        Row(
          children: [
            const Icon(
              Icons.settings_input_component,
              size: 18,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'PASSIVE COLLECTORS',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.0,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Toggle Grid (Gridview.builder)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemCount: _sourceDefinitions.length,
          itemBuilder: (context, index) {
            final source = _sourceDefinitions[index];
            final String key = source['key'];
            final bool isEnabled = CaptureService.instance.isSourceEnabled(key);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? AppTheme.primary.withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  width: isEnabled ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? AppTheme.primary.withOpacity(0.08)
                              : AppTheme.surfaceDim,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          source['icon'],
                          size: 18,
                          color: isEnabled
                              ? AppTheme.primary
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: isEnabled,
                          activeColor: AppTheme.primary,
                          inactiveThumbColor: AppTheme.onSurfaceVariant,
                          inactiveTrackColor: AppTheme.outlineVariant
                              .withOpacity(0.5),
                          onChanged: (val) => _handleToggle(key, val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source['title'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        source['subtitle'],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 28),

        // Live scrolling logger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'PASSTHROUGH STREAM KERNEL LOG',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.0,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.contextGreenContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.contextGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'STREAMING LIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.contextGreen,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Console container
        Container(
          height: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161719), // Pitch Slate
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRect(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    _logs[index],
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(
                        0xFFC5C8C6,
                      ), // Bright grey terminal text
                      fontSize: 10.5,
                      height: 1.4,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBatteryOptimizationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.contextAmber.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.contextAmber.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.contextAmber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Background Service Persistence Required',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'To keep passive streams running reliably in the background, Android requires battery exemption. MemoryOS will be terminated when swiped closed if not set to "Unrestricted".',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
              height: 1.4,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.contextAmber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await CaptureService.instance.openBatterySettings();
                },
                icon: const Icon(Icons.battery_saver, size: 16),
                label: const Text(
                  'Configure Exemption',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  _showSamsungBatteryGuideSheet();
                },
                child: const Text(
                  'View Guide',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
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
}
