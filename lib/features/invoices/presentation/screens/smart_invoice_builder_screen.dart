import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';

// ─── Constants ──────────────────────────────────────────────────────────────

const _kCategories = [
  _InvoiceCategory('all', 'الكل', Icons.grid_view_rounded, AppColors.primary),
  _InvoiceCategory('cladding', 'بدائل التشطيبات', Icons.dashboard_outlined, Color(0xFF059669)),
  _InvoiceCategory(
    'ceilings_walls',
    'ديكورات الأسقف والحوائط',
    Icons.home_outlined,
    Color(0xFF6366F1),
  ),
  _InvoiceCategory(
    'skirting_accessories',
    'وزرات وإكسسوارات',
    Icons.extension_outlined,
    Color(0xFFD97706),
  ),
  _InvoiceCategory('materials', 'خامات مساعدة', Icons.build_outlined, Color(0xFFDC2626)),
];

class _InvoiceCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  const _InvoiceCategory(this.id, this.label, this.icon, [this.color = AppColors.primary]);
}

// ─── Smart Sub-Categories ──────────────────────────────────────────────────

class SmartSubCategory {
  final String id;
  final String label;
  final String emoji;
  final String parentGroupId;
  final List<String> patterns;
  final List<String> negativePatterns;

  const SmartSubCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.parentGroupId,
    required this.patterns,
    this.negativePatterns = const [],
  });

  bool matches(EnrichedProduct p) {
    final cat = p.category.toLowerCase();
    final sub = (p.subcategory ?? '').toLowerCase();
    final name = p.name.toLowerCase();
    final mat = (p.material ?? '').toLowerCase();
    final code = p.code.toLowerCase();
    final notes = (p.notes ?? '').toLowerCase();

    // Check negative patterns first
    for (final neg in negativePatterns) {
      final n = neg.toLowerCase();
      if (cat.contains(n) || name.contains(n) || sub.contains(n)) {
        return false;
      }
    }

    // Check positive patterns
    for (final pat in patterns) {
      final patL = pat.toLowerCase();
      if (cat.contains(patL) ||
          sub.contains(patL) ||
          name.contains(patL) ||
          mat.contains(patL) ||
          code.contains(patL) ||
          notes.contains(patL)) {
        return true;
      }
      if (p.variants.any((v) =>
          v.variantName.toLowerCase().contains(patL) ||
          (v.color?.toLowerCase().contains(patL) ?? false))) {
        return true;
      }
    }

    return false;
  }
}

const _kSubCategories = [
  // ─── بدائل التشطيبات (cladding) ─────────────────────────
  SmartSubCategory(
    id: 'wood',
    label: 'بديل خشب',
    emoji: '🪵',
    parentGroupId: 'cladding',
    patterns: [
      'بديل خشب',
      'بديل الخشب',
      'تجليد خشب',
      'خشب كوري',
      'خشب تركي',
      'سداسي خشب',
      'لوفر خشب',
      'شرايح خشب',
      'ألواح خشب',
      'wpc',
      'خشب',
    ],
    negativePatterns: ['شيبورد', 'chipboard'],
  ),
  SmartSubCategory(
    id: 'marble',
    label: 'بديل رخام',
    emoji: '🏛️',
    parentGroupId: 'cladding',
    patterns: [
      'بديل رخام',
      'بديل الرخام',
      'رخام uv',
      'رخام ريزن',
      'رخام pvc',
      'ماربل',
      'marble',
      'رخام',
    ],
  ),
  SmartSubCategory(
    id: 'chipboard',
    label: 'شيبورد',
    emoji: '🟫',
    parentGroupId: 'cladding',
    patterns: [
      'شيبورد',
      'chipboard',
      'chi-',
    ],
  ),
  SmartSubCategory(
    id: 'stone',
    label: 'بديل حجر',
    emoji: '🪨',
    parentGroupId: 'cladding',
    patterns: [
      'بديل حجر',
      'بديل الحجر',
      'حجر فيوتك',
      'pu stone',
      'حجر صخري',
      'حجر صناعي',
      'حجر',
    ],
  ),

  // ─── ديكورات الأسقف والحوائط (ceilings_walls) ─────────────
  SmartSubCategory(
    id: 'mouldings',
    label: 'بانوهات',
    emoji: '🖼️',
    parentGroupId: 'ceilings_walls',
    patterns: [
      'بانوه',
      'بانوهات',
      'برواز',
      'براويز',
      'زوايا بانوه',
      'ركن بانوه',
    ],
  ),
  SmartSubCategory(
    id: 'cornices',
    label: 'كرانيش وبيت نور',
    emoji: '🏛️',
    parentGroupId: 'ceilings_walls',
    patterns: [
      'كرانيش',
      'كورنيش',
      'بيت نور',
      'شادو',
      'كوف',
      'مجرى إضاءة',
      'كرنيشة',
    ],
  ),
  SmartSubCategory(
    id: 'wall_3d',
    label: 'ألواح 3D',
    emoji: '🧱',
    parentGroupId: 'ceilings_walls',
    patterns: [
      '3d',
      'ثلاثية الأبعاد',
      'بلاطات 3d',
      'ألواح 3d',
      'ألواح جدارية',
    ],
  ),
  SmartSubCategory(
    id: 'medallions',
    label: 'صرر وإطارات',
    emoji: '⭕',
    parentGroupId: 'ceilings_walls',
    patterns: [
      'صرة',
      'صرر',
      'روزيت',
      'حلقة',
      'إطار دائم',
      'زخارف',
      'دائرية زخرفية',
    ],
  ),

  // ─── الوزرات والإكسسوارات (skirting_accessories) ─────────
  SmartSubCategory(
    id: 'skirting',
    label: 'وزرات',
    emoji: '📏',
    parentGroupId: 'skirting_accessories',
    patterns: [
      'وزر',
      'وزرات',
      'وزرة',
      'بالتو',
    ],
  ),
  SmartSubCategory(
    id: 'stainless',
    label: 'زوايا استانلس',
    emoji: '✨',
    parentGroupId: 'skirting_accessories',
    patterns: [
      'استانلس',
      'ستانلس',
      'زاوية استانلس',
      'زوايا استانلس',
      'stainless',
      'زاوية pvc',
    ],
  ),
  SmartSubCategory(
    id: 'profiles',
    label: 'بروفايلات وفواصل',
    emoji: '📐',
    parentGroupId: 'skirting_accessories',
    patterns: [
      'بروفايل',
      'بروفايلات',
      'فاصل',
      'فواصل',
      'نهاية',
      'نهايات',
      'تي بار',
      't-bar',
    ],
  ),

  // ─── الخامات المساعدة (materials) ───────────────────────
  SmartSubCategory(
    id: 'silicone',
    label: 'سيليكون وعظم',
    emoji: '🧴',
    parentGroupId: 'materials',
    patterns: [
      'سيليكون',
      'سليكون',
      'عظم',
      'لاصق عظم',
      'silicone',
      'مسدس',
    ],
  ),
  SmartSubCategory(
    id: 'adhesives',
    label: 'معجون ولواصق',
    emoji: '🧪',
    parentGroupId: 'materials',
    patterns: [
      'معجون',
      'غراء',
      'لاصق فيوتك',
      'paste',
      'مادة لاصقة',
    ],
  ),
  SmartSubCategory(
    id: 'fasteners',
    label: 'مسامير وتثبيت',
    emoji: '🔩',
    parentGroupId: 'materials',
    patterns: [
      'مسمار',
      'مسامير',
      'فيشر',
      'تثبيت',
      'كلبسات',
      'سوستة',
    ],
  ),
];

