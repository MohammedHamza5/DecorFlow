import 'package:flutter/material.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../app/theme/app_colors.dart';

/// Horizontal selector for calculation modes.
class CalcModeSelector extends StatelessWidget {
  final CalcMode selectedMode;
  final ValueChanged<CalcMode> onModeChanged;

  const CalcModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  static const _modes = [
    CalcMode.rod,
    CalcMode.panel,
    CalcMode.linearMeter,
    CalcMode.squareMeter,
  ];

  static const _icons = {
    CalcMode.rod: Icons.view_column_outlined,
    CalcMode.panel: Icons.grid_view_outlined,
    CalcMode.linearMeter: Icons.straighten_outlined,
    CalcMode.squareMeter: Icons.crop_square_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _modes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mode = _modes[index];
          final isSelected = mode == selectedMode;
          return _ModeChip(
            label: mode.shortName,
            icon: _icons[mode] ?? Icons.calculate,
            isSelected: isSelected,
            onTap: () => onModeChanged(mode),
          );
        },
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
