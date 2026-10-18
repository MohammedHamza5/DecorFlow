import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/features/invoices/presentation/screens/invoice_pdf_screen.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/auth/rbac/permission_gate.dart';
import 'package:stream_pay/features/quotes/presentation/widgets/material_picker_modal.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/features/dashboard/presentation/screens/dashboard_screen.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _invoice;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      final data = await repo.getInvoiceDetails(widget.invoiceId);
      if (mounted) {
        setState(() {
          _invoice = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── Confirm Invoice (Electronic Seal) ────────────────────
  Future<void> _confirmInvoice() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'اعتماد وختم الفاتورة رسمياً',
      message: 'تنبيه: سيتم خصم كافة أصناف هذه الفاتورة من المخزون تلقائياً، وتتحول الفاتورة إلى مستند مالي رسمي.\n\nهل تريد المتابعة واعتماد الفاتورة؟',
      confirmLabel: 'اعتماد وختم الآن',
      icon: Icons.verified_rounded,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      await repo.confirmInvoice(widget.invoiceId);
      ref.invalidate(invoicesProvider);
      ref.invalidate(inventoryProvider);
      ref.read(catalogHubProvider.notifier).invalidate();
      ref.invalidate(drawerBalanceProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(currentMonthNetProfitProvider);
      ref.invalidate(geniusDashboardProvider);
      
      final customerId = _invoice?['customer_id'] as String?;
      if (customerId != null) {
        ref.invalidate(customerProfileProvider(customerId));
        ref.invalidate(customerLedgerProvider(customerId));
      }
      await _loadInvoice();
      if (mounted) {
        AppToast.showSuccess(context, 'تم اعتماد الفاتورة وخصم المخزون بنجاح ✓');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'خطأ: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── Delete Invoice ───────────────────────────────────────
  Future<void> _deleteInvoice() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'حذف مسودة الفاتورة',
      message: 'هل أنت متأكد من رغبتك في حذف هذه المسودة نهائياً؟\nلن يتم التأثير على أرصدة المخزون.',
      confirmLabel: 'حذف الآن',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      await repo.deleteInvoice(widget.invoiceId);
      ref.invalidate(invoicesProvider);
      if (mounted) {
        AppToast.showSuccess(context, 'تم حذف المسودة');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'خطأ: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showPaymentModal() async {
    final total = double.tryParse(_invoice!['invoice']['total_amount'].toString()) ?? 0;
    final payments = (_invoice!['payments'] as List?) ?? [];
    final paid = payments.fold<double>(0, (sum, p) => sum + (p['amount'] as num).toDouble());
    final balance = total - paid;
    final amountCtrl = TextEditingController(
      text: balance > 0
          ? (balance == balance.truncateToDouble() ? balance.toInt().toString() : balance.toStringAsFixed(2))
          : '',
    );
    String method = 'cash';

    final result = await AppBottomSheet.show<bool>(
      context: context,
      title: 'تسجيل دفعة نقدية / بنكية',
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Balance info chip
                if (balance > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المتبقي على الفاتورة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          '${balance.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Quick percentage preset chips
                if (balance > 0) ...[
                  const Text('مبالغ سريعة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('كامل المتبقي 100%'),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        side: const BorderSide(color: AppColors.primary),
                        onPressed: () {
                          AppHaptics.selection();
                          amountCtrl.text = balance == balance.truncateToDouble()
                              ? balance.toInt().toString()
                              : balance.toStringAsFixed(2);
                          setModalState(() {});
                        },
                      ),
                      ActionChip(
                        label: const Text('50% النصف'),
                        onPressed: () {
                          AppHaptics.selection();
                          final half = balance / 2;
                          amountCtrl.text = half == half.truncateToDouble()
                              ? half.toInt().toString()
                              : half.toStringAsFixed(2);
                          setModalState(() {});
                        },
                      ),
                      ActionChip(
                        label: const Text('25% الربع'),
                        onPressed: () {
                          AppHaptics.selection();
                          final quarter = balance / 4;
                          amountCtrl.text = quarter == quarter.truncateToDouble()
                              ? quarter.toInt().toString()
                              : quarter.toStringAsFixed(2);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: amountCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'المبلغ المدفوع (ج.م) *',
                    suffixText: 'ج.م',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: method,
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('💵 كاش (نقدي)')),
                    DropdownMenuItem(value: 'instapay', child: Text('⚡ إنستاباي (InstaPay)')),
                    DropdownMenuItem(value: 'vodafone_cash', child: Text('📱 فودافون كاش')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('🏦 تحويل بنكي')),
                    DropdownMenuItem(value: 'credit_card', child: Text('💳 فيزا / بطاقة ائتمان')),
                    DropdownMenuItem(value: 'cheque', child: Text('📝 شيك')),
                  ],
                  onChanged: (v) => setModalState(() => method = v!),
                  decoration: InputDecoration(
                    labelText: 'طريقة الدفع والتحصيل',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text);
                    if (amt != null && amt > 0) {
                      AppHaptics.medium();
                      Navigator.pop(ctx, true);
                    } else {
                      AppToast.showInfo(ctx, 'الرجاء إدخال مبلغ صحيح');
                    }
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('تسجيل الدفعة والاعتماد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final double paidAmount = double.parse(amountCtrl.text);
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(invoiceRepositoryProvider);
        await repo.recordPayment(
          invoiceId: widget.invoiceId,
          customerId: _invoice!['customer_id'],
          amount: paidAmount,
          paymentMethod: method,
        );
        ref.invalidate(invoicesProvider);
        ref.invalidate(drawerBalanceProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(currentMonthNetProfitProvider);
        ref.invalidate(geniusDashboardProvider);
        
        final customerId = _invoice?['customer_id'] as String?;
        if (customerId != null) {
          ref.invalidate(customerProfileProvider(customerId));
          ref.invalidate(customerLedgerProvider(customerId));
        }
        await _loadInvoice();
        if (mounted) {
          AppToast.showSuccess(context, 'تم تسجيل دفعة ${paidAmount.toStringAsFixed(0)} ج.م بنجاح ✓');

          // Offer 1-tap WhatsApp Receipt
          final customerPhone = _invoice?['customer']?['phone'] as String?;
          final customerName = _invoice?['customer']?['name'] as String? ?? 'العميل';
          final invNumber = _invoice?['invoice']?['invoice_number'] ?? '';

          if (customerPhone != null && customerPhone.isNotEmpty) {
            final remainingAfter = (balance - paidAmount).clamp(0, 999999999);
            final receiptText = 'سند تحصيل دفعة 🧾\n\n'
                'عزيزنا $customerName،\n'
                'تم استلام دفعة بقيمة ${paidAmount.toStringAsFixed(0)} ج.م على الفاتورة رقم $invNumber بنجاح.\n'
                'المتبقي على الفاتورة: ${remainingAfter.toStringAsFixed(0)} ج.م.\n\n'
                'شكراً لتعاملك مع السويدي للديكور ✨';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('هل ترغب بإرسال إيصال الدفع عبر واتساب؟'),
                action: SnackBarAction(
                  label: 'إرسال واتساب 💬',
                  textColor: const Color(0xFF25D366),
                  onPressed: () {
                    AppContactActions.launchWhatsApp(
                      context: context,
                      phone: customerPhone,
                      text: receiptText,
                    );
                  },
                ),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'خطأ في تسجيل الدفعة: $e');
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // ─── Return Items ─────────────────────────────────────────
  Future<void> _showReturnModal() async {
    final items = _invoice!['invoice_items'] as List? ?? [];
    if (items.isEmpty) return;

    // Track return quantities for each item
    final returnQtyControllers = <String, TextEditingController>{};
    for (final item in items) {
      returnQtyControllers[item['id']] = TextEditingController(text: '0');
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إنشاء فاتورة مرتجع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('حدد الكميات التي تريد إرجاعها:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final maxQty = (item['quantity'] as num).toDouble();
                  final price = (item['unit_price'] as num).toDouble();
                  return ListTile(
                    title: Text(item['product_name'] ?? 'منتج'),
                    subtitle: Text('الكمية المباعة: $maxQty × ${price.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: returnQtyControllers[item['id']],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'مرتجع', border: OutlineInputBorder()),
                        onChanged: (val) {
                          final input = double.tryParse(val) ?? 0;
                          if (input > maxQty) {
                            returnQtyControllers[item['id']]!.text = maxQty.toString();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  Navigator.pop(ctx, true);
                },
                child: const Text('تنفيذ المرتجع'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      try {
        final returnItems = <Map<String, dynamic>>[];
        for (final item in items) {
          final qtyToReturn = double.tryParse(returnQtyControllers[item['id']]!.text) ?? 0;
          if (qtyToReturn > 0) {
            returnItems.add({
              'product_variant_id': item['product_variant_id'],
              'product_name': item['product_name'],
              'quantity': qtyToReturn,
              'unit_price': item['unit_price'],
            });
          }
        }

        if (returnItems.isEmpty) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم يتم تحديد أي كميات للإرجاع')));
          }
          return;
        }

        final repo = ref.read(invoiceRepositoryProvider);
        await repo.createReturnInvoice(
          originalInvoiceId: widget.invoiceId,
          returnItems: returnItems,
        );
        
        ref.invalidate(invoicesProvider);
        ref.invalidate(inventoryProvider);
        ref.read(catalogHubProvider.notifier).invalidate();
        ref.invalidate(drawerBalanceProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(currentMonthNetProfitProvider);
        ref.invalidate(geniusDashboardProvider);
        await _loadInvoice();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء فاتورة المرتجع واسترداد المخزون بنجاح'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _editInvoiceItem(Map<String, dynamic> item, double initialQty, double initialPrice) async {
    final variantId = item['product_variant_id'] as String?;
    final minPrice = (item['product_variant'] as Map?)?['min_selling_price'] as double? ?? 0.0;

    List<Map<String, dynamic>> pricings = [];
    if (variantId != null) {
      try {
        pricings = await ref.read(productRepositoryProvider).getVariantPricing(variantId);
      } catch (_) {}
    }

    if (!mounted) return;

    double costPrice = 0.0;
    double listPrice = 0.0;
    if (pricings.isNotEmpty) {
      final preferred = pricings.where((p) => p['is_preferred'] == true);
      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
      costPrice = (pref['net_price'] as num?)?.toDouble() ?? 0.0;
      listPrice = (pref['list_price'] as num?)?.toDouble() ?? 0.0;
    }

    final qtyCtrl   = TextEditingController(text: initialQty.toStringAsFixed(initialQty.truncateToDouble() == initialQty ? 0 : 2));
    final priceCtrl = TextEditingController(text: initialPrice.toStringAsFixed(2));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final double inputPrice = double.tryParse(priceCtrl.text) ?? 0.0;
          final bool isBelowMin = minPrice > 0 && inputPrice < minPrice;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('تعديل البند', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  onChanged: (_) => setS(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر الوحدة (ج.م)',
                    helperText: 'يمكن تغييره لتطبيق سعر خاص للعميل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                  onChanged: (_) => setS(() {}),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('سعر التكلفة (المورد):', style: TextStyle(fontSize: 11)),
                          Text('${costPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('سعر اللائحة الرسمي:', style: TextStyle(fontSize: 11)),
                          Text('${listPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      if (minPrice > 0) ...[
                        const Divider(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الحد الأدنى للبيع:', style: TextStyle(fontSize: 11, color: AppColors.error)),
                            Text('${minPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.error)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBelowMin) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'تنبيه: لا يمكن البيع بأقل من الحد الأدنى المحدد.',
                          style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isBelowMin ? AppColors.error.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isBelowMin ? AppColors.error.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي البند:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${((double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0)).toStringAsFixed(2)} ج.م',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isBelowMin ? AppColors.error : AppColors.primary, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
              FilledButton.icon(
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('حفظ التعديل'),
                onPressed: isBelowMin ? null : () => Navigator.pop(ctx, true),
                style: isBelowMin ? FilledButton.styleFrom(backgroundColor: Colors.grey) : null,
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final newQty = double.tryParse(qtyCtrl.text) ?? initialQty;
      final newPrice = double.tryParse(priceCtrl.text) ?? initialPrice;

      setState(() => _isLoading = true);
      try {
        final repo = ref.read(invoiceRepositoryProvider);
        await repo.updateInvoiceItem(item['id'], {
          'quantity': newQty,
          'unit_price': newPrice,
          'total_price': newQty * newPrice,
        });
        ref.invalidate(invoicesProvider);
        await _loadInvoice();
      } catch (e) {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteInvoiceItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف البند'),
        content: const Text('هل أنت متأكد من حذف هذا البند من الفاتورة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(invoiceRepositoryProvider);
        await repo.removeInvoiceItem(item['id']);
        ref.invalidate(invoicesProvider);
        await _loadInvoice();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _addInvoiceItemManually() async {
    final result = await MaterialPickerModal.show(context);
    if (result == null || !mounted) return;

    final product = result['product'] as Map<String, dynamic>;
    final variant = result['variant'] as Map<String, dynamic>;

    final pricings = variant['supplier_product_pricings'] as List? ?? [];
    double defaultPrice = 0.0;
    double costPrice = 0.0;
    double listPrice = 0.0;
    if (pricings.isNotEmpty) {
      final preferred = pricings.where((p) => (p as Map)['is_preferred'] == true);
      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
      defaultPrice = (pref['net_price'] as num?)?.toDouble() 
          ?? (pref['list_price'] as num?)?.toDouble() 
          ?? 0.0;
      costPrice = (pref['net_price'] as num?)?.toDouble() ?? 0.0;
      listPrice = (pref['list_price'] as num?)?.toDouble() ?? 0.0;
    }
    final minPrice = (variant['min_selling_price'] as num?)?.toDouble() ?? 0.0;

    if (!mounted) return;

    final qtyCtrl = TextEditingController(text: '1.0');
    final priceCtrl = TextEditingController(text: defaultPrice.toStringAsFixed(2));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final double inputPrice = double.tryParse(priceCtrl.text) ?? 0.0;
          final bool isBelowMin = minPrice > 0 && inputPrice < minPrice;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('تحديد الكمية والسعر', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الصنف: ${product['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('الموديل: ${variant['variant_name'] ?? 'افتراضي'}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  autofocus: true,
                  onChanged: (_) => setS(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر الوحدة (ج.م)',
                    helperText: 'يمكن تغييره لتطبيق سعر خاص لهذا العميل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                  onChanged: (_) => setS(() {}),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('سعر التكلفة (المورد):', style: TextStyle(fontSize: 11)),
                          Text('${costPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('سعر اللائحة الرسمي:', style: TextStyle(fontSize: 11)),
                          Text('${listPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      if (minPrice > 0) ...[
                        const Divider(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الحد الأدنى للبيع:', style: TextStyle(fontSize: 11, color: AppColors.error)),
                            Text('${minPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.error)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBelowMin) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'تنبيه: لا يمكن البيع بأقل من الحد الأدنى المحدد.',
                          style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isBelowMin ? AppColors.error.withValues(alpha: 0.08) : AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isBelowMin ? AppColors.error.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي البند:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${((double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0)).toStringAsFixed(2)} ج.م',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isBelowMin ? AppColors.error : AppColors.success, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('إضافة البند'),
                onPressed: isBelowMin ? null : () {
                  final q = double.tryParse(qtyCtrl.text);
                  final p = double.tryParse(priceCtrl.text);
                  if (q != null && p != null && q > 0) {
                    Navigator.pop(ctx, true);
                  }
                },
                style: isBelowMin ? FilledButton.styleFrom(backgroundColor: Colors.grey) : null,
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true && mounted) {
      final q = double.parse(qtyCtrl.text);
      final p = double.parse(priceCtrl.text);

      setState(() => _isLoading = true);
      try {
        final repo = ref.read(invoiceRepositoryProvider);
        await repo.addInvoiceItem(widget.invoiceId, {
          'product_variant_id': variant['id'],
          'quantity': q,
          'unit_price': p,
          'total_price': q * p,
          'notes': 'إضافة يدوية',
        });

        ref.invalidate(invoicesProvider);
        await _loadInvoice();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة البند وتحديث الفاتورة بنجاح ✓'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

    qtyCtrl.dispose();
    priceCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_invoice == null) {
      return const Scaffold(body: Center(child: Text('لم يتم العثور على الفاتورة')));
    }

    final inv = _invoice!;
    final customer = inv['customer'] as Map<String, dynamic>?;
    final items = inv['invoice_items'] as List? ?? [];
    final payments = inv['payments'] as List? ?? [];
    final String status = inv['status'] ?? 'draft';

    final double total = (inv['total_amount'] as num).toDouble();
    final double paid = (inv['paid_amount'] as num).toDouble();
    final double due = total - paid;
    final bool isDraft = status == 'draft';

    return Scaffold(
      appBar: AppBar(
        title: Text('فاتورة ${inv['invoice_number']}'),
        actions: [
          if (isDraft)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'حذف المسودة',
              onPressed: _deleteInvoice,
            ),
          if (!isDraft && inv['invoice_type'] != 'return')
            IconButton(
              icon: const Icon(Icons.assignment_return_outlined, color: AppColors.error),
              tooltip: 'إنشاء مرتجع',
              onPressed: _showReturnModal,
            ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'طباعة إيصال حراري (80 مم)',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => InvoicePdfScreen(invoiceId: widget.invoiceId, initialThermal: true),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'فاتورة A4 كاملة',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => InvoicePdfScreen(invoiceId: widget.invoiceId, initialThermal: false),
            )),
          ),
        ],
      ),
      body: ConstrainedBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ─── Status Badge ──────────────────────────────
            _buildStatusBanner(status, inv),
            const SizedBox(height: 16),

            // ─── Summary Card ──────────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('معلومات العميل',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(
                          customer?['name'] != null && customer!['name'].toString().trim().isNotEmpty
                              ? Icons.person_rounded
                              : Icons.point_of_sale_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          customer?['name'] != null && customer!['name'].toString().trim().isNotEmpty
                              ? customer['name']
                              : 'عميل نقدي (كاش)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (customer?['name'] == null || customer!['name'].toString().trim().isEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('بيع مباشر', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    if (customer?['phone'] != null && customer!['phone'].toString().trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(customer['phone'], style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountCol('الإجمالي', total, AppColors.textPrimary),
                        _buildAmountCol('المدفوع', paid, AppColors.success),
                        _buildAmountCol('المتبقي', due, due > 0 ? AppColors.error : AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Items List ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('البنود (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (isDraft)
                  TextButton.icon(
                    onPressed: _addInvoiceItemManually,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('إضافة بند'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              final qty = (item['quantity'] as num).toDouble();
              final price = (item['unit_price'] as num).toDouble();
              final lineTotal = (item['final_line_total'] as num).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: isDraft ? () => _editInvoiceItem(item, qty, price) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product_name'] ?? 'منتوج',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'كمية: ${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} ${item['unit'] ?? ''}',
                                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'سعر: ${price.toStringAsFixed(2)} ج.م',
                                       style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${lineTotal.toStringAsFixed(2)} ج.م',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            if (isDraft)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _editInvoiceItem(item, qty, price),
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _deleteInvoiceItem(item),
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ─── Payments List ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('سجل الدفعات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (due > 0)
                  PermissionGate(
                    permission: AppPermission.createPayment,
                    child: TextButton.icon(
                      onPressed: _showPaymentModal,
                      icon: const Icon(Icons.add),
                      label: const Text('سند قبض'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (payments.isEmpty)
              Text('لم يتم تسجيل أي دفعات بعد.', style: TextStyle(color: AppColors.textTertiary))
            else
              ...payments.map((p) {
                final pAmt = (p['amount'] as num).toDouble();
                final pDate = DateTime.parse(p['created_at']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.success,
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                    title: Text('${pAmt.toStringAsFixed(2)} ج.م'),
                    subtitle: Text(
                      '${_translatePaymentMethod(p['payment_method'])} • ${DateFormat('yyyy/MM/dd HH:mm').format(pDate.toLocal())}',
                    ),
                  ),
                );
              }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
      bottomNavigationBar: SafeArea(
        child: ConstrainedBody(
          padding: const EdgeInsets.all(16),
          child: isDraft
              ? FilledButton.icon(
                  onPressed: _confirmInvoice,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('اعتماد الفاتورة (ختم إلكتروني)', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
              : due > 0
                  ? PermissionGate(
                      permission: AppPermission.createPayment,
                      child: FilledButton.icon(
                        onPressed: _showPaymentModal,
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('تسجيل دفعة (سند قبض)'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ─── Status Banner ──────────────────────────────────────
  Widget _buildStatusBanner(String status, Map<String, dynamic> inv) {
    Color bgColor;
    Color fgColor;
    IconData icon;
    String label;

    switch (status) {
      case 'draft':
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        fgColor = AppColors.warning;
        icon = Icons.edit_note_rounded;
        label = 'مسودة — تحتاج اعتماد';
      case 'confirmed':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        fgColor = AppColors.success;
        icon = Icons.verified_rounded;
        label = 'معتمدة ✓ — تم خصم المخزون';
      case 'partially_paid':
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        fgColor = AppColors.primary;
        icon = Icons.account_balance_wallet_rounded;
        label = 'مدفوعة جزئياً';
      case 'paid':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        fgColor = Colors.blue;
        icon = Icons.check_circle_rounded;
        label = 'مدفوعة بالكامل ✓';
      default:
        bgColor = AppColors.surfaceVariant;
        fgColor = AppColors.textSecondary;
        icon = Icons.receipt_long_rounded;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: fgColor, fontWeight: FontWeight.w900, fontSize: 14)),
                if (status == 'confirmed' && inv['confirmed_at'] != null)
                  Text(
                    'تاريخ الاعتماد: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(inv['confirmed_at']).toLocal())}',
                    style: TextStyle(color: fgColor.withValues(alpha: 0.7), fontSize: 11),
                  ),
              ],
            ),
          ),
          if (status == 'confirmed')
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: fgColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium_rounded, color: fgColor, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountCol(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(amount.toStringAsFixed(2),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  String _translatePaymentMethod(String? method) {
    switch (method) {
      case 'cash': return 'نقدي (كاش)';
      case 'bank_transfer': return 'تحويل بنكي';
      case 'credit_card': return 'بطاقة ائتمان';
      case 'cheque': return 'شيك بنكي';
      case 'instapay': return 'إنستاباي (InstaPay)';
      case 'vodafone_cash': return 'فودافون كاش';
      default: return method ?? '';
    }
  }
}
