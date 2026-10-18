import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/domain/smart_catalog_filters.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// Upgraded Material Picker Modal (محدد الخامات الذكي المتطور)
/// 
/// Replaces the cramped, unstyled mobile sheet with a modern, high-contrast,
/// categorized dialog featuring prices, stock levels, and instant quantity selection.
/// ══════════════════════════════════════════════════════════════════════════════

class MaterialPickerModal extends ConsumerStatefulWidget {
  const MaterialPickerModal({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    if (isWide) {
      return showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: MaterialPickerModal(),
        ),
      );
    } else {
      return showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const MaterialPickerModal(),
      );
    }
  }

  @override
  ConsumerState<MaterialPickerModal> createState() => _MaterialPickerModalState();
}

class _MaterialPickerModalState extends ConsumerState<MaterialPickerModal> {
  String _searchQuery = '';
  String? _selectedSubCategoryId;

  Map<String, dynamic>? _selectedProduct;
  Map<String, dynamic>? _selectedVariant;
  double _wastePercent = 10.0;
  String _calcMode = 'standard';
  final _qtyCtrl = TextEditingController(text: '1.0');
  final _priceCtrl = TextEditingController(text: '0.0');

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(catalogHubProvider);
    final allProducts = hub.allProducts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter by Subcategory
    List filtered = allProducts;
    if (_selectedSubCategoryId != null) {
      final sub = kDefaultSmartSubCategories.cast<SmartSubCategory?>().firstWhere(
            (s) => s?.id == _selectedSubCategoryId,
            orElse: () => null,
          );
      if (sub != null) {
        filtered = filtered.where((p) => sub.matches(p)).toList();
      }
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        final name = p.name.toLowerCase();
        final code = p.code.toLowerCase();
        return name.contains(q) || code.contains(q);
      }).toList();
    }

    return Container(
      width: 780,
      height: 640,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category_rounded, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اختيار خامة من كتالوج المعرض',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        'حدد الخامة والموديل والكمية لتضمينها في الحساب والمقايسة',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          if (_selectedProduct == null) ...[
            // ─── Search Bar ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم الخامة أو كود الصنف (مثلاً بديل خشب أو 952)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              ),
            ),

            // ─── Quick Subcategory Chips ───
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kDefaultSmartSubCategories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    final isAll = _selectedSubCategoryId == null;
                    return ChoiceChip(
                      label: const Text('الكل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      selected: isAll,
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _selectedSubCategoryId = null),
                    );
                  }
                  final sub = kDefaultSmartSubCategories[i - 1];
                  final isSel = _selectedSubCategoryId == sub.id;
                  return ChoiceChip(
                    label: Text('${sub.emoji} ${sub.label}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    onSelected: (val) => setState(() => _selectedSubCategoryId = val ? sub.id : null),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            // ─── Products List ───
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textTertiary),
                          const SizedBox(height: 8),
                          Text('لا توجد خامات مطابقة للبحث', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 6),
                      itemBuilder: (ctx, i) {
                        final p = filtered[i];
                        final price = p.maxNetPrice > 0 ? p.maxNetPrice : p.minNetPrice;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.architecture_rounded, color: AppColors.primary, size: 22),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                  ),
                                ),
                                if (p.code.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(p.code, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(p.category, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const Spacer(),
                                Text(
                                  '${price.toStringAsFixed(0)} ج.م',
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                            onTap: () {
                              AppHaptics.selection();
                              final pMap = {
                                'id': p.id,
                                'name': p.name,
                                'category': p.category,
                                'code': p.code,
                                'unit_type': p.unitType,
                                'base_price': price,
                                'product_variants': p.variants.map((v) => {
                                  'id': v.id,
                                  'variant_name': v.variantName,
                                  'default_waste_percent': 10.0,
                                  'min_selling_price': v.minSellingPrice,
                                  'selling_price': v.sellingPrice > 0 ? v.sellingPrice : price,
                                }).toList(),
                              };
                              setState(() {
                                _selectedProduct = pMap;
                                final variants = pMap['product_variants'] as List? ?? [];
                                if (variants.isNotEmpty) {
                                  _selectedVariant = variants.first;
                                  _priceCtrl.text = (_selectedVariant!['selling_price'] as num?)?.toStringAsFixed(0) ?? price.toStringAsFixed(0);
                                } else {
                                  _priceCtrl.text = price.toStringAsFixed(0);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            // ─── Step 2: Configure Selected Material (Inline) ───
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Item Badge
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.arrow_forward_rounded),
                          tooltip: 'الرجوع لاختيار خامة أخرى',
                          onPressed: () => setState(() {
                            _selectedProduct = null;
                            _selectedVariant = null;
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedProduct!['name'],
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              Text(
                                '${_selectedProduct!['category'] ?? ""} ${_selectedProduct!['code'] != null ? "• كود: ${_selectedProduct!['code']}" : ""}',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 14),

                    // Variant selector if multiple
                    if (((_selectedProduct!['product_variants'] as List?) ?? []).length > 1) ...[
                      const Text('الموديل / اللون:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ((_selectedProduct!['product_variants'] as List?) ?? []).map((v) {
                          final isSel = _selectedVariant?['id'] == v['id'];
                          return ChoiceChip(
                            label: Text(v['variant_name'] ?? 'افتراضي'),
                            selected: isSel,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedVariant = v;
                                  final p = (v['selling_price'] as num?)?.toDouble() ?? 0.0;
                                  if (p > 0) _priceCtrl.text = p.toStringAsFixed(0);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Quantity and Price Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'الكمية المطلوبة (${_selectedProduct!['unit_type'] ?? "وحدة"})',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'سعر الوحدة (ج.م)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Waste Percent and Calc Mode
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            value: _wastePercent,
                            decoration: const InputDecoration(
                              labelText: 'نسبة الهالك المقدرة',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 0.0, child: Text('بدون هالك (0%)')),
                              DropdownMenuItem(value: 5.0, child: Text('هالك قياسي (5%)')),
                              DropdownMenuItem(value: 10.0, child: Text('هالك معتاد (10%)')),
                              DropdownMenuItem(value: 15.0, child: Text('هالك زوايا ودوران (15%)')),
                            ],
                            onChanged: (v) => setState(() => _wastePercent = v ?? 10.0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _calcMode,
                            decoration: const InputDecoration(
                              labelText: 'طريقة الحساب',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'standard', child: Text('قياسي (بالوحدة)')),
                              DropdownMenuItem(value: 'vertical', child: Text('أعواد - رأسي')),
                              DropdownMenuItem(value: 'horizontal', child: Text('أعواد - أفقي')),
                            ],
                            onChanged: (v) => setState(() => _calcMode = v ?? 'standard'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _selectedProduct = null;
                      _selectedVariant = null;
                    }),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 1.0;
                        final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;

                        Navigator.pop(context, {
                          'product': _selectedProduct,
                          'variant': _selectedVariant ?? (_selectedProduct!['product_variants'] as List).first,
                          'quantity': qty,
                          'unit_price': price,
                          'total_price': qty * price,
                          'waste_percent': _wastePercent,
                          'calc_mode': _calcMode,
                        });
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('اعتماد وإضافة للمقايسة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
