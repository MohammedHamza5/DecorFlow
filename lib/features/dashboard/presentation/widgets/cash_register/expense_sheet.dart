import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Quick expense recording bottom sheet.
/// Deducts expenses (tea, transport, maintenance) directly from the drawer ledger.
class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ExpenseSheet(),
    );
  }

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  int? _selectedCategoryId;
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isSaving = false;

  void _addQuickAmount(double val) {
    AppHaptics.light();
    final cur = double.tryParse(_amountCtrl.text) ?? 0.0;
    final next = cur + val;
    _amountCtrl.text = next == next.truncateToDouble()
        ? next.toInt().toString()
        : next.toStringAsFixed(1);
    setState(() {});
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.money_off_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'تسجيل مصروف جديد من الخزينة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          categoriesAsync.when(
            loading: () => const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Text('خطأ في تحميل بنود المصروف: $e'),
            data: (categories) {
              if (_selectedCategoryId == null && categories.isNotEmpty) {
                _selectedCategoryId = categories.first.id;
              }
              return DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'بند المصروف *',
                  prefixIcon: const Icon(Icons.category_rounded, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              );
            },
          ),

          const SizedBox(height: 12),

          // Quick Preset Amount Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'مبالغ سريعة: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                ...[20.0, 50.0, 100.0, 200.0, 500.0].map(
                  (amt) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ActionChip(
                      label: Text('+${amt.toInt()} ج'),
                      onPressed: () => _addQuickAmount(amt),
                      backgroundColor:
                          AppColors.error.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.25),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Amount TextField
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'المبلغ المطلوب خصمه (ج.م) *',
              prefixIcon: const Icon(Icons.attach_money_rounded),
              suffixText: 'ج.م',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Notes / Purpose TextField
          TextFormField(
            controller: _notesCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'البيان / تفاصيل المصروف',
              hintText: 'مثلاً: شاي وسكر، بنزين سيارة، نقل ألواح رخام...',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Submit Button
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveExpense,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'تأكيد خصم المصروف من الدرج',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (_selectedCategoryId == null || _amountCtrl.text.isEmpty) {
      AppToast.showError(context, 'يرجى إدخال المبلغ وتحديد بند المصروف');
      return;
    }

    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      AppToast.showError(context, 'يرجى إدخال مبلغ صحيح أكبر من الصفر');
      return;
    }

    final engine = ref.read(cashFlowEngineProvider);
    final currentBalance = await engine.getDrawerBalance();

    if (amount > currentBalance && currentBalance <= 0) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('تنبيه: الخزينة خالية!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            'رصيد الدرج الحالي هو (${currentBalance.toStringAsFixed(0)} ج.م) ولا توجد نقدية كافية بالدرج لصرف (${amount.toStringAsFixed(0)} ج.م).\n\nهل هذا المصروف تم دفعه من خارج الدرج (سلفة خارجية) وتريد تسجيله استثنائياً؟',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء ووضع عهدة أولاً'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('نعم، سلفة خارجية'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSaving = true);

    try {
      await engine.recordExpense(
        categoryId: _selectedCategoryId!,
        amount: amount,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );

      ref.invalidate(drawerBalanceProvider);
      ref.invalidate(dailyCashSummaryProvider);
      ref.invalidate(recentTransactionsProvider);

      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(context, 'تم تسجيل المصروف وخصمه من الدرج بنجاح ✅');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(context, 'خطأ أثناء تسجيل المصروف: $e');
      }
    }
  }
}
