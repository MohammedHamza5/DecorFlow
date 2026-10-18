import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/features/auth/presentation/screens/login_screen.dart';
import 'package:stream_pay/features/auth/presentation/screens/register_screen.dart';

import 'package:stream_pay/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:stream_pay/features/calculator/presentation/screens/fast_calculator_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/category_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/add_product_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/price_list_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/quick_price_board_screen.dart';
import 'package:stream_pay/features/quotes/presentation/screens/quotes_list_screen.dart';
import 'package:stream_pay/features/quotes/presentation/screens/quote_studio_screen.dart';
import 'package:stream_pay/features/quotes/presentation/screens/quote_pdf_screen.dart';
import 'package:stream_pay/features/projects/presentation/screens/projects_screen.dart';
import 'package:stream_pay/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:stream_pay/features/projects/presentation/screens/measurement_screen.dart';
import 'package:stream_pay/features/projects/presentation/screens/customers_screen.dart';
import 'package:stream_pay/features/projects/presentation/screens/customer_profile_screen.dart';
import 'package:stream_pay/features/settings/presentation/screens/settings_screen.dart';
import 'package:stream_pay/features/settings/presentation/screens/profile_screen.dart';
import 'package:stream_pay/features/settings/presentation/screens/team_management_screen.dart';
import 'package:stream_pay/features/settings/presentation/screens/suppliers_screen.dart';
import 'package:stream_pay/features/invoices/presentation/screens/invoices_list_screen.dart';
import 'package:stream_pay/features/invoices/presentation/screens/smart_invoice_builder_screen.dart';
import 'package:stream_pay/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:stream_pay/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:stream_pay/features/inventory/presentation/screens/inventory_item_detail_screen.dart';
import 'package:stream_pay/features/inventory/presentation/screens/stock_adjustment_screen.dart';
import 'package:stream_pay/features/inventory/presentation/screens/purchase_orders_screen.dart';
import 'package:stream_pay/features/inventory/presentation/screens/purchasing_hub_screen.dart';
import 'package:stream_pay/features/dashboard/presentation/screens/cash_register_screen.dart';
import 'package:stream_pay/features/erp/presentation/screens/technicians_screen.dart';
import 'package:stream_pay/shared/widgets/app_shell.dart';
import 'package:stream_pay/features/premium/core/premium_router.dart';


