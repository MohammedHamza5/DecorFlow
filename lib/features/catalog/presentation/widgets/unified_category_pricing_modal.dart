import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/pricing_repository.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

// ─── Normalized Category Group Information ─────────────────────────────────

class CategoryGroupInfo {
  final String key;
  final String title;
  final IconData icon;
  final List<String> aliases;

  const CategoryGroupInfo({
    required this.key,
    required this.title,
    required this.icon,
    required this.aliases,
  });

  bool matches(String cat) {
    final lower = cat.trim().toLowerCase();
    return aliases.any((a) => lower.contains(a.toLowerCase()));
  }
}

const List<CategoryGroupInfo> kStandardCategoryGroups = [
  CategoryGroupInfo(
    key: 'بديل الرخام',
    title: 'بديل الرخام',
    icon: Icons.layers_rounded,
    aliases: ['بديل الرخام', 'بديل رخام', 'ألواح رخام', 'رخام', 'marble'],
  ),
  CategoryGroupInfo(
    key: 'بديل الخشب',
    title: 'بديل الخشب',
    icon: Icons.view_column_rounded,
    aliases: ['بديل الخشب', 'بديل خشب', 'شرائح خشب', 'تجليد خشب', 'wood', 'wpc'],
  ),
  CategoryGroupInfo(
    key: 'شيبورد',
    title: 'شيبورد',
    icon: Icons.table_restaurant_rounded,
    aliases: ['شيبورد', 'ألواح شيبورد', 'chipboard'],
  ),
  CategoryGroupInfo(
    key: 'بديل الحجر',
    title: 'بديل الحجر',
    icon: Icons.terrain_rounded,
    aliases: ['بديل الحجر', 'بديل حجر', 'حجر بو فوم', 'stone'],
  ),
  CategoryGroupInfo(
    key: 'بانوهات',
    title: 'بانوهات',
    icon: Icons.crop_square_rounded,
    aliases: ['بانوهات', 'بانوه', 'أعواد بانوهات', 'molding'],
  ),
  CategoryGroupInfo(
    key: 'كرانيش وفيوتك',
    title: 'كرانيش وفيوتك',
    icon: Icons.line_style_rounded,
    aliases: ['كرانيش', 'فيوتك', 'كرنيشة', 'كرانيش فيوتك السويدي'],
  ),
  CategoryGroupInfo(
    key: 'وزرات واستيل',
    title: 'وزرات واستيل',
    icon: Icons.border_bottom_rounded,
    aliases: ['وزرات', 'وزرة', 'استيل', 'استانلس', 'فواصل'],
  ),
  CategoryGroupInfo(
    key: 'إكسسوارات ومواد لاصقة',
    title: 'إكسسوارات ولاصق',
    icon: Icons.handyman_rounded,
    aliases: ['إكسسوارات', 'اكسسوارات', 'لاصق', 'سيليكون', 'معجون', 'غراء', 'مسامير'],
  ),
];

CategoryGroupInfo resolveCategoryGroup(String category) {
  final lower = category.trim().toLowerCase();
  for (final g in kStandardCategoryGroups) {
    if (g.matches(lower)) return g;
  }
  return CategoryGroupInfo(
    key: category,
    title: category,
    icon: Icons.auto_awesome,
    aliases: [category],
  );
}

/// المودال الموحد الذكي لتسعير فئة كاملة دفعة واحدة.
/// يربط مباشرة بقاعدة البيانات ويضمن تحديث 100% من أصناف الفئة محلياً وفي الـ State.
class UnifiedCategoryPricingModal extends ConsumerStatefulWidget {
  final String categoryTitle;
  final List<String> categoryAliases;
  final IconData icon;
  final int affectedCount;
  final double? initialSellingPrice;
  final double? initialTechPrice;
  final double? initialCostPrice;
  final double? initialMinPrice;
  final VoidCallback onSuccess;

