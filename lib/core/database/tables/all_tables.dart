import 'package:drift/drift.dart';

/// Customers table — stores client information.
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get alternatePhone => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Projects table — the root entity per PRD section 7.
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get name => text().withLength(min: 1, max: 300)();
  TextColumn get projectType => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('inquiry'))();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Products table — main product catalog.
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 300)();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get brand => text().nullable()();
  IntColumn get defaultSupplierId => integer().nullable()();
  TextColumn get code => text().nullable()();
  TextColumn get material => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get finish => text().nullable()();
  TextColumn get unitType => text()();
  TextColumn get installationMethod => text().nullable()();
  TextColumn get suitableAreas => text().nullable()();
  TextColumn get moistureResistance => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get image => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Product variants — sizes, colors, dimensions for a product.
class ProductVariants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get variantName => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get dimensions => text().nullable()();
  RealColumn get pieceLength => real().nullable()();
  RealColumn get pieceWidth => real().nullable()();
  RealColumn get thickness => real().nullable()();
  RealColumn get effectiveCoverageWidth => real().nullable()();
  RealColumn get effectiveCoverageArea => real().nullable()();
  RealColumn get defaultWastePercent => real().withDefault(const Constant(0.10))();
  RealColumn get costOverride => real().nullable()();
  RealColumn get priceOverride => real().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Product presets — auto-fill settings when selecting a product.
class ProductPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productVariantId => integer().references(ProductVariants, #id)();
  TextColumn get calculationMode => text()();
  TextColumn get defaultOrientation => text().nullable()();
  RealColumn get defaultWastePercent => real().nullable()();
  TextColumn get defaultAccessoriesRule => text().nullable()();
  TextColumn get defaultInstallationRule => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Product assemblies — accessories linked to main products.
class ProductAssemblies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productVariantId => integer().references(ProductVariants, #id)();
  IntColumn get accessoryProductId => integer()();
  TextColumn get quantityRuleType => text()();
  RealColumn get quantityRuleValue => real().withDefault(const Constant(1.0))();
  BoolColumn get optional => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Suppliers table.
class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Supplier product pricing — prices per supplier per variant.
class SupplierProductPricings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierId => integer().references(Suppliers, #id)();
  IntColumn get productVariantId => integer().references(ProductVariants, #id)();
  TextColumn get supplierCode => text().nullable()();
  RealColumn get listPrice => real()();
  TextColumn get discountType => text().nullable()();
  RealColumn get discountValue => real().nullable()();
  RealColumn get netPrice => real().nullable()();
  RealColumn get minOrderQty => real().nullable()();
  IntColumn get leadTimeDays => integer().nullable()();
  BoolColumn get isPreferred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get effectiveFrom => dateTime().nullable()();
  DateTimeColumn get effectiveTo => dateTime().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Price history — audit trail for price changes.
class PriceHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierProductPricingId =>
      integer().references(SupplierProductPricings, #id)();
  RealColumn get oldListPrice => real()();
  RealColumn get newListPrice => real()();
  RealColumn get oldDiscount => real().nullable()();
  RealColumn get newDiscount => real().nullable()();
  TextColumn get changedBy => text().nullable()();
  DateTimeColumn get changedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reason => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Quotes table.
class Quotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  RealColumn get totalBeforeDiscount => real().withDefault(const Constant(0))();
  RealColumn get totalDiscount => real().withDefault(const Constant(0))();
  RealColumn get installationCost => real().withDefault(const Constant(0))();
  RealColumn get accessoriesCost => real().withDefault(const Constant(0))();
  RealColumn get finalTotal => real().withDefault(const Constant(0))();
  DateTimeColumn get validUntil => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Quote items — individual line items in a quote.
class QuoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get quoteId => integer().references(Quotes, #id)();
  IntColumn get productVariantId =>
      integer().nullable().references(ProductVariants, #id)();
  IntColumn get calculationId => integer().nullable()();
  RealColumn get qty => real()();
  TextColumn get unit => text()();
  RealColumn get unitPrice => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get finalUnitPrice => real()();
  RealColumn get accessoriesTotal => real().withDefault(const Constant(0))();
  RealColumn get installationTotal => real().withDefault(const Constant(0))();
  RealColumn get finalLineTotal => real()();
  RealColumn get wastePercent => real().withDefault(const Constant(0))();
  TextColumn get productName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Calculation records — saved calculation history.
class CalculationRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get measurementSessionId => integer().nullable()();
  IntColumn get productVariantId =>
      integer().nullable().references(ProductVariants, #id)();
  TextColumn get calculationMode => text()();
  TextColumn get inputPayload => text()();
  TextColumn get outputPayload => text()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Measurement sessions.
class MeasurementSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get technicianId => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('in_progress'))();
  DateTimeColumn get sessionDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get photos => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Rooms within a measurement session.
class Rooms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(MeasurementSessions, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get shapeType => text().nullable()();
  RealColumn get ceilingHeight => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Walls within a room.
class Walls extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roomId => integer().references(Rooms, #id)();
  TextColumn get label => text().nullable()();
  RealColumn get length => real()();
  RealColumn get height => real()();
  TextColumn get orientation => text().nullable()();
  BoolColumn get isExterior =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Openings within walls (doors, windows, columns, recesses).
class Openings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wallId => integer().references(Walls, #id)();
  TextColumn get type => text()();
  RealColumn get width => real()();
  RealColumn get height => real()();
  RealColumn get fromFloor => real().nullable()();
  BoolColumn get deductFromCalc =>
      boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
}

/// Basic inventory tracking.
class InventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productVariantId =>
      integer().references(ProductVariants, #id)();
  IntColumn get supplierId => integer().nullable().references(Suppliers, #id)();
  TextColumn get unitType => text()();
  RealColumn get availableQty => real().withDefault(const Constant(0))();
  RealColumn get reservedQty => real().withDefault(const Constant(0))();
  RealColumn get reorderPoint => real().nullable()();
  TextColumn get remoteId => text().nullable().unique()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// System logs — for smart bug tracking and data integrity.
class SystemLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text()(); // info, warning, error, data_conflict
  TextColumn get message => text()();
  TextColumn get error => text().nullable()();
  TextColumn get stackTrace => text().nullable()();
  TextColumn get context => text().nullable()(); // JSON string with user_id, screen, etc.
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tiered Pricing: Category base prices
class CategoryPrices extends Table {
  TextColumn get category => text()();
  RealColumn get baseCost => real().withDefault(const Constant(0))();
  RealColumn get basePrice => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {category};
}

/// Tiered Pricing: Rule-based modifiers (e.g., Resin + 100 EGP)
class PricingRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().references(CategoryPrices, #category)();
  TextColumn get conditionAttribute => text()(); // e.g., 'material'
  TextColumn get conditionValue => text()(); // e.g., 'ريزين'
  RealColumn get modifierAmount => real()();
  TextColumn get modifierType => text().withDefault(const Constant('fixed_addition'))();
}

// ─── ERP: Purchasing & Inventory Ledger ────────────────────────

/// Purchase Orders (فواتير المشتريات)
class PurchaseOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierId => integer().references(Suppliers, #id)();
  TextColumn get invoiceNumber => text().nullable()(); // Supplier's invoice number
  RealColumn get totalAmount => real().withDefault(const Constant(0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, received, cancelled
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Items in a Purchase Order
class PurchaseOrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseOrderId => integer().references(PurchaseOrders, #id)();
  IntColumn get productVariantId => integer().references(ProductVariants, #id)();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real()();
  RealColumn get totalCost => real()();
}

/// Stock Movements Ledger (حركة المخزون)
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productVariantId => integer().references(ProductVariants, #id)();
  TextColumn get movementType => text()(); // purchase_receive, sales_dispatch, sales_return, wastage, adjustment
  RealColumn get quantityChange => real()(); // Positive for IN, Negative for OUT
  IntColumn get referenceId => integer().nullable()(); // ID of the PO, Invoice, or Return
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── ERP: Cash Flow & Expenses Ledger ──────────────────────────

/// Cash Transactions (دفتر الخزينة)
class CashTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'in' or 'out'
  TextColumn get category => text()(); // 'customer_payment', 'supplier_payment', 'expense', 'refund', 'adjustment'
  IntColumn get referenceId => integer().nullable()(); // ID of Quote, PO, or Expense
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Expense Categories (تصنيفات المصروفات)
class ExpenseCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()(); // e.g. 'Rent', 'Electricity', 'Salaries', 'Transport'
}

/// Daily Expenses (المصروفات اليومية)
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(ExpenseCategories, #id)();
  RealColumn get amount => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get recordedBy => text().nullable()(); // user_id or name
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Technicians & Installations (ERP) ─────────────────────────

@DataClassName('Technician')
class Technicians extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  RealColumn get defaultCommission => real().withDefault(const Constant(0.0))(); // Default percentage or fixed amount
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('InstallationJob')
class InstallationJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceId => text().nullable()(); // UUID from localInvoices
  IntColumn get technicianId => integer().references(Technicians, #id)();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, in_progress, completed, cancelled
  RealColumn get agreedFee => real().withDefault(const Constant(0.0))();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('TechnicianTransaction')
class TechnicianLedger extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get technicianId => integer().references(Technicians, #id)();
  IntColumn get jobId => integer().nullable().references(InstallationJobs, #id)();
  TextColumn get type => text()(); // 'fee_earned' (credit), 'payment_given' (debit)
  RealColumn get amount => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Daily Shift Closing (ERP) ─────────────────────────────

@DataClassName('ShiftClosing')
class ShiftClosings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get closedBy => text()(); // Name of the seller
  RealColumn get expectedCash => real()(); // What the system calculated
  RealColumn get actualCash => real()(); // What the seller counted
  RealColumn get difference => real()(); // Actual - Expected (Negative means shortage)
  TextColumn get notes => text().nullable()();
  DateTimeColumn get closedAt => dateTime().withDefault(currentDateAndTime)();
}
