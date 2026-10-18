import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';
import 'package:stream_pay/features/projects/utils/customer_ledger_pdf_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart' as intl;
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Customer profile — transformed into an interactive CRM Dashboard with 4 tabs:
/// 1. Overview & Smart Actions (الملخص والنشاط)
/// 2. Invoices & Payments (الفواتير والمدفوعات)
/// 3. Projects & Quotes (المشاريع والعروض)
/// 4. Financial Ledger & PDF Export (كشف الحساب المالي)
class CustomerProfileScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to refresh all customer related providers
  void _refreshData() {
    ref.invalidate(customerProfileProvider(widget.customerId));
    ref.invalidate(customerLedgerProvider(widget.customerId));
    ref.invalidate(customersProvider);
    _changed = true;
  }

  Future<void> _launchUrlHelper(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('عذراً، لم نتمكن من فتح الرابط: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerProfileProvider(widget.customerId));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _changed) {
          // Parent screen will listen to pops to update its cache
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الملف المالي للعميل'),
          centerTitle: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          actions: [
            customerAsync.when(
              data: (customer) {
                if (customer == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'تعديل البيانات الأساسية',
                  onPressed: () => _editCustomer(customer),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: customerAsync.when(
          data: (customer) {
            if (customer == null) {
              return const Center(child: Text('عذراً، هذا العميل غير موجود أو تم حذفه'));
            }
            return _buildDashboard(customer);
          },
          loading: () => const LoadingWidget(message: 'جاري تحميل لوحة تحكم العميل...'),
          error: (e, _) => AppErrorWidget(
            message: 'فشل تحميل بيانات العميل',
            onRetry: _refreshData,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(Map<String, dynamic> customer) {
    final name = customer['name'] ?? '';
    final type = customer['type'] ?? 'regular';
    final classTag = customer['class_tag'] ?? 'regular';
    final totalDebt = (customer['total_debt'] as num?)?.toDouble() ?? 0.0;
    final isVIP = classTag == 'VIP' || type == 'VIP';

    return ConstrainedBody(
      child: Column(
        children: [
          // Premium Client Header Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Avatar with initials
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isVIP
                            ? [AppColors.primary, AppColors.primaryDark]
                            : totalDebt > 5000
                                ? [AppColors.error, AppColors.errorDark]
                                : [AppColors.secondary, AppColors.secondaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isVIP
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: isVIP ? Colors.black : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and status chips
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          name,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isVIP)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary, width: 0.8),
                                ),
                                child: const Text(
                                  'عميل VIP متميز',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (totalDebt > 5000)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error, width: 0.8),
                                ),
                                child: const Text(
                                  'مستحقات متأخرة عالية',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else if (totalDebt > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange, width: 0.8),
                                ),
                                child: const Text(
                                  'عليه مديونية',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green, width: 0.8),
                                ),
                                child: const Text(
                                  'خالص الذمة المالية',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tabs Row
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
            tabs: const [
              Tab(text: 'الملخص', icon: Icon(Icons.dashboard_rounded, size: 20)),
              Tab(text: 'الفواتير', icon: Icon(Icons.receipt_long_rounded, size: 20)),
              Tab(text: 'العروض والمشاريع', icon: Icon(Icons.workspaces_outline, size: 20)),
              Tab(text: 'كشف الحساب', icon: Icon(Icons.menu_book_rounded, size: 20)),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(customer),
              _buildInvoicesTab(customer),
              _buildProjectsTab(customer),
              _buildLedgerTab(customer),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ─── TAB 1: OVERVIEW & SMART CRM ACTIONS ───────────────────────────────────
  Widget _buildOverviewTab(Map<String, dynamic> customer) {
    final name = customer['name'] ?? '';
    final phone = customer['phone'] ?? '';
    final address = customer['address'] ?? customer['location'] ?? '';
    final notes = customer['notes'] ?? '';
    final totalSales = (customer['total_sales'] as num?)?.toDouble() ?? 0.0;
    final totalPaid = (customer['total_paid'] as num?)?.toDouble() ?? 0.0;
    final totalDebt = (customer['total_debt'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: Financial Cards
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _OverviewStatCard(
                label: 'إجمالي المبيعات',
                value: '${totalSales.toStringAsFixed(0)} ج.م',
                icon: Icons.storefront_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _OverviewStatCard(
                label: 'إجمالي المسدد',
                value: '${totalPaid.toStringAsFixed(0)} ج.م',
                icon: Icons.payments_rounded,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Outstanding balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: totalDebt > 0
                  ? AppColors.error.withValues(alpha: 0.08)
                  : Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: totalDebt > 0 ? AppColors.error.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalDebt > 0 ? 'المديونية المستحقة حالياً' : 'الرصيد المتبقي المستحق',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: totalDebt > 0 ? AppColors.error : Colors.green,
                      ),
                    ),
                    Icon(
                      totalDebt > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                      color: totalDebt > 0 ? AppColors.error : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  totalDebt > 0 ? '${totalDebt.toStringAsFixed(2)} ج.م' : '0.00 ج.م (خالص تماماً)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: totalDebt > 0 ? AppColors.error : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Smart Operations Panel (Quick Actions)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'العمليات السريعة والتواصل الذكي',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Record payment button
                      _SmartActionButton(
                        icon: Icons.add_card_rounded,
                        label: 'تسجيل دفعة سداد',
                        color: Colors.green,
                        onTap: () => _showRecordPaymentDialog(customer: customer, defaultAmount: totalDebt > 0 ? totalDebt : null),
                      ),
                      const SizedBox(width: 8),
                      // Direct WhatsApp
                      _SmartActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'واتساب وتذكير سداد',
                        color: const Color(0xFF25D366),
                        onTap: () {
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى إضافة رقم الهاتف للعميل أولاً')),
                            );
                            return;
                          }
                          final msg = totalDebt > 0
                              ? 'السلام عليكم أ. $name. نود تذكيركم بالمديونية المتبقية وقدرها ${totalDebt.toStringAsFixed(0)} ج.م. شاكرين لكم حسن تعاونكم.'
                              : 'السلام عليكم أ. $name. يسعدنا دائماً التعامل معكم، رصيدكم المالي لدينا حالياً خالص الذمة. شكراً لكم.';
                          // Remove leading zero, add Egypt country code if needed
                          String formattedPhone = phone.replaceAll(' ', '').replaceAll('-', '');
                          if (formattedPhone.startsWith('0')) {
                            formattedPhone = '2$formattedPhone';
                          }
                          _launchUrlHelper('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(msg)}');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Direct Phone Call
                      _SmartActionButton(
                        icon: Icons.phone_forwarded_rounded,
                        label: 'اتصال هاتفي سريع',
                        color: AppColors.info,
                        onTap: () {
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا يوجد رقم هاتف مسجل لهذا العميل')),
                            );
                            return;
                          }
                          _launchUrlHelper('tel:$phone');
                        },
                      ),
                      const SizedBox(width: 8),
                      // Map link
                      _SmartActionButton(
                        icon: Icons.map_outlined,
                        label: 'موقع العميل بالخريطة',
                        color: Colors.amber[700]!,
                        onTap: () {
                          if (address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى تحديد عنوان العميل لاستعراض الخريطة')),
                            );
                            return;
                          }
                          _launchUrlHelper('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Customer Info & Notes
          if (address.isNotEmpty || notes.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'بيانات التواصل والملاحظات',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    if (address.isNotEmpty) ...[
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              address,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (address.isNotEmpty && notes.isNotEmpty) const Divider(height: 20, color: AppColors.darkBorder),
                    if (notes.isNotEmpty) ...[
                      Row(
                        textDirection: TextDirection.rtl,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_outlined, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notes,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── TAB 2: INVOICES & PAYMENTS ────────────────────────────────────────────
  Widget _buildInvoicesTab(Map<String, dynamic> customer) {
    final invoices = customer['invoices'] as List? ?? [];
    final payments = customer['payments'] as List? ?? [];

    if (invoices.isEmpty && payments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_rounded,
        title: 'لا يوجد فواتير أو مدفوعات',
        subtitle: 'لم يتم إصدار فواتير بيع أو تسجيل حركات دفع لهذا العميل بعد',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (invoices.isNotEmpty) ...[
          const Text(
            'فواتير العميل',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          ...invoices.map((inv) {
            final double total = (inv['total_amount'] as num?)?.toDouble() ?? 0.0;
            final double paid = (inv['amount_paid'] as num?)?.toDouble() ?? 0.0;
            final double due = total - paid;
            final type = inv['invoice_type'] ?? 'sale';
            final isReturn = type == 'return';
            final status = inv['status'] ?? 'draft';

            // تحديد اللون بناءً على حالة الفاتورة
            Color statusColor;
            switch (status) {
              case 'paid':
                statusColor = Colors.green;
              case 'partially_paid':
                statusColor = Colors.orange;
              case 'confirmed':
                statusColor = AppColors.primary;
              case 'draft':
                statusColor = AppColors.textSecondary;
              default:
                statusColor = AppColors.textSecondary;
            }
            if (isReturn) statusColor = AppColors.error;

            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ListTile(
                onTap: () => context.push('/invoice/${inv['id']}'),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isReturn
                        ? Icons.assignment_return_outlined
                        : status == 'paid'
                            ? Icons.check_circle_outline_rounded
                            : Icons.receipt_outlined,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  isReturn
                      ? 'مرتجع #${inv['invoice_number'] ?? ""}'
                      : 'فاتورة #${inv['invoice_number'] ?? ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  isReturn
                      ? 'مرتجع معتمد بقيمة ${total.abs().toStringAsFixed(0)} ج.م'
                      : '${_invoiceStatusLabel(status)} · متبقي: ${due.clamp(0.0, double.infinity).toStringAsFixed(0)} ج.م',
                  style: TextStyle(color: statusColor.withValues(alpha: 0.8), fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${total.abs().toStringAsFixed(0)} ج.م',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                    if (!isReturn && status != 'paid' && due > 0) ...[
                      Text(
                        'باقي ${due.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.error.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      InkWell(
                        onTap: () => _showRecordPaymentDialog(
                          customer: customer,
                          defaultAmount: due,
                          targetInvoiceId: inv['id']?.toString(),
                        ),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'سداد ⚡',
                            style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (payments.isNotEmpty) ...[
          const Text(
            'حركات الدفع المستلمة',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          ...payments.map((p) {
            final double amount = (p['amount'] as num?)?.toDouble() ?? 0.0;
            final method = p['payment_method'] ?? 'cash';
            final notes = p['notes'] ?? '';
            final dateStr = p['created_at'] ?? '';
            String formattedDate = '';
            if (dateStr.isNotEmpty) {
              final dt = DateTime.parse(dateStr);
              formattedDate = intl.DateFormat('yyyy/MM/dd HH:mm').format(dt);
            }

            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                title: Text(
                  'دفعة مستلمة بقيمة ${amount.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                ),
                subtitle: Text(
                  'طريقة الدفع: ${_translatePaymentMethod(method)} ${notes.isNotEmpty ? "($notes)" : ""}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: Text(
                  formattedDate,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ─── TAB 3: PROJECTS & QUOTES ──────────────────────────────────────────────
  Widget _buildProjectsTab(Map<String, dynamic> customer) {
    final projects = customer['projects'] as List? ?? [];
    final quotes = customer['quotes'] as List? ?? [];

    if (projects.isEmpty && quotes.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.folder_open_outlined,
        title: 'لا يوجد مشاريع أو عروض أسعار',
        subtitle: 'أنشئ أول مشروع أو عرض سعر مخصص لهذا العميل لتوثيق قياساته وأسعاره',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (projects.isNotEmpty) ...[
          const Text(
            'المشاريع والقياسات الحالية',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          ...projects.map((p) {
            final status = p['status'] ?? 'pending';
            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => context.push('/project/${p['id']}'),
                leading: const Icon(Icons.architecture_rounded, color: AppColors.primary),
                title: Text(
                  p['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'الحالة: ${_projectStatusLabel(status)}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (quotes.isNotEmpty) ...[
          const Text(
            'عروض الأسعار المقدمة',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          ...quotes.map((q) {
            final status = q['status'] ?? 'draft';
            final double amount = (q['total_amount'] as num?)?.toDouble() ?? 0.0;
            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => context.push('/quote/${q['id']}'),
                leading: const Icon(Icons.receipt_long_rounded, color: AppColors.info),
                title: Text(
                  q['quote_number'] ?? 'عرض سعر',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'حالة العرض: ${_quoteStatusLabel(status)}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: Text(
                  '${amount.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ─── TAB 4: FINANCIAL LEDGER & PDF EXPORT ──────────────────────────────────
  Widget _buildLedgerTab(Map<String, dynamic> customer) {
    final ledgerAsync = ref.watch(customerLedgerProvider(widget.customerId));

    return ledgerAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.menu_book_rounded,
            title: 'كشف الحساب فارغ',
            subtitle: 'لا يوجد قيود مالية مسجلة في كشف حساب العميل لتوليد التقرير',
          );
        }

        return Column(
          children: [
            // PDF Action button header
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _exportLedgerPdf(customer, entries),
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                label: const Text(
                  'تصدير كشف حساب PDF ومشاركته',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // Ledger headers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surfaceVariant,
              child: const Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(flex: 3, child: Text('تفاصيل الحركة', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('مدين (+)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('دائن (-)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('الرصيد', textAlign: TextAlign.left, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            // Entries List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  final desc = e['description'] ?? '';
                  final double debit = (e['debit'] as num?)?.toDouble() ?? 0.0;
                  final double credit = (e['credit'] as num?)?.toDouble() ?? 0.0;
                  final double balance = (e['balance'] as num?)?.toDouble() ?? 0.0;
                  final dateStr = e['date'] ?? '';
                  String formattedDate = '';
                  if (dateStr.isNotEmpty) {
                    final dt = DateTime.parse(dateStr);
                    formattedDate = intl.DateFormat('yyyy/MM/dd').format(dt);
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.8)),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        // Details
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                desc,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedDate,
                                style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        // Debit (Debts client owes us)
                        Expanded(
                          flex: 2,
                          child: Text(
                            debit > 0 ? debit.toStringAsFixed(0) : '—',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: debit > 0 ? AppColors.error : AppColors.textTertiary,
                              fontWeight: debit > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Credit (Payments client paid)
                        Expanded(
                          flex: 2,
                          child: Text(
                            credit > 0 ? credit.toStringAsFixed(0) : '—',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: credit > 0 ? Colors.green : AppColors.textTertiary,
                              fontWeight: credit > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Running balance
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${balance.toStringAsFixed(0)} ج.م',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: balance > 0 ? AppColors.primary : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingWidget(message: 'جاري تحميل كشف الحساب والقيود...'),
      error: (e, _) => AppErrorWidget(
        message: 'فشل تحميل كشف حساب العميل',
        onRetry: _refreshData,
      ),
    );
  }

  // ─── Direct payment dialogue (Smart Luxury Experience) ─────────────────────
  void _showRecordPaymentDialog({
    required Map<String, dynamic> customer,
    double? defaultAmount,
    String? targetInvoiceId,
  }) {
    final name = customer['name'] ?? 'العميل';
    final phone = (customer['phone'] ?? '').toString().trim();
    final double totalDebt = (customer['total_debt'] as num?)?.toDouble() ?? 0.0;
    final invoices = customer['invoices'] as List? ?? [];

    final unpaidInvoices = invoices.where((inv) {
      final double total = (inv['total_amount'] as num?)?.toDouble() ?? 0.0;
      final double paid = (inv['amount_paid'] as num?)?.toDouble() ?? 0.0;
      final double due = total - paid;
      final status = inv['status'] ?? '';
      return (status == 'confirmed' || status == 'partially_paid') && due > 0.001;
    }).toList();

    final amountCtrl = TextEditingController(
      text: defaultAmount != null && defaultAmount > 0
          ? (defaultAmount == defaultAmount.truncateToDouble()
              ? defaultAmount.toInt().toString()
              : defaultAmount.toStringAsFixed(2))
          : (totalDebt > 0
              ? (totalDebt == totalDebt.truncateToDouble()
                  ? totalDebt.toInt().toString()
                  : totalDebt.toStringAsFixed(2))
              : ''),
    );
    final referenceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    String selectedMethod = 'cash';
    String selectedInvoice = targetInvoiceId ?? 'auto';
    bool sendWhatsAppReceipt = phone.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          final double currentInputAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
          final double projectedRemaining = (totalDebt - currentInputAmount).clamp(0.0, double.infinity);
          final double excessAmount = (currentInputAmount - totalDebt).clamp(0.0, double.infinity);

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 580,
              constraints: const BoxConstraints(maxHeight: 780),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Header with Gradient & Customer Snapshot
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: totalDebt > 0
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: totalDebt > 0
                                    ? AppColors.gold.withValues(alpha: 0.3)
                                    : AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.payments_rounded,
                              color: totalDebt > 0 ? AppColors.gold : AppColors.success,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تسجيل دفعة سداد جديدة',
                                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      'العميل: $name',
                                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: totalDebt > 0
                                            ? AppColors.error.withValues(alpha: 0.12)
                                            : AppColors.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: totalDebt > 0
                                              ? AppColors.error.withValues(alpha: 0.3)
                                              : AppColors.success.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        totalDebt > 0
                                            ? 'المستحق: ${totalDebt.toStringAsFixed(0)} ج.م'
                                            : 'الحساب خالص تماماً (0 ج)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: totalDebt > 0 ? AppColors.error : AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 22),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // 2. Scrollable Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // حقل المبلغ البارز
                            const Text(
                              'قيمة المبلغ المستلم',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryLight),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                suffixIcon: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: const Text('ج.م', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    amountCtrl.clear();
                                    setStateDialog(() {});
                                  },
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              onChanged: (_) => setStateDialog(() {}),
                            ),
                            const SizedBox(height: 10),

                            // كبسولات الاختيار السريع
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (totalDebt > 0) ...[
                                  ActionChip(
                                    label: Text('⚡ كامل المستحق (${totalDebt.toStringAsFixed(0)} ج)',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                    backgroundColor: AppColors.primary,
                                    onPressed: () {
                                      amountCtrl.text = totalDebt == totalDebt.truncateToDouble()
                                          ? totalDebt.toInt().toString()
                                          : totalDebt.toStringAsFixed(2);
                                      setStateDialog(() {});
                                    },
                                  ),
                                  ActionChip(
                                    label: Text('50% (${(totalDebt * 0.5).toStringAsFixed(0)} ج)',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    backgroundColor: AppColors.surfaceVariant,
                                    side: BorderSide(color: AppColors.border),
                                    onPressed: () {
                                      final half = (totalDebt * 0.5).round();
                                      amountCtrl.text = half.toString();
                                      setStateDialog(() {});
                                    },
                                  ),
                                  ActionChip(
                                    label: Text('25% (${(totalDebt * 0.25).toStringAsFixed(0)} ج)',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    backgroundColor: AppColors.surfaceVariant,
                                    side: BorderSide(color: AppColors.border),
                                    onPressed: () {
                                      final quart = (totalDebt * 0.25).round();
                                      amountCtrl.text = quart.toString();
                                      setStateDialog(() {});
                                    },
                                  ),
                                ],
                                ...[500, 1000, 2000, 5000].map((step) => ActionChip(
                                      label: Text('+$step', style: const TextStyle(fontSize: 11.5)),
                                      backgroundColor: AppColors.surfaceVariant,
                                      side: BorderSide(color: AppColors.border),
                                      onPressed: () {
                                        final cur = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                        final next = cur + step;
                                        amountCtrl.text = next == next.truncateToDouble()
                                            ? next.toInt().toString()
                                            : next.toStringAsFixed(2);
                                        setStateDialog(() {});
                                      },
                                    )),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // محاكي الحساب الحي (Live Financial Projection)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: currentInputAmount <= 0
                                    ? AppColors.surfaceVariant
                                    : (totalDebt > 0 && currentInputAmount >= totalDebt)
                                        ? AppColors.success.withValues(alpha: 0.12)
                                        : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: currentInputAmount <= 0
                                      ? AppColors.border
                                      : (totalDebt > 0 && currentInputAmount >= totalDebt)
                                          ? AppColors.success.withValues(alpha: 0.35)
                                          : AppColors.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    currentInputAmount <= 0
                                        ? Icons.info_outline_rounded
                                        : (totalDebt > 0 && currentInputAmount >= totalDebt)
                                            ? Icons.check_circle_rounded
                                            : Icons.calculate_outlined,
                                    size: 20,
                                    color: currentInputAmount <= 0
                                        ? AppColors.textSecondary
                                        : (totalDebt > 0 && currentInputAmount >= totalDebt)
                                            ? AppColors.success
                                            : AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      currentInputAmount <= 0
                                          ? 'أدخل المبلغ المستلم لعرض أثر السداد على مديونية العميل'
                                          : (totalDebt > 0 && currentInputAmount == totalDebt)
                                              ? '🎉 رائع! سيصبح حساب العميل خالصاً تماماً بالكامل (صفر مديونية).'
                                              : (totalDebt > 0 && currentInputAmount > totalDebt)
                                                  ? '🌟 سداد كامل المديونية + رصيد دائن إضافي (+${excessAmount.toStringAsFixed(0)} ج.م) كدفعة مقدمة.'
                                                  : (totalDebt > 0)
                                                      ? '📊 سيتبقى بعد هذه الدفعة: ${projectedRemaining.toStringAsFixed(0)} ج.م مستحق على العميل.'
                                                      : '🌟 سيتم تسجيل المبلغ (+${currentInputAmount.toStringAsFixed(0)} ج.م) كرصيد دائن / دفعة مقدمة تحت الحساب.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: currentInputAmount <= 0
                                            ? AppColors.textSecondary
                                            : (totalDebt > 0 && currentInputAmount >= totalDebt)
                                                ? AppColors.success
                                                : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // قنوات وطرق الدفع المرئية (Visual Payment Channels)
                            const Text(
                              'طريقة الاستلام والدفع (الخزينة النشطة)',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildPaymentMethodGrid(selectedMethod, (m) => setStateDialog(() => selectedMethod = m)),
                            const SizedBox(height: 14),

                            // رقم المرجع / التحويل إن لم يكن كاش
                            if (selectedMethod != 'cash') ...[
                              TextField(
                                controller: referenceCtrl,
                                style: TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: selectedMethod == 'cheque'
                                      ? 'رقم الشيك وتاريخ الاستحقاق *'
                                      : 'رقم المرجع / العملية / التحويل (InstaPay أو المحفظة)',
                                  prefixIcon: const Icon(Icons.pin_rounded, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // تخصيص الدفعة (فواتير)
                            if (unpaidInvoices.length > 1) ...[
                              const Text(
                                'توجيه وتخصيص الدفعة',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedInvoice,
                                dropdownColor: AppColors.surfaceVariant,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.alt_route_rounded),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'auto',
                                    child: Text('⚡ توزيع ذكي تلقائي (الأقدم فالأحدث - FIFO)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ),
                                  ...unpaidInvoices.map((inv) {
                                    final total = (inv['total_amount'] as num?)?.toDouble() ?? 0.0;
                                    final paid = (inv['amount_paid'] as num?)?.toDouble() ?? 0.0;
                                    final due = (total - paid).clamp(0.0, double.infinity);
                                    return DropdownMenuItem(
                                      value: inv['id'].toString(),
                                      child: Text(
                                        'فاتورة #${inv['invoice_number'] ?? ""} (متبقي: ${due.toStringAsFixed(0)} ج)',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  if (val != null) setStateDialog(() => selectedInvoice = val);
                                },
                              ),
                              const SizedBox(height: 14),
                            ],

                            // ملاحظات
                            TextField(
                              controller: notesCtrl,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'ملاحظات إضافية على السند (اختياري)',
                                prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // خيار إرسال إشعار وسند قبض عبر واتساب
                            if (phone.isNotEmpty) ...[
                              InkWell(
                                onTap: () => setStateDialog(() => sendWhatsAppReceipt = !sendWhatsAppReceipt),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: sendWhatsAppReceipt,
                                        activeColor: const Color(0xFF25D366),
                                        onChanged: (val) => setStateDialog(() => sendWhatsAppReceipt = val ?? false),
                                      ),
                                      const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'إرسال سند قبض وإشعار بالرصيد للعميل عبر واتساب 📲',
                                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF25D366)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 3. Actions Footer
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('إلغاء', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: currentInputAmount <= 0
                                ? null
                                : () async {
                                    final double amt = currentInputAmount;
                                    final messenger = ScaffoldMessenger.of(context);
                                    try {
                                      final repo = ref.read(customerRepositoryProvider);
                                      await repo.recordDirectPayment(
                                        customerId: widget.customerId,
                                        amount: amt,
                                        paymentMethod: selectedMethod,
                                        referenceNumber: referenceCtrl.text.trim().isEmpty ? null : referenceCtrl.text.trim(),
                                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                                        specificInvoiceId: selectedInvoice == 'auto' ? null : selectedInvoice,
                                      );

                                      _refreshData();
                                      if (!ctx.mounted) return;
                                      Navigator.pop(ctx);

                                      // إرسال واتساب إن كان مفعل
                                      if (sendWhatsAppReceipt && phone.isNotEmpty) {
                                        final double newBalance = (totalDebt - amt).clamp(0.0, double.infinity);
                                        final methodArabic = _translatePaymentMethod(selectedMethod);
                                        final refText = referenceCtrl.text.trim().isNotEmpty
                                            ? '\n🔖 رقم المرجع: ${referenceCtrl.text.trim()}'
                                            : '';
                                        final msg = '🧾 *سند استلام دفعة سداد — معرض السويدي للديكور*\n'
                                            '━━━━━━━━━━━━━━━━━\n'
                                            'عزيزنا أ/ $name المحترم،\n'
                                            'تم بحمد الله استلام دفعة سداد وتحديث حسابكم لدينا:\n'
                                            '💰 المبلغ المستلم: ${amt.toStringAsFixed(0)} ج.م\n'
                                            '💳 طريقة الدفع: $methodArabic$refText\n'
                                            '📅 التاريخ: ${intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}\n'
                                            '📊 المتبقي المستحق: ${newBalance <= 0 ? "0.00 ج.م (خالص تماماً 🎉)" : "${newBalance.toStringAsFixed(0)} ج.م"}\n\n'
                                            'شاكرين لكم حسن تعاونكم وثقتكم الغالية! 🌟';

                                        String formattedPhone = phone.replaceAll(' ', '').replaceAll('-', '');
                                        if (formattedPhone.startsWith('0')) formattedPhone = '2$formattedPhone';
                                        if (!formattedPhone.startsWith('2') && formattedPhone.length == 10) formattedPhone = '20$formattedPhone';
                                        _launchUrlHelper('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(msg)}');
                                      }

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('تم بنجاح تسجيل دفعة السداد بقيمة ${amt.toStringAsFixed(0)} ج.م وتغذية الخزينة!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    } catch (e) {
                                      messenger.showSnackBar(
                                        SnackBar(content: Text('فشل تسجيل الدفعة: $e'), backgroundColor: AppColors.error),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.flash_on_rounded, size: 18),
                            label: Text(
                              currentInputAmount > 0
                                  ? 'تأكيد واستلام (${currentInputAmount.toStringAsFixed(0)} ج) ⚡'
                                  : 'تأكيد واستلام الدفعة',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodGrid(String selected, ValueChanged<String> onSelected) {
    final channels = [
      {'id': 'cash', 'label': 'نقداً (كاش)', 'sub': 'الخزينة', 'icon': Icons.payments_rounded, 'color': AppColors.success},
      {'id': 'instapay', 'label': 'إنستاباي', 'sub': 'InstaPay', 'icon': Icons.bolt_rounded, 'color': const Color(0xFFF59E0B)},
      {'id': 'vodafone_cash', 'label': 'محفظة كاش', 'sub': 'فودافون/أورنج', 'icon': Icons.phone_android_rounded, 'color': const Color(0xFFEF4444)},
      {'id': 'pos_card', 'label': 'بطاقة بنكية', 'sub': 'فيزا POS', 'icon': Icons.credit_card_rounded, 'color': const Color(0xFF3B82F6)},
      {'id': 'bank_transfer', 'label': 'تحويل بنكي', 'sub': 'حساب بنكي', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF8B5CF6)},
      {'id': 'cheque', 'label': 'شيك بنكي', 'sub': 'أجل / مقاصة', 'icon': Icons.description_rounded, 'color': const Color(0xFF64748B)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final ch = channels[index];
        final isSel = selected == ch['id'];
        final color = ch['color'] as Color;

        return InkWell(
          onTap: () => onSelected(ch['id'] as String),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSel ? color.withValues(alpha: 0.15) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? color : AppColors.border,
                width: isSel ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(ch['icon'] as IconData, size: 20, color: isSel ? color : AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ch['label'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ch['sub'] != null)
                        Text(
                          ch['sub'] as String,
                          style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Export statement to PDF and share ─────────────────────────────────────
  void _exportLedgerPdf(Map<String, dynamic> customer, List<Map<String, dynamic>> entries) async {
    try {
      final pdfBytes = await CustomerLedgerPdfGenerator.generate(
        customer: customer,
        ledgerEntries: entries,
        shopName: 'السويدي للديكور والمقاولات',
        shopPhone: '01000000000',
        shopAddress: 'القاهرة، جمهورية مصر العربية',
      );

      final tempDir = await getTemporaryDirectory();
      final nameCleaned = (customer['name'] ?? 'client').toString().replaceAll(' ', '_');
      final file = File('${tempDir.path}/كشف_حساب_$nameCleaned.pdf');
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'كشف حساب مالي — ${customer['name']}',
          subject: 'كشف حساب — ${customer['name']}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تصدير كشف الحساب: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ─── Update customer info dialog ───────────────────────────────────────────
  void _editCustomer(Map<String, dynamic> customer) async {
    final nameCtrl = TextEditingController(text: customer['name'] ?? '');
    final phoneCtrl = TextEditingController(text: customer['phone'] ?? '');
    final addressCtrl = TextEditingController(text: customer['address'] ?? customer['location'] ?? '');
    final notesCtrl = TextEditingController(text: customer['notes'] ?? '');
    String type = customer['type'] ?? 'regular';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تعديل بيانات العميل', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'الاسم *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'التليفون',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: AppColors.textPrimary),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Text('تصنيف العميل:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ChoiceChip(
                      label: const Text('VIP'),
                      selected: type == 'VIP',
                      onSelected: (selected) {
                        setStateDialog(() {
                          type = selected ? 'VIP' : 'regular';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('عادي'),
                      selected: type == 'regular',
                      onSelected: (selected) {
                        setStateDialog(() {
                          type = selected ? 'regular' : 'VIP';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: AppColors.textPrimary),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                try {
                  final repo = ref.read(customerRepositoryProvider);
                  await repo.updateCustomer(customer['id'], {
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'location': addressCtrl.text.trim(),
                    'notes': notesCtrl.text.trim(),
                    'type': type,
                  });
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل الحفظ: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    notesCtrl.dispose();

    if (result == true) {
      _refreshData();
    }
  }

  // ─── Status string localization helper functions ───────────────────────────
  String _invoiceStatusLabel(String s) {
    const m = {
      'draft': 'مسودة',
      'confirmed': 'بانتظار السداد',
      'partially_paid': 'مسدد جزئياً',
      'paid': 'مدفوع بالكامل',
      'cancelled': 'ملغاة',
    };
    return m[s] ?? s;
  }

  String _projectStatusLabel(String s) {
    const m = {
      'pending': 'مُعلّق (انتظار)',
      'in_progress': 'جارِ العمل',
      'completed': 'مكتمل بنجاح',
      'cancelled': 'ملغي',
    };
    return m[s] ?? s;
  }

  String _quoteStatusLabel(String s) {
    const m = {
      'draft': 'مسودة عرض',
      'sent': 'مُرسل للعميل',
      'approved': 'مقبول ومعتمد',
      'rejected': 'مرفوض من العميل',
    };
    return m[s] ?? s;
  }

  String _translatePaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'bank_transfer':
        return 'تحويل بنكي / محفظة الكترونية';
      case 'cheque':
        return 'شيك';
      default:
        return method;
    }
  }
}

// ─── Overview Stat Card Widget ───────────────────────────────────────────────
class _OverviewStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.surface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Smart Action Button Widget ──────────────────────────────────────────────
class _SmartActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmartActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
