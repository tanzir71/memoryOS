import 'package:flutter/material.dart';
import '../app/tokens.dart';
import 'glyph.dart';

class RailEntry extends StatelessWidget {
  const RailEntry({
    super.key,
    required this.glyphKind,
    required this.timeLabel,
    required this.title,
    this.subtitle,
    this.body,
    this.showRail = true,
    this.onTap,
  });

  final GlyphKind glyphKind;
  final String timeLabel;
  final String title;
  final String? subtitle;
  final Widget? body;
  final bool showRail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.inset),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Glyph(kind: glyphKind),
                  if (showRail)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: AppSpace.s4),
                        color: AppColors.line,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: showRail ? AppSpace.s20 : AppSpace.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: AppType.labelSm.copyWith(color: AppColors.ink3),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    if (title.isNotEmpty) Text(title, style: AppType.titleSm),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpace.s4),
                      Text(subtitle!, style: AppType.bodySm),
                    ],
                    if (body != null) ...[
                      const SizedBox(height: AppSpace.s8),
                      body!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
