import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:stream_pay/shared/widgets/glass_container.dart';

/// بند داخل إذن استلام الشحنة / التوريد
class _ManifestItem {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  double qty;

  _ManifestItem({
    required this.product,
    required this.variant,
    required this.qty,
  });

  String get variantId => variant.id;

  String get unitLabel {
    switch (product.unitType) {
      case 'rod':
        return 'عود';
      case 'panel':
        return 'لوح';
      case 'piece':
        return 'قطعة';
      case 'box':
        return 'علبة';
      case 'square_meter':
        return 'م2';
      case 'linear_meter':
        return 'م.ط';
      default:
        return 'وحدة';
    }
  }
}

/// شاشة استلام وتوريد المخزون الذكية والفورية
class StockAdjustmentScreen extends ConsumerStatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  ConsumerState<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends ConsumerState<StockAdjustmentScreen> {
  final _searchController = TextEditingController();
  final _manifestNotesController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  String _stockFilter = 'all'; // 'all', 'low', 'out', 'in'
  String _selectedReason = 'purchase'; // 'purchase', 'inventory', 'return'
  String? _selectedSupplierId;
  bool _isSubmitting = false;

  // سلة إذن التوريد الجاري استلامه
  final List<_ManifestItem> _manifest = [];

  @override
  void dispose() {
    _searchController.dispose();
    _manifestNotesController.dispose();
    super.dispose();
  }

  // ─── منطق إذن التوريد السريع ──────────────────────────────────────────

