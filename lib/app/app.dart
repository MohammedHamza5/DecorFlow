import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'router.dart';

import '../features/update/providers/update_providers.dart';
import '../features/update/providers/update_state.dart';
import '../features/update/presentation/update_dialog.dart';

/// The root application widget.
class DecorProApp extends ConsumerStatefulWidget {
  const DecorProApp({super.key});

  @override
  ConsumerState<DecorProApp> createState() => _DecorProAppState();
}

class _DecorProAppState extends ConsumerState<DecorProApp> {
  @override
  void initState() {
    super.initState();
    // Check for updates on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateNotifierProvider.notifier).checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    // Listen for update state changes to show dialog
    ref.listen<UpdateState>(updateNotifierProvider, (previous, next) {
      if (next.status == UpdateStatus.available && (previous?.status != UpdateStatus.available)) {
        showDialog(
          context: router.routerDelegate.navigatorKey.currentContext ?? context,
          barrierDismissible: !(next.updateInfo?.isRequired ?? false),
          builder: (ctx) => const UpdateDialog(),
        );
      }
    });

    // Update AppColors.isDark based on resolved theme mode
    final resolvedBrightness = themeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    AppColors.isDark = resolvedBrightness == Brightness.dark;

    return MaterialApp.router(
      title: 'السويدي للديكور',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Localization — Arabic first
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: router,
    );
  }
}
