import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _privacyKey = 'dashboard_financial_privacy_mode';

/// Notifier to toggle and persist privacy mode on the dashboard.
/// When enabled, financial figures (sales, cash amounts) are masked with dots (•••••).
class DashboardPrivacyNotifier extends StateNotifier<bool> {
  DashboardPrivacyNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_privacyKey) ?? false;
    } catch (_) {}
  }

  Future<void> toggle() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_privacyKey, state);
    } catch (_) {}
  }
}

final dashboardPrivacyProvider =
    StateNotifierProvider<DashboardPrivacyNotifier, bool>((ref) {
  return DashboardPrivacyNotifier();
});
