import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/providers/monitoring_providers.dart';
import 'package:stream_pay/core/monitoring/smart_logger.dart';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import 'package:stream_pay/app/router.dart';

class PremiumDependenciesImpl implements PremiumDependencies {
  final Ref _ref;

  PremiumDependenciesImpl(this._ref);

  @override
  SupabaseClient get supabaseClient => _ref.read(supabaseProvider);

  @override
  String? get currentShopId {
    final profileAsyncValue = _ref.read(userProfileProvider);
    return profileAsyncValue.value?['shop_id'] ??
        profileAsyncValue.value?['id'];
  }

  @override
  String? get currentUserId => supabaseClient.auth.currentUser?.id;

  @override
  void logSystem({
    required String level,
    required String message,
    String? error,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final logger = _ref.read(smartLoggerProvider);
    final logLevel = LogLevel.values.firstWhere(
      (e) => e.toString().split('.').last == level,
      orElse: () => LogLevel.info,
    );

    logger.log(
      message,
      level: logLevel,
      error: error,
      stackTrace: stackTrace != null ? StackTrace.fromString(stackTrace) : null,
      context: context,
    );
  }

  @override
  void navigateToProductDetail(String productId, {String? variantId}) {
    // Navigate using the GoRouter global state if needed, or by getting router context.
    // For now, since routerProvider exists, we can read it:
    final router = _ref.read(routerProvider);
    final query = variantId != null ? '?variantId=$variantId' : '';
    router.push('/product/$productId$query');
  }
}

/// Provider that implements the premium dependencies using core providers.
final premiumDependenciesImplProvider = Provider<PremiumDependencies>((ref) {
  return PremiumDependenciesImpl(ref);
});
