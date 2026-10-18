import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/technician_providers.dart';
import '../../domain/models/technician.dart';
import '../../domain/models/technician_transaction.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class TechnicianDetailsScreen extends ConsumerWidget {
  final Technician technician;

  const TechnicianDetailsScreen({super.key, required this.technician});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(technicianBalanceProvider(technician.id));
    final pendingBalance = ref.watch(technicianPendingBalanceProvider(technician.id));
    final transactionsAsync = ref.watch(technicianTransactionsProvider(technician.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('محفظة ${technician.name}'),
        centerTitle: true,
      ),
      body: ConstrainedBody(
        child: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(
            child: _buildWalletSummary(context, balance, pendingBalance),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'سجل العمليات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'لا توجد عمليات مسجلة',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    return _TransactionTile(transaction: tx);
                  },
                  childCount: transactions.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('حدث خطأ: $error', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildWalletSummary(BuildContext context, double balance, double pending) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'الرصيد المتاح للسحب',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (pending > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'رصيد معلق: ${pending.toStringAsFixed(2)} ج.م',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: balance > 0
                    ? () {
                        // TODO: Implement withdrawal functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سحب الرصيد (قريباً)')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.money_off),
                label: const Text('سحب رصيد'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TechnicianTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.amount > 0;
    final isPending = transaction.status == 'pending';
    final formatter = DateFormat('yyyy/MM/dd hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          isCredit ? 'إضافة عمولة' : 'سحب نقدي',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatter.format(transaction.createdAt)),
            if (transaction.invoiceId != null)
              Text('فاتورة رقم: ${transaction.invoiceId}', style: const TextStyle(fontSize: 12)),
            if (isPending)
              const Text('قيد الانتظار', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Text(
          '${isCredit ? '+' : ''}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
