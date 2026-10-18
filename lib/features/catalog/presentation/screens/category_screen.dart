import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/glass_container.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

// ─── Premium Color Resolver & Painters ──────────────────────────────

class ResolvedColor {
  final String name;
  final Color color;
  final Gradient? gradient;
  final bool isLight;

  const ResolvedColor({
    required this.name,
    required this.color,
    this.gradient,
    required this.isLight,
  });
}

// Caches to avoid redundant expensive calculations and regex parsing
final Map<String, ResolvedColor> _resolvedColorCache = {};
final Map<String, bool> _isActualColorCache = {};
final Map<String, String> _trueColorNameCache = {};

ResolvedColor resolveColor(String name) {
  final cached = _resolvedColorCache[name];
  if (cached != null) return cached;

  final n = name.trim().toLowerCase();
  ResolvedColor result;

  if (n.contains('أبيض فيوتك') || n == 'أبيض') {
    result = const ResolvedColor(
      name: 'أبيض فيوتك',
      color: Color(0xFFFAFAFA),
      isLight: true,
    );
  } else if (n.contains('أبيض سادة')) {
    result = const ResolvedColor(
      name: 'أبيض سادة',
      color: Color(0xFFFFFFFF),
      isLight: true,
    );
  } else if (n.contains('أبيض بيرل') || n.contains('لؤلؤي')) {
    result = const ResolvedColor(
      name: 'أبيض لؤلؤي',
      color: Color(0xFFF5F2EB),
      isLight: true,
    );
  } else if (n.contains('أبيض كلكتا') ||
      n.contains('عروق رمادية') ||
      n.contains('إيطالي كلكتا') ||
      n.contains('كلكتا')) {
    result = const ResolvedColor(
      name: 'أبيض كلكتا',
      color: Color(0xFFF5F5F5),
      isLight: true,
      gradient: LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFE5E5E5), Color(0xFFFFFFFF)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('كريمي لايت') ||
      n.contains('سيلكي كريم') ||
      n.contains('كريمي فاتح') ||
      n.contains('كريمي')) {
    result = const ResolvedColor(
      name: 'كريمي',
      color: Color(0xFFFFFDD0),
      isLight: true,
    );
  } else if (n.contains('بيج فاتح') ||
      n.contains('بيج') ||
      n.contains('جراي بيج') ||
      n.contains('بيج بعروق بنية')) {
    result = const ResolvedColor(
      name: 'بيج',
      color: Color(0xFFF5F5DC),
      isLight: true,
    );
  } else if (n.contains('أوف وايت') || n.contains('أوفوايت')) {
    result = const ResolvedColor(
      name: 'أوف وايت',
      color: Color(0xFFFAF9F6),
      isLight: true,
    );
  } else if (n.contains('ثلجي فاتح') || n.contains('ثلجي')) {
    result = const ResolvedColor(
      name: 'ثلجي',
      color: Color(0xFFE0F7FA),
      isLight: true,
    );
  } else if (n.contains('ذهبي') ||
      n.contains('مذهب') ||
      n.contains('ذهب') ||
      n.contains('عروق ذهبية')) {
    result = const ResolvedColor(
      name: 'ذهبي',
      color: Color(0xFFD4AF37),
      isLight: false,
      gradient: LinearGradient(
        colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFFAA7C11)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('سونوما براون') ||
      n.contains('تان أوك') ||
      n.contains('أوك سونوما') ||
      n.contains('سونوما') ||
      n.contains('أوك')) {
    result = const ResolvedColor(
      name: 'سونوما',
      color: Color(0xFFD7B183),
      isLight: true,
      gradient: LinearGradient(
        colors: [Color(0xFFE5C298), Color(0xFFC69C6D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('تيك كلاسيك') ||
      n.contains('تيك أحمر') ||
      n.contains('تيك ميد') ||
      n.contains('تيك')) {
    result = const ResolvedColor(
      name: 'تيك',
      color: Color(0xFFC87D55),
      isLight: false,
      gradient: LinearGradient(
        colors: [Color(0xFFC87D55), Color(0xFF8B4513)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('بُن غامق') ||
      n.contains('بني محروق') ||
      n.contains('وينج دارك') ||
      n.contains('وينج كلاسيك') ||
      n.contains('إيبوني') ||
      n.contains('داركو') ||
      n.contains('بلاك وود') ||
      n.contains('داكن') ||
      n.contains('محروق')) {
    result = const ResolvedColor(
      name: 'بني داكن',
      color: Color(0xFF3E2723),
      isLight: false,
      gradient: LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF271B15)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('بني طبيعي') ||
      n.contains('بني') ||
      n.contains('خشبي')) {
    result = const ResolvedColor(
      name: 'بني طبيعي',
      color: Color(0xFFB08D57),
      isLight: false,
      gradient: LinearGradient(
        colors: [Color(0xFFB08D57), Color(0xFF7A5835)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('تشيري براون') || n.contains('تشيري')) {
    result = const ResolvedColor(
      name: 'بني كرزي',
      color: Color(0xFF8D4F4F),
      isLight: false,
      gradient: LinearGradient(
        colors: [Color(0xFF9E5E5E), Color(0xFF5D2D2D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else if (n.contains('رمادي مودرن') ||
      n.contains('رمادي فاتح') ||
      n.contains('سيلفر ناعم') ||
      n.contains('رمادي') ||
      n.contains('رصاصي') ||
      n.contains('سيلفر')) {
    if (n.contains('رصاصي محروق') || n.contains('رمادي غامق')) {
      result = const ResolvedColor(
        name: 'رمادي غامق',
        color: Color(0xFF4A4A4A),
        isLight: false,
      );
    } else {
      result = const ResolvedColor(
        name: 'رمادي',
        color: Color(0xFFB0B0B0),
        isLight: true,
      );
    }
  } else if (n.contains('أسود') || n.contains('كربون')) {
    result = const ResolvedColor(
      name: 'أسود',
      color: Color(0xFF1E1E1E),
      isLight: false,
    );
  } else if (n.contains('موف خشبي') || n.contains('موف')) {
    result = const ResolvedColor(
      name: 'موف',
      color: Color(0xFF90708C),
      isLight: false,
    );
  } else if (n.contains('بنفسج دخاني') || n.contains('بنفسج')) {
    result = const ResolvedColor(
      name: 'بنفسج',
      color: Color(0xFF6A5ACD),
      isLight: false,
    );
  } else if (n.contains('سيليكون عظم') || n.contains('شفاف')) {
    result = const ResolvedColor(
      name: 'شفاف',
      color: Color(0xFFE0F2F1),
      isLight: true,
    );
  } else if (n.contains('نحاسي') || n.contains('برونز')) {
    result = const ResolvedColor(
      name: 'نحاسي',
      color: Color(0xFFCD7F32),
      isLight: false,
      gradient: LinearGradient(
        colors: [Color(0xFFE5A65D), Color(0xFFCD7F32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  } else {
    result = const ResolvedColor(
      name: 'أساسي',
      color: Color(0xFF8C7853),
      isLight: false,
    );
  }

  _resolvedColorCache[name] = result;
  return result;
}

bool _isActualColor(String name) {
  final cached = _isActualColorCache[name];
  if (cached != null) return cached;

  final n = name.trim().toLowerCase();
  if (n.isEmpty || n == 'أساسي') {
    _isActualColorCache[name] = false;
    return false;
  }

  if (n.contains('×') ||
      n.contains('مم') ||
      n.contains('سم') ||
      RegExp(r'\d+').hasMatch(n)) {
    _isActualColorCache[name] = false;
    return false;
  }

  final colorKeywords = [
    'أبيض',
    'أسود',
    'رمادي',
    'رصاصي',
    'بيج',
    'بني',
    'ذهبي',
    'كريمي',
    'أوف وايت',
    'أوفوايت',
    'سونوما',
    'تيك',
    'وينج',
    'أوك',
    'موف',
    'بنفسج',
    'عروق',
    'نحاسي',
    'برونز',
    'شفاف',
    'كربون',
    'جراي',
    'سيلفر',
    'لايت',
    'كلاسيك',
    'ثلجي',
    'سيلكي',
    'رخام',
    'ميكس',
    'دخاني',
    'بُن',
    'طبيعي',
    'كرزي',
    'بريشيا',
    'لؤلؤي',
    'بيرل',
    'سادة',
    'ملون',
    'براون',
    'بلاك',
    'إيبوني',
    'بلوط',
    'جوز',
    'جوزي',
    'كراميل',
    'فحمي',
    'فضي',
    'عسلي',
    'أوليف',
    'زيتي',
    'وود',
    'داركو',
    'ماربل',
    'بورتورو',
    'تجزيع',
    'داكن',
    'تشيري',
    'أرو',
  ];

  final result = colorKeywords.any((keyword) => n.contains(keyword));
  _isActualColorCache[name] = result;
  return result;
}

String _getTrueColorName(EnrichedProduct p, EnrichedVariant v) {
  final cached = _trueColorNameCache[v.id];
  if (cached != null) return cached;

  String result = 'أساسي';
  if (v.color != null && v.color!.isNotEmpty) {
    final colorName = v.color!.split('|')[0];
    if (colorName != 'أساسي') {
      result = colorName;
    }
  } else if (p.name.contains('-')) {
    final parts = p.name.split('-');
    if (parts.length > 1) {
      final extracted = parts.last.trim();
      if (_isActualColor(extracted)) {
        result = extracted;
      }
    }
  }

  _trueColorNameCache[v.id] = result;
  return result;
}

class _WoodPanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paintBg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD7B183), Color(0xFFB08D57)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, paintBg);

    final double slatWidth = 16.0;
    final Paint linePaint = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.15)
      ..strokeWidth = 2.0;

    final Paint bevelPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (double x = slatWidth; x < size.width; x += slatWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      canvas.drawLine(Offset(x + 2, 0), Offset(x + 2, size.height), bevelPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarbleVeinsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paintBg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFAFAFA), Color(0xFFEEEEEE), Color(0xFFF5F5F5)],
        stops: [0.0, 0.6, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, paintBg);

    final Paint greyVein = Paint()
      ..color = const Color(0xFF9E9E9E).withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint goldVein = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.75,
      size.width,
      size.height * 0.8,
    );
    canvas.drawPath(path1, greyVein);

    final path1Branch = Path();
    path1Branch.moveTo(size.width * 0.5, size.height * 0.5);
    path1Branch.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.2,
    );
    canvas.drawPath(path1Branch, greyVein);

    final path2 = Path();
    path2.moveTo(size.width * 0.2, size.height);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.5,
    );
    path2.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width * 0.9,
      0,
    );
    canvas.drawPath(path2, goldVein);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoneTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paintBg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF37474F), Color(0xFF212121)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, paintBg);

    final Paint cutPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    final Paint lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
      cutPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.3 + 1),
      Offset(size.width, size.height * 0.2 + 1),
      lightPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.8),
      cutPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75 + 1),
      Offset(size.width, size.height * 0.8 + 1),
      lightPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.6, size.height),
      cutPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MoldingPlasterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paintBg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFAFAFA), Color(0xFFF5F5DC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, paintBg);

    final Paint plasterPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final Paint plasterPaintLight = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.3,
      plasterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.3 - 3,
      plasterPaintLight,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.45,
      plasterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.45 - 3,
      plasterPaintLight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Premium Category browsing screen with generic dynamic filtering and inner search.
class CategoryScreen extends ConsumerStatefulWidget {
  final String? groupId;
  final String? categoryName;

  const CategoryScreen({super.key, this.groupId, this.categoryName});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  // Navigation / Base category
  String? _selectedCategory;

  // Memoization fields for extracting options
  List<EnrichedProduct>? _lastAllGroupProducts;
  String? _lastSelectedCategory;

  // Dynamic filter options extracted from active products
  List<String> _extractedSubcategories = [];
  List<String> _extractedBrands = [];
  List<String> _extractedMaterials = [];
  List<String> _extractedDimensions = [];
  List<String> _extractedColors = [];
  double _calculatedMaxPrice = 1000.0;

  // Selected filters
  final Set<String> _selectedSubcategories = {};
  final Set<String> _selectedBrands = {};
  final Set<String> _selectedDimensions = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedMaterials = {};
  RangeValues? _priceRange;

  // Stock filter and sorting
  StockFilter _stockFilter = StockFilter.all;
  CatalogSortBy _sortBy = CatalogSortBy.nameAsc;

  // Inner search state
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CategoryGroup? get _group => widget.groupId != null
      ? CategoryGroup.defaults.cast<CategoryGroup?>().firstWhere(
          (g) => g!.id == widget.groupId,
          orElse: () => null,
        )
      : null;

  Color get _groupColor => _group?.color ?? AppColors.primary;
  String get _title => widget.categoryName ?? _group?.title ?? 'المنتجات';

  @override
  void initState() {
    super.initState();
    if (widget.categoryName != null) _selectedCategory = widget.categoryName;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSubFilters() {
    _selectedSubcategories.clear();
    _selectedBrands.clear();
    _selectedDimensions.clear();
    _selectedColors.clear();
    _selectedMaterials.clear();
    _priceRange = null;
  }

  // Dynamic extraction of options based on the CURRENT category/group products
  void _extractFilterOptions(List<EnrichedProduct> allGroupProducts) {
    // Filter down to the active category first, if any is selected (either via chip or path)
    final activeCat = _selectedCategory ?? widget.categoryName;

    // Check if the inputs have changed, if not, skip recalculating to optimize performance
    if (_lastAllGroupProducts == allGroupProducts &&
        _lastSelectedCategory == activeCat) {
      return;
    }
    _lastAllGroupProducts = allGroupProducts;
    _lastSelectedCategory = activeCat;

    final products = allGroupProducts.where((p) {
      if (widget.groupId != null) {
        if (!_group!.matchesCategory(p.category)) return false;
      }
      if (activeCat != null) {
        return p.category == activeCat;
      }
      return true;
    }).toList();

    // Now extract
    final subcats = <String>{};
    final brands = <String>{};
    final materials = <String>{};
    final dimensions = <String>{};
    final colors = <String>{}; // stores color names only, e.g. "أبيض فيوتك"

    double maxProductPrice = 0.0;

    for (final p in products) {
      if (p.subcategory != null && p.subcategory!.isNotEmpty) {
        subcats.add(p.subcategory!);
      }
      if (p.brand != null && p.brand!.isNotEmpty) {
        brands.add(p.brand!);
      }
      if (p.material != null && p.material!.isNotEmpty) {
        materials.add(p.material!);
      }
      if (p.maxNetPrice > maxProductPrice) {
        maxProductPrice = p.maxNetPrice;
      }
      for (final v in p.variants) {
        if (v.dimensions != null && v.dimensions!.isNotEmpty) {
          dimensions.add(v.dimensions!);
        }
        final colorName = _getTrueColorName(p, v);
        if (colorName.isNotEmpty) {
          colors.add(colorName);
        }
      }
    }

    _extractedSubcategories = subcats.toList()..sort();
    _extractedBrands = brands.toList()..sort();
    _extractedMaterials = materials.toList()..sort();
    _extractedDimensions = dimensions.toList()..sort();
    _extractedColors = colors.where((c) => c != 'أساسي').toList()..sort();
    _calculatedMaxPrice = maxProductPrice > 0 ? maxProductPrice : 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(catalogHubProvider);
    final role = ref.watch(currentUserRoleProvider);
    final canEdit = role == AppRole.owner || role == AppRole.manager;

    // 1. Get filtered products
    final List<EnrichedProduct> products = _getFilteredProducts(hub);

    // 2. Extract filtering options for UI
    _extractFilterOptions(hub.allProducts);

    // 3. Extract categories list inside this group
    final categories =
        hub.allProducts
            .where(
              (p) =>
                  _group != null ? _group!.matchesCategory(p.category) : true,
            )
            .map((p) => p.category)
            .toSet()
            .toList()
          ..sort();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: _buildFilterDrawer(hub.allProducts),
      body: ConstrainedBody(
        child: Stack(
          children: [
            // Background Gradient decoration
            Positioned(
              top: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _groupColor.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: _groupColor.withValues(alpha: 0.1),
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
                _buildSliverAppBar(products.length, canEdit),

                // Category selector chips (shown only when browsing a group containing multiple categories)
                if (widget.groupId != null && categories.length > 1)
                  SliverToBoxAdapter(child: _buildCategoryChips(categories)),

                // In-category search bar
                SliverToBoxAdapter(child: _buildSearchBar()),

                // Active filter tags bar
                SliverToBoxAdapter(child: _buildActiveFiltersBar()),

                // Sorting & quick stock selection bar
                SliverToBoxAdapter(child: _buildSortAndStockBar()),

                // Grid items
                _buildGrid(products, canEdit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<EnrichedProduct> _getFilteredProducts(CatalogHubState hub) {
    var list = hub.allProducts.toList();

    // 1. Filter by Group/Category Name
    if (_group != null) {
      list = list.where((p) => _group!.matchesCategory(p.category)).toList();
    } else if (widget.categoryName != null) {
      list = list.where((p) => p.category == widget.categoryName).toList();
    }

    // 2. Filter by Active Chip Category Selection
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // 3. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      final terms = q.split(RegExp(r'\s+'));
      list = list.where((p) {
        final fields = [
          p.name,
          p.code,
          p.category,
          p.subcategory ?? '',
          p.brand ?? '',
          p.notes ?? '',
          p.unitType,
          ...p.variants.map((v) => v.variantName),
          ...p.variants.map((v) => v.color ?? ''),
          ...p.variants.map((v) => v.dimensions ?? ''),
        ].map((s) => s.toLowerCase()).join(' ');
        return terms.every((t) => fields.contains(t));
      }).toList();
    }

    // 4. Filter by Subcategories
    if (_selectedSubcategories.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.subcategory != null &&
                _selectedSubcategories.contains(p.subcategory),
          )
          .toList();
    }

    // 5. Filter by Brands
    if (_selectedBrands.isNotEmpty) {
      list = list
          .where((p) => p.brand != null && _selectedBrands.contains(p.brand))
          .toList();
    }

    // 6. Filter by Materials
    if (_selectedMaterials.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.material != null && _selectedMaterials.contains(p.material),
          )
          .toList();
    }

    // 7. Filter by Dimensions and Colors (Variant level check)
    if (_selectedDimensions.isNotEmpty || _selectedColors.isNotEmpty) {
      list = list.where((p) {
        return p.variants.any((v) {
          bool dimMatch = true;
          if (_selectedDimensions.isNotEmpty) {
            dimMatch =
                v.dimensions != null &&
                _selectedDimensions.contains(v.dimensions);
          }
          bool colMatch = true;
          if (_selectedColors.isNotEmpty) {
            final colorName = _getTrueColorName(p, v);
            colMatch = _selectedColors.contains(colorName);
          }
          return dimMatch && colMatch;
        });
      }).toList();
    }

    // 8. Filter by Price Range
    if (_priceRange != null) {
      list = list.where((p) {
        if (!p.hasPrice) return _priceRange!.start == 0.0;
        return p.minNetPrice >= _priceRange!.start &&
            p.maxNetPrice <= _priceRange!.end;
      }).toList();
    }

    // 9. Filter by Stock Status
    switch (_stockFilter) {
      case StockFilter.inStock:
        list = list.where((p) => p.stockStatus == StockStatus.inStock).toList();
        break;
      case StockFilter.lowStock:
        list = list
            .where((p) => p.stockStatus == StockStatus.lowStock)
            .toList();
        break;
      case StockFilter.outOfStock:
        list = list
            .where((p) => p.stockStatus == StockStatus.outOfStock)
            .toList();
        break;
      case StockFilter.all:
        break;
    }

    // 10. Sorting
    switch (_sortBy) {
      case CatalogSortBy.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CatalogSortBy.priceLow:
        list.sort((a, b) => a.minNetPrice.compareTo(b.minNetPrice));
        break;
      case CatalogSortBy.priceHigh:
        list.sort((a, b) => b.minNetPrice.compareTo(a.minNetPrice));
        break;
      case CatalogSortBy.stockHigh:
        list.sort((a, b) => b.totalAvailableQty.compareTo(a.totalAvailableQty));
        break;
      case CatalogSortBy.newest:
        break;
    }
    return list;
  }

  Widget _buildSliverAppBar(int count, bool canEdit) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      title: Column(
        children: [
          Text(
            _title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$count منتج',
            style: TextStyle(
              fontSize: 12,
              color: _groupColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list_rounded, color: AppColors.textPrimary),
          tooltip: 'تصفية النتائج',
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        if (canEdit &&
            (_selectedCategory != null || widget.categoryName != null))
          IconButton(
            icon: const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.error,
            ),
            tooltip: 'حذف الفئة',
            onPressed: () => _confirmDeleteCategory(
              context,
              ref,
              _selectedCategory ?? widget.categoryName!,
            ),
          ),
        if (canEdit)
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.textPrimary),
            onPressed: () async {
              final ok = await context.push<bool>('/product/add');
              if (ok == true) {
                ref.read(catalogHubProvider.notifier).invalidate();
              }
            },
          ),
      ],
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip('الكل', _selectedCategory == null, () {
            if (_selectedCategory != null) {
              setState(() {
                _clearSubFilters();
                _selectedCategory = null;
              });
            }
          }),
          ...categories.map(
            (cat) => _buildChip(cat, _selectedCategory == cat, () {
              if (_selectedCategory != cat) {
                setState(() {
                  _clearSubFilters();
                  _selectedCategory = cat;
                });
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: _groupColor,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? _groupColor : AppColors.border),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        blur: 15,
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'البحث عن كود، لون أو مقاس...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersBar() {
    final tags = <Widget>[];

    for (final s in _selectedSubcategories) {
      tags.add(
        _buildActiveFilterChip(
          s,
          () => setState(() => _selectedSubcategories.remove(s)),
        ),
      );
    }
    for (final d in _selectedDimensions) {
      tags.add(
        _buildActiveFilterChip(
          d,
          () => setState(() => _selectedDimensions.remove(d)),
        ),
      );
    }
    for (final c in _selectedColors) {
      tags.add(
        _buildActiveFilterChip(
          c,
          () => setState(() => _selectedColors.remove(c)),
        ),
      );
    }
    for (final b in _selectedBrands) {
      tags.add(
        _buildActiveFilterChip(
          b,
          () => setState(() => _selectedBrands.remove(b)),
        ),
      );
    }
    for (final m in _selectedMaterials) {
      tags.add(
        _buildActiveFilterChip(
          m,
          () => setState(() => _selectedMaterials.remove(m)),
        ),
      );
    }
    if (_priceRange != null) {
      tags.add(
        _buildActiveFilterChip(
          'سعر: ${_priceRange!.start.toStringAsFixed(0)} - ${_priceRange!.end.toStringAsFixed(0)} ج.م',
          () => setState(() => _priceRange = null),
        ),
      );
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          TextButton(
            onPressed: () => setState(() => _clearSubFilters()),
            child: const Text(
              'مسح الكل',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ...tags,
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        onDeleted: onDelete,
        backgroundColor: _groupColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: _groupColor.withValues(alpha: 0.2)),
        ),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }

  Widget _buildSortAndStockBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<CatalogSortBy>(
              value: _sortBy,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
              items: const [
                DropdownMenuItem(
                  value: CatalogSortBy.nameAsc,
                  child: Text('أبجدي'),
                ),
                DropdownMenuItem(
                  value: CatalogSortBy.priceLow,
                  child: Text('الأقل سعراً'),
                ),
                DropdownMenuItem(
                  value: CatalogSortBy.priceHigh,
                  child: Text('الأعلى سعراً'),
                ),
                DropdownMenuItem(
                  value: CatalogSortBy.stockHigh,
                  child: Text('الأكثر مخزوناً'),
                ),
              ],
              onChanged: (v) => setState(() => _sortBy = v!),
            ),
          ),
          const Spacer(),
          // Quick stock filters
          ...[StockFilter.all, StockFilter.inStock, StockFilter.lowStock].map((
            f,
          ) {
            final label = f == StockFilter.all
                ? 'الكل'
                : f == StockFilter.inStock
                ? 'متاح'
                : 'منخفض';
            final color = f == StockFilter.inStock
                ? AppColors.success
                : f == StockFilter.lowStock
                ? AppColors.warning
                : AppColors.textSecondary;
            final sel = _stockFilter == f;
            return GestureDetector(
              onTap: () => setState(() => _stockFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? color : AppColors.border),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: sel ? color : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterDrawer(List<EnrichedProduct> allGroupProducts) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              border: Border(
                left: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تصفية النتائج',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _clearSubFilters());
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'إعادة ضبط',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Scrollable filters
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Subcategory / Type Filter
                        if (_extractedSubcategories.isNotEmpty) ...[
                          _buildFilterSectionTitle('النوع / التصنيف الفرعي'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _extractedSubcategories.map((sc) {
                              final sel = _selectedSubcategories.contains(sc);
                              return _buildCustomFilterChip(
                                label: sc,
                                isSelected: sel,
                                onTap: () {
                                  setState(() {
                                    if (sel) {
                                      _selectedSubcategories.remove(sc);
                                    } else {
                                      _selectedSubcategories.add(sc);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Color swatches selector (Flexible Wrap layout with Pills)
                        if (_extractedColors.isNotEmpty) ...[
                          _buildFilterSectionTitle('الألوان المتوفرة'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _extractedColors.map((colorName) {
                              final resolved = resolveColor(colorName);
                              final sel = _selectedColors.contains(colorName);
                              final visualColor = resolved.color;
                              final gradient = resolved.gradient;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (sel) {
                                      _selectedColors.remove(colorName);
                                    } else {
                                      _selectedColors.add(colorName);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? _groupColor.withValues(alpha: 0.1)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: sel
                                          ? _groupColor
                                          : AppColors.border,
                                      width: 1.5,
                                    ),
                                    boxShadow: sel
                                        ? [
                                            BoxShadow(
                                              color: _groupColor.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: gradient == null
                                              ? visualColor
                                              : null,
                                          gradient: gradient,
                                          border: Border.all(
                                            color:
                                                visualColor.computeLuminance() >
                                                    0.8
                                                ? Colors.black.withValues(
                                                    alpha: 0.15,
                                                  )
                                                : Colors.transparent,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: sel
                                            ? Icon(
                                                Icons.check,
                                                size: 11,
                                                color:
                                                    visualColor
                                                            .computeLuminance() >
                                                        0.6
                                                    ? Colors.black
                                                    : Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        colorName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: sel
                                              ? _groupColor
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Dimensions / Size selector
                        if (_extractedDimensions.isNotEmpty) ...[
                          _buildFilterSectionTitle('المقاس والأبعاد'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _extractedDimensions.map((dim) {
                              final sel = _selectedDimensions.contains(dim);
                              return _buildCustomFilterChip(
                                label: dim,
                                isSelected: sel,
                                onTap: () {
                                  setState(() {
                                    if (sel) {
                                      _selectedDimensions.remove(dim);
                                    } else {
                                      _selectedDimensions.add(dim);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Material / Raw Material Filter
                        if (_extractedMaterials.isNotEmpty) ...[
                          _buildFilterSectionTitle('الخامة والتركيب'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _extractedMaterials.map((mat) {
                              final sel = _selectedMaterials.contains(mat);
                              return _buildCustomFilterChip(
                                label: mat,
                                isSelected: sel,
                                onTap: () {
                                  setState(() {
                                    if (sel) {
                                      _selectedMaterials.remove(mat);
                                    } else {
                                      _selectedMaterials.add(mat);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Brand Selector
                        if (_extractedBrands.isNotEmpty) ...[
                          _buildFilterSectionTitle('الماركة / البراند'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _extractedBrands.map((b) {
                              final sel = _selectedBrands.contains(b);
                              return _buildCustomFilterChip(
                                label: b,
                                isSelected: sel,
                                onTap: () {
                                  setState(() {
                                    if (sel) {
                                      _selectedBrands.remove(b);
                                    } else {
                                      _selectedBrands.add(b);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Price Dual Range Slider
                        _buildFilterSectionTitle('النطاق السعري'),
                        const SizedBox(height: 10),
                        RangeSlider(
                          values:
                              _priceRange ??
                              RangeValues(0.0, _calculatedMaxPrice),
                          min: 0.0,
                          max: _calculatedMaxPrice,
                          divisions: _calculatedMaxPrice > 100
                              ? (_calculatedMaxPrice / 10).round()
                              : 10,
                          activeColor: _groupColor,
                          inactiveColor: AppColors.border,
                          labels: RangeLabels(
                            '${(_priceRange ?? RangeValues(0.0, _calculatedMaxPrice)).start.toStringAsFixed(0)} ج.م',
                            '${(_priceRange ?? RangeValues(0.0, _calculatedMaxPrice)).end.toStringAsFixed(0)} ج.م',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0 ج.م',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_calculatedMaxPrice.toStringAsFixed(0)} ج.م',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Footer Action
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: _groupColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تطبيق التصفية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildCustomFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _groupColor.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _groupColor : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _groupColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? _groupColor : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<EnrichedProduct> products, bool canEdit) {
    final List<Map<String, dynamic>> flatItems = [];
    for (final p in products) {
      for (final v in p.variants) {
        bool matchDim =
            _selectedDimensions.isEmpty ||
            (v.dimensions != null &&
                _selectedDimensions.contains(v.dimensions));
        bool matchCol =
            _selectedColors.isEmpty ||
            (_selectedColors.contains(_getTrueColorName(p, v)));
        if (matchDim && matchCol) {
          flatItems.add({'product': p, 'variant': v});
        }
      }
    }

    if (flatItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 64,
                color: _groupColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد منتجات بهذه الفلاتر',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1200
              ? 6
              : MediaQuery.of(context).size.width > 800
              ? 4
              : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.60, // Taller to fit variant info
        ),
        delegate: SliverChildBuilderDelegate((ctx, i) {
          final item = flatItems[i];
          final EnrichedProduct p = item['product'];
          final EnrichedVariant v = item['variant'];
          return PremiumVariantCard(
            product: p,
            variant: v,
            groupColor: _groupColor,
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
                    extra: {
                      'product': p.toRawMap(),
                      'variant': {
                        'id': v.id,
                        'product_id': v.productId,
                        'variant_name': v.variantName,
                        'color': v.color,
                        'dimensions': v.dimensions,
                        'piece_length': v.pieceLength,
                        'piece_width': v.pieceWidth,
                        'thickness': v.thickness,
                        'net_price': v.netPrice,
                        'list_price': v.listPrice,
                      },
                    },
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
                ? () => _confirmDeleteVariant(context, ref, p, v)
                : null,
          );
        }, childCount: flatItems.length),
      ),
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    String categoryName,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'حذف الفئة بالكامل',
      message: 'هل أنت متأكد من حذف الفئة "$categoryName" وجميع المنتجات والأصناف التابعة لها؟\nهذا الإجراء لا يمكن التراجع عنه.',
      confirmLabel: 'نعم، احذف',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );

    if (!confirmed || !context.mounted) return;

    try {
      final client = ref.read(supabaseProvider);
      await client
          .from('products')
          .delete()
          .eq('category', categoryName);
      ref.read(catalogHubProvider.notifier).invalidate();
      if (context.mounted) {
        AppToast.showSuccess(context, 'تم حذف الفئة بنجاح ✓');
        if (widget.categoryName != null) {
          context.pop();
        } else {
          setState(() => _selectedCategory = null);
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, 'حدث خطأ: $e');
      }
    }
  }

  Future<void> _confirmDeleteVariant(
    BuildContext context,
    WidgetRef ref,
    EnrichedProduct product,
    EnrichedVariant variant,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'تأكيد حذف الصنف',
      message: 'هل أنت متأكد من حذف صنف "${variant.variantName}" من منتج "${product.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.',
      confirmLabel: 'نعم، احذف',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );

    if (!confirmed || !context.mounted) return;

    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteVariant(variant.id.toString());
      ref.read(catalogHubProvider.notifier).invalidate();
      if (context.mounted) {
        AppToast.showSuccess(context, 'تم حذف الصنف بنجاح ✓');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, 'حدث خطأ: $e');
      }
    }
  }
}

// ─── Premium Variant Card ──────────────────────────────────────
class PremiumVariantCard extends StatefulWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final Color groupColor;
  final VoidCallback onTap;
  final VoidCallback? onCalculate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PremiumVariantCard({
    super.key,
    required this.product,
    required this.variant,
    required this.groupColor,
    required this.onTap,
    this.onCalculate,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PremiumVariantCard> createState() => _PremiumVariantCardState();
}

class _PremiumVariantCardState extends State<PremiumVariantCard> {
  bool _isHovered = false;
  bool _isTapped = false;

  Widget _buildImagePlaceholder(EnrichedProduct product, Color groupColor) {
    final cat = product.category;

    if (cat.contains('\u062e\u0634\u0628')) {
      return CustomPaint(
        painter: _WoodPanelPainter(),
        child: _buildBadgeOverlay(product.code, const Color(0xFF5D4037)),
      );
    } else if (cat.contains('\u0631\u062e\u0627\u0645')) {
      return CustomPaint(
        painter: _MarbleVeinsPainter(),
        child: _buildBadgeOverlay(product.code, const Color(0xFF37474F)),
      );
    } else if (cat.contains('\u062d\u062c\u0631')) {
      return CustomPaint(
        painter: _StoneTexturePainter(),
        child: _buildBadgeOverlay(product.code, const Color(0xFF263238)),
      );
    } else if (cat.contains('\u0628\u064a\u062a \u0646\u0648\u0631') ||
        cat.contains('\u0643\u0631\u0627\u0646\u064a\u0634') ||
        cat.contains('\u0635\u0631\u0631') ||
        cat.contains('\u0628\u0627\u0646\u0648')) {
      return CustomPaint(
        painter: _MoldingPlasterPainter(),
        child: _buildBadgeOverlay(product.code, groupColor),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            groupColor.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: _buildBadgeOverlay(product.code, groupColor),
    );
  }

  Widget _buildBadgeOverlay(String code, Color themeColor) {
    if (code.isEmpty) return const SizedBox.shrink();
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: themeColor,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDim(double d) {
    if (d <= 0) return '';
    double cm = d * 100;
    return '${cm == cm.roundToDouble() ? cm.toInt() : cm.toStringAsFixed(1)}سم';
  }

  Widget? _buildSpecRow(EnrichedVariant v) {
    final List<Widget> specs = [];

    if (v.dimensions != null && v.dimensions!.isNotEmpty) {
      specs.add(_buildMiniSpec(Icons.aspect_ratio_rounded, v.dimensions!));
    } else if (v.pieceLength > 0) {
      final len = _formatDim(v.pieceLength);
      if (v.pieceWidth > 0) {
        specs.add(
          _buildMiniSpec(
            Icons.aspect_ratio_rounded,
            '$len × ${_formatDim(v.pieceWidth)}',
          ),
        );
      } else {
        specs.add(_buildMiniSpec(Icons.height_rounded, len));
      }
    }

    if (v.thickness > 0) {
      specs.add(_buildMiniSpec(Icons.layers_rounded, '${v.thickness} مم'));
    }

    if (v.color != null && v.color!.isNotEmpty) {
      final parts = v.color!.split('|');
      final name = parts[0];
      if (name.isNotEmpty && !name.startsWith('#')) {
        specs.add(_buildMiniSpec(Icons.color_lens_outlined, name));
      }
    }

    if (specs.isEmpty) return null;

    return Wrap(spacing: 6, runSpacing: 4, children: specs);
  }

  Widget _buildMiniSpec(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.variant;
    final p = widget.product;
    final String displayImageUrl = v.imageUrl ?? p.imageUrl ?? '';
    final specWidget = _buildSpecRow(v);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) => setState(() => _isTapped = false),
        onTapCancel: () => setState(() => _isTapped = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            _isTapped ? 0.96 : (_isHovered ? 1.03 : 1.0),
            _isTapped ? 0.96 : (_isHovered ? 1.03 : 1.0),
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? widget.groupColor.withValues(alpha: 0.5)
                  : AppColors.border,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.groupColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 20 : 10,
                offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Image Half
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(23),
                        ),
                        child: displayImageUrl.isNotEmpty
                            ? Image.network(
                                displayImageUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 400,
                              )
                            : _buildImagePlaceholder(p, widget.groupColor),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _StockBadge(status: v.stockStatus),
                      ),
                      // Edit/Delete overlay on image
                      if (widget.onEdit != null || widget.onDelete != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              color: AppColors.surface,
                              onSelected: (val) {
                                if (val == 'edit') widget.onEdit?.call();
                                if (val == 'delete') widget.onDelete?.call();
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: widget.groupColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تعديل',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: widget.groupColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_rounded,
                                        size: 16,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
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
                            ),
                          ),
                        ),

                      if (widget.onCalculate != null)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: widget.onCalculate,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.groupColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.groupColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.calculate_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Bottom Info Half
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المنتج
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // المواصفات (أبعاد / سُمك / لون)
                        if (specWidget != null) ...[
                          specWidget,
                          const SizedBox(height: 6),
                        ],
                        // صف الكود + المخزون
                        Row(
                          children: [
                            // كود الصنف (الـ Variant Name)
                            if (v.variantName.isNotEmpty) ...[
                              (() {
                                final rawCode = p.code.isNotEmpty ? p.code : v.variantName;
                                final cleanedCode = rawCode
                                    .replaceAll(RegExp(r'\s*\(\)\s*'), '')
                                    .trim();
                                if (cleanedCode.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.groupColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.groupColor.withValues(
                                          alpha: 0.25,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.tag_rounded,
                                          size: 12,
                                          color: widget.groupColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            cleanedCode,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: widget.groupColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })(),
                              const SizedBox(width: 8),
                            ],
                            // المخزون
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 12,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              v.availableQty.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 11,
                                color: v.availableQty > 0
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            v.hasPrice
                                ? '${v.netPrice.toStringAsFixed(0)} ج.م'
                                : 'بدون سعر',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: v.hasPrice
                                  ? AppColors.textPrimary
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stock Badge ─────────────────────────────────────────────────
class _StockBadge extends StatelessWidget {
  final StockStatus status;
  const _StockBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case StockStatus.inStock:
        color = AppColors.success;
        label = 'متاح';
        break;
      case StockStatus.lowStock:
        color = AppColors.warning;
        label = 'منخفض';
        break;
      case StockStatus.outOfStock:
        color = AppColors.error;
        label = 'نفد';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
