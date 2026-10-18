import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

class TechniciansScreen extends ConsumerStatefulWidget {
  const TechniciansScreen({super.key});

  @override
  ConsumerState<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends ConsumerState<TechniciansScreen> {
  @override
  Widget build(BuildContext context) {
    final techniciansAsync = ref.watch(techniciansListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة الفنيين والتركيبات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTechnicianSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('إضافة فني جديد'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.engineering_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سجل الفنيين', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('إدارة مستحقات الفنيين، حسابات التركيبات وتسوية الأرصدة.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          techniciansAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(child: Center(child: Text('خطأ: $e'))),
            data: (technicians) {
              if (technicians.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('لا يوجد فنيين مسجلين بعد.')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tech = technicians[index];
                    return _TechnicianCard(technician: tech);
                  },
                  childCount: technicians.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddTechnicianSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const _AddTechnicianForm(),
    );
  }
}

class _TechnicianCard extends ConsumerWidget {
  final Technician technician;
  
  const _TechnicianCard({required this.technician});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(technicianBalanceProvider(technician.id));
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person_rounded, color: AppColors.primary),
        ),
        title: Text(technician.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(technician.phone ?? 'بدون رقم', style: const TextStyle(fontSize: 12)),
        trailing: balanceAsync.when(
          data: (balance) {
            final color = balance > 0 ? AppColors.error : AppColors.success;
            return Text(
              '${NumberFormat.currency(locale: 'en_US', symbol: '').format(balance)} ج',
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
            );
          },
          loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, _) => const Icon(Icons.error, color: AppColors.error),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showStatementSheet(context, ref),
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text('كشف حساب'),
                ),
                FilledButton.icon(
                  onPressed: () => _showSettleSheet(context, ref),
                  icon: const Icon(Icons.payments_rounded),
                  label: const Text('دفع دفعة / تسوية'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showStatementSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _TechnicianStatementSheet(technician: technician),
    );
  }

  void _showSettleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _SettleBalanceForm(technician: technician),
    );
  }
}

class _AddTechnicianForm extends ConsumerStatefulWidget {
  const _AddTechnicianForm();
  @override
  ConsumerState<_AddTechnicianForm> createState() => _AddTechnicianFormState();
}

class _AddTechnicianFormState extends ConsumerState<_AddTechnicianForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const Text('تسجيل فني جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: 'اسم الفني', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: 'رقم الهاتف (اختياري)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
          
          FilledButton(
            onPressed: _isSaving ? null : () async {
              if (_nameCtrl.text.isEmpty) return;
              setState(() => _isSaving = true);
              
              final db = ref.read(erpDatabaseProvider);
              await db.into(db.technicians).insert(TechniciansCompanion.insert(
                name: _nameCtrl.text,
                phone: drift.Value(_phoneCtrl.text.isEmpty ? null : _phoneCtrl.text),
              ));
              
              ref.invalidate(techniciansListProvider);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الفني بنجاح')));
              }
            },
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ الفني', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _SettleBalanceForm extends ConsumerStatefulWidget {
  final Technician technician;
  const _SettleBalanceForm({required this.technician});

  @override
  ConsumerState<_SettleBalanceForm> createState() => _SettleBalanceFormState();
}

