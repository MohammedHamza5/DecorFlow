import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/utils/price_list_pdf_generator.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart'; // To use CategoryGroup
import 'package:stream_pay/shared/widgets/glass_container.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class PriceListScreen extends ConsumerStatefulWidget {
  const PriceListScreen({super.key});

  @override
  ConsumerState<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends ConsumerState<PriceListScreen> {
  // Catalog Configuration States
  String _scope = 'all'; // 'all' | 'group' | 'category'
  String? _selectedGroupId = CategoryGroup.defaults.first.id;
  String? _selectedCategory;
  String _layoutTemplate = 'grid'; // 'grid' | 'table' | 'text'
  bool _includeImages = true;
  bool _showPrices = true;
  String _priceType = 'both'; // 'net' | 'list' | 'both'
  bool _addCoverPage = true;

  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'كتالوج أسعار معرض السويدي للديكور');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'استوديو الكتالوج الذكي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('لا توجد منتجات مسجلة.'));
          }

          // Dynamic Categories list extracted from all products
          final allCategories = products
              .map((p) => p['category'] as String?)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();

          if (_selectedCategory == null && allCategories.isNotEmpty) {
            _selectedCategory = allCategories.first;
          }

          // Apply current filters dynamically to compute preview and export list
          List<Map<String, dynamic>> filteredProducts = products;
          if (_scope == 'group' && _selectedGroupId != null) {
            final group = CategoryGroup.defaults.firstWhere((g) => g.id == _selectedGroupId);
            filteredProducts = products.where((p) {
              final cat = p['category'] ?? '';
              return group.matchesCategory(cat);
            }).toList();
          } else if (_scope == 'category' && _selectedCategory != null) {
            filteredProducts = products.where((p) => p['category'] == _selectedCategory).toList();
          }

          return ConstrainedBody(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Control Studio Header Box
                  _buildStudioDashboard(allCategories),
                  const SizedBox(height: 20),

                  // 2. Export Preview Banner
                  _buildPreviewBanner(filteredProducts.length),
                  const SizedBox(height: 16),

                  // 3. Gold Action Button
                  _buildGenerateButton(filteredProducts),
                  const SizedBox(height: 24),

                  // 4. Preview list header
                  Row(
                    children: [
                      const Text(
                        'معاينة المنتجات المستهدفة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${filteredProducts.length} منتج',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. Product Preview Grid/List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = filteredProducts[index];
                      return _buildPreviewTile(p);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('خطأ في تحميل البيانات: $e')),
      ),
    );
  }

  // ─── Studio Dashboard Container ────────────────────────────────────
  Widget _buildStudioDashboard(List<String> allCategories) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'إعدادات وتخصيص الكتالوج',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Title Input
          const Text('عنوان الكتالوج الرئيسي:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background.withValues(alpha: 0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // 1. Export Scope Choice
          const Text('نطاق التصدير:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildScopeChip('all', 'كل المنتجات'),
              const SizedBox(width: 8),
              _buildScopeChip('group', 'مجموعة رئيسية'),
              const SizedBox(width: 8),
              _buildScopeChip('category', 'تصنيف محدد'),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Scope Detail Selectors
          if (_scope == 'group') ...[
            const Text('اختر المجموعة الرئيسية:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: CategoryGroup.defaults.map((group) {
                final isSel = _selectedGroupId == group.id;
                return ChoiceChip(
                  label: Text(group.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
                  selected: isSel,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background.withValues(alpha: 0.3),
                  side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) {
                    if (val) setState(() => _selectedGroupId = group.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ] else if (_scope == 'category' && allCategories.isNotEmpty) ...[
            const Text('اختر التصنيف المحدد:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                  isExpanded: true,
                  items: allCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 2. Layout template
          const Text('تخطيط الكتالوج:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLayoutCard('grid', 'كتالوج كروت', Icons.grid_view_rounded),
              const SizedBox(width: 8),
              _buildLayoutCard('table', 'جدول بصور', Icons.table_chart_rounded),
              const SizedBox(width: 8),
              _buildLayoutCard('text', 'جدول نصي', Icons.format_list_bulleted_rounded),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Option switches
          Container(
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildSwitchRow(
                  icon: Icons.image_rounded,
                  title: 'تضمين صور المنتجات',
                  subtitle: 'تترك فارغة إذا لم تتوفر صورة',
                  value: _includeImages,
                  onChanged: (val) => setState(() => _includeImages = val),
                ),
                const Divider(height: 16),
                _buildSwitchRow(
                  icon: Icons.menu_book_rounded,
                  title: 'إضافة صفحة غلاف فخمة',
                  subtitle: 'صفحة غلاف تحمل الهوية وعنوان الكتالوج',
                  value: _addCoverPage,
                  onChanged: (val) => setState(() => _addCoverPage = val),
                ),
                const Divider(height: 16),
                _buildSwitchRow(
                  icon: Icons.price_check_rounded,
                  title: 'عرض الأسعار في الكتالوج',
                  subtitle: 'تعطيله يسمح بعرض الكتالوج للزبائن فقط',
                  value: _showPrices,
                  onChanged: (val) => setState(() => _showPrices = val),
                ),
              ],
            ),
          ),

          // 4. Price Type Selectors (if showPrices is true)
          if (_showPrices) ...[
            const SizedBox(height: 16),
            const Text('نوع السعر المعروض:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriceTypeChip('net', 'الصافي فقط'),
                const SizedBox(width: 8),
                _buildPriceTypeChip('list', 'الليستة فقط'),
                const SizedBox(width: 8),
                _buildPriceTypeChip('both', 'كلاهما (الصافي والليستة)'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Auxiliary UI Builders ─────────────────────────────────────────
  Widget _buildScopeChip(String value, String label) {
    final isSel = _scope == value;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
        selected: isSel,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background.withValues(alpha: 0.3),
        side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
        onSelected: (val) {
          if (val) setState(() => _scope = value);
        },
      ),
    );
  }

  Widget _buildPriceTypeChip(String value, String label) {
    final isSel = _priceType == value;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
        selected: isSel,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background.withValues(alpha: 0.3),
        side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        showCheckmark: false,
        onSelected: (val) {
          if (val) setState(() => _priceType = value);
        },
      ),
    );
  }

  Widget _buildLayoutCard(String value, String label, IconData icon) {
    final isSel = _layoutTemplate == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _layoutTemplate = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? AppColors.primary : AppColors.secondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSel ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPreviewBanner(int count) {
    return GlassContainer(
      blur: 10,
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count > 0
                  ? 'سيتم تصدير عدد ($count) منتج متطابق مع الاختيارات السابقة.'
                  : 'لا توجد منتجات مطابقة للفلاتر الحالية! يرجى تغيير الإعدادات.',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(List<Map<String, dynamic>> filteredProducts) {
    final isDisabled = filteredProducts.isEmpty;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? AppColors.border : AppColors.primary,
          foregroundColor: isDisabled ? Colors.grey : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: isDisabled
            ? null
            : () async {
                // Show generating overlay/loader dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: AppColors.darkSurface,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'جاري تحضير الكتالوج وتحميل الصور...',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'يرجى الانتظار لحين معالجة البيانات',
                            style: TextStyle(fontSize: 12, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                try {
                  await PriceListPdfGenerator.generateAndPrint(
                    products: filteredProducts,
                    catalogTitle: _titleController.text,
                    layoutTemplate: _layoutTemplate,
                    includeImages: _includeImages,
                    showPrices: _showPrices,
                    priceType: _priceType,
                    addCoverPage: _addCoverPage,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('حدث خطأ أثناء تصدير الكتالوج: $e'), backgroundColor: AppColors.error),
                    );
                  }
                } finally {
                  // Hide loading dialog
                  if (mounted) Navigator.pop(context);
                }
              },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 22),
            SizedBox(width: 8),
            Text(
              'توليد الكتالوج الذكي الفاخر (PDF)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTile(Map<String, dynamic> p) {
    final name = p['name'] ?? 'بدون اسم';
    final code = p['code'] ?? 'بدون كود';
    final cat = p['category'] ?? 'غير مصنف';
    final imgUrl = p['image_url'] as String?;
    final brand = p['brand'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Dynamic image preview
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: (imgUrl != null && imgUrl.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_outlined, size: 20)),
                  )
                : const Icon(Icons.image_outlined, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                    ),
                    if (brand.toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '| $brand',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: AppColors.secondary),
        ],
      ),
    );
  }
}
