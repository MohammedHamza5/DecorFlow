import 'package:flutter/material.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/engines/calculation/models/calc_output.dart';

/// Card showing auto-calculated accessories with toggle for optional ones.
class AccessoriesCard extends StatelessWidget {
  final List<AccessoryCalcResult> accessories;
  final void Function(int index, bool enabled) onToggle;

  const AccessoriesCard({
    super.key,
    required this.accessories,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (accessories.isEmpty) return const SizedBox.shrink();

    final required = accessories.where((a) => !a.isOptional).toList();
    final optional = accessories.where((a) => a.isOptional).toList();

    final totalCost = accessories
        .where((a) => a.isEnabled)
        .fold(0.0, (sum, a) => sum + a.lineTotal);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.build_circle_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('الإكسسوارات والمستلزمات',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                if (totalCost > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${totalCost.toStringAsFixed(0)} ج.م',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border.withValues(alpha: 0.5)),
            const SizedBox(height: 8),

            // Required accessories
            if (required.isNotEmpty) ...[
              _buildSectionHeader(context, 'إجبارية', Icons.check_circle,
                  AppColors.success),
              const SizedBox(height: 8),
              ...required.asMap().entries.map(
                    (entry) => _buildAccessoryTile(
                      context,
                      entry.value,
                      accessories.indexOf(entry.value),
                    ),
                  ),
            ],

            // Optional accessories
            if (optional.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'اختيارية',
                  Icons.add_circle_outline, AppColors.warning),
              const SizedBox(height: 8),
              ...optional.asMap().entries.map(
                    (entry) => _buildAccessoryTile(
                      context,
                      entry.value,
                      accessories.indexOf(entry.value),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessoryTile(
      BuildContext context, AccessoryCalcResult acc, int globalIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Toggle for optional
          if (acc.isOptional)
            SizedBox(
              width: 36,
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: acc.isEnabled,
                  onChanged: (v) => onToggle(globalIndex, v),
                  activeColor: AppColors.primary,
                ),
              ),
            )
          else
            const SizedBox(width: 36),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: acc.isEnabled
                        ? null
                        : AppColors.textTertiary,
                    decoration:
                        acc.isEnabled ? null : TextDecoration.lineThrough,
                  ),
                ),
                if (acc.explanation.isNotEmpty)
                  Text(
                    acc.explanation,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),

          // Quantity
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${acc.quantity.toStringAsFixed(acc.quantity == acc.quantity.roundToDouble() ? 0 : 1)} ${acc.unitLabel}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: acc.isEnabled ? null : AppColors.textTertiary,
              ),
            ),
          ),

          // Price
          if (acc.unitPrice > 0) ...[
            const SizedBox(width: 8),
            Text(
              '${acc.lineTotal.toStringAsFixed(0)} ج.م',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: acc.isEnabled
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
