import 'package:flutter/material.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/engines/calculation/category_calc_registry.dart';
import 'package:stream_pay/features/catalog/data/pricing_repository.dart';

// ─── Enums ─────────────────────────────────────────────────────

enum StockStatus { inStock, lowStock, outOfStock }

enum StockFilter { all, inStock, lowStock, outOfStock }

enum CatalogSortBy { nameAsc, priceLow, priceHigh, stockHigh, newest }

// ─── Category Groups (dynamic, not hardcoded) ──────────────────

class CategoryGroup {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<String> categoryPatterns; // partial match patterns

  const CategoryGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.categoryPatterns,
  });

  bool matchesCategory(String category) {
    return categoryPatterns.any(
      (p) => category.contains(p) || category == p,
    );
  }

  static const List<CategoryGroup> defaults = [
    CategoryGroup(
      id: 'ceilings_walls',
      title: 'ديكورات الأسقف والحوائط',
      icon: Icons.home_outlined,
      color: Color(0xFF6366F1),
      categoryPatterns: [
        'ديكورات الأسقف والحوائط', 'كرانيش', 'بيت نور', 'شادو', 'بانوه', 'بانوهات', 'صرر', 'روزيت',
        'حلقة', 'ألواح 3D', 'بلاطات 3D', 'تجليد', 'عنصر حائط',
        'زوايا بانوه', 'ركن بانوه', 'زوايا ديكور', 'أسقف', 'حوائط',
      ],
    ),
    CategoryGroup(
      id: 'cladding',
      title: 'بدائل التشطيبات',
      icon: Icons.dashboard_outlined,
      color: Color(0xFF059669),
      categoryPatterns: [
        'بدائل التشطيبات', 'بديل خشب', 'بديل رخام', 'شيبورد', 'بديل حجر',
        'بديل الخشب', 'بديل الرخام', 'بديل الحجر', 'بدائل',
      ],
    ),
    CategoryGroup(
      id: 'skirting_accessories',
      title: 'الوزرات والإكسسوارات',
      icon: Icons.extension_outlined,
      color: Color(0xFFD97706),
      categoryPatterns: [
        'الوزرات والإكسسوارات', 'وزر', 'وزرات', 'بروفايل', 'إكسسوار', 'فاصل', 'نهاية',
        'زاوية استانلس', 'زاوية PVC', 'زوايا استانلس', 'زوايا PVC',
      ],
    ),
    CategoryGroup(
      id: 'materials',
      title: 'الخامات المساعدة',
      icon: Icons.build_outlined,
      color: Color(0xFFDC2626),
      categoryPatterns: [
        'الخامات المساعدة', 'معجون', 'لاصق', 'سيليكون', 'خامات',
      ],
    ),
  ];
}

// ─── Enriched Variant ──────────────────────────────────────────

/// A single product variant enriched with stock + price + calc config.
class EnrichedVariant {
  final String id;
  final String productId;
  final String variantName;
  final String? color;
  final String? dimensions;
  final String? imageUrl;
  final double pieceLength;
  final double pieceWidth;
  final double thickness;
  final double effectiveCoverageWidth;
  final double effectiveCoverageArea;
  final double defaultWastePercent;
  final double listPrice;
  final double netPrice;
  final bool hasPrice;
  final double availableQty;
  final double reservedQty;
  final double reorderPoint;
  final StockStatus stockStatus;
  final String? pricingId;
  final String? supplierId;
  final String? supplierCode;
  final double minSellingPrice;
  final double costPrice;
  final double sellingPrice;
  final double technicianPrice;
  final bool isCustomOverride;
  final String priceSourceLabel;

  const EnrichedVariant({
    required this.id,
    required this.productId,
    required this.variantName,
    this.color,
    this.dimensions,
    this.imageUrl,
    this.pieceLength = 2.4,
    this.pieceWidth = 0.0,
    this.thickness = 0.0,
    this.effectiveCoverageWidth = 0.0,
    this.effectiveCoverageArea = 0.0,
    this.defaultWastePercent = 0.10,
    this.listPrice = 0.0,
    this.netPrice = 0.0,
    this.hasPrice = false,
    this.availableQty = 0.0,
    this.reservedQty = 0.0,
    this.reorderPoint = 0.0,
    this.stockStatus = StockStatus.outOfStock,
    this.pricingId,
    this.supplierId,
    this.supplierCode,
    this.minSellingPrice = 0.0,
    this.costPrice = 0.0,
    this.sellingPrice = 0.0,
    this.technicianPrice = 0.0,
    this.isCustomOverride = false,
    this.priceSourceLabel = '',
  });

