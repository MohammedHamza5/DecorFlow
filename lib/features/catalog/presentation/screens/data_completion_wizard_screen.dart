import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/features/catalog/data/pricing_repository.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:stream_pay/features/catalog/presentation/widgets/unified_category_pricing_modal.dart';

// ─── Data Quality Item Types ─────────────────────────────────────────────────

enum QualityIssueType {
  missingImage,
  missingCode,
  missingPrice,
  missingDimensions,
  noVariants,
}

// ─── Filter Mode ─────────────────────────────────────────────────────────────

enum QualityFilter {
  all,
  missingPrice,
  missingDimensions,
  missingImage,
  missingCode,
  noVariants,
}

extension QualityFilterExt on QualityFilter {
  String get label {
    switch (this) {
      case QualityFilter.all: return 'الكل';
      case QualityFilter.missingPrice: return 'بدون سعر';
      case QualityFilter.missingDimensions: return 'بدون مقاسات';
      case QualityFilter.missingImage: return 'بدون صورة';
      case QualityFilter.missingCode: return 'بدون كود';
      case QualityFilter.noVariants: return 'بدون أصناف';
    }
  }

  IconData get icon {
    switch (this) {
      case QualityFilter.all: return Icons.apps_rounded;
      case QualityFilter.missingPrice: return Icons.money_off_rounded;
      case QualityFilter.missingDimensions: return Icons.straighten_rounded;
      case QualityFilter.missingImage: return Icons.image_not_supported_rounded;
      case QualityFilter.missingCode: return Icons.code_off_rounded;
      case QualityFilter.noVariants: return Icons.layers_clear_rounded;
    }
  }

  Color get color {
    switch (this) {
      case QualityFilter.all: return AppColors.primary;
      case QualityFilter.missingPrice: return const Color(0xFFEF4444);
      case QualityFilter.missingDimensions: return const Color(0xFF06B6D4);
      case QualityFilter.missingImage: return const Color(0xFF8B5CF6);
      case QualityFilter.missingCode: return const Color(0xFFF59E0B);
      case QualityFilter.noVariants: return const Color(0xFF10B981);
    }
  }
}

// ─── Product Issue Model ─────────────────────────────────────────────────────

class ProductIssue {
  final EnrichedProduct product;
  final EnrichedVariant? variant;
  final QualityIssueType type;
  bool _dismissed = false;

  ProductIssue({required this.product, this.variant, required this.type});

  bool get isDismissed => _dismissed;
  void dismiss() => _dismissed = true;

  String get productId => product.id;
  String get productName => product.name.isEmpty ? 'بدون اسم' : product.name;
  String get category => product.category;
  String? get variantId => variant?.id;
  String get variantName => variant?.variantName ?? '';

  String get issueLabel {
    switch (type) {
      case QualityIssueType.missingImage: return 'صورة مفقودة';
      case QualityIssueType.missingCode: return 'كود مفقود';
      case QualityIssueType.missingPrice: return 'سعر مفقود';
      case QualityIssueType.missingDimensions: return 'مقاسات ناقصة';
      case QualityIssueType.noVariants: return 'لا توجد أصناف';
    }
  }

