import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/constants/app_constants.dart';
import 'package:stream_pay/engines/calculation/category_calc_registry.dart';
import 'package:stream_pay/features/premium/core/premium_dependencies.dart';
import 'package:stream_pay/core/providers/premium_deps_impl.dart';
import 'app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_pay/core/providers/monitoring_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with autoRefreshToken enabled
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  // Keep saved_refresh_token always synchronized on every token refresh event
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final session = data.session;
    if (session != null && session.refreshToken != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_refresh_token', session.refreshToken!);
      } catch (_) {}
    }
  });

  // Auto-recover session on startup using saved refresh token if needed
  try {
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) {
      final prefs = await SharedPreferences.getInstance();
      final savedRefreshToken = prefs.getString('saved_refresh_token');
      if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
        await client.auth.setSession(savedRefreshToken);
      }
    }
  } catch (e) {
    // Only remove saved refresh token if it's explicitly rejected as invalid/revoked
    // Never remove on network timeouts or temporary offline status
    if (e is AuthException &&
        (e.statusCode == '400' ||
            e.message.toLowerCase().contains('invalid') ||
            e.message.toLowerCase().contains('revoked'))) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_refresh_token');
      } catch (_) {}
    }
  }

  // Load custom calculator categories
  await CategoryCalcRegistry.loadCustomCategories();

  // Allow all orientations — the app is designed for mobile, tablet, and desktop.
  // Locking to portrait only would break desktop/tablet layouts.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final container = ProviderContainer(
    overrides: [
      premiumDependenciesProvider.overrideWith(
        (ref) => ref.read(premiumDependenciesImplProvider),
      ),
    ],
  );

  // Initialize Global Error Monitoring
  final appMonitor = container.read(appMonitorProvider);
  appMonitor.initialize();

  // Start Telemetry Service periodic sync (every 1 hour)
  final telemetry = container.read(telemetryServiceProvider);
  telemetry.startPeriodicSync(const Duration(hours: 1));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DecorProApp(),
    ),
  );
}
