import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intl;

/// 🌟 Professional Premium Arabic RTL PDF Invoice Generator.
/// Redesigned with a modern two-tone header, status watermark,
/// colored totals block, and clean typography.
class InvoicePdfGenerator {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;

  // ─── Brand Colors ──────────────────────────────────────────
  static final PdfColor _brandDark   = PdfColor.fromHex('#1A1A2E');
  static final PdfColor _brandAccent = PdfColor.fromHex('#C9A84C'); // ذهبي
  static final PdfColor _brandBlue   = PdfColor.fromHex('#16213E');
  static final PdfColor _successGreen = PdfColor.fromHex('#16A34A');
  static final PdfColor _errorRed    = PdfColor.fromHex('#DC2626');
  static final PdfColor _lightGray   = PdfColor.fromHex('#F8FAFC');
  static final PdfColor _borderGray  = PdfColor.fromHex('#E2E8F0');
  static final PdfColor _textMuted   = PdfColor.fromHex('#64748B');

  static Future<void> _loadFonts() async {
    if (_arabicFont != null) return;
    try {
      final reg  = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      _arabicFont     = pw.Font.ttf(reg);
      _arabicBoldFont = pw.Font.ttf(bold);
    } catch (_) {
      _arabicFont = _arabicBoldFont = null;
    }
  }

