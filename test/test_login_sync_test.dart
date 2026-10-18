@Timeout(Duration(seconds: 120))
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/constants/app_constants.dart';

class EmptyGotrueAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> getItem({required String key}) async => _storage[key];

  @override
  Future<void> removeItem({required String key}) async => _storage.remove(key);

  @override
  Future<void> setItem({required String key, required String value}) async => _storage[key] = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null; // Enable real network requests in flutter test

  test('Test Supabase RLS and Selection', () async {
    print('Initializing Supabase with custom Empty storage...');
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: EmptyGotrueAsyncStorage(),
      ),
    );
    
    final client = Supabase.instance.client;
    final email = 'test_sync_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'Password123';

    print('Signing up test user: $email...');
    try {
      final res = await client.auth.signUp(email: email, password: password);
      print('Signed up! User ID: ${res.user?.id}');
      
      print('Querying products...');
      final products = await client.from('products').select('id, name').limit(5);
      print('Products fetched: ${products.length}');
      for (var p in products) {
        print(' - ${p['id']}: ${p['name']}');
      }
      expect(products, isA<List>());
    } catch (e, st) {
      print('Error during test: $e');
      print('Stack trace:\n$st');
      fail('Test failed due to exception: $e');
    }
  });
}