/// A Listenable that notifies its listeners when a stream emits an event.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class RouterRefreshNotifier extends ChangeNotifier {
  late final ProviderSubscription _authSub;
  late final ProviderSubscription _profileSub;

  RouterRefreshNotifier(Ref ref) {
    _authSub = ref.listen(isAuthenticatedProvider, (prev, next) {
      if (prev != next) notifyListeners();
    });
    _profileSub = ref.listen(userProfileProvider, (prev, next) {
      if (prev?.value != next.value) notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub.close();
    _profileSub.close();
    super.dispose();
  }
}

final routerRefreshProvider = Provider<Listenable>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// App router configuration using GoRouter with auth guard.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: ref.watch(routerRefreshProvider),
    // Auth guard â€” redirect unauthenticated users to login
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final location = state.matchedLocation;

      final isOnAuth =
          location == '/login' ||
          location == '/register';

      if (!isAuthenticated) {
        return isOnAuth ? null : '/login';
      }

      if (isOnAuth) {
        return '/dashboard';
      }

      // Role-based route guard for seller role
      final role = ref.read(currentUserRoleProvider);
      if (role == AppRole.seller) {
        final sellerBlockedRoutes = [
          '/team-management',
          '/suppliers',
          '/inventory',
          '/stock-adjustment',
        ];
        if (sellerBlockedRoutes.any((route) => location == route || location.startsWith('$route/'))) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      // ─── Auth Routes ─────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),


      // ─── Shell Route (Bottom Navigation) ────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/invoices',
            name: 'invoices',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InvoicesListScreen()),
          ),
          GoRoute(
            path: '/calculator',
            name: 'calculator',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NoTransitionPage(
                child: FastCalculatorScreen(
                  preloadedProduct: extra?['product'] as Map<String, dynamic>?,
                  preloadedVariant: extra?['variant'] as Map<String, dynamic>?,
                ),
              );
            },
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CatalogScreen()),
          ),
          GoRoute(
            path: '/quotes',
            name: 'quotes',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QuotesListScreen()),
          ),
          GoRoute(
            path: '/customers',
            name: 'customers',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomersScreen()),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProjectsScreen()),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryScreen()),
          ),
          GoRoute(
            path: '/cash-register',
            name: 'cashRegister',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashRegisterScreen()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),

          // ─── Sub-routes & Detail Screens (Inside App Shell) ───
          GoRoute(
            path: '/quote-builder',
            name: 'quoteBuilder',
            builder: (context, state) {
              final extra = state.extra;
              String? quoteId;
              Map<String, dynamic>? initialItem;

              if (extra is String) {
                quoteId = extra;
              } else if (extra is Map<String, dynamic>) {
                quoteId = extra['quoteId'] as String?;
                initialItem = extra['initialItem'] as Map<String, dynamic>?;
              }

              return SmartQuoteStudioScreen(quoteId: quoteId, initialItem: initialItem);
            },
          ),
          GoRoute(
            path: '/quotes/new',
            redirect: (context, state) => '/quote-builder',
          ),
          GoRoute(
            path: '/quote/:id',
            name: 'quoteDetail',
            builder: (context, state) =>
                SmartQuoteStudioScreen(quoteId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/quote/:id/pdf',
            name: 'quotePdf',
            builder: (context, state) =>
                QuotePdfScreen(quoteId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/product/add',
            name: 'addProduct',
            builder: (context, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: '/category/:groupId',
            name: 'category',
            builder: (context, state) =>
                CategoryScreen(groupId: state.pathParameters['groupId']),
          ),
          GoRoute(
            path: '/product/:id',
            name: 'productDetail',
            builder: (context, state) =>
                ProductDetailScreen(
                  productId: state.pathParameters['id']!,
                  variantId: state.uri.queryParameters['variantId'],
                ),
          ),
          GoRoute(
            path: '/product/:id/edit',
            name: 'editProduct',
            builder: (context, state) =>
                AddProductScreen(productId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/price-list',
            name: 'priceList',
            builder: (context, state) => const PriceListScreen(),
          ),
          GoRoute(
            path: '/quick-price-board',
            name: 'quickPriceBoard',
            builder: (context, state) => const QuickPriceBoardScreen(),
          ),
          GoRoute(
            path: '/project/:id',
            name: 'projectDetail',
            builder: (context, state) =>
                ProjectDetailScreen(projectId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/measurement/:sessionId',
            name: 'measurement',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return MeasurementScreen(
                sessionId: state.pathParameters['sessionId']!,
                projectId: extra?['projectId'] ?? '',
              );
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/team-management',
            name: 'teamManagement',
            builder: (context, state) => const TeamManagementScreen(),
          ),
          GoRoute(
            path: '/suppliers',
            name: 'suppliers',
            builder: (context, state) => const SuppliersScreen(),
          ),
          GoRoute(
            path: '/customer/:id',
            name: 'customerProfile',
            builder: (context, state) =>
                CustomerProfileScreen(customerId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/invoice/:id',
            name: 'invoiceDetail',
            builder: (context, state) =>
                InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/inventory/:id',
            name: 'inventoryDetail',
            builder: (context, state) =>
                InventoryItemDetailScreen(itemId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/smart-invoice',
            name: 'smartInvoiceNew',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SmartInvoiceBuilderScreen(
                customerId: state.uri.queryParameters['customerId'] ?? extra?['customerId'] ?? 'cash_customer',
                customerName: state.uri.queryParameters['name'] ?? extra?['customerName'] ?? 'عميل نقدي (كاش)',
                initialItems: extra?['initialItems'] as List<Map<String, dynamic>>?,
              );
            },
          ),
          GoRoute(
            path: '/smart-invoice/:customerId',
            name: 'smartInvoiceBuilder',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SmartInvoiceBuilderScreen(
                customerId: state.pathParameters['customerId']!,
                customerName: state.uri.queryParameters['name'] ?? extra?['customerName'] ?? 'عميل',
                initialItems: extra?['initialItems'] as List<Map<String, dynamic>>?,
              );
            },
          ),
          GoRoute(
            path: '/stock-adjustment',
            name: 'stockAdjustment',
            builder: (context, state) => const StockAdjustmentScreen(),
          ),
          GoRoute(
            path: '/purchasing-hub',
            name: 'purchasingHub',
            builder: (context, state) => const PurchasingHubScreen(),
          ),
          GoRoute(
            path: '/purchase-orders',
            name: 'purchaseOrders',
            builder: (context, state) => const PurchaseOrdersScreen(),
          ),
          GoRoute(
            path: '/technicians',
            name: 'technicians',
            builder: (context, state) => const TechniciansScreen(),
          ),
          ...PremiumRouter.premiumRoutes,
        ],
      ),
    ],
  );
});

