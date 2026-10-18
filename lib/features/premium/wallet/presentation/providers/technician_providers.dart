import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../data/repositories/technician_repository.dart';
import '../../domain/models/technician.dart';
import '../../domain/models/technician_transaction.dart';

/// Provider for the TechnicianRepository instance.
final technicianRepositoryProvider = Provider<TechnicianRepository>((ref) {
  final deps = ref.watch(premiumDependenciesProvider);
  return TechnicianRepository(deps);
});

/// FutureProvider that fetches all technicians.
final techniciansListProvider = FutureProvider<List<Technician>>((ref) async {
  final repository = ref.watch(technicianRepositoryProvider);
  return repository.getTechnicians();
});

/// FutureProvider that fetches all transactions for a specific technician.
final technicianTransactionsProvider = FutureProvider.family<List<TechnicianTransaction>, String>((ref, technicianId) async {
  final repository = ref.watch(technicianRepositoryProvider);
  return repository.getTransactions(technicianId);
});

/// Provider that computes the current wallet balance (total credit - total debit) for a technician.
final technicianBalanceProvider = Provider.family<double, String>((ref, technicianId) {
  final transactionsAsync = ref.watch(technicianTransactionsProvider(technicianId));
  return transactionsAsync.when(
    data: (transactions) {
      // Sum all amount values (credits are positive, debits/withdrawals are negative)
      return transactions.fold<double>(
        0.0,
        (sum, tx) => sum + (tx.status == 'completed' ? tx.amount : 0.0),
      );
    },
    loading: () => 0.0,
    error: (error, stackTrace) => 0.0,
  );
});

/// Provider that computes the pending/uncollected balance for a technician.
final technicianPendingBalanceProvider = Provider.family<double, String>((ref, technicianId) {
  final transactionsAsync = ref.watch(technicianTransactionsProvider(technicianId));
  return transactionsAsync.when(
    data: (transactions) {
      return transactions.fold<double>(
        0.0,
        (sum, tx) => sum + (tx.status == 'pending' ? tx.amount : 0.0),
      );
    },
    loading: () => 0.0,
    error: (error, stackTrace) => 0.0,
  );
});
