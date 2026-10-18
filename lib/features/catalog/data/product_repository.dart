import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:stream_pay/core/monitoring/action_tracker.dart';

/// Repository for Product Catalog operations, now offline-first.
class ProductRepository {
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  ProductRepository(this._db, this._syncEngine);

  // ─── Cache ────────────────────────────────────────────────
  List<Map<String, dynamic>>? _cachedProducts;
  String? _cachedCategory;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 3);

  bool _isCacheValid(String? category) {
    return _cachedProducts != null &&
        _cachedCategory == category &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }

  void invalidateCache() {
    _cachedProducts = null;
    _cacheTime = null;
  }

  // ─── Products ─────────────────────────────────────────────

  /// Get all products — lightweight query for catalog list.
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    String? search,
    bool activeOnly = true,
    int limit = 200,
  }) async {
    if (_isCacheValid(category) && (search == null || search.isEmpty)) {
      if ((_cachedProducts?.length ?? 0) <= 5) {
        invalidateCache();
      } else {
        return _cachedProducts!;
      }
    }

    var query = _db.select(_db.localProducts);

    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    if (category != null) {
      query.where((t) => t.category.equals(category));
    }
    if (search != null && search.isNotEmpty) {
      final q = '%$search%';
      query.where((t) => 
          t.name.like(q) | 
          t.code.like(q) | 
          t.brand.like(q));
    }
    
    // Filter out logically deleted products
    query.where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not());

    query.orderBy([(t) => OrderingTerm(expression: t.name)]);
    query.limit(limit);

    final productsList = await query.get();
    if (productsList.isEmpty) return [];

    final productIds = productsList.map((p) => p.id).toList();

    final variantsQuery = _db.select(_db.localProductVariants)
      ..where((t) => t.productId.isIn(productIds))
      ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not());
    final variantsList = await variantsQuery.get();
    final variantIds = variantsList.map((v) => v.id).toList();

    List<LocalSupplierPricing> pricingsList = [];
    List<LocalInventoryItem> inventoryList = [];
    if (variantIds.isNotEmpty) {
      pricingsList = await (_db.select(_db.localSupplierPricings)
        ..where((t) => t.productVariantId.isIn(variantIds))).get();
      inventoryList = await (_db.select(_db.localInventoryItems)
        ..where((t) => t.productVariantId.isIn(variantIds))).get();
    }

    final pricingsByVariant = <String, List<Map<String, dynamic>>>{};
    for (final pricing in pricingsList) {
      pricingsByVariant.putIfAbsent(pricing.productVariantId, () => []).add(_mapPricing(pricing));
    }

    final inventoryByVariant = <String, List<Map<String, dynamic>>>{};
    for (final inv in inventoryList) {
      inventoryByVariant.putIfAbsent(inv.productVariantId, () => []).add(_mapInventory(inv));
    }

    final variantsByProduct = <String, List<Map<String, dynamic>>>{};
    for (final variant in variantsList) {
      final vMap = _mapVariant(variant);
      
      var pricings = pricingsByVariant[variant.id] ?? [];
      var invs = inventoryByVariant[variant.id] ?? [];

      vMap['supplier_product_pricings'] = pricings;
      vMap['inventory_items'] = invs;
      variantsByProduct.putIfAbsent(variant.productId, () => []).add(vMap);
    }

    final result = <Map<String, dynamic>>[];
    for (final product in productsList) {
      final pMap = _mapProduct(product);
      pMap['product_variants'] = variantsByProduct[product.id] ?? [];
      result.add(pMap);
    }

    if (search == null || search.isEmpty) {
      _cachedProducts = result;
      _cachedCategory = category;
      _cacheTime = DateTime.now();
    }

    return result;
  }

  /// Get a single product with all variants.
  Future<Map<String, dynamic>?> getProductWithVariants(String productId) async {
    final query = _db.select(_db.localProducts)
      ..where((t) => t.id.equals(productId))
      ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not());
    final product = await query.getSingleOrNull();
    if (product == null) return null;

    final variantsQuery = _db.select(_db.localProductVariants)
      ..where((t) => t.productId.equals(productId))
      ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not());
    final variantsList = await variantsQuery.get();
    final variantIds = variantsList.map((v) => v.id).toList();

    List<LocalSupplierPricing> pricingsList = [];
    List<LocalInventoryItem> inventoryList = [];
    List<LocalProductPreset> presetsList = [];
    List<LocalProductAssembly> assembliesList = [];

    if (variantIds.isNotEmpty) {
      pricingsList = await (_db.select(_db.localSupplierPricings)..where((t) => t.productVariantId.isIn(variantIds))).get();
      inventoryList = await (_db.select(_db.localInventoryItems)..where((t) => t.productVariantId.isIn(variantIds))).get();
      presetsList = await (_db.select(_db.localProductPresets)..where((t) => t.productVariantId.isIn(variantIds))).get();
      assembliesList = await (_db.select(_db.localProductAssemblies)..where((t) => t.productVariantId.isIn(variantIds))).get();
    }

    final pricingsByVariant = <String, List<Map<String, dynamic>>>{};
    for (var p in pricingsList) {
      pricingsByVariant.putIfAbsent(p.productVariantId, () => []).add(_mapPricing(p));
    }

    final inventoryByVariant = <String, List<Map<String, dynamic>>>{};
    for (var i in inventoryList) {
      inventoryByVariant.putIfAbsent(i.productVariantId, () => []).add(_mapInventory(i));
    }

    final presetsByVariant = <String, List<Map<String, dynamic>>>{};
    for (var p in presetsList) {
      presetsByVariant.putIfAbsent(p.productVariantId, () => []).add({
        'id': p.id,
        'product_variant_id': p.productVariantId,
        'name': p.name,
        'preset_data': p.presetData,
      });
    }

    final assembliesByVariant = <String, List<Map<String, dynamic>>>{};
    for (var a in assembliesList) {
      assembliesByVariant.putIfAbsent(a.productVariantId, () => []).add({
        'id': a.id,
        'product_variant_id': a.productVariantId,
        'accessory_product_id': a.accessoryProductId,
        'quantity': a.quantity,
      });
    }

    final variantsMapped = variantsList.map((v) {
      final vMap = _mapVariant(v);
      
      var pricings = pricingsByVariant[v.id] ?? [];
      var invs = inventoryByVariant[v.id] ?? [];

      vMap['supplier_product_pricings'] = pricings;
      vMap['inventory_items'] = invs;
      vMap['product_presets'] = presetsByVariant[v.id] ?? [];
      vMap['product_assemblies'] = assembliesByVariant[v.id] ?? [];
      return vMap;
    }).toList();

    final pMap = _mapProduct(product);
    pMap['product_variants'] = variantsMapped;
    return pMap;
  }

  /// Create a product with its default variant.
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> product, {
    Map<String, dynamic>? defaultVariant,
  }) async {
    final productName = product['name'] ?? 'Unknown';
    return await ActionTracker.track(
      operationName: '[Product - Add] $productName',
      localAction: () async {
        final comp = _productCompanionFromMap(product);
        final inserted = await _db.into(_db.localProducts).insertReturning(comp);
        final pMap = _mapProduct(inserted);

        if (defaultVariant != null) {
          defaultVariant['product_id'] = inserted.id;
          final vComp = _variantCompanionFromMap(defaultVariant);
          final vInserted = await _db.into(_db.localProductVariants).insertReturning(vComp);
          pMap['product_variants'] = [_mapVariant(vInserted)];
        }

        invalidateCache();
        return pMap;
      },
      cloudAction: () async {
        await _syncEngine.sync();
      },
    );
  }

  /// Get distinct categories.
  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    final productName = data['name'] ?? 'ID: $id';
    return await ActionTracker.track(
      operationName: '[Product - Edit] $productName',
      localAction: () async {
        await (_db.update(_db.localProducts)..where((t) => t.id.equals(id))).write(
          LocalProductsCompanion(
            name: data['name'] != null ? Value(data['name']) : const Value.absent(),
            code: data['code'] != null ? Value(data['code']) : const Value.absent(),
            category: data['category'] != null ? Value(data['category']) : const Value.absent(),
            subcategory: data['subcategory'] != null ? Value(data['subcategory']) : const Value.absent(),
            unitType: data['unit_type'] != null ? Value(data['unit_type']) : const Value.absent(),
            imageUrl: data['image_url'] != null ? Value(data['image_url']) : const Value.absent(),
            notes: data['notes'] != null ? Value(data['notes']) : const Value.absent(),
            isActive: data['is_active'] != null ? Value(data['is_active']) : const Value.absent(),
            brand: data['brand'] != null ? Value(data['brand']) : const Value.absent(),
            material: data['material'] != null ? Value(data['material']) : const Value.absent(),
            moistureResistance: data['moisture_resistance'] != null ? Value(data['moisture_resistance']) : const Value.absent(),
            installationMethod: data['installation_method'] != null ? Value(data['installation_method']) : const Value.absent(),
            defaultSupplierId: data['default_supplier_id'] != null ? Value(data['default_supplier_id']) : const Value.absent(),
            syncStatus: const Value('pending_update'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return data;
      },
      cloudAction: () async {
        await _syncEngine.sync();
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    await ActionTracker.track(
      operationName: '[Product - Delete] ID: $id',
      localAction: () async {
        await (_db.update(_db.localProducts)..where((t) => t.id.equals(id))).write(
          const LocalProductsCompanion(syncStatus: Value('pending_delete')),
        );
      },
      cloudAction: () async {
        await _syncEngine.sync();
      },
    );
  }

  Future<void> deleteVariant(String id) async {
    await (_db.update(_db.localProductVariants)..where((t) => t.id.equals(id))).write(
      const LocalProductVariantsCompanion(syncStatus: Value('pending_delete')),
    );
    invalidateCache();
    _syncEngine.sync();
  }

  /// Update custom pricing overrides for a specific variant.
  Future<void> updateVariantPricingOverrides(
    String variantId, {
    double? costPriceOverride,
    double? sellingPriceOverride,
    double? technicianPriceOverride,
    bool clearOverrides = false,
  }) async {
    await (_db.update(_db.localProductVariants)..where((t) => t.id.equals(variantId))).write(
      LocalProductVariantsCompanion(
        costPriceOverride: clearOverrides
            ? const Value(null)
            : (costPriceOverride != null ? Value(costPriceOverride) : const Value.absent()),
        sellingPriceOverride: clearOverrides
            ? const Value(null)
            : (sellingPriceOverride != null ? Value(sellingPriceOverride) : const Value.absent()),
        technicianPriceOverride: clearOverrides
            ? const Value(null)
            : (technicianPriceOverride != null ? Value(technicianPriceOverride) : const Value.absent()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    invalidateCache();
  }

  /// Update pricing for all variants of products matching given category or category aliases.
  Future<int> batchUpdateCategoryPricing({
    required List<String> categoryAliases,
    required double sellingPrice,
    required double technicianPrice,
    required double costPrice,
    required double minSellingPrice,
  }) async {
    // 1. Fetch all active products
    final allProducts = await (_db.select(_db.localProducts)
          ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not()))
        .get();

    final cleanAliases = categoryAliases
        .map((a) => a.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '))
        .where((a) => a.isNotEmpty)
        .toList();

    // Match products whose category contains or is contained by any alias
    final matchingProducts = allProducts.where((p) {
      final pCat = p.category.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
      return cleanAliases.any((a) =>
          pCat == a ||
          pCat.contains(a) ||
          a.contains(pCat) ||
          pCat.replaceAll('ال', '') == a.replaceAll('ال', '') ||
          pCat.replaceAll('ال', '').contains(a.replaceAll('ال', '')) ||
          a.replaceAll('ال', '').contains(pCat.replaceAll('ال', '')));
    }).toList();

    if (matchingProducts.isEmpty) return 0;

    final productIds = matchingProducts.map((p) => p.id).toList();

    // 2. Fetch existing variants for these products
    final existingVariants = await (_db.select(_db.localProductVariants)
          ..where((t) => t.productId.isIn(productIds))
          ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not()))
        .get();

    // 3. For any product without a variant, create a default one
    final productsWithVariants = existingVariants.map((v) => v.productId).toSet();
    for (final p in matchingProducts) {
      if (!productsWithVariants.contains(p.id)) {
        final newVariantId = const Uuid().v4();
        await _db.into(_db.localProductVariants).insert(
          LocalProductVariantsCompanion(
            id: Value(newVariantId),
            productId: Value(p.id),
            variantName: Value(p.code?.isNotEmpty == true ? p.code! : p.name),
            sellingPriceOverride: Value(sellingPrice),
            technicianPriceOverride: Value(technicianPrice),
            costPriceOverride: Value(costPrice),
            minSellingPrice: Value(minSellingPrice),
            syncStatus: const Value('pending_insert'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }

    // 4. Update all variants of the matched products
    final now = DateTime.now();
    await (_db.update(_db.localProductVariants)
          ..where((t) => t.productId.isIn(productIds))
          ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not()))
        .write(
      LocalProductVariantsCompanion(
        sellingPriceOverride: Value(sellingPrice),
        technicianPriceOverride: Value(technicianPrice),
        costPriceOverride: Value(costPrice),
        minSellingPrice: Value(minSellingPrice),
        syncStatus: const Value('pending_update'),
        updatedAt: Value(now),
      ),
    );

    // 5. Invalidate caches and trigger sync
    invalidateCache();
    _syncEngine.sync();

    // Count how many variants were updated
    final totalVariants = await (_db.select(_db.localProductVariants)
          ..where((t) => t.productId.isIn(productIds))
          ..where((t) => t.syncStatus.isNull() | t.syncStatus.equals('pending_delete').not()))
        .get();

    return totalVariants.length;
  }

  Future<List<String>> getCategories() async {
    final query = _db.selectOnly(_db.localProducts, distinct: true)..addColumns([_db.localProducts.category]);
    final result = await query.map((row) => row.read(_db.localProducts.category)).get();
    final categories = result.whereType<String>().toList();
    categories.sort();
    return categories;
  }

  // ─── Storage ──────────────────────────────────────────────

  /// Delete an entire category and all its products
  Future<void> deleteCategory(String category) async {
    await (_db.delete(_db.localProducts)..where((t) => t.category.equals(category))).go();
    invalidateCache();
  }

  /// Upload a product image to storage (Not implemented offline).
  Future<String?> uploadImage(String fileName, dynamic fileBytes) async {
    return null;
  }

  // ─── Variants ─────────────────────────────────────────────

  /// Add a variant to a product.
  Future<Map<String, dynamic>> addVariant(
    String productId,
    Map<String, dynamic> variant,
  ) async {
    variant['product_id'] = productId;
    final comp = _variantCompanionFromMap(variant);
    final inserted = await _db.into(_db.localProductVariants).insertReturning(comp);
    invalidateCache();
    return _mapVariant(inserted);
  }

  /// Update a variant.
  Future<Map<String, dynamic>> updateVariant(
    String variantId,
    Map<String, dynamic> data,
  ) async {
    final comp = _variantCompanionFromMap(data).copyWith(
      id: Value(variantId),
      syncStatus: const Value('pending_update'),
      updatedAt: Value(DateTime.now()),
    );
    await (_db.update(_db.localProductVariants)..where((t) => t.id.equals(variantId))).write(comp);
    invalidateCache();
    
    final updated = await (_db.select(_db.localProductVariants)..where((t) => t.id.equals(variantId))).getSingleOrNull();
    return updated != null ? _mapVariant(updated) : data;
  }
  // ─── Pricing ──────────────────────────────────────────────

  /// Get pricing for a variant.
  Future<List<Map<String, dynamic>>> getVariantPricing(String variantId) async {
    final query = _db.select(_db.localSupplierPricings)..where((t) => t.productVariantId.equals(variantId));
    final result = await query.get();
    return result.map(_mapPricing).toList();
  }

  /// Set/update pricing for a variant.
  Future<Map<String, dynamic>> upsertVariantPricing({
    required String variantId,
    required double listPrice,
    required double netPrice,
    String? supplierId,
    String? supplierCode,
  }) async {
    final query = _db.select(_db.localSupplierPricings)..where((t) => t.productVariantId.equals(variantId));
    final existing = await query.getSingleOrNull();

    if (existing != null) {
      final comp = LocalSupplierPricingsCompanion(
        listPrice: Value(listPrice),
        netPrice: Value(netPrice),
        supplierId: supplierId != null ? Value(supplierId) : const Value.absent(),
        supplierCode: supplierCode != null ? Value(supplierCode) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_update'),
      );
      await (_db.update(_db.localSupplierPricings)..where((t) => t.id.equals(existing.id))).write(comp);
      invalidateCache();
      final updated = await (_db.select(_db.localSupplierPricings)..where((t) => t.id.equals(existing.id))).getSingle();
      return _mapPricing(updated);
    } else {
      final comp = LocalSupplierPricingsCompanion(
        productVariantId: Value(variantId),
        listPrice: Value(listPrice),
        netPrice: Value(netPrice),
        supplierId: supplierId != null ? Value(supplierId) : const Value.absent(),
        supplierCode: supplierCode != null ? Value(supplierCode) : const Value.absent(),
        isPreferred: const Value(true),
        syncStatus: const Value('pending_insert'),
      );
      final inserted = await _db.into(_db.localSupplierPricings).insertReturning(comp);
      invalidateCache();
      return _mapPricing(inserted);
    }
  }

  /// Set/update pricing for a variant.
  Future<Map<String, dynamic>> upsertPricing(
    Map<String, dynamic> pricing,
  ) async {
    final comp = _pricingCompanionFromMap(pricing);
    if (pricing['id'] != null) {
      final query = _db.select(_db.localSupplierPricings)..where((t) => t.id.equals(pricing['id']));
      final existing = await query.getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.localSupplierPricings)..where((t) => t.id.equals(pricing['id'])))
            .write(comp.copyWith(syncStatus: const Value('pending_update')));
        invalidateCache();
        final updated = await (_db.select(_db.localSupplierPricings)..where((t) => t.id.equals(pricing['id']))).getSingle();
        return _mapPricing(updated);
      }
    }
    final inserted = await _db.into(_db.localSupplierPricings).insertReturning(comp.copyWith(syncStatus: const Value('pending_insert')));
    invalidateCache();
    return _mapPricing(inserted);
  }

  /// Bulk update discount for products.
  Future<int> bulkUpdateDiscount({
    List<String>? categories,
    required double discountPercent,
  }) async {
    final pQuery = _db.select(_db.localProducts);
    if (categories != null && categories.isNotEmpty) {
      pQuery.where((t) => t.category.isIn(categories));
    }
    final products = await pQuery.get();
    final productIds = products.map((e) => e.id).toList();
    if (productIds.isEmpty) return 0;

    final vQuery = _db.select(_db.localProductVariants)..where((t) => t.productId.isIn(productIds));
    final variants = await vQuery.get();
    final variantIds = variants.map((e) => e.id).toList();
    if (variantIds.isEmpty) return 0;

    final pricingQuery = _db.select(_db.localSupplierPricings)..where((t) => t.productVariantId.isIn(variantIds));
    final pricings = await pricingQuery.get();

    int updatedCount = 0;
    for (final p in pricings) {
      if (p.listPrice > 0) {
        final newNetPrice = p.listPrice * (1 - discountPercent / 100);
        await (_db.update(_db.localSupplierPricings)..where((t) => t.id.equals(p.id))).write(
          LocalSupplierPricingsCompanion(
            netPrice: Value(newNetPrice),
            discountValue: Value(discountPercent),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending_update'),
          ),
        );
        updatedCount++;
      }
    }

    invalidateCache();
    return updatedCount;
  }

  /// Revert discounts for specific categories (or all if null)
  Future<int> revertDiscount({List<String>? categories}) async {
    final pQuery = _db.select(_db.localProducts);
    if (categories != null && categories.isNotEmpty) {
      pQuery.where((t) => t.category.isIn(categories));
    }
    final products = await pQuery.get();
    final productIds = products.map((e) => e.id).toList();
    if (productIds.isEmpty) return 0;

    final vQuery = _db.select(_db.localProductVariants)..where((t) => t.productId.isIn(productIds));
    final variants = await vQuery.get();
    final variantIds = variants.map((e) => e.id).toList();
    if (variantIds.isEmpty) return 0;

    final pricingQuery = _db.select(_db.localSupplierPricings)..where((t) => t.productVariantId.isIn(variantIds));
    final pricings = await pricingQuery.get();

    int revertedCount = 0;
    for (final p in pricings) {
      if (p.listPrice > 0) {
        await (_db.update(_db.localSupplierPricings)..where((t) => t.id.equals(p.id))).write(
          LocalSupplierPricingsCompanion(
            netPrice: Value(p.listPrice),
            discountValue: const Value(0.0),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending_update'),
          ),
        );
        revertedCount++;
      }
    }

    invalidateCache();
    return revertedCount;
  }

  /// Get price history for a pricing record.
  Future<List<Map<String, dynamic>>> getPriceHistory(
    String pricingId, {
    int limit = 20,
  }) async {
    return []; // Offline price history not mapped yet.
  }

  // ─── Mappers & Companions ─────────────────────────────────

  Map<String, dynamic> _mapProduct(LocalProduct p) {
    return {
      'id': p.id,
      'name': p.name,
      'code': p.code,
      'category': p.category,
      'subcategory': p.subcategory,
      'unit_type': p.unitType,
      'image_url': p.imageUrl,
      'notes': p.notes,
      'is_active': p.isActive,
      'brand': p.brand,
      'material': p.material,
      'moisture_resistance': p.moistureResistance,
      'installation_method': p.installationMethod,
      'default_supplier_id': p.defaultSupplierId,
      'created_at': p.createdAt.toIso8601String(),
      'updated_at': p.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _mapVariant(LocalProductVariant v) {
    return {
      'id': v.id,
      'product_id': v.productId,
      'variant_name': v.variantName,
      'color': v.color,
      'dimensions': v.dimensions,
      'piece_length': v.pieceLength,
      'piece_width': v.pieceWidth,
      'thickness': v.thickness,
      'effective_coverage_width': v.effectiveCoverageWidth,
      'default_waste_percent': v.defaultWastePercent,
      'image_url': v.imageUrl,
      'min_selling_price': v.minSellingPrice,
      'cost_price_override': v.costPriceOverride,
      'selling_price_override': v.sellingPriceOverride,
      'technician_price_override': v.technicianPriceOverride,
      'created_at': v.createdAt.toIso8601String(),
      'updated_at': v.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _mapPricing(LocalSupplierPricing p) {
    return {
      'id': p.id,
      'product_variant_id': p.productVariantId,
      'supplier_id': p.supplierId,
      'supplier_code': p.supplierCode,
      'list_price': p.listPrice,
      'net_price': p.netPrice,
      'discount_value': p.discountValue,
      'is_preferred': p.isPreferred,
      'created_at': p.createdAt.toIso8601String(),
      'updated_at': p.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _mapInventory(LocalInventoryItem i) {
    return {
      'id': i.id,
      'product_variant_id': i.productVariantId,
      'available_qty': i.availableQty,
      'reserved_qty': i.reservedQty,
      'damaged_qty': i.damagedQty,
      'reorder_point': i.reorderPoint,
      'created_at': i.createdAt.toIso8601String(),
      'updated_at': i.updatedAt.toIso8601String(),
    };
  }

  LocalProductsCompanion _productCompanionFromMap(Map<String, dynamic> map) {
    return LocalProductsCompanion(
      id: map['id'] != null ? Value(map['id']) : const Value.absent(),
      name: map['name'] != null ? Value(map['name']) : const Value.absent(),
      code: map['code'] != null ? Value(map['code']) : const Value.absent(),
      category: map['category'] != null ? Value(map['category']) : const Value.absent(),
      subcategory: map['subcategory'] != null ? Value(map['subcategory']) : const Value.absent(),
      unitType: map['unit_type'] != null ? Value(map['unit_type']) : const Value.absent(),
      imageUrl: map['image_url'] != null ? Value(map['image_url']) : const Value.absent(),
      notes: map['notes'] != null ? Value(map['notes']) : const Value.absent(),
      isActive: map['is_active'] != null ? Value(map['is_active']) : const Value.absent(),
      brand: map['brand'] != null ? Value(map['brand']) : const Value.absent(),
      material: map['material'] != null ? Value(map['material']) : const Value.absent(),
      moistureResistance: map['moisture_resistance'] != null ? Value(map['moisture_resistance']) : const Value.absent(),
      installationMethod: map['installation_method'] != null ? Value(map['installation_method']) : const Value.absent(),
      defaultSupplierId: map['default_supplier_id'] != null ? Value(map['default_supplier_id']) : const Value.absent(),
      syncStatus: const Value('pending_insert'),
    );
  }

  LocalProductVariantsCompanion _variantCompanionFromMap(Map<String, dynamic> map) {
    return LocalProductVariantsCompanion(
      id: map['id'] != null ? Value(map['id']) : const Value.absent(),
      productId: map['product_id'] != null ? Value(map['product_id']) : const Value.absent(),
      variantName: map['variant_name'] != null ? Value(map['variant_name']) : const Value.absent(),
      color: map['color'] != null ? Value(map['color']) : const Value.absent(),
      dimensions: map['dimensions'] != null ? Value(map['dimensions']) : const Value.absent(),
      pieceLength: map['piece_length'] != null ? Value((map['piece_length'] as num).toDouble()) : const Value.absent(),
      pieceWidth: map['piece_width'] != null ? Value((map['piece_width'] as num).toDouble()) : const Value.absent(),
      thickness: map['thickness'] != null ? Value((map['thickness'] as num).toDouble()) : const Value.absent(),
      effectiveCoverageWidth: map['effective_coverage_width'] != null ? Value((map['effective_coverage_width'] as num).toDouble()) : const Value.absent(),
      defaultWastePercent: map['default_waste_percent'] != null ? Value((map['default_waste_percent'] as num).toDouble()) : const Value.absent(),
      imageUrl: map['image_url'] != null ? Value(map['image_url']) : const Value.absent(),
      minSellingPrice: map['min_selling_price'] != null ? Value((map['min_selling_price'] as num).toDouble()) : const Value.absent(),
      costPriceOverride: map['cost_price_override'] != null ? Value((map['cost_price_override'] as num).toDouble()) : const Value.absent(),
      sellingPriceOverride: map['selling_price_override'] != null ? Value((map['selling_price_override'] as num).toDouble()) : const Value.absent(),
      technicianPriceOverride: map['technician_price_override'] != null ? Value((map['technician_price_override'] as num).toDouble()) : const Value.absent(),
      syncStatus: const Value('pending_insert'),
    );
  }

  LocalSupplierPricingsCompanion _pricingCompanionFromMap(Map<String, dynamic> map) {
    return LocalSupplierPricingsCompanion(
      id: map['id'] != null ? Value(map['id']) : const Value.absent(),
      productVariantId: map['product_variant_id'] != null ? Value(map['product_variant_id']) : const Value.absent(),
      supplierId: map['supplier_id'] != null ? Value(map['supplier_id']) : const Value.absent(),
      supplierCode: map['supplier_code'] != null ? Value(map['supplier_code'] as String?) : const Value.absent(),
      listPrice: map['list_price'] != null ? Value((map['list_price'] as num).toDouble()) : const Value.absent(),
      netPrice: map['net_price'] != null ? Value((map['net_price'] as num).toDouble()) : const Value.absent(),
      discountValue: map['discount_value'] != null ? Value((map['discount_value'] as num).toDouble()) : const Value.absent(),
      isPreferred: map['is_preferred'] != null ? Value(map['is_preferred'] as bool) : const Value.absent(),
      syncStatus: const Value('pending_insert'),
    );
  }
}

