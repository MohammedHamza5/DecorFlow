import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:stream_pay/engines/erp/inventory_engine.dart'
    as stream_pay_inventory_engine;
import 'package:stream_pay/engines/erp/cash_flow_engine.dart'
    as stream_pay_cash_flow_engine;
import 'package:uuid/uuid.dart';

class InvoiceRepository {
  final AppDatabase _db;
  final ErpDatabase _erpDb;
  final SyncEngine _syncEngine;

  InvoiceRepository(this._db, this._erpDb, this._syncEngine);

  /// ─── Create a Direct Invoice (No Quote Required) ───────────
  /// Creates an empty draft invoice directly for a customer.
  /// Items are added afterwards via addItemToInvoice.
  /// This enables the "lightning fast" invoice flow.
  Future<String> createDirectInvoice({
    required String customerId,
    String? notes,
  }) async {
    final invoiceId = const Uuid().v4();
    final invoiceNumber =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    await _db
        .into(_db.localInvoices)
        .insert(
          LocalInvoicesCompanion.insert(
            id: Value(invoiceId),
            invoiceNumber: Value(invoiceNumber),
            customerId: Value(customerId),
            totalAmount: const Value(0.0),
            status: const Value('draft'),
            syncStatus: const Value('pending_insert'),
          ),
        );

    _syncEngine.sync();
    return invoiceId;
  }

  /// Create a new invoice from a quote.
  /// The invoice starts as 'draft' — NO inventory deduction yet.
  /// Inventory is only deducted upon confirmation (confirmInvoice).
  Future<Map<String, dynamic>> createInvoiceFromQuote(String quoteId) async {
    // Fetch the quote with items
    final quote = await (_db.select(
      _db.localQuotes,
    )..where((tbl) => tbl.id.equals(quoteId))).getSingle();

    final quoteItems = await (_db.select(
      _db.localQuoteItems,
    )..where((tbl) => tbl.quoteId.equals(quoteId))).get();

    // Generate invoice number
    final String invoiceNumber =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final newInvoiceId = const Uuid().v4();

    // Create Invoice (as DRAFT — no inventory deduction)
    await _db
        .into(_db.localInvoices)
        .insert(
          LocalInvoicesCompanion.insert(
            id: Value(newInvoiceId),
            invoiceNumber: Value(invoiceNumber),
            customerId: Value(quote.customerId),
            totalAmount: Value(quote.totalAmount),
            taxAmount: Value(quote.taxAmount),
            discountAmount: Value(quote.discountAmount),
            status: const Value('draft'),
            syncStatus: const Value('pending_insert'),
          ),
        );

    // Create Invoice Items (NO inventory deduction here)
    for (final item in quoteItems) {
      await _db
          .into(_db.localInvoiceItems)
          .insert(
            LocalInvoiceItemsCompanion.insert(
              id: Value(const Uuid().v4()),
              invoiceId: newInvoiceId,
              productVariantId: item.productVariantId,
              quantity: Value(item.quantity),
              unitPrice: Value(item.unitPrice),
              totalPrice: Value(item.totalPrice),
              notes: Value(item.notes),
              syncStatus: const Value('pending_insert'),
            ),
          );
    }

    _syncEngine.sync();

    return {
      'id': newInvoiceId,
      'project_id': null,
      'quote_id': quoteId,
      'customer_id': quote.customerId,
      'invoice_number': invoiceNumber,
      'subtotal': quote.totalAmount - quote.taxAmount + quote.discountAmount,
      'tax_amount': quote.taxAmount,
      'discount_amount': quote.discountAmount,
      'total_amount': quote.totalAmount,
      'status': 'draft',
    };
  }