  static Future<Uint8List> generate({
    required Map<String, dynamic> invoice,
    String? shopName,
    String? shopPhone,
    String? shopAddress,
  }) async {
    await _loadFonts();

    final pdf         = pw.Document();
    final dateFmt     = intl.DateFormat('yyyy/MM/dd', 'ar');
    final timeFmt     = intl.DateFormat('HH:mm', 'ar');
    final numberFmt   = intl.NumberFormat('#,##0.00', 'ar');

    final invoiceNumber = invoice['invoice_number'] ?? '';
    final customer      = invoice['customer'] as Map<String, dynamic>?;
    final items         = invoice['invoice_items'] as List? ?? [];
    final payments      = invoice['payments'] as List? ?? [];
    final status        = invoice['status'] ?? 'draft';
    final invoiceType   = invoice['invoice_type'] ?? 'sale';
    final isReturn      = invoiceType == 'return';

    final createdAt = invoice['created_at'] != null
        ? DateTime.parse(invoice['created_at']).toLocal()
        : DateTime.now();
    final confirmedAt = invoice['confirmed_at'] != null
        ? DateTime.parse(invoice['confirmed_at']).toLocal()
        : null;

    final totalAmount = (invoice['total_amount'] as num?)?.toDouble() ?? 0;
    final paidAmount  = (invoice['paid_amount'] as num?)?.toDouble() ?? 0;
    final dueAmount   = (totalAmount - paidAmount).abs();

    // ─── Text Styles ──────────────────────────────────────────
    pw.TextStyle s(double size, {
      PdfColor? color,
      pw.FontWeight weight = pw.FontWeight.normal,
    }) =>
        pw.TextStyle(
          font: weight == pw.FontWeight.bold ? _arabicBoldFont : _arabicFont,
          fontBold: _arabicBoldFont,
          fontSize: size,
          color: color ?? _brandDark,
        );

    final sBase  = s(9);
    final sBold  = s(9, weight: pw.FontWeight.bold);
    final sSmall = s(7.5, color: _textMuted);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: pw.EdgeInsets.zero,
        header: (_) => _buildPremiumHeader(
          invoiceNumber: invoiceNumber,
          createdAt: createdAt,
          confirmedAt: confirmedAt,
          status: status,
          isReturn: isReturn,
          shopName: shopName ?? 'السويدي للديكور',
          shopPhone: shopPhone,
          shopAddress: shopAddress,
          dateFmt: dateFmt,
          timeFmt: timeFmt,
          s: s,
        ),
        footer: (ctx) => _buildFooter(ctx, sSmall, invoiceNumber),
        build: (_) => [
          pw.SizedBox(height: 16),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ─── Customer Info Card ──────────────────────
                _buildCustomerCard(customer, s, sBold),
                pw.SizedBox(height: 16),

                // ─── Items Table ──────────────────────────────
                _buildSectionTitle('بيان الأصناف والخدمات', s),
                pw.SizedBox(height: 6),
                _buildItemsTable(items, sBase, sBold, numberFmt, isReturn),
                pw.SizedBox(height: 20),

                // ─── Payments + Totals Side by Side ──────────
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Payments (right side, RTL)
                    if (payments.isNotEmpty)
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('سجل الدفعات المستلمة', s),
                            pw.SizedBox(height: 6),
                            _buildPaymentsTable(payments, sBase, sBold, dateFmt, numberFmt),
                          ],
                        ),
                      ),
                    if (payments.isNotEmpty) pw.SizedBox(width: 16),
                    // Totals (left side)
                    pw.Expanded(
                      flex: 4,
                      child: _buildTotalsCard(
                        total: totalAmount,
                        paid: paidAmount,
                        due: dueAmount,
                        status: status,
                        s: s,
                        numberFmt: numberFmt,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 28),
                _buildSignatureBlock(s),
                pw.SizedBox(height: 20),
                _buildNoteBlock(s, sSmall),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateThermal({
    required Map<String, dynamic> invoice,
    String? shopName,
    String? shopPhone,
    String? shopAddress,
  }) async {
    await _loadFonts();

    final pdf         = pw.Document();
    final dateFmt     = intl.DateFormat('yyyy/MM/dd', 'ar');
    final timeFmt     = intl.DateFormat('HH:mm', 'ar');
    final numberFmt   = intl.NumberFormat('#,##0.00', 'ar');

    final invoiceNumber = invoice['invoice_number'] ?? '';
    final customer      = invoice['customer'] as Map<String, dynamic>?;
    final items         = invoice['invoice_items'] as List? ?? [];
    final payments      = invoice['payments'] as List? ?? [];
    final status        = invoice['status'] ?? 'draft';
    final invoiceType   = invoice['invoice_type'] ?? 'sale';
    final isReturn      = invoiceType == 'return';

    final createdAt = invoice['created_at'] != null
        ? DateTime.parse(invoice['created_at']).toLocal()
        : DateTime.now();

    final totalAmount = (invoice['total_amount'] as num?)?.toDouble() ?? 0;
    final paidAmount  = (invoice['paid_amount'] as num?)?.toDouble() ?? 0;
    final dueAmount   = (totalAmount - paidAmount).abs();
    final discountAmount = (invoice['discount_amount'] as num?)?.toDouble() ?? 0;
    final taxAmount = (invoice['tax_amount'] as num?)?.toDouble() ?? 0;

    // ─── Text Styles ──────────────────────────────────────────
    pw.TextStyle s(double size, {
      PdfColor? color,
      pw.FontWeight weight = pw.FontWeight.normal,
    }) =>
        pw.TextStyle(
          font: weight == pw.FontWeight.bold ? _arabicBoldFont : _arabicFont,
          fontBold: _arabicBoldFont,
          fontSize: size,
          color: color ?? _brandDark,
        );

    final sBold  = s(8, weight: pw.FontWeight.bold);
    final sSmall = s(7, color: _textMuted);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginTop: 6 * PdfPageFormat.mm,
          marginBottom: 6 * PdfPageFormat.mm,
          marginLeft: 4 * PdfPageFormat.mm,
          marginRight: 4 * PdfPageFormat.mm,
        ),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // --- Header ---
              pw.Center(
                child: pw.Text(
                  shopName ?? 'السويدي للديكور',
                  style: s(11, weight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (shopAddress != null && shopAddress.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    shopAddress,
                    style: s(7, color: _textMuted),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              if (shopPhone != null && shopPhone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    'تليفون: $shopPhone',
                    style: s(7, color: _textMuted),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(color: _borderGray, thickness: 1),
              pw.SizedBox(height: 4),

              // --- Invoice Details ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('رقم الفاتورة:', style: sBold),
                  pw.Text(invoiceNumber, style: sBold),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('التاريخ:', style: sSmall),
                  pw.Text('${dateFmt.format(createdAt)} ${timeFmt.format(createdAt)}', style: sSmall),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('النوع:', style: sSmall),
                  pw.Text(isReturn ? 'فاتورة مرتجع' : 'فاتورة بيع', style: sSmall),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('الحالة:', style: sSmall),
                  pw.Text(_statusArabic(status, isReturn), style: s(7.5, color: _statusColor(status, isReturn), weight: pw.FontWeight.bold)),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Divider(color: _borderGray, thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Text(
                'العميل: ${customer != null && (customer['name']?.toString().trim().isNotEmpty ?? false) ? customer['name'] : 'عميل نقدي (كاش)'}',
                style: sBold,
              ),
              if (customer != null && customer['phone'] != null && customer['phone'].toString().isNotEmpty)
                pw.Text('الهاتف: ${customer['phone']}', style: sSmall),
              if (customer != null && customer['location'] != null && customer['location'].toString().isNotEmpty)
                pw.Text('العنوان: ${customer['location']}', style: sSmall),


              pw.SizedBox(height: 6),
              pw.Divider(color: _brandDark, thickness: 1),
              pw.SizedBox(height: 4),
              pw.Center(child: pw.Text('بيان الأصناف', style: s(8.5, weight: pw.FontWeight.bold))),
              pw.SizedBox(height: 4),
              pw.Divider(color: _borderGray, thickness: 0.5),
              pw.SizedBox(height: 6),

              // --- Items list ---
              ...items.map((item) {
                final String pName = item['product_name'] ?? 'صنف';
                final double qty = (item['qty'] as num?)?.toDouble() ?? (item['quantity'] as num?)?.toDouble() ?? 1.0;
                final double price = (item['final_unit_price'] as num?)?.toDouble() ?? (item['unit_price'] as num?)?.toDouble() ?? 0.0;
                final double total = (item['final_line_total'] as num?)?.toDouble() ?? (item['total_price'] as num?)?.toDouble() ?? 0.0;
                final String unit = item['unit'] ?? '';

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Item Name
                      pw.Text(
                        pName,
                        style: sBold,
                      ),
                      pw.SizedBox(height: 2),
                      // Details
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${qty.toStringAsFixed(1)} $unit × ${numberFmt.format(price)} ج.م',
                            style: sSmall,
                          ),
                          pw.Text(
                            '${numberFmt.format(total)} ج.م',
                            style: sBold,
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Divider(color: _borderGray, thickness: 0.5),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 4),

              // --- Totals ---
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: _lightGray,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: _borderGray, width: 0.8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('الإجمالي الفرعي:', style: sSmall),
                        pw.Text('${numberFmt.format(totalAmount - taxAmount + discountAmount)} ج.م', style: sSmall),
                      ],
                    ),
                    if (discountAmount > 0) ...[
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('الخصم:', style: sSmall),
                          pw.Text('-${numberFmt.format(discountAmount)} ج.م', style: sSmall.copyWith(color: _errorRed)),
                        ],
                      ),
                    ],
                    if (taxAmount > 0) ...[
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('الضريبة:', style: sSmall),
                          pw.Text('+${numberFmt.format(taxAmount)} ج.م', style: sSmall),
                        ],
                      ),
                    ],
                    pw.Divider(color: _borderGray, thickness: 0.5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('صافي الفاتورة:', style: sBold),
                        pw.Text('${numberFmt.format(totalAmount)} ج.م', style: s(9.5, weight: pw.FontWeight.bold, color: _brandBlue)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المدفوع:', style: sSmall),
                        pw.Text('${numberFmt.format(paidAmount)} ج.م', style: sSmall.copyWith(color: _successGreen)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المتبقي:', style: sSmall),
                        pw.Text('${numberFmt.format(dueAmount)} ج.م', style: sSmall.copyWith(color: dueAmount > 0 ? _brandAccent : _textMuted)),
                      ],
                    ),
                  ],
                ),
              ),

              if (payments.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Center(child: pw.Text('الدفعات المستلمة', style: sBold)),
                pw.SizedBox(height: 4),
                ...payments.map((p) {
                  final double amt = (p['amount'] as num?)?.toDouble() ?? 0.0;
                  final DateTime pDate = p['created_at'] != null ? DateTime.parse(p['created_at']).toLocal() : DateTime.now();
                  final method = _translatePaymentMethod(p['payment_method']?.toString());
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${dateFmt.format(pDate)} ($method)', style: sSmall),
                        pw.Text('${numberFmt.format(amt)} ج.م', style: sSmall.copyWith(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],

              pw.SizedBox(height: 10),
              pw.Divider(color: _brandDark, thickness: 1),
              pw.SizedBox(height: 6),
              if (invoiceNumber.isNotEmpty) ...[
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: invoiceNumber,
                    height: 28,
                    width: 130,
                    drawText: false,
                  ),
                ),
                pw.SizedBox(height: 4),
              ],
              pw.Center(
                child: pw.Text(
                  'الاسترجاع والاستبدال خلال 14 يوماً بموجب أصل الفاتورة',
                  style: s(6.5, color: _textMuted),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'شكراً لزيارتكم ونسعد بخدمتكم دائماً',
                  style: sBold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'نظام السويدي للديكور لإدارة المبيعات',
                  style: sSmall,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              // مسافة تغذية للورق لضمان عمل القاطع التلقائي بعد النص دون قصه (Xprinter Auto-Cutter)
              pw.SizedBox(height: 10 * PdfPageFormat.mm),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── Premium Header with Two-Tone Design ──────────────────
  static pw.Widget _buildPremiumHeader({
    required String invoiceNumber,
    required DateTime createdAt,
    required DateTime? confirmedAt,
    required String status,
    required bool isReturn,
    required String shopName,
    required String? shopPhone,
    required String? shopAddress,
    required intl.DateFormat dateFmt,
    required intl.DateFormat timeFmt,
    required pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s,
  }) {
    final statusLabel = _statusArabic(status, isReturn);
    final statusColor = _statusColor(status, isReturn);

    return pw.Column(
      children: [
        // ── Top dark band ──
        pw.Container(
          height: 70,
          decoration: pw.BoxDecoration(color: _brandBlue),
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Shop info (right in RTL)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      shopName,
                      style: s(20,
                          color: _brandAccent, weight: pw.FontWeight.bold),
                    ),
                    if (shopAddress != null)
                      pw.Text(shopAddress,
                          style: s(8, color: PdfColors.white)),
                    if (shopPhone != null)
                      pw.Text('📞 $shopPhone',
                          style: s(8, color: PdfColors.white)),
                  ],
                ),
                // Invoice tag (left)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      isReturn ? 'فاتورة مرتجع' : 'فاتورة مبيعات / سند قبض',
                      style: s(11, color: PdfColors.white, weight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    // Status badge
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: statusColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        statusLabel,
                        style: s(8, color: PdfColors.white, weight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Gold accent stripe ──
        pw.Container(height: 3, color: _brandAccent),

        // ── Invoice meta bar ──
        pw.Container(
          color: _lightGray,
          padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Right: invoice number
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: _brandAccent,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'رقم الفاتورة:  $invoiceNumber',
                      style: s(10,
                          color: PdfColors.white, weight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Left: dates
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'تاريخ الإصدار:  ${dateFmt.format(createdAt)}  ${timeFmt.format(createdAt)}',
                    style: s(8, color: _textMuted),
                  ),
                  if (confirmedAt != null)
                    pw.Text(
                      'تاريخ الاعتماد:  ${dateFmt.format(confirmedAt)}',
                      style: s(8, color: _successGreen, weight: pw.FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ),

        pw.Container(height: 1, color: _borderGray),
      ],
    );
  }

  // ─── Section Title with gold left bar ─────────────────────
  static pw.Widget _buildSectionTitle(
      String title,
      pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s) {
    return pw.Row(
      children: [
        pw.Container(width: 3, height: 16, color: _brandAccent),
        pw.SizedBox(width: 8),
        pw.Text(title,
            style: s(10, color: _brandBlue, weight: pw.FontWeight.bold)),
      ],
    );
  }

  // ─── Customer Info Card ────────────────────────────────────
  static pw.Widget _buildCustomerCard(
    Map<String, dynamic>? customer,
    pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s,
    pw.TextStyle sBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        border: pw.Border(
          right: pw.BorderSide(color: _brandAccent, width: 3),
          left: pw.BorderSide(color: _borderGray),
          top: pw.BorderSide(color: _borderGray),
          bottom: pw.BorderSide(color: _borderGray),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('بيانات العميل',
                    style: s(9, color: _brandAccent, weight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(
                  customer != null && (customer['name']?.toString().trim().isNotEmpty ?? false)
                      ? customer['name']
                      : 'عميل نقدي (كاش)',
                  style: s(13, color: _brandDark, weight: pw.FontWeight.bold),
                ),
                if (customer?['phone'] != null)
                  pw.Text('هاتف: ${customer!['phone']}',
                      style: s(9, color: _textMuted)),
                if (customer?['location'] != null)
                  pw.Text('العنوان: ${customer!['location']}',
                      style: s(9, color: _textMuted)),
              ],
            ),
          ),
          // Decorative icon placeholder
          pw.Container(
            width: 44,
            height: 44,
            decoration: pw.BoxDecoration(
              color: _brandAccent.shade(0.2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(22)),
            ),
            child: pw.Center(
              child: pw.Text(
                customer?['name']?.toString().isNotEmpty == true
                    ? customer!['name'].toString()[0]
                    : '؟',
                style: s(18, color: _brandDark, weight: pw.FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Items Table ──────────────────────────────────────────
  static pw.Widget _buildItemsTable(
    List items,
    pw.TextStyle base,
    pw.TextStyle bold,
    intl.NumberFormat fmt,
    bool isReturn,
  ) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _borderGray, width: 0.5),
        bottom: pw.BorderSide(color: _borderGray),
        left: pw.BorderSide(color: _borderGray),
        right: pw.BorderSide(color: _borderGray),
        top: pw.BorderSide(color: _borderGray),
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(22),
        1: pw.FlexColumnWidth(4),
        2: pw.FixedColumnWidth(45),
        3: pw.FixedColumnWidth(38),
        4: pw.FixedColumnWidth(60),
        5: pw.FixedColumnWidth(68),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _brandBlue),
          children: ['م', 'البيان', 'الكمية', 'الوحدة', 'سعر الوحدة', 'الإجمالي']
              .map((h) => _cell(h, bold.copyWith(color: PdfColors.white, fontSize: 9),
                  align: pw.Alignment.center))
              .toList(),
        ),
        // Rows
        ...List.generate(items.length, (i) {
          final item   = items[i];
          final qty    = (item['quantity'] as num).toDouble();
          final price  = (item['unit_price'] as num).toDouble();
          final total  = (item['final_line_total'] as num).toDouble();
          final isEven = i % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : _lightGray,
            ),
            children: [
              _cell('${i + 1}', base.copyWith(color: _textMuted),
                  align: pw.Alignment.center),
              _cell(item['product_name'] ?? '', base),
              _cell(qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1), base,
                  align: pw.Alignment.center),
              _cell(item['unit'] ?? '', base, align: pw.Alignment.center),
              _cell(fmt.format(price), base, align: pw.Alignment.center),
              _cell(
                fmt.format(total.abs()),
                bold.copyWith(
                    color: isReturn ? _errorRed : _brandBlue, fontSize: 9),
                align: pw.Alignment.center,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(
    String text,
    pw.TextStyle style, {
    pw.Alignment align = pw.Alignment.centerRight,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Text(text, style: style),
    );
  }

  // ─── Payments Table ───────────────────────────────────────
  static pw.Widget _buildPaymentsTable(
    List payments,
    pw.TextStyle base,
    pw.TextStyle bold,
    intl.DateFormat dateFmt,
    intl.NumberFormat fmt,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderGray, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(62),
        1: pw.FlexColumnWidth(2),
        2: pw.FixedColumnWidth(68),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _lightGray),
          children: ['التاريخ', 'وسيلة الدفع', 'المبلغ']
              .map((h) => _cell(h, bold.copyWith(fontSize: 8, color: _brandBlue),
                  align: pw.Alignment.center))
              .toList(),
        ),
        ...payments.map((p) {
          final amt  = (p['amount'] as num).toDouble();
          final date = dateFmt.format(DateTime.parse(p['created_at']).toLocal());
          return pw.TableRow(
            children: [
              _cell(date, base.copyWith(fontSize: 8), align: pw.Alignment.center),
              _cell(_translatePaymentMethod(p['payment_method']),
                  base.copyWith(fontSize: 8), align: pw.Alignment.center),
              _cell(
                fmt.format(amt),
                bold.copyWith(color: _successGreen, fontSize: 9),
                align: pw.Alignment.center,
              ),
            ],
          );
        }),
      ],
    );
  }

  // ─── Totals Card ──────────────────────────────────────────
  static pw.Widget _buildTotalsCard({
    required double total,
    required double paid,
    required double due,
    required String status,
    required pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s,
    required intl.NumberFormat numberFmt,
  }) {
    final isPaid = due <= 0;
    final dueColor = isPaid ? _successGreen : _errorRed;

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _borderGray),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _brandBlue,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('ملخص المبالغ',
                    style: s(10, color: PdfColors.white, weight: pw.FontWeight.bold)),
              ],
            ),
          ),
          // Rows
          _totalRow('إجمالي الفاتورة', numberFmt.format(total), s,
              isHeader: true),
          _totalRow('إجمالي المدفوع', numberFmt.format(paid), s,
              valueColor: _successGreen),
          pw.Container(height: 1, color: _brandAccent),
          // Due amount with colored bg
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: pw.BoxDecoration(
              color: isPaid
                  ? PdfColor.fromHex('#F0FDF4')
                  : PdfColor.fromHex('#FEF2F2'),
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  isPaid ? '✓ مسدد بالكامل' : 'المتبقي المستحق',
                  style: s(10, color: dueColor, weight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${numberFmt.format(due)} ج.م',
                  style: s(13, color: dueColor, weight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value,
    pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s, {
    bool isHeader = false,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: s(9, color: _textMuted,
                  weight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            '$value ج.م',
            style: s(10,
                color: valueColor ?? _brandDark,
                weight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ─── Signature Block ──────────────────────────────────────
  static pw.Widget _buildSignatureBlock(
      pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signBox('توقيع العميل واستلامه', s),
        _signBox('توقيع المحاسب / الإدارة', s),
        _signBox('مراجعة واعتماد', s),
      ],
    );
  }

  static pw.Widget _signBox(
      String label,
      pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label,
            style: s(8, color: _textMuted, weight: pw.FontWeight.bold)),
        pw.SizedBox(height: 24),
        pw.Container(
          width: 120,
          height: 1,
          decoration: pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: _brandAccent, width: 1.5,
                    style: pw.BorderStyle.dashed)),
          ),
        ),
      ],
    );
  }

  // ─── Note Block ───────────────────────────────────────────
  static pw.Widget _buildNoteBlock(
    pw.TextStyle Function(double, {PdfColor? color, pw.FontWeight weight}) s,
    pw.TextStyle sSmall,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFFBEB'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColor.fromHex('#FCD34D'), width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ملاحظة: ',
              style: s(8, color: PdfColor.fromHex('#92400E'), weight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(
              'هذه الفاتورة وثيقة رسمية معتمدة. يُرجى الاحتفاظ بها للمراجعة. '
              'في حال وجود أي استفسار يرجى التواصل مع الإدارة خلال 7 أيام من تاريخ الإصدار.',
              style: sSmall.copyWith(color: PdfColor.fromHex('#78350F')),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────
  static pw.Widget _buildFooter(
      pw.Context ctx, pw.TextStyle sSmall, String invNumber) {
    return pw.Column(
      children: [
        pw.Container(
          height: 3,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(colors: [_brandBlue, _brandAccent, _brandBlue]),
          ),
        ),
        pw.Container(
          color: _brandBlue,
          padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 5),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'السويدي للديكور والمقاولات',
                style: sSmall.copyWith(color: PdfColors.white),
              ),
              pw.Text(
                'فاتورة $invNumber  |  صفحة ${ctx.pageNumber}/${ctx.pagesCount}',
                style: sSmall.copyWith(color: _brandAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────
  static String _statusArabic(String status, bool isReturn) {
    if (isReturn) return 'مرتجع';
    switch (status) {
      case 'draft':         return 'مسودة';
      case 'confirmed':     return 'معتمدة — بانتظار السداد';
      case 'partially_paid': return 'مدفوعة جزئياً';
      case 'paid':          return 'مدفوعة بالكامل ✓';
      default:              return status;
    }
  }

  static PdfColor _statusColor(String status, bool isReturn) {
    if (isReturn) return _errorRed;
    switch (status) {
      case 'paid':           return _successGreen;
      case 'partially_paid': return PdfColor.fromHex('#D97706');
      case 'confirmed':      return PdfColor.fromHex('#1D4ED8');
      default:               return _textMuted;
    }
  }

  static String _translatePaymentMethod(String? method) {
    switch (method) {
      case 'cash':          return 'نقدي';
      case 'bank_transfer': return 'تحويل بنكي';
      case 'credit_card':   return 'بطاقة ائتمان';
      case 'cheque':        return 'شيك';
      case 'instapay':      return 'إنستاباي';
      case 'vodafone_cash': return 'فودافون كاش';
      default:              return method ?? '';
    }
  }
}
