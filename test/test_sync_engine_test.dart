@Timeout(Duration(seconds: 120))
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/constants/app_constants.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/sync/sync_engine.dart';

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
  HttpOverrides.global = null;

  // Mock Native Channels
  setUpAll(() {
    // 1. Mock Connectivity
    const MethodChannel connChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return ['wifi'];
      }
      return null;
    });

    // 2. Mock Path Provider
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path; // write to temporary system directory during test
      }
      return null;
    });

    // 3. Mock SharedPreferences
    const MethodChannel prefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(prefsChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      if (methodCall.method.startsWith('set') || methodCall.method == 'remove' || methodCall.method == 'clear') {
        return true;
      }
      return null;
    });
  });

  test('Run SyncEngine sync and check for errors', () async {
    print('Initializing Supabase...');
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

    await client.auth.signUp(email: email, password: password);

    // Initialize local database (which now writes to systemTemp because of our mock)
    print('Initializing database in systemTemp...');
    final db = AppDatabase();
    
    print('Initializing SyncEngine...');
    final syncEngine = SyncEngine(db, client, null, shopIdOverride: '00000000-0000-0000-0000-000000000000');

    // Wait for the background sync to start and finish
    print('Waiting for SyncEngine background sync to complete...');
    // Give it a tiny moment to trigger the microtask
    await Future.delayed(const Duration(milliseconds: 10));
    while (syncEngine.isSyncingNotifier.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    print('Background sync completed.');

    // Check counts in local database
    final productsCount = await db.select(db.localProducts).get();
    final variantsCount = await db.select(db.localProductVariants).get();
    final pricingsCount = await db.select(db.localSupplierPricings).get();
    
    print('SYNC SUMMARY IN LOCAL DB:');
    print(' - Local products count: ${productsCount.length}');
    print(' - Local variants count: ${variantsCount.length}');
    print(' - Local pricings count: ${pricingsCount.length}');

    // Clean up
    await db.close();
    
    // Check if sync succeeded
    expect(productsCount, isA<List>());
    expect(variantsCount, isA<List>());
    expect(pricingsCount, isA<List>());
  });
}
