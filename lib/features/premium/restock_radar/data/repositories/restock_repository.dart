import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../domain/models/supplier.dart';

class LowStockItem {
  final String variantId;
  final String productName;
  final String variantName;
  final String category;
  final double availableQty;
  final double safetyStock;
  final double recommendedOrderQty;
  final String? supplierName;
  final String? supplierPhone;

  LowStockItem({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.category,
    required this.availableQty,
    required this.safetyStock,
    required this.recommendedOrderQty,
    this.supplierName,
    this.supplierPhone,
  });
}

class RestockRepository {
  final PremiumDependencies _deps;

  RestockRepository(this._deps);

  /// Fetches all suppliers for the shop.
  Future<List<Supplier>> getSuppliers() async {
    final shopId = _deps.currentShopId;
    if (shopId == null) return [];

    try {
      final response = await _deps.supabaseClient
          .from('premium_supplier_contacts')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Supplier.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to fetch suppliers',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Creates a supplier contact.
  Future<Supplier> createSupplier({
    required String name,
    required String phone,
    String? contactPerson,
    String? email,
    String? categorySupplied,
  }) async {
    final shopId = _deps.currentShopId;
    if (shopId == null) throw Exception('No active shop session');

    try {
      final data = {
        'shop_id': shopId,
        'name': name,
        'phone': phone,
        'contact_person': contactPerson,
        'email': email,
        'category_supplied': categorySupplied,
      };

      final response = await _deps.supabaseClient
          .from('premium_supplier_contacts')
          .insert(data)
          .select()
          .single();

      return Supplier.fromJson(response);
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to create supplier contact',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      rethrow;
    }
  }

  /// Fetches low stock items that are below the safety threshold.
  Future<List<LowStockItem>> getLowStockItems() async {
    try {
      // 1. Fetch all inventory items (core table)
      final coreInventory = await _deps.supabaseClient
          .from('inventory_items')
          .select('*, product_variants(*, products(*))');

      // 2. Fetch all premium radar settings
      final premiumRadar = await _deps.supabaseClient
          .from('premium_inventory_radar')
          .select('*, premium_supplier_contacts(*)');

      // Index premium radar by product_variant_id for O(1) lookup
      final radarMap = {
        for (var item in premiumRadar as List)
          item['product_variant_id'] as String: item
      };

      final List<LowStockItem> lowStockList = [];

      for (var inv in coreInventory as List) {
        final variant = inv['product_variants'] as Map<String, dynamic>?;
        if (variant == null) continue;
        final product = variant['products'] as Map<String, dynamic>?;
        if (product == null) continue;

        final variantId = variant['id'] as String;
        final availableQty = (inv['available_qty'] as num?)?.toDouble() ?? 0.0;

        // Determine safety stock limit
        double safetyStock = 10.0; // Default fallback
        double recommendedOrderQty = 50.0;
        String? supplierName;
        String? supplierPhone;

        if (radarMap.containsKey(variantId)) {
          final radar = radarMap[variantId]!;
          if (radar['safety_stock_override'] != null) {
            safetyStock = (radar['safety_stock_override'] as num).toDouble();
          }
          recommendedOrderQty = (radar['restock_order_quantity'] as num?)?.toDouble() ?? 50.0;
          
          final supplier = radar['premium_supplier_contacts'] as Map<String, dynamic>?;
          if (supplier != null) {
            supplierName = supplier['name'] as String?;
            supplierPhone = supplier['phone'] as String?;
          }
        } else {
          // If no override, try core reorder point if available
          final coreReorderPoint = (inv['reorder_point'] as num?)?.toDouble();
          if (coreReorderPoint != null && coreReorderPoint > 0.0) {
            safetyStock = coreReorderPoint;
          }
        }

        // Check if stock is low
        if (availableQty <= safetyStock) {
          lowStockList.add(
            LowStockItem(
              variantId: variantId,
              productName: product['name'] as String? ?? '',
              variantName: variant['variant_name'] as String? ?? '',
              category: product['category'] as String? ?? '',
              availableQty: availableQty,
              safetyStock: safetyStock,
              recommendedOrderQty: recommendedOrderQty,
              supplierName: supplierName,
              supplierPhone: supplierPhone,
            ),
          );
        }
      }

      return lowStockList;
    } catch (e, st) {
      _deps.logSystem(
        level: 'error',
        message: 'Failed to fetch low stock items via radar',
        error: e.toString(),
        stackTrace: st.toString(),
      );
      return [];
    }
  }
}
