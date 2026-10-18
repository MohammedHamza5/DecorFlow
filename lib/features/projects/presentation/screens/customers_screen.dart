import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Customers list screen — main entry point for customer management.
/// Upgraded to premium dark theme, smart filters, financial status badges, and quick actions.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all' | 'has_debt' | 'VIP'
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch customers with financial data using the selected filter
    final customersAsync = ref.watch(customersWithFinancialsProvider(_selectedFilter));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إدارة العملاء',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(customersWithFinancialsProvider(_selectedFilter)),
          ),
        ],
      ),
      body: ConstrainedBody(
        child: Column(
          children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(
            child: customersAsync.when(
              data: (customers) => _buildList(customers),
              loading: () => const LoadingWidget(message: 'جاري تحميل قائمة العملاء والتحليلات...'),
              error: (e, _) => AppErrorWidget(
                message: 'فشل تحميل بيانات العملاء المالية',
                onRetry: () => ref.invalidate(customersWithFinancialsProvider(_selectedFilter)),
              ),
            ),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCustomer(),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'عميل جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo',
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        textDirection: TextDirection.rtl,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'بحث باسم العميل، رقم الهاتف، أو العنوان...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.primary),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'id': 'all', 'label': 'الكل', 'icon': Icons.people_rounded},
      {'id': 'has_debt', 'label': 'المدينين', 'icon': Icons.money_off_rounded},
      {'id': 'VIP', 'label': 'عملاء مميزين VIP', 'icon': Icons.star_rounded},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];
          final color = isSelected ? AppColors.primary : AppColors.textSecondary;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter['id'] as String;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
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

  Widget _buildList(List<Map<String, dynamic>> customers) {
    final filtered = _filter(customers);

    if (filtered.isEmpty) {
      return EmptyStateWidget(
        icon: _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.people_outline_rounded,
        title: _searchQuery.isNotEmpty ? 'لا توجد نتائج مطابقة' : 'لا يوجد عملاء في هذا التصنيف',
        subtitle: _searchQuery.isNotEmpty ? 'جرّب البحث بكلمة مختلفة أو اسم آخر' : 'أضف عميلك الأول لتبدأ بإدارته ومراقبة حساباته',
        actionLabel: _searchQuery.isEmpty ? 'إضافة عميل' : null,
        onAction: _searchQuery.isEmpty ? () => _addCustomer() : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customersWithFinancialsProvider(_selectedFilter));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final customer = filtered[index];
          return _CustomerCard(
            customer: customer,
            onTap: () => _openProfile(customer),
            onEdit: () => _editCustomer(customer),
            onDelete: () => _deleteCustomer(customer),
            onQuote: () => _createQuote(customer),
            onProject: () => _createProject(customer),
            onQuickInvoice: () => _quickInvoice(customer),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> customers) {
    if (_searchQuery.isEmpty) return customers;
    final q = _searchQuery.toLowerCase().trim();
    return customers.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      final phone = (c['phone'] ?? '').toString().toLowerCase();
      final address = (c['address'] ?? c['location'] ?? '').toString().toLowerCase();
      return name.contains(q) || phone.contains(q) || address.contains(q);
    }).toList();
  }

  void _openProfile(Map<String, dynamic> customer) async {
    final result = await context.push<bool>('/customer/${customer['id']}');
    if (result == true || result == null) {
      ref.invalidate(customersWithFinancialsProvider(_selectedFilter));
      ref.invalidate(customersProvider);
    }
  }

  void _addCustomer() async {
    final result = await _showCustomerDialog();
    if (result != null && result != false) {
      ref.invalidate(customersWithFinancialsProvider(_selectedFilter));
      ref.invalidate(customersProvider);
      
      if (result is Map<String, dynamic>) {
        if (!mounted) return;
        final customerName = result['name'] as String? ?? 'عميل';
        final customerId = result['id'] as String;
        final encodedName = Uri.encodeComponent(customerName);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة العميل "$customerName" بنجاح ✓', textDirection: TextDirection.rtl),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'بدء فاتورة الآن ⚡',
              textColor: AppColors.primary,
              onPressed: () {
                context.push('/smart-invoice/$customerId?name=$encodedName');
              },
            ),
          ),
        );
      }
    }
  }

  void _editCustomer(Map<String, dynamic> customer) async {
    final result = await _showCustomerDialog(existing: customer);
    if (result == true) {
      ref.invalidate(customersWithFinancialsProvider(_selectedFilter));
      ref.invalidate(customersProvider);
    }
  }

  void _deleteCustomer(Map<String, dynamic> customer) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'حذف العميل نهائياً',
      message: 'هل أنت متأكد من رغبتك في حذف العميل "${customer['name']}"؟\nسوف يتم إخفاء العميل نهائياً من القوائم والحسابات.',
      confirmLabel: 'حذف الآن',
      isDanger: true,
      icon: Icons.person_remove_rounded,
    );

    if (confirmed) {
      try {
        final repo = ref.read(customerRepositoryProvider);
        await repo.deleteCustomer(customer['id']);
        ref.invalidate(customersWithFinancialsProvider(_selectedFilter));
        ref.invalidate(customersProvider);
        if (mounted) {
          AppToast.showSuccess(context, 'تم حذف العميل بنجاح ✓');
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'فشل حذف العميل: $e');
        }
      }
    }
  }

  void _createQuote(Map<String, dynamic> customer) {
    context.push('/quote-builder', extra: {
      'customerId': customer['id'],
    });
  }

  void _quickInvoice(Map<String, dynamic> customer) {
    final name = Uri.encodeComponent(customer['name'] as String? ?? 'عميل');
    context.push('/smart-invoice/${customer['id']}?name=$name');
  }

  void _createProject(Map<String, dynamic> customer) {
    context.push('/projects', extra: {
      'customerId': customer['id'],
    });
  }

  Future<dynamic> _showCustomerDialog({Map<String, dynamic>? existing}) async {
    return AppBottomSheet.show<dynamic>(
      context: context,
      title: existing != null ? 'تعديل بيانات العميل' : 'إضافة عميل جديد',
      builder: (ctx) => _CustomerDialog(existing: existing),
    );
  }
}

