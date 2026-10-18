import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth repository — handles all authentication operations.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'seller',
    String? shopName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'shop_name': shopName,
      },
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user.
  User? get currentUser => _client.auth.currentUser;

  /// Get current session.
  Session? get currentSession => _client.auth.currentSession;

  /// Reset password.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user metadata.
  Future<UserResponse> updateProfile({String? fullName, String? phone}) async {
    return await _client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName, 'phone': phone}),
    );
  }

  /// Listen to auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
