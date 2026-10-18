import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Projects screen — manage customer projects.
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (label: 'الكل', status: null),
    (label: 'جارِ', status: 'in_progress'),
    (label: 'مُعلّق', status: 'pending'),
    (label: 'مكتمل', status: 'completed'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشاريع'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((t) => _ProjectTab(status: t.status)).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createProject(),
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد'),
      ),
    );
  }

  void _createProject() async {
    final result = await _showCreateProjectDialog();
    if (result == true) {
      for (final tab in _tabs) {
        ref.invalidate(projectsProvider(tab.status));
      }
    }
  }

  Future<bool?> _showCreateProjectDialog() async {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String? selectedCustomerId;

    final customersAsync = ref.read(customersProvider);
    final customers = customersAsync.value ?? [];

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('مشروع جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (() {
                  Future<void> submit() async {
                    if (nameCtrl.text.trim().isEmpty || selectedCustomerId == null) return;
                    try {
                      final repo = ref.read(offlineProjectRepositoryProvider);
                      await repo.createProject({
                        'name': nameCtrl.text.trim(),
                        'customer_id': selectedCustomerId,
                        if (addressCtrl.text.isNotEmpty) 'address': addressCtrl.text.trim(),
                      });
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل إنشاء المشروع: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                TextField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المشروع *',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'العميل *',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  items: customers.map((c) {
                    return DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(c['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedCustomerId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => submit(),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              );
              })(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty ||
                  selectedCustomerId == null) {
                return;
              }
              try {
                final repo = ref.read(offlineProjectRepositoryProvider);
                await repo.createProject({
                  'name': nameCtrl.text.trim(),
                  'customer_id': selectedCustomerId,
                  if (addressCtrl.text.isNotEmpty)
                    'address': addressCtrl.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل إنشاء المشروع: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('إنشاء'),
          ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    addressCtrl.dispose();
    return result;
  }
}

class _ProjectTab extends ConsumerWidget {
  final String? status;

  const _ProjectTab({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider(status));

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.folder_outlined,
            title: 'لا توجد مشاريع',
            subtitle: 'أنشئ مشروع جديد لتنظيم العملاء والقياسات',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(projectsProvider(status)),
          child: ConstrainedBody(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) => _ProjectCard(
                project: projects[index],
                onTap: () async {
                  final result = await context.push<bool>(
                    '/project/${projects[index]['id']}',
                  );
                  if (result == true) {
                    ref.invalidate(projectsProvider(status));
                  }
                },
              ),
            ),
          ),
        );
      },
      loading: () => const LoadingWidget(message: 'جارِ تحميل المشاريع...'),
      error: (e, _) => AppErrorWidget(
        message: 'فشل تحميل المشاريع',
        onRetry: () => ref.invalidate(projectsProvider(status)),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final customer = project['customer'] as Map<String, dynamic>?;
    final status = project['status'] as String? ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.folder_open_outlined,
                  color: _statusColor(status),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (customer != null)
                      Row(
                        children: [
                          Icon(
                            Icons.person_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer['name'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (project['address'] != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              project['address'],
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _ProjectStatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ProjectStatusBadge extends StatelessWidget {
  final String status;

  const _ProjectStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'pending': 'مُعلّق',
      'in_progress': 'جارِ',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
    };
    final colors = {
      'pending': AppColors.warning,
      'in_progress': AppColors.info,
      'completed': AppColors.success,
      'cancelled': AppColors.error,
    };
    final color = colors[status] ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
