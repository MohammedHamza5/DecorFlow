import 'package:drift/drift.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:uuid/uuid.dart';

/// Repository for Quote operations.
class QuoteRepository {
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  QuoteRepository(this._db, this._syncEngine);

  /// Get all quotes with customer info.
  Future<List<Map<String, dynamic>>> getQuotes({
    String? status,
    String? customerId,
    int limit = 50,
  }) async {
    var query = _db.select(_db.localQuotes).join([
      leftOuterJoin(
        _db.localCustomers,
        _db.localCustomers.id.equalsExp(_db.localQuotes.customerId),
      ),
    ]);

    if (status != null) {
      query.where(_db.localQuotes.status.equals(status));
    }
    if (customerId != null) {
      query.where(_db.localQuotes.customerId.equals(customerId));
    }
    
    // don't fetch deleted ones
    query.where(_db.localQuotes.syncStatus.isNotValue('pending_delete'));

    query.orderBy([OrderingTerm.desc(_db.localQuotes.createdAt)]);
    query.limit(limit);

    final results = await query.get();

    if (results.isEmpty) return [];

    final quoteIds = results.map((row) => row.readTable(_db.localQuotes).id).toList();

    // Query item counts
    final countsQuery = _db.selectOnly(_db.localQuoteItems)
      ..addColumns([_db.localQuoteItems.quoteId, _db.localQuoteItems.id.count()])
      ..where(_db.localQuoteItems.quoteId.isIn(quoteIds))
      ..where(_db.localQuoteItems.syncStatus.isNotValue('pending_delete'))
      ..groupBy([_db.localQuoteItems.quoteId]);
    final countsRows = await countsQuery.get();
    final countsMap = {
      for (final r in countsRows)
        r.read(_db.localQuoteItems.quoteId)!: r.read(_db.localQuoteItems.id.count())!
    };

    return results.map((row) {
      final quote = row.readTable(_db.localQuotes);
      final customer = row.readTableOrNull(_db.localCustomers);
      final itemsCount = countsMap[quote.id] ?? 0;

      return {
        'id': quote.id,
        'quote_number': quote.quoteNumber,
        'customer_id': quote.customerId,
        'status': quote.status,
        'total_amount': quote.totalAmount,
        'tax_amount': quote.taxAmount,
        'discount_amount': quote.discountAmount,
        'final_total': quote.totalAmount - quote.discountAmount + quote.taxAmount,
        'total_discount': quote.discountAmount,
        'total_before_discount': quote.totalAmount,
        'notes': quote.notes,
        'valid_until': quote.validUntil?.toIso8601String(),
        'created_at': quote.createdAt.toIso8601String(),
        'updated_at': quote.updatedAt.toIso8601String(),
        'customer': customer != null
            ? {
                'id': customer.id,
                'name': customer.name,
                'phone': customer.phone,
              }
            : null,
        'quote_items': List.filled(itemsCount, {}),
      };
    }).toList();
  }

