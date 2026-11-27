import 'package:flutter/material.dart';
import '../app/tokens.dart';

enum AppButtonVariant { primary, quiet, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.accent,
      AppButtonVariant.quiet => AppColors.surface,
      AppButtonVariant.text => Colors.transparent,
    };

    final foregroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.onAccent,
      AppButtonVariant.quiet => AppColors.ink,
      AppButtonVariant.text => AppColors.accent,
    };

    final border = switch (variant) {
      AppButtonVariant.quiet => Border.all(color: AppColors.lineStrong),
      _ => null,
    };

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: onPressed == null
                ? backgroundColor.withValues(alpha: 0.5)
                : backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: border,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppType.labelMd.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
