import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/features/catalog/data/product_repository.dart';
import 'package:stream_pay/features/quotes/data/quote_repository.dart';
import 'package:stream_pay/features/invoices/data/invoice_repository.dart';
import 'package:stream_pay/features/inventory/data/inventory_repository.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:stream_pay/features/projects/data/offline_project_repository.dart';
import 'package:stream_pay/features/projects/data/customer_repository.dart';
import 'package:stream_pay/features/projects/data/project_repository.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_pay/core/data/supabase_repository.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';

/// ─── Repository Providers ────────────────────────────────────
///
/// Single source of truth for all data access providers.
/// Each repository is scoped to the current Supabase client.

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseProvider);
  // Watch shop ID to automatically recreate and sync when it becomes available or changes.
  ref.watch(currentShopIdProvider);
  
  final engine = SyncEngine(db, supabase, ref);
  ref.onDispose(() => engine.dispose());
  return engine;
});

final isSyncingProvider = Provider<ValueNotifier<bool>>((ref) {
  return ref.watch(syncEngineProvider).isSyncingNotifier;
});

final offlineProjectRepositoryProvider = Provider<OfflineProjectRepository>((
  ref,
) {
  return OfflineProjectRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(erpDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
    ref.watch(erpDatabaseProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(supabaseProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

/// ─── Data Providers (Async) ──────────────────────────────────

/// Products list (kept alive — no autoDispose for fast navigation).
final productsProvider = FutureProvider
    .family<List<Map<String, dynamic>>, String?>((ref, category) async {
      print('[Provider] productsProvider($category) — STARTED');
      final stopwatch = Stopwatch()..start();
      try {
        final repo = ref.watch(productRepositoryProvider);
        final result = await repo.getProducts(category: category, limit: 5000);
        print('[Provider] productsProvider($category) — ✓ DONE ${result.length} products (${stopwatch.elapsedMilliseconds}ms)');
        return result;
      } catch (e, stack) {
        print('[Provider] productsProvider($category) — ✗ ERROR: $e');
        print('[Provider] Stack: ${stack.toString().split('\n').take(3).join('\n')}');
        rethrow;
      }
    });

/// Checks if the product catalog is empty (lightweight check).
final isCatalogEmptyProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final products = await repo.getProducts(limit: 1);
  return products.isEmpty;
});

/// Product categories (kept alive).
final categoriesProvider = FutureProvider<List<String>>((
  ref,
) async {
  print('[Provider] categoriesProvider — STARTED');
  try {
    final repo = ref.watch(productRepositoryProvider);
    final result = await repo.getCategories();
    print('[Provider] categoriesProvider — ✓ DONE ${result.length} categories');
    return result;
  } catch (e) {
    print('[Provider] categoriesProvider — ✗ ERROR: $e');
    rethrow;
  }
});

/// Single product with variants.
final productDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, productId) async {
      final repo = ref.watch(productRepositoryProvider);
      return repo.getProductWithVariants(productId);
    });

/// Quotes list.
final quotesProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, status) async {
  final repo = ref.read(quoteRepositoryProvider);
  return repo.getQuotes(status: status);
});

final invoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, customerId) async {
  final repo = ref.read(invoiceRepositoryProvider);
  return repo.getInvoices(customerId: customerId);
});

/// Single quote with items.
final quoteDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, quoteId) async {
      final repo = ref.watch(quoteRepositoryProvider);
      return repo.getQuoteWithItems(quoteId);
    });

/// Customers list (basic, fast — no financial data).
final customersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repo = ref.watch(customerRepositoryProvider);
      return repo.getCustomersBasic();
    });

/// Customers list with financial data (used in smart CRM list screen).
/// Param: filterType ('all' | 'has_debt' | 'VIP')
final customersWithFinancialsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String?>((ref, filterType) async {
      final repo = ref.watch(customerRepositoryProvider);
      return repo.getCustomers(filterType: filterType ?? 'all');
    });

/// Full customer profile (for tab-based CRM profile screen).
final customerProfileProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, customerId) async {
      final repo = ref.watch(customerRepositoryProvider);
      return repo.getCustomerProfile(customerId);
    });

/// Customer financial ledger (chronological account statement).
final customerLedgerProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, customerId) async {
      final repo = ref.watch(customerRepositoryProvider);
      return repo.getCustomerLedger(customerId);
    });

/// Suppliers list with connectivity checking and SharedPreferences caching for offline usage.
final suppliersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  final prefs = await SharedPreferences.getInstance();
  const cacheKey = 'cached_suppliers';
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    final cachedStr = prefs.getString(cacheKey);
    if (cachedStr != null) {
      final list = jsonDecode(cachedStr) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
  
  try {
    final repo = SupabaseRepository(ref.watch(supabaseProvider));
    final result = await repo.fetchAll('suppliers', orderBy: 'name', ascending: true);
    await prefs.setString(cacheKey, jsonEncode(result));
    return result;
  } catch (e) {
    final cachedStr = prefs.getString(cacheKey);
    if (cachedStr != null) {
      final list = jsonDecode(cachedStr) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
});

/// Projects list.
final projectsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String?>((ref, status) async {
      final repo = ref.watch(offlineProjectRepositoryProvider);
      return repo.getProjects(status: status);
    });

/// Single project with measurements.
final projectDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, projectId) async {
      final repo = ref.watch(offlineProjectRepositoryProvider);
      return repo.getProjectWithMeasurements(projectId);
    });

// ─── Inventory Providers ──────────────────────────────────────

/// Inventory items list.
final inventoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, category) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryItems(category: category);
});

/// Low stock items count (for badge on nav).
final lowStockCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getLowStockCount();
});

/// Inventory stats summary.
final inventoryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryStats();
});

/// Single inventory item detail.
final inventoryItemDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, itemId) async {
      final repo = ref.watch(inventoryRepositoryProvider);
      return repo.getInventoryItem(itemId);
    });

/// Movement history for an inventory item.
final inventoryMovementsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, itemId) async {
      final repo = ref.watch(inventoryRepositoryProvider);
      return repo.getMovements(itemId);
    });

/// Shop info (name, phone, address) from Supabase.
final shopInfoProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return null;
  try {
    final supabase = ref.watch(supabaseProvider);
    final data = await supabase
        .from('shops')
        .select('name, phone, address')
        .eq('id', shopId)
        .maybeSingle();
    return data;
  } catch (_) {
    return null;
  }
});

