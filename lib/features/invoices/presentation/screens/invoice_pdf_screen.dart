import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/invoices/utils/invoice_pdf_generator.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';

/// شاشة معاينة ومشاركة فاتورة PDF.
/// تحمّل بيانات الفاتورة مرة واحدة فقط لتجنب التكرار وضمان التناسق.
class InvoicePdfScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  final bool initialThermal;

  const InvoicePdfScreen({
    super.key,
    required this.invoiceId,
    this.initialThermal = true,
  });

  @override
  ConsumerState<InvoicePdfScreen> createState() => _InvoicePdfScreenState();
}

class _InvoicePdfScreenState extends ConsumerState<InvoicePdfScreen> {
  Map<String, dynamic>? _invoice;
  bool _isLoading = true;
  String? _error;
  bool _isSharing = false;
  late bool _isThermal;

  @override
  void initState() {
    super.initState();
    _isThermal = widget.initialThermal;
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    try {
      final invoice = await ref
          .read(invoiceRepositoryProvider)
          .getInvoiceDetails(widget.invoiceId);
      if (mounted) {
        setState(() {
          _invoice = invoice;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _share() async {
    final invoice = _invoice;
    if (invoice == null) return;

    setState(() => _isSharing = true);
    try {
      final shopInfo = ref.read(shopInfoProvider).value;
      final shopName = shopInfo?['name'] as String? ?? 'محلنا';
      final shopPhone = shopInfo?['phone'] as String?;
      final invoiceNumber = invoice['invoice_number'] ?? '';

      // توليد PDF من البيانات المحملة مسبقاً بناءً على الوضع الحالي
      final pdfBytes = _isThermal
          ? await InvoicePdfGenerator.generateThermal(
              invoice: invoice,
              shopName: shopName,
              shopPhone: shopPhone,
            )
          : await InvoicePdfGenerator.generate(
              invoice: invoice,
              shopName: shopName,
              shopPhone: shopPhone,
            );

      // حفظ الملف في مجلد مؤقت
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/فاتورة_$invoiceNumber.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      final customerName = (invoice['customer'] as Map<String, dynamic>?)?['name'] ?? '';
      final shareText =
          'أهلاً بك يا فندم،\n\nمرفق الفاتورة رقم $invoiceNumber من $shopName.'
          '${customerName.isNotEmpty ? "\nالعميل: $customerName" : ""}'
          '\n\nنسعد دائماً بخدمتكم.';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/pdf', name: 'فاتورة_$invoiceNumber.pdf')],
          subject: 'فاتورة رقم $invoiceNumber - $shopName',
        ),
      );

      // عرض النص في snackbar حتى يتمكن المستخدم من نسخه إن أراد
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shareText, style: const TextStyle(fontSize: 12)),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'نسخ',
              onPressed: () async {
                await _copyTextToClipboard(shareText);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل المشاركة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _copyTextToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ النص'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _print() async {
    final invoice = _invoice;
    if (invoice == null) return;

    try {
      final shopInfo = ref.read(shopInfoProvider).value;
      final shopName = shopInfo?['name'] as String? ?? 'محلنا';
      final shopPhone = shopInfo?['phone'] as String?;
      final pdfBytes = _isThermal
          ? await InvoicePdfGenerator.generateThermal(
              invoice: invoice,
              shopName: shopName,
              shopPhone: shopPhone,
            )
          : await InvoicePdfGenerator.generate(
              invoice: invoice,
              shopName: shopName,
              shopPhone: shopPhone,
            );
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الطباعة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _invoice != null
              ? 'فاتورة ${_invoice!['invoice_number'] ?? ''}'
              : 'معاينة الفاتورة',
        ),
        actions: [
          if (_invoice != null) ...[
            if (_isSharing)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.share_rounded),
                tooltip: 'مشاركة الفاتورة',
                onPressed: _share,
              ),
            IconButton(
              icon: const Icon(Icons.print_rounded),
              tooltip: 'طباعة',
              onPressed: _print,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تجهيز الفاتورة...');
    }

    if (_error != null || _invoice == null) {
      return AppErrorWidget(
        message: 'تعذر تحميل الفاتورة',
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _loadInvoice();
        },
      );
    }

    return Column(
      children: [
        // Premium Layout Toggle Bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildToggleButton(
                      label: 'فاتورة A4 المتميزة',
                      isActive: !_isThermal,
                      icon: Icons.picture_as_pdf_rounded,
                      onTap: () => setState(() => _isThermal = false),
                    ),
                    const SizedBox(width: 4),
                    _buildToggleButton(
                      label: 'إيصال حراري (80 مم)',
                      isActive: _isThermal,
                      icon: Icons.print_rounded,
                      onTap: () => setState(() => _isThermal = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PdfPreview(
            build: (format) {
              final shopInfo = ref.read(shopInfoProvider).value;
              final shopName = shopInfo?['name'] as String? ?? 'محلنا';
              final shopPhone = shopInfo?['phone'] as String?;
              final shopAddress = shopInfo?['address'] as String?;
              return _isThermal
                  ? InvoicePdfGenerator.generateThermal(
                      invoice: _invoice!,
                      shopName: shopName,
                      shopPhone: shopPhone,
                      shopAddress: shopAddress,
                    )
                  : InvoicePdfGenerator.generate(
                      invoice: _invoice!,
                      shopName: shopName,
                      shopPhone: shopPhone,
                      shopAddress: shopAddress,
                    );
            },
            pdfFileName: 'فاتورة_${_invoice!['invoice_number'] ?? widget.invoiceId}.pdf',
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            loadingWidget: const LoadingWidget(message: 'جاري التصيير...'),
            onError: (context, error) =>
                AppErrorWidget(message: 'حدث خطأ في عرض الفاتورة: $error'),
            actions: [
              PdfPreviewAction(
                icon: const Icon(Icons.share_rounded),
                onPressed: (context, build, pageFormat) => _share(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

