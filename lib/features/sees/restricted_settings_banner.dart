import 'package:flutter/material.dart';
import '../../app/tokens.dart';
import '../../widgets/app_button.dart';

/// Shown when Android blocks Notification Access (Android 13+) or SMS
/// permission (Android 15+) on sideloaded APKs until "Allow restricted
/// settings" is turned on in App info.
class RestrictedSettingsBanner extends StatelessWidget {
  const RestrictedSettingsBanner({
    super.key,
    required this.permissionLabel,
    required this.onOpenAppInfo,
  });

  final String permissionLabel;
  final VoidCallback onOpenAppInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.attentionSoft,
        borderRadius: BorderRadius.circular(AppRadius.inset),
        border: Border.all(color: AppColors.attention.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Android blocked $permissionLabel',
            style: AppType.titleSm.copyWith(color: AppColors.attention),
          ),
          const SizedBox(height: AppSpace.s6),
          Text(
            'Because MemoryOS was installed directly from an APK, open App info, tap the menu in the top corner, and choose "Allow restricted settings". Then come back and allow $permissionLabel.',
            style: AppType.bodySm.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpace.s12),
          AppButton(
            label: 'Open app info',
            variant: AppButtonVariant.quiet,
            onPressed: onOpenAppInfo,
          ),
        ],
      ),
    );
  }
}
