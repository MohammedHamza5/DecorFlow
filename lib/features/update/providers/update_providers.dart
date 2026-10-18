import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../data/services/update_local_service.dart';
import '../data/services/update_remote_service.dart';
import '../data/update_repository.dart';
import 'update_state.dart';

final updateLocalServiceProvider = Provider<UpdateLocalService>((ref) {
  return UpdateLocalService();
});

final updateRemoteServiceProvider = Provider<UpdateRemoteService>((ref) {
  return UpdateRemoteService(Supabase.instance.client);
});

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  final local = ref.watch(updateLocalServiceProvider);
  final remote = ref.watch(updateRemoteServiceProvider);
  return UpdateRepository(remote, local);
});

final updateNotifierProvider = NotifierProvider<UpdateNotifier, UpdateState>(() {
  return UpdateNotifier();
});

class UpdateNotifier extends Notifier<UpdateState> {
  StreamSubscription<double>? _downloadSub;

  @override
  UpdateState build() {
    ref.onDispose(() {
      _downloadSub?.cancel();
    });
    return const UpdateState();
  }

  UpdateRepository get _repository => ref.read(updateRepositoryProvider);

  Future<void> checkForUpdates() async {
    state = state.copyWith(status: UpdateStatus.checking);
    
    final latest = await _repository.checkForUpdate();
    
    if (latest != null) {
      state = state.copyWith(
        status: UpdateStatus.available,
        updateInfo: latest,
      );
    } else {
      state = state.copyWith(status: UpdateStatus.noUpdate);
    }
  }

  Future<void> downloadUpdate() async {
    if (state.updateInfo == null) return;
    
    final updateInfo = state.updateInfo!;
    state = state.copyWith(status: UpdateStatus.downloading, downloadProgress: 0.0);

    try {
      final savePath = await _repository.getDownloadSavePath(updateInfo);
      
      _downloadSub = _repository.downloadUpdate(updateInfo, savePath).listen(
        (progress) {
          state = state.copyWith(downloadProgress: progress);
        },
        onDone: () {
          state = state.copyWith(
            status: UpdateStatus.readyToInstall,
            downloadProgress: 1.0,
            downloadedFilePath: savePath,
          );
        },
        onError: (e) {
          state = state.copyWith(
            status: UpdateStatus.error,
            errorMessage: 'فشل التنزيل: $e',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'حدث خطأ أثناء بدء التنزيل: $e',
      );
    }
  }

  Future<void> installUpdate() async {
    if (state.downloadedFilePath == null) return;
    
    try {
      await _repository.applyUpdate(state.downloadedFilePath!);
      // Application will close shortly after this if using Inno Setup
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'فشل التثبيت: $e',
      );
    }
  }
}
