import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Modal bottom sheet for depositing float/capital or withdrawing cash (e.g. owner withdrawals).
class DepositWithdrawalSheet extends ConsumerStatefulWidget {
  final bool initialIsDeposit;

  const DepositWithdrawalSheet({super.key, this.initialIsDeposit = true});

  static Future<void> show(BuildContext context, {bool isDeposit = true}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DepositWithdrawalSheet(initialIsDeposit: isDeposit),
    );
  }

  @override
  ConsumerState<DepositWithdrawalSheet> createState() =>
      _DepositWithdrawalSheetState();
}

class _DepositWithdrawalSheetState
    extends ConsumerState<DepositWithdrawalSheet> {
  late bool _isDeposit;
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isDeposit = widget.initialIsDeposit;
  }

  void _setAmount(double val) {
    AppHaptics.light();
    _amountCtrl.text = val == val.truncateToDouble()
        ? val.toInt().toString()
        : val.toStringAsFixed(1);
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
    final color = _isDeposit ? AppColors.success : AppColors.error;

    final quickReasons = _isDeposit
        ? ['عهدة افتتاحية للوردية (فكة)', 'تغذية الدرج', 'إيداع إضافي من المالك']
        : ['مسحوبات صاحب المحل', 'إيداع نقدي بالبنك', 'سلفة / عهدة مؤقتة'];

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

          // Header Title
          Text(
            _isDeposit ? 'إيداع نقدي في الخزينة (+)' : 'سحب نقدي من الخزينة (-)',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Toggle Mode
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      setState(() => _isDeposit = true);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _isDeposit
                            ? AppColors.success
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'إيداع بالخزينة (+)',
                        style: TextStyle(
                          color: _isDeposit
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      setState(() => _isDeposit = false);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: !_isDeposit
                            ? AppColors.error
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'سحب من الخزينة (-)',
                        style: TextStyle(
                          color: !_isDeposit
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Preset Amounts
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
                ...[100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0].map(
                  (amt) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ActionChip(
                      label: Text('${amt.toInt()} ج'),
                      onPressed: () => _setAmount(amt),
                      backgroundColor: color.withValues(alpha: 0.08),
                      side: BorderSide(color: color.withValues(alpha: 0.25)),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Amount Input
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'المبلغ (ج.م) *',
              prefixIcon: Icon(Icons.payments_rounded, color: color),
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

          // Quick Reason Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: quickReasons
                .map(
                  (reason) => ActionChip(
                    label: Text(reason, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.background,
                    side: BorderSide(color: AppColors.border),
                    onPressed: () {
                      AppHaptics.light();
                      _notesCtrl.text = reason;
                      setState(() {});
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          // Notes Input
          TextFormField(
            controller: _notesCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'البيان / سبب الحركة',
              hintText: 'اكتب تفاصيل إضافية إن وجدت...',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
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
            onPressed: _isSaving ? null : _saveTransaction,
            style: FilledButton.styleFrom(
              backgroundColor: color,
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
                : Text(
                    _isDeposit
                        ? 'تأكيد الإيداع في الخزينة'
                        : 'تأكيد السحب من الخزينة',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      AppToast.showError(context, 'يرجى إدخال مبلغ صحيح أكبر من الصفر');
      return;
    }

    final engine = ref.read(cashFlowEngineProvider);

    if (!_isDeposit) {
      final currentBalance = await engine.getDrawerBalance();
      if (amount > currentBalance) {
        if (!mounted) return;
        AppToast.showError(
          context,
          'لا يمكن السحب: رصيد الدرج الحالي (${currentBalance.toStringAsFixed(0)} ج.م) غير كافٍ!',
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await engine.recordTransaction(
        amount: amount,
        type: _isDeposit ? 'in' : 'out',
        category: _isDeposit ? 'drawer_deposit' : 'drawer_withdrawal',
        notes: _notesCtrl.text.isEmpty
            ? (_isDeposit ? 'إيداع نقدي بالخزينة' : 'سحب نقدي من الخزينة')
            : _notesCtrl.text,
      );

      ref.invalidate(drawerBalanceProvider);
      ref.invalidate(dailyCashSummaryProvider);
      ref.invalidate(recentTransactionsProvider);

      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(
          context,
          _isDeposit
              ? 'تم إيداع $amount ج.م في الخزينة بنجاح ✅'
              : 'تم سحب $amount ج.م من الخزينة بنجاح ✅',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(context, 'خطأ أثناء تسجيل الحركة: $e');
      }
    }
  }
}
