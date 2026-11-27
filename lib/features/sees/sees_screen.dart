import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app/providers.dart';
import '../../app/tokens.dart';
import '../../capture/capture_api.g.dart';
import '../../capture/history_importer.dart';
import '../../engine/rules_loader.dart';
import '../../engine/unparsed_exporter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/capture_pill.dart';
import 'restricted_settings_banner.dart';

class SeesScreen extends ConsumerStatefulWidget {
  const SeesScreen({super.key});

  @override
  ConsumerState<SeesScreen> createState() => _SeesScreenState();
}

class _SeesScreenState extends ConsumerState<SeesScreen> {
  final _hostApi = CaptureHostApi();
  final Map<String, bool> _enabled = {
    'calls': false,
    'sms': false,
    'messages': false,
    'email': false,
    'meetings': false,
    'orders': false,
    'places': false,
  };
  String? _restrictedBlockedLabel;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadStatus);
  }

  Future<void> _loadStatus() async {
    final db = ref.read(databaseProvider);
    for (final key in _enabled.keys) {
      final val = await db.getSetting('source_$key');
      if (val != null && mounted) {
        setState(() => _enabled[key] = val == 'true');
      }
    }
    if (!Platform.isAndroid) return;
    try {
      final snap = await _hostApi.checkPermissions();
      if (!mounted) return;
      setState(() {
        _enabled['calls'] = snap.callLog;
        _enabled['sms'] = snap.sms;
        _enabled['messages'] = snap.notificationAccess;
        _enabled['email'] = snap.notificationAccess;
        _enabled['meetings'] = snap.calendar;
        _enabled['orders'] = snap.notificationAccess || snap.sms;
      });
    } catch (_) {}
  }

  Future<void> _toggleSource(String key, bool next) async {
    final db = ref.read(databaseProvider);
    if (next && Platform.isAndroid) {
      if (key == 'messages' || key == 'email' || key == 'orders') {
        final snap = await _hostApi.checkPermissions();
        if (!snap.notificationAccess) {
          await _hostApi.openNotificationListenerSettings();
          final after = await _hostApi.checkPermissions();
          if (!after.notificationAccess) {
            setState(() => _restrictedBlockedLabel = 'Notification access');
            return;
          }
        }
      } else if (key == 'sms') {
        final status = await Permission.sms.request();
        if (!status.isGranted) {
          setState(() => _restrictedBlockedLabel = 'SMS permission');
          return;
        }
      } else if (key == 'calls') {
        final status = await Permission.phone.request();
        if (!status.isGranted) return;
      } else if (key == 'meetings') {
        final status = await Permission.calendarFullAccess.request();
        if (!status.isGranted) return;
      }
    }

    setState(() {
      _enabled[key] = next;
      _restrictedBlockedLabel = null;
    });
    await db.setSetting('source_$key', next.toString());
    if (Platform.isAndroid) {
      try {
        await _hostApi.setSourceEnabled(key, next);
      } catch (_) {}
    }
  }

  Future<void> _togglePause() async {
    final db = ref.read(databaseProvider);
    final pausedUntil = ref.read(pausedUntilProvider).asData?.value;
    final nextEpoch = pausedUntil == null
        ? DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch
        : 0;
    await db.setSetting('capture_paused_until', nextEpoch.toString());
    if (Platform.isAndroid) {
      try {
        await _hostApi.setCapturePausedUntil(nextEpoch);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final pausedUntil = ref.watch(pausedUntilProvider).asData?.value;
    final sources = const [
      (
        key: 'calls',
        title: 'Calls',
        reads: 'Call log times, length and WhatsApp call alerts.',
        notRead: 'Never records or listens to calls.',
      ),
      (
        key: 'sms',
        title: 'Text messages (SMS)',
        reads: 'Stored SMS inbox for bills, recharges and personal texts.',
        notRead: 'One-time codes are never kept.',
      ),
      (
        key: 'messages',
        title: 'Messages',
        reads: 'Chat notifications from apps you choose.',
        notRead: 'Never opens chat apps or reads inside them.',
      ),
      (
        key: 'email',
        title: 'Email',
        reads: 'Sender, subject and first lines from email notifications.',
        notRead: 'Never reads your mailbox or attachments.',
      ),
      (
        key: 'meetings',
        title: 'Meetings',
        reads: 'Calendar events, guests and overlapping Meet or Zoom alerts.',
        notRead: 'Never edits or creates calendar events.',
      ),
      (
        key: 'orders',
        title: 'Orders and payments',
        reads: 'Order, courier and payment alerts from SMS and notifications.',
        notRead: 'Never reads PINs, passwords or banking apps directly.',
      ),
      (
        key: 'places',
        title: 'Places',
        reads: 'Off by default. Planned for a later update.',
        notRead: 'No location permission is requested while off.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('What MemoryOS sees', style: AppType.titleMd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screenHorizontal,
          AppSpace.s12,
          AppSpace.screenHorizontal,
          AppSpace.s40,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                CapturePill(isCapturing: pausedUntil == null),
                const Spacer(),
                AppButton(
                  label: pausedUntil == null ? 'Pause 1 hour' : 'Resume',
                  variant: AppButtonVariant.quiet,
                  onPressed: _togglePause,
                ),
              ],
            ),
          ),
          if (_restrictedBlockedLabel != null) ...[
            const SizedBox(height: AppSpace.s16),
            RestrictedSettingsBanner(
              permissionLabel: _restrictedBlockedLabel!,
              onOpenAppInfo: () {
                if (Platform.isAndroid) {
                  _hostApi.openAppInfoSettings();
                }
              },
            ),
          ],
          const SizedBox(height: AppSpace.s16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: List.generate(sources.length, (index) {
                final s = sources[index];
                final isLast = index == sources.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpace.cardPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title, style: AppType.titleSm),
                                const SizedBox(height: AppSpace.s4),
                                Text(s.reads, style: AppType.bodySm),
                                const SizedBox(height: AppSpace.s2),
                                Text(
                                  s.notRead,
                                  style: AppType.bodySm.copyWith(
                                    color: AppColors.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpace.s12),
                          AppSwitch(
                            value: _enabled[s.key] ?? false,
                            onChanged: s.key == 'places'
                                ? null
                                : (val) => _toggleSource(s.key, val),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          AppButton(
            label: 'Import history already on phone',
            variant: AppButtonVariant.quiet,
            expand: true,
            onPressed: () async {
              await HistoryImportCoordinator.scheduleBackgroundHistoryImport();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History import scheduled in background.'),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpace.s10),
          AppButton(
            label: 'Export unparsed samples',
            variant: AppButtonVariant.quiet,
            expand: true,
            onPressed: () async {
              final rules = await EngineRules.loadFromAssets();
              final res = await exportUnparsedTransactionalSamples(
                db: ref.read(databaseProvider),
                rules: rules,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported ${res.sampleCount} unparsed samples to ${res.filePath}',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpace.s20),
          Text(
            'Stored on this phone only. Nothing is uploaded.',
            style: AppType.bodySm.copyWith(color: AppColors.ink3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