// ─── Invoice Line Item ───────────────────────────────────────────────────────

class _LineItem {
  final String variantId;
  final String productName;
  final String variantName;
  final String unit;
  final double defaultPrice;
  final double technicianPrice;
  final double costPrice;
  final Color categoryColor;
  String? imageUrl;
  final double minSellingPrice;

  double qty;
  double price;

  _LineItem({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.unit,
    required this.defaultPrice,
    this.technicianPrice = 0.0,
    this.costPrice = 0.0,
    required this.categoryColor,
    this.minSellingPrice = 0.0,
    this.imageUrl,
    this.qty = 1,
    double? price,
  }) : price = price ?? defaultPrice;

  double get total => qty * price;
  String get displayName => variantName.isNotEmpty && variantName != productName
      ? '$productName - $variantName'
      : productName;
}

// ─── Smart Invoice Builder Screen ───────────────────────────────────────────

class SmartInvoiceBuilderScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;
  final String? invoiceId; // if null → create new draft
  final List<Map<String, dynamic>>? initialItems;

  const SmartInvoiceBuilderScreen({
    super.key,
    this.customerId = 'cash_customer',
    this.customerName = 'عميل نقدي (كاش)',
    this.invoiceId,
    this.initialItems,
  });

  @override
  ConsumerState<SmartInvoiceBuilderScreen> createState() =>
      _SmartInvoiceBuilderScreenState();
}

