import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intl;

/// Professional Arabic RTL PDF generator for quotes.
class QuotePdfGenerator {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;

  /// Load Arabic font (Cairo from Google Fonts bundled in assets).
  static Future<void> _loadFonts() async {
    if (_arabicFont != null) return;

    // Use the built-in Helvetica as fallback — for production,
    // bundle an Arabic font file (e.g., Cairo-Regular.ttf)
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _arabicFont = pw.Font.ttf(fontData);

      final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      _arabicBoldFont = pw.Font.ttf(boldData);
    } catch (_) {
      // Fallback: will use default fonts (non-Arabic)
      _arabicFont = null;
      _arabicBoldFont = null;
    }
  }

  /// Generate a professional quote PDF.
  static Future<Uint8List> generate({
    required Map<String, dynamic> quote,
    String? shopName,
    String? shopPhone,
    String? shopAddress,
  }) async {
    await _loadFonts();

    final pdf = pw.Document();
    final dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');

    // Extract data
    final quoteNumber = quote['quote_number'] ?? '';
    final status = quote['status'] ?? 'draft';
    final customer = quote['customer'] as Map<String, dynamic>?;
    final items = quote['quote_items'] as List? ?? [];
    final notes = quote['notes'] as String?;
    final createdAt = quote['created_at'] != null
        ? dateFormat.format(DateTime.parse(quote['created_at']))
        : '';
    final subtotal = (quote['subtotal'] as num?)?.toDouble() ?? 0;
    final discount = (quote['discount_amount'] as num?)?.toDouble() ?? 0;
    final finalTotal = (quote['final_total'] as num?)?.toDouble() ?? 0;

    // Theme
    final baseStyle = pw.TextStyle(
      font: _arabicFont,
      fontBold: _arabicBoldFont,
      fontSize: 10,
    );
    final headerStyle = baseStyle.copyWith(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#6B4226'),
    );
    final subHeaderStyle = baseStyle.copyWith(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#8B6914'),
    );
    final smallStyle = baseStyle.copyWith(fontSize: 8);
    final labelColor = PdfColor.fromHex('#6B4226');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(
          context: context,
          quoteNumber: quoteNumber,
          createdAt: createdAt,
          status: status,
          shopName: shopName ?? 'السويدي للديكور',
          shopPhone: shopPhone,
          shopAddress: shopAddress,
          headerStyle: headerStyle,
          baseStyle: baseStyle,
          smallStyle: smallStyle,
          labelColor: labelColor,
        ),
        footer: (context) => _buildFooter(
          context: context,
          baseStyle: baseStyle,
          smallStyle: smallStyle,
        ),
        build: (context) => [
          // Customer Info
          if (customer != null)
            _buildCustomerSection(
              customer: customer,
              subHeaderStyle: subHeaderStyle,
              baseStyle: baseStyle,
              labelColor: labelColor,
            ),
          pw.SizedBox(height: 20),

          // Items by Category
          _buildItemsByCategory(
            items: items,
            subHeaderStyle: subHeaderStyle,
            baseStyle: baseStyle,
            labelColor: labelColor,
          ),
          pw.SizedBox(height: 16),

          // Totals
          _buildTotals(
            subtotal: subtotal,
            discount: discount,
            finalTotal: finalTotal,
            baseStyle: baseStyle,
            labelColor: labelColor,
          ),

          // Notes
          if (notes != null && notes.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotes(
              notes: notes,
              subHeaderStyle: subHeaderStyle,
              baseStyle: baseStyle,
            ),
          ],

          // Terms
          pw.SizedBox(height: 30),
          _buildTerms(baseStyle: baseStyle, smallStyle: smallStyle),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required pw.Context context,
    required String quoteNumber,
    required String createdAt,
    required String status,
    required String shopName,
    String? shopPhone,
    String? shopAddress,
    required pw.TextStyle headerStyle,
    required pw.TextStyle baseStyle,
    required pw.TextStyle smallStyle,
    required PdfColor labelColor,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Shop info
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(shopName, style: headerStyle),
                  if (shopPhone != null)
                    pw.Text(
                      shopPhone,
                      style: smallStyle.copyWith(color: PdfColors.grey700),
                    ),
                  if (shopAddress != null)
                    pw.Text(
                      shopAddress,
                      style: smallStyle.copyWith(color: PdfColors.grey700),
                    ),
                ],
              ),
            ),
            // Quote number box
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF8E7'),
                border: pw.Border.all(color: labelColor, width: 1.5),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'عرض سعر',
                    style: baseStyle.copyWith(
                      color: labelColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    quoteNumber,
                    style: headerStyle.copyWith(fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('التاريخ: $createdAt', style: smallStyle),
                  pw.Text(
                    'الحالة: ${_statusLabel(status)}',
                    style: smallStyle.copyWith(color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: labelColor, thickness: 2),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildFooter({
    required pw.Context context,
    required pw.TextStyle baseStyle,
    required pw.TextStyle smallStyle,
  }) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'تم إنشاء هذا العرض بواسطة تطبيق السويدي للديكور',
              style: smallStyle.copyWith(color: PdfColors.grey500),
            ),
            pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: smallStyle.copyWith(color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerSection({
    required Map<String, dynamic> customer,
    required pw.TextStyle subHeaderStyle,
    required pw.TextStyle baseStyle,
    required PdfColor labelColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FAFAFA'),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات العميل',
            style: subHeaderStyle.copyWith(fontSize: 11),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _infoBlock(
                'الاسم',
                customer['name'] ?? '',
                baseStyle,
                labelColor,
              ),
              pw.SizedBox(width: 40),
              if (customer['phone'] != null)
                _infoBlock('الهاتف', customer['phone'], baseStyle, labelColor),
              pw.SizedBox(width: 40),
              if (customer['location'] != null)
                _infoBlock(
                  'العنوان',
                  customer['location'],
                  baseStyle,
                  labelColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoBlock(
    String label,
    String value,
    pw.TextStyle style,
    PdfColor labelColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: style.copyWith(fontSize: 8, color: labelColor)),
        pw.Text(value, style: style.copyWith(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildItemsByCategory({
    required List items,
    required pw.TextStyle subHeaderStyle,
    required pw.TextStyle baseStyle,
    required PdfColor labelColor,
  }) {
    // Group items by category
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      final Map<String, dynamic> i = item as Map<String, dynamic>;
      String cat = 'أخرى';
      if (i['product_variant'] != null &&
          i['product_variant']['product'] != null) {
        cat = i['product_variant']['product']['category'] ?? 'أخرى';
      }
      grouped.putIfAbsent(cat, () => []).add(i);
    }

    final children = <pw.Widget>[];

    for (final cat in grouped.keys) {
      children.add(
        pw.Container(
          width: double.infinity,
          margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F0F0F0'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            cat,
            style: subHeaderStyle.copyWith(color: labelColor, fontSize: 11),
          ),
        ),
      );

      children.add(
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerDecoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#6B4226'),
          ),
          headerStyle: baseStyle.copyWith(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
          cellStyle: baseStyle.copyWith(fontSize: 9),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          columnWidths: {
            0: const pw.FixedColumnWidth(25), // #
            1: const pw.FlexColumnWidth(3), // Product
            2: const pw.FlexColumnWidth(2), // Dimensions
            3: const pw.FixedColumnWidth(40), // Qty
            4: const pw.FixedColumnWidth(40), // Unit
            5: const pw.FixedColumnWidth(55), // Unit Price
            6: const pw.FixedColumnWidth(45), // Discount
            7: const pw.FixedColumnWidth(65), // Total
          },
          headers: [
            '#',
            'المنتج',
            'المقاس / الوصف',
            'الكمية',
            'الوحدة',
            'السعر',
            'الخصم',
            'الإجمالي',
          ],
          data: grouped[cat]!.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;

            String dimsStr = '-';
            if (item['product_variant'] != null &&
                item['product_variant']['dimensions'] != null) {
              final dimsRaw = item['product_variant']['dimensions'];
              if (dimsRaw != null) {
                if (dimsRaw is Map) {
                  final l = dimsRaw['length'];
                  final w = dimsRaw['width'];
                  final t = dimsRaw['thickness'];
                  if (l != null && w != null) {
                    dimsStr = '${l}x$w ${t != null ? 'سمك $t' : ''}';
                  }
                } else {
                  dimsStr = dimsRaw.toString();
                }
              }
            } else if (item['notes'] != null &&
                item['notes'].toString().isNotEmpty) {
              dimsStr = item['notes'];
            }

            return [
              '${i + 1}',
              item['product_name'] ?? '',
              dimsStr,
              _num(item['qty']),
              item['unit'] ?? '',
              '${_num(item['unit_price'])} ج',
              '${_num(item['discount'])} ج',
              '${_num(item['final_line_total'])} ج',
            ];
          }).toList(),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('بنود العرض مقسمة', style: subHeaderStyle),
        ...children,
      ],
    );
  }

  static pw.Widget _buildTotals({
    required double subtotal,
    required double discount,
    required double finalTotal,
    required pw.TextStyle baseStyle,
    required PdfColor labelColor,
  }) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Container(
        width: 220,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#FFF8E7'),
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: labelColor, width: 0.5),
        ),
        child: pw.Column(
          children: [
            _totalRow(
              'الإجمالي الفرعي',
              '${subtotal.toStringAsFixed(0)} ج.م',
              baseStyle,
            ),
            if (discount > 0) ...[
              pw.SizedBox(height: 4),
              _totalRow(
                'الخصم',
                '- ${discount.toStringAsFixed(0)} ج.م',
                baseStyle,
                color: PdfColors.red,
              ),
            ],
            pw.Divider(color: labelColor),
            _totalRow(
              'الإجمالي النهائي',
              '${finalTotal.toStringAsFixed(0)} ج.م',
              baseStyle.copyWith(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value,
    pw.TextStyle style, {
    PdfColor? color,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: style.copyWith(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: style.copyWith(color: color, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildNotes({
    required String notes,
    required pw.TextStyle subHeaderStyle,
    required pw.TextStyle baseStyle,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFFDF0'),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.amber, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ملاحظات', style: subHeaderStyle.copyWith(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(notes, style: baseStyle.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTerms({
    required pw.TextStyle baseStyle,
    required pw.TextStyle smallStyle,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F5F5'),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'الشروط والأحكام',
            style: smallStyle.copyWith(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• هذا العرض ساري لمدة 15 يوم من تاريخ الإصدار\n'
            '• الأسعار شاملة ضريبة القيمة المضافة\n'
            '• يتم الدفع 50% مقدم والباقي عند التسليم\n'
            '• مدة التنفيذ تحدد بعد المعاينة',
            style: smallStyle.copyWith(
              color: PdfColors.grey600,
              lineSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  static String _num(dynamic value) {
    if (value == null) return '0';
    if (value is num) {
      return value == value.toInt()
          ? value.toInt().toString()
          : value.toStringAsFixed(2);
    }
    return value.toString();
  }

  static String _statusLabel(String status) {
    const map = {
      'draft': 'مسودة',
      'sent': 'مُرسل',
      'accepted': 'مقبول',
      'rejected': 'مرفوض',
      'expired': 'منتهي',
    };
    return map[status] ?? status;
  }
}
