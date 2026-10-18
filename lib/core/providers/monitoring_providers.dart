import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_providers.dart';
import 'supabase_providers.dart';
import '../monitoring/smart_logger.dart';
import '../monitoring/app_monitor.dart';
import '../monitoring/telemetry_service.dart';
import '../sync/integrity_checker.dart';

final smartLoggerProvider = Provider<SmartLogger>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SmartLogger(db);
});

final appMonitorProvider = Provider<AppMonitor>((ref) {
  final logger = ref.watch(smartLoggerProvider);
  return AppMonitor(logger);
});

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseProvider);
  return TelemetryService(db, supabase);
});

final integrityCheckerProvider = Provider<IntegrityChecker>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseProvider);
  final logger = ref.watch(smartLoggerProvider);
  return IntegrityChecker(db, supabase, logger);
});
