import 'package:flutter/material.dart';
import '../app/tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppType.titleSm),
        if (trailing != null)
          Text(
            trailing!,
            style: AppType.bodySm.copyWith(color: AppColors.ink3),
          ),
      ],
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
        child: row,
      ),
    );
  }
}
