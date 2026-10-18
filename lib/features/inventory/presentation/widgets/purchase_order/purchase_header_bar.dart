import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'quick_add_supplier_dialog.dart';

/// Top configuration bar for the purchase invoice:
/// Supplier selection with quick add, reference invoice number, and payment method (Cash/Credit/Bank).
class PurchaseHeaderBar extends ConsumerWidget {
  final int? selectedSupplierId;
  final ValueChanged<int?> onSupplierChanged;
  final TextEditingController invoiceNumberCtrl;
  final String paymentMethod; // 'cash', 'credit', 'bank'
  final ValueChanged<String> onPaymentMethodChanged;

  const PurchaseHeaderBar({
    super.key,
    required this.selectedSupplierId,
    required this.onSupplierChanged,
    required this.invoiceNumberCtrl,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(erpDatabaseProvider);
    final suppliersFuture = (db.select(db.suppliers)
          ..where((s) => s.active.equals(true)))
        .get();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;

          final supplierDropdown = FutureBuilder<List<Supplier>>(
            future: suppliersFuture,
            builder: (context, snap) {
              final suppliers = snap.data ?? [];
              final hasSelected = suppliers.any((s) => s.id == selectedSupplierId);
              final effectiveSelectedId = hasSelected ? selectedSupplierId : null;

              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: effectiveSelectedId,
                      decoration: InputDecoration(
                        labelText: 'المورد *',
                        prefixIcon: const Icon(Icons.business_rounded, size: 20),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                      hint: const Text('اختر المورد...'),
                      items: suppliers
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          )
                          .toList(),
                      onChanged: onSupplierChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    tooltip: 'إضافة مورد جديد',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      AppHaptics.selection();
                      final newId = await QuickAddSupplierDialog.show(context);
                      if (newId != null) {
                        onSupplierChanged(newId);
                      }
                    },
                  ),
                ],
              );
            },
          );

          final invoiceNumberField = TextField(
            controller: invoiceNumberCtrl,
            decoration: InputDecoration(
              labelText: 'رقم الفاتورة المرجعي للمورد',
              hintText: 'مثلاً: INV-4580',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.tag_rounded, size: 20),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          );

          final paymentMethodSelector = Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _paymentChip('cash', 'كاش من الدرج 💵', AppColors.success),
                _paymentChip('credit', 'آجل على المورد ⏳', const Color(0xFFD97706)),
                _paymentChip('bank', 'تحويل بنكي 🏦', const Color(0xFF0284C7)),
              ],
            ),
          );

          if (isWide) {
            return Row(
              children: [
                // Supplier Selector
                Expanded(flex: 4, child: supplierDropdown),
                const SizedBox(width: 12),
                // Invoice Number
                Expanded(flex: 3, child: invoiceNumberField),
                const SizedBox(width: 12),
                // Payment Method
                Expanded(flex: 4, child: paymentMethodSelector),
              ],
            );
          } else {
            return Column(
              children: [
                supplierDropdown,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: invoiceNumberField),
                  ],
                ),
                const SizedBox(height: 10),
                paymentMethodSelector,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _paymentChip(String key, String label, Color activeColor) {
    final isSelected = paymentMethod == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onPaymentMethodChanged(key);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
