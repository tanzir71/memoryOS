import 'package:flutter/material.dart';
import '../app/tokens.dart';

enum IntentKind { asksYou, youSaid, plan, confirms, fyi }

enum CertaintyKind { stated, learned, guess }

class IntentTag extends StatelessWidget {
  const IntentTag({super.key, required this.kind});

  final IntentKind kind;

  (String, Color) get _spec => switch (kind) {
    IntentKind.asksYou => ('Asks you', AppColors.attention),
    IntentKind.youSaid => ('You said', AppColors.accent),
    IntentKind.plan => ('Plan', AppColors.ink2),
    IntentKind.confirms => ('Confirms', AppColors.positive),
    IntentKind.fyi => ('FYI', AppColors.ink3),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _spec;
    return _DotTag(label: label, color: color);
  }
}

class CertaintyTag extends StatelessWidget {
  const CertaintyTag({super.key, required this.kind});

  final CertaintyKind kind;

  (String, Color) get _spec => switch (kind) {
    CertaintyKind.stated => ('Stated', AppColors.positive),
    CertaintyKind.learned => ('Learned', AppColors.accent),
    CertaintyKind.guess => ('Guess', AppColors.ink3),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _spec;
    return _DotTag(label: label, color: color);
  }
}

class _DotTag extends StatelessWidget {
  const _DotTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpace.s6),
        Text(label, style: AppType.labelSm.copyWith(color: color)),
      ],
    );
  }
}
