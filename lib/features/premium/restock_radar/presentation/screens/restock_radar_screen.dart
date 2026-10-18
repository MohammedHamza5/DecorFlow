import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/restock_providers.dart';
import '../../data/repositories/restock_repository.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class RestockRadarScreen extends ConsumerWidget {
  const RestockRadarScreen({super.key});

  Future<void> _sendWhatsAppMessage(LowStockItem item, BuildContext context) async {
    final phone = item.supplierPhone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم هاتف المورد غير متوفر')),
      );
      return;
    }

    final message = '''
مرحباً ${item.supplierName ?? 'شركة التوريد'}،
نود طلب المواد التالية:
- الصنف: ${item.productName} (${item.variantName})
- الكمية المطلوبة: ${item.recommendedOrderQty.toInt()} وحدة

يرجى تأكيد توفر الكمية وإعلامنا بالتكلفة الإجمالية وموعد التوصيل.
شكراً لكم.
''';

    final encodedMessage = Uri.encodeComponent(message);
    // Format phone to international format if not already. 
    // Assuming Egypt (+20) for this example if it starts with 01
    String formattedPhone = phone;
    if (formattedPhone.startsWith('01') && formattedPhone.length == 11) {
      formattedPhone = '+20${formattedPhone.substring(1)}';
    }

    final url = Uri.parse('whatsapp://send?phone=$formattedPhone&text=$encodedMessage');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback to web link if app is not installed
        final webUrl = Uri.parse('https://wa.me/$formattedPhone?text=$encodedMessage');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا يمكن فتح WhatsApp')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('رادار النواقص والأوامر'),
        centerTitle: true,
      ),
      body: ConstrainedBody(
        child: lowStockAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'جميع المنتجات فوق حد الأمان',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _LowStockCard(
                  item: item,
                  onOrderPressed: () => _sendWhatsAppMessage(item, context),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('خطأ: $error', style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final LowStockItem item;
  final VoidCallback onOrderPressed;

  const _LowStockCard({
    required this.item,
    required this.onOrderPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shortage = item.safetyStock - item.availableQty;
    // Severity calculation
    final isCritical = item.availableQty <= 0;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCritical ? Colors.red.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCritical ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCritical ? Icons.warning : Icons.inventory_2,
                    color: isCritical ? Colors.red : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.productName} (${item.variantName})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        item.category,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isCritical)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('نفذ الكمية', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('المتاح', '${item.availableQty.toInt()}', isCritical ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                _buildStatColumn('حد الخطر', '${item.safetyStock.toInt()}', Colors.grey),
                _buildStatColumn('النقص', '${shortage.toInt()}', Colors.orange),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المورد المقترح', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        item.supplierName ?? 'غير محدد',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: item.supplierPhone != null ? onOrderPressed : null,
                  icon: const Icon(Icons.share),
                  label: const Text('طلب توريد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
