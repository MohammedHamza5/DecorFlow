import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Quotes list screen — view, search, and manage all quotes with 1-tap quick actions.
class QuotesListScreen extends ConsumerStatefulWidget {
  const QuotesListScreen({super.key});

  @override
  ConsumerState<QuotesListScreen> createState() => _QuotesListScreenState();
}

class _QuotesListScreenState extends ConsumerState<QuotesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const _tabs = [
    (label: 'الكل', status: null),
    (label: 'مسودة', status: 'draft'),
    (label: 'مُرسل', status: 'sent'),
    (label: 'مقبول', status: 'approved'),
    (label: 'مرفوض', status: 'rejected'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('عروض الأسعار', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () {
              AppHaptics.light();
              for (final tab in _tabs) {
                ref.invalidate(quotesProvider(tab.status));
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          onTap: (_) {
            AppHaptics.selection();
            setState(() {});
          },
        ),
      ),
      body: Column(
        children: [
          // ─── Search Bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث برقم العرض أو اسم العميل أو هاتفه...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),

          // ─── POS vs Quote Guidance Banner ─────────────────────
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorderMid : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'عروض الأسعار هي مقايسات تقديرية للعميل. للبيع المباشر الفوري وخصم المخزون افتح "فاتورة بيع".',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => context.push('/smart-invoice'),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            'فاتورة بيع ⚡',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ─── Tab View ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs
                  .map((t) => _QuoteTab(status: t.status, searchQuery: _searchQuery))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createQuote(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('عرض سعر جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  void _createQuote() async {
    AppHaptics.light();
    final result = await context.push<bool>('/quote-builder');
    if (result == true) {
      for (final tab in _tabs) {
        ref.invalidate(quotesProvider(tab.status));
      }
    }
  }
}

class _QuoteTab extends ConsumerWidget {
  final String? status;
  final String searchQuery;

  const _QuoteTab({this.status, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quotesProvider(status));

    return quotesAsync.when(
      data: (quotes) {
        // Filter by search query
        var list = quotes;
        if (searchQuery.isNotEmpty) {
          list = list.where((q) {
            final numStr = (q['quote_number'] ?? '').toString().toLowerCase();
            final customer = q['customer'] as Map<String, dynamic>?;
            final custName = (customer?['name'] ?? '').toString().toLowerCase();
            final custPhone = (customer?['phone'] ?? '').toString().toLowerCase();
            return numStr.contains(searchQuery) ||
                custName.contains(searchQuery) ||
                custPhone.contains(searchQuery);
          }).toList();
        }

        if (list.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: searchQuery.isNotEmpty ? 'لا توجد نتائج مطابقة للبحث' : 'لا توجد عروض أسعار',
            subtitle: searchQuery.isNotEmpty ? 'جرّب البحث باسم أو رقم آخر' : 'أنشئ عرض سعر جديد من الحاسبة أو من هنا',
          );
        }

        final totalValue = list.fold<double>(0.0, (sum, q) => sum + ((q['final_total'] as num?)?.toDouble() ?? 0));

        return RefreshIndicator(
          onRefresh: () async {
            AppHaptics.light();
            return ref.invalidate(quotesProvider(status));
          },
          color: AppColors.primary,
          child: ConstrainedBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                // Summary Metrics Badge
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorderMid : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'عدد العروض: ${list.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'الإجمالي: ${totalValue.toStringAsFixed(0)} ج.م',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ...list.map((quote) => _QuoteCard(
                  quote: quote,
                  onTap: () => _openQuote(context, ref, quote),
                  onRefresh: () => ref.invalidate(quotesProvider(status)),
                )),
              ],
            ),
          ),
        );
      },
      loading: () => const LoadingWidget(message: 'جارِ تحميل العروض...'),
      error: (e, _) => AppErrorWidget(
        message: 'فشل تحميل العروض',
        onRetry: () => ref.invalidate(quotesProvider(status)),
      ),
    );
  }

  void _openQuote(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> quote,
  ) async {
    AppHaptics.light();
    final result = await context.push<bool>('/quote/${quote['id']}');
    if (result == true) {
      ref.invalidate(quotesProvider(status));
    }
  }
}

