import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/features/inventory/presentation/helpers/inventory_helpers.dart';
import 'package:stream_pay/core/responsive/app_responsive.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Main Inventory Screen — smart dashboard + enriched item list.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  String _searchQuery = '';
  StockFilter _stockFilter = StockFilter.all;
  final _searchController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final catalogState = ref.watch(catalogHubProvider);
    final role = ref.watch(currentUserRoleProvider);
    final canManageStock = RolePermissions.hasPermission(
      role,
      AppPermission.addStock,
    );

    // Get all products that have inventory (variants with stock data)
    final allProducts = catalogState.allProducts;

    // Compute stats from catalog data
    final stats = _computeStats(allProducts);
    final alertCount =
        (stats['low_stock'] as int) + (stats['out_of_stock'] as int);

    // Filter products based on selected filters
    final filteredItems = _filterItems(allProducts);

    return Scaffold(
      body: ConstrainedBody(
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ────────────────────────────────────────
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 70,
              title: Text(
                'المخزون',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'تحديث',
                  onPressed: () {
                    ref.read(catalogHubProvider.notifier).invalidate();
                  },
                ),
              ],
            ),

            // ─── Smart Alert Banner ─────────────────────────────
            if (alertCount > 0)
              SliverToBoxAdapter(
                child: _AlertBanner(
                  lowStock: stats['low_stock'] as int,
                  outOfStock: stats['out_of_stock'] as int,
                  pulseController: _pulseController,
                ),
              ),

            // ─── Dashboard Stats ────────────────────────────────
            SliverToBoxAdapter(child: _SmartDashboard(stats: stats)),

            // ─── ERP Quick Actions ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push('/purchase-orders'),
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: const Text('فواتير المشتريات'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/stock-adjustment'),
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: const Text('تسوية المخزون'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Search Bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن صنف بالاسم أو اللون...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),

            // ─── Stock Status Filter ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _StockStatusFilter(
                  selected: _stockFilter,
                  stats: stats,
                  onSelected: (f) => setState(() => _stockFilter = f),
                ),
              ),
            ),

            // ─── Category Chips ─────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: _CategoryChips(
                  categories: catalogState.availableCategories,
                  selected: _selectedCategory,
                  onSelected: (cat) => setState(() => _selectedCategory = cat),
                ),
              ),
            ),

            // ─── Inventory List ─────────────────────────────────
            if (catalogState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredItems.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  hasFilter:
                      _selectedCategory != null ||
                      _searchQuery.isNotEmpty ||
                      _stockFilter != StockFilter.all,
                  onAdd: () => context.push('/stock-adjustment'),
                ),
              )
            else
              SliverLayoutBuilder(
                builder: (context, sliverConstraints) {
                  final info = ResponsiveInfo(
                    width: sliverConstraints.crossAxisExtent,
                    height: sliverConstraints.crossAxisExtent,
                  );
                  final hPad = info.isMobile ? 16.0 : 24.0;
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 100),
                    sliver: SliverList.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _SmartInventoryCard(
                          product: item.product,
                          variant: item.variant,
                          canManageStock: canManageStock,
                          onTap: () => _showQuickActions(
                            context,
                            item,
                            canManageStock: canManageStock,
                          ),
                          onAddStock: canManageStock
                              ? () => _showMovementDialog(context, item, 'in')
                              : null,
                          onDeductStock: canManageStock
                              ? () => _showMovementDialog(context, item, 'out')
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: canManageStock
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/stock-adjustment'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة مخزون'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimaryDark,
            )
          : null,
    );
  }

  // ─── Stats Computation ─────────────────────────────────────

  Map<String, dynamic> _computeStats(List<EnrichedProduct> products) {
    int totalItems = 0;
    int lowStock = 0;
    int outOfStock = 0;
    int inStock = 0;
    double totalValue = 0;

    for (final product in products) {
      for (final variant in product.variants) {
        // Only count variants that have been stocked (have inventory data)
        if (variant.availableQty > 0 ||
            variant.reservedQty > 0 ||
            variant.reorderPoint > 0) {
          totalItems++;

          switch (variant.stockStatus) {
            case StockStatus.inStock:
              inStock++;
              break;
            case StockStatus.lowStock:
              lowStock++;
              break;
            case StockStatus.outOfStock:
              outOfStock++;
              break;
          }

          if (variant.availableQty > 0 && variant.netPrice > 0) {
            totalValue += variant.availableQty * variant.netPrice;
          } else if (variant.availableQty > 0 && variant.listPrice > 0) {
            totalValue += variant.availableQty * variant.listPrice;
          }
        }
      }
    }

    return {
      'total_items': totalItems,
      'in_stock': inStock,
      'low_stock': lowStock,
      'out_of_stock': outOfStock,
      'total_value': totalValue,
    };
  }

  // ─── Filtering ─────────────────────────────────────────────

  List<_InventoryEntry> _filterItems(List<EnrichedProduct> products) {
    final entries = <_InventoryEntry>[];

    for (final product in products) {
      for (final variant in product.variants) {
        // Include stocked items + items with reorder point set
        if (variant.availableQty > 0 ||
            variant.reservedQty > 0 ||
            variant.reorderPoint > 0) {
          entries.add(_InventoryEntry(product: product, variant: variant));
        }
      }
    }

    var filtered = entries.toList();

    // Stock status filter
    switch (_stockFilter) {
      case StockFilter.inStock:
        filtered = filtered
            .where((e) => e.variant.stockStatus == StockStatus.inStock)
            .toList();
        break;
      case StockFilter.lowStock:
        filtered = filtered
            .where((e) => e.variant.stockStatus == StockStatus.lowStock)
            .toList();
        break;
      case StockFilter.outOfStock:
        filtered = filtered
            .where((e) => e.variant.stockStatus == StockStatus.outOfStock)
            .toList();
        break;
      case StockFilter.all:
        break;
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((e) => e.product.category == _selectedCategory)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.product.name.toLowerCase().contains(q) ||
            (e.variant.variantName.toLowerCase()).contains(q) ||
            (e.variant.color?.toLowerCase() ?? '').contains(q) ||
            e.product.category.toLowerCase().contains(q);
      }).toList();
    }

    // Sort: out of stock first, then low, then in stock
    filtered.sort((a, b) {
      final aOrder = a.variant.stockStatus == StockStatus.outOfStock
          ? 0
          : a.variant.stockStatus == StockStatus.lowStock
          ? 1
          : 2;
      final bOrder = b.variant.stockStatus == StockStatus.outOfStock
          ? 0
          : b.variant.stockStatus == StockStatus.lowStock
          ? 1
          : 2;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return a.product.name.compareTo(b.product.name);
    });

    return filtered;
  }

  // ─── Quick Actions ─────────────────────────────────────────

  void _showQuickActions(
    BuildContext context,
    _InventoryEntry entry, {
    bool canManageStock = false,
  }) {
    final theme = Theme.of(context);
    final variant = entry.variant;
    final product = entry.product;
    final unitLabel = InventoryHelpers.unitLabel(product.unitType);

    AppBottomSheet.show(
      context: context,
      title: '${product.name} — ${variant.variantName}',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الرصيد المتاح حالياً:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${InventoryHelpers.formatQty(variant.availableQty)} $unitLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: InventoryHelpers.stockStatusColor(
                      variant.availableQty,
                      variant.reorderPoint,
                      theme.colorScheme,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons — only shown if user can manage stock
          if (canManageStock) ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_rounded,
                    label: 'إضافة كمية',
                    color: Colors.green,
                    onTap: () {
                      AppHaptics.light();
                      Navigator.pop(ctx);
                      _showMovementDialog(context, entry, 'in');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.remove_rounded,
                    label: 'خصم كمية',
                    color: theme.colorScheme.error,
                    onTap: variant.availableQty > 0
                        ? () {
                            AppHaptics.light();
                            Navigator.pop(ctx);
                            _showMovementDialog(context, entry, 'out');
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.broken_image_rounded,
                    label: 'تسجيل تالف',
                    color: Colors.red.shade700,
                    onTap: variant.availableQty > 0
                        ? () {
                            AppHaptics.light();
                            Navigator.pop(ctx);
                            _showMovementDialog(context, entry, 'damaged');
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.tune_rounded,
                    label: 'تعديل الرصيد',
                    color: Colors.blue,
                    onTap: () {
                      AppHaptics.light();
                      Navigator.pop(ctx);
                      _showMovementDialog(context, entry, 'adjustment');
                    },
                  ),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'لا تملك صلاحية تعديل المخزون',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  void _showMovementDialog(
    BuildContext context,
    _InventoryEntry entry,
    String type,
  ) {
    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    final color = InventoryHelpers.movementColor(type);
    final label = InventoryHelpers.movementLabel(type);

    final List<String> reasonPresets;
    if (type == 'in') {
      reasonPresets = ['توريد بضاعة جديدة', 'مرتجع من ورشة', 'فائض من عميل', 'تسوية جردية +'];
    } else if (type == 'out') {
      reasonPresets = ['صرف لورشة فني', 'تسليم عميل يدوي', 'عينة معرض', 'تسوية جردية -'];
    } else if (type == 'damaged') {
      reasonPresets = ['كسر أثناء النقل', 'عيب صناعة', 'تالف رطوبة', 'هالك قص وتفصيل'];
    } else {
      reasonPresets = ['جرد دوري', 'تصحيح خطأ إدخال', 'مطابقة رصيد فعلي'];
    }

    final qtyPresets = [1, 5, 10, 25, 50, 100];

    AppBottomSheet.show(
      context: context,
      title:
          '${InventoryHelpers.movementSign(type)} $label — ${entry.product.name}',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الصنف: ${entry.variant.variantName}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'الكمية المطلوبة',
                suffixText: InventoryHelpers.unitLabel(entry.product.unitType),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 8),
            // Quick Quantity Increments
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: qtyPresets.map((preset) {
                return ActionChip(
                  label: Text('+$preset', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  onPressed: () {
                    final current = double.tryParse(qtyController.text) ?? 0.0;
                    final next = current + preset;
                    qtyController.text = next == next.roundToDouble() ? next.toInt().toString() : next.toString();
                    setDialogState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'ملاحظات الحركة (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 8),
            // Quick Reason Presets
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: reasonPresets.map((reason) {
                final isSelected = notesController.text == reason;
                return ActionChip(
                  label: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: isSelected ? color : AppColors.surface,
                  side: BorderSide(color: isSelected ? color : AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  onPressed: () {
                    notesController.text = reason;
                    setDialogState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text);
              if (qty == null || qty <= 0) {
                AppToast.showInfo(ctx, 'يرجى إدخال كمية صحيحة');
                return;
              }
              AppHaptics.medium();
              Navigator.pop(ctx);

              final repo = ref.read(inventoryRepositoryProvider);

              final existingItem = await repo.getInventoryItemByVariantId(
                entry.variant.id,
              );

              if (existingItem != null) {
                final itemId = existingItem['id'] as String;
                if (type == 'damaged') {
                  await repo.recordDamage(
                    inventoryItemId: itemId,
                    quantity: qty,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );
                } else {
                  await repo.recordMovement(
                    inventoryItemId: itemId,
                    type: type,
                    quantity: qty,
                    referenceType: 'manual',
                    notes: notesController.text.isEmpty
                        ? InventoryHelpers.movementLabel(type)
                        : notesController.text,
                  );
                }
              } else {
                if (type == 'out' || type == 'damaged') {
                  if (context.mounted) {
                    AppToast.showError(context, 'لا يمكن سحب كمية من منتج ليس له رصيد مسبق');
                  }
                  return;
                }
                await repo.addInventoryItem(
                  productVariantId: entry.variant.id,
                  unitType: entry.product.unitType,
                  quantity: qty,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );
              }

              // Refresh catalog
              ref.read(catalogHubProvider.notifier).invalidate();

              if (context.mounted) {
                AppToast.showSuccess(
                  context,
                  'تم: $label ${InventoryHelpers.formatQty(qty)} ${InventoryHelpers.unitLabel(entry.product.unitType)} بنجاح ✓',
                );
              }
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(
              'تأكيد حركة $label',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// ─── Data Entry Helper ─────────────────────────────────────────

class _InventoryEntry {
  final EnrichedProduct product;
  final EnrichedVariant variant;

  const _InventoryEntry({required this.product, required this.variant});
}

// ─── Smart Alert Banner ────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final int lowStock;
  final int outOfStock;
  final AnimationController pulseController;

  const _AlertBanner({
    required this.lowStock,
    required this.outOfStock,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final hasOutOfStock = outOfStock > 0;
    final color = hasOutOfStock ? AppColors.error : Colors.orange;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final opacity = 0.8 + (pulseController.value * 0.2);
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              hasOutOfStock ? Icons.error_rounded : Icons.warning_amber_rounded,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _buildAlertText(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAlertText() {
    final parts = <String>[];
    if (outOfStock > 0) parts.add('$outOfStock صنف نفد');
    if (lowStock > 0) parts.add('$lowStock صنف منخفض');
    return '⚠ تنبيه: ${parts.join(' و ')}';
  }
}

// ─── Smart Dashboard ───────────────────────────────────────────

class _SmartDashboard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _SmartDashboard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalItems = stats['total_items'] as int;
    final lowStock = stats['low_stock'] as int;
    final outOfStock = stats['out_of_stock'] as int;
    final totalValue = stats['total_value'] as double;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DashCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'إجمالي الأصناف',
                  value: '$totalItems',
                  gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'منخفض',
                  value: '$lowStock',
                  gradient: const [Color(0xFFD97706), Color(0xFFFBBF24)],
                  pulse: lowStock > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DashCard(
                  icon: Icons.remove_shopping_cart_rounded,
                  label: 'نفد',
                  value: '$outOfStock',
                  gradient: const [Color(0xFFDC2626), Color(0xFFF87171)],
                  pulse: outOfStock > 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'قيمة المخزون',
                  value: InventoryHelpers.formatCurrency(totalValue),
                  gradient: const [Color(0xFF059669), Color(0xFF34D399)],
                  isLarge: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final bool pulse;
  final bool isLarge;

  const _DashCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.pulse = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withValues(alpha: 0.18),
            gradient[1].withValues(alpha: 0.06),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient[0].withValues(alpha: pulse ? 0.5 : 0.2),
          width: pulse ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: gradient[0].withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: gradient[0], size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 15 : 20,
                    fontWeight: FontWeight.bold,
                    color: gradient[0],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stock Status Filter ───────────────────────────────────────

class _StockStatusFilter extends StatelessWidget {
  final StockFilter selected;
  final Map<String, dynamic> stats;
  final ValueChanged<StockFilter> onSelected;

  const _StockStatusFilter({
    required this.selected,
    required this.stats,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterPill(
          label: 'الكل',
          count: stats['total_items'] as int,
          isSelected: selected == StockFilter.all,
          color: AppColors.primary,
          onTap: () => onSelected(StockFilter.all),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          label: 'متوفر',
          count: stats['in_stock'] as int,
          isSelected: selected == StockFilter.inStock,
          color: Colors.green,
          onTap: () => onSelected(StockFilter.inStock),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          label: 'منخفض',
          count: stats['low_stock'] as int,
          isSelected: selected == StockFilter.lowStock,
          color: Colors.orange,
          onTap: () => onSelected(StockFilter.lowStock),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          label: 'نفد',
          count: stats['out_of_stock'] as int,
          isSelected: selected == StockFilter.outOfStock,
          color: Colors.red,
          onTap: () => onSelected(StockFilter.outOfStock),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? color : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Chips ────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: FilterChip(
            label: const Text('الكل'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected == null
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: selected == null
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 12,
            ),
            side: BorderSide(
              color: selected == null ? AppColors.primary : AppColors.border,
            ),
          ),
        ),
        ...categories.map(
          (cat) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: FilterChip(
              label: Text(cat),
              selected: selected == cat,
              onSelected: (_) => onSelected(selected == cat ? null : cat),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected == cat
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: selected == cat
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: selected == cat ? AppColors.primary : AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Smart Inventory Card ──────────────────────────────────────

class _SmartInventoryCard extends StatelessWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final VoidCallback onTap;
  final VoidCallback? onAddStock;
  final VoidCallback? onDeductStock;
  final bool canManageStock;

  const _SmartInventoryCard({
    required this.product,
    required this.variant,
    required this.onTap,
    this.onAddStock,
    this.onDeductStock,
    this.canManageStock = false,
  });

  Widget _buildCardContent(
    BuildContext context,
    double qty,
    double reorder,
    Color statusColor,
    String statusText,
    IconData statusIcon,
    String unitLabel,
    double progressRatio,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: qty <= 0 || (reorder > 0 && qty <= reorder)
              ? statusColor.withValues(alpha: 0.4)
              : AppColors.border,
          width: qty <= 0 || (reorder > 0 && qty <= reorder) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status icon with glow
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 14),

                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (variant.variantName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsetsDirectional.only(
                                    end: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    variant.variantName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Text(
                                product.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Quantity + status + price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${InventoryHelpers.formatQty(qty)} $unitLabel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (variant.netPrice > 0)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 6,
                                ),
                                child: Text(
                                  '${variant.netPrice.toStringAsFixed(0)} ج.م',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Progress bar
                if (reorder > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final qty = variant.availableQty;
    final reorder = variant.reorderPoint;
    final statusColor = InventoryHelpers.stockStatusColor(
      qty,
      reorder,
      colorScheme,
    );
    final statusText = InventoryHelpers.stockStatusText(qty, reorder);
    final statusIcon = InventoryHelpers.stockStatusIcon(qty, reorder);
    final unitLabel = InventoryHelpers.unitLabel(product.unitType);

    // Progress bar ratio
    double progressRatio = 0;
    if (reorder > 0) {
      // Show ratio relative to 3x reorder point (full bar = healthy stock)
      progressRatio = (qty / (reorder * 3)).clamp(0.0, 1.0);
    } else if (qty > 0) {
      progressRatio = 1.0; // No reorder point set, so any stock is "full"
    }

    final cardContent = _buildCardContent(
      context,
      qty,
      reorder,
      statusColor,
      statusText,
      statusIcon,
      unitLabel,
      progressRatio,
    );

    // If user can't manage stock, disable swipe gestures
    if (!canManageStock) {
      return cardContent;
    }

    return Dismissible(
      key: ValueKey('${product.id}_${variant.id}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onAddStock?.call();
        } else {
          if (qty > 0) onDeductStock?.call();
        }
        return false; // Don't actually dismiss
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(
              'إضافة',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'خصم',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.remove_rounded, color: Colors.red, size: 28),
          ],
        ),
      ),
      child: cardContent,
    );
  }
}

// ─── Action Button ─────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final effectiveColor = isDisabled ? AppColors.textTertiary : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: effectiveColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: effectiveColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: effectiveColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onAdd;

  const _EmptyState({required this.hasFilter, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.filter_alt_off_rounded : Icons.warehouse_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'لا توجد نتائج' : 'المخزون فارغ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'جرب تغيير الفلتر أو البحث'
                : 'ابدأ بإضافة أصناف للمخزون',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة مخزون'),
            ),
          ],
        ],
      ),
    );
  }
}
