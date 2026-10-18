import 'package:flutter/foundation.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/database/app_database.dart' show ErpDatabase;
import 'package:stream_pay/engines/erp/cash_flow_engine.dart' as stream_pay_cash_flow_engine;
import 'package:stream_pay/core/sync/sync_engine.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Offline-first repository for Customer operations.
/// Provides full financial data: invoices, payments, debts, and ledger.
class CustomerRepository {
  final AppDatabase _db;
  final SyncEngine _syncEngine;
  final ErpDatabase? _erpDb;

  CustomerRepository(this._db, this._syncEngine, [this._erpDb]);

  // ─── Customer Classification Tags ─────────────────────────────────────────
  /// Returns a smart classification label based on financial status.
  static String classifyCustomer({
    required double totalDebt,
    required double totalSales,
    required int invoiceCount,
    required String? storedType,
  }) {
    if (storedType == 'VIP') return 'VIP';
    if (totalDebt > 5000) return 'debt_risk';
    if (totalDebt > 0) return 'has_debt';
    if (invoiceCount == 0) return 'new';
    return 'regular';
  }

  // ─── Get All Customers (with financial snapshot) ───────────────────────────
  Future<List<Map<String, dynamic>>> getCustomers({
    String? search,
    String? filterType, // 'all' | 'has_debt' | 'VIP'
    int limit = 200,
  }) async {
    final query = _db.select(_db.localCustomers)
      ..where((t) => t.syncStatus.isNotValue('pending_delete') & t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)])
      ..limit(limit);

    final customers = await query.get();

    final results = <Map<String, dynamic>>[];

    for (final c in customers) {
      final financials = await _getCustomerFinancials(c.id);

      final totalSales = financials['total_sales'] as double;
      final totalPaid = financials['total_paid'] as double;
      final totalDebt = financials['total_debt'] as double;
      final invoiceCount = financials['invoice_count'] as int;

      final classTag = classifyCustomer(
        totalDebt: totalDebt,
        totalSales: totalSales,
        invoiceCount: invoiceCount,
        storedType: c.type,
      );

      final row = {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'address': c.address,
        'type': c.type,
        'class_tag': classTag,
        'notes': c.notes,
        'created_at': c.createdAt.toIso8601String(),
        'total_sales': totalSales,
        'total_paid': totalPaid,
        'total_debt': totalDebt,
        'invoice_count': invoiceCount,
      };

      results.add(row);
    }

    // Apply search filter
    var filtered = results;
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase().trim();
      filtered = filtered.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final phone = (c['phone'] as String? ?? '').toLowerCase();
        final address = (c['address'] as String? ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q) || address.contains(q);
      }).toList();
    }

    // Apply type filter
    if (filterType != null && filterType != 'all') {
      if (filterType == 'has_debt') {
        filtered = filtered.where((c) => (c['total_debt'] as double) > 0).toList();
      } else if (filterType == 'VIP') {
        filtered = filtered.where((c) => c['class_tag'] == 'VIP' || c['type'] == 'VIP').toList();
      }
    }

    return filtered;
  }

  // ─── Get Customer Financial Summary ───────────────────────────────────────
  Future<Map<String, dynamic>> _getCustomerFinancials(String customerId) async {
    // Sum confirmed/paid/partially_paid sales invoices
    final invoices = await (_db.select(_db.localInvoices)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false) &
              t.syncStatus.isNotValue('pending_delete') &
              t.invoiceType.equals('sale')))
        .get();

    double totalSales = 0;
    double totalPaid = 0;
    int invoiceCount = 0;

    for (final inv in invoices) {
      if (inv.status == 'confirmed' ||
          inv.status == 'paid' ||
          inv.status == 'partially_paid') {
        totalSales += inv.totalAmount;
        invoiceCount++;
      }
    }

    // Sum all payments for this customer
    final payments = await (_db.select(_db.localPayments)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false)))
        .get();

    for (final p in payments) {
      totalPaid += p.amount;
    }

    // Subtract confirmed return invoices
    final returns = await (_db.select(_db.localInvoices)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false) &
              t.invoiceType.equals('return')))
        .get();

    double totalReturns = 0;
    for (final ret in returns) {
      if (ret.status == 'confirmed') {
        // Return invoice amounts are stored as negative values
        totalReturns += ret.totalAmount.abs();
      }
    }

    final effectiveSales = totalSales - totalReturns;
    final totalDebt = (effectiveSales - totalPaid).clamp(0.0, double.infinity);

    return {
      'total_sales': effectiveSales,
      'total_paid': totalPaid,
      'total_debt': totalDebt,
      'total_returns': totalReturns,
      'invoice_count': invoiceCount,
    };
  }

  // ─── Get Full Customer Profile (with projects, quotes, invoices) ───────────
  Future<Map<String, dynamic>?> getCustomerProfile(String customerId) async {
    final c = await (_db.select(_db.localCustomers)
          ..where((t) => t.id.equals(customerId)))
        .getSingleOrNull();
    if (c == null || c.syncStatus == 'pending_delete') return null;

    final projects = await (_db.select(_db.localProjects)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.syncStatus.isNotValue('pending_delete') &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();

    final quotes = await (_db.select(_db.localQuotes)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.syncStatus.isNotValue('pending_delete') &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();

    final invoices = await (_db.select(_db.localInvoices)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false) &
              t.syncStatus.isNotValue('pending_delete'))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();

    // Get all payments for this customer's invoices
    final allPayments = await (_db.select(_db.localPayments)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();

    final financials = await _getCustomerFinancials(customerId);

    final classTag = classifyCustomer(
      totalDebt: financials['total_debt'] as double,
      totalSales: financials['total_sales'] as double,
      invoiceCount: financials['invoice_count'] as int,
      storedType: c.type,
    );

    return {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'address': c.address,
      'type': c.type,
      'class_tag': classTag,
      'notes': c.notes,
      'created_at': c.createdAt.toIso8601String(),
      // Financials
      'total_sales': financials['total_sales'],
      'total_paid': financials['total_paid'],
      'total_debt': financials['total_debt'],
      'total_returns': financials['total_returns'],
      'invoice_count': financials['invoice_count'],
      // Relations
      'projects': projects.map((p) => {
        'id': p.id,
        'title': p.title,
        'status': p.status,
        'description': p.description,
        'created_at': p.createdAt.toIso8601String(),
      }).toList(),
      'quotes': quotes.map((q) => {
        'id': q.id,
        'quote_number': q.quoteNumber,
        'status': q.status,
        'total_amount': q.totalAmount,
        'created_at': q.createdAt.toIso8601String(),
        'valid_until': q.validUntil?.toIso8601String(),
      }).toList(),
      'invoices': invoices.map((inv) => {
        'id': inv.id,
        'invoice_number': inv.invoiceNumber,
        'status': inv.status,
        'invoice_type': inv.invoiceType,
        'total_amount': inv.totalAmount,
        'amount_paid': inv.amountPaid,
        'due_date': inv.dueDate?.toIso8601String(),
        'created_at': inv.createdAt.toIso8601String(),
      }).toList(),
      'payments': allPayments.map((p) => {
        'id': p.id,
        'invoice_id': p.invoiceId,
        'amount': p.amount,
        'payment_method': p.paymentMethod,
        'reference_number': p.referenceNumber,
        'notes': p.notes,
        'created_at': p.createdAt.toIso8601String(),
      }).toList(),
    };
  }

  // ─── Financial Ledger (Chronological Statement) ────────────────────────────
  /// Returns a chronological list of all financial movements for a customer,
  /// with running balance for a complete accounting ledger.
  Future<List<Map<String, dynamic>>> getCustomerLedger(String customerId) async {
    final entries = <Map<String, dynamic>>[];

    // Invoices (debit entries — what the customer owes us)
    // ⚠️ استثناء المسودات (draft) — لا تُحتسب في كشف الحساب حتى تُعتمد
    final invoices = await (_db.select(_db.localInvoices)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false) &
              t.syncStatus.isNotValue('pending_delete'))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();

    for (final inv in invoices) {
      // تجاهل الفواتير المسودة غير المعتمدة
      if (inv.status == 'draft') continue;

      final isReturn = inv.invoiceType == 'return';
      entries.add({
        'date': inv.createdAt,
        'type': isReturn ? 'credit' : 'debit',
        'entry_type': isReturn ? 'return_invoice' : 'sale_invoice',
        'description': isReturn
            ? 'فاتورة مرتجع ${inv.invoiceNumber ?? ""}'
            : 'فاتورة مبيعات ${inv.invoiceNumber ?? ""}',
        'invoice_id': inv.id,
        'debit': isReturn ? 0.0 : inv.totalAmount,
        'credit': isReturn ? inv.totalAmount.abs() : 0.0,
        'status': inv.status,
        'ref': inv.invoiceNumber ?? '',
      });
    }

    // Payments (credit entries — what the customer paid)
    final payments = await (_db.select(_db.localPayments)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();

    for (final p in payments) {
      entries.add({
        'date': p.createdAt,
        'type': 'credit',
        'entry_type': 'payment',
        'description': 'دفعة مستلمة — ${_translatePaymentMethod(p.paymentMethod)}',
        'invoice_id': p.invoiceId,
        'debit': 0.0,
        'credit': p.amount,
        'ref': p.referenceNumber ?? '',
      });
    }

    // Sort all entries by date ascending
    entries.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Calculate running balance
    double runningBalance = 0;
    for (final e in entries) {
      final debit = (e['debit'] as double);
      final credit = (e['credit'] as double);
      runningBalance = runningBalance + debit - credit;
      e['balance'] = runningBalance;
      e['date'] = (e['date'] as DateTime).toIso8601String();
    }

    return entries;
  }

  // ─── Record Direct Payment (Smart Debt Waterfall & FIFO) ────────────────
  /// Records a payment for the customer with smart multi-invoice distribution.
  /// Cascades across unpaid/partially paid invoices (FIFO), handles excess advance payments,
  /// and deposits the inflow into CashFlowEngine.
  Future<Map<String, dynamic>> recordDirectPayment({
    required String customerId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? specificInvoiceId,
  }) async {
    if (amount <= 0) {
      throw Exception('قيمة الدفعة يجب أن تكون أكبر من الصفر');
    }

    final customer = await (_db.select(_db.localCustomers)
          ..where((t) => t.id.equals(customerId)))
        .getSingleOrNull();
    final customerName = customer?.name ?? 'عميل';

    // البحث عن كافة فواتير المبيعات المعتمدة غير المحذوفة للعميل
    final confirmedInvoices = await (_db.select(_db.localInvoices)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.isDeleted.equals(false) &
              t.invoiceType.equals('sale') &
              t.syncStatus.isNotValue('pending_delete'))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();

    double remainingToAllocate = amount;
    final createdPaymentIds = <String>[];
    String? primaryInvoiceId;

    // 1. إذا اختار المستخدم فاتورة محددة يدوياً
    if (specificInvoiceId != null &&
        specificInvoiceId.isNotEmpty &&
        specificInvoiceId != 'auto' &&
        specificInvoiceId != 'advance') {
      final targetInv = confirmedInvoices.firstWhere(
        (inv) => inv.id == specificInvoiceId,
        orElse: () => confirmedInvoices.first,
      );

      final double due = (targetInv.totalAmount - targetInv.amountPaid).clamp(0.0, double.infinity);
      final double allocated = remainingToAllocate > due && due > 0 ? due : remainingToAllocate;

      final pId = const Uuid().v4();
      createdPaymentIds.add(pId);
      primaryInvoiceId = targetInv.id;

      await _db.into(_db.localPayments).insert(
        LocalPaymentsCompanion.insert(
          id: Value(pId),
          invoiceId: targetInv.id,
          customerId: Value(customerId),
          amount: Value(allocated),
          paymentMethod: Value(paymentMethod),
          referenceNumber: Value(referenceNumber),
          notes: Value(notes ?? 'سداد مخصص للفاتورة #${targetInv.invoiceNumber ?? ""}'),
          syncStatus: const Value('pending_insert'),
        ),
      );

      final newPaid = targetInv.amountPaid + allocated;
      final newStatus = newPaid >= targetInv.totalAmount ? 'paid' : 'partially_paid';
      await (_db.update(_db.localInvoices)..where((t) => t.id.equals(targetInv.id))).write(
        LocalInvoicesCompanion(
          amountPaid: Value(newPaid),
          status: Value(newStatus),
          syncStatus: const Value('pending_update'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      remainingToAllocate -= allocated;
    }

    // 2. التوزيع التلقائي الذكي على الفواتير المتبقية (FIFO - الأقدم أولاً)
    final unpaidInvoices = confirmedInvoices.where((inv) {
      final double due = inv.totalAmount - inv.amountPaid;
      return (inv.status == 'confirmed' || inv.status == 'partially_paid') && due > 0.001;
    }).toList();

    if (remainingToAllocate > 0.001 &&
        unpaidInvoices.isNotEmpty &&
        (specificInvoiceId == null || specificInvoiceId == 'auto')) {
      for (final inv in unpaidInvoices) {
        if (remainingToAllocate <= 0.001) break;

        final double due = (inv.totalAmount - inv.amountPaid).clamp(0.0, double.infinity);
        if (due <= 0) continue;

        final double allocated = remainingToAllocate >= due ? due : remainingToAllocate;

        final pId = const Uuid().v4();
        createdPaymentIds.add(pId);
        primaryInvoiceId ??= inv.id;

        await _db.into(_db.localPayments).insert(
          LocalPaymentsCompanion.insert(
            id: Value(pId),
            invoiceId: inv.id,
            customerId: Value(customerId),
            amount: Value(allocated),
            paymentMethod: Value(paymentMethod),
            referenceNumber: Value(referenceNumber),
            notes: Value(notes ?? 'سداد موزع للفاتورة #${inv.invoiceNumber ?? ""}'),
            syncStatus: const Value('pending_insert'),
          ),
        );

        final newPaid = inv.amountPaid + allocated;
        final newStatus = newPaid >= inv.totalAmount ? 'paid' : 'partially_paid';
        await (_db.update(_db.localInvoices)..where((t) => t.id.equals(inv.id))).write(
          LocalInvoicesCompanion(
            amountPaid: Value(newPaid),
            status: Value(newStatus),
            syncStatus: const Value('pending_update'),
            updatedAt: Value(DateTime.now()),
          ),
        );

        remainingToAllocate -= allocated;
      }
    }

    // 3. إذا تبقى فائض أو لا توجد فواتير معتمدة مستحقة (دفعة مقدمة / رصيد دائن)
    if (remainingToAllocate > 0.001 || createdPaymentIds.isEmpty) {
      final pId = const Uuid().v4();
      createdPaymentIds.add(pId);
      final fallbackInvoiceId = confirmedInvoices.isNotEmpty ? confirmedInvoices.last.id : 'advance';
      primaryInvoiceId ??= fallbackInvoiceId;

      await _db.into(_db.localPayments).insert(
        LocalPaymentsCompanion.insert(
          id: Value(pId),
          invoiceId: fallbackInvoiceId,
          customerId: Value(customerId),
          amount: Value(remainingToAllocate),
          paymentMethod: Value(paymentMethod),
          referenceNumber: Value(referenceNumber),
          notes: Value(notes != null && notes.isNotEmpty ? notes : 'دفعة مقدمة / رصيد دائن تحت الحساب'),
          syncStatus: const Value('pending_insert'),
        ),
      );
    }

    // 4. تسجيل النقدية في الخزينة النشطة (CashFlowEngine)
    if (_erpDb != null) {
      try {
        final cashEngine = stream_pay_cash_flow_engine.CashFlowEngine(_erpDb);
        await cashEngine.recordTransaction(
          type: 'in',
          amount: amount,
          category: 'customer_payment',
          notes: 'سداد دفعة من العميل: $customerName (${_formatPaymentMethod(paymentMethod)}) ${notes ?? ""}'.trim(),
        );
      } catch (e) {
        debugPrint('[CustomerRepository] CashFlowEngine warning: $e');
      }
    }

    _triggerSync();

    return {
      'id': createdPaymentIds.isNotEmpty ? createdPaymentIds.first : const Uuid().v4(),
      'payment_ids': createdPaymentIds,
      'customer_id': customerId,
      'invoice_id': primaryInvoiceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'notes': notes,
    };
  }

  static String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً (كاش)';
      case 'instapay':
        return 'إنستاباي (InstaPay)';
      case 'vodafone_cash':
        return 'فودافون كاش / محفظة';
      case 'pos_card':
        return 'بطاقة بنكية (فيزا)';
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'cheque':
        return 'شيك بنكي';
      default:
        return method;
    }
  }

  // ─── CRUD Operations ───────────────────────────────────────────────────────

  /// Get all customers (basic list without financials — fast).
  Future<List<Map<String, dynamic>>> getCustomersBasic({
    String? search,
    int limit = 200,
  }) async {
    final query = _db.select(_db.localCustomers)
      ..where((t) => t.syncStatus.isNotValue('pending_delete') & t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)])
      ..limit(limit);

    final response = await query.get();
    var result = response.map((c) => {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'address': c.address,
      'type': c.type,
      'notes': c.notes,
      'created_at': c.createdAt.toIso8601String(),
    }).toList();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final phone = (c['phone'] ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    }
    return result;
  }

  /// Get customer with projects (legacy method for compatibility).
  Future<Map<String, dynamic>?> getCustomerWithProjects(String customerId) async {
    return getCustomerProfile(customerId);
  }

  /// Create a customer.
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async {
    final id = data['id'] ?? const Uuid().v4();
    await _db.into(_db.localCustomers).insert(
      LocalCustomersCompanion.insert(
        id: Value(id),
        name: data['name'] ?? 'بدون اسم',
        phone: Value(data['phone']),
        address: Value(data['address'] ?? data['location']),
        type: Value(data['type']),
        notes: Value(data['notes']),
      ),
    );
    _triggerSync();
    data['id'] = id;
    return data;
  }

  /// Update a customer.
  Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> data) async {
    await (_db.update(_db.localCustomers)..where((t) => t.id.equals(id))).write(
      LocalCustomersCompanion(
        name: data['name'] != null ? Value(data['name']) : const Value.absent(),
        phone: data['phone'] != null ? Value(data['phone']) : const Value.absent(),
        address: data.containsKey('address')
            ? Value(data['address'])
            : data.containsKey('location')
                ? Value(data['location'])
                : const Value.absent(),
        type: data['type'] != null ? Value(data['type']) : const Value.absent(),
        notes: data['notes'] != null ? Value(data['notes']) : const Value.absent(),
        syncStatus: const Value('pending_update'),
        updatedAt: Value(DateTime.now()),
      ),
    );
    _triggerSync();
    return data;
  }

  /// Delete a customer (soft delete).
  Future<void> deleteCustomer(String id) async {
    await (_db.update(_db.localCustomers)..where((t) => t.id.equals(id))).write(
      const LocalCustomersCompanion(
        syncStatus: Value('pending_delete'),
        isDeleted: Value(true),
      ),
    );
    _triggerSync();
  }

  void _triggerSync() {
    _syncEngine.sync();
  }

  String _translatePaymentMethod(String method) {
    switch (method) {
      case 'cash': return 'نقدي';
      case 'bank_transfer': return 'تحويل بنكي';
      case 'credit_card': return 'بطاقة ائتمان';
      case 'cheque': return 'شيك';
      default: return method;
    }
  }
}
