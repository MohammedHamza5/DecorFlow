import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/features/catalog/domain/smart_catalog_filters.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// Smart Quote Studio Screen (استوديو عروض الأسعار والمقايسات الذكي الموحد)
///
/// تم تطوير وتوحيد واجهة المستخدم بالكامل لتطابق شاشة الفاتورة الجديدة (SmartInvoiceBuilderScreen)
/// في الهيكل البصري، الكروت، سرعة الإضافة، وفصل الكتالوج عن بنود العرض.
/// ══════════════════════════════════════════════════════════════════════════════

class SmartQuoteStudioScreen extends ConsumerStatefulWidget {
  final String? quoteId;
  final Map<String, dynamic>? initialItem;

  const SmartQuoteStudioScreen({
    super.key,
    this.quoteId,
    this.initialItem,
  });

  @override
  ConsumerState<SmartQuoteStudioScreen> createState() => _SmartQuoteStudioScreenState();
}

class _QuoteStudioLineItem {
  final String id;
  final String variantId;
  String productName;
  String variantName;
  String unit;
  double defaultPrice;
  double technicianPrice;
  double costPrice;
  double unitPrice;
  double quantity;
  double minSellingPrice;
  Color categoryColor;
  String? imageUrl;
  bool isCustom;
  String? notes;

  _QuoteStudioLineItem({
    required this.id,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.unit,
    required this.defaultPrice,
    required this.technicianPrice,
    this.costPrice = 0.0,
    required this.unitPrice,
    required this.quantity,
    this.minSellingPrice = 0.0,
    this.categoryColor = AppColors.primary,
    this.imageUrl,
    this.isCustom = false,
    this.notes,
  });

  String get displayName => variantName.isNotEmpty && variantName != productName
      ? '$productName - $variantName'
      : productName;

  double get totalPrice => quantity * unitPrice;
}

