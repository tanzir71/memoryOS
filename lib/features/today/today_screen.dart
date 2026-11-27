import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/providers.dart';
import '../../app/tokens.dart';
import '../../data/database.dart';
import '../../widgets/capture_pill.dart';
import '../../widgets/glyph.dart';
import '../../widgets/rail_entry.dart';
import '../../widgets/section_header.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalsAsync = ref.watch(keptSignalsProvider);
    final pausedUntil = ref.watch(pausedUntilProvider).asData?.value;
    final dateLabel = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.screenHorizontal,
              AppSpace.s12,
              AppSpace.screenHorizontal,
              AppSpace.s32,
            ),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    CapturePill(
                      isCapturing: pausedUntil == null,
                      pausedUntilLabel: pausedUntil == null
                          ? null
                          : DateFormat('h:mm a')
                              .format(pausedUntil)
                              .toLowerCase(),
                      onTap: () => context.push('/sees'),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push('/sees'),
                      icon: const Icon(
                        LucideIcons.slidersHorizontal,
                        size: 20,
                        color: AppColors.ink,
                      ),
                      tooltip: 'What MemoryOS sees',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s20),
                Text(
                  dateLabel,
                  style: AppType.bodySm.copyWith(color: AppColors.ink3),
                ),
                const SizedBox(height: AppSpace.s6),
                Text(
                  signalsAsync.asData?.value.isNotEmpty == true
                      ? 'Today so far.'
                      : 'Nothing worth keeping yet today',
                  style: AppType.displayDay,
                ),
                const SizedBox(height: AppSpace.s24),
                signalsAsync.when(
                  data: (signals) {
                    if (signals.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSpace.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          'Kept signals will appear here as MemoryOS reads notifications, messages, calls and calendar events on this phone.',
                          style: AppType.bodySm,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'How the day went',
                          trailing: '${signals.length}',
                        ),
                        const SizedBox(height: AppSpace.s14),
                        ...List.generate(signals.length, (index) {
                          final s = signals[index];
                          return RailEntry(
                            glyphKind: _glyphForSignal(s),
                            timeLabel: DateFormat('h:mm a')
                                .format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    s.occurredAt,
                                  ),
                                )
                                .toLowerCase(),
                            title: s.title.isNotEmpty ? s.title : s.source,
                            subtitle: s.body.isNotEmpty ? s.body : null,
                            showRail: index < signals.length - 1,
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpace.s32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Text('Error: $err', style: AppType.bodySm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  GlyphKind _glyphForSignal(SignalRow row) => switch (row.source) {
    'call' => GlyphKind.call,
    'sms' => GlyphKind.message,
    'calendar' => GlyphKind.meeting,
    'voice' => GlyphKind.voice,
    'note' => GlyphKind.note,
    _ => GlyphKind.message,
  };
}
