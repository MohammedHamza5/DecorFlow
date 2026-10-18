import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../engines/calculation/models/calc_output.dart';
import '../../../../engines/pricing/models/price_models.dart';
import '../../../../core/extensions/number_extensions.dart';

/// Result card displaying calculation and pricing results.
///
/// Shows large, clear numbers suitable for shop floor conditions.
class ResultCard extends StatelessWidget {
  final CalcOutput output;
  final PriceOutput priceOutput;

  const ResultCard({
    super.key,
    required this.output,
    this.priceOutput = PriceOutput.empty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.calcResult.withValues(alpha: 0.15),
            AppColors.calcResultBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.calcResult.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.calcResult.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main Result
            _buildMainResult(context),
            const SizedBox(height: 16),
            Divider(color: AppColors.calcResult.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            // Details
            _buildDetails(context),
            // Pricing
            if (priceOutput.finalTotal > 0) ...[
              const SizedBox(height: 16),
              Divider(color: AppColors.calcResult.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              _buildPricing(context),
            ],
            // Warnings
            if (output.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...output.warnings.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            w,
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // Visual Cutting Plan for Optimized Rods
            if (output.rodCuts.isNotEmpty) _buildVisualCuttingPlan(context),
            // Calculation Steps (expandable)
            if (output.calculationSteps.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSteps(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisualCuttingPlan(BuildContext context) {
    final efficiency = output.optimizationEfficiency ?? 0.0;

    // Group identical plans
    final groups = <String, List<int>>{};
    for (int i = 0; i < output.rodCuts.length; i++) {
      final cuts = output.rodCuts[i];
      final key = cuts.map((c) => c.toStringAsFixed(3)).join(',');
      groups.putIfAbsent(key, () => []).add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Divider(color: AppColors.calcResult.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'مخطط تقطيع الأعواد الموفر',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'كفاءة المادة: ${(efficiency * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...groups.entries.map((entry) {
          final indices = entry.value;
          final firstIndex = indices.first;
          final cuts = output.rodCuts[firstIndex];
          final totalCuts = cuts.fold(0.0, (sum, c) => sum + c);

          double leftover = 0.0;
          if (firstIndex < output.cuttingInstructions.length) {
            final instruction = output.cuttingInstructions[firstIndex];
            final match = RegExp(
              r'المتبقي:\s*([\d\.]+)',
            ).firstMatch(instruction);
            if (match != null) {
              leftover = double.tryParse(match.group(1) ?? '0') ?? 0.0;
            }
          }
          final rawLength = totalCuts + leftover;

          final isUncut = cuts.length == 1 && leftover < 0.02;
          final title = indices.length == 1
              ? 'العود ${firstIndex + 1} (${(rawLength * 100).toStringAsFixed(0)} سم)'
              : 'عدد ${indices.length} أعواد - ${isUncut ? "كاملة بدون تقطيع" : "تقطيع متطابق"} (${(rawLength * 100).toStringAsFixed(0)} سم)';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.border, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: indices.length > 1
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 24,
                      color: AppColors.divider,
                      child: Row(
                        children: [
                          ...cuts.map((cut) {
                            final pct = cut / rawLength;
                            return Expanded(
                              flex: (pct * 1000).round(),
                              child: Container(
                                margin: const EdgeInsets.only(right: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${(cut * 100).toStringAsFixed(0)}سم',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (leftover > 0.01)
                            Expanded(
                              flex: (leftover / rawLength * 1000).round(),
                              child: Container(
                                color: Colors.grey.withValues(alpha: 0.3),
                                child: Center(
                                  child: Text(
                                    'هالك: ${(leftover * 100).toStringAsFixed(0)}سم',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 9,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMainResult(BuildContext context) {
    final isLinearMeter = output.unitLabel == 'م.ط' || output.unitLabel == 'م';
    final numberText = isLinearMeter
        ? (output.quantityWithWaste * 100).toStringAsFixed(0)
        : '${output.unitsNeeded}';
    final labelText = isLinearMeter ? 'سم' : output.unitLabel;

    return Column(
      children: [
        Text(
          'الكمية المطلوبة',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.calcResult),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              numberText,
              style: AppTypography.calcResultLarge.copyWith(
                color: AppColors.calcResult,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: AppTypography.calcResultMedium.copyWith(
                color: AppColors.calcResult.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final isDiscrete =
        output.unitLabel.contains('عود') ||
        output.unitLabel.contains('لوح') ||
        output.unitLabel.contains('كرتونة') ||
        output.unitLabel.contains('قطعة');

    final isLinearMeter = output.unitLabel == 'م.ط' || output.unitLabel == 'م';

    final baseStr = isDiscrete
        ? '${output.baseQuantity.round()} ${output.unitLabel.split(' ')[0]}'
        : isLinearMeter
        ? '${(output.baseQuantity * 100).toStringAsFixed(0)} سم'
        : '${output.baseQuantity.toCompact()} ${output.unitLabel}';

    final wasteStr = isDiscrete
        ? '+${output.wasteQuantity.round()} ${output.unitLabel.split(' ')[0]}'
        : isLinearMeter
        ? '+${(output.wasteQuantity * 100).toStringAsFixed(0)} سم'
        : '+${output.wasteQuantity.toCompact()} ${output.unitLabel}';

    final totalStr = isDiscrete
        ? '${output.unitsNeeded} ${output.unitLabel.split(' ')[0]}'
        : isLinearMeter
        ? '${(output.quantityWithWaste * 100).toStringAsFixed(0)} سم'
        : '${output.quantityWithWaste.toCompact()} ${output.unitLabel}';

    return Column(
      children: [
        _detailRow(
          'العدد الفعلي (قبل الهالك)',
          baseStr,
          Icons.straighten_outlined,
        ),
        _detailRow(
          'نسبة الهالك (${(output.wastePercent * 100).toStringAsFixed(0)}%)',
          wasteStr,
          Icons.recycling_outlined,
          valueColor: AppColors.calcWaste,
        ),
        _detailRow(
          'العدد الإجمالي (شامل الهالك)',
          totalStr,
          Icons.assignment_turned_in_outlined,
          valueColor: AppColors.calcResult,
        ),
        if (output.openingsArea > 0)
          _detailRow(
            'خصم الفتحات',
            '-${output.openingsArea.toCompact()} م²',
            Icons.door_front_door_outlined,
          ),
      ],
    );
  }

  Widget _buildPricing(BuildContext context) {
    return Column(
      children: [
        if (priceOutput.totalDiscount > 0) ...[
          _detailRow(
            'قبل الخصم',
            priceOutput.totalBeforeDiscount.toCurrency(),
            Icons.sell_outlined,
            isStrikethrough: true,
          ),
          _detailRow(
            'الخصم',
            '-${priceOutput.totalDiscount.toCurrency()}',
            Icons.discount_outlined,
            valueColor: AppColors.success,
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.calcResult.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: AppTypography.priceStyle.copyWith(
                  color: AppColors.calcResult,
                ),
              ),
              Text(
                priceOutput.finalTotal.toCurrency(),
                style: AppTypography.priceStyle.copyWith(
                  color: AppColors.calcResult,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    bool isStrikethrough = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? AppColors.textPrimary,
              decoration: isStrikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'تفاصيل الحساب',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      children: output.calculationSteps
          .map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
