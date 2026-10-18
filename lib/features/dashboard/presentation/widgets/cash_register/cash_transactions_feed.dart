import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Interactive Transaction Feed for the cash drawer with instant category filtering.
class CashTransactionsFeed extends StatefulWidget {
  final List<CashTransaction> transactions;

  const CashTransactionsFeed({super.key, required this.transactions});

  @override
  State<CashTransactionsFeed> createState() => _CashTransactionsFeedState();
}

class _CashTransactionsFeedState extends State<CashTransactionsFeed> {
  String _selectedFilter = 'all'; // all, sales, expenses, transfers

  List<CashTransaction> get _filteredTransactions {
    if (_selectedFilter == 'sales') {
      return widget.transactions
          .where((t) => t.category == 'customer_payment')
          .toList();
    } else if (_selectedFilter == 'expenses') {
      return widget.transactions
          .where((t) => t.category == 'expense' || t.category == 'sales_return')
          .toList();
    } else if (_selectedFilter == 'transfers') {
      return widget.transactions
          .where((t) =>
              t.category == 'drawer_deposit' ||
              t.category == 'drawer_withdrawal' ||
              t.category == 'shift_transfer')
          .toList();
    }
    return widget.transactions;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'سجل حركة الدرج والخزينة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.transactions.length} حركة مسجلة',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all', 'الكل (${widget.transactions.length})'),
                      const SizedBox(width: 6),
                      _filterChip('sales', 'مبيعات نقدية 🟢'),
                      const SizedBox(width: 6),
                      _filterChip('expenses', 'مصروفات ونثريات 🔴'),
                      const SizedBox(width: 6),
                      _filterChip('transfers', 'إيداع وسحب 💵'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List or Empty
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لا توجد حركات مسجلة تحت هذا التصنيف',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tr = filtered[index];
                final isIn = tr.type == 'in';
                final info = _formatTransaction(tr.category, tr.type);
                final color = info.color;
                final timeStr = DateFormat(
                  'hh:mm a • yyyy/MM/dd',
                  'ar',
                ).format(tr.createdAt);

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(info.icon, color: color, size: 18),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          info.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isIn ? '+' : '-'}${NumberFormat('#,##0', 'ar').format(tr.amount)} ج.م',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${tr.notes != null && tr.notes!.isNotEmpty ? "${tr.notes} • " : ""}$timeStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      onSelected: (_) {
        AppHaptics.selection();
        setState(() => _selectedFilter = filterKey);
      },
    );
  }

  ({String title, IconData icon, Color color}) _formatTransaction(
    String category,
    String type,
  ) {
    final isIn = type == 'in';
    switch (category) {
      case 'customer_payment':
        return (
          title: 'تحصيل فاتورة مبيعات كاش',
          icon: Icons.point_of_sale_rounded,
          color: AppColors.success,
        );
      case 'sales_return':
        return (
          title: 'رد نقدية مرتجع مبيعات',
          icon: Icons.assignment_return_rounded,
          color: AppColors.error,
        );
      case 'expense':
        return (
          title: 'صرف مصروف ونثريات',
          icon: Icons.receipt_long_rounded,
          color: AppColors.error,
        );
      case 'drawer_deposit':
        return (
          title: 'إيداع عهدة بالخزينة',
          icon: Icons.arrow_downward_rounded,
          color: AppColors.success,
        );
      case 'drawer_withdrawal':
        return (
          title: 'سحب نقدي من الخزينة',
          icon: Icons.arrow_upward_rounded,
          color: AppColors.error,
        );
      case 'supplier_payment':
        return (
          title: 'سداد مشتريات مورد',
          icon: Icons.local_shipping_rounded,
          color: AppColors.error,
        );
      case 'shift_transfer':
        return (
          title: 'تسليم عهدة تقفيل الوردية',
          icon: Icons.lock_clock_rounded,
          color: const Color(0xFF0284C7),
        );
      case 'shift_shortage':
        return (
          title: 'تسوية عجز الوردية',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
        );
      case 'shift_surplus':
        return (
          title: 'زيادة نقدية في الوردية',
          icon: Icons.add_circle_outline_rounded,
          color: AppColors.success,
        );
      case 'shift_settlement':
        return (
          title: 'تسوية وتصفير رصيد الدرج',
          icon: Icons.balance_rounded,
          color: Colors.orange,
        );
      default:
        return (
          title: category,
          icon: isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: isIn ? AppColors.success : AppColors.error,
        );
    }
  }
}