class _QuoteCard extends ConsumerWidget {
  final Map<String, dynamic> quote;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const _QuoteCard({
    required this.quote,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = quote['customer'] as Map<String, dynamic>?;
    final status = quote['status'] as String? ?? 'draft';
    final total = (quote['final_total'] as num?)?.toDouble() ?? 0;
    final itemCount = (quote['quote_items'] as List?)?.length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      color: AppColors.surface,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: _statusColor(status),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote['quote_number'] ?? 'عرض سعر',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (customer != null)
                          Text(
                            customer['name'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Bottom details and 1-tap quick actions
              Row(
                children: [
                  _infoItem(
                    context,
                    Icons.attach_money_rounded,
                    '${total.toStringAsFixed(0)} ج.م',
                    isHighlight: true,
                  ),
                  const SizedBox(width: 14),
                  _infoItem(context, Icons.format_list_numbered_rounded, '$itemCount بند'),
                  const SizedBox(width: 14),
                  // Validity Indicator
                  if (quote['valid_until'] != null) ...[
                    Builder(
                      builder: (context) {
                        final validUntil = DateTime.tryParse(quote['valid_until']);
                        if (validUntil == null) return const SizedBox.shrink();
                        final isExpired = validUntil.isBefore(DateTime.now());
                        final daysLeft = validUntil.difference(DateTime.now()).inDays;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isExpired
                                ? AppColors.error.withValues(alpha: 0.12)
                                : (daysLeft <= 2 ? AppColors.warning.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.12)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExpired ? Icons.event_busy_rounded : Icons.schedule_rounded,
                                size: 12,
                                color: isExpired ? AppColors.error : (daysLeft <= 2 ? AppColors.warning : AppColors.success),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isExpired ? 'منتهي الصلاحية' : (daysLeft == 0 ? 'ينتهي اليوم' : 'باقي $daysLeft يوم'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isExpired ? AppColors.error : (daysLeft <= 2 ? AppColors.warning : AppColors.success),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const Spacer(),
                  Text(
                    _formatDate(quote['created_at']),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quick action buttons bar
              Row(
                children: [
                  // Quick Convert to Invoice Button (High-Contrast Solid Action Button)
                  FilledButton.icon(
                    onPressed: () => _convertDirectlyToInvoice(context, ref),
                    icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'تحويل لفاتورة ⚡',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      elevation: isDark ? 2 : 1,
                      shadowColor: const Color(0xFF059669).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Spacer(),

                  // WhatsApp Share
                  if (customer?['phone'] != null && (customer?['phone'] as String).isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      tooltip: 'مشاركة واتساب',
                      color: const Color(0xFF25D366),
                      onPressed: () {
                        AppHaptics.light();
                        final phone = customer!['phone'] as String;
                        final text = 'مرحباً ${customer['name']}، مرفق عرض السعر رقم ${quote['quote_number']} بإجمالي ${total.toStringAsFixed(0)} ج.م من السويدي للديكور.';
                        AppContactActions.launchWhatsApp(
                          context: context,
                          phone: phone,
                          text: text,
                        );
                      },
                    ),

                  // View PDF Button
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    tooltip: 'عرض وتصدير PDF',
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    onPressed: () {
                      AppHaptics.light();
                      context.push('/quote/${quote['id']}/pdf');
                    },
                  ),

                  // Open Details in Studio
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 13,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    label: Text(
                      'فتح الاستوديو',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String label, {bool isHighlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = isHighlight
        ? (isDark ? AppColors.primaryLight : AppColors.primary)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: highlightColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: highlightColor,
          ),
        ),
      ],
    );
  }

  void _convertDirectlyToInvoice(BuildContext context, WidgetRef ref) async {
    AppHaptics.medium();
    final quoteId = quote['id'] as String;
    try {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      final newInvoice = await invoiceRepo.createInvoiceFromQuote(quoteId);
      if (context.mounted) {
        AppToast.showSuccess(context, 'تم تحويل المقايسة إلى فاتورة بيع بنجاح ⚡');
        ref.invalidate(invoicesProvider);
        onRefresh();
        context.push('/invoice/${newInvoice['id']}');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, 'فشل تحويل المقايسة لفاتورة: $e');
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppColors.quoteDraft;
      case 'sent':
        return AppColors.quoteSent;
      case 'approved':
        return AppColors.quoteApproved;
      case 'rejected':
        return AppColors.quoteRejected;
      case 'expired':
        return AppColors.quoteExpired;
      case 'revised':
        return AppColors.quoteRevised;
      default:
        return AppColors.quoteDraft;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'draft': 'مسودة',
      'sent': 'مُرسل',
      'approved': 'مقبول',
      'rejected': 'مرفوض',
      'expired': 'منتهي',
      'revised': 'مُعدّل',
    };
    final colors = {
      'draft': AppColors.quoteDraft,
      'sent': AppColors.quoteSent,
      'approved': AppColors.quoteApproved,
      'rejected': AppColors.quoteRejected,
      'expired': AppColors.quoteExpired,
      'revised': AppColors.quoteRevised,
    };
    final color = colors[status] ?? AppColors.quoteDraft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
