import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface representing all external dependencies the Premium module
/// requires from the core Stream Pay application.
/// This allows the Premium module to remain fully decoupled and easily extractable
/// into a separate application in the future.
abstract class PremiumDependencies {
  /// Gets the active Supabase client instance.
  SupabaseClient get supabaseClient;

  /// Gets the current shop/merchant profile ID.
  String? get currentShopId;

  /// Gets the current authenticated user ID.
  String? get currentUserId;

  /// Logs a system message or error using the core application's logger.
  void logSystem({
    required String level,
    required String message,
    String? error,
    String? stackTrace,
    Map<String, dynamic>? context,
  });

  /// Navigates to a product detail screen in the core app.
  void navigateToProductDetail(String productId, {String? variantId});
}

/// Provider for the [PremiumDependencies] implementation.
/// The core application MUST override this provider in the [ProviderScope]
/// at the root of the app to supply its implementation.
final premiumDependenciesProvider = Provider<PremiumDependencies>((ref) {
  throw UnimplementedError(
    'premiumDependenciesProvider must be overridden by the core application.',
  );
});
