import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/update_providers.dart';
import '../providers/update_state.dart';

class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateNotifierProvider);
    final notifier = ref.read(updateNotifierProvider.notifier);
    final updateInfo = updateState.updateInfo;

    return AlertDialog(
      title: const Text('تحديث جديد متاح!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (updateInfo != null) ...[
            Text('الإصدار الجديد: ${updateInfo.version}'),
            const SizedBox(height: 8),
            if (updateInfo.releaseNotes != null && updateInfo.releaseNotes!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  updateInfo.releaseNotes!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
          const SizedBox(height: 16),
          
          if (updateState.status == UpdateStatus.downloading) ...[
            const Text('جاري تنزيل التحديث...'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: updateState.downloadProgress > 0 ? updateState.downloadProgress : null),
            const SizedBox(height: 8),
            Text('${(updateState.downloadProgress * 100).toStringAsFixed(1)}%'),
          ],

          if (updateState.status == UpdateStatus.readyToInstall)
            const Text('اكتمل التنزيل! التطبيق جاهز للتثبيت وإعادة التشغيل.'),
            
          if (updateState.status == UpdateStatus.error)
            Text(
              updateState.errorMessage ?? 'حدث خطأ غير معروف.',
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
      actions: [
        if (updateState.status != UpdateStatus.downloading && 
            !(updateInfo?.isRequired ?? false) && 
            updateState.status != UpdateStatus.readyToInstall)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لاحقاً'),
          ),
          
        if (updateState.status == UpdateStatus.available || updateState.status == UpdateStatus.error)
          ElevatedButton(
            onPressed: () {
              if (Platform.isWindows) {
                notifier.downloadUpdate();
              } else {
                // For non-Windows (like Android), we open the download URL in browser
                if (updateInfo?.downloadUrl != null) {
                  launchUrl(Uri.parse(updateInfo!.downloadUrl), mode: LaunchMode.externalApplication);
                }
              }
            },
            child: Text(Platform.isWindows ? 'تنزيل التحديث' : 'الذهاب للتحميل'),
          ),

        if (updateState.status == UpdateStatus.readyToInstall)
          ElevatedButton(
            onPressed: () => notifier.installUpdate(),
            child: const Text('تثبيت الآن'),
          ),
      ],
    );
  }
}
