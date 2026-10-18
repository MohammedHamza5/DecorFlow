import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import 'tables/all_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Customers,
  Projects,
  Products,
  ProductVariants,
  ProductPresets,
  ProductAssemblies,
  Suppliers,
  SupplierProductPricings,
  PriceHistories,
  Quotes,
  QuoteItems,
  CalculationRecords,
  MeasurementSessions,
  Rooms,
  Walls,
  Openings,
  InventoryItems,
  SystemLogs,
  CategoryPrices,
  PricingRules,
  PurchaseOrders,
  PurchaseOrderItems,
  StockMovements,
  CashTransactions,
  ExpenseCategories,
  Expenses,
  Technicians,
  InstallationJobs,
  TechnicianLedger,
  ShiftClosings,
])
class ErpDatabase extends _$ErpDatabase {
  ErpDatabase() : super(_openConnection());

  // For testing
  ErpDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }

  // ─── Customer DAOs ─────────────────────────────────────────────

  Future<List<Customer>> getAllCustomers() => select(customers).get();

  Stream<List<Customer>> watchAllCustomers() => select(customers).watch();

  Future<Customer> getCustomerById(int id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingle();

  Future<int> insertCustomer(CustomersCompanion entry) =>
      into(customers).insert(entry);

  Future<bool> updateCustomer(CustomersCompanion entry) =>
      update(customers).replace(entry);

  Future<int> deleteCustomer(int id) =>
      (delete(customers)..where((c) => c.id.equals(id))).go();

  // ─── Project DAOs ──────────────────────────────────────────────

  Future<List<Project>> getAllProjects() => select(projects).get();

  Stream<List<Project>> watchAllProjects() => select(projects).watch();

  Future<Project> getProjectById(int id) =>
      (select(projects)..where((p) => p.id.equals(id))).getSingle();

  Future<List<Project>> getProjectsByCustomer(int customerId) =>
      (select(projects)..where((p) => p.customerId.equals(customerId))).get();

  Future<int> insertProject(ProjectsCompanion entry) =>
      into(projects).insert(entry);

  Future<bool> updateProject(ProjectsCompanion entry) =>
      update(projects).replace(entry);

  // ─── Product DAOs ──────────────────────────────────────────────

  Future<List<Product>> getAllProducts() => select(products).get();

  Stream<List<Product>> watchAllProducts() => select(products).watch();

  Future<Product> getProductById(int id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingle();

  Future<List<Product>> searchProducts(String query) {
    return (select(products)
          ..where((p) =>
              p.name.contains(query) |
              p.code.contains(query) |
              p.brand.contains(query) |
              p.category.contains(query) |
              p.color.contains(query) |
              p.material.contains(query)))
        .get();
  }

  Future<List<Product>> getProductsByCategory(String category) =>
      (select(products)..where((p) => p.category.equals(category))).get();

  Future<int> insertProduct(ProductsCompanion entry) =>
      into(products).insert(entry);

  Future<bool> updateProduct(ProductsCompanion entry) =>
      update(products).replace(entry);

  Future<int> deleteProduct(int id) =>
      (delete(products)..where((p) => p.id.equals(id))).go();

  // ─── Product Variant DAOs ──────────────────────────────────────

  Future<List<ProductVariant>> getVariantsByProduct(int productId) =>
      (select(productVariants)
            ..where((v) => v.productId.equals(productId)))
          .get();

  Stream<List<ProductVariant>> watchVariantsByProduct(int productId) =>
      (select(productVariants)
            ..where((v) => v.productId.equals(productId)))
          .watch();

  Future<ProductVariant> getVariantById(int id) =>
      (select(productVariants)..where((v) => v.id.equals(id))).getSingle();

  Future<int> insertVariant(ProductVariantsCompanion entry) =>
      into(productVariants).insert(entry);

  Future<bool> updateVariant(ProductVariantsCompanion entry) =>
      update(productVariants).replace(entry);

  // ─── Supplier DAOs ─────────────────────────────────────────────

  Future<List<Supplier>> getAllSuppliers() => select(suppliers).get();

  Future<int> insertSupplier(SuppliersCompanion entry) =>
      into(suppliers).insert(entry);

  // ─── Supplier Pricing DAOs ─────────────────────────────────────

  Future<List<SupplierProductPricing>> getPricingByVariant(int variantId) =>
      (select(supplierProductPricings)
            ..where((p) => p.productVariantId.equals(variantId)))
          .get();

  Future<SupplierProductPricing?> getPreferredPricing(int variantId) =>
      (select(supplierProductPricings)
            ..where((p) =>
                p.productVariantId.equals(variantId) &
                p.isPreferred.equals(true)))
          .getSingleOrNull();

  Future<int> insertPricing(SupplierProductPricingsCompanion entry) =>
      into(supplierProductPricings).insert(entry);

  // ─── Quote DAOs ────────────────────────────────────────────────

  Future<List<Quote>> getAllQuotes() =>
      (select(quotes)..orderBy([(q) => OrderingTerm.desc(q.createdAt)])).get();

  Stream<List<Quote>> watchAllQuotes() =>
      (select(quotes)..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
          .watch();

  Future<Quote> getQuoteById(int id) =>
      (select(quotes)..where((q) => q.id.equals(id))).getSingle();

  Future<int> insertQuote(QuotesCompanion entry) =>
      into(quotes).insert(entry);

  Future<bool> updateQuote(QuotesCompanion entry) =>
      update(quotes).replace(entry);

  // ─── Quote Item DAOs ───────────────────────────────────────────

  Future<List<QuoteItem>> getItemsByQuote(int quoteId) =>
      (select(quoteItems)..where((i) => i.quoteId.equals(quoteId))).get();

  Stream<List<QuoteItem>> watchItemsByQuote(int quoteId) =>
      (select(quoteItems)..where((i) => i.quoteId.equals(quoteId))).watch();

  Future<int> insertQuoteItem(QuoteItemsCompanion entry) =>
      into(quoteItems).insert(entry);

  Future<bool> updateQuoteItem(QuoteItemsCompanion entry) =>
      update(quoteItems).replace(entry);

  Future<int> deleteQuoteItem(int id) =>
      (delete(quoteItems)..where((i) => i.id.equals(id))).go();

  // ─── Calculation Record DAOs ───────────────────────────────────

  Future<int> insertCalculation(CalculationRecordsCompanion entry) =>
      into(calculationRecords).insert(entry);

  Future<List<CalculationRecord>> getRecentCalculations({int limit = 10}) =>
      (select(calculationRecords)
            ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
            ..limit(limit))
          .get();

  // ─── Product Preset DAOs ───────────────────────────────────────

  Future<ProductPreset?> getPresetByVariant(int variantId) =>
      (select(productPresets)
            ..where((p) => p.productVariantId.equals(variantId)))
          .getSingleOrNull();

  Future<int> insertPreset(ProductPresetsCompanion entry) =>
      into(productPresets).insert(entry);

  // ─── Product Assembly DAOs ─────────────────────────────────────

  Future<List<ProductAssembly>> getAssembliesByVariant(int variantId) =>
      (select(productAssemblies)
            ..where((a) => a.productVariantId.equals(variantId)))
          .get();

  Future<int> insertAssembly(ProductAssembliesCompanion entry) =>
      into(productAssemblies).insert(entry);

  // ─── System Logs DAOs ──────────────────────────────────────────

  Future<int> insertSystemLog(SystemLogsCompanion entry) =>
      into(systemLogs).insert(entry);

  Future<List<SystemLog>> getUnsyncedLogs() =>
      (select(systemLogs)..where((l) => l.synced.equals(false))).get();

  Future<void> markLogsAsSynced(List<int> ids) =>
      (update(systemLogs)..where((l) => l.id.isIn(ids)))
          .write(const SystemLogsCompanion(synced: Value(true)));

  Stream<List<SystemLog>> watchSystemLogs({int limit = 100}) =>
      (select(systemLogs)
            ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
            ..limit(limit))
          .watch();

  // ─── Tiered Pricing DAOs ───────────────────────────────────────

  Future<CategoryPrice?> getCategoryPrice(String category) =>
      (select(categoryPrices)..where((c) => c.category.equals(category)))
          .getSingleOrNull();

  Stream<CategoryPrice?> watchCategoryPrice(String category) =>
      (select(categoryPrices)..where((c) => c.category.equals(category)))
          .watchSingleOrNull();

  Future<int> insertOrUpdateCategoryPrice(CategoryPricesCompanion entry) =>
      into(categoryPrices).insertOnConflictUpdate(entry);

  Future<List<PricingRule>> getRulesByCategory(String category) =>
      (select(pricingRules)..where((r) => r.category.equals(category))).get();

  Stream<List<PricingRule>> watchRulesByCategory(String category) =>
      (select(pricingRules)..where((r) => r.category.equals(category))).watch();
      
  Future<int> insertPricingRule(PricingRulesCompanion entry) =>
      into(pricingRules).insert(entry);
      
  Future<int> deletePricingRule(int id) =>
      (delete(pricingRules)..where((r) => r.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
