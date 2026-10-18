import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/features/quotes/data/quote_pdf_generator.dart';

/// Screen to preview and export/share a quote as PDF.
class QuotePdfScreen extends ConsumerWidget {
  final String quoteId;

  const QuotePdfScreen({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(quoteDetailProvider(quoteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض السعر PDF'),
        actions: [
          // Share
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'مشاركة',
            onPressed: () => _share(context, ref),
          ),
        ],
      ),
      body: quoteAsync.when(
        data: (quote) {
          if (quote == null) {
            return const Center(
              child: Text('العرض غير موجود'),
            );
          }

          // Get shop info from profile
          final profileAsync = ref.watch(_shopInfoProvider);

          return profileAsync.when(
            data: (shop) => PdfPreview(
              build: (format) => QuotePdfGenerator.generate(
                quote: quote,
                shopName: shop['shop_name'] ?? shop['full_name'],
                shopPhone: shop['phone'],
                shopAddress: shop['address'],
              ),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              allowSharing: true,
              allowPrinting: true,
              pdfFileName: 'عرض_سعر_${quote['quote_number'] ?? ''}.pdf',
              loadingWidget: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري إنشاء ملف PDF...'),
                  ],
                ),
              ),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => PdfPreview(
              build: (format) => QuotePdfGenerator.generate(
                quote: quote,
              ),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              allowSharing: true,
              allowPrinting: true,
              pdfFileName: 'عرض_سعر_${quote['quote_number'] ?? ''}.pdf',
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل العرض...'),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'فشل تحميل العرض',
                style: TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 4),
              Text(e.toString(),
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  void _share(BuildContext context, WidgetRef ref) async {
    final quote = ref.read(quoteDetailProvider(quoteId)).value;
    if (quote == null) return;

    final profile = ref.read(_shopInfoProvider).value ?? {};
    final shopName = profile['shop_name'] ?? profile['full_name'] ?? 'السويدي للديكور';

    final pdfBytes = await QuotePdfGenerator.generate(
      quote: quote,
      shopName: shopName,
      shopPhone: profile['phone'],
    );

    if (!context.mounted) return;

    try {
      final dir = await getTemporaryDirectory();
      final quoteNumber = quote['quote_number'] ?? '';
      final filePath = '${dir.path}/عرض_سعر_$quoteNumber.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // مشاركة الملف فقط بدون text لضمان ظهور PDF في كل التطبيقات
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/pdf', name: 'عرض_سعر_$quoteNumber.pdf')],
          subject: 'عرض سعر رقم $quoteNumber - $shopName',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل المشاركة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Provider to get shop info from current user's profile.
final _shopInfoProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return {};

  final result = await client
      .from('profiles')
      .select('full_name, phone, shop_name, address')
      .eq('id', userId)
      .maybeSingle();

  return result ?? {};
});