class _SmartInvoiceBuilderScreenState
    extends ConsumerState<SmartInvoiceBuilderScreen>
    with SingleTickerProviderStateMixin {
  // ─── State ──────────────────────────────────────────────────────────────
  String _invoiceId = '';
  bool _isCreating = true; // creating the draft on load
  bool _isConfirming = false;

  String _selectedCategoryId = 'all';
  String? _selectedSubCategoryId;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final List<_LineItem> _lines = [];
  int _mobileTabIndex = 0; // 0 = Catalog, 1 = Cart
  bool _isTechnicianPrice = false;

  // ─── UI ─────────────────────────────────────────────────────────────────
  late final AnimationController _totalAnimCtrl;
  late final Animation<double> _totalScaleAnim;

  @override
  void initState() {
    super.initState();
    _totalAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _totalScaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _totalAnimCtrl, curve: Curves.easeOut));
    _initDraft();
  }

  @override
  void dispose() {
    _totalAnimCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Draft Lifecycle ────────────────────────────────────────────────────

  Future<void> _initDraft() async {
    if (widget.invoiceId != null) {
      setState(() {
        _invoiceId = widget.invoiceId!;
        _isCreating = false;
      });
      return;
    }
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      final id = await repo.createDirectInvoice(customerId: widget.customerId);

      // Populate initial items if provided (e.g., from Fast Calculator)
      if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
        for (final item in widget.initialItems!) {
          final pName = (item['product_name'] ?? item['productName'] ?? 'صنف تشطيب') as String;
          final vName = (item['variant_name'] ?? item['variantName'] ?? '') as String;
          final vId = (item['product_variant_id'] ?? item['variantId'] ?? 'item_${DateTime.now().millisecondsSinceEpoch}_${_lines.length}') as String;
          final unit = (item['unit'] ?? 'قطعة') as String;
          final qty = ((item['quantity'] ?? item['qty'] ?? 1.0) as num).toDouble();
          final price = ((item['unit_price'] ?? item['unitPrice'] ?? item['price'] ?? 0.0) as num).toDouble();

          _lines.add(_LineItem(
            variantId: vId,
            productName: pName,
            variantName: vName,
            unit: unit,
            defaultPrice: price,
            price: price,
            qty: qty,
            categoryColor: AppColors.primary,
          ));
        }
      }

      if (!mounted) return;
      setState(() {
        _invoiceId = id;
        _isCreating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      _showError('فشل إنشاء الفاتورة: $e');
    }
  }

  // ─── Line Item Management ────────────────────────────────────────────────

  void _addLine(_LineItem item) {
    HapticFeedback.lightImpact();
    final existing = _lines.indexWhere((l) => l.variantId == item.variantId);
    if (existing >= 0) {
      setState(() => _lines[existing].qty++);
    } else {
      setState(() => _lines.add(item));
    }
    _animateTotal();
  }

  void _removeLine(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _lines.removeAt(index));
    _animateTotal();
  }

  void _updateQty(int index, double qty) {
    setState(() => _lines[index].qty = qty.clamp(0.01, 99999));
    _animateTotal();
  }

  void _updatePrice(int index, double price) {
    setState(() => _lines[index].price = price.clamp(0, 9999999));
    _animateTotal();
  }

  void _setPricingTier(bool isTechnician) {
    if (_isTechnicianPrice == isTechnician) return;
    setState(() {
      _isTechnicianPrice = isTechnician;
      for (final line in _lines) {
        if (isTechnician) {
          line.price = line.technicianPrice > 0 ? line.technicianPrice : line.defaultPrice;
        } else {
          line.price = line.defaultPrice;
        }
      }
    });
    _animateTotal();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isTechnician ? 'تم التبديل إلى أسعار الفنيين والمهندسين 👷‍♂️' : 'تم التبديل إلى أسعار البيع القطاعي 🛍️',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isTechnician ? const Color(0xFF2563EB) : AppColors.primary,
      ),
    );
  }

  void _animateTotal() {
    _totalAnimCtrl.forward().then((_) => _totalAnimCtrl.reverse());
  }

  double get _grandTotal => _lines.fold(0.0, (s, l) => s + l.total);

  // ─── Confirm & Save ─────────────────────────────────────────────────────

  Future<void> _confirmInvoice({bool isImmediateCash = false}) async {
    if (_lines.isEmpty) {
      _showError('أضف منتجاً واحداً على الأقل قبل الاعتماد');
      return;
    }
    if (_invoiceId.isEmpty) return;

    // Validate minimum selling price
    for (final line in _lines) {
      if (line.minSellingPrice > 0 && line.price < line.minSellingPrice) {
        _showError(
          'لا يمكن اعتماد الفاتورة: سعر "${line.displayName}" (${line.price.toStringAsFixed(2)}) أقل من الحد الأدنى المسموح (${line.minSellingPrice.toStringAsFixed(2)})',
        );
        return;
      }
    }

    String? action;
    if (isImmediateCash) {
      action = 'cash';
    } else {
      action = await showDialog<String>(
        context: context,
        builder: (ctx) => _ConfirmDialog(
          customerName: widget.customerName,
          linesCount: _lines.length,
          grandTotal: _grandTotal,
        ),
      );
    }

    if (action == null || !mounted) return;

    setState(() => _isConfirming = true);
    try {
      final repo = ref.read(invoiceRepositoryProvider);

      // Push each line to the backend
      for (final line in _lines) {
        await repo.addItemToInvoice(
          invoiceId: _invoiceId,
          productVariantId: line.variantId,
          productName: line.displayName,
          unit: line.unit,
          quantity: line.qty,
          unitPrice: line.price,
        );
      }

      // Confirm (changes status draft → confirmed, deducts stock)
      await repo.confirmInvoice(_invoiceId);

      // If immediate cash, record payment now into CashFlow & update invoice to paid!
      if (action == 'cash') {
        await repo.recordPayment(
          invoiceId: _invoiceId,
          customerId: widget.customerId,
          amount: _grandTotal,
          paymentMethod: 'cash',
          notes: 'سداد نقدي فوري بنقطة البيع',
        );
      }

      if (!mounted) return;
      context.pushReplacement('/invoice/$_invoiceId');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      _showError('فشل اعتماد الفاتورة: $e');
    }
  }

  Future<void> _saveDraftAndExit() async {
    if (_invoiceId.isEmpty || _lines.isEmpty) {
      if (!mounted) return;
      context.pop();
      return;
    }
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      for (final line in _lines) {
        await repo.addItemToInvoice(
          invoiceId: _invoiceId,
          productVariantId: line.variantId,
          productName: line.displayName,
          unit: line.unit,
          quantity: line.qty,
          unitPrice: line.price,
        );
      }
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      _showError('فشل حفظ المسودة: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: TextDirection.rtl),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isCreating) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'جارٍ إنشاء الفاتورة...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final hub = ref.watch(catalogHubProvider);
    final allProducts = hub.allProducts;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          if (!isMobile || _mobileTabIndex == 0) ...[
            _buildCategoryFilter(),
            _buildSubCategoryFilter(allProducts),
            _buildActiveFilterBanner(),
            _buildSearchBar(),
          ],
          if (isMobile) _buildMobileTabSwitcher(),
          Expanded(
            child: isMobile
                ? (_mobileTabIndex == 0
                    ? _CatalogPanel(
                        categoryId: _selectedCategoryId,
                        subCategoryId: _selectedSubCategoryId,
                        searchQuery: _searchQuery,
                        addedVariantIds: _lines.map((l) => l.variantId).toSet(),
                        isTechnicianPrice: _isTechnicianPrice,
                        onClearSubFilter: () => setState(() => _selectedSubCategoryId = null),
                        onClearAllFilters: () => setState(() {
                          _selectedCategoryId = 'all';
                          _selectedSubCategoryId = null;
                          _searchCtrl.clear();
                          _searchQuery = '';
                        }),
                        onAdd: (item) {
                          _addLine(item);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة "${item.displayName}" للسلة', textDirection: TextDirection.rtl),
                              duration: const Duration(milliseconds: 1000),
                              action: SnackBarAction(
                                label: 'عرض السلة',
                                textColor: AppColors.primary,
                                onPressed: () => setState(() => _mobileTabIndex = 1),
                              ),
                            ),
                          );
                        },
                      )
                    : _CartPanel(
                        lines: _lines,
                        grandTotal: _grandTotal,
                        totalScaleAnim: _totalScaleAnim,
                        onRemove: _removeLine,
                        onQtyChanged: _updateQty,
                        onPriceChanged: _updatePrice,
                        onManualAdd: _showManualItemSheet,
                      ))
                : Row(
                    children: [
                      // Left panel — catalog
                      Expanded(
                        flex: 3,
                        child: _CatalogPanel(
                          categoryId: _selectedCategoryId,
                          subCategoryId: _selectedSubCategoryId,
                          searchQuery: _searchQuery,
                          addedVariantIds: _lines.map((l) => l.variantId).toSet(),
                          isTechnicianPrice: _isTechnicianPrice,
                          onClearSubFilter: () => setState(() => _selectedSubCategoryId = null),
                          onClearAllFilters: () => setState(() {
                            _selectedCategoryId = 'all';
                            _selectedSubCategoryId = null;
                            _searchCtrl.clear();
                            _searchQuery = '';
                          }),
                          onAdd: _addLine,
                        ),
                      ),
                      // Divider
                      VerticalDivider(width: 1, color: AppColors.border),
                      // Right panel — cart
                      Expanded(
                        flex: 2,
                        child: _CartPanel(
                          lines: _lines,
                          grandTotal: _grandTotal,
                          totalScaleAnim: _totalScaleAnim,
                          onRemove: _removeLine,
                          onQtyChanged: _updateQty,
                          onPriceChanged: _updatePrice,
                          onManualAdd: _showManualItemSheet,
                        ),
                      ),
                    ],
                  ),
          ),
          _buildBottomBar(isMobile),
        ],
      ),
    );
  }

  Widget _buildMobileTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mobileTabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _mobileTabIndex == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: _mobileTabIndex == 0 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الكتالوج والأصناف',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _mobileTabIndex == 0 ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mobileTabIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _mobileTabIndex == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: _mobileTabIndex == 1 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'سلة الفاتورة (${_lines.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _mobileTabIndex == 1 ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () {
              if (_lines.isEmpty) {
                context.pop();
              } else {
                _saveDraftAndExit();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فاتورة جديدة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.customerName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pricing Tier Toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _setPricingTier(false),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: !_isTechnicianPrice ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🛍️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'قطاعي',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: !_isTechnicianPrice ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _setPricingTier(true),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isTechnicianPrice ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👷‍♂️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'فنيين',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isTechnicianPrice ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Items count badge
          if (_lines.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${_lines.length} بند',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Category Filter ─────────────────────────────────────────────────────

  void _onCategorySelected(String catId) {
    setState(() {
      _selectedCategoryId = catId;
      if (_selectedSubCategoryId != null && catId != 'all') {
        final currentSub = _kSubCategories.cast<SmartSubCategory?>().firstWhere(
          (s) => s!.id == _selectedSubCategoryId,
          orElse: () => null,
        );
        if (currentSub?.parentGroupId != catId) {
          _selectedSubCategoryId = null;
        }
      }
    });
  }

  void _onSubCategorySelected(String? subId) {
    setState(() {
      if (_selectedSubCategoryId == subId) {
        _selectedSubCategoryId = null;
      } else {
        _selectedSubCategoryId = subId;
      }
    });
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 48,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _kCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = _kCategories[i];
          final selected = _selectedCategoryId == cat.id;
          final catColor = cat.color;
          return GestureDetector(
            onTap: () => _onCategorySelected(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? catColor : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? catColor : AppColors.border,
                  width: selected ? 1.5 : 1.0,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: catColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 15,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoryFilter(List<EnrichedProduct> allProducts) {
    List<SmartSubCategory> subCats;
    if (_selectedCategoryId == 'all') {
      subCats = _kSubCategories;
    } else {
      subCats = _kSubCategories.where((s) => s.parentGroupId == _selectedCategoryId).toList();
    }

    final activeCategory = _kCategories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => _kCategories.first,
    );
    final accentColor = activeCategory.color;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.4), width: 0.5),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        itemCount: subCats.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = _selectedSubCategoryId == null;
            return GestureDetector(
              onTap: () => _onSubCategorySelected(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: isAll
                      ? accentColor.withValues(alpha: 0.18)
                      : AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAll ? accentColor : AppColors.border.withValues(alpha: 0.6),
                    width: isAll ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _selectedCategoryId == 'all' ? 'جميع الأصناف' : 'الكل في القسم',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isAll ? FontWeight.w900 : FontWeight.w600,
                    color: isAll ? accentColor : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final sub = subCats[index - 1];
          final isSelected = _selectedSubCategoryId == sub.id;

          // Count matching products
          final count = allProducts.where((p) {
            if (_selectedCategoryId != 'all' && p.group?.id != _selectedCategoryId) {
              return false;
            }
            return sub.matches(p);
          }).length;

          return GestureDetector(
            onTap: () => _onSubCategorySelected(sub.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor
                    : AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.border.withValues(alpha: 0.6),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sub.emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    sub.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterBanner() {
    if (_selectedSubCategoryId == null) return const SizedBox.shrink();
    final sub = _kSubCategories.cast<SmartSubCategory?>().firstWhere(
      (s) => s!.id == _selectedSubCategoryId,
      orElse: () => null,
    );
    if (sub == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'تصفية نشطة: ${sub.emoji} ${sub.label} فقط',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => setState(() => _selectedSubCategoryId = null),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'عرض كل الفئة',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.close_rounded, size: 13, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ──────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        textDirection: TextDirection.rtl,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج، كود، أو لون...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Bar ──────────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Grand total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الإجمالي (${_lines.length} بند)',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                ScaleTransition(
                  scale: _totalScaleAnim,
                  child: Text(
                    '${_grandTotal.toStringAsFixed(0)} ج.م',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Draft save (wide screens)
          if (!isMobile) ...[
            OutlinedButton.icon(
              onPressed: _lines.isEmpty ? null : _saveDraftAndExit,
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('حفظ مسودة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          // Credit confirm
          OutlinedButton(
            onPressed: (_lines.isEmpty || _isConfirming)
                ? null
                : () => _confirmInvoice(isImmediateCash: false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'اعتماد آجل',
              style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          // Immediate Cash confirm
          FilledButton.icon(
            onPressed: (_lines.isEmpty || _isConfirming)
                ? null
                : () => _confirmInvoice(isImmediateCash: true),
            icon: _isConfirming
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
            label: Text(
              _isConfirming ? 'اعتماد...' : 'كاش فوري ⚡',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isMobile ? 12 : 13,
                color: Colors.white,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _lines.isEmpty
                  ? AppColors.surfaceVariant
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Manual Item Sheet ───────────────────────────────────────────────────

  void _showManualItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManualItemSheet(
        onAdd: (name, qty, price, unit) {
          _addLine(
            _LineItem(
              variantId: 'manual-${DateTime.now().millisecondsSinceEpoch}',
              productName: name,
              variantName: '',
              unit: unit,
              defaultPrice: price,
              categoryColor: AppColors.textSecondary,
              qty: qty,
            ),
          );
        },
      ),
    );
  }
}

// ─── Catalog Panel ────────────────────────────────────────────────────────

class _CatalogPanel extends ConsumerWidget {
  final String categoryId;
  final String? subCategoryId;
  final String searchQuery;
  final Set<String> addedVariantIds;
  final bool isTechnicianPrice;
  final void Function(_LineItem) onAdd;
  final VoidCallback? onClearSubFilter;
  final VoidCallback? onClearAllFilters;

  const _CatalogPanel({
    required this.categoryId,
    this.subCategoryId,
    required this.searchQuery,
    required this.addedVariantIds,
    this.isTechnicianPrice = false,
    required this.onAdd,
    this.onClearSubFilter,
    this.onClearAllFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hub = ref.watch(catalogHubProvider);
    final allProducts = hub.allProducts;

    // Filter by category group
    List<EnrichedProduct> filtered = allProducts.where((p) {
      if (categoryId == 'all') return true;
      final group = p.group;
      if (group == null) return false;
      return group.id == categoryId;
    }).toList();

    // Filter by smart subcategory
    if (subCategoryId != null && subCategoryId != 'all') {
      final sub = _kSubCategories.cast<SmartSubCategory?>().firstWhere(
        (s) => s!.id == subCategoryId,
        orElse: () => null,
      );
      if (sub != null) {
        filtered = filtered.where((p) => sub.matches(p)).toList();
      }
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            (p.subcategory?.toLowerCase().contains(q) ?? false) ||
            (p.material?.toLowerCase().contains(q) ?? false) ||
            p.variants.any(
              (v) =>
                  v.variantName.toLowerCase().contains(q) ||
                  (v.color?.toLowerCase().contains(q) ?? false) ||
                  (v.dimensions?.toLowerCase().contains(q) ?? false),
            );
      }).toList();
    }

    if (filtered.isEmpty) {
      final hasSub = subCategoryId != null;
      final hasSearch = searchQuery.isNotEmpty;
      final sub = hasSub
          ? _kSubCategories.cast<SmartSubCategory?>().firstWhere(
              (s) => s!.id == subCategoryId,
              orElse: () => null,
            )
          : null;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textTertiary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                hasSearch && hasSub
                    ? 'لا توجد نتائج لكلمة "$searchQuery" داخل ${sub?.label ?? "هذا الصنف"}'
                    : hasSearch
                        ? 'لا توجد نتائج للبحث عن "$searchQuery"'
                        : hasSub
                            ? 'لا توجد منتجات مسجلة في صنف "${sub?.label ?? ""}"'
                            : 'لا توجد منتجات في هذه الفئة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              if (hasSub && onClearSubFilter != null) ...[
                OutlinedButton.icon(
                  onPressed: onClearSubFilter,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'عرض جميع أصناف القسم (${_kCategories.firstWhere((c) => c.id == categoryId, orElse: () => _kCategories.first).label})',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else if (hasSearch && onClearAllFilters != null) ...[
                OutlinedButton.icon(
                  onPressed: onClearAllFilters,
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: const Text('البحث في كامل الكتالوج'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final product = filtered[i];
        return _ProductCatalogCard(
          product: product,
          addedVariantIds: addedVariantIds,
          isTechnicianPrice: isTechnicianPrice,
          onAdd: onAdd,
        );
      },
    );
  }
}

// ─── Product Catalog Card ─────────────────────────────────────────────────

class _ProductCatalogCard extends StatelessWidget {
  final EnrichedProduct product;
  final Set<String> addedVariantIds;
  final bool isTechnicianPrice;
  final void Function(_LineItem) onAdd;

  const _ProductCatalogCard({
    required this.product,
    required this.addedVariantIds,
    this.isTechnicianPrice = false,
    required this.onAdd,
  });

  Color get _groupColor => product.group?.color ?? AppColors.primary;

  String _unitLabel(String type) {
    const m = {
      'rod': 'عود',
      'panel': 'لوح',
      'linear_meter': 'م.ط',
      'square_meter': 'م2',
      'roll': 'رول',
      'box': 'كرتونة',
      'piece': 'قطعة',
      'tube': 'أنبوبة',
      'container': 'عبوة',
    };
    return m[type] ?? type;
  }

  @override
  Widget build(BuildContext context) {
    // Show product name header and then each variant as a row
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _groupColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (product.category.isNotEmpty && product.category != product.name)
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: _groupColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (product.code.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _groupColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.code,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _groupColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Variants
          ...product.variants.map((v) {
            final alreadyAdded = addedVariantIds.contains(v.id);
            final retailPrice = v.sellingPrice > 0 ? v.sellingPrice : 0.0;
            final techPrice = v.technicianPrice > 0 ? v.technicianPrice : retailPrice;
            final activePrice = isTechnicianPrice ? techPrice : retailPrice;
            final hasPrice = activePrice > 0;
            return _VariantRow(
              variant: v,
              activePrice: activePrice,
              isTechnicianPrice: isTechnicianPrice,
              groupColor: _groupColor,
              unitLabel: _unitLabel(product.unitType),
              alreadyAdded: alreadyAdded,
              hasPrice: hasPrice,
              onAdd: () => onAdd(
                _LineItem(
                  variantId: v.id,
                  productName: product.name,
                  variantName: v.variantName == product.name
                      ? ''
                      : v.variantName,
                  unit: _unitLabel(product.unitType),
                  defaultPrice: retailPrice,
                  technicianPrice: techPrice,
                  costPrice: v.costPrice,
                  price: activePrice,
                  minSellingPrice: v.minSellingPrice,
                  categoryColor: _groupColor,
                  imageUrl: v.imageUrl ?? product.imageUrl,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Variant Row ──────────────────────────────────────────────────────────

class _VariantRow extends StatelessWidget {
  final EnrichedVariant variant;
  final double activePrice;
  final bool isTechnicianPrice;
  final Color groupColor;
  final String unitLabel;
  final bool alreadyAdded;
  final bool hasPrice;
  final VoidCallback onAdd;

  const _VariantRow({
    required this.variant,
    required this.activePrice,
    this.isTechnicianPrice = false,
    required this.groupColor,
    required this.unitLabel,
    required this.alreadyAdded,
    required this.hasPrice,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Row(
          children: [
            // Color swatch / image indicator
            _ColorDot(colorString: variant.color, fallbackColor: groupColor),
            const SizedBox(width: 10),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.variantName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasPrice)
                    Row(
                      children: [
                        Text(
                          '${activePrice.toStringAsFixed(0)} ج.م / $unitLabel',
                          style: TextStyle(
                            fontSize: 11,
                            color: isTechnicianPrice ? const Color(0xFF2563EB) : groupColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isTechnicianPrice) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'فنيين',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Text(
                      'يحدد السعر لاحقاً',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Add button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: alreadyAdded
                    ? groupColor.withValues(alpha: 0.2)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                alreadyAdded ? Icons.add_circle_rounded : Icons.add_rounded,
                color: alreadyAdded ? groupColor : Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cart Panel ───────────────────────────────────────────────────────────

class _CartPanel extends StatelessWidget {
  final List<_LineItem> lines;
  final double grandTotal;
  final Animation<double> totalScaleAnim;
  final void Function(int) onRemove;
  final void Function(int, double) onQtyChanged;
  final void Function(int, double) onPriceChanged;
  final VoidCallback onManualAdd;

  const _CartPanel({
    required this.lines,
    required this.grandTotal,
    required this.totalScaleAnim,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onPriceChanged,
    required this.onManualAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 56,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'القائمة فارغة',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onManualAdd,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('أو أضف بنداً يدوياً'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Text(
                'بنود الفاتورة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onManualAdd,
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('بند يدوي', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lines
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            itemCount: lines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, i) => _CartLineCard(
              index: i,
              line: lines[i],
              onRemove: () => onRemove(i),
              onQtyChanged: (q) => onQtyChanged(i, q),
              onPriceChanged: (p) => onPriceChanged(i, p),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Cart Line Card ───────────────────────────────────────────────────────

class _CartLineCard extends StatefulWidget {
  final int index;
  final _LineItem line;
  final VoidCallback onRemove;
  final void Function(double) onQtyChanged;
  final void Function(double) onPriceChanged;

  const _CartLineCard({
    required this.index,
    required this.line,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onPriceChanged,
  });

  @override
  State<_CartLineCard> createState() => _CartLineCardState();
}

class _CartLineCardState extends State<_CartLineCard> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: _fmt(widget.line.qty));
    _priceCtrl = TextEditingController(
      text: widget.line.price.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant _CartLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line.qty != widget.line.qty) {
      final currentTextVal = double.tryParse(_qtyCtrl.text) ?? 0.0;
      if (currentTextVal != widget.line.qty) {
        final newText = _fmt(widget.line.qty);
        _qtyCtrl.value = _qtyCtrl.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
    if (oldWidget.line.price != widget.line.price) {
      final currentTextVal = double.tryParse(_priceCtrl.text) ?? 0.0;
      if (currentTextVal != widget.line.price) {
        final newText = widget.line.price.toStringAsFixed(0);
        _priceCtrl.value = _priceCtrl.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: line.categoryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + remove
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: line.categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  line.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Qty + Price inputs
          Row(
            children: [
              // Qty
              Expanded(
                child: _MiniInput(
                  controller: _qtyCtrl,
                  label: 'الكمية',
                  suffix: line.unit,
                  color: line.categoryColor,
                  onCalcTapped: (line.unit == 'م2' || line.unit == 'م.ط')
                      ? () async {
                          final res = await showDialog<double>(
                            context: context,
                            builder: (ctx) => _DimCalcDialog(
                              unit: line.unit,
                              color: line.categoryColor,
                            ),
                          );
                          if (res != null && res > 0) {
                            widget.onQtyChanged(res);
                          }
                        }
                      : null,
                  onChanged: (v) {
                    v = v
                        .replaceAll('١', '1')
                        .replaceAll('٢', '2')
                        .replaceAll('٣', '3')
                        .replaceAll('٤', '4')
                        .replaceAll('٥', '5')
                        .replaceAll('٦', '6')
                        .replaceAll('٧', '7')
                        .replaceAll('٨', '8')
                        .replaceAll('٩', '9')
                        .replaceAll('٠', '0');
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed > 0) {
                      widget.onQtyChanged(parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              // Price
              Expanded(
                child: _MiniInput(
                  controller: _priceCtrl,
                  label: 'السعر',
                  suffix: 'ج.م',
                  color: line.categoryColor,
                  onChanged: (v) {
                    v = v
                        .replaceAll('١', '1')
                        .replaceAll('٢', '2')
                        .replaceAll('٣', '3')
                        .replaceAll('٤', '4')
                        .replaceAll('٥', '5')
                        .replaceAll('٦', '6')
                        .replaceAll('٧', '7')
                        .replaceAll('٨', '8')
                        .replaceAll('٩', '9')
                        .replaceAll('٠', '0');
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      widget.onPriceChanged(parsed);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Total line
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'الإجمالي: ',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              Text(
                '${line.total.toStringAsFixed(0)} ج.م',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mini Input ───────────────────────────────────────────────────────────

class _MiniInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final Color color;
  final void Function(String) onChanged;
  final VoidCallback? onCalcTapped;

  const _MiniInput({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.color,
    required this.onChanged,
    this.onCalcTapped,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: color),
        suffixText: suffix,
        suffixStyle: TextStyle(fontSize: 10, color: AppColors.textTertiary),
        prefixIcon: onCalcTapped != null
            ? InkWell(
                onTap: onCalcTapped,
                borderRadius: BorderRadius.circular(8),
                child: Icon(Icons.calculate_outlined, size: 16, color: color),
              )
            : null,
        prefixIconConstraints: onCalcTapped != null
            ? const BoxConstraints(minWidth: 32, minHeight: 32)
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Dimension Calculator Dialog ──────────────────────────────────────────

class _DimCalcDialog extends StatefulWidget {
  final String unit;
  final Color color;
  const _DimCalcDialog({required this.unit, required this.color});

  @override
  State<_DimCalcDialog> createState() => _DimCalcDialogState();
}

class _DimCalcDialogState extends State<_DimCalcDialog> {
  final _lCtrl = TextEditingController();
  final _wCtrl = TextEditingController();

  void _submit() {
    final l =
        double.tryParse(
          _lCtrl.text
              .replaceAll('١', '1')
              .replaceAll('٢', '2')
              .replaceAll('٣', '3')
              .replaceAll('٤', '4')
              .replaceAll('٥', '5')
              .replaceAll('٦', '6')
              .replaceAll('٧', '7')
              .replaceAll('٨', '8')
              .replaceAll('٩', '9')
              .replaceAll('٠', '0'),
        ) ??
        0.0;
    final w =
        double.tryParse(
          _wCtrl.text
              .replaceAll('١', '1')
              .replaceAll('٢', '2')
              .replaceAll('٣', '3')
              .replaceAll('٤', '4')
              .replaceAll('٥', '5')
              .replaceAll('٦', '6')
              .replaceAll('٧', '7')
              .replaceAll('٨', '8')
              .replaceAll('٩', '9')
              .replaceAll('٠', '0'),
        ) ??
        1.0;
    if (l > 0) {
      final total = widget.unit == 'م2' ? (l * w) : l;
      Navigator.pop(context, total);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSq = widget.unit == 'م2';
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.calculate_rounded, color: widget.color),
          const SizedBox(width: 8),
          Text(
            'حساب المقاسات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _lCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isSq ? 'الطول (متر)' : 'المقاس (متر طولي)',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (isSq) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _wCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'العرض (متر)',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'حساب وإضافة',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

// ─── Color Dot ────────────────────────────────────────────────────────────

class _ColorDot extends StatelessWidget {
  final String? colorString;
  final Color fallbackColor;

  const _ColorDot({this.colorString, required this.fallbackColor});

  Color _parseColor(String? raw) {
    if (raw == null || raw.isEmpty) return fallbackColor;
    final hex = raw.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.tryParse('FF$hex', radix: 16) ?? 0xFFDAA520);
    }
    return fallbackColor;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(colorString);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
    );
  }
}

// ─── Manual Item Sheet ────────────────────────────────────────────────────

class _ManualItemSheet extends StatefulWidget {
  final void Function(String name, double qty, double price, String unit) onAdd;

  const _ManualItemSheet({required this.onAdd});

  @override
  State<_ManualItemSheet> createState() => _ManualItemSheetState();
}

class _ManualItemSheetState extends State<_ManualItemSheet> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  String _unit = 'لوح';

  static const _units = [
    'لوح',
    'عود',
    'م.ط',
    'م2',
    'كرتونة',
    'رول',
    'قطعة',
    'أنبوبة',
    'عبوة',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qtyCtrl.text) ?? 1.0;
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    widget.onAdd(name, qty, price, _unit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'إضافة بند يدوي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            textDirection: TextDirection.rtl,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'اسم المنتج أو الخدمة',
              labelStyle: TextStyle(color: AppColors.primary, fontSize: 13),
              prefixIcon: Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'السعر (ج.م)',
                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Unit selector
          Wrap(
            spacing: 6,
            children: _units.map((u) {
              final selected = _unit == u;
              return ChoiceChip(
                label: Text(u, style: TextStyle(fontSize: 12)),
                selected: selected,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                onSelected: (_) => setState(() => _unit = u),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'إضافة للفاتورة',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Dialog ───────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String customerName;
  final int linesCount;
  final double grandTotal;

  const _ConfirmDialog({
    required this.customerName,
    required this.linesCount,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'تأكيد اعتماد الفاتورة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row('العميل', customerName),
          const SizedBox(height: 8),
          _Row('عدد البنود', '$linesCount بند'),
          const SizedBox(height: 8),
          _Row(
            'الإجمالي',
            '${grandTotal.toStringAsFixed(0)} ج.م',
            highlight: true,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'بعد الاعتماد سيتم خصم الكميات من المخزون تلقائياً ولا يمكن التعديل.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(
            'إلغاء',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, 'credit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('اعتماد آجل'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, 'cash'),
          icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          label: const Text(
            'اعتماد وكاش فوري ⚡',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Row(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: highlight ? 16 : 13,
          ),
        ),
      ],
    );
  }
}
