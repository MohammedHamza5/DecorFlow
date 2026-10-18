import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_db/app_database.dart';
import '../../core/monitoring/smart_logger.dart';
import '../../core/sync/integrity_checker.dart';

class DebugDashboard extends ConsumerStatefulWidget {
  final AppDatabase db;
  final IntegrityChecker integrityChecker;

  const DebugDashboard({
    super.key,
    required this.db,
    required this.integrityChecker,
  });

  @override
  ConsumerState<DebugDashboard> createState() => _DebugDashboardState();
}

class _DebugDashboardState extends ConsumerState<DebugDashboard> {
  bool _isRunningCheck = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Debug Dashboard', style: TextStyle(color: Colors.red)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: _isRunningCheck
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.security),
            tooltip: 'Run Integrity Check',
            onPressed: () async {
              setState(() => _isRunningCheck = true);
              await widget.integrityChecker.runFullCheck();
              if (mounted) {
                setState(() => _isRunningCheck = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Integrity check completed')),
                  );
                }
              }
            },
          )
        ],
      ),
      body: StreamBuilder<List<LocalSystemLog>>(
        stream: widget.db.watchSystemLogs(limit: 200),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading logs: ${snapshot.error}'));
          }
          
          final logs = snapshot.data ?? [];
          
          if (logs.isEmpty) {
            return const Center(child: Text('No system logs found.'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              Color bgColor = Colors.transparent;
              if (log.level == LogLevel.error.toString().split('.').last) {
                bgColor = Colors.red.withValues(alpha: 0.2);
              } else if (log.level == LogLevel.warning.toString().split('.').last) {
                bgColor = Colors.orange.withValues(alpha: 0.2);
              } else if (log.level == LogLevel.dataConflict.toString().split('.').last) {
                bgColor = Colors.purple.withValues(alpha: 0.2);
              }

              return Container(
                color: bgColor,
                child: ExpansionTile(
                  title: Text(log.message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${log.level.toUpperCase()} • ${log.createdAt}'),
                  trailing: Icon(
                    log.syncStatus == 'synced' ? Icons.cloud_done : Icons.cloud_upload,
                    color: log.syncStatus == 'synced' ? Colors.green : Colors.grey,
                  ),
                  children: [
                    if (log.error != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText('Error: ${log.error}'),
                      ),
                    if (log.context != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText('Context: ${log.context}'),
                      ),
                    if (log.stackTrace != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText('Stack: ${log.stackTrace}'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
