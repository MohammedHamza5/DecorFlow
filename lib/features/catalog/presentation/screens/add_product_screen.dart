import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/pricing_repository.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:stream_pay/shared/widgets/glass_container.dart';

/// عنصر الصنف / الكود مع رصيده الافتتاحي
class _VariantEntry {
  String code;
  String? color;
  double initialStock;
  final TextEditingController stockCtrl;

  _VariantEntry({
    required this.code,
    this.color,
    this.initialStock = 0.0,
  }) : stockCtrl = TextEditingController(
          text: initialStock > 0
              ? (initialStock == initialStock.roundToDouble()
                  ? initialStock.toInt().toString()
                  : initialStock.toString())
              : '0',
        );

  void dispose() {
    stockCtrl.dispose();
  }
}

class AddProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'بديل خشب');
  final _customCategoryCtrl = TextEditingController();
  final _unitTypeCtrl = TextEditingController(text: 'عود');

  // أسعار التسعير
  final _purchasePriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _techPriceCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();

  // إدخال الأكواد الفردية والمتعددة
  final _singleVariantCtrl = TextEditingController();
  final _batchPasteCtrl = TextEditingController();
  final _rangePrefixCtrl = TextEditingController(text: 'كود ');
  final _rangeStartCtrl = TextEditingController(text: '101');
  final _rangeEndCtrl = TextEditingController(text: '120');
  final _rangeStockCtrl = TextEditingController(text: '0');

  // حالة المواصفات الديناميكية حسب الفئة
  // 1. بديل خشب
  String _woodMaterial = 'PVC داخلي';
  final _customWoodMaterialCtrl = TextEditingController();
  String _woodLength = '280 سم';
  final _customWoodLengthCtrl = TextEditingController();
  String _woodWidth = '17 سم';
  final _customWoodWidthCtrl = TextEditingController();
  String _woodThickness = '18 مم';
  final _customWoodThicknessCtrl = TextEditingController();

  // 2. بديل رخام
  String _marbleDimension = '280×122 سم';
  final _customMarbleDimensionCtrl = TextEditingController();
  String _marbleThickness = '2.8 مم';
  final _customMarbleThicknessCtrl = TextEditingController();
  String _marbleType = 'عادي UV';

  // 3. شيبورد
  String _chipboardDimension = '280×122 سم';
  final _customChipboardDimensionCtrl = TextEditingController();
  String _chipboardThickness = '18 مم';
  final _customChipboardThicknessCtrl = TextEditingController();
  String _chipboardOrigin = 'إسباني';

  // 4. بديل حجر
  String _stoneDimension = '120×60 سم';
  final _customStoneDimensionCtrl = TextEditingController();
  String _stoneThickness = '3 سم';
  final _customStoneThicknessCtrl = TextEditingController();
  String _stoneType = 'حجر بو فوم PU';

  // 5. فيوتك وكرانيش
  String _corniceLength = 'عود 2.4 م';
  final _customCorniceLengthCtrl = TextEditingController();
  String _corniceDrop = '9 سم';
  final _customCorniceDropCtrl = TextEditingController();
  String _corniceType = 'كرنيشة سادة';

  // 6. بانوهات
  String _moldingLength = 'عود 2.4 م';
  final _customMoldingLengthCtrl = TextEditingController();
  String _moldingWidth = '4 سم';
  final _customMoldingWidthCtrl = TextEditingController();
  String _moldingMaterial = 'بوليمر PS عالي الكثافة';

  // 7. وزرات واستيل
  String _profileType = 'شريط استانلس 304';
  String _profileSize = '2 سم';
  final _customProfileSizeCtrl = TextEditingController();
  final String _profileLength = '2.7 م';
  String _profileColor = 'ذهبي لامع';

  // 8. خامات مساعدة
  String _accessoryType = 'سيليكون ألماني شفاف';
  final _customAccessoryTypeCtrl = TextEditingController();

  // موردين
  String? _selectedSupplierId;
  dynamic _suppliers = [];

  // قائمة الأصناف المضافة
  final List<_VariantEntry> _variantEntries = [];
  bool _isLoading = false;
  bool _useCustomPricing = false;
  bool _isEditingCategoryRule = false;
  int _activeCodeTab = 0; // 0: توليد تسلسلي، 1: لصق فوري، 2: ألوان دارجة

  static const List<String> _categories = [
    'بديل خشب',
    'بديل رخام',
    'شيبورد',
    'بديل حجر',
    'فيوتك وكرانيش',
    'بانوهات',
    'وزرات واستيل',
    'خامات مساعدة',
  ];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    if (widget.productId != null) {
      _loadExistingProduct();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _customCategoryCtrl.dispose();
    _unitTypeCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _techPriceCtrl.dispose();
    _minPriceCtrl.dispose();
    _singleVariantCtrl.dispose();
    _batchPasteCtrl.dispose();
    _rangePrefixCtrl.dispose();
    _rangeStartCtrl.dispose();
    _rangeEndCtrl.dispose();
    _rangeStockCtrl.dispose();

    _customWoodMaterialCtrl.dispose();
    _customWoodLengthCtrl.dispose();
    _customWoodWidthCtrl.dispose();
    _customWoodThicknessCtrl.dispose();
    _customMarbleDimensionCtrl.dispose();
    _customMarbleThicknessCtrl.dispose();
    _customChipboardDimensionCtrl.dispose();
    _customChipboardThicknessCtrl.dispose();
    _customStoneDimensionCtrl.dispose();
    _customStoneThicknessCtrl.dispose();
    _customCorniceLengthCtrl.dispose();
    _customCorniceDropCtrl.dispose();
    _customMoldingLengthCtrl.dispose();
    _customMoldingWidthCtrl.dispose();
    _customProfileSizeCtrl.dispose();
    _customAccessoryTypeCtrl.dispose();

    for (final v in _variantEntries) {
      v.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      final db = ref.read(erpDatabaseProvider);
      final suppliers = await db.select(db.suppliers).get();
      if (mounted) {
        setState(() {
          _suppliers = suppliers;
          if (suppliers.isNotEmpty && _selectedSupplierId == null) {
            _selectedSupplierId = suppliers.first.id.toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
    }
  }

  Future<void> _loadExistingProduct() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final p = await repo.getProductWithVariants(widget.productId!);
      if (p != null && mounted) {
        setState(() {
          _nameCtrl.text = p['name']?.toString() ?? '';
          final cat = p['category']?.toString() ?? '';
          if (_categories.contains(cat)) {
            _categoryCtrl.text = cat;
          } else {
            _categoryCtrl.text = 'أخرى';
            _customCategoryCtrl.text = cat;
          }
          if (p['unit_type'] != null) _unitTypeCtrl.text = p['unit_type'].toString();
          if (p['default_supplier_id'] != null) {
            _selectedSupplierId = p['default_supplier_id'].toString();
          }

          final variants = p['product_variants'] as List? ?? [];
          _variantEntries.clear();
          for (final v in variants) {
            final vName = v['variant_name']?.toString() ?? '';
            final invItems = v['inventory_items'] as List? ?? [];
            double stock = 0.0;
            if (invItems.isNotEmpty) {
              stock = (invItems.first['available_qty'] as num?)?.toDouble() ?? 0.0;
            }
            if (vName.isNotEmpty && vName != 'الافتراضي') {
              _variantEntries.add(_VariantEntry(
                code: vName,
                color: v['color']?.toString(),
                initialStock: stock,
              ));
            }
          }

          if (variants.isNotEmpty) {
            final first = variants.first;
            final sellPrice = (first['selling_price_override'] ?? 0.0) as num;
            final costPrice = (first['cost_price_override'] ?? 0.0) as num;
            if (sellPrice > 0 || costPrice > 0) {
              _useCustomPricing = true;
              _sellingPriceCtrl.text = sellPrice > 0 ? sellPrice.toStringAsFixed(0) : '';
              _purchasePriceCtrl.text = costPrice > 0 ? costPrice.toStringAsFixed(0) : '';
              final tech = (first['technician_price_override'] ?? 0.0) as num;
              final min = (first['min_selling_price'] ?? 0.0) as num;
              if (tech > 0) _techPriceCtrl.text = tech.toStringAsFixed(0);
              if (min > 0) _minPriceCtrl.text = min.toStringAsFixed(0);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading product for edit: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── استخلاص المواصفات الفعلية ──────────────────────────────────────────

  String get _effectiveCategory {
    final cat = _categoryCtrl.text.trim();
    if (cat == 'أخرى') {
      return _customCategoryCtrl.text.trim().isEmpty ? 'عام' : _customCategoryCtrl.text.trim();
    }
    return cat;
  }

  String get _effectiveMaterial {
    final cat = _effectiveCategory;
    if (cat.contains('خشب')) {
      return _woodMaterial == 'مخصص'
          ? (_customWoodMaterialCtrl.text.trim().isEmpty ? 'PVC' : _customWoodMaterialCtrl.text.trim())
          : _woodMaterial;
    } else if (cat.contains('رخام')) {
      return _marbleType;
    } else if (cat.contains('شيبورد')) {
      return _chipboardOrigin;
    } else if (cat.contains('حجر')) {
      return _stoneType;
    } else if (cat.contains('بانوهات')) {
      return _moldingMaterial;
    } else if (cat.contains('وزرات')) {
      return _profileType;
    } else if (cat.contains('مساعدة')) {
      return _accessoryType == 'مخصص'
          ? (_customAccessoryTypeCtrl.text.trim().isEmpty ? 'سيليكون' : _customAccessoryTypeCtrl.text.trim())
          : _accessoryType;
    }
    return '';
  }

  String get _effectiveDimensionsLabel {
    final cat = _effectiveCategory;
    if (cat.contains('خشب')) {
      final l = _woodLength == 'مخصص' ? '${_customWoodLengthCtrl.text.trim()}سم' : _woodLength;
      final w = _woodWidth == 'مخصص' ? '${_customWoodWidthCtrl.text.trim()}سم' : _woodWidth;
      final t = _woodThickness == 'مخصص' ? '${_customWoodThicknessCtrl.text.trim()}مم' : _woodThickness;
      return '$l × $w (سمك $t)';
    } else if (cat.contains('رخام')) {
      final d = _marbleDimension == 'مخصص' ? _customMarbleDimensionCtrl.text.trim() : _marbleDimension;
      final t = _marbleThickness == 'مخصص' ? '${_customMarbleThicknessCtrl.text.trim()}مم' : _marbleThickness;
      return '$d (سمك $t)';
    } else if (cat.contains('شيبورد')) {
      final d = _chipboardDimension == 'مخصص' ? _customChipboardDimensionCtrl.text.trim() : _chipboardDimension;
      final t = _chipboardThickness == 'مخصص' ? '${_customChipboardThicknessCtrl.text.trim()}مم' : _chipboardThickness;
      return 'لوح $d ($t)';
    } else if (cat.contains('حجر')) {
      final d = _stoneDimension == 'مخصص' ? _customStoneDimensionCtrl.text.trim() : _stoneDimension;
      final t = _stoneThickness == 'مخصص' ? '${_customStoneThicknessCtrl.text.trim()}سم' : _stoneThickness;
      return '$d (بروز $t)';
    } else if (cat.contains('فيوتك')) {
      final l = _corniceLength == 'مخصص' ? _customCorniceLengthCtrl.text.trim() : _corniceLength;
      final d = _corniceDrop == 'مخصص' ? '${_customCorniceDropCtrl.text.trim()}سم' : _corniceDrop;
      return '$l (سقوط $d)';
    } else if (cat.contains('بانوهات')) {
      final l = _moldingLength == 'مخصص' ? _customMoldingLengthCtrl.text.trim() : _moldingLength;
      final w = _moldingWidth == 'مخصص' ? '${_customMoldingWidthCtrl.text.trim()}سم' : _moldingWidth;
      return '$l (عرض $w)';
    } else if (cat.contains('وزرات')) {
      final s = _profileSize == 'مخصص' ? '${_customProfileSizeCtrl.text.trim()}سم' : _profileSize;
      return 'طول $_profileLength (مقاس $s)';
    }
    return '';
  }

  /// حل السعر الذكي بناء على المواصفات الحالية
  ResolvedPriceInfo _getCurrentResolvedPrice(List<LocalPricingRule> rules) {
    final cat = _effectiveCategory;
    final mat = _effectiveMaterial;
    final dim = _effectiveDimensionsLabel;

    double? pieceWidth;
    double? pieceLength;
    double? thickness;

    final numRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final nums = numRegex.allMatches(dim).map((m) => double.tryParse(m.group(1)!) ?? 0).toList();

    if (cat.contains('خشب')) {
      if (nums.isNotEmpty) pieceLength = nums[0] / 100.0;
      if (nums.length > 1) pieceWidth = nums[1] / 100.0;
      if (nums.length > 2) thickness = nums[2];
    } else if (cat.contains('رخام') || cat.contains('شيبورد')) {
      pieceLength = 2.80;
      pieceWidth = 1.22;
      if (nums.length > 2) thickness = nums[2];
    }

    return PricingRepository.resolveVariantPriceStatic(
      category: cat,
      material: mat.isNotEmpty ? mat : null,
      variantType: (cat.contains('رخام') || cat.contains('فيوتك') || cat.contains('حجر')) ? mat : null,
      dimensionSpec: dim.isNotEmpty ? dim : null,
      dimensions: dim.isNotEmpty ? dim : null,
      pieceLength: pieceLength,
      pieceWidth: pieceWidth,
      thickness: thickness,
      cachedRules: rules,
    );
  }

  // ─── دوال توليد الأكواد السريعة ──────────────────────────────────────────

  void _addSingleVariant() {
    final code = _singleVariantCtrl.text.trim();
    if (code.isNotEmpty) {
      if (_variantEntries.any((v) => v.code == code)) {
        AppToast.showInfo(context, 'الصنف "$code" موجود بالفعل');
        return;
      }
      setState(() {
        _variantEntries.add(_VariantEntry(code: code));
        _singleVariantCtrl.clear();
      });
    }
  }

  void _generateRange() {
    final prefix = _rangePrefixCtrl.text;
    final start = int.tryParse(_rangeStartCtrl.text.trim()) ?? 0;
    final end = int.tryParse(_rangeEndCtrl.text.trim()) ?? 0;
    final stock = double.tryParse(_rangeStockCtrl.text.trim()) ?? 0.0;

    if (start <= 0 || end <= 0 || end < start) {
      AppToast.showError(context, 'الرجاء إدخال نطاق أرقام صحيح (من رقم أصغر إلى رقم أكبر)');
      return;
    }

    final count = (end - start) + 1;
    if (count > 200) {
      AppToast.showError(context, 'الحد الأقصى لتوليد الأكواد دفعة واحدة هو 200 كود');
      return;
    }

    int added = 0;
    setState(() {
      for (int i = start; i <= end; i++) {
        final code = '$prefix$i'.trim();
        if (!_variantEntries.any((v) => v.code == code)) {
          _variantEntries.add(_VariantEntry(code: code, initialStock: stock));
          added++;
        }
      }
    });

    AppToast.showSuccess(context, 'تم توليد $added صنف بنجاح!');
  }

  void _generateFromBatchPaste() {
    final raw = _batchPasteCtrl.text.trim();
    if (raw.isEmpty) {
      AppToast.showInfo(context, 'الرجاء لصق أو كتابة الأكواد أولاً');
      return;
    }

    final parts = raw.split(RegExp(r'[,،\n]+'));
    int added = 0;
    setState(() {
      for (final p in parts) {
        final code = p.trim();
        if (code.isNotEmpty && !_variantEntries.any((v) => v.code == code)) {
          _variantEntries.add(_VariantEntry(code: code));
          added++;
        }
      }
      _batchPasteCtrl.clear();
    });

    AppToast.showSuccess(context, 'تمت إضافة $added صنف بنجاح!');
  }

  void _addQuickSwatch(String colorName) {
    final code = colorName.trim();
    if (_variantEntries.any((v) => v.code == code)) {
      AppToast.showInfo(context, 'اللون "$code" مضاف مسبقاً');
      return;
    }
    setState(() {
      _variantEntries.add(_VariantEntry(code: code, color: colorName));
    });
  }

  void _applyStockToAll() {
    final stockCtrl = TextEditingController(text: '10');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تعيين رصيد موحد لجميع الأصناف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل الكمية التي ترغب في تطبيقها كرصيد افتتاحي لكافة الأصناف في القائمة:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'الكمية لكل صنف (${_unitTypeCtrl.text})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(stockCtrl.text.trim()) ?? 0.0;
              setState(() {
                for (final v in _variantEntries) {
                  v.initialStock = val;
                  v.stockCtrl.text = val == val.roundToDouble() ? val.toInt().toString() : val.toString();
                }
              });
              Navigator.pop(ctx);
              AppToast.showSuccess(context, 'تم تحديث الرصيد لجميع الأصناف (${val.toInt()} ${_unitTypeCtrl.text})');
            },
            child: const Text('تطبيق على الكل'),
          ),
        ],
      ),
    );
  }

  // ─── حفظ المنتج بالكامل ──────────────────────────────────────────────────

  Future<void> _saveProduct() async {
    final name = _nameCtrl.text.trim();
    final category = _effectiveCategory;

    if (name.isEmpty || category.isEmpty) {
      AppToast.showInfo(context, 'الرجاء إدخال اسم المجموعة والتصنيف');
      return;
    }

    final pricingRepo = ref.read(pricingRepositoryProvider);
    final allRules = await pricingRepo.getAllRules();
    if (!mounted) return;
    final resolved = _getCurrentResolvedPrice(allRules);

    double finalSelling = 0.0;
    double finalCost = 0.0;
    double finalTech = 0.0;
    double finalMin = 0.0;

    final bool isFirstTimeForSpec = resolved.sellingPrice <= 0;

    if (isFirstTimeForSpec || _isEditingCategoryRule || _useCustomPricing) {
      finalCost = double.tryParse(_purchasePriceCtrl.text.trim()) ?? 0.0;
      finalSelling = double.tryParse(_sellingPriceCtrl.text.trim()) ?? 0.0;
      finalTech = double.tryParse(_techPriceCtrl.text.trim()) ?? (finalSelling * 0.90);
      finalMin = double.tryParse(_minPriceCtrl.text.trim()) ?? (finalCost > 0 ? finalCost * 1.05 : finalSelling * 0.85);

      if (finalSelling <= 0) {
        AppToast.showError(context, 'الرجاء إدخال سعر بيع صحيح للمجموعة');
        return;
      }

      // إذا كانت أول مرة تسعير لهذه الفئة، أو كان المستخدم يعدل قاعدة الفئة العامة
      if ((isFirstTimeForSpec || _isEditingCategoryRule) && !_useCustomPricing) {
        await pricingRepo.saveRuleForSpec(
          category: category,
          material: _effectiveMaterial.isNotEmpty ? _effectiveMaterial : null,
          dimensionSpec: _effectiveDimensionsLabel.isNotEmpty ? _effectiveDimensionsLabel : null,
          variantType: (category.contains('رخام') || category.contains('فيوتك') || category.contains('حجر'))
              ? _effectiveMaterial
              : null,
          costPrice: finalCost,
          sellingPrice: finalSelling,
          technicianPrice: finalTech,
          minSellingPrice: finalMin,
          notes: 'تسعير معتمد بواسطة صاحب المعرض',
        );
      }
    } else {
      finalCost = resolved.costPrice;
      finalSelling = resolved.sellingPrice;
      finalTech = resolved.technicianPrice;
      finalMin = resolved.minSellingPrice;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(productRepositoryProvider);

      // استخراج الأبعاد بدقة من التوصيف
      double length = 2.4;
      double width = 0.0;
      double thick = 0.0;
      final dimLabel = _effectiveDimensionsLabel;
      final numRegex = RegExp(r'(\d+(?:\.\d+)?)');
      final nums = numRegex.allMatches(dimLabel).map((m) => double.tryParse(m.group(1)!) ?? 0).toList();

      if (category.contains('خشب')) {
        if (nums.isNotEmpty) length = nums[0] / 100.0;
        if (nums.length > 1) width = nums[1] / 100.0;
        if (nums.length > 2) thick = nums[2];
      } else if (category.contains('رخام') || category.contains('شيبورد')) {
        length = 2.80;
        width = 1.22;
        if (nums.length > 2) thick = nums[2];
      } else if (category.contains('حجر')) {
        if (nums.isNotEmpty) length = nums[0] / 100.0;
        if (nums.length > 1) width = nums[1] / 100.0;
        if (nums.length > 2) thick = nums[2] * 10; // سم إلى مم
      } else if (category.contains('بانوهات')) {
        if (nums.isNotEmpty) length = nums[0];
        if (nums.length > 1) width = nums[1] / 100.0;
      }

      final productMap = {
        'name': name,
        'category': category,
        'material': _effectiveMaterial.isNotEmpty ? _effectiveMaterial : null,
        'default_supplier_id': _selectedSupplierId,
        'unit_type': _unitTypeCtrl.text.trim().isNotEmpty ? _unitTypeCtrl.text.trim() : 'piece',
        'is_active': true,
      };

      if (widget.productId != null) {
        await repo.updateProduct(widget.productId!, productMap);
        ref.read(catalogHubProvider.notifier).invalidate();
        if (mounted) {
          AppToast.showSuccess(context, 'تم تحديث بيانات المنتج بنجاح!');
          Navigator.pop(context, true);
        }
        return;
      }

      // تجهيز الصنف الأول
      final firstVariantEntry = _variantEntries.isNotEmpty ? _variantEntries.first : _VariantEntry(code: 'الافتراضي');
      final defaultVariant = {
        'variant_name': firstVariantEntry.code,
        'color': firstVariantEntry.color,
        'piece_length': length,
        'piece_width': width,
        'thickness': thick > 0 ? thick : null,
        'dimensions': dimLabel.isNotEmpty ? dimLabel : '${(length * 100).toInt()} سم',
        if (_useCustomPricing) ...{
          'cost_price_override': finalCost,
          'selling_price_override': finalSelling,
          'technician_price_override': finalTech,
          'min_selling_price': finalMin,
        }
      };

      final p = await repo.createProduct(
        productMap,
        defaultVariant: defaultVariant,
      );
      final productId = p['id'];
      final firstVariantId = p['product_variants'][0]['id'];

      // تسعير المورد للرجوع التاريخي
      await repo.upsertVariantPricing(
        variantId: firstVariantId,
        listPrice: finalSelling,
        netPrice: finalCost,
        supplierId: _selectedSupplierId,
      );

      // تسجيل الرصيد الافتتاحي للصنف الأول إن وجد
      if (firstVariantEntry.initialStock > 0) {
        try {
          await ref.read(inventoryRepositoryProvider).addInventoryItem(
            productVariantId: firstVariantId,
            unitType: _unitTypeCtrl.text.trim(),
            quantity: firstVariantEntry.initialStock,
            notes: 'رصيد افتتاحي عند التأسيس',
          );
        } catch (e) {
          debugPrint('Error adding initial stock for variant 1: $e');
        }
      }

      // إضافة باقي الأصناف
      if (_variantEntries.length > 1) {
        for (int i = 1; i < _variantEntries.length; i++) {
          final entry = _variantEntries[i];
          final vMap = await repo.addVariant(productId, {
            'variant_name': entry.code,
            'color': entry.color,
            'piece_length': length,
            'piece_width': width,
            'thickness': thick > 0 ? thick : null,
            'dimensions': dimLabel.isNotEmpty ? dimLabel : '${(length * 100).toInt()} سم',
            if (_useCustomPricing) ...{
              'cost_price_override': finalCost,
              'selling_price_override': finalSelling,
              'technician_price_override': finalTech,
              'min_selling_price': finalMin,
            }
          });

          await repo.upsertVariantPricing(
            variantId: vMap['id'],
            listPrice: finalSelling,
            netPrice: finalCost,
            supplierId: _selectedSupplierId,
          );

          if (entry.initialStock > 0) {
            try {
              await ref.read(inventoryRepositoryProvider).addInventoryItem(
                productVariantId: vMap['id'],
                unitType: _unitTypeCtrl.text.trim(),
                quantity: entry.initialStock,
                notes: 'رصيد افتتاحي عند التأسيس',
              );
            } catch (e) {
              debugPrint('Error adding stock for variant $i: $e');
            }
          }
        }
      }

      // تحديث الكاش بالكامل
      ref.read(catalogHubProvider.notifier).invalidate();
      ref.read(inventoryRepositoryProvider).invalidateCache();

      if (mounted) {
        AppToast.showSuccess(
          context,
          'تمت إضافة المجموعة بنجاح (${_variantEntries.isEmpty ? 1 : _variantEntries.length} صنف/كود)!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'حدث خطأ أثناء الحفظ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── واجهة المستخدم (Build) ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(pricingRulesStreamProvider);
    final rules = rulesAsync.value ?? [];
    final resolved = _getCurrentResolvedPrice(rules);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.productId != null ? 'تعديل المنتج' : 'إضافة منتج وأصناف جديدة',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ConstrainedBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── 1. التصنيف والفئة الأساسية ──────────────────────────
              _buildSectionHeader('1. الفئة ونوع المنتج', Icons.category_rounded),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._categories.map((cat) {
                    final isSelected = _categoryCtrl.text == cat;
                    return ChoiceChip(
                      label: Text(cat,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _categoryCtrl.text = cat;
                            _setDefaultUnitForCategory(cat);
                            _useCustomPricing = false;
                            _isEditingCategoryRule = false;
                          });
                        }
                      },
                    );
                  }),
                  ChoiceChip(
                    label: Text('أخرى / مخصص',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: _categoryCtrl.text == 'أخرى' ? FontWeight.bold : FontWeight.w500,
                            color: _categoryCtrl.text == 'أخرى' ? Colors.white : AppColors.textPrimary)),
                    selected: _categoryCtrl.text == 'أخرى',
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _categoryCtrl.text = 'أخرى';
                          _useCustomPricing = false;
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_categoryCtrl.text == 'أخرى') ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customCategoryCtrl,
                  decoration: InputDecoration(
                    labelText: 'اكتب اسم التصنيف الجديد هنا',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),

              // ─── 2. بيانات المجموعة والوحدة ──────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'اسم المجموعة / المنتج (مثال: بديل خشب PVC كوري سادة)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.inventory_2_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _unitTypeCtrl,
                      decoration: InputDecoration(
                        labelText: 'الوحدة (لوح/عود)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // المورد إذا توفر
              if (_suppliers is List && (_suppliers as List).isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedSupplierId,
                  decoration: InputDecoration(
                    labelText: 'الشركة المصنعة / المورد (اختياري)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.store_rounded),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: (_suppliers as List)
                      .map((s) => DropdownMenuItem<String>(
                            value: s.id.toString(),
                            child: Text(s.name.toString(), style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSupplierId = val);
                  },
                ),
                const SizedBox(height: 20),
              ],

              // ─── 3. المواصفات الفنية والأبعاد الديناميكية ─────────────
              _buildSectionHeader('2. المواصفات الفنية والأبعاد (مرنة وحرة)', Icons.straighten_rounded),
              const SizedBox(height: 10),
              _buildCategorySpecificationsPanel(),
              const SizedBox(height: 20),

              // ─── 4. بطاقة التسعير الموحد الذكي ────────────────────────
              _buildSectionHeader('3. التسعير الموحد المعتمد', Icons.monetization_on_rounded),
              const SizedBox(height: 10),
              _buildSmartPricingCard(resolved),
              const SizedBox(height: 24),

              // ─── 5. مولد الأكواد والأصناف السريع ───────────────────────
              _buildSectionHeader('4. الأصناف والأكواد والألوان (مولد الأكواد السريع)', Icons.qr_code_2_rounded),
              const SizedBox(height: 10),
              _buildBulkCodeGeneratorSection(),
              const SizedBox(height: 16),

              // جدول الأصناف والأرصدة
              _buildVariantsReviewList(),
              const SizedBox(height: 32),

              // ─── زر الحفظ النهائي ────────────────────────────────────
              FilledButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('جارٍ الحفظ وتسجيل الأرصدة...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Text(
                        widget.productId != null
                            ? 'حفظ التعديلات'
                            : 'حفظ المجموعة وتأكيد (${_variantEntries.isEmpty ? 1 : _variantEntries.length}) صنف بالأسعار المحددة ⚡',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _setDefaultUnitForCategory(String cat) {
    if (cat.contains('خشب') || cat.contains('بانوهات') || cat.contains('وزرات') || cat.contains('فيوتك')) {
      _unitTypeCtrl.text = 'عود';
    } else if (cat.contains('رخام') || cat.contains('شيبورد') || cat.contains('حجر')) {
      _unitTypeCtrl.text = 'لوح';
    } else if (cat.contains('مساعدة')) {
      _unitTypeCtrl.text = 'علبة';
    } else {
      _unitTypeCtrl.text = 'قطعة';
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  // ─── لوحة المواصفات الفنية الديناميكية ─────────────────────────────────────

  Widget _buildCategorySpecificationsPanel() {
    final cat = _effectiveCategory;

    Widget content;
    if (cat.contains('خشب')) {
      content = _buildWoodSlatsSpecs();
    } else if (cat.contains('رخام')) {
      content = _buildMarbleSpecs();
    } else if (cat.contains('شيبورد')) {
      content = _buildChipboardSpecs();
    } else if (cat.contains('حجر')) {
      content = _buildStoneSpecs();
    } else if (cat.contains('فيوتك')) {
      content = _buildCorniceSpecs();
    } else if (cat.contains('بانوهات')) {
      content = _buildMoldingSpecs();
    } else if (cat.contains('وزرات')) {
      content = _buildProfileSpecs();
    } else if (cat.contains('مساعدة')) {
      content = _buildAccessorySpecs();
    } else {
      content = _buildGenericSpecs();
    }

    return GlassContainer(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 12),
          // معاينة المواصفة الفنية المكتملة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المواصفة المعتمدة: $cat | ${_effectiveMaterial.isNotEmpty ? '$_effectiveMaterial | ' : ''}$_effectiveDimensionsLabel',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoodSlatsSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. الخامة
        _buildChoiceChipRow(
          title: 'الخامة والتصنيع:',
          options: ['PVC داخلي', 'WPC خارجي', 'PS بوليمر', 'فوم مضغوط', 'مخصص'],
          selected: _woodMaterial,
          onSelected: (val) => setState(() => _woodMaterial = val),
          customCtrl: _customWoodMaterialCtrl,
          customHint: 'اكتب اسم الخامة (مثال: أكريليك معالج)',
        ),
        const Divider(height: 20),

        // 2. الطول
        _buildChoiceChipRow(
          title: 'الطول (الارتفاع):',
          options: ['280 سم', '290 سم', '300 سم', '240 سم', 'مخصص'],
          selected: _woodLength,
          onSelected: (val) => setState(() => _woodLength = val),
          customCtrl: _customWoodLengthCtrl,
          customHint: 'الطول بالسم (مثال: 285)',
          isNumber: true,
        ),
        const Divider(height: 20),

        // 3. العرض
        _buildChoiceChipRow(
          title: 'عرض الشريحة (المقاس):',
          options: ['12 سم', '15 سم', '16 سم', '17 سم', '20 سم', 'مخصص'],
          selected: _woodWidth,
          onSelected: (val) => setState(() => _woodWidth = val),
          customCtrl: _customWoodWidthCtrl,
          customHint: 'العرض بالسم (مثال: 16.5)',
          isNumber: true,
        ),
        const Divider(height: 20),

        // 4. السمك
        _buildChoiceChipRow(
          title: 'السمك / البروز:',
          options: ['12 مم', '15 مم', '18 مم', '21 مم', 'مخصص'],
          selected: _woodThickness,
          onSelected: (val) => setState(() => _woodThickness = val),
          customCtrl: _customWoodThicknessCtrl,
          customHint: 'السمك بالمم (مثال: 14)',
          isNumber: true,
        ),
      ],
    );
  }

  Widget _buildMarbleSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'أبعاد اللوح:',
          options: ['280×122 سم', '244×122 سم', '300×122 سم', 'مخصص'],
          selected: _marbleDimension,
          onSelected: (val) => setState(() => _marbleDimension = val),
          customCtrl: _customMarbleDimensionCtrl,
          customHint: 'الأبعاد (مثال: 290×120 سم)',
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'السمك:',
          options: ['2.5 مم', '2.8 مم', '3.0 مم', '3.5 مم', 'مخصص'],
          selected: _marbleThickness,
          onSelected: (val) => setState(() => _marbleThickness = val),
          customCtrl: _customMarbleThicknessCtrl,
          customHint: 'السمك بالمم (مثال: 2.7)',
          isNumber: true,
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'نوع اللوح والتشطيب:',
          options: ['عادي UV', 'ريزن عالي اللمعان', 'أوبن بوك (Bookmatch)', 'مضلع 3D'],
          selected: _marbleType,
          onSelected: (val) => setState(() => _marbleType = val),
        ),
      ],
    );
  }

  Widget _buildChipboardSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'مقاس اللوح:',
          options: ['280×122 سم', '244×122 سم', 'مخصص'],
          selected: _chipboardDimension,
          onSelected: (val) => setState(() => _chipboardDimension = val),
          customCtrl: _customChipboardDimensionCtrl,
          customHint: 'المقاس (مثال: 280×120 سم)',
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'السمك:',
          options: ['16 مم', '18 مم', '25 مم', 'مخصص'],
          selected: _chipboardThickness,
          onSelected: (val) => setState(() => _chipboardThickness = val),
          customCtrl: _customChipboardThicknessCtrl,
          customHint: 'السمك بالمم (مثال: 17)',
          isNumber: true,
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'المنشأ والنوع:',
          options: ['إسباني', 'تايلاندي', 'تركي', 'ألماني', 'ملامين محلي'],
          selected: _chipboardOrigin,
          onSelected: (val) => setState(() => _chipboardOrigin = val),
        ),
      ],
    );
  }

  Widget _buildStoneSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'أبعاد اللوح / البلاطة:',
          options: ['120×60 سم', '240×120 سم', '60×60 سم', 'مخصص'],
          selected: _stoneDimension,
          onSelected: (val) => setState(() => _stoneDimension = val),
          customCtrl: _customStoneDimensionCtrl,
          customHint: 'المقاس بالسم',
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'السمك / البروز:',
          options: ['2 سم', '3 سم', '5 سم', 'مخصص'],
          selected: _stoneThickness,
          onSelected: (val) => setState(() => _stoneThickness = val),
          customCtrl: _customStoneThicknessCtrl,
          customHint: 'البروز بالسم',
          isNumber: true,
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'نوع الحجر:',
          options: ['حجر بو فوم PU', 'حجر طبيعي مرن', 'حجر صخري أسمنتي'],
          selected: _stoneType,
          onSelected: (val) => setState(() => _stoneType = val),
        ),
      ],
    );
  }

  Widget _buildCorniceSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'طول العود:',
          options: ['عود 2.4 م', 'عود 2.0 م', 'مخصص'],
          selected: _corniceLength,
          onSelected: (val) => setState(() => _corniceLength = val),
          customCtrl: _customCorniceLengthCtrl,
          customHint: 'طول العود (مثال: عود 2.8م)',
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'السقوط / المقاس:',
          options: ['5 سم', '7 سم', '9 سم', '12 سم', '15 سم', '20 سم', 'مخصص'],
          selected: _corniceDrop,
          onSelected: (val) => setState(() => _corniceDrop = val),
          customCtrl: _customCorniceDropCtrl,
          customHint: 'المقاس بالسم',
          isNumber: true,
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'النوع والاستخدام:',
          options: ['كرنيشة سادة', 'كرنيشة مضلعة', 'إنارة مخفية LED', 'صرة سقف 30سم', 'صرة سقف 50سم'],
          selected: _corniceType,
          onSelected: (val) => setState(() => _corniceType = val),
        ),
      ],
    );
  }

  Widget _buildMoldingSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'طول العود:',
          options: ['عود 2.4 م', 'عود 2.9 م', 'مخصص'],
          selected: _moldingLength,
          onSelected: (val) => setState(() => _moldingLength = val),
          customCtrl: _customMoldingLengthCtrl,
          customHint: 'طول العود',
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'عرض الإطار (البانوه):',
          options: ['2 سم', '2.5 سم', '3 سم', '4 سم', '6 سم', '8 سم', 'مخصص'],
          selected: _moldingWidth,
          onSelected: (val) => setState(() => _moldingWidth = val),
          customCtrl: _customMoldingWidthCtrl,
          customHint: 'العرض بالسم',
          isNumber: true,
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'الخامة:',
          options: ['بوليمر PS عالي الكثافة', 'فوم مضغوط', 'خشب طبيعي'],
          selected: _moldingMaterial,
          onSelected: (val) => setState(() => _moldingMaterial = val),
        ),
      ],
    );
  }

  Widget _buildProfileSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'نوع القطاع:',
          options: ['شريط استانلس 304', 'وزرة فوم', 'وزرة PVC', 'زاوية حماية'],
          selected: _profileType,
          onSelected: (val) => setState(() => _profileType = val),
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'المقاس / الارتفاع:',
          options: ['1 سم', '2 سم', '3 سم', '8 سم', '10 سم', '12 سم', 'مخصص'],
          selected: _profileSize,
          onSelected: (val) => setState(() => _profileSize = val),
          customCtrl: _customProfileSizeCtrl,
          customHint: 'المقاس بالسم',
          isNumber: true,
        ),
        const Divider(height: 20),
        _buildChoiceChipRow(
          title: 'اللون والتشطيب:',
          options: ['ذهبي لامع', 'ذهبي مط', 'فضي لامع', 'فضي مط', 'أسود ملكي', 'روز جولد'],
          selected: _profileColor,
          onSelected: (val) => setState(() => _profileColor = val),
        ),
      ],
    );
  }

  Widget _buildAccessorySpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChoiceChipRow(
          title: 'نوع المادة المساعدة:',
          options: [
            'سيليكون ألماني شفاف',
            'سيليكون أبيض',
            'معجون عظم تثبيت',
            'فوم مسدس تثبيت',
            'كلبسات خشب ستانلس',
            'مخصص'
          ],
          selected: _accessoryType,
          onSelected: (val) => setState(() => _accessoryType = val),
          customCtrl: _customAccessoryTypeCtrl,
          customHint: 'اكتب اسم المادة (مثال: مسامير فيشر 6)',
        ),
      ],
    );
  }

  Widget _buildGenericSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أبعاد ومواصفات حرة لهذه الفئة:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customWoodMaterialCtrl,
          decoration: InputDecoration(
            labelText: 'المواصفة أو المقاس (مثال: مقاس 100×50 سم)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildChoiceChipRow({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
    TextEditingController? customCtrl,
    String? customHint,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((opt) {
            final isSel = selected == opt;
            return ChoiceChip(
              label: Text(opt,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              onSelected: (val) {
                if (val) onSelected(opt);
              },
            );
          }).toList(),
        ),
        if (selected == 'مخصص' && customCtrl != null) ...[
          const SizedBox(height: 8),
          TextField(
            controller: customCtrl,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            decoration: InputDecoration(
              labelText: customHint ?? 'اكتب القيمة المخصصة',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }

  // ─── بطاقة التسعير الذكي (Smart Pricing Card) ─────────────────────────────

  Widget _buildSmartPricingCard(ResolvedPriceInfo resolved) {
    final isFirstTimeForSpec = resolved.sellingPrice <= 0;
    final showInputs = isFirstTimeForSpec || _isEditingCategoryRule || _useCustomPricing;

    Color cardColor;
    Border cardBorder;
    Color headerColor;
    IconData headerIcon;
    String headerTitle;
    String headerSubtitle;

    if (isFirstTimeForSpec) {
      cardColor = AppColors.primary.withValues(alpha: 0.05);
      cardBorder = Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5);
      headerColor = AppColors.primary;
      headerIcon = Icons.add_chart_rounded;
      headerTitle = 'أول مرة تسعر هذه المواصفة في النظام';
      headerSubtitle = 'أدخل الأسعار المعتمدة لتوحيدها وتطبيقها تلقائياً على كل الأكواد الحالية والمستقبلية';
    } else if (_useCustomPricing) {
      cardColor = AppColors.surface;
      cardBorder = Border.all(color: AppColors.border, width: 1.5);
      headerColor = AppColors.textPrimary;
      headerIcon = Icons.edit_note_rounded;
      headerTitle = 'تسعير استثنائي لهذا المنتج فقط';
      headerSubtitle = 'لن يتم المساس بالسعر الموحد المعتمد لباقي الفئة';
    } else if (_isEditingCategoryRule) {
      cardColor = AppColors.primary.withValues(alpha: 0.05);
      cardBorder = Border.all(color: AppColors.primary, width: 1.5);
      headerColor = AppColors.primary;
      headerIcon = Icons.edit_rounded;
      headerTitle = 'تعديل السعر الموحد العام للفئة والمواصفة';
      headerSubtitle = 'سيتم تحديث السعر لكافة الأكواد القديمة والجديدة فور الحفظ';
    } else {
      cardColor = AppColors.success.withValues(alpha: 0.05);
      cardBorder = Border.all(color: AppColors.success.withValues(alpha: 0.35), width: 1.5);
      headerColor = AppColors.success;
      headerIcon = Icons.verified_rounded;
      headerTitle = 'التسعير الموحد المعتمد لهذه المواصفة';
      headerSubtitle = 'القاعدة المعتمدة: ${resolved.sourceLabel}';
    }

    return GlassContainer(
      color: cardColor,
      border: cardBorder,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(headerIcon, color: headerColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headerTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: headerColor)),
                    const SizedBox(height: 2),
                    Text(headerSubtitle, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!isFirstTimeForSpec) ...[
                if (!_useCustomPricing && !_isEditingCategoryRule) ...[
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditingCategoryRule = true;
                        _purchasePriceCtrl.text = resolved.costPrice.toStringAsFixed(0);
                        _sellingPriceCtrl.text = resolved.sellingPrice.toStringAsFixed(0);
                        _techPriceCtrl.text = resolved.technicianPrice.toStringAsFixed(0);
                        _minPriceCtrl.text = resolved.minSellingPrice.toStringAsFixed(0);
                      });
                    },
                    icon: const Icon(Icons.edit_rounded, size: 15),
                    label: const Text('تعديل سعر الفئة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _useCustomPricing = true;
                        _purchasePriceCtrl.text = resolved.costPrice.toStringAsFixed(0);
                        _sellingPriceCtrl.text = resolved.sellingPrice.toStringAsFixed(0);
                        _techPriceCtrl.text = resolved.technicianPrice.toStringAsFixed(0);
                        _minPriceCtrl.text = resolved.minSellingPrice.toStringAsFixed(0);
                      });
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    label: const Text('سعر استثنائي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditingCategoryRule = false;
                        _useCustomPricing = false;
                      });
                    },
                    icon: const Icon(Icons.undo_rounded, size: 16),
                    label: const Text('إلغاء والرجوع للمعتمد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ],
          ),
          const Divider(height: 20),

          if (!showInputs) ...[
            Row(
              children: [
                _buildPricePill('شراء (تكلفة)', '${resolved.costPrice.toStringAsFixed(0)} ج', AppColors.error),
                const SizedBox(width: 8),
                _buildPricePill('بيع قطاعي', '${resolved.sellingPrice.toStringAsFixed(0)} ج', AppColors.success),
                const SizedBox(width: 8),
                _buildPricePill('فنيين ومهندسين', '${resolved.technicianPrice.toStringAsFixed(0)} ج', const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                _buildPricePill('حد أدنى للبيع', '${resolved.minSellingPrice.toStringAsFixed(0)} ج', const Color(0xFFD97706)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '💡 هامش الربح: +${resolved.retailProfit.toStringAsFixed(0)} ج (${resolved.retailProfitMarginPercent.toStringAsFixed(1)}%) — موحد ومطبق تلقائياً على كافة الأكواد.',
              style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                isFirstTimeForSpec
                    ? '💡 هذه المواصفة غير مسعرة في النظام. حدد أسعار البيع والتكلفة ليتم حفظها واعتمادها تلقائياً لكافة الأكواد:'
                    : (_isEditingCategoryRule
                        ? '✏️ تعديل السعر الموحد: سيتم تحديث هذا السعر لجميع المنتجات والأكواد التي تطابق هذه المواصفة.'
                        : '⚡ سعر مخصص: سيتم تطبيق هذا السعر على هذا الصنف فقط دون تغيير السعر الموحد للفئة.'),
                style: TextStyle(
                  fontSize: 12,
                  color: isFirstTimeForSpec ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _purchasePriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سعر الشراء / التكلفة',
                      hintText: '0',
                      suffixText: 'ج.م',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _sellingPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سعر البيع قطاعي',
                      hintText: '0',
                      suffixText: 'ج.م',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (val) {
                      final sell = double.tryParse(val) ?? 0;
                      if (sell > 0) {
                        if (_techPriceCtrl.text.isEmpty || _techPriceCtrl.text == '0') {
                          _techPriceCtrl.text = (sell * 0.90).round().toString();
                        }
                        if (_minPriceCtrl.text.isEmpty || _minPriceCtrl.text == '0') {
                          _minPriceCtrl.text = (sell * 0.85).round().toString();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _techPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سعر الفنيين والمهندسين',
                      hintText: '0',
                      suffixText: 'ج.م',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الحد الأدنى للبيع',
                      hintText: '0',
                      suffixText: 'ج.م',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricePill(String title, String price, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(price, style: TextStyle(fontSize: 13.5, color: color, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // ─── مولد الأكواد والأصناف السريع ──────────────────────────────────────────

  Widget _buildBulkCodeGeneratorSection() {
    return GlassContainer(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تبويبات المولد
          Row(
            children: [
              _buildTabButton(index: 0, label: '⚡ توليد تسلسلي (نطاق)', icon: Icons.auto_awesome_rounded),
              const SizedBox(width: 8),
              _buildTabButton(index: 1, label: '📋 لصق أو كتابة متعددة', icon: Icons.content_paste_rounded),
              const SizedBox(width: 8),
              _buildTabButton(index: 2, label: '🎨 ألوان دارجة', icon: Icons.palette_rounded),
            ],
          ),
          const SizedBox(height: 16),

          // المحتوى حسب التبويب النشط
          if (_activeCodeTab == 0) ...[
            // 1. توليد تسلسلي
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rangePrefixCtrl,
                    decoration: InputDecoration(
                      labelText: 'بادئة الكود',
                      hintText: 'كود أو كود-',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rangeStartCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'من رقم',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rangeEndCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'إلى رقم',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rangeStockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'رصيد كل كود',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _generateRange,
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text('توليد كافة الأكواد المحددة دفعة واحدة ⚡'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ] else if (_activeCodeTab == 1) ...[
            // 2. لصق متعدد
            TextField(
              controller: _batchPasteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'الصق الأكواد مفصولة بفواصل أو أسطر جديدة',
                hintText: 'مثال: 101, 102, 105, 108, 110, بيج فاتح، رخامي كلكتا',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _generateFromBatchPaste,
              icon: const Icon(Icons.playlist_add_rounded, size: 18),
              label: const Text('إضافة الأكواد المكتوبة للقائمة'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ] else ...[
            // 3. ألوان دارجة
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'أبيض صريح',
                'أسود ملكي',
                'خشبي فاتح',
                'خشبي غامق',
                'بيج كلاسيك',
                'رمادي فاتح',
                'رمادي غامق',
                'رخامي كلكتا',
                'ذهبي فاخر',
                'بني محروق',
                'عسلي طبيعي',
              ].map((color) {
                return ActionChip(
                  label: Text('+$color', style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.background,
                  side: BorderSide(color: AppColors.border),
                  onPressed: () => _addQuickSwatch(color),
                );
              }).toList(),
            ),
          ],

          const Divider(height: 24),
          // إدخال كود فردي يدوي
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _singleVariantCtrl,
                  decoration: InputDecoration(
                    labelText: 'أو أضف كود/لون يدوي محدد (مثال: كود 105 بيج)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _addSingleVariant(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _addSingleVariant,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label, required IconData icon}) {
    final isSelected = _activeCodeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeCodeTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── استعراض ومراجعة الأصناف والأرصدة المخزنية ─────────────────────────────

  Widget _buildVariantsReviewList() {
    if (_variantEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.style_outlined, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            const Text(
              'لم تقم بإضافة أكواد حتى الآن',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'استخدم مولد الأكواد بالأعلى لتوليد درجات وألوان هذا المنتج، أو احفظ مباشرة ليتم اعتماد صنف افتراضي.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'الأصناف والأكواد المجهزة (${_variantEntries.length} صنف)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _applyStockToAll,
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('رصيد موحد للكل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      for (final v in _variantEntries) {
                        v.dispose();
                      }
                      _variantEntries.clear();
                    });
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                  label: const Text('مسح الكل', style: TextStyle(fontSize: 12, color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 320),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: _variantEntries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _variantEntries[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text('${index + 1}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                title: Text(
                  item.code,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                subtitle: item.color != null
                    ? Text('لون: ${item.color}', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 36,
                      child: TextField(
                        controller: item.stockCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'الرصيد',
                          suffixText: _unitTypeCtrl.text,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) {
                          item.initialStock = double.tryParse(val) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          final removed = _variantEntries.removeAt(index);
                          removed.dispose();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
