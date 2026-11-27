import 'dart:async';
import 'package:flutter/material.dart';
import '../services/capture_service.dart';
import '../theme/app_theme.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  bool _isBatteryOptimized = false;

  final List<Map<String, dynamic>> _sourceDefinitions = const [
    {
      'key': 'voice_note',
      'title': 'Voice notes',
      'subtitle': 'Recorded inside the app (audio only, no transcript)',
      'icon': Icons.mic,
    },
    {
      'key': 'notification',
      'title': 'Notifications',
      'subtitle': 'Incoming app notifications via Android notification access',
      'icon': Icons.notifications,
    },
    {
      'key': 'bluetooth',
      'title': 'Bluetooth devices',
      'subtitle': 'Connected and disconnected Bluetooth devices',
      'icon': Icons.bluetooth,
    },
    {
      'key': 'location',
      'title': 'Location',
      'subtitle': 'Periodic device coordinates (every 4 hours)',
      'icon': Icons.location_on,
    },
    {
      'key': 'photo',
      'title': 'Screenshots',
      'subtitle': 'Screenshot filenames saved on device',
      'icon': Icons.photo_library,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkBatteryStatus();
  }

  Future<void> _checkBatteryStatus() async {
    final ignored = await CaptureService.instance
        .isIgnoringBatteryOptimizations();
    if (mounted && _isBatteryOptimized == ignored) {
      setState(() {
        _isBatteryOptimized = !ignored;
      });
    }
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

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      children: [
        Text(
          'Sources',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose what MemoryOS reads on this phone. Everything stays in a local SQLite database on this device.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (_isBatteryOptimized) ...[
          _buildBatteryOptimizationCard(theme),
          const SizedBox(height: 16),
        ],
        ..._sourceDefinitions.map((source) {
          final String key = source['key'] as String;
          final bool isEnabled = CaptureService.instance.isSourceEnabled(key);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? AppTheme.primary.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppTheme.primary.withValues(alpha: 0.08)
                        : AppTheme.surfaceDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    source['icon'] as IconData,
                    size: 18,
                    color: isEnabled
                        ? AppTheme.primary
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        source['subtitle'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  activeTrackColor: AppTheme.primary,
                  onChanged: (val) => _handleToggle(key, val),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Text(
          'Stored on this phone only. Nothing is uploaded.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
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
          color: AppTheme.contextAmber.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.contextAmber,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Battery exemption recommended',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Android battery optimization can stop background capture when the app is swiped away. Set MemoryOS to Unrestricted.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.contextAmber,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () async {
                  await CaptureService.instance.openBatterySettings();
                  await _checkBatteryStatus();
                },
                icon: const Icon(Icons.battery_saver, size: 16),
                label: const Text('Allow unrestricted'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _showSamsungBatteryGuideSheet,
                child: const Text('Samsung guide'),
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
              Text(
                'Samsung battery settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Samsung phones stop background apps aggressively. Set MemoryOS to Unrestricted so capture keeps running.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text('1. Tap "Open app info" below.'),
              const SizedBox(height: 6),
              const Text('2. Scroll down and tap "Battery".'),
              const SizedBox(height: 6),
              const Text('3. Select "Unrestricted".'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await CaptureService.instance.openBatterySettings();
                      },
                      child: const Text('Open app info'),
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
}
