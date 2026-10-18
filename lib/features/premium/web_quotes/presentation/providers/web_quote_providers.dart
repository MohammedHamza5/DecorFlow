import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import '../../data/repositories/web_quote_repository.dart';
import '../../domain/models/web_quote.dart';

/// Provider for WebQuoteRepository.
final webQuoteRepositoryProvider = Provider<WebQuoteRepository>((ref) {
  final deps = ref.watch(premiumDependenciesProvider);
  return WebQuoteRepository(deps);
});

/// FutureProvider to fetch or create the interactive web quote configuration.
final webQuoteConfigProvider = FutureProvider.family<WebQuote, String>((ref, quoteId) async {
  final repository = ref.watch(webQuoteRepositoryProvider);
  return repository.getOrCreateWebQuote(quoteId);
});