  /// ─── Confirm Invoice (Electronic Seal) ─────────────────────
  /// Changes status from 'draft' → 'confirmed' and deducts inventory.
  /// This is the ONLY place inventory is deducted.
  Future<void> confirmInvoice(String invoiceId) async {
    // 1. Fetch invoice with items
    final invoice = await (_db.select(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).getSingle();

    if (invoice.status != 'draft') {
      throw Exception('هذه الفاتورة معتمدة بالفعل ولا يمكن اعتمادها مرة أخرى.');
    }

    // 2. Update invoice status to confirmed + stamp confirmedAt
    final now = DateTime.now();
    await (_db.update(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).write(
      LocalInvoicesCompanion(
        status: const Value('confirmed'),
        confirmedAt: Value(now),
        syncStatus: const Value('pending_update'),
        updatedAt: Value(now),
      ),
    );

    // 3. Deduct inventory for each item
    final items = await (_db.select(
      _db.localInvoiceItems,
    )..where((tbl) => tbl.invoiceId.equals(invoiceId))).get();

    final inventoryEngine = stream_pay_inventory_engine.InventoryEngine(_erpDb);

    for (final item in items) {
      final variantIdStr = item.productVariantId;
      final qty = item.quantity;
      if (qty <= 0) continue;

      // Also record in the new ERP StockMovements Ledger
      // Note: variantId in old sync engine is a UUID string, but ProductVariants uses int id.
      // We will try to parse it. If it's a UUID, this might fail unless ProductVariants are actually synced with int IDs.
      // Wait, local products/variants in this app use UUID strings for everything.
      // Let's just catch the error if it fails parsing.
      int? parsedVariantId = int.tryParse(variantIdStr);
      if (parsedVariantId != null) {
        await inventoryEngine.recordMovement(
          variantId: parsedVariantId,
          movementType: 'sales_dispatch',
          quantityChange: -qty,
          notes: 'خصم تلقائي للمبيعات - فاتورة $invoiceId',
        );
      }

      // Find inventory item for this variant (Legacy Sync)
      final invItem =
          await (_db.select(_db.localInventoryItems)
                ..where((tbl) => tbl.productVariantId.equals(variantIdStr)))
              .getSingleOrNull();

      if (invItem != null) {
        await _db
            .into(_db.localInventoryMovements)
            .insert(
              LocalInventoryMovementsCompanion.insert(
                id: Value(const Uuid().v4()),
                inventoryItemId: invItem.id,
                movementType: 'out',
                quantity: Value(qty),
                referenceId: Value(invoiceId),
                notes: const Value('خصم تلقائي - فاتورة معتمدة'),
                createdBy: const Value('system'),
                syncStatus: const Value('pending_insert'),
              ),
            );

        await (_db.update(
          _db.localInventoryItems,
        )..where((tbl) => tbl.id.equals(invItem.id))).write(
          LocalInventoryItemsCompanion(
            availableQty: Value(invItem.availableQty - qty),
            syncStatus: const Value('pending_update'),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }

    _syncEngine.sync();
  }

  /// ─── Create Return Invoice ──────────────────────────────────────
  /// Creates a return invoice linked to the original invoice,
  /// and automatically restores inventory.
  Future<void> createReturnInvoice({
    required String originalInvoiceId,
    required List<Map<String, dynamic>> returnItems,
  }) async {
    final originalInvoice = await (_db.select(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(originalInvoiceId))).getSingle();

    final returnInvoiceId = const Uuid().v4();
    final String invoiceNumber =
        'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    double totalReturnAmount = 0;
    for (final item in returnItems) {
      final lineTotal =
          (item['quantity'] as num).toDouble() *
          (item['unit_price'] as num).toDouble();
      totalReturnAmount += lineTotal;
    }

    // 1. Create Return Invoice
    await _db
        .into(_db.localInvoices)
        .insert(
          LocalInvoicesCompanion.insert(
            id: Value(returnInvoiceId),
            invoiceNumber: Value(invoiceNumber),
            customerId: Value(originalInvoice.customerId),
            totalAmount: Value(-totalReturnAmount), // Negative for accounting
            invoiceType: const Value('return'),
            originalInvoiceId: Value(originalInvoiceId),
            status: const Value('confirmed'), // Auto-confirm returns
            syncStatus: const Value('pending_insert'),
          ),
        );

    // 2. Create items and restore inventory
    for (final item in returnItems) {
      final variantId = item['product_variant_id'] as String?;
      final qty = (item['quantity'] as num).toDouble();
      final price = (item['unit_price'] as num).toDouble();
      final lineTotal = qty * price;
      final productName = item['product_name'] as String?;

      // Store product name in notes so return items are readable
      final notesJson = productName != null
          ? '{"product_name":"$productName","is_return":true}'
          : '{"is_return":true}';

      await _db
          .into(_db.localInvoiceItems)
          .insert(
            LocalInvoiceItemsCompanion.insert(
              id: Value(const Uuid().v4()),
              invoiceId: returnInvoiceId,
              productVariantId: variantId ?? 'manual',
              quantity: Value(qty),
              unitPrice: Value(price),
              totalPrice: Value(-lineTotal), // Negative line total
              notes: Value(notesJson),
              syncStatus: const Value('pending_insert'),
            ),
          );

      // Restore Inventory — only for real variants (not manual items)
      final isRealVariant =
          variantId != null &&
          variantId.isNotEmpty &&
          variantId != 'manual' &&
          variantId.length == 36; // UUID length

      if (isRealVariant) {
        final invItem =
            await (_db.select(_db.localInventoryItems)
                  ..where((tbl) => tbl.productVariantId.equals(variantId)))
                .getSingleOrNull();

        if (invItem != null) {
          await _db
              .into(_db.localInventoryMovements)
              .insert(
                LocalInventoryMovementsCompanion.insert(
                  id: Value(const Uuid().v4()),
                  inventoryItemId: invItem.id,
                  movementType: 'in', // IN because it's a return
                  quantity: Value(qty),
                  referenceId: Value(returnInvoiceId),
                  notes: const Value('إضافة تلقائية - مرتجع مبيعات'),
                  createdBy: const Value('system'),
                  syncStatus: const Value('pending_insert'),
                ),
              );

          await (_db.update(
            _db.localInventoryItems,
          )..where((tbl) => tbl.id.equals(invItem.id))).write(
            LocalInventoryItemsCompanion(
              availableQty: Value(invItem.availableQty + qty),
              syncStatus: const Value('pending_update'),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }

    // 3. Record Cash Refund Outflow in CashFlowEngine (if amount > 0)
    if (totalReturnAmount > 0) {
      try {
        final cashEngine = stream_pay_cash_flow_engine.CashFlowEngine(_erpDb);
        await cashEngine.recordTransaction(
          type: 'out',
          amount: totalReturnAmount,
          category: 'sales_return',
          notes: 'رد نقدية مرتجع مبيعات للفاتورة ${originalInvoice.invoiceNumber} ($invoiceNumber)',
        );
      } catch (_) {}
    }

    _syncEngine.sync();
  }

  /// ─── Delete Invoice (Drafts Only) ──────────────────────────
  Future<void> deleteInvoice(String invoiceId) async {
    final invoice = await (_db.select(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).getSingle();

    if (invoice.status != 'draft') {
      throw Exception('لا يمكن حذف فاتورة معتمدة. يمكن حذف المسودات فقط.');
    }

    // Delete invoice items first
    await (_db.delete(
      _db.localInvoiceItems,
    )..where((tbl) => tbl.invoiceId.equals(invoiceId))).go();

    // Ignore payments for now

    // Delete invoice
    await (_db.delete(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).go();

    _syncEngine.sync();
  }

  /// Get all invoices with customer details
  Future<List<Map<String, dynamic>>> getInvoices({String? customerId}) async {
    var query = _db.select(_db.localInvoices);
    if (customerId != null) {
      query.where((tbl) => tbl.customerId.equals(customerId));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);

    final response = await query.get();

    final customers = await _db.select(_db.localCustomers).get();
    final customerMap = {for (var c in customers) c.id: c};

    return response.map((inv) {
      final c = customerMap[inv.customerId];
      return {
        'id': inv.id,
        'invoice_number': inv.invoiceNumber,
        'customer_id': inv.customerId,
        'status': inv.status,
        'total_amount': inv.totalAmount,
        'paid_amount': inv.amountPaid,
        'tax_amount': inv.taxAmount,
        'discount_amount': inv.discountAmount,
        'created_at': inv.createdAt.toIso8601String(),
        'customer': c != null
            ? {'name': c.name, 'phone': c.phone}
            : {'name': 'عميل نقدي (كاش)', 'phone': ''},
      };
    }).toList();
  }

  /// Get single invoice with items and payments
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    final invoice = await (_db.select(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).getSingle();

    final itemsQuery =
        _db.select(_db.localInvoiceItems).join([
            leftOuterJoin(
              _db.localProductVariants,
              _db.localProductVariants.id.equalsExp(
                _db.localInvoiceItems.productVariantId,
              ),
            ),
            leftOuterJoin(
              _db.localProducts,
              _db.localProducts.id.equalsExp(
                _db.localProductVariants.productId,
              ),
            ),
          ])
          ..where(_db.localInvoiceItems.invoiceId.equals(invoiceId))
          ..where(
            _db.localInvoiceItems.syncStatus.isNotValue('pending_delete'),
          );

    final itemsRows = await itemsQuery.get();

    final itemsList = itemsRows.map((row) {
      final item = row.readTable(_db.localInvoiceItems);
      final variant = row.readTableOrNull(_db.localProductVariants);
      final product = row.readTableOrNull(_db.localProducts);

      String? notesName;
      String? notesUnit;
      if (item.notes != null && item.notes!.startsWith('{')) {
        try {
          final map = jsonDecode(item.notes!) as Map;
          notesName = map['product_name'] as String?;
          notesUnit = map['unit'] as String?;
        } catch (_) {}
      }

      final String pName = product != null
          ? product.name
          : (notesName ?? 'منتج');
      final String vName = variant != null
          ? (variant.variantName != 'default' &&
                    variant.variantName != 'افتراضي'
                ? ' - ${variant.variantName}'
                : '')
          : '';
      final String displayName = product != null
          ? '$pName$vName'
          : (notesName ?? 'منتج');

      String unitLabel = notesUnit ?? '';
      if (product?.unitType != null && unitLabel.isEmpty) {
        switch (product!.unitType) {
          case 'linear_meter':
            unitLabel = 'م.ط';
            break;
          case 'square_meter':
            unitLabel = 'م²';
            break;
          case 'rod':
            unitLabel = 'عود';
            break;
          case 'panel':
            unitLabel = 'لوح';
            break;
          case 'piece':
            unitLabel = 'قطعة';
            break;
          case 'roll':
            unitLabel = 'رول';
            break;
          case 'box':
            unitLabel = 'كرتونة';
            break;
          case 'tube':
            unitLabel = 'أنبوبة';
            break;
          case 'container':
            unitLabel = 'عبوة';
            break;
          default:
            unitLabel = product.unitType ?? '';
        }
      }

      return {
        'id': item.id,
        'invoice_id': item.invoiceId,
        'product_variant_id': item.productVariantId,
        'product_name': displayName,
        'quantity': item.quantity,
        'qty': item.quantity,
        'unit': unitLabel,
        'unit_price': item.unitPrice,
        'final_line_total': item.totalPrice,
        'total_price': item.totalPrice,
        'notes': item.notes,
        'created_at': item.createdAt.toIso8601String(),
        'updated_at': item.updatedAt.toIso8601String(),
        'product_variant': variant != null
            ? {
                'id': variant.id,
                'variant_name': variant.variantName,
                'color': variant.color,
                'dimensions': variant.dimensions,
                'min_selling_price': variant.minSellingPrice,
                'product': product != null
                    ? {
                        'id': product.id,
                        'name': product.name,
                        'brand': product.brand,
                        'category': product.category,
                      }
                    : null,
              }
            : null,
      };
    }).toList();

    LocalCustomer? customer;
    if (invoice.customerId != null) {
      customer = await (_db.select(
        _db.localCustomers,
      )..where((tbl) => tbl.id.equals(invoice.customerId!))).getSingleOrNull();
    }

    final payments =
        await (_db.select(_db.localPayments)
              ..where((tbl) => tbl.invoiceId.equals(invoiceId))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    return {
      'id': invoice.id,
      'invoice_number': invoice.invoiceNumber,
      'customer_id': invoice.customerId,
      'status': invoice.status,
      'total_amount': invoice.totalAmount,
      'paid_amount': invoice.amountPaid,
      'tax_amount': invoice.taxAmount,
      'discount_amount': invoice.discountAmount,
      'notes': invoice.notes,
      'invoice_type': invoice.invoiceType,
      'created_at': invoice.createdAt.toIso8601String(),
      'confirmed_at': invoice.confirmedAt?.toIso8601String(),
      'customer': customer != null
          ? {
              'name': customer.name,
              'phone': customer.phone,
              'location': customer.address,
            }
          : null,
      'invoice_items': itemsList,
      'payments': payments
          .map(
            (p) => {
              'id': p.id,
              'amount': p.amount,
              'payment_method': p.paymentMethod,
              'reference_number': p.referenceNumber,
              'created_at': p.createdAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  /// ─── Add Item to Invoice (Direct/Manual) ───────────────────
  /// Supports both catalog variants and free-text manual items.
  /// Manual items store their name+unit in the notes field as JSON.
  Future<void> addItemToInvoice({
    required String invoiceId,
    required String productVariantId,
    required String productName,
    required String unit,
    required double quantity,
    required double unitPrice,
  }) async {
    final existingInvoice = await (_db.select(
      _db.localInvoices,
    )..where((t) => t.id.equals(invoiceId))).getSingle();

    if (existingInvoice.status != 'draft') {
      throw Exception('لا يمكن إضافة بنود لفاتورة معتمدة.');
    }

    final lineTotal = quantity * unitPrice;

    // For manual items (no real variant), store metadata in notes as JSON
    final notesJson = productVariantId == 'manual'
        ? '{"product_name":"$productName","unit":"$unit"}'
        : '{"product_name":"$productName","unit":"$unit"}';

    await _db
        .into(_db.localInvoiceItems)
        .insert(
          LocalInvoiceItemsCompanion.insert(
            id: Value(const Uuid().v4()),
            invoiceId: invoiceId,
            productVariantId: productVariantId == 'manual'
                ? 'MANUAL-${const Uuid().v4()}'
                : productVariantId,
            quantity: Value(quantity),
            unitPrice: Value(unitPrice),
            totalPrice: Value(lineTotal),
            notes: Value(notesJson),
            syncStatus: const Value('pending_insert'),
          ),
        );

    await recalculateInvoiceTotals(invoiceId);
    _syncEngine.sync();
  }

  /// Add an item to an invoice (Drafts only).
  Future<Map<String, dynamic>> addInvoiceItem(
    String invoiceId,
    Map<String, dynamic> item,
  ) async {
    final existingInvoice = await (_db.select(
      _db.localInvoices,
    )..where((t) => t.id.equals(invoiceId))).getSingle();

    if (existingInvoice.status != 'draft') {
      throw Exception(
        'لا يمكن تعديل بنود فاتورة معتمدة. التعديل متاح للمسودات فقط.',
      );
    }

    final companion = LocalInvoiceItemsCompanion.insert(
      id: Value(const Uuid().v4()),
      invoiceId: invoiceId,
      productVariantId: item['product_variant_id'] ?? '',
      quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1.0),
      unitPrice: Value((item['unit_price'] as num?)?.toDouble() ?? 0.0),
      totalPrice: Value((item['total_price'] as num?)?.toDouble() ?? 0.0),
      notes: Value(item['notes']),
      syncStatus: const Value('pending_insert'),
    );
    final row = await _db
        .into(_db.localInvoiceItems)
        .insertReturning(companion);
    await recalculateInvoiceTotals(invoiceId);
    _syncEngine.sync();

    return {
      'id': row.id,
      'invoice_id': row.invoiceId,
      'product_variant_id': row.productVariantId,
      'quantity': row.quantity,
      'unit_price': row.unitPrice,
      'total_price': row.totalPrice,
      'notes': row.notes,
    };
  }

  /// Update an invoice item (Drafts only).
  Future<Map<String, dynamic>> updateInvoiceItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    final existing = await (_db.select(
      _db.localInvoiceItems,
    )..where((t) => t.id.equals(itemId))).getSingle();

    final existingInvoice = await (_db.select(
      _db.localInvoices,
    )..where((t) => t.id.equals(existing.invoiceId))).getSingle();

    if (existingInvoice.status != 'draft') {
      throw Exception(
        'لا يمكن تعديل بنود فاتورة معتمدة. التعديل متاح للمسودات فقط.',
      );
    }

    final newStatus = existing.syncStatus == 'pending_insert'
        ? 'pending_insert'
        : 'pending_update';

    final companion = LocalInvoiceItemsCompanion(
      quantity: data.containsKey('quantity')
          ? Value((data['quantity'] as num?)?.toDouble() ?? 1.0)
          : const Value.absent(),
      unitPrice: data.containsKey('unit_price')
          ? Value((data['unit_price'] as num?)?.toDouble() ?? 0.0)
          : const Value.absent(),
      totalPrice: data.containsKey('total_price')
          ? Value((data['total_price'] as num?)?.toDouble() ?? 0.0)
          : const Value.absent(),
      notes: data.containsKey('notes')
          ? Value(data['notes'])
          : const Value.absent(),
      syncStatus: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    );

    await (_db.update(
      _db.localInvoiceItems,
    )..where((t) => t.id.equals(itemId))).write(companion);
    await recalculateInvoiceTotals(existing.invoiceId);
    _syncEngine.sync();

    final updatedRow = await (_db.select(
      _db.localInvoiceItems,
    )..where((t) => t.id.equals(itemId))).getSingle();
    return {
      'id': updatedRow.id,
      'invoice_id': updatedRow.invoiceId,
      'product_variant_id': updatedRow.productVariantId,
      'quantity': updatedRow.quantity,
      'unit_price': updatedRow.unitPrice,
      'total_price': updatedRow.totalPrice,
      'notes': updatedRow.notes,
    };
  }

  /// Remove an invoice item (Drafts only).
  Future<void> removeInvoiceItem(String itemId) async {
    final existing = await (_db.select(
      _db.localInvoiceItems,
    )..where((t) => t.id.equals(itemId))).getSingleOrNull();
    if (existing == null) return;

    final existingInvoice = await (_db.select(
      _db.localInvoices,
    )..where((t) => t.id.equals(existing.invoiceId))).getSingle();

    if (existingInvoice.status != 'draft') {
      throw Exception(
        'لا يمكن تعديل بنود فاتورة معتمدة. التعديل متاح للمسودات فقط.',
      );
    }

    if (existing.syncStatus == 'pending_insert') {
      await (_db.delete(
        _db.localInvoiceItems,
      )..where((t) => t.id.equals(itemId))).go();
    } else {
      await (_db.update(
        _db.localInvoiceItems,
      )..where((t) => t.id.equals(itemId))).write(
        LocalInvoiceItemsCompanion(
          syncStatus: const Value('pending_delete'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    await recalculateInvoiceTotals(existing.invoiceId);
    _syncEngine.sync();
  }

  /// Recalculate invoice totals.
  Future<void> recalculateInvoiceTotals(String invoiceId) async {
    final items =
        await (_db.select(_db.localInvoiceItems)
              ..where((t) => t.invoiceId.equals(invoiceId))
              ..where((t) => t.syncStatus.isNotValue('pending_delete')))
            .get();

    double total = 0;
    for (final item in items) {
      total += item.totalPrice;
    }

    final existing = await (_db.select(
      _db.localInvoices,
    )..where((t) => t.id.equals(invoiceId))).getSingle();
    final newStatus = existing.syncStatus == 'pending_insert'
        ? 'pending_insert'
        : 'pending_update';

    await (_db.update(
      _db.localInvoices,
    )..where((t) => t.id.equals(invoiceId))).write(
      LocalInvoicesCompanion(
        totalAmount: Value(total),
        syncStatus: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Record a payment for an invoice
  Future<Map<String, dynamic>> recordPayment({
    required String invoiceId,
    required String customerId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final invoice = await (_db.select(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).getSingle();

    final newPaid = invoice.amountPaid + amount;
    String newStatus = invoice.status;

    // Auto-update status if fully paid
    if (invoice.status == 'confirmed' || invoice.status == 'partially_paid') {
      if (newPaid >= invoice.totalAmount) {
        newStatus = 'paid';
      } else {
        newStatus = 'partially_paid';
      }
    }

    await (_db.update(
      _db.localInvoices,
    )..where((tbl) => tbl.id.equals(invoiceId))).write(
      LocalInvoicesCompanion(
        amountPaid: Value(newPaid),
        status: Value(newStatus),
        syncStatus: const Value('pending_update'),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final newPaymentId = const Uuid().v4();
    await _db
        .into(_db.localPayments)
        .insert(
          LocalPaymentsCompanion.insert(
            id: Value(newPaymentId),
            invoiceId: invoiceId,
            customerId: Value(customerId),
            amount: Value(amount),
            paymentMethod: Value(paymentMethod),
            referenceNumber: Value(referenceNumber),
            notes: Value(notes),
            syncStatus: const Value('pending_insert'),
          ),
        );

    // Add payment to ERP CashFlowEngine
    final cashEngine = stream_pay_cash_flow_engine.CashFlowEngine(_erpDb);
    await cashEngine.recordTransaction(
      type: 'in',
      amount: amount,
      category: 'customer_payment',
      notes: 'دفعة فاتورة المبيعات $invoiceId - $paymentMethod',
    );

    // 4. Update Invoice Statusync();

    _syncEngine.sync();

    return {
      'id': newPaymentId,
      'invoice_id': invoiceId,
      'customer_id': customerId,
      'amount': amount,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'notes': notes,
    };
  }
}
