import 'package:flutter/material.dart';
import '../app/tokens.dart';

enum DecisionChoice { show, quiet, drop }

class DecisionControl extends StatelessWidget {
  const DecisionControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DecisionChoice? selected;
  final ValueChanged<DecisionChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Show',
            isSelected: selected == DecisionChoice.show,
            onTap: () => onChanged(DecisionChoice.show),
          ),
          _Segment(
            label: 'Track quietly',
            isSelected: selected == DecisionChoice.quiet,
            onTap: () => onChanged(DecisionChoice.quiet),
          ),
          _Segment(
            label: 'Drop',
            isSelected: selected == DecisionChoice.drop,
            onTap: () => onChanged(DecisionChoice.drop),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s12,
          vertical: AppSpace.s6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppType.labelSm.copyWith(
            color: isSelected ? AppColors.accent : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
