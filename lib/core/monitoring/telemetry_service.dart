import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local_db/app_database.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  TelemetryService(this._db, this._supabase);

  /// Push unsynced logs to Supabase and mark them as synced.
  Future<void> syncLogs() async {
    try {
      final unsyncedLogs = await _db.getUnsyncedLogs();
      if (unsyncedLogs.isEmpty) return;

      final List<Map<String, dynamic>> payload = unsyncedLogs.map((log) {
        return {
          'level': log.level,
          'message': log.message,
          'error_details': log.error,
          'stack_trace': log.stackTrace,
          'context': log.context != null ? jsonDecode(log.context!) : null,
          'created_at': log.createdAt.toIso8601String(),
        };
      }).toList();

      // Assuming table is named 'app_issues_logs'
      await _supabase.from('app_issues_logs').insert(payload);

      // Mark as synced
      final ids = unsyncedLogs.map((e) => e.id).toList();
      await _db.markLogsAsSynced(ids);

      if (kDebugMode) {
        print('Successfully synced ${ids.length} system logs to Supabase.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync system logs: $e');
      }
    }
  }

  /// Can be called periodically
  void startPeriodicSync(Duration interval) {
    Stream.periodic(interval).listen((_) {
      syncLogs();
    });
  }
}
