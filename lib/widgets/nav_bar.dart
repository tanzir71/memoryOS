import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app/tokens.dart';

class MemoryNavBar extends StatelessWidget {
  const MemoryNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (label: 'Today', icon: LucideIcons.sun),
    (label: 'Threads', icon: LucideIcons.layers),
    (label: 'People', icon: LucideIcons.users),
    (label: 'Ahead', icon: LucideIcons.clock),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accentSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          tab.icon,
                          size: 20,
                          color: isActive ? AppColors.accent : AppColors.ink2,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s4),
                      Text(
                        tab.label,
                        style: AppType.labelNav.copyWith(
                          color: isActive ? AppColors.accent : AppColors.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