  factory EnrichedVariant.fromMap(
    Map<String, dynamic> v,
    Map<String, dynamic> product, {
    List<LocalPricingRule>? pricingRules,
  }) {
    double lp = 0, np = 0;
    String? pricingId;
    String? supplierId;
    String? supplierCode;
    final pricings = v['supplier_product_pricings'] as List? ?? [];
    if (pricings.isNotEmpty) {
      final preferred = pricings.where((p) => (p as Map)['is_preferred'] == true);
      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
      lp = _d(pref['list_price']);
      np = _d(pref['net_price']);
      if (np == 0) np = lp;
      pricingId = pref['id']?.toString();
      supplierId = pref['supplier_id']?.toString();
      supplierCode = pref['supplier_code']?.toString();
    }

    // Smart pricing resolution
    final sellingOverride = _d(v['selling_price_override']);
    final costOverride = _d(v['cost_price_override']);
    final techOverride = _d(v['technician_price_override']);
    final minOverride = _d(v['min_selling_price']);

    double finalCost = 0.0;
    double finalSelling = 0.0;
    double finalTech = 0.0;
    double finalMin = 0.0;
    bool isCustom = false;
    String sourceLabel = 'غير مسعر';

    // 1. هل الصنف مسعر باستثناء فردي؟
    if (sellingOverride > 0) {
      finalSelling = sellingOverride;
      finalCost = costOverride > 0 ? costOverride : (lp > 0 && np > 0 ? np : 0.0);
      finalTech = techOverride > 0 ? techOverride : (finalSelling * 0.90);
      finalMin = minOverride > 0 ? minOverride : (finalCost > 0 ? finalCost * 1.05 : finalSelling * 0.85);
      isCustom = true;
      sourceLabel = 'سعر استثنائي مخصص';
    } else if (pricingRules != null && pricingRules.isNotEmpty) {
      // 2. حل السعر من مصفوفة قواعد التسعير الذكي
      final cat = (product['category']?.toString() ?? '').trim();
      final sub = (product['subcategory']?.toString() ?? '').trim();
      final mat = (product['material']?.toString() ?? '').trim();
      final vName = (v['variant_name']?.toString() ?? '').trim();
      final dims = (v['dimensions']?.toString() ?? '').trim();
      final pLength = _d(v['piece_length']);
      final pWidth = _d(v['piece_width']);
      final pThickness = _d(v['thickness']);

      final resolved = PricingRepository.resolveVariantPriceStatic(
        category: cat,
        subcategory: sub.isNotEmpty ? sub : null,
        material: mat.isNotEmpty ? mat : null,
        variantName: vName.isNotEmpty ? vName : null,
        dimensions: dims.isNotEmpty ? dims : null,
        pieceLength: pLength > 0 ? pLength : null,
        pieceWidth: pWidth > 0 ? pWidth : null,
        thickness: pThickness > 0 ? pThickness : null,
        cachedRules: pricingRules,
      );

      if (resolved.sellingPrice > 0) {
        finalSelling = resolved.sellingPrice;
        finalCost = resolved.costPrice;
        finalTech = resolved.technicianPrice;
        finalMin = resolved.minSellingPrice;
        sourceLabel = resolved.sourceLabel;
      }
    }

    // 3. احتياطي لو لم يطابق أي قاعدة مصفوفة
    if (finalSelling == 0) {
      if (lp > 0) {
        finalSelling = lp;
        if (np > 0) finalCost = np;
      } else {
        // حماية هامة: إذا كان هناك سعر تكلفة فقط من المورد، يبقى للتكلفة ولا يوضع كسعر بيع قطاعي!
        if (np > 0) finalCost = np;
      }
      if (finalTech == 0 && finalSelling > 0) finalTech = finalSelling * 0.90;
      if (finalMin == 0 && finalSelling > 0) finalMin = finalCost > 0 ? finalCost * 1.05 : finalSelling * 0.85;
      if (finalSelling > 0) sourceLabel = 'سعر أساسي قديم';
    }

    // Stock from embedded inventory_items
    double availQty = 0, reservedQty = 0, reorderPt = 0;
    final invItems = v['inventory_items'] as List? ?? [];
    if (invItems.isNotEmpty) {
      availQty = _d(invItems.first['available_qty']);
      reservedQty = _d(invItems.first['reserved_qty']);
      reorderPt = _d(invItems.first['reorder_point']);
    }

    StockStatus status;
    if (availQty <= 0) {
      status = StockStatus.outOfStock;
    } else if (reorderPt > 0 && availQty <= reorderPt) {
      status = StockStatus.lowStock;
    } else {
      status = StockStatus.inStock;
    }

    return EnrichedVariant(
      id: v['id']?.toString() ?? '',
      productId: product['id']?.toString() ?? '',
      variantName: (v['variant_name']?.toString() ?? '').replaceAll(RegExp(r'\s*\(\)\s*'), '').trim(),
      color: v['color']?.toString(),
      dimensions: v['dimensions']?.toString(),
      imageUrl: v['image_url']?.toString(),
      pieceLength: _d(v['piece_length'], 2.4),
      pieceWidth: _d(v['piece_width']),
      thickness: _d(v['thickness']),
      effectiveCoverageWidth: _d(v['effective_coverage_width']),
      effectiveCoverageArea: _d(v['effective_coverage_area']),
      defaultWastePercent: _d(v['default_waste_percent'], 0.10),
      listPrice: finalSelling,
      netPrice: finalSelling,
      hasPrice: finalSelling > 0,
      availableQty: availQty,
      reservedQty: reservedQty,
      reorderPoint: reorderPt,
      stockStatus: status,
      pricingId: pricingId,
      supplierId: supplierId,
      supplierCode: supplierCode,
      minSellingPrice: finalMin,
      costPrice: finalCost,
      sellingPrice: finalSelling,
      technicianPrice: finalTech,
      isCustomOverride: isCustom,
      priceSourceLabel: sourceLabel,
    );
  }

