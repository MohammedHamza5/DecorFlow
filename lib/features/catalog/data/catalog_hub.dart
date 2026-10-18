import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/product_repository.dart';
import 'package:stream_pay/features/catalog/data/pricing_repository.dart';
import 'catalog_hub_state.dart';
import 'local_catalog_data.dart';

/// The central StateNotifier for the entire catalog system.
/// Single source of truth for products + stock + filter.
class CatalogHubNotifier extends StateNotifier<CatalogHubState> {
  final ProductRepository _repository;
  final PricingRepository _pricingRepository;

  CatalogHubNotifier(this._repository, this._pricingRepository) : super(const CatalogHubState()) {
    load();
  }

  // ─── Load ──────────────────────────────────────────────────

  Future<void> load({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final List<dynamic> response;

      if (LocalCatalogData.useLocalCatalog) {
        response = LocalCatalogData.getProducts();
      } else {
        if (forceRefresh) {
          _repository.invalidateCache();
        }
        response = await _repository.getProducts(limit: 500);
      }

      final pricingRules = await _pricingRepository.getAllRules();

      final products = response
          .map((p) => EnrichedProduct.fromMap(
                p as Map<String, dynamic>,
                pricingRules: pricingRules,
              ))
          .toList();

      // Build metadata from actual data
      final categories = products.map((p) => p.category).toSet().toList()
        ..sort();
      final brands =
          products
              .where((p) => p.brand != null && p.brand!.isNotEmpty)
              .map((p) => p.brand!)
              .toSet()
              .toList()
            ..sort();

      final allPrices = products
          .where((p) => p.hasPrice)
          .map((p) => p.maxNetPrice)
          .toList();
      final maxPrice = allPrices.isNotEmpty
          ? allPrices.reduce((a, b) => a > b ? a : b)
          : 1000.0;

      state = state.copyWith(
        isLoading: false,
        allProducts: products,
        availableCategories: categories,
        availableBrands: brands,
        globalMaxPrice: maxPrice,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Filter Actions ────────────────────────────────────────

  void selectGroup(String? groupId) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        selectedGroupId: groupId,
        clearGroup: groupId == null,
        clearCategory: true,
      ),
    );
  }

  void selectCategory(String? category) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        selectedCategory: category,
        clearCategory: category == null,
      ),
    );
  }

  void setSearch(String query) {
    state = state.copyWith(filter: state.filter.copyWith(searchQuery: query));
  }

  void toggleBrand(String brand) {
    final brands = Set<String>.from(state.filter.selectedBrands);
    if (brands.contains(brand)) {
      brands.remove(brand);
    } else {
      brands.add(brand);
    }
    state = state.copyWith(
      filter: state.filter.copyWith(selectedBrands: brands),
    );
  }

  void setPriceRange(RangeValues? range) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        priceRange: range,
        clearPriceRange: range == null,
      ),
    );
  }

  void setStockFilter(StockFilter f) {
    state = state.copyWith(filter: state.filter.copyWith(stockFilter: f));
  }

  void setSortBy(CatalogSortBy sort) {
    state = state.copyWith(filter: state.filter.copyWith(sortBy: sort));
  }

  void resetFilter() {
    state = state.copyWith(filter: state.filter.reset());
  }

  // ─── Mutations (invalidate after) ─────────────────────────

  void invalidate() => load(forceRefresh: true);

  /// Update a single product's inventory qty locally (optimistic update).
  void updateLocalStock(String variantId, double newQty) {
    final updated = state.allProducts.map((p) {
      final variants = p.variants.map((v) {
        if (v.id == variantId) {
          StockStatus status;
          if (newQty <= 0) {
            status = StockStatus.outOfStock;
          } else if (v.reorderPoint > 0 && newQty <= v.reorderPoint) {
            status = StockStatus.lowStock;
          } else {
            status = StockStatus.inStock;
          }
          return EnrichedVariant(
            id: v.id,
            productId: v.productId,
            variantName: v.variantName,
            color: v.color,
            dimensions: v.dimensions,
            pieceLength: v.pieceLength,
            pieceWidth: v.pieceWidth,
            thickness: v.thickness,
            effectiveCoverageWidth: v.effectiveCoverageWidth,
            effectiveCoverageArea: v.effectiveCoverageArea,
            defaultWastePercent: v.defaultWastePercent,
            listPrice: v.listPrice,
            netPrice: v.netPrice,
            hasPrice: v.hasPrice,
            availableQty: newQty,
            reservedQty: v.reservedQty,
            reorderPoint: v.reorderPoint,
            stockStatus: status,
            pricingId: v.pricingId,
            supplierId: v.supplierId,
            supplierCode: v.supplierCode,
          );
        }
        return v;
      }).toList();

      return EnrichedProduct.fromRebuild(p, variants);
    }).toList();

    state = state.copyWith(allProducts: updated);
  }
}

/// Global provider — kept alive for the entire app session.
final catalogHubProvider =
    StateNotifierProvider<CatalogHubNotifier, CatalogHubState>((ref) {
  final notifier = CatalogHubNotifier(
    ref.watch(productRepositoryProvider),
    ref.watch(pricingRepositoryProvider),
  );
  ref.listen(isSyncingProvider, (previous, next) {
    if (previous?.value == true && next.value == false) {
      notifier.invalidate();
    }
  });
  return notifier;
});

/// Quick access to filtered products list.
final filteredProductsProvider = Provider<List<EnrichedProduct>>((ref) {
  return ref.watch(catalogHubProvider).filteredProducts;
});

/// Quick access to low stock count (for badge on nav bar).
final catalogLowStockCountProvider = Provider<int>((ref) {
  return ref.watch(catalogHubProvider).lowStockCount;
});

/// Products for a specific category (used by CategoryScreen).
final categoryProductsProvider = Provider.family<List<EnrichedProduct>, String>(
  (ref, category) {
    final all = ref.watch(catalogHubProvider).allProducts;
    return all.where((p) => p.category == category).toList();
  },
);

/// Single enriched product by id.
final enrichedProductProvider = Provider.family<EnrichedProduct?, String>((
  ref,
  productId,
) {
  return ref
      .watch(catalogHubProvider)
      .allProducts
      .cast<EnrichedProduct?>()
      .firstWhere((p) => p?.id == productId, orElse: () => null);
});
