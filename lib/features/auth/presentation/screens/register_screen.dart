import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/auth/presentation/providers/auth_provider.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Professional registration screen.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _shopNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.status == AuthStatus.authenticated) {
        // Go back after successful registration
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.isDark
                    ? [
                        AppColors.darkBg,
                        AppColors.darkBackground,
                        AppColors.darkSurface,
                      ]
                    : [
                        const Color(0xFFFFF8E7),
                        const Color(0xFFF5F0E8),
                        const Color(0xFFEDE7D9),
                      ],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedForm(
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.isDark
                                        ? Colors.transparent
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'إنشاء حساب',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          'أنشئ حسابك لبدء إدارة محلك بذكاء',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Form
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name
                                _buildField(
                                  controller: _nameCtrl,
                                  label: 'الاسم الكامل',
                                  hint: 'أحمد محمد',
                                  icon: Icons.person_outlined,
                                  isLoading: isLoading,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'الاسم مطلوب'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                // Shop Name
                                _buildField(
                                  controller: _shopNameCtrl,
                                  label: 'اسم المحل / المتجر',
                                  hint: 'ديكورات الأندلس',
                                  icon: Icons.storefront_outlined,
                                  isLoading: isLoading,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'اسم المحل مطلوب'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                // Email
                                _buildField(
                                  controller: _emailCtrl,
                                  label: 'البريد الإلكتروني',
                                  hint: 'example@email.com',
                                  icon: Icons.email_outlined,
                                  isLoading: isLoading,
                                  isLtr: true,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'البريد مطلوب';
                                    }
                                    if (!v.contains('@')) {
                                      return 'بريد غير صحيح';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                // Phone
                                _buildField(
                                  controller: _phoneCtrl,
                                  label: 'رقم الهاتف',
                                  hint: '01xxxxxxxxx',
                                  icon: Icons.phone_outlined,
                                  isLoading: isLoading,
                                  isLtr: true,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 14),
                                // Password
                                TextFormField(
                                  controller: _passwordCtrl,
                                  enabled: !isLoading,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                    hintText: '6 أحرف على الأقل',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          Icons.lock_outlined,
                                          color: AppColors.primary,
                                          size: 20),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: AppColors.textTertiary,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'كلمة المرور مطلوبة';
                                    }
                                    if (v.length < 6) {
                                      return 'يجب 6 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                // Confirm password
                                TextFormField(
                                  controller: _confirmCtrl,
                                  enabled: !isLoading,
                                  obscureText: _obscureConfirm,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _register(),
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    labelText: 'تأكيد كلمة المرور',
                                    hintText: '••••••••',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.primary,
                                          size: 20),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      size: 20,
                                      color: AppColors.textTertiary,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscureConfirm =
                                            !_obscureConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != _passwordCtrl.text) {
                                    return 'كلمتا المرور غير متطابقتين';
                                  }
                                  return null;
                                },
                              ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Register button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: isLoading ? null : _register,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add_rounded,
                                          size: 22),
                                      SizedBox(width: 10),
                                      Text(
                                        'إنشاء الحساب',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Login link
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لديك حساب بالفعل؟',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              child: const Text(
                                'سجّل الدخول',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isLoading,
    bool isLtr = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !isLoading,
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      textAlign: isLtr ? TextAlign.left : TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintTextDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
      validator: validator,
    );
  }

  void _register() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final email = _emailCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null;
    final shopName = _shopNameCtrl.text.trim();
    
    ref.read(authNotifierProvider.notifier).signUp(
          email: email,
          password: _passwordCtrl.text,
          fullName: name,
          phone: phone,
          role: 'owner',
          shopName: shopName,
        );
  }
}
