import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:drift/drift.dart' as drift;
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Quick modal dialog to add a new supplier without leaving the purchase screen.
class QuickAddSupplierDialog extends ConsumerStatefulWidget {
  const QuickAddSupplierDialog({super.key});

  static Future<int?> show(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (context) => const QuickAddSupplierDialog(),
    );
  }

  @override
  ConsumerState<QuickAddSupplierDialog> createState() =>
      _QuickAddSupplierDialogState();
}

class _QuickAddSupplierDialogState
    extends ConsumerState<QuickAddSupplierDialog> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1_rounded,
              color: AppColors.primary, size: 22),
          SizedBox(width: 8),
          Text(
            'إضافة مورد جديد',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'اسم المورد / الشركة *',
                prefixIcon: const Icon(Icons.business_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: const Icon(Icons.phone_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityCtrl,
              decoration: InputDecoration(
                labelText: 'المدينة / العنوان',
                prefixIcon: const Icon(Icons.location_city_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSaving ? null : _saveSupplier,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: const Text('حفظ المورد'),
        ),
      ],
    );
  }

  Future<void> _saveSupplier() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppToast.showError(context, 'يرجى إدخال اسم المورد');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = ref.read(erpDatabaseProvider);
      final supplierId = await db.into(db.suppliers).insert(
            SuppliersCompanion.insert(
              name: name,
              phone: drift.Value(_phoneCtrl.text.trim().isEmpty
                  ? null
                  : _phoneCtrl.text.trim()),
              city: drift.Value(_cityCtrl.text.trim().isEmpty
                  ? null
                  : _cityCtrl.text.trim()),
            ),
          );

      if (mounted) {
        AppToast.showSuccess(context, 'تمت إضافة المورد بنجاح');
        Navigator.pop(context, supplierId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(context, 'فشل حفظ المورد: $e');
      }
    }
  }
}
