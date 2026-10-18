import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/constants/app_constants.dart';
import 'package:stream_pay/features/update/data/services/update_remote_service.dart';
import 'package:stream_pay/features/update/data/services/update_local_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  test('Verify OTA update detection and download stream from Supabase', () async {
    print('1. Initializing Supabase...');
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    final client = Supabase.instance.client;
    final remoteService = UpdateRemoteService(client);
    final localService = UpdateLocalService();

    print('2. Fetching latest version for windows_offline...');
    final latest = await remoteService.getLatestVersion('windows_offline');
    
    expect(latest, isNotNull);
    print('Fetched version: ${latest!.version}');
    print('Download URL: ${latest.downloadUrl}');
    print('Release notes: ${latest.releaseNotes}');
    expect(latest.version, '1.0.2');

    print('3. Testing download stream for a small chunk...');
    final tempDir = Directory.systemTemp.createTempSync('stream_pay_test_update');
    final savePath = '${tempDir.path}\\test_installer.exe';

    final progressList = <double>[];
    await for (final progress in localService.downloadFile(latest.downloadUrl, savePath).take(5)) {
      progressList.add(progress);
      print('Progress: ${(progress * 100).toStringAsFixed(1)}%');
    }

    expect(progressList.isNotEmpty, true);
    print('Download test succeeded! First few chunks received.');

    // Clean up
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });
}
