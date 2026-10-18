import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intl;

/// Professional Arabic RTL PDF generator for Customer Account Ledger (كشف الحساب).
class CustomerLedgerPdfGenerator {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;

  static Future<void> _loadFonts() async {
    if (_arabicFont != null) return;
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _arabicFont = pw.Font.ttf(fontData);
      final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      _arabicBoldFont = pw.Font.ttf(boldData);
    } catch (_) {
      _arabicFont = null;
      _arabicBoldFont = null;
    }
  }

  static Future<Uint8List> generate({
    required Map<String, dynamic> customer,
    required List<Map<String, dynamic>> ledgerEntries,
    String? shopName,
    String? shopPhone,
    String? shopAddress,
  }) async {
    await _loadFonts();

    final pdf = pw.Document();
    final dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');
    final now = dateFormat.format(DateTime.now());

    final name = customer['name'] ?? '';
    final phone = customer['phone'] ?? '';
    final address = customer['address'] ?? '';
    final totalSales = (customer['total_sales'] as num?)?.toDouble() ?? 0.0;
    final totalPaid = (customer['total_paid'] as num?)?.toDouble() ?? 0.0;
    final totalDebt = (customer['total_debt'] as num?)?.toDouble() ?? 0.0;

    final baseStyle = pw.TextStyle(
      font: _arabicFont,
      fontBold: _arabicBoldFont,
      fontSize: 9,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: pw.FontWeight.bold);
    final headerStyle = baseStyle.copyWith(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#DAA520'),
    );
    final subHeaderStyle = baseStyle.copyWith(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#1a1a1a'),
    );
    final smallStyle = baseStyle.copyWith(fontSize: 7.5, color: PdfColors.grey700);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.symmetric(horizontal: 35, vertical: 35),
        header: (context) => _buildHeader(
          shopName: shopName ?? 'السويدي للديكور',
          shopPhone: shopPhone,
          shopAddress: shopAddress,
          reportDate: now,
          headerStyle: headerStyle,
          baseStyle: baseStyle,
          smallStyle: smallStyle,
        ),
        footer: (context) => _buildFooter(
          context: context,
          baseStyle: smallStyle,
        ),
        build: (context) => [
          pw.SizedBox(height: 16),

          // ── Customer Summary Card ──
          _buildCustomerSummary(
            name: name,
            phone: phone,
            address: address,
            totalSales: totalSales,
            totalPaid: totalPaid,
            totalDebt: totalDebt,
            baseStyle: baseStyle,
            boldStyle: boldStyle,
            subHeaderStyle: subHeaderStyle,
          ),

          pw.SizedBox(height: 20),

          // ── Ledger Table ──
          pw.Text('تفاصيل الحركات المالية', style: subHeaderStyle),
          pw.SizedBox(height: 8),
          _buildLedgerTable(
            entries: ledgerEntries,
            baseStyle: baseStyle,
            boldStyle: boldStyle,
            dateFormat: dateFormat,
          ),

          pw.SizedBox(height: 24),

          // ── Closing Balance Row ──
          _buildClosingBalance(
            totalDebt: totalDebt,
            baseStyle: baseStyle,
            boldStyle: boldStyle,
          ),

          pw.SizedBox(height: 32),

          // ── Signature Block ──
          _buildSignatureBlock(baseStyle: baseStyle),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required String shopName,
    String? shopPhone,
    String? shopAddress,
    required String reportDate,
    required pw.TextStyle headerStyle,
    required pw.TextStyle baseStyle,
    required pw.TextStyle smallStyle,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Shop Info (Right side in RTL)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(shopName, style: headerStyle),
                if (shopAddress != null)
                  pw.Text(shopAddress, style: smallStyle),
                if (shopPhone != null)
                  pw.Text('هاتف: $shopPhone', style: smallStyle),
              ],
            ),
            // Report Info (Left side)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#DAA520'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(
                    'كشف حساب عميل',
                    style: baseStyle.copyWith(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('تاريخ الإصدار: $reportDate', style: smallStyle),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 2,
          color: PdfColor.fromHex('#DAA520'),
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerSummary({
    required String name,
    required String phone,
    required String address,
    required double totalSales,
    required double totalPaid,
    required double totalDebt,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required pw.TextStyle subHeaderStyle,
  }) {
    final fmt = intl.NumberFormat('#,##0.00', 'ar');

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Customer Info
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('بيانات العميل', style: subHeaderStyle),
                pw.SizedBox(height: 6),
                pw.Text('الاسم: $name', style: boldStyle),
                if (phone.isNotEmpty) pw.Text('التليفون: $phone', style: baseStyle),
                if (address.isNotEmpty) pw.Text('العنوان: $address', style: baseStyle),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          // Financial Summary
          pw.Expanded(
            flex: 3,
            child: pw.Row(
              children: [
                _buildFinancialCell(
                  label: 'إجمالي المبيعات',
                  value: '${fmt.format(totalSales)} ج.م',
                  color: PdfColor.fromHex('#1e3a5f'),
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
                pw.SizedBox(width: 8),
                _buildFinancialCell(
                  label: 'إجمالي المسدّد',
                  value: '${fmt.format(totalPaid)} ج.م',
                  color: PdfColor.fromHex('#065f46'),
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
                pw.SizedBox(width: 8),
                _buildFinancialCell(
                  label: 'الرصيد المستحق',
                  value: '${fmt.format(totalDebt)} ج.م',
                  color: totalDebt > 0 ? PdfColor.fromHex('#7f1d1d') : PdfColor.fromHex('#065f46'),
                  baseStyle: baseStyle,
                  boldStyle: boldStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialCell({
    required String label,
    required String value,
    required PdfColor color,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(value, style: boldStyle.copyWith(color: PdfColors.white, fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text(label, style: baseStyle.copyWith(color: PdfColors.white, fontSize: 7.5)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildLedgerTable({
    required List<Map<String, dynamic>> entries,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required intl.DateFormat dateFormat,
  }) {
    final fmt = intl.NumberFormat('#,##0.00', 'ar');
    final headerBg = PdfColor.fromHex('#2E3B4E');

    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.centerRight,
      headerDecoration: pw.BoxDecoration(color: headerBg),
      headerHeight: 26,
      cellHeight: 22,
      headerStyle: boldStyle.copyWith(color: PdfColors.white, fontSize: 9),
      cellStyle: baseStyle,
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey50),
      columnWidths: {
        0: const pw.FixedColumnWidth(20),
        1: const pw.FixedColumnWidth(62),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FixedColumnWidth(65),
        4: const pw.FixedColumnWidth(65),
        5: const pw.FixedColumnWidth(70),
      },
      headers: ['م', 'التاريخ', 'البيان', 'مدين (فواتير)', 'دائن (مسدد)', 'الرصيد'],
      data: List<List<String>>.generate(entries.length, (i) {
        final e = entries[i];
        final date = e['date'] != null
            ? dateFormat.format(DateTime.parse(e['date'] as String))
            : '';
        final debit = (e['debit'] as double?) ?? 0.0;
        final credit = (e['credit'] as double?) ?? 0.0;
        final balance = (e['balance'] as double?) ?? 0.0;
        return [
          '${i + 1}',
          date,
          e['description'] as String? ?? '',
          debit > 0 ? fmt.format(debit) : '—',
          credit > 0 ? fmt.format(credit) : '—',
          fmt.format(balance),
        ];
      }),
    );
  }

  static pw.Widget _buildClosingBalance({
    required double totalDebt,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
  }) {
    final fmt = intl.NumberFormat('#,##0.00', 'ar');
    final isCredit = totalDebt <= 0;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: isCredit ? PdfColor.fromHex('#f0fdf4') : PdfColor.fromHex('#fef2f2'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(
          color: isCredit ? PdfColor.fromHex('#16a34a') : PdfColor.fromHex('#dc2626'),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            isCredit ? 'الحساب مسدد — لا يوجد رصيد مستحق' : 'إجمالي الرصيد المستحق على العميل',
            style: boldStyle.copyWith(
              color: isCredit ? PdfColor.fromHex('#15803d') : PdfColor.fromHex('#b91c1c'),
              fontSize: 11,
            ),
          ),
          pw.Text(
            '${fmt.format(totalDebt.abs())} ج.م',
            style: boldStyle.copyWith(
              color: isCredit ? PdfColor.fromHex('#15803d') : PdfColor.fromHex('#b91c1c'),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBlock({required pw.TextStyle baseStyle}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _signatureBox('توقيع العميل', baseStyle),
        _signatureBox('توقيع المحاسب / الإدارة', baseStyle),
        _signatureBox('المراجعة والاعتماد', baseStyle),
      ],
    );
  }

  static pw.Widget _signatureBox(String label, pw.TextStyle baseStyle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 28),
        pw.Container(width: 120, height: 1, color: PdfColors.grey500),
      ],
    );
  }

  static pw.Widget _buildFooter({
    required pw.Context context,
    required pw.TextStyle baseStyle,
  }) {
    return pw.Column(
      children: [
        pw.Container(height: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'تم إصدار هذا الكشف بواسطة تطبيق السويدي للديكور',
              style: baseStyle.copyWith(color: PdfColors.grey600),
            ),
            pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: baseStyle.copyWith(color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
