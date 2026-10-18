import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PriceListPdfGenerator {
  /// Safely downloads an image with a timeout.
  /// If the download fails or offline, returns null.
  static Future<Uint8List?> _downloadImage(String url) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode == 200) {
        final builder = BytesBuilder();
        await for (final chunk in response) {
          builder.add(chunk);
        }
        client.close();
        return builder.takeBytes();
      }
      client.close();
    } catch (e) {
      debugPrint('Failed to download image: $url - Error: $e');
    }
    return null;
  }

  /// Generates and previews/prints the smart catalog PDF.
  static Future<void> generateAndPrint({
    required List<Map<String, dynamic>> products,
    required String catalogTitle,
    required String layoutTemplate, // 'grid' | 'table' | 'text'
    required bool includeImages,
    required bool showPrices,
    required String priceType, // 'net' | 'list' | 'both'
    required bool addCoverPage,
  }) async {
    final pdf = pw.Document();

    // Group products by category
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final p in products) {
      final cat = p['category'] ?? 'غير مصنف';
      grouped.putIfAbsent(cat, () => []).add(p);
    }

    // Load Fonts
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final dateStr = DateFormat('yyyy/MM/dd').format(DateTime.now());

    // Theme Colors
    final primaryColor = PdfColor.fromHex('#DAA520'); // Amber Gold
    final darkCharcoal = PdfColor.fromHex('#1E1A0E'); // Near-black amber

    // 1. Concurrent Image Download
    final Map<String, Uint8List> loadedImages = {};
    if (includeImages) {
      final Set<String> urlsToDownload = {};
      for (final p in products) {
        final url = p['image_url'] as String?;
        if (url != null && url.isNotEmpty) {
          urlsToDownload.add(url);
        }
      }

      if (urlsToDownload.isNotEmpty) {
        debugPrint('[PDF Generator] Downloading ${urlsToDownload.length} images concurrently...');
        final List<Future<void>> tasks = urlsToDownload.map((url) async {
          final bytes = await _downloadImage(url);
          if (bytes != null) {
            loadedImages[url] = bytes;
          }
        }).toList();
        await Future.wait(tasks);
        debugPrint('[PDF Generator] Download finished. Successfully loaded ${loadedImages.length} images.');
      }
    }

    // Helper to draw a product image
    pw.Widget buildProductImage(String? url, double width, double height) {
      if (includeImages && url != null && loadedImages.containsKey(url)) {
        return pw.Container(
          width: width,
          height: height,
          decoration: pw.BoxDecoration(
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          ),
          child: pw.Image(
            pw.MemoryImage(loadedImages[url]!),
            fit: pw.BoxFit.cover,
          ),
        );
      }
      // Return blank container as requested ("الي مالوش صور تتركها فارغة")
      return pw.Container(
        width: width,
        height: height,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.grey200, width: 0.5, style: pw.BorderStyle.dashed),
        ),
      );
    }

    // ─── 1. Cover Page (Optional) ──────────────────────────────────
    if (addCoverPage) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          build: (context) {
            return pw.Container(
              width: double.infinity,
              height: double.infinity,
              color: darkCharcoal,
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Gold top border line
                  pw.Container(
                    height: 5,
                    width: double.infinity,
                    color: primaryColor,
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      // Elegant frame around catalog title
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: primaryColor, width: 2),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              catalogTitle.isNotEmpty ? catalogTitle : 'كتالوج المنتجات الفاخر',
                              style: pw.TextStyle(
                                fontSize: 32,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              'مجموعة مختارة من أحدث التصاميم والبدائل الديكورية',
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey300,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        'معرض السويدي للديكور',
                        style: const pw.TextStyle(
                          fontSize: 20,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'التاريخ: $dateStr',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey400,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        height: 2,
                        width: 80,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // ─── 2. Main Content Pages ─────────────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) {
          if (context.pageNumber == 1 && addCoverPage) {
            return pw.SizedBox.shrink();
          }
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    catalogTitle.isNotEmpty ? catalogTitle : 'كتالوج أسعار المنتجات',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: darkCharcoal,
                    ),
                  ),
                  pw.Text(
                    'التاريخ: $dateStr',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Container(height: 1, color: primaryColor),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (context) {
          if (context.pageNumber == 1 && addCoverPage) {
            return pw.SizedBox.shrink();
          }
          return pw.Column(
            children: [
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'معرض السويدي للديكور',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'صفحة ${context.pageNumber} من ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          );
        },
        build: (context) {
          final List<pw.Widget> content = [];

          for (final cat in grouped.keys) {
            // Category Section Header
            content.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 15, bottom: 10),
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: darkCharcoal,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                width: double.infinity,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      cat,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      '${grouped[cat]!.length} منتجات',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),
            );

            final catProducts = grouped[cat]!;

            // ─── Template A: Premium Grid Cards ──────────────────────
            if (layoutTemplate == 'grid') {
              // We render cards in rows of 2
              final List<pw.Widget> gridRows = [];
              for (int i = 0; i < catProducts.length; i += 2) {
                final p1 = catProducts[i];
                final p2 = (i + 1 < catProducts.length) ? catProducts[i + 1] : null;

                gridRows.add(
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildGridCard(p1, buildProductImage, showPrices, priceType, primaryColor, darkCharcoal)),
                      pw.SizedBox(width: 12),
                      if (p2 != null)
                        pw.Expanded(child: _buildGridCard(p2, buildProductImage, showPrices, priceType, primaryColor, darkCharcoal))
                      else
                        pw.Expanded(child: pw.SizedBox.shrink()),
                    ],
                  ),
                );
                gridRows.add(pw.SizedBox(height: 12));
              }
              content.addAll(gridRows);
            }
            // ─── Template B: Compact Table with Thumbnails ────────────
            else if (layoutTemplate == 'table') {
              final List<List<dynamic>> tableData = [];

              // Headers configuration
              final headers = <String>['الكود'];
              if (includeImages) headers.add('الصورة');
              headers.add('الوصف والمواصفات');
              headers.add('الوحدة');
              if (showPrices) {
                if (priceType == 'list' || priceType == 'both') headers.add('الليستة');
                if (priceType == 'net' || priceType == 'both') headers.add('الصافي');
              }

              for (final product in catProducts) {
                final variants = product['product_variants'] as List? ?? [];
                final pName = product['name'] ?? '';
                final pCode = product['code'] ?? '';
                final pUnit = product['unit_type'] ?? 'قطعة';
                final imgUrl = product['image_url'] as String?;

                final material = product['material'] ?? '';
                final brand = product['brand'] ?? '';
                final specText = [
                  if (brand.toString().isNotEmpty) 'ماركة: $brand',
                  if (material.toString().isNotEmpty) 'خامة: $material'
                ].join(' | ');

                if (variants.isEmpty) {
                  final List<dynamic> row = [pCode];
                  if (includeImages) row.add(buildProductImage(imgUrl, 30, 30));
                  row.add(
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(pName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        if (specText.isNotEmpty) pw.Text(specText, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      ],
                    ),
                  );
                  row.add(pUnit);
                  if (showPrices) {
                    if (priceType == 'list' || priceType == 'both') row.add('0.00');
                    if (priceType == 'net' || priceType == 'both') row.add('0.00');
                  }
                  tableData.add(row);
                } else {
                  for (final v in variants) {
                    final vName = v['variant_name'] != null && v['variant_name'] != 'افتراضي'
                        ? '$pName - ${v['variant_name']}'
                        : pName;
                    final vCode = v['sku'] ?? pCode;
                    final vDim = v['dimensions'] ?? '';

                    double listPrice = 0.0;
                    double netPrice = 0.0;

                    final pricings = v['supplier_product_pricings'] as List? ?? [];
                    if (pricings.isNotEmpty) {
                      final preferred = pricings.where((pr) => (pr as Map)['is_preferred'] == true);
                      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
                      listPrice = (pref['list_price'] as num?)?.toDouble() ?? 0.0;
                      netPrice = (pref['net_price'] as num?)?.toDouble() ?? 0.0;
                      if (netPrice <= 0 && listPrice > 0) netPrice = listPrice;
                    }

                    final variantSpecText = [
                      if (specText.isNotEmpty) specText,
                      if (vDim.toString().isNotEmpty) 'مقاس: $vDim'
                    ].join(' | ');

                    final List<dynamic> row = [vCode];
                    if (includeImages) row.add(buildProductImage(imgUrl, 30, 30));
                    row.add(
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(vName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          if (variantSpecText.isNotEmpty)
                            pw.Text(variantSpecText, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                        ],
                      ),
                    );
                    row.add(v['unit_type'] ?? pUnit);
                    if (showPrices) {
                      if (priceType == 'list' || priceType == 'both') row.add(listPrice.toStringAsFixed(2));
                      if (priceType == 'net' || priceType == 'both') row.add(netPrice.toStringAsFixed(2));
                    }
                    tableData.add(row);
                  }
                }
              }

              // Build Flex column widths
              final columnWidths = <int, pw.TableColumnWidth>{};
              int idx = 0;
              columnWidths[idx++] = const pw.FlexColumnWidth(2); // كود
              if (includeImages) columnWidths[idx++] = const pw.FlexColumnWidth(1.2); // صورة
              columnWidths[idx++] = const pw.FlexColumnWidth(5); // وصف
              columnWidths[idx++] = const pw.FlexColumnWidth(1.5); // وحدة
              if (showPrices) {
                if (priceType == 'list' || priceType == 'both') columnWidths[idx++] = const pw.FlexColumnWidth(2);
                if (priceType == 'net' || priceType == 'both') columnWidths[idx++] = const pw.FlexColumnWidth(2);
              }

              content.add(
                pw.Table(
                  columnWidths: columnWidths,
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: darkCharcoal),
                      children: headers.map((header) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                    // Data Rows
                    ...tableData.map((row) {
                      return pw.TableRow(
                        children: row.map((cell) {
                          if (cell is pw.Widget) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.all(6),
                              alignment: pw.Alignment.centerRight,
                              child: cell,
                            );
                          }
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              cell.toString(),
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              );
            }
            // ─── Template C: Simple Text Only (Legacy) ───────────────
            else {
              final List<List<String>> tableData = [];
              final headers = ['الكود', 'الوصف والمواصفات', 'الوحدة'];
              if (showPrices) {
                if (priceType == 'list' || priceType == 'both') headers.add('الليستة');
                if (priceType == 'net' || priceType == 'both') headers.add('الصافي');
              }

              for (final product in catProducts) {
                final variants = product['product_variants'] as List? ?? [];
                final pName = product['name'] ?? '';
                final pCode = product['code'] ?? '';
                final pUnit = product['unit_type'] ?? 'قطعة';

                if (variants.isEmpty) {
                  final List<String> row = [pCode, pName, pUnit];
                  if (showPrices) {
                    if (priceType == 'list' || priceType == 'both') row.add('0.00');
                    if (priceType == 'net' || priceType == 'both') row.add('0.00');
                  }
                  tableData.add(row);
                } else {
                  for (final v in variants) {
                    final vName = v['variant_name'] != null && v['variant_name'] != 'افتراضي'
                        ? '$pName - ${v['variant_name']}'
                        : pName;
                    final vCode = v['sku'] ?? pCode;

                    double listPrice = 0.0;
                    double netPrice = 0.0;

                    final pricings = v['supplier_product_pricings'] as List? ?? [];
                    if (pricings.isNotEmpty) {
                      final preferred = pricings.where((pr) => (pr as Map)['is_preferred'] == true);
                      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
                      listPrice = (pref['list_price'] as num?)?.toDouble() ?? 0.0;
                      netPrice = (pref['net_price'] as num?)?.toDouble() ?? 0.0;
                      if (netPrice <= 0 && listPrice > 0) netPrice = listPrice;
                    }

                    final List<String> row = [vCode, vName, (v['unit_type'] ?? pUnit) as String];
                    if (showPrices) {
                      if (priceType == 'list' || priceType == 'both') row.add(listPrice.toStringAsFixed(2));
                      if (priceType == 'net' || priceType == 'both') row.add(netPrice.toStringAsFixed(2));
                    }
                    tableData.add(row);
                  }
                }
              }

              final columnWidths = <int, pw.TableColumnWidth>{};
              int idx = 0;
              columnWidths[idx++] = const pw.FlexColumnWidth(2); // كود
              columnWidths[idx++] = const pw.FlexColumnWidth(6); // وصف
              columnWidths[idx++] = const pw.FlexColumnWidth(1.5); // وحدة
              if (showPrices) {
                if (priceType == 'list' || priceType == 'both') columnWidths[idx++] = const pw.FlexColumnWidth(2);
                if (priceType == 'net' || priceType == 'both') columnWidths[idx++] = const pw.FlexColumnWidth(2);
              }

              content.add(
                pw.Table(
                  columnWidths: columnWidths,
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: darkCharcoal),
                      children: headers.map((header) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                    // Data Rows
                    ...tableData.map((row) {
                      return pw.TableRow(
                        children: row.map((cell) {
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              cell,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              );
            }

            content.add(pw.SizedBox(height: 20));
          }

          return content;
        },
      ),
    );

    // Save and print/layout
    final titleFormatted = catalogTitle.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '_');
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${titleFormatted}_$dateStr',
    );
  }

  /// Builds a single premium Grid Card for layoutTemplate = 'grid'
  static pw.Widget _buildGridCard(
    Map<String, dynamic> product,
    pw.Widget Function(String?, double, double) imageBuilder,
    bool showPrices,
    String priceType,
    PdfColor primaryColor,
    PdfColor darkCharcoal,
  ) {
    final name = product['name'] ?? '';
    final code = product['code'] ?? '';
    final brand = product['brand'] ?? '';
    final material = product['material'] ?? '';
    final unit = product['unit_type'] ?? 'قطعة';
    final imageUrl = product['image_url'] as String?;

    final variants = product['product_variants'] as List? ?? [];

    double minNet = 0.0;
    double maxNet = 0.0;
    double listPrice = 0.0;

    if (variants.isNotEmpty) {
      final List<double> prices = [];
      for (final v in variants) {
        final pricings = v['supplier_product_pricings'] as List? ?? [];
        if (pricings.isNotEmpty) {
          final preferred = pricings.where((pr) => (pr as Map)['is_preferred'] == true);
          final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
          final lp = (pref['list_price'] as num?)?.toDouble() ?? 0.0;
          double np = (pref['net_price'] as num?)?.toDouble() ?? 0.0;
          if (np <= 0 && lp > 0) np = lp;
          if (np > 0) prices.add(np);
          if (lp > listPrice) listPrice = lp;
        }
      }
      if (prices.isNotEmpty) {
        prices.sort();
        minNet = prices.first;
        maxNet = prices.last;
      }
    }

    String priceStr = '';
    if (showPrices && minNet > 0) {
      if (priceType == 'net') {
        priceStr = maxNet > minNet
            ? '${minNet.toStringAsFixed(0)} - ${maxNet.toStringAsFixed(0)} ج.م'
            : '${minNet.toStringAsFixed(0)} ج.م';
      } else if (priceType == 'list') {
        priceStr = '${listPrice.toStringAsFixed(0)} ج.م';
      } else {
        // Both
        priceStr = maxNet > minNet
            ? 'صافي: ${minNet.toStringAsFixed(0)} - ${maxNet.toStringAsFixed(0)} ج.م'
            : 'صافي: ${minNet.toStringAsFixed(0)} ج.م (الليستة: ${listPrice.toStringAsFixed(0)})';
      }
    }

    final specs = [
      if (brand.toString().isNotEmpty) 'ماركة: $brand',
      if (material.toString().isNotEmpty) 'خامة: $material',
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFFDF9'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // 1. Image
          imageBuilder(imageUrl, double.infinity, 90),
          pw.SizedBox(height: 8),

          // 2. Code Badge + Title
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  code,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: darkCharcoal,
                  ),
                ),
              ),
              pw.Text(
                'بـ $unit',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // 3. Product Title
          pw.Text(
            name,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkCharcoal),
            maxLines: 2,
            overflow: pw.TextOverflow.clip,
          ),
          pw.SizedBox(height: 4),

          // 4. Specifications
          if (specs.isNotEmpty)
            pw.Text(
              specs.join(' | '),
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),

          // 5. Variants (list dimensions if any)
          if (variants.length > 1) ...[
            pw.SizedBox(height: 4),
            pw.Container(
              height: 0.5,
              color: PdfColors.grey200,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'الأصناف والمقاسات:',
              style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: variants.take(3).map((v) {
                final vName = v['variant_name'] ?? '';
                final vDim = v['dimensions'] ?? '';
                return pw.Bullet(
                  text: '$vName ${vDim.isNotEmpty ? "($vDim)" : ""}',
                  style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
                  bulletSize: 2,
                );
              }).toList(),
            ),
          ],

          // 6. Price tag (if active)
          if (showPrices && priceStr.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#E6F4EA'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                priceStr,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#137333'),
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
