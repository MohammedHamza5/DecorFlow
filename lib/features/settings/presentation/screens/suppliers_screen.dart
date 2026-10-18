import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:drift/drift.dart' as drift;

final _suppliersProvider = FutureProvider.autoDispose<List<Supplier>>((
  ref,
) async {
  final db = ref.watch(erpDatabaseProvider);
  return (db.select(
    db.suppliers,
  )..orderBy([(t) => drift.OrderingTerm(expression: t.name)])).get();
});

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(_suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الموردون والشركات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () {
              AppHaptics.light();
              ref.invalidate(_suppliersProvider);
            },
          ),
        ],
      ),
      body: ConstrainedBody(
        child: suppliersAsync.when(
          data: (suppliers) {
            if (suppliers.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.local_shipping_outlined,
                title: 'لا يوجد موردون مسجلون',
                subtitle: 'أضف موردين لإدارة أسعار التكلفة وربط الأصناف',
                actionLabel: 'إضافة مورد جديد',
                onAction: () => _addSupplier(context, ref),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                AppHaptics.light();
                return ref.invalidate(_suppliersProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: suppliers.length,
                itemBuilder: (context, index) => _SupplierCard(
                  supplier: suppliers[index],
                  onEdit: () => _editSupplier(context, ref, suppliers[index]),
                  onDelete: () =>
                      _deleteSupplier(context, ref, suppliers[index]),
                ),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'جاري تحميل الموردين...'),
          error: (e, _) => AppErrorWidget(
            message: 'فشل تحميل الموردين',
            onRetry: () => ref.invalidate(_suppliersProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSupplier(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'إضافة مورد جديد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _addSupplier(BuildContext context, WidgetRef ref) async {
    AppHaptics.light();
    final result = await _showSupplierDialog(context);
    if (result != null) {
      try {
        final db = ref.read(erpDatabaseProvider);
        await db
            .into(db.suppliers)
            .insert(
              SuppliersCompanion.insert(
                name: result['name'],
                phone: drift.Value(result['phone']),
                city: drift.Value(result['location']),
                notes: drift.Value(result['notes']),
              ),
            );
        ref.invalidate(_suppliersProvider);
        if (context.mounted) {
          AppToast.showSuccess(context, 'تمت إضافة المورد بنجاح !');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.showError(context, 'فشل الإضافة: $e');
        }
      }
    }
  }

  void _editSupplier(
    BuildContext context,
    WidgetRef ref,
    Supplier supplier,
  ) async {
    AppHaptics.light();
    final result = await _showSupplierDialog(context, supplier: supplier);
    if (result != null) {
      try {
        final db = ref.read(erpDatabaseProvider);
        await (db.update(
          db.suppliers,
        )..where((t) => t.id.equals(supplier.id))).write(
          SuppliersCompanion(
            name: drift.Value(result['name']),
            phone: drift.Value(result['phone']),
            city: drift.Value(result['location']),
            notes: drift.Value(result['notes']),
          ),
        );
        ref.invalidate(_suppliersProvider);
        if (context.mounted) {
          AppToast.showSuccess(context, 'تم تحديث بيانات المورد !');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.showError(context, 'فشل التحديث: $e');
        }
      }
    }
  }

  void _deleteSupplier(
    BuildContext context,
    WidgetRef ref,
    Supplier supplier,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'حذف المورد',
      message:
          'هل أنت متأكد من حذف ${supplier.name}؟ لا يمكن التراجع عن هذا الإجراء.',
      isDanger: true,
      confirmLabel: 'حذف',
    );

    if (confirmed) {
      try {
        final db = ref.read(erpDatabaseProvider);
        await (db.delete(
          db.suppliers,
        )..where((t) => t.id.equals(supplier.id))).go();
        ref.invalidate(_suppliersProvider);
        if (context.mounted) {
          AppToast.showSuccess(context, 'تم حذف المورد');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.showError(context, 'فشل الحذف: $e');
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _showSupplierDialog(
    BuildContext context, {
    Supplier? supplier,
  }) async {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final locationCtrl = TextEditingController(text: supplier?.city ?? '');
    final notesCtrl = TextEditingController(text: supplier?.notes ?? '');
    final isEdit = supplier != null;

    final result = await AppBottomSheet.show<Map<String, dynamic>>(
      context: context,
      title: isEdit ? 'تعديل بيانات المورد' : 'إضافة مورد جديد',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameCtrl,
            autofocus: !isEdit,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'اسم المورد / الشركة *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.business_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: locationCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'العنوان / المدينة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.location_on_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesCtrl,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'ملاحظات',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.note_rounded),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                AppToast.showInfo(context, 'الرجاء إدخال اسم المورد');
                return;
              }
              Navigator.pop(ctx, {
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim().isEmpty
                    ? null
                    : phoneCtrl.text.trim(),
                'location': locationCtrl.text.trim().isEmpty
                    ? null
                    : locationCtrl.text.trim(),
                'notes': notesCtrl.text.trim().isEmpty
                    ? null
                    : notesCtrl.text.trim(),
              });
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
    return result;
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          foregroundColor: AppColors.primary,
          radius: 24,
          child: const Icon(Icons.store_rounded),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (supplier.phone != null && supplier.phone!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      supplier.phone!,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (supplier.city != null && supplier.city!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      supplier.city!,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: onEdit,
              tooltip: 'تعديل',
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: onDelete,
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }
}
