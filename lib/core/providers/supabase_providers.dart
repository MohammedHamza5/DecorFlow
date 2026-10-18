import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client provider.
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current auth session stream.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

/// Explicit sign out tracker flag.
class ExplicitSignOutNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSignedOut(bool value) {
    state = value;
  }
}

final isExplicitSignOutProvider =
    NotifierProvider<ExplicitSignOutNotifier, bool>(ExplicitSignOutNotifier.new);

/// Safe monotonic background session refresh manager.
/// Replaces Gotrue's clock-dependent timer with a runtime periodic timer and a strict cooldown guard.
class SafeSessionManager {
  final SupabaseClient _supabase;
  DateTime? _lastRefreshAttempt;

  SafeSessionManager(this._supabase);

  Future<void> safeRefreshToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    final now = DateTime.now();
    if (_lastRefreshAttempt != null &&
        now.difference(_lastRefreshAttempt!).inMinutes < 5) {
      // Cooldown: at most 1 refresh every 5 minutes
      return;
    }
    _lastRefreshAttempt = now;

    try {
      await _supabase.auth.refreshSession();
    } catch (_) {
      // Gracefully ignore background refresh failures
    }
  }
}

final safeSessionManagerProvider = Provider<SafeSessionManager>((ref) {
  final client = ref.watch(supabaseProvider);
  final manager = SafeSessionManager(client);

  // Periodic refresh every 30 minutes
  final timer = Stream.periodic(const Duration(minutes: 30)).listen((_) {
    manager.safeRefreshToken();
  });

  ref.onDispose(timer.cancel);
  return manager;
});

/// Current user provider with offline protection.
final currentUserProvider = Provider<User?>((ref) {
  // Ensure session manager is active
  ref.watch(safeSessionManagerProvider);

  // Watch the stream to trigger rebuilds on auth changes
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final isExplicitSignOut = ref.watch(isExplicitSignOutProvider);

  if (isExplicitSignOut) {
    return null;
  }

  return client.auth.currentUser;
});

/// Whether user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
