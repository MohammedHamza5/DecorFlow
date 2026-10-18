import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/features/inventory/presentation/screens/new_purchase_order_screen.dart';

class PurchaseOrdersScreen extends ConsumerStatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  ConsumerState<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends ConsumerState<PurchaseOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final purchaseOrdersFuture = ref.watch(purchaseOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('فواتير المشتريات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: purchaseOrdersFuture.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('لا توجد فواتير مشتريات حالياً', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPurchaseOrderScreen()));
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('إدخال فاتورة مشتريات جديدة'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إجمالي الفواتير: ${orders.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPurchaseOrderScreen()));
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('إدخال فاتورة جديدة'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.receipt_long, color: AppColors.primary),
                        ),
                        title: Text('رقم المرجع: ${order.invoiceNumber ?? 'بدون'}'),
                        subtitle: Text('التاريخ: ${order.createdAt.toString().split(' ')[0]} | الحالة: ${order.status}'),
                        trailing: Text(order.totalAmount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ')),
      ),
    );
  }
}