class _SettleBalanceFormState extends ConsumerState<_SettleBalanceForm> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(technicianBalanceProvider(widget.technician.id)).value ?? 0.0;
    final quickAmounts = [100, 200, 500, 1000];
    final quickNotes = ['تصفية حساب نهائية', 'دفعة أسبوعية', 'دفعة تحت الحساب', 'سلفة'];

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Text('صرف دفعة لـ ${widget.technician.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (balance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('الرصيد المستحق الحالي: ${balance.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'المبلغ المدفوع (ج.م)',
              prefixIcon: const Icon(Icons.payments_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
            ),
          ),
          const SizedBox(height: 8),
          // Quick amount chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (balance > 0)
                ActionChip(
                  label: Text('كامل الرصيد (${balance.toStringAsFixed(0)} ج)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: AppColors.success,
                  onPressed: () {
                    setState(() {
                      _amountCtrl.text = balance.toStringAsFixed(0);
                    });
                  },
                ),
              ...quickAmounts.map((q) => ActionChip(
                label: Text('+$q', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.surface,
                side: BorderSide(color: AppColors.border),
                onPressed: () {
                  final cur = double.tryParse(_amountCtrl.text) ?? 0.0;
                  final next = cur + q;
                  setState(() {
                    _amountCtrl.text = next.toStringAsFixed(0);
                  });
                },
              )),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            decoration: InputDecoration(labelText: 'ملاحظات (اختياري)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 8),
          // Quick notes chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: quickNotes.map((note) => ActionChip(
              label: Text(note, style: const TextStyle(fontSize: 11)),
              backgroundColor: _notesCtrl.text == note ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
              side: BorderSide(color: _notesCtrl.text == note ? AppColors.primary : AppColors.border),
              onPressed: () {
                setState(() {
                  _notesCtrl.text = note;
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 20),
          
          FilledButton(
            onPressed: _isSaving ? null : () async {
              if (_amountCtrl.text.isEmpty) return;
              final amount = double.tryParse(_amountCtrl.text);
              if (amount == null || amount <= 0) return;

              setState(() => _isSaving = true);
              
              final engine = ref.read(techniciansEngineProvider);
              await engine.payTechnician(
                technicianId: widget.technician.id,
                amount: amount,
                notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
              );
              
              // Deduct from Cash Register
              final cashEngine = ref.read(cashFlowEngineProvider);
              await cashEngine.recordTransaction(
                type: 'out',
                amount: amount,
                category: 'technician_payment',
                notes: 'دفعة للفني ${widget.technician.name}: ${_notesCtrl.text}',
              );
              
              ref.invalidate(technicianBalanceProvider(widget.technician.id));
              ref.invalidate(drawerBalanceProvider); // update dashboard cash balance
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدفعة وخصمها من الخزينة بنجاح ✅')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('تأكيد الدفع', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─── Technician Statement Sheet ─────────────────────────────────────────────

class _TechnicianStatementSheet extends ConsumerWidget {
  final Technician technician;
  const _TechnicianStatementSheet({required this.technician});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(erpDatabaseProvider);
    final balanceAsync = ref.watch(technicianBalanceProvider(technician.id));
    final entriesFuture = (db.select(db.technicianLedger)
          ..where((l) => l.technicianId.equals(technician.id))
          ..orderBy([(l) => drift.OrderingTerm.desc(l.createdAt)]))
        .get();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كشف حساب: ${technician.name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      technician.phone ?? 'بدون هاتف',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              balanceAsync.when(
                data: (bal) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: bal > 0 ? AppColors.error.withValues(alpha: 0.12) : AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'الرصيد: ${bal.toStringAsFixed(0)} ج',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: bal > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
                loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, _) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<TechnicianTransaction>>(
              future: entriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 8),
                        Text(
                          'لا توجد حركات مسجلة لهذا الفني حتى الآن',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    final isPayment = item.type == 'payment_given';
                    final dateStr = DateFormat('yyyy/MM/dd HH:mm').format(item.createdAt);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: isPayment
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        child: Icon(
                          isPayment ? Icons.payments_outlined : Icons.engineering_rounded,
                          size: 18,
                          color: isPayment ? AppColors.error : AppColors.success,
                        ),
                      ),
                      title: Text(
                        isPayment ? 'دفعة مسددة للفني' : 'مستحق عمولة تركيب',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        '${item.notes ?? ''} • $dateStr',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        '${isPayment ? '-' : '+'}${item.amount.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isPayment ? AppColors.error : AppColors.success,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => _SettleBalanceForm(technician: technician),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('دفع دفعة / تصفية حساب الآن'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
