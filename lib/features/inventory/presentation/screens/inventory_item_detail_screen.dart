import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/inventory/presentation/helpers/inventory_helpers.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Detail screen for a single inventory item — shows stock info & movement history.
class InventoryItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const InventoryItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemAsync = ref.watch(inventoryItemDetailProvider(itemId));
    final movementsAsync = ref.watch(inventoryMovementsProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الصنف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditReorderDialog(context, ref),
          ),
        ],
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('الصنف غير موجود'));
          }

          final variantRaw = item['product_variant'];
          final variant = variantRaw != null ? Map<String, dynamic>.from(variantRaw as Map) : <String, dynamic>{};
          final productRaw = variant['product'];
          final product = productRaw != null ? Map<String, dynamic>.from(productRaw as Map) : <String, dynamic>{};
          final pricings = (variant['supplier_product_pricings'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];

          final name = product['name'] as String? ?? 'بدون اسم';
          final variantName = variant['variant_name'] as String? ?? '';
          final category = product['category'] as String? ?? '';
          final qty = (item['available_qty'] as num?)?.toDouble() ?? 0;
          final reserved = (item['reserved_qty'] as num?)?.toDouble() ?? 0;
          final damaged = (item['damaged_qty'] as num?)?.toDouble() ?? 0;
          final reorder = (item['reorder_point'] as num?)?.toDouble() ?? 0;
          final unitType = item['unit_type'] as String? ?? 'piece';

          // Get pricing info
          double? listPrice;
          double? costPrice;
          if (pricings.isNotEmpty) {
            final preferredList = pricings.where((p) => p['is_preferred'] == true);
            final preferred = preferredList.isNotEmpty ? preferredList.first : pricings.first;
            listPrice = (preferred['list_price'] as num?)?.toDouble();
            costPrice = (preferred['cost_price'] as num?)?.toDouble();
          }

          final statusColor = InventoryHelpers.stockStatusColor(qty, reorder, colorScheme);
          final statusText = InventoryHelpers.stockStatusText(qty, reorder);
          final unitLabel = InventoryHelpers.unitLabel(unitType);

          return ConstrainedBody(
            child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Product Info Card ─────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          if (variantName.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                variantName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Stock Status — 4 Cards ─────────────────
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.inventory_2_rounded,
                      label: 'متاح',
                      value: '${InventoryHelpers.formatQty(qty)} $unitLabel',
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'محجوز',
                      value: '${InventoryHelpers.formatQty(reserved)} $unitLabel',
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.broken_image_rounded,
                      label: 'تالف',
                      value: '${InventoryHelpers.formatQty(damaged)} $unitLabel',
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.notifications_active_outlined,
                      label: 'حد التنبيه',
                      value: reorder > 0 ? InventoryHelpers.formatQty(reorder) : 'غير محدد',
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ─── Pricing Info ──────────────────────────
              if (listPrice != null || costPrice != null)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (listPrice != null) ...[
                          Expanded(
                            child: Column(
                              children: [
                                Text('سعر البيع', style: theme.textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Text(
                                  '${listPrice.toStringAsFixed(0)} ج.م',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (costPrice != null) ...[
                          Expanded(
                            child: Column(
                              children: [
                                Text('سعر التكلفة', style: theme.textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Text(
                                  '${costPrice.toStringAsFixed(0)} ج.م',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (listPrice != null && costPrice != null) ...[
                          Expanded(
                            child: Column(
                              children: [
                                Text('هامش الربح', style: theme.textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Text(
                                  '${((listPrice - costPrice) / listPrice * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ─── Stock Value ───────────────────────────
              if (listPrice != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('قيمة المخزون: ', style: theme.textTheme.bodyLarge),
                        Text(
                          '${(qty * listPrice).toStringAsFixed(0)} ج.م',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ─── Quick Actions ─────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showMovementDialog(context, ref, item, 'in'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('إضافة كمية'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: qty > 0
                          ? () => _showMovementDialog(context, ref, item, 'out')
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                      label: const Text('خصم كمية'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: qty > 0
                          ? () => _showMovementDialog(context, ref, item, 'damaged')
                          : null,
                      icon: const Icon(Icons.broken_image_rounded),
                      label: const Text('تالف'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Movement History ──────────────────────
              Text(
                'سجل الحركة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              movementsAsync.when(
                data: (movements) {
                  if (movements.isEmpty) {
                    return Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'لا توجد حركات بعد',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: movements
                        .map((m) => _MovementTile(movement: m))
                        .toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => const Text('خطأ في تحميل السجل'),
              ),
            ],
          ),);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  void _showMovementDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
    String type,
  ) {
    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    final color = InventoryHelpers.movementColor(type);
    final label = InventoryHelpers.movementLabel(type);
    final sign = InventoryHelpers.movementSign(type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$sign $label',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'الكمية',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text);
                if (qty == null || qty <= 0) return;

                Navigator.pop(ctx);

                final repo = ref.read(inventoryRepositoryProvider);

                if (type == 'damaged') {
                  await repo.recordDamage(
                    inventoryItemId: itemId,
                    quantity: qty,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                } else {
                  await repo.recordMovement(
                    inventoryItemId: itemId,
                    type: type,
                    quantity: qty,
                    referenceType: 'manual',
                    notes: notesController.text.isEmpty
                        ? label
                        : notesController.text,
                  );
                }

                ref.invalidate(inventoryItemDetailProvider(itemId));
                ref.invalidate(inventoryMovementsProvider(itemId));
                ref.invalidate(inventoryProvider(null));
                ref.invalidate(inventoryStatsProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم: $label ✓'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReorderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل حد التنبيه'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'حد إعادة الطلب',
            hintText: 'مثال: 10',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null) return;
              Navigator.pop(ctx);

              final repo = ref.read(inventoryRepositoryProvider);
              await repo.updateReorderPoint(itemId, value);
              ref.invalidate(inventoryItemDetailProvider(itemId));
              ref.invalidate(inventoryProvider(null));
              ref.invalidate(inventoryStatsProvider);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

// ─── Info Tile ──────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Movement Tile ─────────────────────────────────────────────

class _MovementTile extends StatelessWidget {
  final Map<String, dynamic> movement;

  const _MovementTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = movement['movement_type'] as String? ?? '';
    final qty = (movement['quantity'] as num?)?.toDouble() ?? 0;
    final balance = (movement['balance_after'] as num?)?.toDouble() ?? 0;
    final notes = movement['notes'] as String? ?? '';
    final date = DateTime.tryParse(movement['created_at'] as String? ?? '');

    final icon = InventoryHelpers.movementIcon(type);
    final color = InventoryHelpers.movementColor(type);
    final label = InventoryHelpers.movementLabel(type);
    final sign = InventoryHelpers.movementSign(type);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              '$sign${InventoryHelpers.formatQty(qty)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if (notes.isNotEmpty)
              Expanded(
                child: Text(
                  notes,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (date != null)
              Text(
                DateFormat('d/M  HH:mm', 'ar').format(date.toLocal()),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: Text(
          'رصيد: ${InventoryHelpers.formatQty(balance)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