  /// Get a single quote with all line items.
  Future<Map<String, dynamic>?> getQuoteWithItems(String quoteId) async {
    final quoteRow = await (_db.select(_db.localQuotes).join([
      leftOuterJoin(
        _db.localCustomers,
        _db.localCustomers.id.equalsExp(_db.localQuotes.customerId),
      ),
    ])..where(_db.localQuotes.id.equals(quoteId))).getSingleOrNull();

    if (quoteRow == null) return null;

    final quote = quoteRow.readTable(_db.localQuotes);
    final customer = quoteRow.readTableOrNull(_db.localCustomers);

    // Get items
    final itemsQuery = _db.select(_db.localQuoteItems).join([
      leftOuterJoin(
        _db.localProductVariants,
        _db.localProductVariants.id.equalsExp(_db.localQuoteItems.productVariantId),
      ),
      leftOuterJoin(
        _db.localProducts,
        _db.localProducts.id.equalsExp(_db.localProductVariants.productId),
      ),
    ])..where(_db.localQuoteItems.quoteId.equals(quoteId))
      ..where(_db.localQuoteItems.syncStatus.isNotValue('pending_delete'));

    final itemsRows = await itemsQuery.get();
    
    final itemsList = itemsRows.map((row) {
      final item = row.readTable(_db.localQuoteItems);
      final variant = row.readTableOrNull(_db.localProductVariants);
      final product = row.readTableOrNull(_db.localProducts);

      final String pName = product != null ? product.name : 'منتج';
      final String vName = variant != null ? (variant.variantName != 'default' && variant.variantName != 'افتراضي' ? ' - ${variant.variantName}' : '') : '';
      final String displayName = '$pName$vName';

      String unitLabel = '';
      if (product?.unitType != null) {
        switch (product!.unitType) {
          case 'linear_meter': unitLabel = 'م.ط'; break;
          case 'square_meter': unitLabel = 'م²'; break;
          case 'rod': unitLabel = 'عود'; break;
          case 'panel': unitLabel = 'لوح'; break;
          case 'piece': unitLabel = 'قطعة'; break;
          case 'roll': unitLabel = 'رول'; break;
          case 'box': unitLabel = 'كرتونة'; break;
          case 'tube': unitLabel = 'أنبوبة'; break;
          case 'container': unitLabel = 'عبوة'; break;
          default: unitLabel = product.unitType ?? '';
        }
      }

      return {
        'id': item.id,
        'quote_id': item.quoteId,
        'product_variant_id': item.productVariantId,
        'quantity': item.quantity,
        'qty': item.quantity,
        'unit_price': item.unitPrice,
        'final_unit_price': item.unitPrice,
        'total_price': item.totalPrice,
        'final_line_total': item.totalPrice,
        'product_name': displayName,
        'unit': unitLabel,
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

    return {
      'id': quote.id,
      'quote_number': quote.quoteNumber,
      'customer_id': quote.customerId,
      'status': quote.status,
      'total_amount': quote.totalAmount,
      'tax_amount': quote.taxAmount,
      'discount_amount': quote.discountAmount,
      'final_total': quote.totalAmount - quote.discountAmount + quote.taxAmount,
      'total_discount': quote.discountAmount,
      'total_before_discount': quote.totalAmount,
      'notes': quote.notes,
      'valid_until': quote.validUntil?.toIso8601String(),
      'created_at': quote.createdAt.toIso8601String(),
      'updated_at': quote.updatedAt.toIso8601String(),
      'customer': customer != null
          ? {
              'id': customer.id,
              'name': customer.name,
              'phone': customer.phone,
              'location': customer.address,
            }
          : null,
      'quote_items': itemsList,
    };
  }

  /// Create a new quote (quote_number is auto-generated).
  Future<Map<String, dynamic>> createQuote(Map<String, dynamic> quote) async {
    final quoteId = quote['id'] ?? const Uuid().v4();
    final companion = LocalQuotesCompanion.insert(
      id: Value(quoteId),
      quoteNumber: quote['quote_number'] != null ? Value(quote['quote_number']) : const Value.absent(),
      customerId: quote['customer_id'] != null ? Value(quote['customer_id']) : const Value.absent(),
      status: quote['status'] != null ? Value(quote['status']) : const Value.absent(),
      notes: quote['notes'] != null ? Value(quote['notes']) : const Value.absent(),
    );
    final row = await _db.into(_db.localQuotes).insertReturning(companion);
    _syncEngine.sync();
    return _quoteToMap(row);
  }

  /// Create a quote directly from a session payload containing calculated items.
  Future<Map<String, dynamic>> createQuoteFromSession({
    required String customerId,
    required String projectId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final quoteId = const Uuid().v4();
    final companion = LocalQuotesCompanion.insert(
      id: Value(quoteId),
      customerId: Value(customerId),
      status: const Value('draft'),
      notes: Value(notes),
    );
    final quoteRow = await _db.into(_db.localQuotes).insertReturning(companion);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      await _db.into(_db.localQuoteItems).insert(
        LocalQuoteItemsCompanion.insert(
          id: Value(const Uuid().v4()),
          quoteId: quoteRow.id,
          productVariantId: item['product_variant_id'] ?? '',
          quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1.0),
          unitPrice: Value((item['unit_price'] as num?)?.toDouble() ?? 0.0),
          totalPrice: Value((item['total_price'] as num?)?.toDouble() ?? 0.0),
          notes: Value(item['notes']),
        ),
      );
    }
    
    _syncEngine.sync();
    return _quoteToMap(quoteRow);
  }

  /// Add an item to a quote.
  Future<Map<String, dynamic>> addQuoteItem(
    String quoteId,
    Map<String, dynamic> item,
  ) async {
    final companion = LocalQuoteItemsCompanion.insert(
      id: Value(const Uuid().v4()),
      quoteId: quoteId,
      productVariantId: item['product_variant_id'] ?? '',
      quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1.0),
      unitPrice: Value((item['unit_price'] as num?)?.toDouble() ?? 0.0),
      totalPrice: Value((item['total_price'] as num?)?.toDouble() ?? 0.0),
      notes: Value(item['notes']),
    );
    final row = await _db.into(_db.localQuoteItems).insertReturning(companion);
    await recalculateQuoteTotals(quoteId);
    _syncEngine.sync();
    return _quoteItemToMap(row);
  }

  /// Update quote item.
  Future<Map<String, dynamic>> updateQuoteItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    final existing = await (_db.select(_db.localQuoteItems)..where((t) => t.id.equals(itemId))).getSingle();
    final newStatus = existing.syncStatus == 'pending_insert' ? 'pending_insert' : 'pending_update';

    final companion = LocalQuoteItemsCompanion(
      quantity: data.containsKey('quantity') ? Value((data['quantity'] as num?)?.toDouble() ?? 1.0) : const Value.absent(),
      unitPrice: data.containsKey('unit_price') ? Value((data['unit_price'] as num?)?.toDouble() ?? 0.0) : const Value.absent(),
      totalPrice: data.containsKey('total_price') ? Value((data['total_price'] as num?)?.toDouble() ?? 0.0) : const Value.absent(),
      notes: data.containsKey('notes') ? Value(data['notes']) : const Value.absent(),
      syncStatus: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    );
    
    await (_db.update(_db.localQuoteItems)..where((t) => t.id.equals(itemId))).write(companion);
    
    final updatedRow = await (_db.select(_db.localQuoteItems)..where((t) => t.id.equals(itemId))).getSingle();
    await recalculateQuoteTotals(existing.quoteId);
    _syncEngine.sync();
    return _quoteItemToMap(updatedRow);
  }