  void _addItemToManifest(
    EnrichedProduct product,
    EnrichedVariant variant,
    double qty,
  ) {
    if (qty <= 0) return;
    AppHaptics.light();

    setState(() {
      final idx = _manifest.indexWhere((m) => m.variantId == variant.id);
      if (idx >= 0) {
        _manifest[idx].qty += qty;
      } else {
        _manifest.add(
          _ManifestItem(
            product: product,
            variant: variant,
            qty: qty,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إضافة +${qty.toStringAsFixed(0)} إلى إذن التوريد: ${product.name} (${variant.variantName})',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(milliseconds: 900),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateManifestItemQty(String variantId, double newQty) {
    setState(() {
      final idx = _manifest.indexWhere((m) => m.variantId == variantId);
      if (idx >= 0) {
        if (newQty <= 0) {
          _manifest.removeAt(idx);
        } else {
          _manifest[idx].qty = newQty;
        }
      }
    });
  }

  void _removeManifestItem(String variantId) {
    AppHaptics.medium();
    setState(() {
      _manifest.removeWhere((m) => m.variantId == variantId);
    });
  }

  void _clearManifest() {
    setState(() {
      _manifest.clear();
      _manifestNotesController.clear();
    });
  }

  Future<void> _submitManifest() async {
    if (_manifest.isEmpty) {
      AppToast.showInfo(context, 'أضف صنفاً واحداً على الأقل لإذن التوريد');
      return;
    }

    AppHaptics.medium();
    setState(() => _isSubmitting = true);

    final reasonLabel = switch (_selectedReason) {
      'purchase' => 'توريد شحنة بضاعة من المصنع',
      'inventory' => 'جرد وتصحيح رصيد المخزن',
      'return' => 'مرتجع بضاعة إلى المخزن',
      _ => 'إذن توريد مخزن',
    };

    final notes = _manifestNotesController.text.trim().isNotEmpty
        ? '$reasonLabel - ${_manifestNotesController.text.trim()}'
        : reasonLabel;

    try {
      final repo = ref.read(inventoryRepositoryProvider);

      for (final item in _manifest) {
        await repo.addInventoryItem(
          productVariantId: item.variantId,
          unitType: item.product.unitType,
          quantity: item.qty,
          notes: notes,
        );
      }

      // تحديث جميع المزودات والمخزن والكتالوج
      ref.invalidate(inventoryProvider(null));
      ref.invalidate(inventoryStatsProvider);
      ref.invalidate(lowStockCountProvider);
      ref.read(catalogHubProvider.notifier).invalidate();

      if (!mounted) return;
      final count = _manifest.length;
      final totalUnits = _manifest.fold(0.0, (s, m) => s + m.qty);

      _clearManifest();

      AppToast.showSuccess(
        context,
        'تم بنجاح اعتماد إذن التوريد لـ $count صنف (+${totalUnits.toStringAsFixed(0)} وحدة) وتحديث المخزون فوراً ✓',
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'خطأ أثناء تسجيل التوريد: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── التسوية المباشرة الفردية (Single Direct Modal) ──────────────────────

  void _showDirectAdjustmentModal(
    BuildContext context,
    EnrichedProduct product,
    EnrichedVariant variant,
  ) {
    showDialog(
      context: context,
      builder: (dlgCtx) => _DirectAdjustmentDialog(
        product: product,
        variant: variant,
        onSuccess: () {
          ref.invalidate(inventoryProvider(null));
          ref.invalidate(inventoryStatsProvider);
          ref.invalidate(lowStockCountProvider);
          ref.read(catalogHubProvider.notifier).invalidate();
        },
      ),
    );
  }

  // ─── مساعدات العرض والواجهة ──────────────────────────────────────────────

  Color _parseColor(String? colorString, Color fallback) {
    if (colorString == null || colorString.isEmpty) return fallback;
    final parts = colorString.split('|');
    final hex = (parts.length > 1 ? parts[1] : parts[0]).replaceAll('#', '');
    if (hex.length == 6 || hex.length == 8) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return fallback;
  }

  String _unitLabel(String unitType) {
    switch (unitType) {
      case 'rod':
        return 'عود';
      case 'panel':
        return 'لوح';
      case 'piece':
        return 'قطعة';
      case 'box':
        return 'علبة';
      case 'square_meter':
        return 'م2';
      case 'linear_meter':
        return 'م.ط';
      default:
        return 'وحدة';
    }
  }

  // ─── البناء الرئيسي للواجهة ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogHubProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
    final suppliers = suppliersAsync.value ?? [];

    final isWide = MediaQuery.of(context).size.width >= 920;

    // استخراج وتصفية الأصناف
    final allProducts = catalogState.allProducts;
    final List<Map<String, dynamic>> allItems = [];

    int totalVariantsCount = 0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (final p in allProducts) {
      for (final v in p.variants) {
        totalVariantsCount++;
        if (v.stockStatus == StockStatus.lowStock) lowStockCount++;
        if (v.stockStatus == StockStatus.outOfStock) outOfStockCount++;

        // Category filter
        if (_selectedCategory != null && p.category != _selectedCategory) {
          continue;
        }

        // Stock status filter
        if (_stockFilter == 'low' && v.stockStatus != StockStatus.lowStock) {
          continue;
        }
        if (_stockFilter == 'out' && v.stockStatus != StockStatus.outOfStock) {
          continue;
        }
        if (_stockFilter == 'in' && v.stockStatus != StockStatus.inStock) {
          continue;
        }

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase().trim();
          final searchable = [
            p.name,
            p.code,
            v.variantName,
            v.color ?? '',
            v.dimensions ?? '',
            v.supplierCode ?? '',
          ].join(' ').toLowerCase();

          if (!q.split(' ').every((term) => searchable.contains(term))) {
            continue;
          }
        }

        allItems.add({
          'product': p,
          'variant': v,
        });
      }
    }

    final totalManifestUnits = _manifest.fold(0.0, (s, m) => s + m.qty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'استلام وتوريد المخزون',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${allItems.length} صنف',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              ref.read(catalogHubProvider.notifier).invalidate();
              ref.invalidate(inventoryStatsProvider);
            },
          ),
          if (!isWide && _manifest.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Badge(
                label: Text('${_manifest.length}'),
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.receipt_long_rounded),
                  tooltip: 'عرض إذن التوريد',
                  onPressed: () => _showMobileManifestSheet(context, suppliers),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ─── شريط الإحصائيات السريع (KPI Bar) ─────────────────────
          _buildTopKpiStrip(totalVariantsCount, lowStockCount, outOfStockCount),

          // ─── شريط البحث والتصفية ──────────────────────────────────
          _buildFilterBar(catalogState.availableCategories),

          const Divider(height: 1),

          // ─── المحتوى الرئيسي: تقسيم متجاوب ─────────────────────────
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      // الكتالوج وقائمة الأصناف المتاحة للإضافة
                      Expanded(
                        flex: 6,
                        child: _buildItemsList(allItems),
                      ),

                      // الفاصل الرأسي
                      VerticalDivider(width: 1, color: AppColors.border),

                      // لوحة إذن التوريد الجاري (Manifest Panel)
                      Expanded(
                        flex: 4,
                        child: _buildManifestPanel(suppliers, totalManifestUnits),
                      ),
                    ],
                  )
                : _buildItemsList(allItems),
          ),
        ],
      ),
      // زر عائم للموبايل في حال وجود بنود في إذن التوريد
      bottomNavigationBar: (!isWide && _manifest.isNotEmpty)
          ? _buildMobileBottomBar(context, suppliers, totalManifestUnits)
          : null,
    );
  }