  Color get issueColor => switch (type) {
    QualityIssueType.missingPrice => const Color(0xFFEF4444),
    QualityIssueType.missingDimensions => const Color(0xFF06B6D4),
    QualityIssueType.missingImage => const Color(0xFF8B5CF6),
    QualityIssueType.missingCode => const Color(0xFFF59E0B),
    QualityIssueType.noVariants => const Color(0xFF10B981),
  };
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class DataCompletionWizardScreen extends ConsumerStatefulWidget {
  const DataCompletionWizardScreen({super.key});

  @override
  ConsumerState<DataCompletionWizardScreen> createState() =>
      _DataCompletionWizardScreenState();
}

class _DataCompletionWizardScreenState
    extends ConsumerState<DataCompletionWizardScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  QualityFilter _activeFilter = QualityFilter.all;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  bool _multiSelectMode = false;
  final Set<String> _selectedProductIds = {};
  late AnimationController _fabAnimCtrl;

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  // Build all issues with modern, intelligent checks
  List<ProductIssue> _buildIssues(List<EnrichedProduct> products) {
    final issues = <ProductIssue>[];
    for (final p in products) {
      final unit = p.unitType;

      // 1. No variants
      if (p.variants.isEmpty) {
        issues.add(ProductIssue(product: p, type: QualityIssueType.noVariants));
      }

      // 2. Missing image
      if (p.imageUrl == null || p.imageUrl!.isEmpty) {
        issues.add(ProductIssue(product: p, type: QualityIssueType.missingImage));
      }

      // 3. Missing code
      if (p.code.trim().isEmpty) {
        issues.add(ProductIssue(product: p, type: QualityIssueType.missingCode));
      }

      // 4. Variant-level checks
      for (final v in p.variants) {
        // Missing price check: check modern resolved selling price
        final displaySelling = v.sellingPrice;
        if (displaySelling <= 0) {
          issues.add(ProductIssue(product: p, variant: v, type: QualityIssueType.missingPrice));
        }

        // Missing dimensions check:
        // Respect piece-based categories (rosettes, adhesives, accessories) and textual dimensions
        final isPieceCategory = p.category.contains('صر') ||
            p.category.contains('إكسسوار') ||
            p.category.contains('اكسسوار') ||
            p.category.contains('لاصق') ||
            p.category.contains('سيليكون') ||
            p.category.contains('بت لور') ||
            p.category.contains('معجون') ||
            p.category.contains('أدوات');
        final hasTextDimensions = v.dimensions != null && v.dimensions!.trim().isNotEmpty;
        final isLinearProfile = p.category.contains('بانو') || p.category.contains('كرانيش') || p.category.contains('وزرات');

        bool hasValidDim = false;
        if (isPieceCategory || unit == 'piece' || unit == 'box' || unit == 'tube' || unit == 'container') {
          hasValidDim = true; // Piece-based decor items do not require length x width
        } else if (hasTextDimensions) {
          hasValidDim = true;
        } else if (isLinearProfile) {
          hasValidDim = v.pieceLength > 0;
        } else {
          hasValidDim = v.pieceLength > 0 && v.pieceWidth > 0;
        }

        if (!hasValidDim) {
          issues.add(ProductIssue(product: p, variant: v, type: QualityIssueType.missingDimensions));
        }
      }
    }
    return issues;
  }

