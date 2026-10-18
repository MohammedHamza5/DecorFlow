import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:go_router/go_router.dart';

class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterInvoices(List<Map<String, dynamic>> all) {
    var list = all;

    // فلتر الحالة أو النوع
    if (_statusFilter == 'cash_sales') {
      list = list.where((inv) {
        final custId = inv['customer_id']?.toString() ?? '';
        final custName = ((inv['customer'] as Map?)?['name'] ?? '').toString();
        return custId == 'cash_customer' ||
            custName.contains('نقدي') ||
            custName.isEmpty ||
            inv['status'] == 'paid';
      }).toList();
    } else if (_statusFilter == 'returns') {
      list = list.where((inv) => inv['invoice_type'] == 'return').toList();
    } else if (_statusFilter != 'all') {
      list = list.where((inv) => inv['status'] == _statusFilter && inv['invoice_type'] != 'return').toList();
    }

    // فلتر البحث — يبحث في اسم العميل ورقم الفاتورة
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((inv) {
        final invNumber = (inv['invoice_number'] ?? '').toString().toLowerCase();
        final customer = inv['customer'] as Map<String, dynamic>?;
        final customerName = (customer?['name'] ?? 'عميل نقدي (كاش)').toString().toLowerCase();
        final customerPhone = (customer?['phone'] ?? '').toString().toLowerCase();
        return invNumber.contains(q) ||
            customerName.contains(q) ||
            customerPhone.contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الفواتير والتحصيلات'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(invoicesProvider),
          ),
          FilledButton.icon(
            onPressed: () => context.push('/smart-invoice'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('فاتورة جديدة'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'invoices_list_fab',
        onPressed: () => context.push('/smart-invoice'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text(
          'فاتورة جديدة ⚡',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          final filtered = _filterInvoices(invoices);
          return ConstrainedBody(
            child: Column(
              children: [
              // ─── Search + Filter Bar ──────────────────────────
              _buildSearchBar(invoices),
              // ─── Stats Row ────────────────────────────────────
              _buildStatsRow(filtered),
              // ─── List ─────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _buildInvoiceCard(context, filtered[index]),
                      ),
              ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('خطأ في تحميل الفواتير', style: TextStyle(color: AppColors.error)),
              TextButton(
                onPressed: () => ref.invalidate(invoicesProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(List<Map<String, dynamic>> all) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // حقل البحث
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'ابحث برقم الفاتورة أو اسم العميل أو هاتفه...',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              prefixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: const Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary, size: 18),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 10),
          // فلاتر الحالة
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'الكل', Icons.list_alt_rounded),
                _filterChip('cash_sales', 'مبيعات نقدية 💵', Icons.point_of_sale_rounded),
                _filterChip('returns', 'مرتجعات ↩', Icons.assignment_return_rounded),
                _filterChip('confirmed', 'بانتظار السداد', Icons.hourglass_top_rounded),
                _filterChip('partially_paid', 'جزئي', Icons.pie_chart_outline_rounded),
                _filterChip('paid', 'مكتمل', Icons.check_circle_outline_rounded),
                _filterChip('draft', 'مسودة', Icons.edit_note_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, IconData icon) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          setState(() => _statusFilter = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 15,
                  color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<Map<String, dynamic>> filtered) {
    double totalAmount = 0;
    double totalDue = 0;
    for (final inv in filtered) {
      final total = (inv['total_amount'] as num?)?.toDouble() ?? 0;
      final paid = (inv['paid_amount'] as num?)?.toDouble() ?? 0;
      totalAmount += total;
      totalDue += (total - paid).clamp(0.0, double.infinity);
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _miniStat(
              '${filtered.length} فاتورة',
              Icons.receipt_long_rounded,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniStat(
              '${totalAmount.toStringAsFixed(0)} ج.م',
              Icons.attach_money_rounded,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniStat(
              '${totalDue.toStringAsFixed(0)} ج.م متبقي',
              Icons.warning_amber_rounded,
              totalDue > 0 ? AppColors.error : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Map<String, dynamic> inv) {
    final customer = inv['customer'] as Map<String, dynamic>?;
    final double total = (inv['total_amount'] as num?)?.toDouble() ?? 0;
    final double paid = (inv['paid_amount'] as num?)?.toDouble() ?? 0;
    final double due = (total - paid).clamp(0.0, double.infinity);
    final String status = inv['status'] ?? 'draft';
    final String invNumber = inv['invoice_number'] ?? '';
    final isReturn = inv['invoice_type'] == 'return';

    // ألوان الحالة
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'paid':
        statusColor = Colors.green;
        statusLabel = 'مكتمل الدفع';
        statusIcon = Icons.check_circle_rounded;
      case 'partially_paid':
        statusColor = Colors.orange;
        statusLabel = 'مدفوع جزئياً';
        statusIcon = Icons.pie_chart_rounded;
      case 'confirmed':
        statusColor = AppColors.primary;
        statusLabel = 'بانتظار السداد';
        statusIcon = Icons.hourglass_top_rounded;
      case 'draft':
        statusColor = AppColors.textSecondary;
        statusLabel = 'مسودة';
        statusIcon = Icons.edit_note_rounded;
      default:
        statusColor = AppColors.textSecondary;
        statusLabel = status;
        statusIcon = Icons.receipt_rounded;
    }
    if (isReturn) {
      statusColor = AppColors.error;
      statusLabel = 'مرتجع';
      statusIcon = Icons.assignment_return_rounded;
    }

    // تمييز نص البحث في رقم الفاتورة
    final highlightQ = _searchQuery.trim();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.25), width: 1),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => InvoiceDetailScreen(invoiceId: inv['id'])),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: رقم الفاتورة + Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _highlightText(
                          invNumber,
                          highlightQ,
                          const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Builder(
                          builder: (context) {
                            final rawName = (customer?['name'] as String?)?.trim();
                            final isNamedCustomer = rawName != null && rawName.isNotEmpty;
                            final displayName = isNamedCustomer ? rawName : 'عميل نقدي (كاش)';
                            return Row(
                              children: [
                                Icon(
                                  isNamedCustomer
                                      ? Icons.person_outline_rounded
                                      : Icons.point_of_sale_rounded,
                                  size: 13,
                                  color: isNamedCustomer
                                      ? AppColors.textSecondary
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _highlightText(
                                    displayName,
                                    highlightQ,
                                    TextStyle(
                                      fontSize: 12,
                                      color: isNamedCustomer
                                          ? AppColors.textSecondary
                                          : AppColors.primary,
                                      fontWeight: isNamedCustomer
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (inv['invoice_type'] == 'return') ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: const Text('فاتورة مرتجع', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 0.8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2: الأرقام
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _amountCell('الإجمالي', total, AppColors.textPrimary),
                    Container(width: 1, height: 28, color: AppColors.darkBorder),
                    _amountCell('المدفوع', paid, Colors.green),
                    Container(width: 1, height: 28, color: AppColors.darkBorder),
                    _amountCell(
                      'المتبقي',
                      due,
                      due > 0 ? AppColors.error : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Row 3: التاريخ
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy/MM/dd').format(
                        DateTime.parse(inv['created_at']).toLocal()),
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                  const Spacer(),
                  if (customer?['phone'] != null && (customer?['phone'] as String).isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.chat_rounded, size: 16),
                      tooltip: 'مراسلة العميل واتساب',
                      color: const Color(0xFF25D366),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        AppHaptics.light();
                        final phone = customer!['phone'] as String;
                        final name = customer['name'] ?? 'العميل';
                        final msg = 'مرحباً $name، نود تذكيرك بتفاصيل الفاتورة رقم $invNumber بإجمالي ${total.toStringAsFixed(0)} ج.م (المتبقي: ${due.toStringAsFixed(0)} ج.م) من السويدي للديكور.';
                        AppContactActions.launchWhatsApp(
                          context: context,
                          phone: phone,
                          text: msg,
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    tooltip: 'تصدير PDF',
                    color: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      AppHaptics.light();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailScreen(invoiceId: inv['id']),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountCell(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          '${amount.toStringAsFixed(0)} ج.م',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
      ],
    );
  }

  /// يُبرز النص المطابق لاستعلام البحث بلون ذهبي
  Widget _highlightText(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) return Text(text, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return Text(text, style: baseStyle);

    return Text.rich(
      TextSpan(
        children: [
          if (index > 0)
            TextSpan(text: text.substring(0, index), style: baseStyle),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: baseStyle.copyWith(
              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (index + query.length < text.length)
            TextSpan(
                text: text.substring(index + query.length), style: baseStyle),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'لا توجد نتائج لـ "$_searchQuery"'
                : 'لا توجد فواتير في هذه الحالة',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('مسح البحث'),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ],
        ],
      ),
    );
  }
}
