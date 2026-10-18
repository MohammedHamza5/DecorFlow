import 'package:stream_pay/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Handles the Inventory Ledger calculations.
/// Ensures that `availableQty` is completely deterministic based on `StockMovements`.
class InventoryEngine {
  final ErpDatabase _db;

  InventoryEngine(this._db);

  /// Registers a stock movement and updates the current `availableQty` in InventoryItems.
  Future<void> recordMovement({
    required int variantId,
    required String movementType, // purchase_receive, sales_dispatch, sales_return, wastage, adjustment
    required double quantityChange,
    int? referenceId,
    String? notes,
  }) async {
    return _db.transaction(() async {
      // 1. Record the movement in the ledger
      await _db.into(_db.stockMovements).insert(
        StockMovementsCompanion.insert(
          productVariantId: variantId,
          movementType: movementType,
          quantityChange: quantityChange,
          referenceId: Value(referenceId),
          notes: Value(notes),
        ),
      );

      // 2. Recalculate available quantity from ledger for absolute truth
      final movements = await (_db.select(_db.stockMovements)
            ..where((m) => m.productVariantId.equals(variantId)))
          .get();

      double totalAvailable = 0.0;
      for (final m in movements) {
        totalAvailable += m.quantityChange;
      }

      // 3. Update or Insert the cached value in InventoryItems
      final existingItem = await (_db.select(_db.inventoryItems)
            ..where((i) => i.productVariantId.equals(variantId)))
          .getSingleOrNull();

      if (existingItem != null) {
        await (_db.update(_db.inventoryItems)
              ..where((i) => i.id.equals(existingItem.id)))
            .write(InventoryItemsCompanion(
          availableQty: Value(totalAvailable),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        await _db.into(_db.inventoryItems).insert(
          InventoryItemsCompanion.insert(
            productVariantId: variantId,
            unitType: 'piece', // Fallback, normally retrieved from product
            availableQty: Value(totalAvailable),
          ),
        );
      }
    });
  }

  /// Specialized method: Receive Purchase Order
  Future<void> receivePurchaseOrder(int poId) async {
    return _db.transaction(() async {
      final po = await (_db.select(_db.purchaseOrders)..where((p) => p.id.equals(poId))).getSingle();
      if (po.status == 'received') return;

      final items = await (_db.select(_db.purchaseOrderItems)..where((i) => i.purchaseOrderId.equals(poId))).get();

      for (final item in items) {
        await recordMovement(
          variantId: item.productVariantId,
          movementType: 'purchase_receive',
          quantityChange: item.quantity,
          referenceId: poId,
          notes: 'PO #$poId received',
        );

        // Optionally update the CategoryPrices base_cost here if the logic dictates it
        // based on moving average or latest cost.
      }

      await (_db.update(_db.purchaseOrders)..where((p) => p.id.equals(poId))).write(
        PurchaseOrdersCompanion(status: const Value('received'), updatedAt: Value(DateTime.now()))
      );
    });
  }
}
