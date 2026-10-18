import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist theme mode in SharedPreferences.
const _kThemeModeKey = 'theme_mode';

/// [ThemeMode] state notifier — persists across app restarts.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    return switch (stored) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
  }

  /// Toggle between dark and light modes.
  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.dark;
    await setMode(current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set a specific [ThemeMode] and persist it.
  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    });
  }

  /// Whether the current resolved theme is dark.
  bool isDark(BuildContext context) {
    final mode = state.value ?? ThemeMode.dark;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}

/// Global theme mode provider.
final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Convenience: watch the current [ThemeMode] value (defaults to dark).
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeProvider).value ?? ThemeMode.dark;
});