  const UnifiedCategoryPricingModal({
    super.key,
    required this.categoryTitle,
    this.categoryAliases = const [],
    this.icon = Icons.auto_awesome,
    required this.affectedCount,
    this.initialSellingPrice,
    this.initialTechPrice,
    this.initialCostPrice,
    this.initialMinPrice,
    required this.onSuccess,
  });

  @override
  ConsumerState<UnifiedCategoryPricingModal> createState() =>
      _UnifiedCategoryPricingModalState();
}

class _UnifiedCategoryPricingModalState
    extends ConsumerState<UnifiedCategoryPricingModal> {
  late final TextEditingController _sellingCtrl;
  late final TextEditingController _techCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _minCtrl;

  double _selling = 0;
  double _cost = 0;
  double _tech = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selling = widget.initialSellingPrice ?? 0;
    _tech = widget.initialTechPrice ?? (_selling > 0 ? (_selling * 0.90).roundToDouble() : 0);
    _cost = widget.initialCostPrice ?? 0;

    _sellingCtrl = TextEditingController(
      text: _selling > 0 ? _selling.toStringAsFixed(0) : '',
    );
    _techCtrl = TextEditingController(
      text: _tech > 0 ? _tech.toStringAsFixed(0) : '',
    );
    _costCtrl = TextEditingController(
      text: _cost > 0 ? _cost.toStringAsFixed(0) : '',
    );
    _minCtrl = TextEditingController(
      text: widget.initialMinPrice != null && widget.initialMinPrice! > 0
          ? widget.initialMinPrice!.toStringAsFixed(0)
          : (_selling > 0 ? (_selling * 0.85).round().toString() : ''),
    );

    _sellingCtrl.addListener(() {
      final s = double.tryParse(_sellingCtrl.text) ?? 0;
      setState(() {
        _selling = s;
        if (s > 0) {
          if (_techCtrl.text.isEmpty || _tech == 0) {
            final t = (s * 0.90).roundToDouble();
            _techCtrl.text = t.toStringAsFixed(0);
            _tech = t;
          }
          if (_minCtrl.text.isEmpty) {
            _minCtrl.text = (s * 0.85).round().toString();
          }
        }
      });
    });

    _techCtrl.addListener(() {
      setState(() => _tech = double.tryParse(_techCtrl.text) ?? 0);
    });

    _costCtrl.addListener(() {
      setState(() => _cost = double.tryParse(_costCtrl.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _sellingCtrl.dispose();
    _techCtrl.dispose();
    _costCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _applyQuickDiscount(double percent) {
    if (_selling <= 0) return;
    final discounted = (_selling * (1.0 - percent / 100)).roundToDouble();
    _techCtrl.text = discounted.toStringAsFixed(0);
    setState(() => _tech = discounted);
  }

  Future<void> _submit() async {
    final selling = double.tryParse(_sellingCtrl.text) ?? 0;
    if (selling <= 0) {
      AppToast.showError(context, 'يرجى إدخال سعر بيع قطاعي صحيح أكبر من الصفر');
      return;
    }

    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final tech = double.tryParse(_techCtrl.text) ?? (selling * 0.90);
    final minPrice = double.tryParse(_minCtrl.text) ?? (selling * 0.85);

    if (minPrice > selling) {
      AppToast.showError(context, 'الحد الأدنى للبيع لا يمكن أن يكون أكبر من سعر البيع القطاعي');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final productRepo = ref.read(productRepositoryProvider);
      final pricingRepo = ref.read(pricingRepositoryProvider);

      // جمع جميع الأسماء المرادفة للفئة لضمان الشمول التام
      final aliases = <String>{
        widget.categoryTitle.trim(),
        ...widget.categoryAliases.map((a) => a.trim()),
      }.where((a) => a.isNotEmpty).toList();

      // 1. تحديث مباشر وقاطع في قاعدة البيانات SQLite لجميع أصناف الفئة
      final updatedCount = await productRepo.batchUpdateCategoryPricing(
        categoryAliases: aliases,
        sellingPrice: selling,
        technicianPrice: tech,
        costPrice: cost,
        minSellingPrice: minPrice,
      );

      // 2. حفظ / تحديث قاعدة التسعير العامة كمرجع مستقبلي
      await pricingRepo.saveRuleForSpec(
        category: widget.categoryTitle,
        costPrice: cost,
        sellingPrice: selling,
        technicianPrice: tech,
        minSellingPrice: minPrice,
        notes: 'تسعير موحد معتمد لقسم ${widget.categoryTitle}',
      );

      // 3. تحديث الـ State اللحظي
      ref.read(catalogHubProvider.notifier).invalidate();
      ref.invalidate(productsProvider);

      widget.onSuccess();

      if (!mounted) return;
      Navigator.pop(context);

      AppToast.showSuccess(
        context,
        'تم تسعير وتطبيق السعر الموحد بنجاح على $updatedCount صنفاً في قسم ${widget.categoryTitle} ✓',
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'حدث خطأ أثناء حفظ التسعير: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final retailProfit = (_selling - _cost).clamp(0, double.infinity);
    final retailProfitMargin = _selling > 0 ? (retailProfit / _selling) * 100 : 0.0;
    final techProfit = (_tech - _cost).clamp(0, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المقبض العلوي
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // رأس النافذة
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسعير موحد: ${widget.categoryTitle}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'سيتم تطبيق هذا السعر فورياً على (${widget.affectedCount}) صنفاً ⚡',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // حقل 1: سعر البيع قطاعي (الأساسي)
            TextField(
              controller: _sellingCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'سعر البيع قطاعي (ج.م) *',
                hintText: 'مثال: 650',
                prefixIcon: const Icon(Icons.sell_outlined, color: AppColors.success),
                suffixText: 'ج.م',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.success, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // حقل 2: سعر الفنيين والمهندسين مع أزرار الخصم السريع
            TextField(
              controller: _techCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'سعر الفنيين والمهندسين (ج.م)',
                hintText: 'افتراضياً خصم 10%',
                prefixIcon: const Icon(Icons.engineering_outlined, color: Color(0xFF2563EB)),
                suffixText: 'ج.م',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 6),

            // رقائق الخصم السريع للفني
            Row(
              children: [
                Text(
                  'خصم سريع للفني: ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(width: 4),
                _discountChip('10%', () => _applyQuickDiscount(10)),
                const SizedBox(width: 6),
                _discountChip('15%', () => _applyQuickDiscount(15)),
                const SizedBox(width: 6),
                _discountChip('20%', () => _applyQuickDiscount(20)),
              ],
            ),
            const SizedBox(height: 12),

            // حقل 3 و 4: سعر التكلفة والحد الأدنى للبيع
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'سعر التكلفة / الشراء (ج.م)',
                      prefixIcon: const Icon(Icons.receipt_outlined),
                      suffixText: 'ج.م',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'الحد الأدنى للبيع (ج.م)',
                      prefixIcon: const Icon(Icons.shield_outlined),
                      suffixText: 'ج.م',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // بطاقة المؤشرات المالية اللحظية
            if (_selling > 0 && _cost > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'هامش الربح القطاعي',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                        Text(
                          '+${retailProfit.toStringAsFixed(0)} ج (${retailProfitMargin.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 24, width: 1, color: AppColors.border),
                    Column(
                      children: [
                        Text(
                          'هامش ربح الفنيين',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                        Text(
                          '+${techProfit.toStringAsFixed(0)} ج',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),

            // زر الاعتماد
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.rocket_launch_rounded),
                label: Text(
                  _isSaving
                      ? 'جارٍ الاعتماد وتحديث الأصناف...'
                      : 'تأكيد واعتماد السعر لجميع الـ (${widget.affectedCount}) صنف 🚀',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discountChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
