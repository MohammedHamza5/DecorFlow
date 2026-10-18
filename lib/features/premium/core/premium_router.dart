import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../wallet/presentation/screens/technicians_list_screen.dart';
import '../wallet/presentation/screens/technician_details_screen.dart';
import '../wallet/domain/models/technician.dart';

import '../design_advisor/presentation/screens/design_gallery_screen.dart';
import '../design_advisor/presentation/screens/design_calculator_screen.dart';
import '../design_advisor/domain/models/design_template.dart';

import '../restock_radar/presentation/screens/restock_radar_screen.dart';

// Placeholder screens so the routing builds correctly.
// These will be replaced by actual screen widgets in their respective feature folders.

class PremiumCuttingPlaceholderScreen extends StatelessWidget {
  const PremiumCuttingPlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('مخطط التقطيع ثنائي الأبعاد وتفادي الهدر (قريباً)')),
    );
  }
}

/// Router config containing all routes for the Premium features module.
/// These can be registered by spreading [premiumRoutes] in the main application's router.
class PremiumRouter {
  PremiumRouter._();

  static final List<RouteBase> premiumRoutes = [
    GoRoute(
      path: '/premium/wallet',
      name: 'premiumWallet',
      builder: (context, state) => const TechniciansListScreen(),
    ),
    GoRoute(
      path: '/premium/wallet/details',
      name: 'premiumTechnicianDetails',
      builder: (context, state) {
        final technician = state.extra as Technician;
        return TechnicianDetailsScreen(technician: technician);
      },
    ),
    GoRoute(
      path: '/premium/cutting-optimizer',
      name: 'premiumCuttingOptimizer',
      builder: (context, state) => const PremiumCuttingPlaceholderScreen(),
    ),
    GoRoute(
      path: '/premium/design-advisor',
      name: 'premiumDesignAdvisor',
      builder: (context, state) => const DesignGalleryScreen(),
    ),
    GoRoute(
      path: '/premium/design-advisor/calculator',
      name: 'premiumDesignCalculator',
      builder: (context, state) {
        final template = state.extra as DesignTemplate;
        return DesignCalculatorScreen(template: template);
      },
    ),
    GoRoute(
      path: '/premium/restock-radar',
      name: 'premiumRestockRadar',
      builder: (context, state) => const RestockRadarScreen(),
    ),
  ];
}
