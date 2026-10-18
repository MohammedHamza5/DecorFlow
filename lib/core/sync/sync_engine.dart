import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SyncEngine handles bidirectional synchronization between local Drift SQLite
/// and remote Supabase database.
class SyncEngine {
  final AppDatabase db;
  final SupabaseClient supabase;
  final Ref? ref;
  final String? shopIdOverride;
  
  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier(false);
  bool get _isSyncing => isSyncingNotifier.value;
  set _isSyncing(bool val) => isSyncingNotifier.value = val;
  StreamSubscription? _connectivitySubscription;

  SyncEngine(this.db, this.supabase, this.ref, {this.shopIdOverride}) {
    // Listen to network changes to trigger sync
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        sync();
      }
    });

    // Listen to realtime changes from Supabase
    _setupRealtime();

    // Trigger an initial sync on startup
    Future.microtask(() => sync());
  }

  String? get _currentShopId {
    if (shopIdOverride != null) return shopIdOverride;
    try {
      return ref?.read(currentShopIdProvider);
    } catch (_) {
      return null;
    }
  }

  Timer? _debounceTimer;

  void _setupRealtime() {
    supabase.channel('public:*').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      callback: (payload) {
        print('Realtime Event received: ${payload.table} - ${payload.eventType}');
        // Debounce to avoid freezing the app on massive updates
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 2), () {
          _pullChanges();
        });
      },
    ).subscribe();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _debounceTimer?.cancel();
  }

  /// Manually trigger a synchronization
  Future<void> sync() async {
    if (_isSyncing) return;

    final shopId = _currentShopId;
    
    final session = supabase.auth.currentSession;
    if (session == null || session.isExpired) {
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return;
    }

    _isSyncing = true;
    try {
      // Only push user data if shop exists
      if (shopId != null) {
        await _pushChanges();
      }
      // Always pull (includes global catalog products for new users)
      await _pullChanges();
      print('SyncEngine: Synchronization completed successfully.');
    } catch (e, st) {
      print('SyncEngine: Error during sync - $e\n$st');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushChanges() async {
    // We collect all pending items per table and push them using batch upsert.
    final shopId = _currentShopId;
    if (shopId == null) return;
    
    try {
// 1. Projects
    final pendingProjects = await (db.select(db.localProjects)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingProjects.isNotEmpty) {
      final dataList = pendingProjects.map((p) => {
        'id': p.id,
        'owner_id': supabase.auth.currentUser?.id,
        'shop_id': shopId,
        'name': p.title,
        'project_type': p.description,
        'customer_id': p.customerId,
        'status': p.status,
        'notes': p.notes,
        'address': p.address,
        'is_deleted': p.isDeleted,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('projects', dataList, pendingProjects.map((e) => e.id).toList(), db.localProjects);
    }

    
    } catch (e) {
      print('SyncEngine: Error pushing table projects - $e');
    }

    try {
// 2. Sessions
    final pendingSessions = await (db.select(db.localMeasurementSessions)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingSessions.isNotEmpty) {
      final dataList = pendingSessions.map((s) => {
        'id': s.id,
        'project_id': s.projectId,
        'technician_id': s.technicianId,
        'status': s.status,
        'notes': s.notes,
        'is_deleted': s.isDeleted,
        'created_at': s.createdAt.toIso8601String(),
        'updated_at': s.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('measurement_sessions', dataList, pendingSessions.map((e) => e.id).toList(), db.localMeasurementSessions);
    }

    
    } catch (e) {
      print('SyncEngine: Error pushing table sessions - $e');
    }

    try {
// 3. Rooms
    final pendingRooms = await (db.select(db.localRooms)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingRooms.isNotEmpty) {
      final dataList = pendingRooms.map((r) => {
        'id': r.id,
        'session_id': r.sessionId,
        'name': r.name,
        'shape_type': r.type,
        'ceiling_height': r.height,
        'is_deleted': r.isDeleted,
        'updated_at': r.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('rooms', dataList, pendingRooms.map((e) => e.id).toList(), db.localRooms);
    }

    
    } catch (e) {
      print('SyncEngine: Error pushing table rooms - $e');
    }

    try {
// 4. Walls
    final pendingWalls = await (db.select(db.localWalls)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingWalls.isNotEmpty) {
      final dataList = pendingWalls.map((w) => {
        'id': w.id,
        'room_id': w.roomId,
        'label': w.name,
        'length': w.length,
        'height': w.height,
        'notes': w.materialType,
        'is_deleted': w.isDeleted,
        'updated_at': w.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('walls', dataList, pendingWalls.map((e) => e.id).toList(), db.localWalls);
    }

    
    } catch (e) {
      print('SyncEngine: Error pushing table walls - $e');
    }

    try {
// 5. Openings
    final pendingOpenings = await (db.select(db.localWallOpenings)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingOpenings.isNotEmpty) {
      final dataList = pendingOpenings.map((o) => {
        'id': o.id,
        'wall_id': o.wallId,
        'type': o.type,
        'label': o.name,
        'width': o.width,
        'height': o.height,
        'deduct': o.deductFromWall,
        'is_deleted': o.isDeleted,
        'created_at': o.createdAt.toIso8601String(),
        'updated_at': o.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('wall_openings', dataList, pendingOpenings.map((e) => e.id).toList(), db.localWallOpenings);
    }

    
    } catch (e) {
      print('SyncEngine: Error pulling table - $e');
    }

    try {
// 6. Products
    final pendingProducts = await (db.select(db.localProducts)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingProducts.isNotEmpty) {
      final dataList = pendingProducts.map((p) => {
        'id': p.id,
        'owner_id': supabase.auth.currentUser?.id,
        'shop_id': shopId,
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
        'is_deleted': p.isDeleted,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('products', dataList, pendingProducts.map((e) => e.id).toList(), db.localProducts);
    }

    
    } catch (e) {
      print('SyncEngine: Error pulling table - $e');
    }

    try {
// 7. Product Variants
    final pendingVariants = await (db.select(db.localProductVariants)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingVariants.isNotEmpty) {
      final dataList = pendingVariants.map((v) => {
        'id': v.id,
        'product_id': v.productId,
        'variant_name': v.variantName,
        'color': v.color,
        'dimensions': v.dimensions,
        'piece_length': v.pieceLength,
        'piece_width': v.pieceWidth,
        'thickness': v.thickness,
        'effective_coverage_width': v.effectiveCoverageWidth,
        'default_waste_percent': v.defaultWastePercent ?? 0.10,
        'min_selling_price': v.minSellingPrice,
        'is_deleted': v.isDeleted,
        'created_at': v.createdAt.toIso8601String(),
        'updated_at': v.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('product_variants', dataList, pendingVariants.map((e) => e.id).toList(), db.localProductVariants);
    }

    
    } catch (e) {
      print('SyncEngine: Error pulling table - $e');
    }

    try {
// 8. Customers
    final pendingCustomers = await (db.select(db.localCustomers)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingCustomers.isNotEmpty) {
      final dataList = pendingCustomers.map((c) => {
        'id': c.id,
        'owner_id': supabase.auth.currentUser?.id,
        'shop_id': shopId,
        'name': c.name,
        'phone': c.phone,
        'location': c.address,
        'customer_type': c.type,
        'notes': c.notes,
        'is_deleted': c.isDeleted,
        'created_at': c.createdAt.toIso8601String(),
        'updated_at': c.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('customers', dataList, pendingCustomers.map((e) => e.id).toList(), db.localCustomers);
    }
    } catch (e) {
      print('SyncEngine: Error pushing customers - $e');
    }

    try {
// 9. Supplier Product Pricings
    final pendingPricings = await (db.select(db.localSupplierPricings)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingPricings.isNotEmpty) {
      final dataList = pendingPricings.map((p) => {
        'id': p.id,
        'product_variant_id': p.productVariantId,
        'supplier_id': p.supplierId,
        'supplier_code': p.supplierCode,
        'list_price': p.listPrice,
        'net_price': p.netPrice,
        'discount_value': p.discountValue,
        'is_preferred': p.isPreferred,
        'is_deleted': p.isDeleted,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('supplier_product_pricings', dataList, pendingPricings.map((e) => e.id).toList(), db.localSupplierPricings);
    }
    } catch (e) {
      print('SyncEngine: Error pushing supplier_product_pricings - $e');
    }

    try {
// 10. Inventory Items
    final pendingInventory = await (db.select(db.localInventoryItems)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingInventory.isNotEmpty) {
      final dataList = pendingInventory.map((i) => {
        'id': i.id,
        'owner_id': supabase.auth.currentUser?.id,
        'shop_id': shopId,
        'product_variant_id': i.productVariantId,
        // Omit available_qty and damaged_qty from push.
        // The server-side trigger recalculates these fields automatically when movements are inserted.
        'reserved_qty': i.reservedQty,
        'reorder_point': i.reorderPoint,
        'is_deleted': i.isDeleted,
        'updated_at': i.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('inventory_items', dataList, pendingInventory.map((e) => e.id).toList(), db.localInventoryItems);
    }
    } catch (e) {
      print('SyncEngine: Error pushing inventory_items - $e');
    }

    try {
// 11. Inventory Movements
    final pendingMovements = await (db.select(db.localInventoryMovements)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingMovements.isNotEmpty) {
      final dataList = pendingMovements.map((m) => {
        'id': m.id,
        'inventory_item_id': m.inventoryItemId,
        'movement_type': m.movementType,
        'quantity': m.quantity,
        'balance_after': 0.0,
        'reference_id': m.referenceId,
        'notes': m.notes,
        'created_by': m.createdBy == 'system' ? null : m.createdBy,
        'is_deleted': m.isDeleted,
        'created_at': m.createdAt.toIso8601String(),
        'updated_at': m.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('inventory_movements', dataList, pendingMovements.map((e) => e.id).toList(), db.localInventoryMovements);
    }
    } catch (e) {
      print('SyncEngine: Error pushing inventory_movements - $e');
    }

    try {
// 12. Quotes
    final pendingQuotes = await (db.select(db.localQuotes)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingQuotes.isNotEmpty) {
      final dataList = pendingQuotes.map((q) => {
        'id': q.id,
        'owner_id': supabase.auth.currentUser?.id,
        'shop_id': shopId,
        'quote_number': q.quoteNumber,
        'customer_id': q.customerId,
        'status': q.status,
        'total_amount': q.totalAmount,
        'tax_amount': q.taxAmount,
        'discount_amount': q.discountAmount,
        'notes': q.notes,
        'valid_until': q.validUntil?.toIso8601String(),
        'is_deleted': q.isDeleted,
        'created_at': q.createdAt.toIso8601String(),
        'updated_at': q.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('quotes', dataList, pendingQuotes.map((e) => e.id).toList(), db.localQuotes);
    }
    } catch (e) {
      print('SyncEngine: Error pushing quotes - $e');
    }

    try {
// 13. Quote Items
    final pendingQuoteItems = await (db.select(db.localQuoteItems)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingQuoteItems.isNotEmpty) {
      final dataList = pendingQuoteItems.map((qi) => {
        'id': qi.id,
        'quote_id': qi.quoteId,
        'product_variant_id': qi.productVariantId,
        'qty': qi.quantity,
        'quantity': qi.quantity,
        'unit_price': qi.unitPrice,
        'final_line_total': qi.totalPrice,
        'notes': qi.notes,
        'is_deleted': qi.isDeleted,
        'created_at': qi.createdAt.toIso8601String(),
        'updated_at': qi.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('quote_items', dataList, pendingQuoteItems.map((e) => e.id).toList(), db.localQuoteItems);
    }
    } catch (e) {
      print('SyncEngine: Error pushing quote_items - $e');
    }

    try {
// 14. Invoices
    final pendingInvoices = await (db.select(db.localInvoices)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingInvoices.isNotEmpty) {
      final dataList = pendingInvoices.map((inv) => {
        'id': inv.id,
        'shop_id': shopId,
        'invoice_number': inv.invoiceNumber,
        'customer_id': inv.customerId,
        'status': inv.status,
        'invoice_type': inv.invoiceType,
        'original_invoice_id': inv.originalInvoiceId,
        'total_amount': inv.totalAmount,
        'paid_amount': inv.amountPaid,
        'tax_amount': inv.taxAmount,
        'discount_amount': inv.discountAmount,
        'notes': inv.notes,
        'due_date': inv.dueDate?.toIso8601String(),
        'confirmed_at': inv.confirmedAt?.toIso8601String(),
        'is_deleted': inv.isDeleted,
        'created_at': inv.createdAt.toIso8601String(),
        'updated_at': inv.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('invoices', dataList, pendingInvoices.map((e) => e.id).toList(), db.localInvoices);
    }
    } catch (e) {
      print('SyncEngine: Error pushing invoices - $e');
    }

    try {
// 15. Invoice Items
    final pendingInvoiceItems = await (db.select(db.localInvoiceItems)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingInvoiceItems.isNotEmpty) {
      final dataList = pendingInvoiceItems.map((ii) => {
        'id': ii.id,
        'invoice_id': ii.invoiceId,
        'product_variant_id': ii.productVariantId,
        'quantity': ii.quantity,
        'unit_price': ii.unitPrice,
        'final_line_total': ii.totalPrice,
        'notes': ii.notes,
        'is_deleted': ii.isDeleted,
        'updated_at': ii.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('invoice_items', dataList, pendingInvoiceItems.map((e) => e.id).toList(), db.localInvoiceItems);
    }
    } catch (e) {
      print('SyncEngine: Error pushing invoice_items - $e');
    }

    try {
// 16. Payments
    final pendingPayments = await (db.select(db.localPayments)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    if (pendingPayments.isNotEmpty) {
      final dataList = pendingPayments.map((p) => {
        'id': p.id,
        'shop_id': shopId,
        'invoice_id': p.invoiceId,
        'customer_id': p.customerId,
        'amount': p.amount,
        'payment_method': p.paymentMethod,
        'reference_number': p.referenceNumber,
        'notes': p.notes,
        'created_by': p.createdBy,
        'is_deleted': p.isDeleted,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      }).toList();
      await _batchUpsert('payments', dataList, pendingPayments.map((e) => e.id).toList(), db.localPayments);
    }
    } catch (e) {
      print('SyncEngine: Error pushing payments - $e');
    }
  }

  Future<void> _batchUpsert(String remoteTable, List<Map<String, dynamic>> dataList, List<String> localIds, dynamic localTableInfo) async {
    try {
      // Bulk Upsert to Supabase
      await supabase.from(remoteTable).upsert(dataList);
      
      // Mark as synced locally
      final localTableName = (localTableInfo as TableInfo).actualTableName;
      
      // Update local status in batch
      for (final localId in localIds) {
        await db.customUpdate(
          'UPDATE $localTableName SET sync_status = ? WHERE id = ?',
          variables: [Variable('synced'), Variable(localId)],
          updates: {localTableInfo},
        );
      }
    } catch (e) {
      print('SyncEngine: Error syncing $remoteTable - $e');
    }
  }

  Future<void> _pullChanges() async {
    final shopId = _currentShopId; // may be null for new users without a shop

    final prefs = await SharedPreferences.getInstance();
    final lastSyncKey = 'last_sync_time';
    final String? lastSyncStr = prefs.getString(lastSyncKey);
    DateTime lastSyncTime = lastSyncStr != null ? DateTime.parse(lastSyncStr) : DateTime.fromMillisecondsSinceEpoch(0);
    
    // If local DB has fewer than 100 catalog products, force a full pull by resetting sync time.
    final localProductCount = await (db.select(db.localProducts)..where((t) => t.isActive.equals(true))).get();
    if (localProductCount.length < 100) {
      print('SyncEngine: Only ${localProductCount.length} local products found. Forcing full catalog pull...');
      lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);
    }
    
    final newSyncTime = DateTime.now().toUtc();

    final isoLastSync = lastSyncTime.toIso8601String();

    print('SyncEngine: Pulling changes since $isoLastSync for shop: $shopId');

    try {
// 1. Projects
    if (shopId != null) {
    final remoteProjects = await supabase.from('projects').select().eq('shop_id', shopId).gte('updated_at', isoLastSync);
    for (final p in remoteProjects) {
      await db.into(db.localProjects).insertOnConflictUpdate(
        LocalProject(
          id: p['id'],
          title: p['name'] ?? '',
          description: p['project_type'],
          customerId: p['customer_id'],
          status: p['status'] ?? 'draft',
          netValue: 0.0,
          taxPercent: 0.0,
          totalValue: 0.0,
          notes: p['notes'],
          address: p['address'],
          isDeleted: p['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: DateTime.parse(p['created_at']),
          updatedAt: DateTime.parse(p['updated_at']),
        ),
      );
    }
    } // end if shopId != null

    
    } catch (e) {
      print('SyncEngine: Error pulling table projects - $e');
    }

    try {
// 2. Sessions
    if (shopId != null) {
      final remoteSessions = await supabase.from('measurement_sessions').select().gte('updated_at', isoLastSync);
      for (final s in remoteSessions) {
        await db.into(db.localMeasurementSessions).insertOnConflictUpdate(
          LocalMeasurementSession(
            id: s['id'],
            projectId: s['project_id'],
            technicianId: s['technician_id'],
            status: s['status'] ?? 'in_progress',
            notes: s['notes'],
            isDeleted: s['is_deleted'] ?? false,
            syncStatus: 'synced',
            createdAt: DateTime.parse(s['created_at']),
            updatedAt: DateTime.parse(s['updated_at']),
          ),
        );
      }
    }
    
    } catch (e) {
      print('SyncEngine: Error pulling table sessions - $e');
    }

    try {
// 3. Rooms
    if (shopId != null) {
      final remoteRooms = await supabase.from('rooms').select().gte('updated_at', isoLastSync);
      for (final r in remoteRooms) {
        await db.into(db.localRooms).insertOnConflictUpdate(
          LocalRoom(
            id: r['id'],
            sessionId: r['session_id'],
            name: r['name'] ?? '',
            type: r['shape_type'],
            length: 0.0,
            width: 0.0,
            height: (r['ceiling_height'] as num?)?.toDouble() ?? 0.0,
            floorArea: 0.0,
            perimeter: 0.0,
            isDeleted: r['is_deleted'] ?? false,
            syncStatus: 'synced',
            createdAt: r['created_at'] != null ? DateTime.parse(r['created_at']) : DateTime.now(),
            updatedAt: DateTime.parse(r['updated_at']),
          ),
        );
      }
    }
    
    } catch (e) {
      print('SyncEngine: Error pulling table rooms - $e');
    }

    try {
// 4. Walls
    if (shopId != null) {
      final remoteWalls = await supabase.from('walls').select().gte('updated_at', isoLastSync);
      for (final w in remoteWalls) {
        final double l = (w['length'] as num?)?.toDouble() ?? 0.0;
        final double h = (w['height'] as num?)?.toDouble() ?? 0.0;
        await db.into(db.localWalls).insertOnConflictUpdate(
          LocalWall(
            id: w['id'],
            roomId: w['room_id'],
            name: w['label'] ?? '',
            length: l,
            height: h,
            grossArea: l * h,
            netArea: l * h,
            materialType: w['notes'],
            isDeleted: w['is_deleted'] ?? false,
            syncStatus: 'synced',
            createdAt: w['created_at'] != null ? DateTime.parse(w['created_at']) : DateTime.now(),
            updatedAt: DateTime.parse(w['updated_at']),
          ),
        );
      }
    }
    
    } catch (e) {
      print('SyncEngine: Error pulling table walls - $e');
    }

    try {
// 5. Openings
    if (shopId != null) {
      final remoteOpenings = await supabase.from('wall_openings').select().gte('updated_at', isoLastSync);
      for (final o in remoteOpenings) {
        final double wd = (o['width'] as num?)?.toDouble() ?? 0.0;
        final double hg = (o['height'] as num?)?.toDouble() ?? 0.0;
        await db.into(db.localWallOpenings).insertOnConflictUpdate(
          LocalWallOpening(
            id: o['id'],
            wallId: o['wall_id'],
            type: o['type'] ?? '',
            name: o['label'],
            width: wd,
            height: hg,
            area: wd * hg,
            deductFromWall: o['deduct'] ?? true,
            isDeleted: o['is_deleted'] ?? false,
            syncStatus: 'synced',
            createdAt: o['created_at'] != null ? DateTime.parse(o['created_at']) : DateTime.now(),
            updatedAt: DateTime.parse(o['updated_at']),
          ),
        );
      }
    }
    
    } catch (e) {
      print('SyncEngine: Error pulling table - $e');
    }

    try {
// 6. Products — pulls BOTH shop-specific products AND global catalog products (shop_id IS NULL)
    final remoteShopProducts = shopId != null
        ? await supabase.from('products').select().eq('shop_id', shopId).gte('updated_at', isoLastSync)
        : <Map<String, dynamic>>[];
    final globalQuery = supabase.from('products').select().isFilter('shop_id', null);
    final remoteGlobalProducts = localProductCount.length < 100
        ? await globalQuery
        : await globalQuery.gte('updated_at', isoLastSync);
    final remoteProducts = [...remoteShopProducts, ...remoteGlobalProducts];
    print('SyncEngine: Fetched ${remoteShopProducts.length} shop products + ${remoteGlobalProducts.length} global catalog products from Supabase.');
    for (final p in remoteProducts) {
      await db.into(db.localProducts).insertOnConflictUpdate(
        LocalProduct(
          id: p['id'],
          name: p['name'] ?? '',
          code: p['code'],
          category: p['category'] ?? '',
          subcategory: p['subcategory'],
          unitType: p['unit_type'],
          imageUrl: p['image_url'],
          notes: p['notes'],
          isActive: p['is_active'] ?? true,
          brand: p['brand'],
          material: p['material'],
          moistureResistance: p['moisture_resistance'],
          installationMethod: p['installation_method'],
          defaultSupplierId: p['default_supplier_id'],
          isDeleted: p['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: p['created_at'] != null ? DateTime.parse(p['created_at']) : DateTime.now(),
          updatedAt: p['updated_at'] != null ? DateTime.parse(p['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling products - $e');
    }

    // All subsequent queries require a shop_id. Stop here for new users without a shop.
    if (shopId == null) {
      await prefs.setString(lastSyncKey, newSyncTime.toIso8601String());
      print('SyncEngine: No shop_id. Catalog-only pull complete.');
      return;
    }

    try {
// 7. Product Variants
    final remoteVariants = await supabase.from('product_variants').select().gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteVariants.length} product_variants from Supabase.');
    for (final v in remoteVariants) {
      await db.into(db.localProductVariants).insertOnConflictUpdate(
        LocalProductVariant(
          id: v['id'],
          productId: v['product_id'],
          variantName: v['variant_name'] ?? '',
          color: v['color'],
          dimensions: v['dimensions'],
          pieceLength: (v['piece_length'] as num?)?.toDouble(),
          pieceWidth: (v['piece_width'] as num?)?.toDouble(),
          thickness: (v['thickness'] as num?)?.toDouble(),
          effectiveCoverageWidth: (v['effective_coverage_width'] as num?)?.toDouble(),
          defaultWastePercent: (v['default_waste_percent'] as num?)?.toDouble(),
          imageUrl: v['image_url'],
          minSellingPrice: (v['min_selling_price'] as num?)?.toDouble(),
          isDeleted: v['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: v['created_at'] != null ? DateTime.parse(v['created_at']) : DateTime.now(),
          updatedAt: v['updated_at'] != null ? DateTime.parse(v['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling product_variants - $e');
    }

    try {
// 8. Customers
    final remoteCustomers = await supabase.from('customers').select().eq('shop_id', shopId).gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteCustomers.length} customers from Supabase.');
    for (final c in remoteCustomers) {
      await db.into(db.localCustomers).insertOnConflictUpdate(
        LocalCustomer(
          id: c['id'],
          name: c['name'] ?? '',
          phone: c['phone'],
          address: c['location'] ?? c['address'],
          type: c['customer_type'],
          notes: c['notes'],
          isDeleted: c['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: c['created_at'] != null ? DateTime.parse(c['created_at']) : DateTime.now(),
          updatedAt: c['updated_at'] != null ? DateTime.parse(c['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling customers - $e');
    }

    try {
// 9. Supplier Product Pricings
    final remotePricings = await supabase.from('supplier_product_pricings').select().gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remotePricings.length} supplier_product_pricings from Supabase.');
    for (final p in remotePricings) {
      await db.into(db.localSupplierPricings).insertOnConflictUpdate(
        LocalSupplierPricing(
          id: p['id'],
          productVariantId: p['product_variant_id'],
          supplierId: p['supplier_id'],
          supplierCode: p['supplier_code'],
          listPrice: (p['list_price'] as num?)?.toDouble() ?? 0.0,
          netPrice: (p['net_price'] as num?)?.toDouble() ?? 0.0,
          discountValue: (p['discount_value'] as num?)?.toDouble() ?? 0.0,
          isPreferred: p['is_preferred'] ?? false,
          isDeleted: p['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: p['created_at'] != null ? DateTime.parse(p['created_at']) : DateTime.now(),
          updatedAt: p['updated_at'] != null ? DateTime.parse(p['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling supplier_product_pricings - $e');
    }

    try {
// 10. Inventory Items
    final remoteInventory = await supabase.from('inventory_items').select().eq('shop_id', shopId).gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteInventory.length} inventory_items from Supabase.');
    for (final i in remoteInventory) {
      await db.into(db.localInventoryItems).insertOnConflictUpdate(
        LocalInventoryItem(
          id: i['id'],
          productVariantId: i['product_variant_id'],
          availableQty: (i['available_qty'] as num?)?.toDouble() ?? 0.0,
          reservedQty: (i['reserved_qty'] as num?)?.toDouble() ?? 0.0,
          damagedQty: (i['damaged_qty'] as num?)?.toDouble() ?? 0.0,
          reorderPoint: (i['reorder_point'] as num?)?.toDouble() ?? 0.0,
          isDeleted: i['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: i['created_at'] != null ? DateTime.parse(i['created_at']) : DateTime.now(),
          updatedAt: i['updated_at'] != null ? DateTime.parse(i['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling inventory_items - $e');
    }

    try {
// 11. Inventory Movements
    final remoteMovements = await supabase.from('inventory_movements').select().gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteMovements.length} inventory_movements from Supabase.');
    for (final m in remoteMovements) {
      await db.into(db.localInventoryMovements).insertOnConflictUpdate(
        LocalInventoryMovement(
          id: m['id'],
          inventoryItemId: m['inventory_item_id'],
          movementType: m['movement_type'] ?? '',
          quantity: (m['quantity'] as num?)?.toDouble() ?? 0.0,
          referenceId: m['reference_id'],
          notes: m['notes'],
          createdBy: m['created_by'],
          isDeleted: m['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
          updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling inventory_movements - $e');
    }

    try {
// 12. Quotes
    final remoteQuotes = await supabase.from('quotes').select().eq('shop_id', shopId).gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteQuotes.length} quotes from Supabase.');
    for (final q in remoteQuotes) {
      await db.into(db.localQuotes).insertOnConflictUpdate(
        LocalQuote(
          id: q['id'],
          quoteNumber: q['quote_number'],
          customerId: q['customer_id'],
          status: q['status'] ?? 'draft',
          totalAmount: (q['total_amount'] as num?)?.toDouble() ?? 0.0,
          taxAmount: (q['tax_amount'] as num?)?.toDouble() ?? 0.0,
          discountAmount: (q['discount_amount'] as num?)?.toDouble() ?? 0.0,
          notes: q['notes'],
          validUntil: q['valid_until'] != null ? DateTime.parse(q['valid_until']) : null,
          isDeleted: q['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: q['created_at'] != null ? DateTime.parse(q['created_at']) : DateTime.now(),
          updatedAt: q['updated_at'] != null ? DateTime.parse(q['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling quotes - $e');
    }

    try {
// 13. Quote Items
    final remoteQuoteItems = await supabase.from('quote_items').select().gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteQuoteItems.length} quote_items from Supabase.');
    for (final qi in remoteQuoteItems) {
      await db.into(db.localQuoteItems).insertOnConflictUpdate(
        LocalQuoteItem(
          id: qi['id'],
          quoteId: qi['quote_id'],
          productVariantId: qi['product_variant_id'],
          quantity: (qi['quantity'] as num?)?.toDouble() ?? 1.0,
          unitPrice: (qi['unit_price'] as num?)?.toDouble() ?? 0.0,
          totalPrice: (qi['final_line_total'] as num?)?.toDouble() ?? 0.0,
          notes: qi['notes'],
          isDeleted: qi['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: qi['created_at'] != null ? DateTime.parse(qi['created_at']) : DateTime.now(),
          updatedAt: qi['updated_at'] != null ? DateTime.parse(qi['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling quote_items - $e');
    }

    try {
// 14. Invoices
    final remoteInvoices = await supabase.from('invoices').select().eq('shop_id', shopId).gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteInvoices.length} invoices from Supabase.');
    for (final inv in remoteInvoices) {
      await db.into(db.localInvoices).insertOnConflictUpdate(
        LocalInvoice(
          id: inv['id'],
          invoiceNumber: inv['invoice_number'],
          customerId: inv['customer_id'],
          status: inv['status'] ?? 'draft',
          invoiceType: inv['invoice_type'] ?? 'sale',
          originalInvoiceId: inv['original_invoice_id'],
          totalAmount: (inv['total_amount'] as num?)?.toDouble() ?? 0.0,
          amountPaid: (inv['paid_amount'] as num?)?.toDouble() ?? 0.0,
          taxAmount: (inv['tax_amount'] as num?)?.toDouble() ?? 0.0,
          discountAmount: (inv['discount_amount'] as num?)?.toDouble() ?? 0.0,
          notes: inv['notes'],
          dueDate: inv['due_date'] != null ? DateTime.parse(inv['due_date']) : null,
          confirmedAt: inv['confirmed_at'] != null ? DateTime.parse(inv['confirmed_at']) : null,
          isDeleted: inv['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: inv['created_at'] != null ? DateTime.parse(inv['created_at']) : DateTime.now(),
          updatedAt: inv['updated_at'] != null ? DateTime.parse(inv['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling invoices - $e');
    }

    try {
// 15. Invoice Items
    final remoteInvoiceItems = await supabase.from('invoice_items').select().gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remoteInvoiceItems.length} invoice_items from Supabase.');
    for (final ii in remoteInvoiceItems) {
      await db.into(db.localInvoiceItems).insertOnConflictUpdate(
        LocalInvoiceItem(
          id: ii['id'],
          invoiceId: ii['invoice_id'],
          productVariantId: ii['product_variant_id'],
          quantity: (ii['quantity'] as num?)?.toDouble() ?? 1.0,
          unitPrice: (ii['unit_price'] as num?)?.toDouble() ?? 0.0,
          totalPrice: (ii['final_line_total'] as num?)?.toDouble() ?? 0.0,
          notes: ii['notes'],
          isDeleted: ii['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: ii['created_at'] != null ? DateTime.parse(ii['created_at']) : DateTime.now(),
          updatedAt: ii['updated_at'] != null ? DateTime.parse(ii['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling invoice_items - $e');
    }

    try {
// 16. Payments
    final remotePayments = await supabase.from('payments').select().eq('shop_id', shopId).gte('updated_at', isoLastSync);
    print('SyncEngine: Fetched ${remotePayments.length} payments from Supabase.');
    for (final p in remotePayments) {
      await db.into(db.localPayments).insertOnConflictUpdate(
        LocalPayment(
          id: p['id'],
          invoiceId: p['invoice_id'],
          customerId: p['customer_id'],
          amount: (p['amount'] as num?)?.toDouble() ?? 0.0,
          paymentMethod: p['payment_method'] ?? 'cash',
          referenceNumber: p['reference_number'],
          notes: p['notes'],
          createdBy: p['created_by'],
          isDeleted: p['is_deleted'] ?? false,
          syncStatus: 'synced',
          createdAt: p['created_at'] != null ? DateTime.parse(p['created_at']) : DateTime.now(),
          updatedAt: p['updated_at'] != null ? DateTime.parse(p['updated_at']) : DateTime.now(),
        ),
      );
    }
    } catch (e) {
      print('SyncEngine: Error pulling payments - $e');
    }
    await prefs.setString(lastSyncKey, newSyncTime.toIso8601String());
  }
}

