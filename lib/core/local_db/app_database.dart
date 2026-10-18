import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

// ─── Shared Columns ──────────────────────────────────────────────────────────
mixin UuidPrimaryKey on Table {
  /// UUID primary key (matches Supabase id)
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  @override
  Set<Column> get primaryKey => {id};
}

mixin Syncable on Table {
  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Tables ──────────────────────────────────────────────────────────────────

class LocalProjects extends Table with UuidPrimaryKey, Syncable {
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  RealColumn get netValue => real().withDefault(const Constant(0.0))();
  RealColumn get taxPercent => real().withDefault(const Constant(0.0))();
  RealColumn get totalValue => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  TextColumn get address => text().nullable()();
}

class LocalMeasurementSessions extends Table with UuidPrimaryKey, Syncable {
  TextColumn get projectId => text()();
  TextColumn get technicianId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  TextColumn get notes => text().nullable()();
}

class LocalRooms extends Table with UuidPrimaryKey, Syncable {
  TextColumn get sessionId => text()();
  TextColumn get name => text()();
  TextColumn get type => text().nullable()();
  RealColumn get length => real().withDefault(const Constant(0.0))();
  RealColumn get width => real().withDefault(const Constant(0.0))();
  RealColumn get height => real().withDefault(const Constant(0.0))();
  RealColumn get floorArea => real().withDefault(const Constant(0.0))();
  RealColumn get perimeter => real().withDefault(const Constant(0.0))();
}

class LocalWalls extends Table with UuidPrimaryKey, Syncable {
  TextColumn get roomId => text()();
  TextColumn get name => text()();
  RealColumn get length => real().withDefault(const Constant(0.0))();
  RealColumn get height => real().withDefault(const Constant(0.0))();
  RealColumn get grossArea => real().withDefault(const Constant(0.0))();
  RealColumn get netArea => real().withDefault(const Constant(0.0))();
  TextColumn get materialType => text().nullable()();
}

class LocalWallOpenings extends Table with UuidPrimaryKey, Syncable {
  TextColumn get wallId => text()();
  TextColumn get type => text()(); // 'door', 'window', 'column', 'custom'
  TextColumn get name => text().nullable()();
  RealColumn get width => real().withDefault(const Constant(0.0))();
  RealColumn get height => real().withDefault(const Constant(0.0))();
  RealColumn get area => real().withDefault(const Constant(0.0))();
  BoolColumn get deductFromWall => boolean().withDefault(const Constant(true))();
}

// ─── New Offline Tables ──────────────────────────────────────────────────────

class LocalProducts extends Table with UuidPrimaryKey, Syncable {
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get unitType => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get brand => text().nullable()();
  TextColumn get material => text().nullable()();
  TextColumn get moistureResistance => text().nullable()();
  TextColumn get installationMethod => text().nullable()();
  TextColumn get defaultSupplierId => text().nullable()();
}

class LocalProductVariants extends Table with UuidPrimaryKey, Syncable {
  TextColumn get productId => text()();
  TextColumn get variantName => text()();
  TextColumn get color => text().nullable()();
  TextColumn get dimensions => text().nullable()();
  RealColumn get pieceLength => real().nullable()();
  RealColumn get pieceWidth => real().nullable()();
  RealColumn get thickness => real().nullable()();
  RealColumn get effectiveCoverageWidth => real().nullable()();
  RealColumn get defaultWastePercent => real().nullable()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get minSellingPrice => real().nullable()();
  RealColumn get costPriceOverride => real().nullable()();
  RealColumn get sellingPriceOverride => real().nullable()();
  RealColumn get technicianPriceOverride => real().nullable()();
}

class LocalPricingRules extends Table with UuidPrimaryKey, Syncable {
  TextColumn get category => text()(); // e.g. 'بديل خشب', 'بديل رخام', 'شيبورد', 'بانوهات'
  TextColumn get subcategory => text().nullable()();
  TextColumn get material => text().nullable()(); // e.g. 'PVC', 'WPC', 'PS'
  TextColumn get variantType => text().nullable()(); // e.g. 'عادي UV', 'ريزن', 'أوبن بوك'
  TextColumn get dimensionSpec => text().nullable()(); // e.g. '17 سم', '20 سم', '280×122'
  RealColumn get costPrice => real().withDefault(const Constant(0.0))(); // سعر الشراء / التكلفة
  RealColumn get sellingPrice => real().withDefault(const Constant(0.0))(); // سعر البيع قطاعي
  RealColumn get technicianPrice => real().withDefault(const Constant(0.0))(); // سعر الفنيين / المهندسين
  RealColumn get minSellingPrice => real().withDefault(const Constant(0.0))(); // الحد الأدنى للبيع
  TextColumn get notes => text().nullable()();
}

class LocalSupplierPricings extends Table with UuidPrimaryKey, Syncable {
  TextColumn get productVariantId => text()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get supplierCode => text().nullable()();
  RealColumn get listPrice => real().withDefault(const Constant(0.0))();
  RealColumn get netPrice => real().withDefault(const Constant(0.0))();
  RealColumn get discountValue => real().withDefault(const Constant(0.0))();
  BoolColumn get isPreferred => boolean().withDefault(const Constant(false))();
}

class LocalInventoryItems extends Table with UuidPrimaryKey, Syncable {
  TextColumn get productVariantId => text()();
  RealColumn get availableQty => real().withDefault(const Constant(0.0))();
  RealColumn get reservedQty => real().withDefault(const Constant(0.0))();
  RealColumn get damagedQty => real().withDefault(const Constant(0.0))();
  RealColumn get reorderPoint => real().withDefault(const Constant(0.0))();
}

class LocalInventoryMovements extends Table with UuidPrimaryKey, Syncable {
  TextColumn get inventoryItemId => text()();
  TextColumn get movementType => text()();
  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  TextColumn get referenceId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().nullable()();
}

class LocalQuotes extends Table with UuidPrimaryKey, Syncable {
  TextColumn get quoteNumber => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get validUntil => dateTime().nullable()();
}

class LocalQuoteItems extends Table with UuidPrimaryKey, Syncable {
  TextColumn get quoteId => text()();
  TextColumn get productVariantId => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get totalPrice => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
}

class LocalInvoices extends Table with UuidPrimaryKey, Syncable {
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get invoiceType => text().withDefault(const Constant('sale'))();
  TextColumn get originalInvoiceId => text().nullable()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  /// تاريخ اعتماد الفاتورة (يُملأ عند confirmInvoice)
  DateTimeColumn get confirmedAt => dateTime().nullable()();
}

class LocalInvoiceItems extends Table with UuidPrimaryKey, Syncable {
  TextColumn get invoiceId => text()();
  TextColumn get productVariantId => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get totalPrice => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
}

class LocalCustomers extends Table with UuidPrimaryKey, Syncable {
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class LocalProductPresets extends Table with UuidPrimaryKey, Syncable {
  TextColumn get productVariantId => text()();
  TextColumn get name => text()();
  TextColumn get presetData => text().nullable()();
}

class LocalProductAssemblies extends Table with UuidPrimaryKey, Syncable {
  TextColumn get productVariantId => text()();
  TextColumn get accessoryProductId => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
}

class LocalProfiles extends Table with UuidPrimaryKey, Syncable {
  TextColumn get fullName => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('seller'))();
  TextColumn get phone => text().nullable()();
  TextColumn get shopName => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class LocalPayments extends Table with UuidPrimaryKey, Syncable {
  TextColumn get invoiceId => text()();
  TextColumn get customerId => text().nullable()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().nullable()();
}

// ─── Monitoring & Logging ──────────────────────────────────────────────────────

class LocalSystemLogs extends Table with UuidPrimaryKey, Syncable {
  TextColumn get level => text()(); // info, warning, error, data_conflict
  TextColumn get message => text()();
  TextColumn get error => text().nullable()();
  TextColumn get stackTrace => text().nullable()();
  TextColumn get context => text().nullable()(); // JSON string
}

// ─── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  LocalProjects,
  LocalMeasurementSessions,
  LocalRooms,
  LocalWalls,
  LocalWallOpenings,
  LocalProducts,
  LocalProductVariants,
  LocalSupplierPricings,
  LocalInventoryItems,
  LocalInventoryMovements,
  LocalQuotes,
  LocalQuoteItems,
  LocalInvoices,
  LocalInvoiceItems,
  LocalCustomers,
  LocalProductPresets,
  LocalProductAssemblies,
  LocalProfiles,
  LocalPayments,
  LocalSystemLogs,
  LocalPricingRules,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({String? shopId}) : super(_openConnection(shopId));

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(localPayments);
          }
          if (from < 3) {
            // Add isDeleted column to all tables that use Syncable mixin
            for (final table in allTables) {
              final isDeletedCol = table.columnsByName['is_deleted'];
              if (isDeletedCol != null) {
                await m.addColumn(table, isDeletedCol);
              }
            }
          }
          if (from < 4) {
            await m.addColumn(localInvoices, localInvoices.invoiceType);
            await m.addColumn(localInvoices, localInvoices.originalInvoiceId);
          }
          if (from < 5) {
            await m.addColumn(localSupplierPricings, localSupplierPricings.supplierCode);
          }
          if (from < 6) {
            await m.addColumn(localProjects, localProjects.address);
          }
          if (from < 7) {
            await m.addColumn(localProductVariants, localProductVariants.imageUrl);
          }
          if (from < 8) {
            await m.addColumn(localProductVariants, localProductVariants.minSellingPrice);
          }
          if (from < 9) {
            await m.addColumn(localInvoices, localInvoices.confirmedAt);
          }
          if (from < 10) {
            // Create table if not already there
            try {
              await m.createTable(localPricingRules);
            } catch (_) {}
            // Use raw SQL to safely add columns (avoids duplicate-column error on existing DBs)
            for (final sql in [
              'ALTER TABLE "local_product_variants" ADD COLUMN "cost_price_override" REAL',
              'ALTER TABLE "local_product_variants" ADD COLUMN "selling_price_override" REAL',
              'ALTER TABLE "local_product_variants" ADD COLUMN "technician_price_override" REAL',
            ]) {
              try {
                await customStatement(sql);
              } catch (_) {
                // Column already exists – safe to ignore
              }
            }
          }
          if (from < 11) {
            // Version 11: placeholder for future migrations
            // Ensures DBs stuck on version 9 or below go through migration 10 cleanly
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('''
            CREATE TABLE IF NOT EXISTS "local_system_logs" (
              "id" TEXT NOT NULL PRIMARY KEY,
              "level" TEXT NOT NULL,
              "message" TEXT NOT NULL,
              "error" TEXT,
              "stack_trace" TEXT,
              "context" TEXT,
              "sync_status" TEXT NOT NULL DEFAULT 'pending_insert',
              "is_deleted" INTEGER NOT NULL DEFAULT 0,
              "created_at" INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              "updated_at" INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
        },
      );

  // Sync operations
  Future<List<LocalMeasurementSession>> getPendingSessions() {
    return (select(localMeasurementSessions)
          ..where((t) => t.syncStatus.isNotValue('synced')))
        .get();
  }

  Future<void> markAsSynced(String tableName, String localId) async {
    // We will update sync_status to 'synced' based on the table name.
  }

  // ─── System Logs DAOs ──────────────────────────────────────────

  Future<int> insertSystemLog(LocalSystemLogsCompanion entry) =>
      into(localSystemLogs).insert(entry);

  Future<List<LocalSystemLog>> getUnsyncedLogs() =>
      (select(localSystemLogs)..where((l) => l.syncStatus.isNotValue('synced'))).get();

  Future<void> markLogsAsSynced(List<String> ids) =>
      (update(localSystemLogs)..where((l) => l.id.isIn(ids)))
          .write(const LocalSystemLogsCompanion(syncStatus: Value('synced')));

  Stream<List<LocalSystemLog>> watchSystemLogs({int limit = 100}) =>
      (select(localSystemLogs)
            ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
            ..limit(limit))
          .watch();

  /// Deletes all data from all local tables. Useful on logout if we want to wipe it.
  Future<void> clearAllData() async {
    for (final table in allTables) {
      try {
        await delete(table).go();
      } catch (e) {
        debugPrint('Error clearing table ${table.actualTableName}: $e');
      }
    }
  }
}

LazyDatabase _openConnection(String? shopId) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbName = shopId != null && shopId.isNotEmpty 
        ? 'stream_pay_$shopId.sqlite' 
        : 'stream_pay_db.sqlite';
    final file = File(p.join(dbFolder.path, dbName));
    return NativeDatabase.createInBackground(file);
  });
}