  // ─── شريط إحصائيات النواقص والرصيد ────────────────────────────────────────

  Widget _buildTopKpiStrip(int total, int low, int out) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          _kpiChip(
            label: 'إجمالي الأصناف',
            value: '$total',
            color: AppColors.primary,
            icon: Icons.inventory_2_outlined,
            isSelected: _stockFilter == 'all',
            onTap: () => setState(() => _stockFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _kpiChip(
            label: 'نواقص ومنخفض',
            value: '$low',
            color: const Color(0xFFF59E0B),
            icon: Icons.warning_amber_rounded,
            isSelected: _stockFilter == 'low',
            onTap: () => setState(() => _stockFilter = 'low'),
          ),
          const SizedBox(width: 8),
          _kpiChip(
            label: 'نفد بالكامل (0)',
            value: '$out',
            color: AppColors.error,
            icon: Icons.error_outline_rounded,
            isSelected: _stockFilter == 'out',
            onTap: () => setState(() => _stockFilter = 'out'),
          ),
          const Spacer(),
          if (_manifest.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'شحنة جارية: ${_manifest.length} صنف',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _kpiChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── شريط الفئات والبحث السريع ──────────────────────────────────────────

  Widget _buildFilterBar(List<String> categories) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // مربع البحث الذكي
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: GlassContainer(
            blur: 10,
            color: AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث بالأكواد، الألوان، المقاسات، أو اسم الموديل...',
                hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),

        // شرائح الفئات السريعة
        if (categories.isNotEmpty)
          Container(
            height: 44,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length + 1,
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  final isAll = _selectedCategory == null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: const Text('كل الأقسام'),
                      selected: isAll,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isAll ? FontWeight.w900 : FontWeight.w700,
                        color: isAll ? Colors.white : AppColors.textPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isAll ? AppColors.primary : AppColors.border, width: 1.2),
                      ),
                      onSelected: (sel) {
                        if (sel) setState(() => _selectedCategory = null);
                      },
                    ),
                  );
                }

                final cat = categories[idx - 1];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border, width: 1.2),
                    ),
                    onSelected: (sel) {
                      setState(() => _selectedCategory = sel ? cat : null);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ─── قائمة الأصناف والكتالوج التفاعلي ─────────────────────────────────────

  Widget _buildItemsList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'لا توجد أصناف مطابقة للبحث'
                  : 'لا توجد أصناف في هذا القسم',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final p = item['product'] as EnrichedProduct;
        final v = item['variant'] as EnrichedVariant;

        // التحقق إن كان الصنف مضافاً بالفعل في إذن التوريد الجاري
        final inManifestIdx = _manifest.indexWhere((m) => m.variantId == v.id);
        final manifestQty = inManifestIdx >= 0 ? _manifest[inManifestIdx].qty : 0.0;

        return _InventoryItemCard(
          product: p,
          variant: v,
          manifestQty: manifestQty,
          colorPreview: _parseColor(v.color, p.group?.color ?? AppColors.primary),
          unitLabel: _unitLabel(p.unitType),
          onAddQty: (qty) => _addItemToManifest(p, v, qty),
          onDirectAdjust: () => _showDirectAdjustmentModal(context, p, v),
        );
      },
    );
  }

  // ─── لوحة إذن التوريد (Manifest Panel) ───────────────────────────────────

  Widget _buildManifestPanel(List<Map<String, dynamic>> suppliers, double totalUnits) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان اللوحة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إذن استلام وتوريد الشحنة',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      Text(
                        _manifest.isEmpty
                            ? 'اضغط على +5 أو +10 على أي صنف لإضافته للشحنة'
                            : '${_manifest.length} صنف جاهز للاعتماد (+${totalUnits.toStringAsFixed(0)} قطعة)',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (_manifest.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearManifest,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                    label: const Text('إفراغ', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
              ],
            ),
          ),

          // قائمة البنود المضافة للشحنة
          Expanded(
            child: _manifest.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.post_add_rounded,
                            size: 64,
                            color: AppColors.textTertiary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لم تتم إضافة أصناف للشحنة بعد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'يمكنك استلام عدة أصناف وأكواد معاً واعتمادها بلمسة واحدة دون تكرار الإدخال',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _manifest.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = _manifest[idx];
                      final currentStock = item.variant.availableQty;
                      final newStock = currentStock + item.qty;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.product.name} - ${item.variant.variantName}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'الرصيد: ${currentStock.toStringAsFixed(0)}',
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                                      Text(
                                        ' يصبح: ${newStock.toStringAsFixed(0)} ${item.unitLabel}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // وحدة التحكم بالكمية
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                  onPressed: () => _updateManifestItemQty(item.variantId, item.qty - 1),
                                  color: AppColors.textSecondary,
                                ),
                                Container(
                                  width: 44,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '+${item.qty.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                  onPressed: () => _updateManifestItemQty(item.variantId, item.qty + 1),
                                  color: AppColors.primary,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => _removeManifestItem(item.variantId),
                                  color: AppColors.error,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // خيارات التوريد والمورد والملاحظات
          if (_manifest.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // سبب الحركة
                  Row(
                    children: [
                      _reasonChip('purchase', '🚚 توريد مصنع', Icons.factory_rounded),
                      const SizedBox(width: 6),
                      _reasonChip('inventory', '📋 جرد دوري', Icons.fact_check_rounded),
                      const SizedBox(width: 6),
                      _reasonChip('return', '↩️ مرتجع ورشة', Icons.replay_rounded),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // اختيار المورد (اختياري)
                  if (suppliers.isNotEmpty)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedSupplierId,
                      decoration: InputDecoration(
                        labelText: 'المورد (اختياري)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('بدون تحديد مورد')),
                        ...suppliers.map(
                          (s) => DropdownMenuItem(
                            value: s['id']?.toString(),
                            child: Text(s['name']?.toString() ?? 'مورد'),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedSupplierId = v),
                    ),
                  const SizedBox(height: 10),

                  // ملاحظات
                  TextField(
                    controller: _manifestNotesController,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات / رقم البوليصة / رقم الإذن (اختياري)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // زر الاعتماد الحاسم
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submitManifest,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_rounded),
                    label: Text(
                      _isSubmitting
                          ? 'جارٍ تحديث المخزون...'
                          : 'اعتماد إذن التوريد (+${totalUnits.toStringAsFixed(0)} وحدة) 🚀',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _reasonChip(String key, String label, IconData icon) {
    final isSel = _selectedReason == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedReason = key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                  color: isSel ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── واجهة الموبايل للشحنة السريعة ────────────────────────────────────────

  Widget _buildMobileBottomBar(
    BuildContext context,
    List<Map<String, dynamic>> suppliers,
    double totalUnits,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إذن توريد: ${_manifest.length} صنف',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                Text(
                  'الإجمالي: +${totalUnits.toStringAsFixed(0)} وحدة موردة',
                  style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showMobileManifestSheet(context, suppliers),
            icon: const Icon(Icons.receipt_long_rounded, size: 18),
            label: const Text('معاينة واعتماد'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileManifestSheet(
    BuildContext context,
    List<Map<String, dynamic>> suppliers,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: _buildManifestPanel(suppliers, _manifest.fold(0.0, (s, m) => s + m.qty)),
        ),
      ),
    );
  }
}

// ─── بطاقة الصنف التفاعلية في الكتالوج ────────────────────────────────────────

class _InventoryItemCard extends StatelessWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final double manifestQty;
  final Color colorPreview;
  final String unitLabel;
  final void Function(double qty) onAddQty;
  final VoidCallback onDirectAdjust;

  const _InventoryItemCard({
    required this.product,
    required this.variant,
    required this.manifestQty,
    required this.colorPreview,
    required this.unitLabel,
    required this.onAddQty,
    required this.onDirectAdjust,
  });

  Color get _statusColor {
    switch (variant.stockStatus) {
      case StockStatus.inStock:
        return AppColors.success;
      case StockStatus.lowStock:
        return const Color(0xFFF59E0B);
      case StockStatus.outOfStock:
        return AppColors.error;
    }
  }

  String get _statusText {
    switch (variant.stockStatus) {
      case StockStatus.inStock:
        return 'متوفر';
      case StockStatus.lowStock:
        return 'منخفض';
      case StockStatus.outOfStock:
        return 'نفد (0)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupColor = product.group?.color ?? AppColors.primary;
    final currentQty = variant.availableQty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: manifestQty > 0 ? AppColors.primary : AppColors.border,
          width: manifestQty > 0 ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السطر الأول: دائرة اللون، الاسم، الكود، والرصيد الحالي
            Row(
              children: [
                // دائرة اللون
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorPreview,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: [
                      BoxShadow(color: colorPreview.withValues(alpha: 0.3), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // الاسم والكود
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.name} - ${variant.variantName}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (product.code.isNotEmpty)
                            Text(
                              'كود: ${product.code}',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                          if (variant.dimensions != null && variant.dimensions!.isNotEmpty)
                            Text(
                              variant.dimensions!,
                              style: TextStyle(fontSize: 11, color: groupColor, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // مؤشر الرصيد الحالي بالمخزن
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${currentQty.toStringAsFixed(0)} $unitLabel ($_statusText)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (manifestQty > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${manifestQty.toStringAsFixed(0)} في إذن التوريد ➔ ${(currentQty + manifestQty).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // السطر الثاني: أزرار الإضافة السريعة (+5، +10، +25، +50) والتسوية المباشرة
            Row(
              children: [
                // زر التسوية المباشرة الفردية
                OutlinedButton.icon(
                  onPressed: onDirectAdjust,
                  icon: const Icon(Icons.tune_rounded, size: 15),
                  label: const Text('تسوية جرد', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
                const SizedBox(width: 8),

                Text(
                  'استلام وارد:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),

                // شرائح الكمية السريعة
                _addQtyChip('+5', 5),
                const SizedBox(width: 6),
                _addQtyChip('+10', 10),
                const SizedBox(width: 6),
                _addQtyChip('+25', 25),
                const SizedBox(width: 6),
                _addQtyChip('+50', 50),
                const SizedBox(width: 6),
                _addQtyChip('+100', 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _addQtyChip(String label, double qty) {
    return InkWell(
      onTap: () => onAddQty(qty),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─── نافذة التسوية المباشرة الفردية (Direct Adjustment Modal) ────────────────

class _DirectAdjustmentDialog extends ConsumerStatefulWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final VoidCallback onSuccess;

  const _DirectAdjustmentDialog({
    required this.product,
    required this.variant,
    required this.onSuccess,
  });

  @override
  ConsumerState<_DirectAdjustmentDialog> createState() =>
      _DirectAdjustmentDialogState();
}

class _DirectAdjustmentDialogState
    extends ConsumerState<_DirectAdjustmentDialog> {
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _mode = 'add'; // 'add', 'deduct', 'set'
  bool _isSaving = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _currentStock => widget.variant.availableQty;

  double get _computedStock {
    final input = double.tryParse(_qtyCtrl.text) ?? 0.0;
    switch (_mode) {
      case 'add':
        return _currentStock + input;
      case 'deduct':
        return (_currentStock - input).clamp(0, double.infinity);
      case 'set':
        return input;
      default:
        return _currentStock;
    }
  }

  Future<void> _submit() async {
    final input = double.tryParse(_qtyCtrl.text);
    if (input == null || input <= 0) {
      AppToast.showInfo(context, 'يرجى إدخال كمية صحيحة');
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(inventoryRepositoryProvider);

    try {
      if (_mode == 'add') {
        await repo.addInventoryItem(
          productVariantId: widget.variant.id,
          unitType: widget.product.unitType,
          quantity: input,
          notes: _notesCtrl.text.trim().isNotEmpty
              ? 'إضافة كمية واردة: ${_notesCtrl.text.trim()}'
              : 'إضافة وارد للمخزن',
        );
      } else if (_mode == 'deduct') {
        final existing = await repo.getInventoryItemByVariantId(widget.variant.id);
        if (existing != null) {
          await repo.recordMovement(
            inventoryItemId: existing['id'] as String,
            type: 'damaged',
            quantity: input,
            notes: _notesCtrl.text.trim().isNotEmpty
                ? 'صرف / تالف: ${_notesCtrl.text.trim()}'
                : 'صرف أو تسوية نقص',
          );
        }
      } else if (_mode == 'set') {
        final diff = input - _currentStock;
        if (diff != 0) {
          final existing = await repo.getInventoryItemByVariantId(widget.variant.id);
          if (existing != null) {
            await repo.recordMovement(
              inventoryItemId: existing['id'] as String,
              type: 'adjustment',
              quantity: diff,
              notes: _notesCtrl.text.trim().isNotEmpty
                  ? 'ضبط رصيد جرد: ${_notesCtrl.text.trim()}'
                  : 'تسوية رصيد فعلي بالجرد',
            );
          } else {
            await repo.addInventoryItem(
              productVariantId: widget.variant.id,
              unitType: widget.product.unitType,
              quantity: input,
              notes: 'جرد أولي',
            );
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess();
      AppToast.showSuccess(context, 'تم تحديث رصيد المخزن بنجاح ✓');
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'حدث خطأ: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('تسوية رصيد الصنف', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.product.name} - ${widget.variant.variantName}',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الرصيد الحالي
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الرصيد الحالي بالمخزن:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(
                      '${_currentStock.toStringAsFixed(0)} وحدة',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // محول نوع الحركة
              Row(
                children: [
                  _modeButton('add', '➕ إضافة وارد', AppColors.success),
                  const SizedBox(width: 6),
                  _modeButton('deduct', '➖ صرف / هالك', AppColors.error),
                  const SizedBox(width: 6),
                  _modeButton('set', '🎯 ضبط الرصيد', const Color(0xFF2563EB)),
                ],
              ),
              const SizedBox(height: 14),

              // حقل إدخال الكمية
              TextField(
                controller: _qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: _mode == 'set' ? 'الرصيد الفعلي بعد الجرد' : 'الكمية',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.numbers_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),

              // شرائح سريعة
              Wrap(
                spacing: 6,
                children: [
                  _quickChip(5),
                  _quickChip(10),
                  _quickChip(20),
                  _quickChip(50),
                  _quickChip(100),
                ],
              ),
              const SizedBox(height: 12),

              // المعاينة الحية للرصيد الجديد
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الرصيد النهائي بعد التسوية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '${_computedStock.toStringAsFixed(0)} وحدة',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // سبب / ملاحظات
              TextField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: 'ملاحظات الحركة (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(_isSaving ? 'جارٍ الحفظ...' : 'تأكيد التسوية ✓'),
        ),
      ],
    );
  }

  Widget _modeButton(String key, String label, Color color) {
    final isSel = _mode == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mode = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.15) : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? color : AppColors.border, width: isSel ? 1.5 : 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
              color: isSel ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickChip(int qty) {
    return ActionChip(
      label: Text('+$qty'),
      onPressed: () {
        final current = double.tryParse(_qtyCtrl.text) ?? 0.0;
        _qtyCtrl.text = (current + qty).toStringAsFixed(0);
        setState(() {});
      },
    );
  }
}
