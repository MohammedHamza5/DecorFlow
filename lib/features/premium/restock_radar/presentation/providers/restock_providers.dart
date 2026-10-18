import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../data/repositories/restock_repository.dart';
import '../../domain/models/supplier.dart';

/// Provider for RestockRepository.
final restockRepositoryProvider = Provider<RestockRepository>((ref) {
  final deps = ref.watch(premiumDependenciesProvider);
  return RestockRepository(deps);
});

/// FutureProvider that fetches all suppliers.
final suppliersListProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(restockRepositoryProvider);
  return repository.getSuppliers();
});

/// FutureProvider that fetches all low stock items that need restocking.
final lowStockItemsProvider = FutureProvider<List<LowStockItem>>((ref) async {
  final repository = ref.watch(restockRepositoryProvider);
  return repository.getLowStockItems();
});