  /// Recalculate quote totals.
  Future<void> recalculateQuoteTotals(String quoteId) async {
    final items = await (_db.select(_db.localQuoteItems)..where((t) => t.quoteId.equals(quoteId))
      ..where((t) => t.syncStatus.isNotValue('pending_delete'))).get();
    
    double total = 0;
    for (final item in items) {
      total += item.totalPrice;
    }
    
    final existing = await (_db.select(_db.localQuotes)..where((t) => t.id.equals(quoteId))).getSingle();
    final newStatus = existing.syncStatus == 'pending_insert' ? 'pending_insert' : 'pending_update';
    
    await (_db.update(_db.localQuotes)..where((t) => t.id.equals(quoteId))).write(
      LocalQuotesCompanion(
        totalAmount: Value(total),
        syncStatus: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Remove a quote item.
  Future<void> removeQuoteItem(String itemId) async {
    final existing = await (_db.select(_db.localQuoteItems)..where((t) => t.id.equals(itemId))).getSingleOrNull();
    if (existing == null) return;
    
    if (existing.syncStatus == 'pending_insert') {
      await (_db.delete(_db.localQuoteItems)..where((t) => t.id.equals(itemId))).go();
    } else {
      await (_db.update(_db.localQuoteItems)..where((t) => t.id.equals(itemId))).write(
        LocalQuoteItemsCompanion(
          syncStatus: const Value('pending_delete'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    await recalculateQuoteTotals(existing.quoteId);
    _syncEngine.sync();
  }

  /// Delete an entire quote (soft-delete for sync).
  Future<void> deleteQuote(String quoteId) async {
    final existing = await (_db.select(_db.localQuotes)..where((t) => t.id.equals(quoteId))).getSingleOrNull();
    if (existing == null) return;

    // Soft-delete all items first
    final items = await (_db.select(_db.localQuoteItems)..where((t) => t.quoteId.equals(quoteId))).get();
    for (final item in items) {
      if (item.syncStatus == 'pending_insert') {
        await (_db.delete(_db.localQuoteItems)..where((t) => t.id.equals(item.id))).go();
      } else {
        await (_db.update(_db.localQuoteItems)..where((t) => t.id.equals(item.id))).write(
          LocalQuoteItemsCompanion(
            syncStatus: const Value('pending_delete'),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }

    // Soft-delete the quote
    if (existing.syncStatus == 'pending_insert') {
      await (_db.delete(_db.localQuotes)..where((t) => t.id.equals(quoteId))).go();
    } else {
      await (_db.update(_db.localQuotes)..where((t) => t.id.equals(quoteId))).write(
        LocalQuotesCompanion(
          syncStatus: const Value('pending_delete'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    _syncEngine.sync();
  }

  /// Update quote status.
  Future<Map<String, dynamic>> updateStatus(
    String quoteId,
    String status,
  ) async {
    final existing = await (_db.select(_db.localQuotes)..where((t) => t.id.equals(quoteId))).getSingle();
    final newStatus = existing.syncStatus == 'pending_insert' ? 'pending_insert' : 'pending_update';

    await (_db.update(_db.localQuotes)..where((t) => t.id.equals(quoteId))).write(
      LocalQuotesCompanion(
        status: Value(status),
        syncStatus: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final row = await (_db.select(_db.localQuotes)..where((t) => t.id.equals(quoteId))).getSingle();
    _syncEngine.sync();
    return _quoteToMap(row);
  }

  /// Duplicate a quote (creates a new draft copy).
  Future<Map<String, dynamic>> duplicateQuote(String sourceQuoteId) async {
    final source = await getQuoteWithItems(sourceQuoteId);
    if (source == null) throw Exception('Quote not found');

    // Create new quote
    final newQuoteId = const Uuid().v4();
    final companion = LocalQuotesCompanion.insert(
      id: Value(newQuoteId),
      customerId: Value(source['customer_id']),
      status: const Value('draft'),
      notes: Value('نسخة من عرض ${source['quote_number'] ?? ""}'),
      totalAmount: Value((source['total_amount'] as num?)?.toDouble() ?? 0.0),
      taxAmount: Value((source['tax_amount'] as num?)?.toDouble() ?? 0.0),
      discountAmount: Value((source['discount_amount'] as num?)?.toDouble() ?? 0.0),
    );
    final newQuoteRow = await _db.into(_db.localQuotes).insertReturning(companion);

    // Copy items
    final items = source['quote_items'] as List? ?? [];
    for (final item in items) {
      await _db.into(_db.localQuoteItems).insert(
        LocalQuoteItemsCompanion.insert(
          id: Value(const Uuid().v4()),
          quoteId: newQuoteId,
          productVariantId: item['product_variant_id'] ?? '',
          quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1.0),
          unitPrice: Value((item['unit_price'] as num?)?.toDouble() ?? 0.0),
          totalPrice: Value((item['total_price'] as num?)?.toDouble() ?? 0.0),
          notes: Value(item['notes']),
        ),
      );
    }
    
    _syncEngine.sync();
    return _quoteToMap(newQuoteRow);
  }

  Map<String, dynamic> _quoteToMap(LocalQuote q) {
    return {
      'id': q.id,
      'quote_number': q.quoteNumber,
      'customer_id': q.customerId,
      'status': q.status,
      'total_amount': q.totalAmount,
      'tax_amount': q.taxAmount,
      'discount_amount': q.discountAmount,
      'notes': q.notes,
      'valid_until': q.validUntil?.toIso8601String(),
      'created_at': q.createdAt.toIso8601String(),
      'updated_at': q.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _quoteItemToMap(LocalQuoteItem i) {
    return {
      'id': i.id,
      'quote_id': i.quoteId,
      'product_variant_id': i.productVariantId,
      'quantity': i.quantity,
      'unit_price': i.unitPrice,
      'total_price': i.totalPrice,
      'notes': i.notes,
      'created_at': i.createdAt.toIso8601String(),
      'updated_at': i.updatedAt.toIso8601String(),
    };
  }
}
