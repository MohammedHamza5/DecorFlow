import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:stream_pay/features/catalog/data/local_catalog_data.dart';

/// Repository for Inventory Management operations.
class InventoryRepository {
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  InventoryRepository(this._db, this._syncEngine);

  // ─── In-memory cache ──────────────────────────────────────
  List<Map<String, dynamic>>? _cachedItems;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 2);

  bool get _isCacheValid =>
      _cachedItems != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;

  void invalidateCache() {
    _cachedItems = null;
    _cacheTime = null;
  }

  // ─── Read Operations ──────────────────────────────────────

  /// Get all inventory items with product & variant info.
  Future<List<Map<String, dynamic>>> getInventoryItems({
    String? category,
    bool lowStockOnly = false,
  }) async {
    if (LocalCatalogData.useLocalCatalog) {
      final List<Map<String, dynamic>> localItems = [];
      for (final p in LocalCatalogData.getProducts()) {
        final variants = p['product_variants'] as List? ?? [];
        for (final v in variants) {
          final invList = v['inventory_items'] as List? ?? [];
          for (final inv in invList) {
            localItems.add({
              'id': inv['id'],
              'available_qty': inv['available_qty'],
              'reserved_qty': inv['reserved_qty'],
              'reorder_point': inv['reorder_point'],
              'unit_type': p['unit_type'],
              'updated_at': DateTime.now().toIso8601String(),
              'product_variant': {
                'id': v['id'],
                'variant_name': v['variant_name'],
                'color': v['color'],
                'piece_length': v['piece_length'],
                'piece_width': v['piece_width'],
                'product': {
                  'id': p['id'],
                  'name': p['name'],
                  'category': p['category'],
                  'brand': p['brand'],
                  'unit_type': p['unit_type'],
                  'image_url': p['image_url'],
                }
              }
            });
          }
        }
      }

      var items = localItems;
      if (category != null) {
        items = items.where((item) {
          final variantRaw = item['product_variant'];
          final variant = variantRaw != null ? Map<String, dynamic>.from(variantRaw as Map) : null;
          final productRaw = variant?['product'];
          final product = productRaw != null ? Map<String, dynamic>.from(productRaw as Map) : null;
          return product?['category'] == category;
        }).toList();
      }

      if (lowStockOnly) {
        items = items.where((item) {
          final qty = (item['available_qty'] as num?)?.toDouble() ?? 0;
          final reorder = (item['reorder_point'] as num?)?.toDouble() ?? 0;
          return reorder > 0 && qty <= reorder;
        }).toList();
      }

      return items;
    }

    if (_isCacheValid && category == null && !lowStockOnly) {
      return _cachedItems!;
    }

    final query = _db.select(_db.localInventoryItems).join([
      drift.leftOuterJoin(
        _db.localProductVariants,
        _db.localProductVariants.id.equalsExp(_db.localInventoryItems.productVariantId),
      ),
      drift.leftOuterJoin(
        _db.localProducts,
        _db.localProducts.id.equalsExp(_db.localProductVariants.productId),
      ),
    ]);

    if (category != null) {
      query.where(_db.localProducts.category.equals(category));
    }

    query.orderBy([drift.OrderingTerm.desc(_db.localInventoryItems.updatedAt)]);

    final results = await query.get();

    var items = results.map((row) {
      final inv = row.readTable(_db.localInventoryItems);
      final variant = row.readTableOrNull(_db.localProductVariants);
      final product = row.readTableOrNull(_db.localProducts);

      return {
        'id': inv.id,
        'available_qty': inv.availableQty,
        'reserved_qty': inv.reservedQty,
        'reorder_point': inv.reorderPoint,
        'unit_type': product?.unitType,
        'updated_at': inv.updatedAt.toIso8601String(),
        'product_variant': variant == null ? null : {
          'id': variant.id,
          'variant_name': variant.variantName,
          'color': variant.color,
          'piece_length': variant.pieceLength,
          'piece_width': variant.pieceWidth,
          'product': product == null ? null : {
            'id': product.id,
            'name': product.name,
            'category': product.category,
            'brand': product.brand,
            'unit_type': product.unitType,
            'image_url': product.imageUrl,
          }
        }
      };
    }).toList();

    // Filter low stock
    if (lowStockOnly) {
      items = items.where((item) {
        final qty = (item['available_qty'] as num?)?.toDouble() ?? 0;
        final reorder = (item['reorder_point'] as num?)?.toDouble() ?? 0;
        return reorder > 0 && qty <= reorder;
      }).toList();
    }

    // Cache full results only
    if (category == null && !lowStockOnly) {
      _cachedItems = items;
      _cacheTime = DateTime.now();
    }

    return items;
  }

  /// Get a single inventory item with full details.
  Future<Map<String, dynamic>?> getInventoryItem(String id) async {
    if (LocalCatalogData.useLocalCatalog) {
      for (final p in LocalCatalogData.getProducts()) {
        final variants = p['product_variants'] as List? ?? [];
        for (final v in variants) {
          final invList = v['inventory_items'] as List? ?? [];
          for (final inv in invList) {
            if (inv['id'] == id) {
              return {
                'id': inv['id'],
                'available_qty': inv['available_qty'],
                'reserved_qty': inv['reserved_qty'],
                'reorder_point': inv['reorder_point'],
                'unit_type': p['unit_type'],
                'updated_at': DateTime.now().toIso8601String(),
                'product_variant': {
                  ...v,
                  'product': {
                    'id': p['id'],
                    'name': p['name'],
                    'category': p['category'],
                    'brand': p['brand'],
                    'unit_type': p['unit_type'],
                    'image_url': p['image_url'],
                  },
                  'supplier_product_pricings': v['supplier_product_pricings'],
                }
              };
            }
          }
        }
      }
      return null;
    }

    final query = _db.select(_db.localInventoryItems).join([
      drift.leftOuterJoin(
        _db.localProductVariants,
        _db.localProductVariants.id.equalsExp(_db.localInventoryItems.productVariantId),
      ),
      drift.leftOuterJoin(
        _db.localProducts,
        _db.localProducts.id.equalsExp(_db.localProductVariants.productId),
      ),
    ])..where(_db.localInventoryItems.id.equals(id));

    final results = await query.get();
    if (results.isEmpty) return null;

    final row = results.first;
    final inv = row.readTable(_db.localInventoryItems);
    final variant = row.readTableOrNull(_db.localProductVariants);
    final product = row.readTableOrNull(_db.localProducts);

    List<Map<String, dynamic>> pricings = [];
    if (variant != null) {
      final pricingResults = await (_db.select(_db.localSupplierPricings)
            ..where((p) => p.productVariantId.equals(variant.id)))
          .get();
      pricings = pricingResults.map((p) => {
        'id': p.id,
        'list_price': p.listPrice,
        'net_price': p.netPrice,
        'discount_value': p.discountValue,
        'is_preferred': p.isPreferred,
      }).toList();
    }

    return {
      'id': inv.id,
      'available_qty': inv.availableQty,
      'reserved_qty': inv.reservedQty,
      'reorder_point': inv.reorderPoint,
      'unit_type': product?.unitType,
      'updated_at': inv.updatedAt.toIso8601String(),
      'product_variant': variant == null ? null : {
        'id': variant.id,
        'variant_name': variant.variantName,
        'color': variant.color,
        'piece_length': variant.pieceLength,
        'piece_width': variant.pieceWidth,
        'product': product == null ? null : {
          'id': product.id,
          'name': product.name,
          'category': product.category,
          'brand': product.brand,
          'unit_type': product.unitType,
          'image_url': product.imageUrl,
        },
        'supplier_product_pricings': pricings,
      }
    };
  }

  /// Get low stock items count (for badge).
  Future<int> getLowStockCount() async {
    final items = await getInventoryItems();
    return items.where((item) {
      final qty = (item['available_qty'] as num?)?.toDouble() ?? 0;
      final reorder = (item['reorder_point'] as num?)?.toDouble() ?? 0;
      return reorder > 0 && qty <= reorder;
    }).length;
  }

  Future<Map<String, dynamic>?> getInventoryItemByVariantId(String variantId) async {
    final query = _db.select(_db.localInventoryItems)..where((t) => t.productVariantId.equals(variantId));
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return {
      'id': result.id,
      'product_variant_id': result.productVariantId,
      'available_qty': result.availableQty,
      'reserved_qty': result.reservedQty,
      'damaged_qty': result.damagedQty,
      'reorder_point': result.reorderPoint,
      'created_at': result.createdAt.toIso8601String(),
    };
  }

  /// Get inventory stats summary.
  Future<Map<String, dynamic>> getInventoryStats() async {
    final items = await getInventoryItems();

    int totalItems = items.length;
    int lowStockItems = 0;
    int outOfStockItems = 0;
    double totalValue = 0;

    for (final item in items) {
      final qty = (item['available_qty'] as num?)?.toDouble() ?? 0;
      final reorder = (item['reorder_point'] as num?)?.toDouble() ?? 0;

      if (qty <= 0) {
        outOfStockItems++;
      } else if (reorder > 0 && qty <= reorder) {
        lowStockItems++;
      }

      // Compute stock value
      if (qty > 0) {
        final variantRaw = item['product_variant'];
        if (variantRaw != null) {
          final variant = Map<String, dynamic>.from(variantRaw as Map);
          final variantId = variant['id'] as String?;
          if (variantId != null) {
            double price = 0;
            if (LocalCatalogData.useLocalCatalog) {
              // Look up from local catalog
              for (final p in LocalCatalogData.getProducts()) {
                for (final v in (p['product_variants'] as List? ?? [])) {
                  if (v['id'] == variantId) {
                    final pricings = v['supplier_product_pricings'] as List? ?? [];
                    if (pricings.isNotEmpty) {
                      final pref = pricings.firstWhere(
                        (pr) => pr['is_preferred'] == true,
                        orElse: () => pricings.first,
                      );
                      price = (pref['net_price'] as num?)?.toDouble() ??
                              (pref['list_price'] as num?)?.toDouble() ?? 0;
                    }
                  }
                }
              }
            } else {
              // Look up from Drift DB
              final pricingResults = await (_db.select(_db.localSupplierPricings)
                    ..where((p) => p.productVariantId.equals(variantId)))
                  .get();
              if (pricingResults.isNotEmpty) {
                final pref = pricingResults.firstWhere(
                  (p) => p.isPreferred,
                  orElse: () => pricingResults.first,
                );
                price = pref.netPrice > 0 ? pref.netPrice : pref.listPrice;
              }
            }
            totalValue += qty * price;
          }
        }
      }
    }

    return {
      'total_items': totalItems,
      'low_stock': lowStockItems,
      'out_of_stock': outOfStockItems,
      'total_value': totalValue,
    };
  }

  /// Search inventory by product name or variant code.
  Future<List<Map<String, dynamic>>> searchInventory(String query) async {
    final items = await getInventoryItems();
    final q = query.toLowerCase();

    return items.where((item) {
      final variantRaw = item['product_variant'];
      final variant = variantRaw != null ? Map<String, dynamic>.from(variantRaw as Map) : null;
      final productRaw = variant?['product'];
      final product = productRaw != null ? Map<String, dynamic>.from(productRaw as Map) : null;
      final name = (product?['name'] as String? ?? '').toLowerCase();
      final variantName = (variant?['variant_name'] as String? ?? '').toLowerCase();
      return name.contains(q) || variantName.contains(q);
    }).toList();
  }

  // ─── Write Operations ─────────────────────────────────────

  /// Add a new item to inventory (or update if exists).
  Future<Map<String, dynamic>> addInventoryItem({
    required String productVariantId,
    required String unitType,
    required double quantity,
    double? reorderPoint,
    String? notes,
  }) async {
    final existing = await (_db.select(_db.localInventoryItems)
          ..where((t) => t.productVariantId.equals(productVariantId)))
        .getSingleOrNull();

    if (existing != null) {
      await recordMovement(
        inventoryItemId: existing.id,
        type: 'in',
        quantity: quantity,
        referenceType: 'manual',
        notes: notes ?? 'إضافة كمية',
      );

      if (reorderPoint != null) {
        await (_db.update(_db.localInventoryItems)..where((t) => t.id.equals(existing.id))).write(
          LocalInventoryItemsCompanion(
            reorderPoint: drift.Value(reorderPoint),
            syncStatus: const drift.Value('pending_update'),
            updatedAt: drift.Value(DateTime.now()),
          )
        );
        _syncEngine.sync();
      }

      invalidateCache();
      return (await getInventoryItem(existing.id))!;
    }

    final newId = const Uuid().v4();
    final now = DateTime.now();

    await _db.into(_db.localInventoryItems).insert(
      LocalInventoryItemsCompanion.insert(
        id: drift.Value(newId),
        productVariantId: productVariantId,
        availableQty: drift.Value(0),
        reservedQty: const drift.Value(0),
        reorderPoint: drift.Value(reorderPoint ?? 0),
        syncStatus: const drift.Value('pending_insert'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      )
    );

    await recordMovement(
      inventoryItemId: newId,
      type: 'initial',
      quantity: quantity,
      referenceType: 'initial',
      notes: notes ?? 'جرد أولي',
    );

    invalidateCache();
    return (await getInventoryItem(newId))!;
  }

  /// Record a stock movement (in/out/adjustment).
  Future<Map<String, dynamic>> recordMovement({
    required String inventoryItemId,
    required String type,
    required double quantity,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    final movementId = const Uuid().v4();
    final now = DateTime.now();

    await _db.into(_db.localInventoryMovements).insert(
      LocalInventoryMovementsCompanion.insert(
        id: drift.Value(movementId),
        inventoryItemId: inventoryItemId,
        movementType: type,
        quantity: drift.Value(quantity),
        referenceId: drift.Value(referenceId),
        notes: drift.Value(notes),
        syncStatus: const drift.Value('pending_insert'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      )
    );

    final invItem = await (_db.select(_db.localInventoryItems)..where((t) => t.id.equals(inventoryItemId))).getSingle();
    double qtyChange = 0;
    if (type == 'in' || type == 'initial' || type == 'return') {
      qtyChange = quantity;
    } else if (type == 'out' || type == 'damaged') {
      qtyChange = -quantity;
    } else if (type == 'adjustment') {
      qtyChange = quantity;
    }

    await (_db.update(_db.localInventoryItems)..where((t) => t.id.equals(inventoryItemId))).write(
      LocalInventoryItemsCompanion(
        availableQty: drift.Value(invItem.availableQty + qtyChange),
        syncStatus: const drift.Value('pending_update'),
        updatedAt: drift.Value(now),
      )
    );

    _syncEngine.sync();
    invalidateCache();

    final movement = await (_db.select(_db.localInventoryMovements)..where((t) => t.id.equals(movementId))).getSingle();
    return {
      'id': movement.id,
      'inventory_item_id': movement.inventoryItemId,
      'movement_type': movement.movementType,
      'quantity': movement.quantity,
      'reference_type': referenceType ?? 'manual',
      'reference_id': movement.referenceId,
      'notes': movement.notes,
      'created_by': movement.createdBy,
      'created_at': movement.createdAt.toIso8601String(),
    };
  }

  /// Update reorder point for an item.
  Future<void> updateReorderPoint(String itemId, double reorderPoint) async {
    await (_db.update(_db.localInventoryItems)..where((t) => t.id.equals(itemId))).write(
      LocalInventoryItemsCompanion(
        reorderPoint: drift.Value(reorderPoint),
        syncStatus: const drift.Value('pending_update'),
        updatedAt: drift.Value(DateTime.now()),
      )
    );
    _syncEngine.sync();
    invalidateCache();
  }

  /// Record damaged stock.
  Future<Map<String, dynamic>> recordDamage({
    required String inventoryItemId,
    required double quantity,
    String? notes,
  }) async {
    // Update damaged qty
    final invItem = await (_db.select(_db.localInventoryItems)
          ..where((t) => t.id.equals(inventoryItemId)))
        .getSingle();

    await (_db.update(_db.localInventoryItems)
          ..where((t) => t.id.equals(inventoryItemId)))
        .write(LocalInventoryItemsCompanion(
      damagedQty: drift.Value(invItem.damagedQty + quantity),
      syncStatus: const drift.Value('pending_update'),
      updatedAt: drift.Value(DateTime.now()),
    ));

    // Also record as movement (subtracts from available)
    return recordMovement(
      inventoryItemId: inventoryItemId,
      type: 'damaged',
      quantity: quantity,
      referenceType: 'manual',
      notes: notes ?? 'تسجيل تالف',
    );
  }

  /// Delete an inventory item and its movements.
  Future<void> deleteInventoryItem(String itemId) async {
    await (_db.delete(_db.localInventoryMovements)
          ..where((t) => t.inventoryItemId.equals(itemId)))
        .go();
    await (_db.delete(_db.localInventoryItems)
          ..where((t) => t.id.equals(itemId)))
        .go();
    invalidateCache();
  }

  /// Get movement history for an item.
  Future<List<Map<String, dynamic>>> getMovements(
    String inventoryItemId, {
    int limit = 50,
  }) async {
    final results = await (_db.select(_db.localInventoryMovements)
          ..where((t) => t.inventoryItemId.equals(inventoryItemId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();

    // Get current qty to compute running balance
    final invItem = await (_db.select(_db.localInventoryItems)
          ..where((t) => t.id.equals(inventoryItemId)))
        .getSingleOrNull();
    double runningBalance = invItem?.availableQty ?? 0;

    // Movements are sorted newest-first, so we assign balance going backwards
    final movements = <Map<String, dynamic>>[];
    for (final m in results) {
      movements.add({
        'id': m.id,
        'inventory_item_id': m.inventoryItemId,
        'movement_type': m.movementType,
        'quantity': m.quantity,
        'reference_id': m.referenceId,
        'notes': m.notes,
        'created_by': m.createdBy,
        'created_at': m.createdAt.toIso8601String(),
        'balance_after': runningBalance,
      });

      // Walk backwards: undo the movement to get previous balance
      if (m.movementType == 'in' || m.movementType == 'initial' || m.movementType == 'return') {
        runningBalance -= m.quantity;
      } else if (m.movementType == 'out' || m.movementType == 'damaged') {
        runningBalance += m.quantity;
      }
    }

    return movements;
  }

  /// Deduct stock after invoice is created.
  Future<void> deductForInvoice(
    String invoiceId,
    List<Map<String, dynamic>> items,
  ) async {
    for (final item in items) {
      final variantId = item['product_variant_id'] as String?;
      final qty = (item['quantity'] as num?)?.toDouble() ?? 0;
      if (variantId == null || qty <= 0) continue;

      final invItem = await (_db.select(_db.localInventoryItems)
            ..where((t) => t.productVariantId.equals(variantId)))
          .getSingleOrNull();

      if (invItem != null) {
        await recordMovement(
          inventoryItemId: invItem.id,
          type: 'out',
          quantity: qty,
          referenceType: 'invoice',
          referenceId: invoiceId,
          notes: 'خصم تلقائي - فاتورة',
        );
      }
    }
  }

  /// Get product variants not yet in inventory (for adding new items).
  Future<List<Map<String, dynamic>>> getUnstockedVariants() async {
    final query = _db.select(_db.localProductVariants).join([
      drift.leftOuterJoin(
        _db.localInventoryItems,
        _db.localInventoryItems.productVariantId.equalsExp(_db.localProductVariants.id),
      ),
      drift.innerJoin(
        _db.localProducts,
        _db.localProducts.id.equalsExp(_db.localProductVariants.productId),
      ),
    ])..where(_db.localInventoryItems.id.isNull());

    final results = await query.get();
    return results.map((row) {
      final v = row.readTable(_db.localProductVariants);
      final p = row.readTable(_db.localProducts);
      return {
        'id': v.id,
        'variant_name': v.variantName,
        'color': v.color,
        'piece_length': v.pieceLength,
        'piece_width': v.pieceWidth,
        'product': {
          'id': p.id,
          'name': p.name,
          'category': p.category,
          'unit_type': p.unitType,
        }
      };
    }).toList();
  }

  /// Get variants with product info for adding to inventory.
  Future<List<Map<String, dynamic>>> getVariantsForProduct(
    String productId,
  ) async {
    final query = _db.select(_db.localProductVariants).join([
      drift.innerJoin(
        _db.localProducts,
        _db.localProducts.id.equalsExp(_db.localProductVariants.productId),
      ),
    ])..where(_db.localProductVariants.productId.equals(productId));

    query.where(_db.localProducts.isActive.equals(true));
    query.orderBy([drift.OrderingTerm.asc(_db.localProductVariants.variantName)]);

    final results = await query.get();
    return results.map((row) {
      final v = row.readTable(_db.localProductVariants);
      final p = row.readTable(_db.localProducts);
      return {
        'id': v.id,
        'variant_name': v.variantName,
        'color': v.color,
        'piece_length': v.pieceLength,
        'piece_width': v.pieceWidth,
        'product': {
          'id': p.id,
          'name': p.name,
          'category': p.category,
          'unit_type': p.unitType,
        }
      };
    }).toList();
  }
}