  static double _d(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}

// ─── Enriched Product ──────────────────────────────────────────

/// A product from the catalog with all variants enriched.
class EnrichedProduct {
  final String id;
  final String name;
  final String code;
  final String category;
  final String? subcategory;
  final String? brand;
  final String? imageUrl;
  final String? notes;
  final String unitType;
  final bool isActive;
  final List<EnrichedVariant> variants;

  // New catalog fields for smart filtering
  final String? material;
  final String? moistureResistance;
  final String? installationMethod;

  // Computed fields
  final double minNetPrice;
  final double maxNetPrice;
  final double totalAvailableQty;
  final StockStatus stockStatus;
  final CategoryGroup? group;
  final CategoryCalcConfig? calcConfig;

  const EnrichedProduct({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    this.subcategory,
    this.brand,
    this.imageUrl,
    this.notes,
    required this.unitType,
    this.isActive = true,
    required this.variants,
    this.material,
    this.moistureResistance,
    this.installationMethod,
    this.minNetPrice = 0,
    this.maxNetPrice = 0,
    this.totalAvailableQty = 0,
    this.stockStatus = StockStatus.outOfStock,
    this.group,
    this.calcConfig,
  });

  factory EnrichedProduct.fromMap(Map<String, dynamic> p, {List<LocalPricingRule>? pricingRules}) {
    final rawVariants = p['product_variants'] as List? ?? [];
    var variants = rawVariants
        .map((v) => EnrichedVariant.fromMap(v as Map<String, dynamic>, p, pricingRules: pricingRules))
        .toList();

    if (variants.isEmpty) {
      final meta = p['metadata'] is Map<String, dynamic> ? p['metadata'] as Map<String, dynamic> : {};
      final colorName = p['color']?.toString() ?? meta['color_name_ar']?.toString();
      final category = p['category']?.toString() ?? '';
      final code = p['code']?.toString() ?? '';

      // Determine correct dimensions based on category:
      // Marble (بديل الرخام) & Chipboard (شيبورد): 280cm length x 122cm width
      // Molding / Ceilings (فيوتك / كرانيش): 240cm length
      double length = 2.4;
      double width = 0.0;

      final isMarbleOrChipboard = category.contains('رخام') ||
                                  category.contains('شيبورد') ||
                                  category.contains('خشب') ||
                                  category.contains('حجر');

      if (isMarbleOrChipboard) {
        length = 2.80; // 280 cm
        width = 1.22;  // 122 cm
      }

      final displayCode = code.isNotEmpty ? code : (p['name']?.toString() ?? '');

      double fallbackSelling = 0.0;
      double fallbackCost = 0.0;
      double fallbackTech = 0.0;
      double fallbackMin = 0.0;
      String fallbackLabel = '';

      if (pricingRules != null && pricingRules.isNotEmpty) {
        final resolved = PricingRepository.resolveVariantPriceStatic(
          category: category,
          cachedRules: pricingRules,
        );
        if (resolved.sellingPrice > 0) {
          fallbackSelling = resolved.sellingPrice;
          fallbackCost = resolved.costPrice;
          fallbackTech = resolved.technicianPrice;
          fallbackMin = resolved.minSellingPrice;
          fallbackLabel = resolved.sourceLabel;
        }
      }

      variants = [
        EnrichedVariant(
          id: p['id']?.toString() ?? '',
          productId: p['id']?.toString() ?? '',
          variantName: displayCode,
          color: colorName,
          imageUrl: p['image_url']?.toString(),
          pieceLength: length,
          pieceWidth: width,
          thickness: 0.0,
          effectiveCoverageWidth: width > 0 ? width : 0.0,
          effectiveCoverageArea: (width > 0 && length > 0) ? (width * length) : 0.0,
          defaultWastePercent: 0.10,
          listPrice: fallbackSelling,
          netPrice: fallbackSelling,
          hasPrice: fallbackSelling > 0,
          availableQty: 0.0,
          reservedQty: 0.0,
          reorderPoint: 0.0,
          stockStatus: StockStatus.outOfStock,
          costPrice: fallbackCost,
          sellingPrice: fallbackSelling,
          technicianPrice: fallbackTech,
          minSellingPrice: fallbackMin,
          isCustomOverride: false,
          priceSourceLabel: fallbackLabel,
        )
      ];
    }

    final prices = variants.where((v) => v.sellingPrice > 0).map((v) => v.sellingPrice).toList();
    prices.sort();
    final minPrice = prices.isNotEmpty ? prices.first : 0.0;
    final maxPrice = prices.isNotEmpty ? prices.last : 0.0;

    final totalQty = variants.fold(0.0, (sum, v) => sum + v.availableQty);

    StockStatus stock;
    final hasInStock = variants.any((v) => v.stockStatus == StockStatus.inStock);
    final hasLow = variants.any((v) => v.stockStatus == StockStatus.lowStock);
    if (hasInStock) {
      stock = StockStatus.inStock;
    } else if (hasLow) {
      stock = StockStatus.lowStock;
    } else {
      stock = StockStatus.outOfStock;
    }

    final category = p['category']?.toString() ?? '';
    var unitType = p['unit_type']?.toString() ?? '';

    final isMarbleOrChipboard = category.contains('رخام') ||
                                category.contains('شيبورد') ||
                                category.contains('خشب') ||
                                category.contains('حجر');

    if (isMarbleOrChipboard || unitType.isEmpty) {
      if (isMarbleOrChipboard) {
        unitType = 'panel';
      }
    }

    final group = CategoryGroup.defaults.cast<CategoryGroup?>().firstWhere(
      (g) => g!.matchesCategory(category),
      orElse: () => null,
    );
    final calcConfig = CategoryCalcRegistry.configForProduct(category, unitType);

    return EnrichedProduct(
      id: p['id']?.toString() ?? '',
      name: p['name']?.toString() ?? '',
      code: p['code']?.toString() ?? '',
      category: category,
      subcategory: p['subcategory']?.toString(),
      brand: p['brand']?.toString(),
      imageUrl: p['image_url']?.toString(),
      notes: p['notes']?.toString(),
      unitType: unitType,
      isActive: p['is_active'] as bool? ?? true,
      variants: variants,
      material: p['material']?.toString(),
      moistureResistance: p['moisture_resistance']?.toString(),
      installationMethod: p['installation_method']?.toString(),
      minNetPrice: minPrice,
      maxNetPrice: maxPrice,
      totalAvailableQty: totalQty,
      stockStatus: stock,
      group: group,
      calcConfig: calcConfig,
    );
  }

