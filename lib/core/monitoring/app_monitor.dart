import 'dart:async';
import 'package:flutter/foundation.dart';
import 'smart_logger.dart';

class AppMonitor {
  final SmartLogger _logger;

  AppMonitor(this._logger);

  void initialize() {
    // Handle Flutter framework errors (UI errors)
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
      _logger.error(
        'FlutterError: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
        context: {'library': details.library, 'context': details.context?.toString()},
      );
    };

    // Handle asynchronous Dart errors (outside of Flutter)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      _logger.error(
        'PlatformDispatcher Error: $error',
        error: error,
        stackTrace: stackTrace,
        context: {'type': 'unhandled_async_error'},
      );
      return true; // Prevent the app from crashing
    };
  }

  // A generic wrapper to run zones (if needed for older error capturing methods)
  static void runGuarded(void Function() runAppCall, SmartLogger logger) {
    runZonedGuarded(() {
      runAppCall();
    }, (error, stackTrace) {
      logger.error(
        'ZonedGuarded Error: $error',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }
}
