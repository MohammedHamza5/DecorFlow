import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/features/auth/data/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';

/// Auth repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

/// Auth state for the app.
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Main auth notifier — manages login/signup/logout flows.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final user = ref.watch(supabaseProvider).auth.currentUser;
    
    // Listen to auth changes
    ref.listen(authStateProvider, (prev, next) {
      next.whenData((authState) async {
        final session = authState.session;
        if (session != null && session.refreshToken != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('saved_refresh_token', session.refreshToken!);
            await prefs.setString('last_user_id', session.user.id);
          } catch (_) {}
        }

        if (authState.event == AuthChangeEvent.signedIn ||
            authState.event == AuthChangeEvent.tokenRefreshed) {
          ref.read(isExplicitSignOutProvider.notifier).setSignedOut(false);
          final sessionUser = session?.user;
          
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: sessionUser,
            error: null,
          );
        } else if (authState.event == AuthChangeEvent.signedOut) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      });
    });

    if (user != null) {
      return AuthState(status: AuthStatus.authenticated, user: user);
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      ref.read(isExplicitSignOutProvider.notifier).setSignedOut(false);
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email: email, password: password);
      // Auth state change listener will update state
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _mapError(e),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'seller',
    String? shopName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      ref.read(isExplicitSignOutProvider.notifier).setSignedOut(false);
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        shopName: shopName,
      );

      // Database trigger `on_auth_user_created` handles creating the profile with the correct role and shopName.
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _mapError(e),
      );
    }
  }

  Future<void> signOut() async {
    // 1. Mark explicit sign out
    ref.read(isExplicitSignOutProvider.notifier).setSignedOut(true);
    
    // 2. Clear saved refresh token and last user id
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_refresh_token');
      await prefs.remove('last_user_id');
    } catch (_) {}

    // 3. Invalidate profile provider & set state
    ref.invalidate(userProfileProvider);
    state = const AuthState(status: AuthStatus.unauthenticated);

    // 4. Supabase SignOut
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
  }

  Future<void> resetPassword(String email) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.resetPassword(email);
  }

  String _mapError(dynamic e) {
    if (e is AuthException) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'بيانات الدخول غير صحيحة';
        case 'Email not confirmed':
          return 'يرجى تأكيد البريد الإلكتروني';
        case 'User already registered':
          return 'هذا البريد مسجل مسبقاً';
        default:
          return e.message;
      }
    }
    return 'حدث خطأ غير متوقع';
  }
}

/// Auth notifier provider.
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
