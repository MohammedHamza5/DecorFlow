import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';

/// A widget that conditionally renders its [child] based on whether the
/// current user has the specified [permission].
///
/// If the user does not have permission, the [fallback] widget is rendered
/// (defaults to an empty SizedBox).
class PermissionGate extends ConsumerWidget {
  final AppPermission permission;
  final Widget child;
  final Widget fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    
    if (RolePermissions.hasPermission(role, permission)) {
      return child;
    }
    
    return fallback;
  }
}
