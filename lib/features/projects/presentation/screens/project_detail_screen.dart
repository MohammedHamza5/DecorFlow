import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/common_widgets.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Project detail screen — view measurements, rooms, and linked quotes.
class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      body: projectAsync.when(
        data: (project) {
          if (project == null) {
            return const AppErrorWidget(message: 'المشروع غير موجود');
          }
          return _ProjectDetailBody(
              project: project, projectId: projectId);
        },
        loading: () =>
            const LoadingWidget(message: 'جارِ تحميل المشروع...'),
        error: (e, _) => AppErrorWidget(
          message: 'فشل تحميل المشروع',
          onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
        ),
      ),
    );
  }
}

class _ProjectDetailBody extends ConsumerWidget {
  final Map<String, dynamic> project;
  final String projectId;

  const _ProjectDetailBody(
      {required this.project, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = project['customer'] as Map<String, dynamic>?;
    final sessions =
        project['measurement_sessions'] as List? ?? [];
    final quotes = project['quotes'] as List? ?? [];
    final status = project['status'] as String? ?? 'pending';

    return ConstrainedBody(
      child: CustomScrollView(
        slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 160,
          actions: [
            PopupMenuButton<String>(
              onSelected: (v) => _handleAction(context, ref, v),
              itemBuilder: (_) => [
                if (status == 'pending')
                  const PopupMenuItem(
                      value: 'in_progress', child: Text('بدء العمل')),
                if (status == 'in_progress')
                  const PopupMenuItem(
                      value: 'completed', child: Text('✓ مكتمل')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(project['name'] ?? '',
                style: const TextStyle(fontSize: 16)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
        ),
        // Customer card
        if (customer != null)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_outlined,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        if (customer['phone'] != null)
                          Text(customer['phone'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        if (customer['location'] != null)
                          Text(customer['location'],
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Address
        if (project['address'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(project['address'],
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        // Measurement sessions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.straighten_outlined,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'جلسات القياس (${sessions.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _addSession(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('جلسة جديدة'),
                ),
              ],
            ),
          ),
        ),
        if (sessions.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmptyStateWidget(
                icon: Icons.straighten_outlined,
                title: 'لا توجد جلسات قياس',
                subtitle: 'أضف جلسة قياس لتسجيل القياسات',
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
               (context, index) => _SessionTile(
                  session: sessions[index] as Map<String, dynamic>,
                  index: index + 1,
                  projectId: projectId),
              childCount: sessions.length,
            ),
          ),
        // Linked quotes
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'عروض الأسعار (${quotes.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (quotes.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد عروض مرتبطة',
                subtitle: 'أنشئ عرض سعر مرتبط بهذا المشروع',
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final q = quotes[index] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primary,
                          size: 20),
                    ),
                    title: Text(q['quote_number'] ?? 'عرض'),
                    subtitle: Text(
                      '${(q['final_total'] as num?)?.toStringAsFixed(0) ?? '0'} ج.م',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 12),
                    ),
                    trailing: Text(q['status'] ?? '',
                        style: const TextStyle(fontSize: 11)),
                  ),
                );
              },
              childCount: quotes.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    ),
  );
}

  void _addSession(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(offlineProjectRepositoryProvider);
      await repo.createSession(projectId);
      ref.invalidate(projectDetailProvider(projectId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء جلسة القياس ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _handleAction(
      BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(offlineProjectRepositoryProvider);
    if (action == 'delete') {
      await repo.deleteProject(projectId);
      if (context.mounted) Navigator.of(context).pop(true);
    } else {
      await repo.updateProjectStatus(projectId, action);
      ref.invalidate(projectDetailProvider(projectId));
    }
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  final int index;
  final String projectId;

  const _SessionTile({
    required this.session,
    required this.index,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final rooms = session['rooms'] as List? ?? [];
    final status = session['status'] as String? ?? 'draft';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        onExpansionChanged: (_) {},
        leading: InkWell(
          onTap: () => context.push(
            '/measurement/${session['id']}',
            extra: {'projectId': projectId},
          ),
          child: CircleAvatar(
          radius: 18,
          backgroundColor:
              AppColors.accent.withValues(alpha: 0.12),
          child: Text('$index',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          ),
        ),
        title: InkWell(
          onTap: () => context.push(
            '/measurement/${session['id']}',
            extra: {'projectId': projectId},
          ),
          child: Text('جلسة قياس #$index',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        subtitle: Text('${rooms.length} غرفة — $status',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        children: [
          if (rooms.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد غرف مسجلة بعد',
                  style: TextStyle(color: AppColors.textTertiary)),
            )
          else
            ...rooms.map((room) {
              final r = room as Map<String, dynamic>;
              final walls = r['walls'] as List? ?? [];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24),
                leading: Icon(Icons.room_outlined,
                    size: 20, color: AppColors.textSecondary),
                title: Text(r['name'] ?? 'غرفة',
                    style: const TextStyle(fontSize: 13)),
                trailing: Text('${walls.length} حائط',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary)),
              );
            }),
        ],
      ),
    );
  }
}
