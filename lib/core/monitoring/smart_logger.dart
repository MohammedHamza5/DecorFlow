import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../local_db/app_database.dart';
import 'package:drift/drift.dart' as drift;

enum LogLevel { info, warning, error, dataConflict }

class SmartLogger {
  final AppDatabase _db;
  
  SmartLogger(this._db);

  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final contextString = context != null ? jsonEncode(context) : null;
    
    // Convert enum to string: "LogLevel.info" -> "info"
    final levelString = level.toString().split('.').last;

    if (kDebugMode) {
      print('[$levelString] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('Stack: $stackTrace');
      if (contextString != null) print('Context: $contextString');
    }

    try {
      await _db.insertSystemLog(
        LocalSystemLogsCompanion(
          level: drift.Value(levelString),
          message: drift.Value(message),
          error: drift.Value(error?.toString()),
          stackTrace: drift.Value(stackTrace?.toString()),
          context: drift.Value(contextString),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save log to local database: $e');
      }
    }
  }

  Future<void> info(String message, {Map<String, dynamic>? context}) {
    return log(message, level: LogLevel.info, context: context);
  }

  Future<void> warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    return log(message, level: LogLevel.warning, error: error, stackTrace: stackTrace, context: context);
  }

  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    return log(message, level: LogLevel.error, error: error, stackTrace: stackTrace, context: context);
  }

  Future<void> dataConflict(String message, {Map<String, dynamic>? context}) {
    return log(message, level: LogLevel.dataConflict, context: context);
  }
}
