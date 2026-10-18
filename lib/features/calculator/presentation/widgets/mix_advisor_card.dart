import 'package:flutter/material.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/engines/advisor/models/mix_models.dart';

/// Card showing smart mix proposals to save cost.
class MixAdvisorCard extends StatelessWidget {
  final List<MixProposal> proposals;
  final VoidCallback? onViewDetails;

  const MixAdvisorCard({
    super.key,
    required this.proposals,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) return const SizedBox.shrink();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withValues(alpha: 0.1),
                  AppColors.success.withValues(alpha: 0.05),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb_rounded,
                      color: AppColors.warning, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اقتراحات ذكية لتوفير التكلفة',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                      ),
                      Text(
                        'مزيج مواد مختلفة = ديزاين أفضل + سعر أقل',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Proposals
          ...proposals.take(3).map(
                (proposal) => _buildProposalTile(context, proposal),
              ),
        ],
      ),
    );
  }

  Widget _buildProposalTile(BuildContext context, MixProposal proposal) {
    return InkWell(
      onTap: onViewDetails,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Savings badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'وفّر',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '${proposal.savingsPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proposal.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proposal.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildCostChip(
                        'الأصلي',
                        '${proposal.originalCost.toStringAsFixed(0)} ج.م',
                        AppColors.error.withValues(alpha: 0.1),
                        AppColors.error,
                        lineThrough: true,
                      ),
                      const SizedBox(width: 8),
                      _buildCostChip(
                        'المقترح',
                        '${proposal.totalCost.toStringAsFixed(0)} ج.م',
                        AppColors.success.withValues(alpha: 0.1),
                        AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_left, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCostChip(
    String label,
    String value,
    Color bgColor,
    Color textColor, {
    bool lineThrough = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 10, color: textColor),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              decoration: lineThrough ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
