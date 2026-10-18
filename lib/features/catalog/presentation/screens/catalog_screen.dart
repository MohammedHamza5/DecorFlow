import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/presentation/screens/discount_management_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/data_completion_wizard_screen.dart';
import 'package:stream_pay/features/catalog/presentation/screens/category_screen.dart';
import 'package:stream_pay/shared/widgets/glass_container.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/responsive/app_responsive.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(catalogHubProvider);
    final role = ref.watch(currentUserRoleProvider);
    final canEdit = role == AppRole.owner || role == AppRole.manager;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConstrainedBody(
        child: Stack(
          children: [
            // Background Gradient (Premium touch)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(hub, canEdit),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildSearchBar(hub),
                  ),
                ),

                if (_searchActive && _searchController.text.isNotEmpty)
                  _buildSearchResults(hub, canEdit)
                else ...[
                  SliverToBoxAdapter(child: _buildStatsRow(hub)),
                  SliverToBoxAdapter(child: const SizedBox(height: 32)),
                  SliverToBoxAdapter(child: _buildGroupGrid(hub, canEdit)),
                  SliverToBoxAdapter(child: const SizedBox(height: 32)),
                  SliverToBoxAdapter(child: _buildRecentlyAdded(hub, canEdit)),
                  SliverToBoxAdapter(child: const SizedBox(height: 100)),
                ],
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              heroTag: 'catalog_fab',
              onPressed: () async {
                final ok = await context.push<bool>('/product/add');
                if (ok == true) {
                  ref.read(catalogHubProvider.notifier).invalidate();
                }
              },
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'إضافة منتج',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }

  // ─── Sliver AppBar ──────────────────────────────────────────
  Widget _buildSliverAppBar(CatalogHubState hub, bool canEdit) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'الكتالوج',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        if (hub.isLoading)
          const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        if (canEdit)
          IconButton(
            icon: Icon(Icons.percent_rounded, color: AppColors.textPrimary),
            tooltip: 'إدارة الخصومات',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DiscountManagementScreen(),
              ),
            ),
          ),
        if (canEdit)
          IconButton(
            icon: const Icon(
              Icons.auto_fix_high_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'مساعد جودة البيانات',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DataCompletionWizardScreen(),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.bolt_rounded, color: Colors.amber),
          tooltip: 'لوحة الأسعار السريعة',
          onPressed: () => context.push('/quick-price-board'),
        ),
        IconButton(
          icon: Icon(
            Icons.picture_as_pdf_outlined,
            color: AppColors.textPrimary,
          ),
          tooltip: 'قائمة الأسعار',
          onPressed: () => context.push('/price-list'),
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
          onPressed: () => ref.read(catalogHubProvider.notifier).invalidate(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar(CatalogHubState hub) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        blur: 15,
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'بحث بالكود، الاسم، اللون...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: _searchActive
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(catalogHubProvider.notifier).setSearch('');
                      setState(() => _searchActive = false);
                      _searchFocus.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (v) {
            setState(() => _searchActive = v.isNotEmpty);
            ref.read(catalogHubProvider.notifier).setSearch(v);
          },
          onTap: () => setState(() => _searchActive = true),
        ),
      ),
    );
  }

  // ─── Stats Row ──────────────────────────────────────────────
  Widget _buildStatsRow(CatalogHubState hub) {
    if (hub.isLoading || hub.totalProducts == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            _PillStat(
              label: '${hub.totalProducts}',
              sublabel: 'منتج',
              color: AppColors.primary,
              icon: Icons.inventory_2_rounded,
            ),
            const SizedBox(width: 12),
            _PillStat(
              label: '${hub.inStockCount}',
              sublabel: 'متاح',
              color: AppColors.success,
              icon: Icons.check_circle_rounded,
            ),
            if (hub.lowStockCount > 0) ...[
              const SizedBox(width: 12),
              _PillStat(
                label: '${hub.lowStockCount}',
                sublabel: 'منخفض',
                color: AppColors.warning,
                icon: Icons.warning_rounded,
              ),
            ],
            if (hub.noPriceCount > 0) ...[
              const SizedBox(width: 12),
              _PillStat(
                label: '${hub.noPriceCount}',
                sublabel: 'بلا سعر',
                color: AppColors.error,
                icon: Icons.price_change_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Group Grid ─────────────────────────────────────────────
  Widget _buildGroupGrid(CatalogHubState hub, bool canEdit) {
    if (hub.error != null && hub.allProducts.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'تعذّر تحميل البيانات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () =>
                  ref.read(catalogHubProvider.notifier).invalidate(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'التصنيفات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.dashboard_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveBuilder(
            builder: (context, info) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: info.isLargeDesktop
                    ? 6
                    : info.isDesktop
                    ? 4
                    : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: CategoryGroup.defaults.length,
              itemBuilder: (ctx, i) {
                final group = CategoryGroup.defaults[i];
                final count = hub.allProducts
                    .where((p) => group.matchesCategory(p.category))
                    .length;
                return _PremiumGroupCard(
                  group: group,
                  productCount: count,
                  onTap: () => context.push('/category/${group.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Results & Recently Added (Kept streamlined) ────
  Widget _buildSearchResults(CatalogHubState hub, bool canEdit) {
    final list = hub.filteredProducts;
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'لم نجد منتجات مطابقة',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> flatItems = [];
    for (final p in list) {
      for (final v in p.variants) {
        flatItems.add({'product': p, 'variant': v});
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverLayoutBuilder(
        builder: (context, sliversConstraints) {
          final info = ResponsiveInfo(
            width: sliversConstraints.crossAxisExtent,
            height: sliversConstraints.crossAxisExtent,
          );
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: info.isLargeDesktop
                  ? 6
                  : info.isDesktop
                  ? 4
                  : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.60,
            ),
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final item = flatItems[i];
              final EnrichedProduct p = item['product'];
              final EnrichedVariant v = item['variant'];
              // Determine group color based on product category
              final group = CategoryGroup.defaults
                  .cast<CategoryGroup?>()
                  .firstWhere(
                    (g) => g!.matchesCategory(p.category),
                    orElse: () => null,
                  );
              final color = group?.color ?? AppColors.primary;

              return PremiumVariantCard(
                product: p,
                variant: v,
                groupColor: color,
                onTap: () async {
                  final ok = await context.push<bool>(
                    '/product/${p.id}?variantId=${v.id}',
                  );
                  if (ok == true) {
                    ref.read(catalogHubProvider.notifier).invalidate();
                  }
                },
                onCalculate: p.calcConfig != null
                    ? () => context.go(
                        '/calculator',
                        extra: {'product': p.toRawMap()},
                      )
                    : null,
                onEdit: canEdit
                    ? () async {
                        final ok = await context.push<bool>(
                          '/product/${p.id}/edit',
                        );
                        if (ok == true) {
                          ref.read(catalogHubProvider.notifier).invalidate();
                        }
                      }
                    : null,
                onDelete: canEdit
                    ? () => _confirmDeleteVariant(context, p, v)
                    : null,
              );
            }, childCount: flatItems.length),
          );
        },
      ),
    );
  }

  Widget _buildRecentlyAdded(CatalogHubState hub, bool canEdit) {
    final recent = hub.allProducts.take(5).toList();
    if (recent.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أُضيفت حديثاً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => _PremiumListTile(
              product: recent[i],
              onTap: () async {
                final ok = await context.push<bool>('/product/${recent[i].id}');
                if (ok == true) {
                  ref.read(catalogHubProvider.notifier).invalidate();
                }
              },
              onEdit: canEdit
                  ? () async {
                      final ok = await context.push<bool>(
                        '/product/${recent[i].id}/edit',
                      );
                      if (ok == true) {
                        ref.read(catalogHubProvider.notifier).invalidate();
                      }
                    }
                  : null,
              onDelete: canEdit
                  ? () => _confirmDeleteProduct(context, recent[i])
                  : null, // This is for recent products list, which are whole products.
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    EnrichedProduct product,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Icon(Icons.delete_rounded, color: AppColors.error),
                const SizedBox(width: 8),
                const Text(
                  'حذف المنتج',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف منتج "${product.name}" وجميع أصنافه وبياناته؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
              style: TextStyle(height: 1.6, color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteProduct(product.id.toString());
      ref.read(catalogHubProvider.notifier).invalidate();
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف "${product.name}" بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _confirmDeleteVariant(
    BuildContext context,
    EnrichedProduct product,
    EnrichedVariant variant,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Icon(Icons.delete_rounded, color: AppColors.error),
                const SizedBox(width: 8),
                const Text(
                  'حذف الصنف',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف صنف "${variant.variantName}" من منتج "${product.name}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
              style: TextStyle(height: 1.6, color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteVariant(variant.id.toString());
      ref.read(catalogHubProvider.notifier).invalidate();
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الصنف بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ─── Modern Pill Stat ────────────────────────────────────────
class _PillStat extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;

  const _PillStat({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.8),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Premium Group Card ──────────────────────────────────────
class _PremiumGroupCard extends StatefulWidget {
  final CategoryGroup group;
  final int productCount;
  final VoidCallback onTap;

  const _PremiumGroupCard({
    required this.group,
    required this.productCount,
    required this.onTap,
  });

  @override
  State<_PremiumGroupCard> createState() => _PremiumGroupCardState();
}

class _PremiumGroupCardState extends State<_PremiumGroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.group.color,
                widget.group.color.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.group.color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative background pattern/icon
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  widget.group.icon,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.group.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.group.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.productCount} منتج',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Premium List Tile (for Search & Recent) ─────────────────
class _PremiumListTile extends ConsumerWidget {
  final EnrichedProduct product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _PremiumListTile({
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupColor = product.group?.color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: groupColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        cacheWidth: 180,
                      ),
                    )
                  : Icon(Icons.image_outlined, color: groupColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.code.isNotEmpty)
                    Text(
                      product.code,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: groupColor,
                      ),
                    ),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Edit/Delete menu
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textTertiary.withValues(alpha: 0.6),
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: AppColors.surface,
                onSelected: (v) {
                  if (v == 'edit') onEdit?.call();
                  if (v == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 16, color: groupColor),
                          const SizedBox(width: 8),
                          Text(
                            'تعديل',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: groupColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'حذف',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            else
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.borderDark.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
