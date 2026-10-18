import '../data/models/app_version_model.dart';

enum UpdateStatus {
  initial,
  checking,
  available,
  noUpdate,
  downloading,
  readyToInstall,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final AppVersionModel? updateInfo;
  final double downloadProgress; // 0.0 to 1.0
  final String? errorMessage;
  final String? downloadedFilePath;

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.updateInfo,
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.downloadedFilePath,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    AppVersionModel? updateInfo,
    double? downloadProgress,
    String? errorMessage,
    String? downloadedFilePath,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
    );
  }
}