  /// Price display string.
  String get priceDisplay {
    if (minNetPrice <= 0) return 'بدون سعر';
    if (maxNetPrice > minNetPrice) {
      return '${minNetPrice.toStringAsFixed(0)} – ${maxNetPrice.toStringAsFixed(0)} ج.م';
    }
    return '${minNetPrice.toStringAsFixed(0)} ج.م';
  }

  bool get hasPrice => minNetPrice > 0;

  /// Rebuild from existing product with updated variants (for optimistic updates).
  factory EnrichedProduct.fromRebuild(
    EnrichedProduct p,
    List<EnrichedVariant> newVariants,
  ) {
    final prices = newVariants.where((v) => v.netPrice > 0).map((v) => v.netPrice).toList();
    prices.sort();
    final minPrice = prices.isNotEmpty ? prices.first : 0.0;
    final maxPrice = prices.isNotEmpty ? prices.last : 0.0;
    final totalQty = newVariants.fold(0.0, (s, v) => s + v.availableQty);
    final hasInStock = newVariants.any((v) => v.stockStatus == StockStatus.inStock);
    final hasLow = newVariants.any((v) => v.stockStatus == StockStatus.lowStock);
    final stock = hasInStock
        ? StockStatus.inStock
        : hasLow
            ? StockStatus.lowStock
            : StockStatus.outOfStock;
    return EnrichedProduct(
      id: p.id, name: p.name, code: p.code, category: p.category,
      subcategory: p.subcategory, brand: p.brand, imageUrl: p.imageUrl,
      notes: p.notes, unitType: p.unitType, isActive: p.isActive,
      variants: newVariants,
      material: p.material,
      moistureResistance: p.moistureResistance,
      installationMethod: p.installationMethod,
      minNetPrice: minPrice, maxNetPrice: maxPrice,
      totalAvailableQty: totalQty, stockStatus: stock,
      group: p.group, calcConfig: p.calcConfig,
    );
  }

