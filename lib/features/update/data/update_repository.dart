import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import 'models/app_version_model.dart';
import 'services/update_local_service.dart';
import 'services/update_remote_service.dart';

class UpdateRepository {
  final UpdateRemoteService _remote;
  final UpdateLocalService _local;

  UpdateRepository(this._remote, this._local);

  Future<AppVersionModel?> checkForUpdate() async {
    try {
      final platform = kIsWeb ? 'web' : (Platform.isWindows ? 'windows_offline' : 'other');
      if (platform == 'other') return null;

      final latest = await _remote.getLatestVersion(platform);
      if (latest == null) return null;

      String currentVersion = '';
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
      } catch (e) {
        debugPrint('PackageInfo error: $e');
      }

      if (currentVersion.isEmpty) {
        currentVersion = AppConstants.appVersion;
      }

      if (_isUpdateAvailable(currentVersion, latest.version)) {
        return latest;
      }
      return null;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    final currentParts = current.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final latestParts = latest.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final l = i < latestParts.length ? latestParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  Future<String> getDownloadSavePath(AppVersionModel updateInfo) async {
    final dir = await _local.getUpdatesDirectory();
    return p.join(dir, 'StreamPay_Update_${updateInfo.version}.exe');
  }

  Stream<double> downloadUpdate(AppVersionModel updateInfo, String savePath) {
    return _local.downloadFile(updateInfo.downloadUrl, savePath);
  }

  Future<void> applyUpdate(String archivePath) async {
    await _local.launchInstaller(archivePath);
  }
}