class _CustomerDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;

  const _CustomerDialog({this.existing});

  @override
  ConsumerState<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends ConsumerState<_CustomerDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController addressCtrl;
  late final TextEditingController notesCtrl;
  String _customerType = 'regular'; // 'regular' | 'VIP'
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existing?['name'] ?? '');
    phoneCtrl = TextEditingController(text: widget.existing?['phone'] ?? '');
    addressCtrl = TextEditingController(text: widget.existing?['address'] ?? widget.existing?['location'] ?? '');
    notesCtrl = TextEditingController(text: widget.existing?['notes'] ?? '');
    _customerType = widget.existing?['type'] ?? 'regular';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameCtrl.text.trim().isEmpty) {
      AppToast.showInfo(context, 'يرجى إدخال اسم العميل');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(customerRepositoryProvider);
      final data = {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'location': addressCtrl.text.trim(),
        'notes': notesCtrl.text.trim(),
        'type': _customerType,
      };
      if (widget.existing != null) {
        await repo.updateCustomer(widget.existing!['id'], data);
        if (!mounted) return;
        AppToast.showSuccess(context, 'تم تحديث بيانات العميل ✓');
        Navigator.pop(context, true);
      } else {
        final created = await repo.createCustomer(data);
        if (!mounted) return;
        AppToast.showSuccess(context, 'تمت إضافة العميل بنجاح ✓');
        Navigator.pop(context, created);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, 'فشل الحفظ: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameCtrl,
          autofocus: !isEdit,
          textInputAction: TextInputAction.next,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: 'اسم العميل الكامل *',
            prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'رقم الهاتف (الواتساب)',
            hintText: '01xxxxxxxxx',
            prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressCtrl,
          textInputAction: TextInputAction.next,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'العنوان بالتفصيل',
            prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'تصنيف العميل:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('عميل عادي'),
                  selected: _customerType == 'regular',
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  side: BorderSide(
                    color: _customerType == 'regular' ? AppColors.primary : AppColors.border,
                  ),
                  onSelected: (selected) {
                    AppHaptics.selection();
                    setState(() => _customerType = 'regular');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('VIP مميز ⭐'),
                  selected: _customerType == 'VIP',
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: _customerType == 'VIP' ? AppColors.primary : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: _customerType == 'VIP' ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    AppHaptics.selection();
                    setState(() => _customerType = 'VIP');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: notesCtrl,
          textInputAction: TextInputAction.done,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'ملاحظات إضافية (اختياري)',
            prefixIcon: const Icon(Icons.note_rounded, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            isEdit ? 'حفظ التعديلات' : 'إضافة العميل وتفعيله',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

// ─── Customer Card with Rich Financial Info ──────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQuote;
  final VoidCallback onProject;
  final VoidCallback onQuickInvoice;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onQuote,
    required this.onProject,
    required this.onQuickInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final name = customer['name'] ?? '';
    final phone = customer['phone'] ?? '';
    final address = customer['address'] ?? customer['location'] ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final classTag = customer['class_tag'] ?? 'regular';

    final totalSales = (customer['total_sales'] as num?)?.toDouble() ?? 0.0;
    final totalDebt = (customer['total_debt'] as num?)?.toDouble() ?? 0.0;
    final invoiceCount = (customer['invoice_count'] as num?)?.toInt() ?? 0;

    final isVIP = classTag == 'VIP' || customer['type'] == 'VIP';
    final isDebtRisk = classTag == 'debt_risk';
    final hasDebt = totalDebt > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVIP
              ? AppColors.primary.withValues(alpha: 0.3)
              : isDebtRisk
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.border,
          width: isVIP || isDebtRisk ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row 1: Header (Avatar + Name/Tag + Action menu)
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isVIP
                                ? [AppColors.primary, AppColors.primaryDark]
                                : isDebtRisk
                                    ? [AppColors.error, AppColors.errorDark]
                                    : [
                                        AppColors.secondary.withValues(alpha: 0.8),
                                        AppColors.secondaryDark.withValues(alpha: 0.6),
                                      ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: isVIP ? Colors.black : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info & Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isVIP)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primary, width: 0.8),
                                    ),
                                    child: const Text(
                                      'VIP',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (isDebtRisk)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.error, width: 0.8),
                                    ),
                                    child: const Text(
                                      'مخاطر ديون عالية',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (phone.isNotEmpty)
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quick menu
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
                        iconSize: 22,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (v) {
                          if (v == 'quick_invoice') onQuickInvoice();
                          if (v == 'quote') onQuote();
                          if (v == 'project') onProject();
                          if (v == 'edit') onEdit();
                          if (v == 'delete') onDelete();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'quick_invoice',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('فاتورة سريعة ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.bolt_rounded, size: 18, color: Colors.amber),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'quote',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('إنشاء عرض سعر'),
                                SizedBox(width: 8),
                                Icon(Icons.receipt_long_outlined, size: 18),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'project',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('إنشاء مشروع مخصص'),
                                SizedBox(width: 8),
                                Icon(Icons.folder_outlined, size: 18),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('تعديل البيانات'),
                                SizedBox(width: 8),
                                Icon(Icons.edit_outlined, size: 18),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('حذف نهائياً', style: TextStyle(color: AppColors.error)),
                                SizedBox(width: 8),
                                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.darkBorder),
                  const SizedBox(height: 12),

                  // Row 2: Financial Stats Overview
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      // Debt card or badge
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasDebt
                                ? AppColors.error.withValues(alpha: 0.08)
                                : Colors.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasDebt
                                  ? AppColors.error.withValues(alpha: 0.15)
                                  : Colors.green.withValues(alpha: 0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                hasDebt ? 'المستحق المتبقي' : 'الرصيد المالي',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hasDebt ? AppColors.error : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasDebt ? '${totalDebt.toStringAsFixed(0)} ج.م' : 'خالص الذمة',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: hasDebt ? AppColors.error : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sales summary
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'حجم المعاملات',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${totalSales.toStringAsFixed(0)} ج.م',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Invoice Count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'الفواتير',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$invoiceCount',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Row 3: Address (if any)
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Quick Action Buttons Row (WhatsApp, Call, Invoice, Quote)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Contact shortcuts
                      Row(
                        children: [
                          if (phone.isNotEmpty) ...[
                            IconButton(
                              icon: const Icon(Icons.chat_rounded, size: 20),
                              tooltip: 'محادثة واتساب سريعة',
                              color: const Color(0xFF25D366),
                              onPressed: () {
                                AppHaptics.light();
                                AppContactActions.launchWhatsApp(
                                  context: context,
                                  phone: phone,
                                  text: 'مرحباً $name، نتواصل معك من السويدي للديكور.',
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone_rounded, size: 20),
                              tooltip: 'اتصال هاتفي',
                              color: AppColors.primary,
                              onPressed: () {
                                AppHaptics.light();
                                AppContactActions.callPhone(
                                  context: context,
                                  phone: phone,
                                );
                              },
                            ),
                          ],
                        ],
                      ),

                      // Business shortcuts
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              AppHaptics.light();
                              onQuote();
                            },
                            icon: const Icon(Icons.receipt_long_rounded, size: 15),
                            label: const Text('عرض سعر', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: () {
                              AppHaptics.light();
                              onQuickInvoice();
                            },
                            icon: const Icon(Icons.point_of_sale_rounded, size: 15),
                            label: const Text('فاتورة سريعة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              visualDensity: VisualDensity.compact,
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
        ),
      ),
    );
  }
}