  /// Convert to a raw map for passing to calculator provider.
  Map<String, dynamic> toRawMap() => {
    'id': id, 'name': name, 'code': code, 'category': category,
    'subcategory': subcategory, 'brand': brand, 'image_url': imageUrl,
    'notes': notes, 'unit_type': unitType, 'is_active': isActive,
    'material': material, 'moisture_resistance': moistureResistance,
    'installation_method': installationMethod,
  };
}

// ─── Smart Filter State ────────────────────────────────────────

class SmartFilterState {
  final String? selectedGroupId;
  final String? selectedCategory;
  final Set<String> selectedBrands;
  final RangeValues? priceRange;
  final StockFilter stockFilter;
  final CatalogSortBy sortBy;
  final String searchQuery;

  const SmartFilterState({
    this.selectedGroupId,
    this.selectedCategory,
    this.selectedBrands = const {},
    this.priceRange,
    this.stockFilter = StockFilter.all,
    this.sortBy = CatalogSortBy.nameAsc,
    this.searchQuery = '',
  });

  bool get hasActiveFilter =>
      selectedGroupId != null ||
      selectedCategory != null ||
      selectedBrands.isNotEmpty ||
      priceRange != null ||
      stockFilter != StockFilter.all ||
      searchQuery.isNotEmpty;

