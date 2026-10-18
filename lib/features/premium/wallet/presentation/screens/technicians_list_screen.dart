import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import '../providers/technician_providers.dart';
import '../../domain/models/technician.dart';

class TechniciansListScreen extends ConsumerWidget {
  const TechniciansListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techniciansAsync = ref.watch(techniciansListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('محفظة المهندسين والفنيين'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add technician screen or show dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('إضافة فني جديد (قريباً)')),
              );
            },
          ),
        ],
      ),
      body: techniciansAsync.when(
        data: (technicians) {
          if (technicians.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد فنيين مسجلين',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ConstrainedBody(
            child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final technician = technicians[index];
              return _TechnicianCard(technician: technician);
            },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'حدث خطأ أثناء جلب البيانات:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _TechnicianCard extends ConsumerWidget {
  final Technician technician;

  const _TechnicianCard({required this.technician});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(technicianBalanceProvider(technician.id));
    final pendingBalance = ref.watch(technicianPendingBalanceProvider(technician.id));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to details screen
          context.pushNamed('premiumTechnicianDetails', extra: technician);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  technician.name.isNotEmpty ? technician.name.substring(0, 1) : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technician.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technician.title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'الرصيد المتاح',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${balance.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (pendingBalance > 0)
                    Text(
                      '+${pendingBalance.toStringAsFixed(2)} معلق',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
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
}