class _SmartQuoteStudioScreenState extends ConsumerState<SmartQuoteStudioScreen>
    with SingleTickerProviderStateMixin {
  // Quote Header State
  bool _isLoading = false;
  bool _isSaving = false;
  String? _currentQuoteId;
  String _quoteNumber = 'مسودة جديدة';
  String _status = 'draft';
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedCustomerPhone;
  int _validityDays = 7;
  DateTime? _validUntil;
  bool _isTechnicianPrice = false;
  double _discountAmount = 0.0;
  final _notesCtrl = TextEditingController(
    text: 'الأسعار سارية لمدة 7 أيام من تاريخ العرض نظراً لتغير أسعار الخامات - الدفع 50% مقدم و50% عند الاستلام.',
  );

  // Quote Items
  final List<_QuoteStudioLineItem> _items = [];

  // Catalog Browsing State
  String _selectedCategoryId = 'all';
  String? _selectedSubCategoryId;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _mobileTabIndex = 0; // 0: Catalog, 1: Quote Cart

  // Animations
  late final AnimationController _totalAnimCtrl;
  late final Animation<double> _totalScaleAnim;

  @override
  void initState() {
    super.initState();
    _currentQuoteId = widget.quoteId;
    _validUntil = DateTime.now().add(Duration(days: _validityDays));

    _totalAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _totalScaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _totalAnimCtrl, curve: Curves.easeOut));

    if (widget.quoteId != null) {
      _loadExistingQuote(widget.quoteId!);
    } else if (widget.initialItem != null) {
      _addInitialCalculatorItem(widget.initialItem!);
    }
  }

  @override
  void dispose() {
    _totalAnimCtrl.dispose();
    _notesCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExistingQuote(String quoteId) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(quoteRepositoryProvider);
      final quote = await repo.getQuoteWithItems(quoteId);
      if (quote == null || !mounted) return;

      final customer = quote['customer'] as Map<String, dynamic>?;
      final rawItems = quote['quote_items'] as List? ?? [];

      setState(() {
        _currentQuoteId = quote['id'];
        _quoteNumber = quote['quote_number'] ?? 'عرض سعر';
        _status = quote['status'] ?? 'draft';
        _selectedCustomerId = quote['customer_id'];
        if (customer != null) {
          _selectedCustomerName = customer['name'];
          _selectedCustomerPhone = customer['phone'];
        }
        if (quote['valid_until'] != null) {
          _validUntil = DateTime.tryParse(quote['valid_until']);
          if (_validUntil != null) {
            _validityDays = _validUntil!.difference(DateTime.now()).inDays.clamp(1, 60);
          }
        }
        if (quote['notes'] != null) {
          _notesCtrl.text = quote['notes'];
        }
        _discountAmount = (quote['discount_amount'] as num?)?.toDouble() ?? 0.0;

        _items.clear();
        for (final item in rawItems) {
          final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
          final qty = (item['quantity'] as num?)?.toDouble() ?? 1.0;
          _items.add(_QuoteStudioLineItem(
            id: item['id'] ?? UniqueKey().toString(),
            variantId: item['product_variant_id'] ?? '',
            productName: item['product_name'] ?? (item['notes'] ?? 'خامة'),
            variantName: item['variant_name'] ?? '',
            unit: item['unit_type'] ?? 'قطعة',
            defaultPrice: unitPrice,
            technicianPrice: unitPrice,
            unitPrice: unitPrice,
            quantity: qty,
            notes: item['notes'],
            isCustom: item['product_variant_id'] == null || (item['product_variant_id'] as String).isEmpty,
          ));
        }
      });
    } catch (e) {
      if (mounted) AppToast.showError(context, 'فشل تحميل بيانات العرض: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addInitialCalculatorItem(Map<String, dynamic> initial) {
    final qty = (initial['quantity'] as num?)?.toDouble() ?? 1.0;
    final total = (initial['total_price'] as num?)?.toDouble() ?? 0.0;
    final unitPrice = qty > 0 ? total / qty : total;

    _items.add(_QuoteStudioLineItem(
      id: UniqueKey().toString(),
      variantId: initial['product_variant_id'] ?? '',
      productName: initial['description'] ?? 'مقايسة من الحاسبة',
      variantName: '',
      unit: initial['unit'] ?? 'م.ط',
      defaultPrice: unitPrice,
      technicianPrice: unitPrice,
      unitPrice: unitPrice,
      quantity: qty,
      notes: initial['notes'],
      isCustom: true,
    ));
  }

  // ─── Financial Computations ────────────────────────────────────────────────
  double get _subtotal => _items.fold(0.0, (sum, i) => sum + i.totalPrice);
  double get _netTotal => (_subtotal - _discountAmount).clamp(0.0, double.infinity);

  void _animateTotal() {
    _totalAnimCtrl.forward().then((_) => _totalAnimCtrl.reverse());
  }

  void _onCategorySelected(String catId) {
    AppHaptics.selection();
    setState(() {
      _selectedCategoryId = catId;
      if (_selectedSubCategoryId != null && catId != 'all') {
        final currentSub = kDefaultSmartSubCategories.cast<SmartSubCategory?>().firstWhere(
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
    AppHaptics.selection();
    setState(() {
      if (_selectedSubCategoryId == subId) {
        _selectedSubCategoryId = null;
      } else {
        _selectedSubCategoryId = subId;
      }
    });
  }

  void _setPricingTier(bool technician) {
    if (_isTechnicianPrice == technician) return;
    AppHaptics.selection();
    setState(() {
      _isTechnicianPrice = technician;
      for (final item in _items) {
        if (!item.isCustom) {
          item.unitPrice = technician
              ? (item.technicianPrice > 0 ? item.technicianPrice : item.defaultPrice)
              : item.defaultPrice;
        }
      }
    });
    _animateTotal();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          technician ? 'تم تطبيق أسعار الفنيين والمهندسين 👷‍♂️⚡' : 'تم تطبيق أسعار البيع القطاعي 🛍️',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: technician ? const Color(0xFF2563EB) : AppColors.primary,
      ),
    );
  }

  // ─── Add/Modify Items ──────────────────────────────────────────────────────
  void _addVariantToQuote({
    required EnrichedProduct product,
    required EnrichedVariant variant,
    required double activePrice,
    required double retailPrice,
    required double techPrice,
    required String unit,
    required Color groupColor,
  }) {
    AppHaptics.light();
    final variantId = variant.id;

    // Check if already in quote
    final existingIndex = _items.indexWhere((i) => i.variantId == variantId && !i.isCustom);
    if (existingIndex != -1) {
      setState(() {
        _items[existingIndex].quantity += 1.0;
      });
    } else {
      setState(() {
        _items.add(_QuoteStudioLineItem(
          id: UniqueKey().toString(),
          variantId: variantId,
          productName: product.name,
          variantName: variant.variantName == product.name ? '' : variant.variantName,
          unit: unit,
          defaultPrice: retailPrice,
          technicianPrice: techPrice,
          costPrice: variant.costPrice,
          unitPrice: activePrice,
          quantity: 1.0,
          minSellingPrice: variant.minSellingPrice,
          categoryColor: groupColor,
          imageUrl: variant.imageUrl ?? product.imageUrl,
        ));
      });
    }
    _animateTotal();
  }

  void _updateQuantity(int index, double newQty) {
    if (newQty <= 0) {
      _removeItem(index);
    } else {
      setState(() {
        _items[index].quantity = newQty;
      });
      _animateTotal();
    }
  }

  void _updatePrice(int index, double newPrice) {
    setState(() {
      _items[index].unitPrice = newPrice.clamp(0.0, double.infinity);
    });
    _animateTotal();
  }

  void _removeItem(int index) {
    AppHaptics.medium();
    setState(() {
      _items.removeAt(index);
    });
    _animateTotal();
  }

  void _showAddCustomItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuoteManualItemSheet(
        onAdd: (name, qty, price, unit, notes) {
          setState(() {
            _items.add(_QuoteStudioLineItem(
              id: UniqueKey().toString(),
              variantId: '',
              productName: name,
              variantName: '',
              unit: unit,
              defaultPrice: price,
              technicianPrice: price,
              unitPrice: price,
              quantity: qty,
              notes: notes,
              isCustom: true,
            ));
          });
          _animateTotal();
          AppToast.showSuccess(context, 'تمت إضافة "$name" للمقايسة ✓');
        },
      ),
    );
  }

  // ─── Customer Selection & Dialogs ──────────────────────────────────────────
  void _pickCustomer() async {
    final customersAsync = ref.read(customersProvider);
    final customers = customersAsync.value ?? [];

    final chosen = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _CustomerPickerDialog(
        customers: customers,
        onAddNew: () {
          Navigator.pop(ctx);
          _showAddCustomerDialog();
        },
      ),
    );

    if (chosen != null && mounted) {
      setState(() {
        _selectedCustomerId = chosen['id'];
        _selectedCustomerName = chosen['name'];
        _selectedCustomerPhone = chosen['phone'];
      });
    }
  }

  void _showAddCustomerDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('إضافة عميل جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'اسم العميل *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
                hintText: '01xxxxxxxxx',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('حفظ واختيار العميل'),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      try {
        final repo = ref.read(customerRepositoryProvider);
        final newCustomer = await repo.createCustomer({
          'name': nameCtrl.text.trim(),
          if (phoneCtrl.text.trim().isNotEmpty) 'phone': phoneCtrl.text.trim(),
        });
        ref.invalidate(customersProvider);
        setState(() {
          _selectedCustomerId = newCustomer['id'];
          _selectedCustomerName = newCustomer['name'];
          _selectedCustomerPhone = newCustomer['phone'];
        });
        if (mounted) AppToast.showSuccess(context, 'تم حفظ وتحديد العميل $_selectedCustomerName ✓');
      } catch (e) {
        if (mounted) AppToast.showError(context, 'فشل حفظ العميل: $e');
      }
    }
  }

  void _showValidityPicker() async {
    final chosenDays = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر مدة صلاحية عرض السعر',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            for (final d in [3, 7, 15, 30])
              ListTile(
                leading: Icon(
                  Icons.timer_outlined,
                  color: _validityDays == d ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text('$d أيام من تاريخ العرض', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: _validityDays == d ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () => Navigator.pop(ctx, d),
              ),
          ],
        ),
      ),
    );

    if (chosenDays != null && mounted) {
      setState(() {
        _validityDays = chosenDays;
        _validUntil = DateTime.now().add(Duration(days: chosenDays));
      });
    }
  }

  // ─── Save & Conversion ────────────────────────────────────────────────────
  Future<String?> _saveQuote({bool silent = false}) async {
    if (_items.isEmpty) {
      AppToast.showInfo(context, 'يرجى إضافة خامة واحدة على الأقل لعرض السعر');
      return null;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(quoteRepositoryProvider);
      String quoteId;

      if (_currentQuoteId == null) {
        final newQuote = await repo.createQuote({
          'customer_id': _selectedCustomerId,
          'notes': _notesCtrl.text.trim(),
          'discount_amount': _discountAmount,
          'valid_until': _validUntil?.toIso8601String(),
        });
        quoteId = newQuote['id'];
        _currentQuoteId = quoteId;
        _quoteNumber = newQuote['quote_number'] ?? _quoteNumber;
      } else {
        quoteId = _currentQuoteId!;
        await repo.updateStatus(quoteId, _status);
      }

      for (final item in _items) {
        await repo.addQuoteItem(quoteId, {
          'product_variant_id': item.variantId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'notes': item.isCustom ? '${item.productName} (${item.unit})' : item.notes,
        });
      }

      ref.invalidate(quotesProvider);
      ref.invalidate(quoteDetailProvider(quoteId));

      if (!silent && mounted) {
        AppToast.showSuccess(context, 'تم حفظ عرض السعر $_quoteNumber بنجاح ✓');
      }
      return quoteId;
    } catch (e) {
      if (!silent && mounted) AppToast.showError(context, 'فشل حفظ عرض السعر: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _convertToInvoice() async {
    AppHaptics.medium();
    final quoteId = await _saveQuote(silent: true);
    if (quoteId == null || !mounted) return;

    try {
      final invRepo = ref.read(inventoryRepositoryProvider);
      final List<String> stockWarnings = [];

      for (final item in _items) {
        if (item.variantId.isEmpty || item.isCustom) continue;
        final invItem = await invRepo.getInventoryItemByVariantId(item.variantId);
        if (invItem == null) {
          stockWarnings.add('⚠ "${item.productName}" غير مسجل في المخزون');
        } else {
          final available = (invItem['available_qty'] as num?)?.toDouble() ?? 0;
          if (available < item.quantity) {
            stockWarnings.add('⚠ "${item.productName}" — المتاح: ${available.toStringAsFixed(0)}, المطلوب: ${item.quantity.toStringAsFixed(0)}');
          }
        }
      }

      if (stockWarnings.isNotEmpty && mounted) {
        final proceed = await AppConfirmDialog.show(
          context: context,
          title: 'تنبيه توفر المخزون للخامات',
          message: 'بعض الأصناف غير متوفرة بالكامل في المخزون حالياً:\n\n${stockWarnings.join('\n')}\n\nهل تريد المتابعة وتحويل عرض السعر إلى فاتورة بيع فعلية؟',
          confirmLabel: 'استمرار واعتماد الفاتورة',
          icon: Icons.warning_amber_rounded,
        );
        if (!proceed) return;
      }

      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      final newInvoice = await invoiceRepo.createInvoiceFromQuote(quoteId);
      if (mounted) {
        AppToast.showSuccess(context, 'تم تحويل عرض السعر إلى فاتورة بيع بنجاح ⚡');
        ref.invalidate(invoicesProvider);
        context.pushReplacement('/invoice/${newInvoice['id']}');
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'فشل تحويل المقايسة لفاتورة: $e');
    }
  }

  void _shareWhatsApp() {
    AppHaptics.light();
    final customerName = _selectedCustomerName ?? 'العميل العزيز';
    final buffer = StringBuffer();
    buffer.writeln('مرحباً $customerName،');
    buffer.writeln('مرفق مقايسة وتكلفة الخامات من *معرض السويدي للديكورات والتشطيبات*:');
    buffer.writeln('رقم عرض السعر: $_quoteNumber');
    buffer.writeln('--------------------------------');

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      buffer.writeln('${i + 1}. *${item.displayName}*');
      buffer.writeln('   الكمية: ${item.quantity.toStringAsFixed(1)} ${item.unit} × ${item.unitPrice.toStringAsFixed(0)} ج.م = ${item.totalPrice.toStringAsFixed(0)} ج.م');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('الإجمالي قبل الخصم: ${_subtotal.toStringAsFixed(0)} ج.م');
    if (_discountAmount > 0) {
      buffer.writeln('قيمة الخصم: ${_discountAmount.toStringAsFixed(0)} ج.م');
    }
    buffer.writeln('*الصافي النهائي: ${_netTotal.toStringAsFixed(0)} ج.م*');
    buffer.writeln('صلاحية الأسعار: سارية لمدة $_validityDays أيام حتى ${_validUntil?.toIso8601String().split('T').first ?? ""}.');
    buffer.writeln('يشرفنا تواصلكم دائماً.');

    AppContactActions.launchWhatsApp(
      context: context,
      phone: _selectedCustomerPhone ?? '',
      text: buffer.toString(),
    );
  }

  void _openPdfScreen() async {
    final quoteId = await _saveQuote(silent: true);
    if (quoteId != null && mounted) {
      context.push('/quote/$quoteId/pdf');
    }
  }

  // ─── Build UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'جارٍ تحميل بيانات عرض السعر...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final hub = ref.watch(catalogHubProvider);
    final allProducts = hub.allProducts;
    final isMobile = MediaQuery.of(context).size.width < 750;

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
                    ? _QuoteCatalogPanel(
                        categoryId: _selectedCategoryId,
                        subCategoryId: _selectedSubCategoryId,
                        searchQuery: _searchQuery,
                        addedVariantIds: _items.map((i) => i.variantId).toSet(),
                        isTechnicianPrice: _isTechnicianPrice,
                        onClearSubFilter: () => setState(() => _selectedSubCategoryId = null),
                        onClearAllFilters: () => setState(() {
                          _selectedCategoryId = 'all';
                          _selectedSubCategoryId = null;
                          _searchCtrl.clear();
                          _searchQuery = '';
                        }),
                        onAddVariant: _addVariantToQuote,
                      )
                    : _QuoteCartPanel(
                        items: _items,
                        grandTotal: _netTotal,
                        totalScaleAnim: _totalScaleAnim,
                        onRemove: _removeItem,
                        onQtyChanged: _updateQuantity,
                        onPriceChanged: _updatePrice,
                        onManualAdd: _showAddCustomItemDialog,
                      ))
                : Row(
                    children: [
                      // Left Catalog Panel (flex: 3)
                      Expanded(
                        flex: 3,
                        child: _QuoteCatalogPanel(
                          categoryId: _selectedCategoryId,
                          subCategoryId: _selectedSubCategoryId,
                          searchQuery: _searchQuery,
                          addedVariantIds: _items.map((i) => i.variantId).toSet(),
                          isTechnicianPrice: _isTechnicianPrice,
                          onClearSubFilter: () => setState(() => _selectedSubCategoryId = null),
                          onClearAllFilters: () => setState(() {
                            _selectedCategoryId = 'all';
                            _selectedSubCategoryId = null;
                            _searchCtrl.clear();
                            _searchQuery = '';
                          }),
                          onAddVariant: _addVariantToQuote,
                        ),
                      ),
                      VerticalDivider(width: 1, color: AppColors.border),
                      // Right Quote Items Panel (flex: 2)
                      Expanded(
                        flex: 2,
                        child: _QuoteCartPanel(
                          items: _items,
                          grandTotal: _netTotal,
                          totalScaleAnim: _totalScaleAnim,
                          onRemove: _removeItem,
                          onQtyChanged: _updateQuantity,
                          onPriceChanged: _updatePrice,
                          onManualAdd: _showAddCustomItemDialog,
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

  // ─── Header AppBar ────────────────────────────────────────────────────────
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
          // Back Button
          GestureDetector(
            onTap: () {
              if (_items.isEmpty) {
                context.pop();
              } else {
                _saveQuote(silent: true);
                context.pop();
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
          // Title & Customer Chip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'عرض سعر جديد',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _quoteNumber,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: _pickCustomer,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCustomerName ?? 'تحديد العميل (نقدي / عام)',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: !_isTechnicianPrice ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'قطاعي',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: !_isTechnicianPrice ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _setPricingTier(true),
                  borderRadius: BorderRadius.circular(7),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isTechnicianPrice ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: _isTechnicianPrice ? Colors.white : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'فنيين',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  // ─── Category Filter ──────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return Container(
      height: 48,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: kDefaultSmartCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = kDefaultSmartCategories[i];
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

  // ─── Sub-Category Filter ──────────────────────────────────────────────────
  Widget _buildSubCategoryFilter(List<EnrichedProduct> allProducts) {
    List<SmartSubCategory> subCats;
    if (_selectedCategoryId == 'all') {
      subCats = kDefaultSmartSubCategories;
    } else {
      subCats = kDefaultSmartSubCategories.where((s) => s.parentGroupId == _selectedCategoryId).toList();
    }

    final activeCategory = kDefaultSmartCategories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => kDefaultSmartCategories.first,
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

          final count = allProducts.where((p) {
            if (_selectedCategoryId != 'all' && p.group?.id != _selectedCategoryId) return false;
            return sub.matches(p);
          }).length;

          return GestureDetector(
            onTap: () => _onSubCategorySelected(sub.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.18)
                    : AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.border.withValues(alpha: 0.5),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sub.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    sub.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? accentColor : AppColors.textSecondary,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : AppColors.textTertiary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
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

  // ─── Active Filter Banner ─────────────────────────────────────────────────
  Widget _buildActiveFilterBanner() {
    final hasCategory = _selectedCategoryId != 'all';
    final hasSub = _selectedSubCategoryId != null;
    final hasSearch = _searchQuery.trim().isNotEmpty;

    if (!hasCategory && !hasSub && !hasSearch) return const SizedBox.shrink();

    final cat = kDefaultSmartCategories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => kDefaultSmartCategories.first,
    );
    final sub = hasSub
        ? kDefaultSmartSubCategories.cast<SmartSubCategory?>().firstWhere(
            (s) => s?.id == _selectedSubCategoryId,
            orElse: () => null,
          )
        : null;

    return Container(
      color: AppColors.surfaceVariant.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'الفلتر النشط: ',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          if (hasCategory)
            Text(
              cat.label,
              style: TextStyle(fontSize: 11, color: cat.color, fontWeight: FontWeight.bold),
            ),
          if (hasCategory && hasSub)
            Text(' › ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          if (hasSub && sub != null)
            Text(
              '${sub.emoji} ${sub.label}',
              style: TextStyle(fontSize: 11, color: cat.color, fontWeight: FontWeight.bold),
            ),
          if (hasSearch) ...[
            Text(' • بحث: "$_searchQuery"', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryId = 'all';
                _selectedSubCategoryId = null;
                _searchCtrl.clear();
                _searchQuery = '';
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear_all_rounded, size: 14, color: AppColors.error),
                const SizedBox(width: 2),
                Text(
                  'إلغاء الفلاتر',
                  style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.surface,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        textDirection: TextDirection.rtl,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم، الكود، اللون، أو المواصفة...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ─── Mobile Tab Switcher ──────────────────────────────────────────────────
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
                      Icons.request_quote_outlined,
                      size: 16,
                      color: _mobileTabIndex == 1 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'بنود العرض (${_items.length})',
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

  // ─── Bottom Bar ───────────────────────────────────────────────────────────
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
          // Grand Total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'الإجمالي (${_items.length} بند)',
                      style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _showValidityPicker,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '$_validityDays أيام ⏱️',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                ScaleTransition(
                  scale: _totalScaleAnim,
                  child: Text(
                    '${_netTotal.toStringAsFixed(0)} ج.م',
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
          // WhatsApp Share
          IconButton(
            onPressed: _items.isEmpty ? null : _shareWhatsApp,
            icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366), size: 20),
            tooltip: 'مشاركة عبر واتساب',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 6),
          // PDF Export
          IconButton(
            onPressed: _items.isEmpty ? null : _openPdfScreen,
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 20),
            tooltip: 'تصدير PDF رسمي',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 6),
          // Convert to POS Invoice
          FilledButton.icon(
            onPressed: _items.isEmpty ? null : _convertToInvoice,
            icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
            label: Text(
              isMobile ? 'فاتورة ⚡' : 'تحويل لفاتورة بيع ⚡',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isMobile ? 12 : 13,
                color: Colors.white,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _items.isEmpty ? AppColors.surfaceVariant : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 6),
          // Save Quote Button
          FilledButton(
            onPressed: (_items.isEmpty || _isSaving) ? null : () => _saveQuote(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSaving
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('حفظ العرض', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Catalog Panel ────────────────────────────────────────────────────────────
class _QuoteCatalogPanel extends StatelessWidget {
  final String categoryId;
  final String? subCategoryId;
  final String searchQuery;
  final Set<String> addedVariantIds;
  final bool isTechnicianPrice;
  final VoidCallback? onClearSubFilter;
  final VoidCallback? onClearAllFilters;
  final void Function({
    required EnrichedProduct product,
    required EnrichedVariant variant,
    required double activePrice,
    required double retailPrice,
    required double techPrice,
    required String unit,
    required Color groupColor,
  }) onAddVariant;

  const _QuoteCatalogPanel({
    required this.categoryId,
    required this.subCategoryId,
    required this.searchQuery,
    required this.addedVariantIds,
    required this.isTechnicianPrice,
    this.onClearSubFilter,
    this.onClearAllFilters,
    required this.onAddVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final hub = ref.watch(catalogHubProvider);
        final all = hub.allProducts;

        // 1. Category Filter
        var filtered = categoryId == 'all'
            ? all
            : all.where((p) => p.group?.id == categoryId).toList();

        // 2. Sub-Category Filter
        if (subCategoryId != null) {
          final sub = kDefaultSmartSubCategories.cast<SmartSubCategory?>().firstWhere(
            (s) => s?.id == subCategoryId,
            orElse: () => null,
          );
          if (sub != null) {
            filtered = filtered.where((p) => sub.matches(p)).toList();
          }
        }

        // 3. Search Filter
        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          filtered = filtered.where((p) {
            if (p.name.toLowerCase().contains(q)) return true;
            if (p.category.toLowerCase().contains(q)) return true;
            if (p.code.toLowerCase().contains(q)) return true;
            if (p.material != null && p.material!.toLowerCase().contains(q)) return true;
            return p.variants.any((v) =>
                v.variantName.toLowerCase().contains(q) ||
                (v.color?.toLowerCase().contains(q) ?? false) ||
                (v.dimensions?.toLowerCase().contains(q) ?? false));
          }).toList();
        }

        if (filtered.isEmpty) {
          final hasSub = subCategoryId != null;
          final hasSearch = searchQuery.isNotEmpty;
          final sub = hasSub
              ? kDefaultSmartSubCategories.cast<SmartSubCategory?>().firstWhere(
                  (s) => s?.id == subCategoryId,
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
                        'عرض جميع أصناف القسم (${kDefaultSmartCategories.firstWhere((c) => c.id == categoryId, orElse: () => kDefaultSmartCategories.first).label})',
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
            return _QuoteProductCatalogCard(
              product: product,
              addedVariantIds: addedVariantIds,
              isTechnicianPrice: isTechnicianPrice,
              onAddVariant: onAddVariant,
            );
          },
        );
      },
    );
  }
}

// ─── Product Catalog Card ─────────────────────────────────────────────────────
class _QuoteProductCatalogCard extends StatelessWidget {
  final EnrichedProduct product;
  final Set<String> addedVariantIds;
  final bool isTechnicianPrice;
  final void Function({
    required EnrichedProduct product,
    required EnrichedVariant variant,
    required double activePrice,
    required double retailPrice,
    required double techPrice,
    required String unit,
    required Color groupColor,
  }) onAddVariant;

  const _QuoteProductCatalogCard({
    required this.product,
    required this.addedVariantIds,
    required this.isTechnicianPrice,
    required this.onAddVariant,
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            // Strictly sellingPrice - NO net_price cost leakage!
            final retailPrice = v.sellingPrice > 0 ? v.sellingPrice : 0.0;
            final techPrice = v.technicianPrice > 0 ? v.technicianPrice : retailPrice;
            final activePrice = isTechnicianPrice ? techPrice : retailPrice;
            final hasPrice = activePrice > 0;
            final unitLabel = _unitLabel(product.unitType);

            return InkWell(
              onTap: () => onAddVariant(
                product: product,
                variant: v,
                activePrice: activePrice,
                retailPrice: retailPrice,
                techPrice: techPrice,
                unit: unitLabel,
                groupColor: _groupColor,
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: Row(
                  children: [
                    _QuoteColorDot(colorString: v.color, fallbackColor: _groupColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.variantName,
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
                                    color: isTechnicianPrice ? const Color(0xFF2563EB) : _groupColor,
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: alreadyAdded
                            ? _groupColor.withValues(alpha: 0.2)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        alreadyAdded ? Icons.add_circle_rounded : Icons.add_rounded,
                        color: alreadyAdded ? _groupColor : Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Quote Cart / Items Panel ────────────────────────────────────────────────
class _QuoteCartPanel extends StatelessWidget {
  final List<_QuoteStudioLineItem> items;
  final double grandTotal;
  final Animation<double> totalScaleAnim;
  final void Function(int) onRemove;
  final void Function(int, double) onQtyChanged;
  final void Function(int, double) onPriceChanged;
  final VoidCallback onManualAdd;

  const _QuoteCartPanel({
    required this.items,
    required this.grandTotal,
    required this.totalScaleAnim,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onPriceChanged,
    required this.onManualAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.request_quote_outlined,
              size: 56,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'مسودة عرض السعر فارغة',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onManualAdd,
              icon: const Icon(Icons.handyman_rounded, size: 16),
              label: const Text('أو أضف مصنعية أو بنداً يدوياً'),
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
                'بنود عرض السعر (${items.length})',
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
                label: const Text('بند يدوي / مصنعية', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ),
        // Lines
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, i) => _QuoteCartLineCard(
              index: i,
              item: items[i],
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

// ─── Quote Cart Line Card ────────────────────────────────────────────────────
class _QuoteCartLineCard extends StatefulWidget {
  final int index;
  final _QuoteStudioLineItem item;
  final VoidCallback onRemove;
  final void Function(double) onQtyChanged;
  final void Function(double) onPriceChanged;

  const _QuoteCartLineCard({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onPriceChanged,
  });

  @override
  State<_QuoteCartLineCard> createState() => _QuoteCartLineCardState();
}

class _QuoteCartLineCardState extends State<_QuoteCartLineCard> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: _fmt(widget.item.quantity));
    _priceCtrl = TextEditingController(text: widget.item.unitPrice.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(covariant _QuoteCartLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      final currentTextVal = double.tryParse(_qtyCtrl.text) ?? 0.0;
      if (currentTextVal != widget.item.quantity) {
        final newText = _fmt(widget.item.quantity);
        _qtyCtrl.value = _qtyCtrl.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
    if (oldWidget.item.unitPrice != widget.item.unitPrice) {
      final currentTextVal = double.tryParse(_priceCtrl.text) ?? 0.0;
      if (currentTextVal != widget.item.unitPrice) {
        final newText = widget.item.unitPrice.toStringAsFixed(0);
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

  String _fmt(double v) => v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final line = widget.item;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: line.categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  line.displayName,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  line.unit,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textTertiary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Quantity stepper
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepBtn(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        final q = (line.quantity - 1.0).clamp(0.0, 9999.0);
                        widget.onQtyChanged(q);
                      },
                    ),
                    SizedBox(
                      width: 38,
                      child: TextField(
                        controller: _qtyCtrl,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (v) {
                          final parsed = double.tryParse(v) ?? line.quantity;
                          widget.onQtyChanged(parsed.clamp(0.1, 9999.0));
                        },
                      ),
                    ),
                    _StepBtn(
                      icon: Icons.add_rounded,
                      onTap: () {
                        widget.onQtyChanged(line.quantity + 1.0);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Price textfield
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _priceCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                      border: InputBorder.none,
                      suffixText: 'ج.م',
                      suffixStyle: TextStyle(fontSize: 10),
                    ),
                    onSubmitted: (v) {
                      final parsed = double.tryParse(v) ?? line.unitPrice;
                      widget.onPriceChanged(parsed);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Total
              Text(
                '${line.totalPrice.toStringAsFixed(0)} ج.م',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (line.notes != null && line.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'ملاحظات: ${line.notes}',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

// ─── Color Swatch Dot ────────────────────────────────────────────────────────
class _QuoteColorDot extends StatelessWidget {
  final String? colorString;
  final Color fallbackColor;

  const _QuoteColorDot({this.colorString, required this.fallbackColor});

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

// ─── Manual / Custom Item Sheet ──────────────────────────────────────────────
class _QuoteManualItemSheet extends StatefulWidget {
  final void Function(String name, double qty, double price, String unit, String? notes) onAdd;

  const _QuoteManualItemSheet({required this.onAdd});

  @override
  State<_QuoteManualItemSheet> createState() => _QuoteManualItemSheetState();
}

class _QuoteManualItemSheetState extends State<_QuoteManualItemSheet> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _unit = 'مقطوعية';

  static const _units = [
    'مقطوعية',
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
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qtyCtrl.text) ?? 1.0;
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final notes = _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null;
    widget.onAdd(name, qty, price, _unit, notes);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'إضافة مصنعية أو بند يدوي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'اسم البند / المصنعية *',
                hintText: 'مثلاً: مصنعية تركيب بديل خشب وفواصل',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'الكمية',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'السعر (ج.م) *',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: _units.map((u) {
                final selected = _unit == u;
                return ChoiceChip(
                  label: Text(u, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  onSelected: (_) => setState(() => _unit = u),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtrl,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'شامل التركيب والمسامير',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة لعرض السعر'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer Picker Dialog ─────────────────────────────────────────────────
class _CustomerPickerDialog extends StatefulWidget {
  final List<dynamic> customers;
  final VoidCallback onAddNew;

  const _CustomerPickerDialog({
    required this.customers,
    required this.onAddNew,
  });

  @override
  State<_CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<_CustomerPickerDialog> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((c) {
      if (_filter.isEmpty) return true;
      final name = (c['name'] ?? '').toString().toLowerCase();
      final phone = (c['phone'] ?? '').toString().toLowerCase();
      final q = _filter.toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('تحديد عميل المقايسة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            tooltip: 'إضافة عميل جديد',
            onPressed: widget.onAddNew,
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        height: 380,
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _filter = v.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث باسم أو هاتف العميل...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off_rounded, size: 40, color: AppColors.textTertiary),
                          const SizedBox(height: 8),
                          Text('لا يوجد عميل مطابق', style: TextStyle(color: AppColors.textSecondary)),
                          TextButton(onPressed: widget.onAddNew, child: const Text('إضافة عميل جديد')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final c = filtered[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              (c['name'] ?? 'ع').toString().characters.first,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(c['phone'] ?? 'بدون هاتف', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          onTap: () => Navigator.pop(ctx, c as Map<String, dynamic>),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