  SmartFilterState copyWith({
    String? selectedGroupId,
    String? selectedCategory,
    Set<String>? selectedBrands,
    RangeValues? priceRange,
    StockFilter? stockFilter,
    CatalogSortBy? sortBy,
    String? searchQuery,
    bool clearGroup = false,
    bool clearCategory = false,
    bool clearPriceRange = false,
  }) {
    return SmartFilterState(
      selectedGroupId: clearGroup ? null : (selectedGroupId ?? this.selectedGroupId),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedBrands: selectedBrands ?? this.selectedBrands,
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      stockFilter: stockFilter ?? this.stockFilter,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  SmartFilterState reset() => const SmartFilterState();
}

// ─── CatalogHub State ──────────────────────────────────────────

class CatalogHubState {
  final bool isLoading;
  final String? error;
  final List<EnrichedProduct> allProducts;
  final SmartFilterState filter;

  // Computed from allProducts
  final List<String> availableCategories;
  final List<String> availableBrands;
  final double globalMaxPrice;

  const CatalogHubState({
    this.isLoading = true,
    this.error,
    this.allProducts = const [],
    this.filter = const SmartFilterState(),
    this.availableCategories = const [],
    this.availableBrands = const [],
    this.globalMaxPrice = 1000,
  });

  /// Products after applying filter + sort + search.
  List<EnrichedProduct> get filteredProducts {
    var list = allProducts.toList();

    // 1. Group filter
    if (filter.selectedGroupId != null) {
      final group = CategoryGroup.defaults
          .cast<CategoryGroup?>()
          .firstWhere((g) => g!.id == filter.selectedGroupId, orElse: () => null);
      if (group != null) {
        list = list.where((p) => group.matchesCategory(p.category)).toList();
      }
    }

    // 2. Category filter
    if (filter.selectedCategory != null) {
      list = list.where((p) => p.category == filter.selectedCategory).toList();
    }

    // 3. Brand filter
    if (filter.selectedBrands.isNotEmpty) {
      list = list.where((p) => p.brand != null && filter.selectedBrands.contains(p.brand)).toList();
    }

    // 4. Price range filter
    if (filter.priceRange != null) {
      list = list.where((p) {
        if (!p.hasPrice) return filter.priceRange!.start == 0;
        return p.minNetPrice >= filter.priceRange!.start &&
               p.minNetPrice <= filter.priceRange!.end;
      }).toList();
    }

    // 5. Stock filter
    switch (filter.stockFilter) {
      case StockFilter.inStock:
        list = list.where((p) => p.stockStatus == StockStatus.inStock).toList();
        break;
      case StockFilter.lowStock:
        list = list.where((p) => p.stockStatus == StockStatus.lowStock).toList();
        break;
      case StockFilter.outOfStock:
        list = list.where((p) => p.stockStatus == StockStatus.outOfStock).toList();
        break;
      case StockFilter.all:
        break;
    }

    // 6. Search
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase().trim();
      final terms = q.split(RegExp(r'\s+'));
      list = list.where((p) {
        final fields = [
          p.name, p.code, p.category, p.subcategory ?? '',
          p.brand ?? '', p.notes ?? '', p.unitType,
          ...p.variants.map((v) => v.variantName),
          ...p.variants.map((v) => v.color ?? ''),
          ...p.variants.map((v) => v.dimensions ?? ''),
        ].map((s) => s.toLowerCase()).join(' ');
        return terms.every((t) => fields.contains(t));
      }).toList();
    }

    // 7. Sort
    switch (filter.sortBy) {
      case CatalogSortBy.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CatalogSortBy.priceLow:
        list.sort((a, b) => a.minNetPrice.compareTo(b.minNetPrice));
        break;
      case CatalogSortBy.priceHigh:
        list.sort((a, b) => b.minNetPrice.compareTo(a.minNetPrice));
        break;
      case CatalogSortBy.stockHigh:
        list.sort((a, b) => b.totalAvailableQty.compareTo(a.totalAvailableQty));
        break;
      case CatalogSortBy.newest:
        break; // Already ordered by DB
    }

    return list;
  }

  /// Products grouped by category (for list view).
  Map<String, List<EnrichedProduct>> get filteredByCategory {
    final result = <String, List<EnrichedProduct>>{};
    for (final p in filteredProducts) {
      result.putIfAbsent(p.category, () => []).add(p);
    }
    return result;
  }

  /// Stats across all products.
  int get totalProducts => allProducts.length;
  int get inStockCount => allProducts.where((p) => p.stockStatus == StockStatus.inStock).length;
  int get lowStockCount => allProducts.where((p) => p.stockStatus == StockStatus.lowStock).length;
  int get outOfStockCount => allProducts.where((p) => p.stockStatus == StockStatus.outOfStock).length;
  int get noPriceCount => allProducts.where((p) => !p.hasPrice).length;
  int get filteredCount => filteredProducts.length;

  CatalogHubState copyWith({
    bool? isLoading,
    String? error,
    List<EnrichedProduct>? allProducts,
    SmartFilterState? filter,
    List<String>? availableCategories,
    List<String>? availableBrands,
    double? globalMaxPrice,
    bool clearError = false,
  }) {
    return CatalogHubState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      allProducts: allProducts ?? this.allProducts,
      filter: filter ?? this.filter,
      availableCategories: availableCategories ?? this.availableCategories,
      availableBrands: availableBrands ?? this.availableBrands,
      globalMaxPrice: globalMaxPrice ?? this.globalMaxPrice,
    );
  }
}
