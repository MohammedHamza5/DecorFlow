import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UpdateLocalService {
  /// Downloads a file chunk-by-chunk and yields download progress (0.0 to 1.0).
  Stream<double> downloadFile(String url, String savePath) async* {
    if (kIsWeb) {
      throw UnsupportedError('File downloading is not supported on Web.');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close().timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to download update. Server returned code ${response.statusCode}',
      );
    }

    final file = File(savePath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    final fileSink = file.openWrite();
    final totalBytes = response.contentLength;
    var downloadedBytes = 0;

    try {
      await for (final chunk in response) {
        fileSink.add(chunk);
        downloadedBytes += chunk.length;
        if (totalBytes > 0) {
          yield downloadedBytes / totalBytes;
        } else {
          yield -1.0;
        }
      }
    } finally {
      await fileSink.close();
      client.close();
    }
  }

  /// Deploys the installer and launches it in a detached process.
  Future<void> launchInstaller(String archivePath) async {
    if (kIsWeb) return;
    if (!Platform.isWindows) {
      throw UnsupportedError('App update installer is Windows only.');
    }

    if (archivePath.toLowerCase().endsWith('.exe')) {
      // Launch Inno Setup installer directly
      await Process.start(
        archivePath,
        [
          '/VERYSILENT',
          '/SUPPRESSMSGBOXES',
          '/SP-',
          '/CLOSEAPPLICATIONS',
          '/NORESTART',
          '/MERGETASKS=!desktopicon',
        ],
        mode: ProcessStartMode.detached,
      );

      // Give the OS and Flutter runtime a moment to flush pending file writes
      await Future.delayed(const Duration(milliseconds: 300));

      // Must exit immediately so Inno Setup can overwrite the executable without file lock errors.
      exit(0);
    } else {
      throw UnsupportedError('Only .exe installers are supported currently.');
    }
  }

  Future<String> getUpdatesDirectory() async {
    if (Platform.isWindows) {
      return p.join(
        Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path,
        'StreamPayUpdates',
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return p.join(dir.path, 'StreamPayUpdates');
    }
  }
}
