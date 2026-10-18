import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/features/auth/presentation/providers/auth_provider.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Profile editing screen.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.userMetadata?['full_name'] ?? '';
    _phoneCtrl.text = user?.userMetadata?['phone'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: ConstrainedForm(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                (_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : '?')
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user?.email ?? '',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: const Icon(Icons.person_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneCtrl,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: const Icon(Icons.phone_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ التعديلات'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateProfile(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      // Also update Supabase profiles table
      final client = ref.read(supabaseProvider);
      await client.from('profiles').update({
        'full_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      }).eq('id', client.auth.currentUser!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التعديلات ✓'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
