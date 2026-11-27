import 'package:flutter/material.dart';
import '../app/tokens.dart';

class CapturePill extends StatelessWidget {
  const CapturePill({
    super.key,
    required this.isCapturing,
    this.pausedUntilLabel,
    this.onTap,
  });

  final bool isCapturing;
  final String? pausedUntilLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dotColor = isCapturing ? AppColors.positive : AppColors.attention;
    final label = isCapturing
        ? 'Capturing'
        : 'Paused until ${pausedUntilLabel ?? 'later'}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s12,
            vertical: AppSpace.s6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpace.s8),
              Text(
                label,
                style: AppType.labelSm.copyWith(color: AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
