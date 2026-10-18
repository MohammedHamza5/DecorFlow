import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/core/database/app_database.dart' as erp_db;
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

import '../widgets/purchase_order/purchase_header_bar.dart';
import '../widgets/purchase_order/purchase_catalog_picker.dart';
import '../widgets/purchase_order/purchase_items_table.dart';
import '../widgets/purchase_order/purchase_summary_footer.dart';

/// Redesigned, High-Efficiency Purchase Invoice Screen.
/// Provides effortless stock replenishment, accurate cost tracking,
/// instant color/variant picking, and optional cash flow integration.
class NewPurchaseOrderScreen extends ConsumerStatefulWidget {
  const NewPurchaseOrderScreen({super.key});

  @override
  ConsumerState<NewPurchaseOrderScreen> createState() =>
      _NewPurchaseOrderScreenState();
}

class _NewPurchaseOrderScreenState
    extends ConsumerState<NewPurchaseOrderScreen> {
  int? _selectedSupplierId;
  final TextEditingController _invoiceNumberCtrl = TextEditingController();
  String _paymentMethod = 'cash'; // 'cash', 'credit', 'bank'

  // Added invoice items
  final List<Map<String, dynamic>> _items = [];
  double _discount = 0.0;
  bool _isLoading = false;
  int _mobileSelectedTab = 0; // 0 = Catalog, 1 = Invoice items

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold(
      0.0,
      (sum, item) => sum + ((item['qty'] as num) * (item['cost'] as num)),
    );
  }

  double get _totalQty {
    return _items.fold(0.0, (sum, item) => sum + (item['qty'] as num));
  }

  void _addVariant(EnrichedProduct product, EnrichedVariant variant) async {
    final existingIndex =
        _items.indexWhere((i) => i['variantId'] == variant.id);

    if (existingIndex >= 0) {
      final currentQty = (_items[existingIndex]['qty'] as num).toDouble();
      _updateItemQty(existingIndex, currentQty + 1);
      AppToast.showInfo(context, 'تمت زيادة كمية: ${variant.variantName}');
      return;
    }

    final double cost =
        variant.netPrice > 0 ? variant.netPrice : variant.listPrice;

    setState(() {
      _items.add({
        'variantId': variant.id,
        'productId': product.id,
        'name': '${product.name} - ${variant.variantName}',
        'unit': product.unitType.isNotEmpty ? product.unitType : 'لوح',
        'qty': 1.0,
        'cost': cost,
      });
    });

    AppHaptics.success();
    AppToast.showSuccess(context, 'تمت إضافة: ${variant.variantName}');
  }

  void _updateItemQty(int index, double newQty) {
    setState(() {
      _items[index]['qty'] = newQty;
    });
  }

  void _updateItemCost(int index, double newCost) {
    setState(() {
      _items[index]['cost'] = newCost;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _savePurchaseOrder() async {
    if (_selectedSupplierId == null) {
      AppToast.showError(context, 'الرجاء اختيار المورد من الشريط العلوي أولاً');
      return;
    }
    if (_items.isEmpty) {
      AppToast.showError(
          context, 'فاتورة المشتريات فارغة! اختر خامات لإضافتها');
      return;
    }

    final netTotal = (_subtotal - _discount).clamp(0.0, double.infinity);

    // If paid Cash from Drawer, check if drawer balance is sufficient
    if (_paymentMethod == 'cash') {
      final cashEngine = ref.read(cashFlowEngineProvider);
      final currentDrawer = await cashEngine.getDrawerBalance();
      if (netTotal > currentDrawer) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error),
                SizedBox(width: 8),
                Text('تنبيه: رصيد الدرج غير كافٍ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: Text(
              'قيمة الفاتورة (${netTotal.toStringAsFixed(0)} ج.م) أكبر من رصيد الدرج الحالي (${currentDrawer.toStringAsFixed(0)} ج.م).\n\nهل تم دفع المبلغ نقداً من خارج الدرج (سلفة خارجية) وتريد استكمال السداد النقدي؟',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('تعديل إلى آجل على المورد'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('نعم، سداد نقدي استثنائي'),
              ),
            ],
          ),
        );
        if (proceed != true) {
          setState(() => _paymentMethod = 'credit');
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(erpDatabaseProvider);
      final isPaidCash = _paymentMethod == 'cash';

      final poId = await db.into(db.purchaseOrders).insert(
            erp_db.PurchaseOrdersCompanion.insert(
              supplierId: _selectedSupplierId!,
              invoiceNumber: drift.Value(
                _invoiceNumberCtrl.text.trim().isEmpty
                    ? null
                    : _invoiceNumberCtrl.text.trim(),
              ),
              totalAmount: drift.Value(netTotal),
              paidAmount: drift.Value(isPaidCash ? netTotal : 0.0),
              status: const drift.Value('pending'),
              notes: drift.Value(
                isPaidCash
                    ? 'سداد نقدي من الدرج'
                    : (_paymentMethod == 'credit'
                        ? 'آجل على حساب المورد'
                        : 'تحويل بنكي / شيك'),
              ),
            ),
          );

      // Insert line items
      for (final item in _items) {
        final variantStringId = item['variantId'] as String;
        final variantIntId = variantStringId.hashCode.abs();
        final double qty = (item['qty'] as num).toDouble();
        final double unitCost = (item['cost'] as num).toDouble();

        await db.into(db.purchaseOrderItems).insert(
              erp_db.PurchaseOrderItemsCompanion.insert(
                purchaseOrderId: poId,
                productVariantId: variantIntId,
                quantity: qty,
                unitCost: unitCost,
                totalCost: qty * unitCost,
              ),
            );
      }

      // 1. Receive into Inventory Engine
      final engine = ref.read(inventoryEngineProvider);
      await engine.receivePurchaseOrder(poId);

      // 2. Synchronize with local inventory items
      final invRepo = ref.read(inventoryRepositoryProvider);
      for (final item in _items) {
        final variantStringId = item['variantId'] as String;
        final double qty = (item['qty'] as num).toDouble();
        if (qty <= 0) continue;

        final existing =
            await invRepo.getInventoryItemByVariantId(variantStringId);
        if (existing != null) {
          final itemId = existing['id'] as String;
          await invRepo.recordMovement(
            inventoryItemId: itemId,
            type: 'in',
            quantity: qty,
            referenceType: 'purchase_order',
            referenceId: '$poId',
            notes: 'توريد فاتورة مشتريات #$poId',
          );
        } else {
          await invRepo.addInventoryItem(
            productVariantId: variantStringId,
            unitType: item['unit'] as String? ?? 'لوح',
            quantity: qty,
            notes: 'توريد فاتورة مشتريات #$poId',
          );
        }
      }

      // 3. If Cash payment, record cash outflow in CashFlowEngine
      if (isPaidCash) {
        final cashEngine = ref.read(cashFlowEngineProvider);
        await cashEngine.recordTransaction(
          type: 'out',
          amount: netTotal,
          category: 'supplier_payment',
          notes:
              'سداد فاتورة مشتريات مورد #$poId (${_invoiceNumberCtrl.text.trim()})',
        );
        ref.invalidate(drawerBalanceProvider);
        ref.invalidate(dailyCashSummaryProvider);
        ref.invalidate(recentTransactionsProvider);
      }

      // Refresh catalog and purchase orders
      ref.invalidate(purchaseOrdersProvider);
      await ref.read(catalogHubProvider.notifier).load(forceRefresh: true);

      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(
          context,
          'تم حفظ وتوريد الفاتورة #$poId للمخزن وتحديث الأرصدة بنجاح ✅',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'فشل حفظ وتوريد الفاتورة: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إدخال وتوريد فاتورة مشتريات',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 1. Top Configuration Bar (Supplier + Invoice # + Payment Method)
              PurchaseHeaderBar(
                selectedSupplierId: _selectedSupplierId,
                onSupplierChanged: (val) =>
                    setState(() => _selectedSupplierId = val),
                invoiceNumberCtrl: _invoiceNumberCtrl,
                paymentMethod: _paymentMethod,
                onPaymentMethodChanged: (val) =>
                    setState(() => _paymentMethod = val),
              ),

              const SizedBox(height: 10),

              // 2. Main Workspace (Responsive: Dual-pane on desktop, Tabs on mobile)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 850;

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Right Side (in RTL): Materials Catalog
                          Expanded(
                            flex: 6,
                            child: PurchaseCatalogPicker(
                              onVariantSelected: _addVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Left Side (in RTL): Invoice Items Table
                          Expanded(
                            flex: 5,
                            child: PurchaseItemsTable(
                              items: _items,
                              onQtyChanged: _updateItemQty,
                              onCostChanged: _updateItemCost,
                              onRemoveItem: _removeItem,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile / Small Screen: Tab selector
                      return Column(
                        children: [
                          // Mobile Tab Selector
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(
                                        () => _mobileSelectedTab = 0),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _mobileSelectedTab == 0
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'كتالوج الخامات 📦',
                                        style: TextStyle(
                                          color: _mobileSelectedTab == 0
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(
                                        () => _mobileSelectedTab = 1),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _mobileSelectedTab == 1
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'بنود الفاتورة (${_items.length}) 🛒',
                                        style: TextStyle(
                                          color: _mobileSelectedTab == 1
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: _mobileSelectedTab == 0
                                ? PurchaseCatalogPicker(
                                    onVariantSelected: _addVariant,
                                  )
                                : PurchaseItemsTable(
                                    items: _items,
                                    onQtyChanged: _updateItemQty,
                                    onCostChanged: _updateItemCost,
                                    onRemoveItem: _removeItem,
                                  ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 3. Purchase Summary Footer (Items count, Total qty, Net amount, Save button)
              PurchaseSummaryFooter(
                itemsCount: _items.length,
                totalQty: _totalQty,
                subtotal: _subtotal,
                discount: _discount,
                onDiscountChanged: (val) => setState(() => _discount = val),
                isLoading: _isLoading,
                onSave: _savePurchaseOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
