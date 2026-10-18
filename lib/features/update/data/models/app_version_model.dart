class AppVersionModel {
  final String version;
  final String platform;
  final String downloadUrl;
  final String? releaseNotes;
  final bool isRequired;

  AppVersionModel({
    required this.version,
    required this.platform,
    required this.downloadUrl,
    this.releaseNotes,
    this.isRequired = false,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      version: json['version'] as String,
      platform: json['platform'] as String,
      downloadUrl: json['download_url'] as String,
      releaseNotes: json['release_notes'] as String?,
      isRequired: json['is_required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'platform': platform,
      'download_url': downloadUrl,
      'release_notes': releaseNotes,
      'is_required': isRequired,
    };
  }
}
