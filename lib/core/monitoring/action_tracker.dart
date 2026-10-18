import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stream_pay/core/monitoring/smart_logger.dart';

/// A tracking system to monitor and beautifully log the status of data modifications
/// (Add, Edit, Delete) across local and cloud databases.
class ActionTracker {
  /// Wraps an operation to track its local and cloud execution status.
  /// 
  /// [operationName] A descriptive name for the console, e.g., '[Product - Add] iPhone 15'
  /// [localAction] The primary action that saves to the local database (Drift).
  /// [cloudAction] An optional action that pushes to the cloud (e.g., awaiting SyncEngine).
  /// [logger] Optional SmartLogger for persistent system logging.
  static Future<T> track<T>({
    required String operationName,
    required Future<T> Function() localAction,
    Future<void> Function()? cloudAction,
    SmartLogger? logger,
  }) async {
    bool localSuccess = false;
    bool cloudSuccess = false;
    String localError = '';
    String cloudError = '';
    
    T? result;
    
    // 1. Local Action Execution
    try {
      result = await localAction();
      localSuccess = true;
    } catch (e, st) {
      localSuccess = false;
      localError = e.toString();
      logger?.error('Local Action Failed: $operationName', error: e, stackTrace: st);
    }

    // 2. Cloud Action Execution (Only if local succeeded)
    if (localSuccess && cloudAction != null) {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          cloudSuccess = false;
          cloudError = 'Device is offline';
        } else {
          await cloudAction();
          cloudSuccess = true;
        }
      } catch (e, st) {
        cloudSuccess = false;
        cloudError = e.toString();
        // It's normal for cloud to fail (offline). We just log a warning.
        logger?.warning('Cloud Action Failed: $operationName (Queued for background sync)', error: e, stackTrace: st);
      }
    }

    // 3. Output beautiful console summary
    _printSummary(
      operationName: operationName,
      localSuccess: localSuccess,
      cloudSuccess: cloudSuccess,
      localError: localError,
      cloudError: cloudError,
      hasCloudAction: cloudAction != null,
    );

    // If local fails, we throw the exception so the UI knows it totally failed.
    if (!localSuccess) {
      throw Exception('Operation [$operationName] failed locally: $localError');
    }

    return result as T;
  }

  static void _printSummary({
    required String operationName,
    required bool localSuccess,
    required bool cloudSuccess,
    required String localError,
    required String cloudError,
    required bool hasCloudAction,
  }) {
    if (!kDebugMode) return;

    final StringBuffer sb = StringBuffer();
    sb.writeln('\n╔═══════════════════════════════════════════════════════════════════════╗');
    
    // Auto-truncate or pad operation name to keep box neat (rough approximation)
    String safeName = operationName;
    if (safeName.length > 50) {
      safeName = '${safeName.substring(0, 47)}...';
    }
    sb.writeln('║ 🔄 OPERATION: $safeName');
    sb.writeln('╠═══════════════════════════════════════════════════════════════════════╣');
    
    if (localSuccess) {
      sb.writeln('║ 📱 LOCAL DB : ✅ Saved successfully');
    } else {
      sb.writeln('║ 📱 LOCAL DB : ❌ Failed');
      sb.writeln('║               Reason: $localError');
    }

    if (hasCloudAction) {
      if (!localSuccess) {
        sb.writeln('║ ☁️  CLOUD DB : ⏭️ Skipped (Local failed)');
      } else if (cloudSuccess) {
        sb.writeln('║ ☁️  CLOUD DB : ✅ Synced successfully');
      } else {
        sb.writeln('║ ☁️  CLOUD DB : ❌ Failed - Queued for background sync');
        sb.writeln('║               Reason: $cloudError');
      }
    } else {
      sb.writeln('║ ☁️  CLOUD DB : ➖ Not applicable (Local only operation)');
    }

    sb.writeln('╠═══════════════════════════════════════════════════════════════════════╣');
    
    if (!localSuccess) {
      sb.writeln('║ 📊 STATUS   : 🚨 COMPLETE FAILURE (Nothing saved)');
    } else if (hasCloudAction && !cloudSuccess) {
      sb.writeln('║ 📊 STATUS   : ⚠️ PARTIAL SUCCESS (Saved locally only)');
    } else {
      sb.writeln('║ 📊 STATUS   : 🌟 COMPLETE SUCCESS');
    }
    
    sb.writeln('╚═══════════════════════════════════════════════════════════════════════╝\n');
    
    print(sb.toString());
  }
}
