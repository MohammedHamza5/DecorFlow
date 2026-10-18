import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

// ─── Provider: fetch shop members from Supabase ───────────────────

final shopMembersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return [];

  final supabase = ref.read(supabaseProvider);
  final data = await supabase
      .from('profiles')
      .select('id, full_name, phone, role, is_active')
      .eq('shop_id', shopId)
      .order('role');
  return List<Map<String, dynamic>>.from(data);
});

// ─── Screen ───────────────────────────────────────────────────────

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRole = ref.watch(currentUserRoleProvider);
    final myId = ref.watch(supabaseProvider).auth.currentUser?.id;
    final membersAsync = ref.watch(shopMembersProvider);
    final canChangeRoles = RolePermissions.hasPermission(myRole, AppPermission.manageTeam);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إدارة الفريق',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(shopMembersProvider),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: ConstrainedBody(
        child: Column(
          children: [
          // ─── Invite Banner ─────────────────────────────────────────
          if (canChangeRoles) _InviteBanner(),

          // ─── Members List ─────────────────────────────────────────
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('خطأ: $e', style: const TextStyle(color: AppColors.error)),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return _EmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isMe = member['id'] == myId;
                    return _MemberCard(
                      member: member,
                      isMe: isMe,
                      canChangeRole: canChangeRoles && !isMe,
                      onRoleChanged: (newRole) => _changeRole(context, ref, member['id'], newRole),
                      onToggleActive: canChangeRoles && !isMe
                          ? () => _toggleActive(context, ref, member['id'], !(member['is_active'] as bool? ?? true))
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _changeRole(BuildContext context, WidgetRef ref, String memberId, AppRole newRole) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.rpc('change_team_member_role', params: {
        'target_user_id': memberId,
        'new_role': newRole.nameStr,
      });
      ref.invalidate(shopMembersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير الدور إلى ${_roleName(newRole)} ✓'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, String memberId, bool newStatus) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.rpc('toggle_team_member_active', params: {
        'target_user_id': memberId,
        'is_active': newStatus,
      });
      ref.invalidate(shopMembersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'تم تفعيل الحساب ✓' : 'تم تعطيل الحساب'),
            backgroundColor: newStatus ? AppColors.success : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _roleName(AppRole role) {
    switch (role) {
      case AppRole.owner:   return 'صاحب المحل';
      case AppRole.manager: return 'مدير';
      case AppRole.seller:  return 'بائع';
    }
  }
}

// ─── Member Card ─────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isMe;
  final bool canChangeRole;
  final ValueChanged<AppRole> onRoleChanged;
  final VoidCallback? onToggleActive;

  const _MemberCard({
    required this.member,
    required this.isMe,
    required this.canChangeRole,
    required this.onRoleChanged,
    this.onToggleActive,
  });

  AppRole get _role => AppRole.fromString(member['role'] as String?);
  bool get _isActive => member['is_active'] as bool? ?? true;

  Color _roleColor() {
    switch (_role) {
      case AppRole.owner:   return const Color(0xFF6366F1);
      case AppRole.manager: return const Color(0xFF0EA5E9);
      case AppRole.seller:  return const Color(0xFF10B981);
    }
  }

  String _roleLabel() {
    switch (_role) {
      case AppRole.owner:   return 'صاحب المحل';
      case AppRole.manager: return 'مدير';
      case AppRole.seller:  return 'بائع';
    }
  }

  IconData _roleIcon() {
    switch (_role) {
      case AppRole.owner:   return Icons.store_rounded;
      case AppRole.manager: return Icons.manage_accounts_rounded;
      case AppRole.seller:  return Icons.point_of_sale_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = member['full_name'] as String? ?? 'مستخدم';
    final phone = member['phone'] as String? ?? '';
    final color = _roleColor();

    return AnimatedOpacity(
      opacity: _isActive ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMe
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
            width: isMe ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isMe)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'أنت',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_roleIcon(), color: color, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                _roleLabel(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Active badge
                        if (!_isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'معطّل',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (!isMe && canChangeRole)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'role',
                      child: ListTile(
                        leading: Icon(Icons.swap_horiz_rounded),
                        title: Text('تغيير الدور'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          _isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                          color: _isActive ? AppColors.error : AppColors.success,
                        ),
                        title: Text(
                          _isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
                          style: TextStyle(
                            color: _isActive ? AppColors.error : AppColors.success,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'role') {
                      _showRoleDialog(context);
                    } else if (value == 'toggle') {
                      onToggleActive?.call();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تغيير الدور', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoleOption(
              label: 'بائع',
              subtitle: 'يمكنه البيع وعرض المنتجات',
              icon: Icons.point_of_sale_rounded,
              color: const Color(0xFF10B981),
              selected: _role == AppRole.seller,
              onTap: () {
                Navigator.pop(ctx);
                onRoleChanged(AppRole.seller);
              },
            ),
            const SizedBox(height: 8),
            _RoleOption(
              label: 'مدير',
              subtitle: 'يمكنه إدارة المخزون والفريق',
              icon: Icons.manage_accounts_rounded,
              color: const Color(0xFF0EA5E9),
              selected: _role == AppRole.manager,
              onTap: () {
                Navigator.pop(ctx);
                onRoleChanged(AppRole.manager);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}

// ─── Role Option Widget ───────────────────────────────────────────

class _RoleOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? color : null)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

// ─── Invite Banner ────────────────────────────────────────────────

class _InviteBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopId = ref.watch(currentShopIdProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'دعوة موظف جديد',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'شارك كود المحل لإضافة موظف',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _showShopCode(context, shopId),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('عرض الكود', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showShopCode(BuildContext context, String? shopId) {
    if (shopId == null) return;
    final shortCode = shopId.split('-').first.toUpperCase();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('كود الانضمام للمحل', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                shortCode,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'شارك هذا الكود مع الموظف الجديد ليتمكن من الانضمام.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 72, color: AppColors.textTertiary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد أعضاء في الفريق',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'شارك كود المحل لإضافة موظفين جدد.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
