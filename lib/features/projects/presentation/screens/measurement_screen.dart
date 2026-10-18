import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/quotes/presentation/screens/quote_generation_screen.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Provider to load a session's full tree.
final sessionTreeProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, sessionId) async {
  final repo = ref.watch(offlineProjectRepositoryProvider);
  return repo.getSessionWithTree(sessionId);
});

/// Measurement session screen — rooms → walls → openings tree.
class MeasurementScreen extends ConsumerWidget {
  final String sessionId;
  final String projectId;

  const MeasurementScreen({
    super.key,
    required this.sessionId,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionTreeProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('جلسة القياس'),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                final isSyncing = ref.watch(isSyncingProvider).value;
                if (isSyncing) {
                  return const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return const Icon(Icons.cloud_done_outlined, size: 16, color: Colors.green);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'إصدار عرض سعر',
            onPressed: () {
              // We need customerId. We can get it from the project detail provider.
              // For simplicity, we can fetch it here or pass it if available.
              final projectAsync = ref.read(projectDetailProvider(projectId));
              final customerId = projectAsync.value?['customer_id'] as String?;
              
              if (customerId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء الانتظار حتى تحميل بيانات المشروع')));
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuoteGenerationScreen(
                    sessionId: sessionId,
                    projectId: projectId,
                    customerId: customerId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'إتمام الجلسة',
            onPressed: () => _completeSession(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRoom(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('غرفة جديدة'),
        backgroundColor: AppColors.accent,
      ),
      body: ConstrainedBody(
        child: sessionAsync.when(
          data: (session) {
          if (session == null) {
            return const Center(child: Text('الجلسة غير موجودة'));
          }
          final rooms = session['rooms'] as List? ?? [];
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.room_outlined, size: 64,
                      color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text('لا توجد غرف',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('اضغط + لإضافة غرفة جديدة',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(sessionTreeProvider(sessionId)),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: rooms.length,
              itemBuilder: (_, i) => _RoomCard(
                room: rooms[i] as Map<String, dynamic>,
                index: i + 1,
                sessionId: sessionId,
                projectId: projectId,
                onRefresh: () =>
                    ref.invalidate(sessionTreeProvider(sessionId)),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    ),
  );
}

  void _addRoom(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final heightCtrl = TextEditingController(text: '280');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('غرفة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم الغرفة',
                hintText: 'مثال: صالة، غرفة نوم...',
                prefixIcon: Icon(Icons.room_outlined),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heightCtrl,
              decoration: const InputDecoration(
                labelText: 'ارتفاع السقف (سم)',
                prefixIcon: Icon(Icons.height),
                suffixText: 'سم',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'name': nameCtrl.text.trim(),
                'ceiling_height':
                    (double.tryParse(heightCtrl.text) ?? 280) / 100.0,
              });
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null) {
      final repo = ref.read(offlineProjectRepositoryProvider);
      await repo.addRoom(sessionId, result['name'], type: 'room'); // Ensure arguments map correctly to addRoom signature
      ref.invalidate(sessionTreeProvider(sessionId));
    }
  }

  void _completeSession(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إتمام الجلسة'),
        content: const Text('هل تم الانتهاء من جميع القياسات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ليس بعد'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، تم'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(offlineProjectRepositoryProvider);
      await repo.completeSession(sessionId);
      ref.invalidate(projectDetailProvider(projectId));
      if (context.mounted) Navigator.pop(context);
    }
  }
}

/// Card for a single room with walls inside.
class _RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final int index;
  final String sessionId;
  final String projectId;
  final VoidCallback onRefresh;

  const _RoomCard({
    required this.room,
    required this.index,
    required this.sessionId,
    required this.projectId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final walls = room['walls'] as List? ?? [];
    final ceilingH = (room['ceiling_height'] as num?)?.toDouble() ?? 0;
    final roomId = room['id'] as String;

    // Calculate total wall area and openings
    double totalWallArea = 0;
    double totalOpeningsArea = 0;
    for (final w in walls) {
      final wall = w as Map<String, dynamic>;
      final wl = (wall['length'] as num?)?.toDouble() ?? 0;
      final wh = (wall['height'] as num?)?.toDouble() ?? 0;
      totalWallArea += wl * wh;
      final openings = wall['wall_openings'] as List? ?? [];
      for (final o in openings) {
        final op = o as Map<String, dynamic>;
        if (op['deduct'] == true) {
          totalOpeningsArea += ((op['width'] as num?)?.toDouble() ?? 0) *
              ((op['height'] as num?)?.toDouble() ?? 0);
        }
      }
    }
    final netArea = totalWallArea - totalOpeningsArea;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Column(
        children: [
          // Room header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('$index',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room['name'] ?? 'غرفة',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ارتفاع: ${(ceilingH * 100).toStringAsFixed(0)} سم  •  ${walls.length} حائط',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Area badge
                if (totalWallArea > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${netArea.toStringAsFixed(1)} م²',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700, fontSize: 12,
                      ),
                    ),
                  ),
                // Delete room
                PopupMenuButton<String>(
                  iconSize: 20,
                  onSelected: (v) async {
                    if (v == 'delete') {
                      final repo = ProviderScope.containerOf(context)
                          .read(offlineProjectRepositoryProvider);
                      await repo.deleteRoom(roomId);
                      onRefresh();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف الغرفة',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Walls list
          ...walls.asMap().entries.map((entry) {
            final wall = entry.value as Map<String, dynamic>;
            return _WallTile(
              wall: wall,
              wallIndex: entry.key + 1,
              onRefresh: onRefresh,
            );
          }),
          // Add wall button
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => _addWall(context, roomId, ceilingH),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة حائط'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addWall(BuildContext ctx, String roomId, double ceilingH) async {
    final repo = ProviderScope.containerOf(ctx).read(offlineProjectRepositoryProvider);
    final lengthCtrl = TextEditingController();
    final heightCtrl = TextEditingController(text: (ceilingH * 100).toStringAsFixed(0));
    final labelCtrl = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('إضافة حائط'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم الحائط (اختياري)',
                hintText: 'شمال، جنوب...',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lengthCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'الطول (سم)',
                      suffixText: 'سم',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: heightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الارتفاع (سم)',
                      suffixText: 'سم',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final l = double.tryParse(lengthCtrl.text);
              final h = double.tryParse(heightCtrl.text);
              if (l == null || h == null || l <= 0 || h <= 0) return;
              Navigator.pop(c, {
                'label': labelCtrl.text.trim().isEmpty ? null : labelCtrl.text.trim(),
                'length': l / 100.0,
                'height': h / 100.0,
              });
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null) {
      await repo.addWall(roomId, result['label'] ?? 'حائط', result['length'], result['height']);
      onRefresh();
    }
  }
}

/// Tile for a single wall with openings.
class _WallTile extends StatelessWidget {
  final Map<String, dynamic> wall;
  final int wallIndex;
  final VoidCallback onRefresh;

  const _WallTile({
    required this.wall,
    required this.wallIndex,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final openings = wall['wall_openings'] as List? ?? [];
    final wl = (wall['length'] as num?)?.toDouble() ?? 0;
    final wh = (wall['height'] as num?)?.toDouble() ?? 0;
    final wallArea = wl * wh;
    double openingsArea = 0;
    for (final o in openings) {
      final op = o as Map<String, dynamic>;
      if (op['deduct'] == true) {
        openingsArea += ((op['width'] as num?)?.toDouble() ?? 0) *
            ((op['height'] as num?)?.toDouble() ?? 0);
      }
    }
    final net = wallArea - openingsArea;
    final wallId = wall['id'] as String;
    final label = wall['label'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.border_left_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label ?? 'حائط $wallIndex',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(wl * 100).toStringAsFixed(0)} × ${(wh * 100).toStringAsFixed(0)} سم',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${net.toStringAsFixed(1)} م²',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
              // Delete wall
              InkWell(
                onTap: () async {
                  final repo = ProviderScope.containerOf(context)
                      .read(offlineProjectRepositoryProvider);
                  await repo.deleteWall(wallId);
                  onRefresh();
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
          // Openings chips
          if (openings.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: openings.map((o) {
                final op = o as Map<String, dynamic>;
                final ow = (op['width'] as num?)?.toDouble() ?? 0;
                final oh = (op['height'] as num?)?.toDouble() ?? 0;
                return Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(_openingIcon(op['type'] ?? 'door'),
                      size: 14, color: AppColors.warning),
                  label: Text(
                    '${_openingLabel(op['type'])} ${(ow * 100).toStringAsFixed(0)}×${(oh * 100).toStringAsFixed(0)}سم',
                    style: const TextStyle(fontSize: 10),
                  ),
                  onDeleted: () async {
                    final repo = ProviderScope.containerOf(context)
                        .read(offlineProjectRepositoryProvider);
                    await repo.deleteOpening(op['id'] as String);
                    onRefresh();
                  },
                  deleteIconColor: AppColors.error,
                );
              }).toList(),
            ),
          ],
          // Add opening
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _addOpening(context, wallId),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('إضافة فتحة',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.warning)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addOpening(BuildContext ctx, String wallId) async {
    final repo = ProviderScope.containerOf(ctx).read(offlineProjectRepositoryProvider);
    String type = 'door';
    final widthCtrl = TextEditingController();
    final heightCtrl = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: ctx,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('إضافة فتحة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'door', label: Text('باب'),
                      icon: Icon(Icons.door_front_door_outlined, size: 16)),
                  ButtonSegment(value: 'window', label: Text('شباك'),
                      icon: Icon(Icons.window_outlined, size: 16)),
                  ButtonSegment(value: 'column', label: Text('عمود'),
                      icon: Icon(Icons.view_column_outlined, size: 16)),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widthCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'العرض (سم)', suffixText: 'سم',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: heightCtrl,
                      decoration: const InputDecoration(
                        labelText: 'الارتفاع (سم)', suffixText: 'سم',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final w = double.tryParse(widthCtrl.text);
                final h = double.tryParse(heightCtrl.text);
                if (w == null || h == null || w <= 0 || h <= 0) return;
                Navigator.pop(c, {
                  'type': type,
                  'width': w / 100.0,
                  'height': h / 100.0,
                  'deduct': true,
                });
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await repo.addOpening(wallId, result['type'], result['width'], result['height'], result['deduct']);
      onRefresh();
    }
  }

  IconData _openingIcon(String type) {
    switch (type) {
      case 'door': return Icons.door_front_door_outlined;
      case 'window': return Icons.window_outlined;
      case 'column': return Icons.view_column_outlined;
      default: return Icons.crop_square_outlined;
    }
  }

  String _openingLabel(String? type) {
    switch (type) {
      case 'door': return 'باب';
      case 'window': return 'شباك';
      case 'column': return 'عمود';
      default: return 'فتحة';
    }
  }
}