  // Filter issues by active filter + search
  List<ProductIssue> _filteredIssues(List<ProductIssue> all) {
    return all.where((issue) {
      if (_activeFilter != QualityFilter.all) {
        final match = switch (_activeFilter) {
          QualityFilter.missingImage => issue.type == QualityIssueType.missingImage,
          QualityFilter.missingCode => issue.type == QualityIssueType.missingCode,
          QualityFilter.missingPrice => issue.type == QualityIssueType.missingPrice,
          QualityFilter.missingDimensions => issue.type == QualityIssueType.missingDimensions,
          QualityFilter.noVariants => issue.type == QualityIssueType.noVariants,
          QualityFilter.all => true,
        };
        if (!match) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return issue.productName.toLowerCase().contains(q) ||
               issue.category.toLowerCase().contains(q) ||
               issue.variantName.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Map<QualityFilter, int> _countByFilter(List<ProductIssue> all) {
    final counts = <QualityFilter, int>{QualityFilter.all: all.length};
    for (final f in QualityFilter.values) {
      if (f == QualityFilter.all) continue;
      counts[f] = all.where((i) {
        return switch (f) {
          QualityFilter.missingImage => i.type == QualityIssueType.missingImage,
          QualityFilter.missingCode => i.type == QualityIssueType.missingCode,
          QualityFilter.missingPrice => i.type == QualityIssueType.missingPrice,
          QualityFilter.missingDimensions => i.type == QualityIssueType.missingDimensions,
          QualityFilter.noVariants => i.type == QualityIssueType.noVariants,
          QualityFilter.all => true,
        };
      }).length;
    }
    return counts;
  }

  void _showBatchCategoryPricingSheet(String category, int count) {
    final group = resolveCategoryGroup(category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UnifiedCategoryPricingModal(
        categoryTitle: group.title,
        categoryAliases: group.aliases,
        icon: group.icon,
        affectedCount: count,
        onSuccess: () {
          ref.read(catalogHubProvider.notifier).invalidate();
          ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(catalogHubProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConstrainedBody(
        child: _buildBody(hubState),
      ),
    );
  }

  Widget _buildBody(CatalogHubState hubState) {
    if (hubState.isLoading && hubState.allProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hubState.error != null && hubState.allProducts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('فشل التحميل: ${hubState.error}', style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.read(catalogHubProvider.notifier).load(forceRefresh: true),
            child: const Text('إعادة المحاولة'),
          ),
        ]),
      );
    }

    final products = hubState.allProducts;
    final allIssues = _buildIssues(products);
    final counts = _countByFilter(allIssues);
    final filtered = _filteredIssues(allIssues);

    // Group missing prices by category for smart 1-click batch fix
    final Map<String, int> missingPriceCategories = {};
    for (final issue in allIssues) {
      if (issue.type == QualityIssueType.missingPrice) {
        missingPriceCategories[issue.category] =
            (missingPriceCategories[issue.category] ?? 0) + 1;
      }
    }

    // Health score calculations
    final totalVariantsCount = products.fold<int>(0, (s, p) => s + p.variants.length);
    final totalChecks = (products.length * 2) + (totalVariantsCount * 2);
    final healthScore = totalChecks > 0
        ? (((totalChecks - allIssues.length) / totalChecks) * 100).clamp(0, 100).round()
        : 100;

    return CustomScrollView(
      slivers: [
        // ─── App Bar ──────────────────────────────────
        SliverAppBar(
          pinned: true,
          floating: false,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('جودة البيانات الذكية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.1)),
              Text(
                '${allIssues.length} تنبيه في ${products.length} منتج • اكتمال المعرض: $healthScore%',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_multiSelectMode ? Icons.close_rounded : Icons.checklist_rounded),
              tooltip: _multiSelectMode ? 'إلغاء التحديد' : 'تحديد متعدد',
              onPressed: () => setState(() {
                _multiSelectMode = !_multiSelectMode;
                _selectedProductIds.clear();
              }),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'إعادة فحص الجودة ومزامنة القواعد',
              onPressed: () {
                ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
                if (mounted) {
                  AppToast.showSuccess(context, 'تمت إعادة تقييم جودة البيانات');
                }
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.border),
          ),
        ),

        // ─── Health Score Progress Card ───────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (healthScore >= 90 ? AppColors.success : (healthScore >= 70 ? Colors.orange : AppColors.error)).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          healthScore >= 90 ? Icons.verified_rounded : Icons.health_and_safety_rounded,
                          color: healthScore >= 90 ? AppColors.success : (healthScore >= 70 ? Colors.orange : AppColors.error),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مؤشر اكتمال المعرض: $healthScore%',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            Text(
                              healthScore >= 90
                                  ? 'كتالوج المعرض بحالة ممتازة وجاهز للبيع والفوترة'
                                  : 'استخدم الإصلاح السريع بالأسفل لتسعير الفئات دفعة واحدة',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$healthScore%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: healthScore >= 90 ? AppColors.success : (healthScore >= 70 ? Colors.orange : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: healthScore / 100.0,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        healthScore >= 90 ? AppColors.success : (healthScore >= 70 ? Colors.orange : AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Hero Batch Pricing Auto-Fix Clusters ───────
        if (missingPriceCategories.isNotEmpty &&
            (_activeFilter == QualityFilter.all || _activeFilter == QualityFilter.missingPrice))
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'إصلاح ذكي جماعي: تسعير فئات كاملة بنقرة واحدة ⚡',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '${counts[QualityFilter.missingPrice] ?? 0} صنف',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'بدلاً من تسعير الأصناف واحداً تلو الآخر، حدد سعر الفئة الموحد ليتم حل جميع المشاكل فوراً:',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: missingPriceCategories.entries.map((entry) {
                      return FilledButton.icon(
                        onPressed: () => _showBatchCategoryPricingSheet(entry.key, entry.value),
                        icon: const Icon(Icons.auto_awesome, size: 14),
                        label: Text(
                          'تسعير ${entry.key} (${entry.value} صنف)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

        // ─── Search Bar ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ابحث باسم المنتج أو التصنيف...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),
        ),

        // ─── Filter Chips ─────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 94,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              scrollDirection: Axis.horizontal,
              children: QualityFilter.values.map((f) {
                final count = counts[f] ?? 0;
                final isActive = _activeFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? f.color : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isActive ? f.color : AppColors.border, width: isActive ? 0 : 1),
                      boxShadow: isActive ? [BoxShadow(color: f.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(f.icon, size: 18, color: isActive ? Colors.white : f.color),
                        const SizedBox(height: 2),
                        Text(f.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? Colors.white : AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: isActive ? Colors.white.withValues(alpha: 0.25) : f.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActive ? Colors.white : f.color)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ─── Multi-select action bar ──────────────────
        if (_multiSelectMode && _selectedProductIds.isNotEmpty)
          SliverToBoxAdapter(
            child: _MultiSelectBar(
              count: _selectedProductIds.length,
              onDeleteAll: () => _confirmBulkDelete(products),
              onClear: () => setState(() => _selectedProductIds.clear()),
            ),
          ),

        // ─── Issues List / Empty ──────────────────────
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                    child: Icon(
                      allIssues.isEmpty ? Icons.verified_rounded : Icons.search_off_rounded,
                      size: 64,
                      color: allIssues.isEmpty ? AppColors.success : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    allIssues.isEmpty ? 'ممتاز! لا توجد مشاكل في البيانات 🎉' : 'لا توجد نتائج للفلتر المحدد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    allIssues.isEmpty ? 'جميع المنتجات مكتملة من ناحية الصور والأسعار والمقاسات' : 'جرّب تغيير الفلتر أو كلمة البحث',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final issue = filtered[i];
                return _IssueCard(
                  key: ValueKey('${issue.productId}-${issue.type}-${issue.variantId}'),
                  issue: issue,
                  isSelected: _multiSelectMode && _selectedProductIds.contains(issue.productId),
                  multiSelectMode: _multiSelectMode,
                  onSelect: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedProductIds.add(issue.productId);
                      } else {
                        _selectedProductIds.remove(issue.productId);
                      }
                    });
                  },
                  onFix: () => _showFixDialog(issue),
                  onDeleteProduct: () => _confirmDeleteProduct(issue.product),
                  onDeleteVariant: issue.variant != null
                      ? () => _confirmDeleteVariant(issue.product, issue.variant!)
                      : null,
                  onDeleteCategory: () => _confirmDeleteCategory(issue.category),
                );
              },
            ),
          ),
      ],
    );
  }

  // ─── Fix Dialog ───────────────────────────────────────────────
  void _showFixDialog(ProductIssue issue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FixBottomSheet(
        issue: issue,
        picker: _picker,
        onSaved: () {
          ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
        },
      ),
    );
  }

  // ─── Delete Product ───────────────────────────────────────────
  Future<void> _confirmDeleteProduct(EnrichedProduct product) async {
    final confirmed = await _showDeleteConfirm(
      title: 'حذف المنتج',
      body: 'هل أنت متأكد من حذف المنتج "${product.name}" وجميع أصنافه وبياناته؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteProduct(product.id);
      ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
      if (mounted) {
        AppToast.showSuccess(context, 'تم حذف المنتج بنجاح');
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'خطأ: $e');
    }
  }

  // ─── Delete Variant ───────────────────────────────────────────
  Future<void> _confirmDeleteVariant(EnrichedProduct product, EnrichedVariant variant) async {
    final confirmed = await _showDeleteConfirm(
      title: 'حذف الصنف',
      body: 'هل أنت متأكد من حذف الصنف "${variant.variantName}" من منتج "${product.name}"؟',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteVariant(variant.id);
      ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
      if (mounted) AppToast.showSuccess(context, 'تم حذف الصنف بنجاح');
    } catch (e) {
      if (mounted) AppToast.showError(context, 'خطأ: $e');
    }
  }

  // ─── Delete Category ──────────────────────────────────────────
  Future<void> _confirmDeleteCategory(String category) async {
    final hubState = ref.read(catalogHubProvider);
    final productCount = hubState.allProducts.where((p) => p.category == category).length;

    final confirmed = await _showDeleteConfirm(
      title: 'حذف التصنيف كاملاً',
      body: 'هل أنت متأكد من حذف تصنيف "$category" و$productCount منتج بالكامل؟\n\n⚠️ تحذير: سيتم حذف جميع المنتجات والأصناف والأسعار المرتبطة بهذا التصنيف نهائياً.',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteCategory(category);
      ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
      if (mounted) AppToast.showSuccess(context, 'تم حذف التصنيف "$category" بالكامل');
    } catch (e) {
      if (mounted) AppToast.showError(context, 'خطأ: $e');
    }
  }

  // ─── Bulk Delete ──────────────────────────────────────────────
  Future<void> _confirmBulkDelete(List<EnrichedProduct> allProducts) async {
    final count = _selectedProductIds.length;
    final confirmed = await _showDeleteConfirm(
      title: 'حذف $count منتج',
      body: 'هل أنت متأكد من حذف $count منتجاً وجميع أصنافهم وبياناتهم؟\n\n⚠️ هذا الإجراء لا يمكن التراجع عنه.',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(productRepositoryProvider);
      for (final id in _selectedProductIds) {
        await repo.deleteProduct(id);
      }
      setState(() {
        _selectedProductIds.clear();
        _multiSelectMode = false;
      });
      ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
      if (mounted) AppToast.showSuccess(context, 'تم حذف $count منتجاً بنجاح');
    } catch (e) {
      if (mounted) AppToast.showError(context, 'خطأ: $e');
    }
  }

  Future<bool> _showDeleteConfirm({required String title, required String body, bool danger = false}) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          Icon(Icons.warning_rounded, color: danger ? AppColors.error : AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
        content: Text(body, style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: danger ? AppColors.error : AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('تأكيد الحذف', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    ) ?? false;
  }
}

// ─── Multi-select Bar ────────────────────────────────────────────────────────

class _MultiSelectBar extends StatelessWidget {
  final int count;
  final VoidCallback onDeleteAll;
  final VoidCallback onClear;
  const _MultiSelectBar({required this.count, required this.onDeleteAll, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)), child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
        const SizedBox(width: 10),
        const Expanded(child: Text('منتج محدد', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
        TextButton(onPressed: onClear, child: const Text('إلغاء')),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onDeleteAll,
          icon: const Icon(Icons.delete_forever_rounded, size: 16),
          label: const Text('حذف الكل'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ]),
    );
  }
}

// ─── Issue Card ──────────────────────────────────────────────────────────────

class _IssueCard extends StatelessWidget {
  final ProductIssue issue;
  final bool isSelected;
  final bool multiSelectMode;
  final void Function(bool) onSelect;
  final VoidCallback onFix;
  final VoidCallback onDeleteProduct;
  final VoidCallback? onDeleteVariant;
  final VoidCallback onDeleteCategory;

  const _IssueCard({
    super.key,
    required this.issue,
    required this.isSelected,
    required this.multiSelectMode,
    required this.onSelect,
    required this.onFix,
    required this.onDeleteProduct,
    this.onDeleteVariant,
    required this.onDeleteCategory,
  });

  IconData get _typeIcon => switch (issue.type) {
    QualityIssueType.missingImage => Icons.image_not_supported_rounded,
    QualityIssueType.missingCode => Icons.code_off_rounded,
    QualityIssueType.missingPrice => Icons.money_off_rounded,
    QualityIssueType.missingDimensions => Icons.straighten_rounded,
    QualityIssueType.noVariants => Icons.layers_clear_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final typeColor = issue.issueColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? typeColor.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? typeColor : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: multiSelectMode ? () => onSelect(!isSelected) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (multiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? typeColor : Colors.transparent,
                      border: Border.all(color: isSelected ? typeColor : AppColors.borderDark, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                )
              else
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_typeIcon, size: 22, color: typeColor),
                ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(issue.issueLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: typeColor)),
                    ),
                    const SizedBox(height: 6),
                    Text(issue.productName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (issue.variantName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('صنف: ${issue.variantName}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                      child: Text(issue.category, style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              if (!multiSelectMode)
                Column(
                  children: [
                    FilledButton.icon(
                      onPressed: onFix,
                      icon: const Icon(Icons.build_rounded, size: 14),
                      label: const Text('إصلاح', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: typeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                        child: Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (v) {
                        if (v == 'delete_product') onDeleteProduct();
                        if (v == 'delete_variant') onDeleteVariant?.call();
                        if (v == 'delete_category') onDeleteCategory();
                      },
                      itemBuilder: (_) => [
                        if (issue.variant != null)
                          const PopupMenuItem(value: 'delete_variant', child: _PopItem(Icons.layers_clear_rounded, 'حذف هذا الصنف', AppColors.error)),
                        const PopupMenuItem(value: 'delete_product', child: _PopItem(Icons.delete_rounded, 'حذف المنتج كاملاً', AppColors.error)),
                        const PopupMenuDivider(),
                        PopupMenuItem(value: 'delete_category', child: _PopItem(Icons.folder_delete_rounded, 'حذف التصنيف "${issue.category}"', Color(0xFF7C3AED))),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PopItem(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    ]);
  }
}



// ─── Upgraded Fix Bottom Sheet ───────────────────────────────────────────────

class _FixBottomSheet extends ConsumerStatefulWidget {
  final ProductIssue issue;
  final ImagePicker picker;
  final VoidCallback onSaved;

  const _FixBottomSheet({required this.issue, required this.picker, required this.onSaved});

  @override
  ConsumerState<_FixBottomSheet> createState() => _FixBottomSheetState();
}

class _FixBottomSheetState extends ConsumerState<_FixBottomSheet> {
  final _inputCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _netPriceCtrl = TextEditingController();
  final _techPriceCtrl = TextEditingController();
  bool _isSaving = false;
  bool _applyPriceToAllCategory = true;
  bool _applyDimToAllVariants = true;

  @override
  void initState() {
    super.initState();
    if (widget.issue.type == QualityIssueType.missingCode) {
      final cat = widget.issue.category;
      final prefix = cat.contains('خشب') ? 'WD' : (cat.contains('رخام') ? 'MB' : (cat.contains('شيبورد') ? 'CB' : 'PR'));
      _inputCtrl.text = '$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _widthCtrl.dispose();
    _netPriceCtrl.dispose();
    _techPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final typeColor = widget.issue.issueColor;

    return Container(
      decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderDark, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.build_rounded, color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إصلاح: ${widget.issue.issueLabel}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(
                      '${widget.issue.productName}'
                      '${widget.issue.variantName.isNotEmpty ? ' (${widget.issue.variantName})' : ''}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            _buildInput(typeColor),
        ],
      ),
    );
  }

  Widget _buildInput(Color typeColor) {
    switch (widget.issue.type) {
      case QualityIssueType.missingImage:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _pickAndSave,
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('اختر صورة من المعرض', style: TextStyle(fontWeight: FontWeight.w800)),
            style: FilledButton.styleFrom(backgroundColor: typeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        );

      case QualityIssueType.missingCode:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _inputCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'كود المنتج',
                hintText: 'مثال: WD-001',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: typeColor, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            _saveButton(typeColor),
          ],
        );

      case QualityIssueType.missingPrice:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تطبيق على كل أصناف الفئة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('تسعير جميع أصناف قسم ${widget.issue.category} المشابهة فوراً', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _applyPriceToAllCategory,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _applyPriceToAllCategory = v),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _inputCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'سعر البيع قطاعي (ج.م) *',
                suffixText: 'ج.م',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: typeColor, width: 2)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _techPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'سعر الفنيين',
                      suffixText: 'ج.م',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _netPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'سعر التكلفة',
                      suffixText: 'ج.م',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _saveButton(typeColor),
          ],
        );

      case QualityIssueType.missingDimensions:
        final cat = widget.issue.category;
        final isWood = cat.contains('خشب');
        final isMarble = cat.contains('رخام');
        final isMolding = cat.contains('بانو') || cat.contains('كرانيش');

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مقاسات شائعة مقترحة:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                if (isWood) ...[
                  _presetChip('2.90م × 16سم', () { _inputCtrl.text = '2.9'; _widthCtrl.text = '0.16'; }),
                  _presetChip('2.90م × 17سم', () { _inputCtrl.text = '2.9'; _widthCtrl.text = '0.17'; }),
                  _presetChip('2.90م × 20سم', () { _inputCtrl.text = '2.9'; _widthCtrl.text = '0.20'; }),
                ] else if (isMarble) ...[
                  _presetChip('2.80م × 1.22م', () { _inputCtrl.text = '2.8'; _widthCtrl.text = '1.22'; }),
                  _presetChip('2.44م × 1.22م', () { _inputCtrl.text = '2.44'; _widthCtrl.text = '1.22'; }),
                ] else if (isMolding) ...[
                  _presetChip('عود 2.40م', () { _inputCtrl.text = '2.4'; _widthCtrl.text = '0'; }),
                  _presetChip('عود 2.80م', () { _inputCtrl.text = '2.8'; _widthCtrl.text = '0'; }),
                ] else ...[
                  _presetChip('60 × 60 سم', () { _inputCtrl.text = '0.6'; _widthCtrl.text = '0.6'; }),
                  _presetChip('50 × 50 سم', () { _inputCtrl.text = '0.5'; _widthCtrl.text = '0.5'; }),
                  _presetChip('2.80 × 1.22 م', () { _inputCtrl.text = '2.8'; _widthCtrl.text = '1.22'; }),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'الطول (بالمتر)',
                      hintText: 'مثال: 2.8',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _widthCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'العرض (بالمتر)',
                      hintText: 'مثال: 0.16',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _applyDimToAllVariants,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _applyDimToAllVariants = v ?? true),
                ),
                Expanded(
                  child: Text(
                    'تطبيق هذا المقاس على جميع أصناف منتج "${widget.issue.productName}"',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _saveButton(typeColor),
          ],
        );

      case QualityIssueType.noVariants:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Text(
            'هذا المنتج لا يحتوي على أصناف. يمكنك إضافة أصناف له من شاشة الكتالوج مباشرة.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
        );
    }
  }

  Widget _presetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      padding: EdgeInsets.zero,
      onPressed: onTap,
    );
  }

  Widget _saveButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.check_circle_rounded),
        label: const Text('حفظ واعتماد التعديل ✓', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        style: FilledButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      ),
    );
  }

  Future<void> _pickAndSave() async {
    try {
      final file = await widget.picker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      await _handleSave(imageBytes: bytes);
    } catch (e) {
      if (mounted) AppToast.showError(context, 'فشل اختيار الصورة: $e');
    }
  }

  Future<void> _save() async => _handleSave();

  Future<void> _handleSave({Uint8List? imageBytes}) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final issue = widget.issue;

      switch (issue.type) {
        case QualityIssueType.missingImage:
          if (imageBytes != null) {
            final url = await repo.uploadImage('${DateTime.now().millisecondsSinceEpoch}.jpg', imageBytes);
            if (url != null) await repo.updateProduct(issue.productId, {'image_url': url});
          }
          break;

        case QualityIssueType.missingCode:
          if (_inputCtrl.text.trim().isNotEmpty) {
            await repo.updateProduct(issue.productId, {'code': _inputCtrl.text.trim()});
          }
          break;

        case QualityIssueType.missingPrice:
          final selling = double.tryParse(_inputCtrl.text) ?? 0;
          final tech = double.tryParse(_techPriceCtrl.text) ?? (selling * 0.90);
          final cost = double.tryParse(_netPriceCtrl.text) ?? 0;

          if (selling > 0) {
            if (_applyPriceToAllCategory) {
              final group = resolveCategoryGroup(issue.category);
              await repo.batchUpdateCategoryPricing(
                categoryAliases: group.aliases,
                sellingPrice: selling,
                technicianPrice: tech,
                costPrice: cost,
                minSellingPrice: selling * 0.85,
              );
              final pricingRepo = ref.read(pricingRepositoryProvider);
              await pricingRepo.saveRuleForSpec(
                category: group.title,
                dimensionSpec: issue.variant?.dimensions,
                material: issue.product.material,
                sellingPrice: selling,
                technicianPrice: tech,
                costPrice: cost,
                minSellingPrice: selling * 0.85,
                notes: 'تسعير معتمد لحل مشكلة صنف ${issue.variantName}',
              );
            } else if (issue.variantId != null) {
              await repo.updateVariantPricingOverrides(
                issue.variantId!,
                sellingPriceOverride: selling,
                technicianPriceOverride: tech,
                costPriceOverride: cost,
              );
            }
          }
          break;

        case QualityIssueType.missingDimensions:
          final length = double.tryParse(_inputCtrl.text);
          final width = double.tryParse(_widthCtrl.text);
          if (length != null && length > 0) {
            final dimMap = <String, dynamic>{
              'piece_length': length,
              'piece_width': width ?? 0.0,
              'dimensions': '$lengthم${(width != null && width > 0) ? ' × $widthم' : ''}',
            };

            if (_applyDimToAllVariants) {
              for (final v in issue.product.variants) {
                await repo.updateVariant(v.id, dimMap);
              }
            } else if (issue.variantId != null) {
              await repo.updateVariant(issue.variantId!, dimMap);
            }
          }
          break;

        case QualityIssueType.noVariants:
          break;
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(context, 'تم حفظ الإصلاح وتحديث البيانات بنجاح ✓');
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'خطأ أثناء الحفظ: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
