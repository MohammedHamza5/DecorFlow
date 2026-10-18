import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';

/// Provides the current Supabase session stream
final supabaseSessionProvider = StreamProvider<Session?>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange.map((event) => event.session);
});

/// Provider for the current user's ID to prevent circular dependencies on token refreshes.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider.select((user) => user?.id));
});

/// Profile of the current user fetched from database or offline fallback cache
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return null;
  }
  final user = ref.read(currentUserProvider);

  // 1. Try remote fetch
  final supabase = ref.watch(supabaseProvider);
  try {
    final data = await supabase
        .from('profiles')
        .select('role, shop_id, full_name, is_active, phone')
        .eq('id', userId)
        .maybeSingle();

    if (data != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile_$userId', jsonEncode(data));
      } catch (_) {}
      return data;
    }
  } catch (_) {
    // Network/socket/offline exception - gracefully fallback
  }

  // 2. Fallback to cached profile in SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_profile_$userId');
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
  } catch (_) {}

  // 3. Fallback to user metadata in current auth session
  final metadata = user?.userMetadata;
  return {
    'role': metadata?['role'] ?? 'seller',
    'shop_id': metadata?['shop_id'] ?? userId,
    'full_name': metadata?['full_name'] ?? user?.email?.split('@').first ?? 'مستخدم',
    'is_active': true,
    'phone': metadata?['phone'],
  };
});

/// Current user role provider (reads from database public.profiles)
final currentUserRoleProvider = Provider<AppRole>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (profile) {
      if (profile == null) return AppRole.seller;
      return AppRole.fromString(profile['role'] as String?);
    },
    orElse: () => AppRole.seller,
  );
});

/// Current shop ID provider
final currentShopIdProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (profile) {
      if (profile == null) return null;
      if (profile['role'] == 'owner') {
        return ref.read(currentUserIdProvider);
      }
      return profile['shop_id'] as String?;
    },
    orElse: () => null,
  );
});
