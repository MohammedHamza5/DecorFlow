import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/constants/unit_types.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/engines/calculation/category_calc_registry.dart';
import 'package:stream_pay/features/calculator/presentation/providers/calculator_provider.dart';
import 'package:stream_pay/engines/pricing/models/price_models.dart';
import 'package:stream_pay/features/calculator/presentation/widgets/dimension_input_field.dart';
import 'package:stream_pay/features/calculator/presentation/widgets/result_card.dart';
import 'package:stream_pay/features/calculator/presentation/widgets/product_picker_sheet.dart';
import 'package:stream_pay/features/calculator/presentation/widgets/accessories_card.dart';
import 'package:stream_pay/features/calculator/presentation/widgets/mix_advisor_card.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// The fast calculator screen — the heart of the app.
///
/// Category-driven: user picks category → dynamic inputs → live results
/// + auto-accessories + smart mix proposals.
/// Now also accepts a pre-linked product from the Catalog.
class FastCalculatorScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? preloadedProduct;
  final Map<String, dynamic>? preloadedVariant;
  const FastCalculatorScreen({super.key, this.preloadedProduct, this.preloadedVariant});

  @override
  ConsumerState<FastCalculatorScreen> createState() => _FastCalculatorScreenState();
}

class _FastCalculatorScreenState extends ConsumerState<FastCalculatorScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-link product if passed from catalog
    if (widget.preloadedProduct != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(calculatorProvider.notifier).linkProduct(
          product: widget.preloadedProduct!,
          variant: widget.preloadedVariant ?? {},
        );
      });
    }
  }

  String? _fmt(double v) {
    if (v <= 0) return null;
    final rounded = double.parse(v.toStringAsFixed(4));
    return rounded == rounded.toInt() ? rounded.toInt().toString() : rounded.toString();
  }

  String? _fmtInt(int v) => v > 0 ? v.toString() : null;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    // Stock warning banner
    final hasStockWarning = state.hasLinkedProduct &&
        state.output.hasResults &&
        _getAvailableStock(ref, state) > 0 &&
        state.output.quantityWithWaste > _getAvailableStock(ref, state);

    return Scaffold(
      appBar: AppBar(
        title: state.hasLinkedProduct
            ? Text(state.productDisplayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
            : const Text('الحاسبة الذكية'),
        actions: [
          if (state.hasLinkedProduct)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              tooltip: 'إلغاء ربط المنتج',
              onPressed: () => notifier.unlinkProduct(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'مسح',
            onPressed: () => notifier.reset(),
          ),
        ],
      ),
      body: ConstrainedBody(
        child: Column(
          children: [
            // Stock warning banner
            if (hasStockWarning)
              _buildStockWarningBanner(state, ref),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category Selector
                    _buildCategorySelector(context, state, notifier),
                  const SizedBox(height: 16),

                  // Product Picker
                  _buildProductPicker(context, state, notifier),
                  const SizedBox(height: 16),

                  // Dynamic Input Fields (based on category)
                  if (state.hasCategory) ...[
                    _buildInputFields(context, state, notifier),
                    const SizedBox(height: 20),

                    // Pricing section
                    _buildPricingSection(context, state, notifier),
                    const SizedBox(height: 20),
                  ],

                  // Results Card
                  if (state.output.hasResults)
                    ResultCard(output: state.output, priceOutput: state.priceOutput),

                  // Accessories Card
                  if (state.output.accessories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AccessoriesCard(
                      accessories: state.output.accessories,
                      onToggle: notifier.toggleAccessory,
                    ),
                  ],

                  // Mix Advisor Card
                  if (state.mixProposals.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    MixAdvisorCard(proposals: state.mixProposals),
                  ],

                  // Validation Errors
                  if (state.validationErrors.isNotEmpty)
                    _buildValidationErrors(context, state.validationErrors),

                  const SizedBox(height: 20),

                  // Action Buttons
                  if (state.output.hasResults) _buildActions(context, state),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ─── Stock Warning Banner ────────────────────────────────────

  double _getAvailableStock(WidgetRef ref, CalculatorState state) {
    final variantId = state.selectedVariantId;
    if (variantId == null) return 0;
    final hub = ref.read(catalogHubProvider);
    for (final p in hub.allProducts) {
      for (final v in p.variants) {
        if (v.id == variantId) return v.availableQty;
      }
    }
    return 0;
  }

  Widget _buildStockWarningBanner(CalculatorState state, WidgetRef ref) {
    final available = _getAvailableStock(ref, state);
    final needed = state.output.quantityWithWaste;
    final shortage = (needed - available).ceil();
    return Container(
      color: AppColors.warning.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'المخزون المتاح: ${available.toStringAsFixed(0)} — المطلوب: ${needed.toStringAsFixed(0)} — نقص: $shortage',
              style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Selector ─────────────────────────────────────

  Widget _buildCategorySelector(
    BuildContext context,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر نوع المادة',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...CategoryCalcRegistry.calculableCategories.map((config) {
              final isSelected = state.categoryConfig?.category == config.category;
              return ChoiceChip(
                selected: isSelected,
                label: Text(config.label),
                avatar: Icon(
                  IconData(config.iconCodePoint, fontFamily: 'MaterialIcons'),
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                onSelected: (_) => notifier.setCategory(config),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              );
            }),
            ActionChip(
              label: const Text('إضافة مادة'),
              avatar: const Icon(Icons.add, size: 18, color: AppColors.primary),
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.border, style: BorderStyle.solid),
              labelStyle: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              onPressed: () => _showAddCategoryDialog(context, notifier),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            ),
          ],
        ),
        if (state.categoryConfig != null && state.categoryConfig!.hint.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.categoryConfig!.hint,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Dynamic Input Fields ──────────────────────────────────

  Widget _buildInputFields(
    BuildContext context,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final config = state.categoryConfig!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: ValueKey('inputs_${state.resetCount}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المقاسات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._buildFieldsForConfig(config, state, notifier),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFieldsForConfig(
    CategoryCalcConfig config,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final widgets = <Widget>[];
    String? fmt(double v) => _fmt(v);
    String? fmtInt(int v) => _fmtInt(v);

    // Orientation toggle (if supported)
    if (config.supportsOrientation &&
        config.fields.contains(CalcField.orientation)) {
      widgets.add(_buildOrientationToggle(state, notifier));
      widgets.add(const SizedBox(height: 12));
    }

    // Wall length + height row
    if (config.fields.contains(CalcField.wallLength) &&
        config.fields.contains(CalcField.wallHeight)) {
      widgets.add(Row(
        children: [
          Expanded(
            child: DimensionInputField(
              label: 'العرض (عرض الحائط)',
              suffix: 'سم',
              initialValue: fmt(state.input.wallLength * 100),
              onChanged: (v) => notifier.setWallLength(v / 100),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DimensionInputField(
              label: 'الطول / الارتفاع',
              suffix: 'سم',
              initialValue: fmt(state.input.wallHeight * 100),
              onChanged: (v) => notifier.setWallHeight(v / 100),
            ),
          ),
        ],
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Perimeter (for linear)
    if (config.fields.contains(CalcField.perimeter) &&
        !config.fields.contains(CalcField.wallLength)) {
      widgets.add(DimensionInputField(
        label: 'المحيط / الطول الإجمالي',
        suffix: 'سم',
        initialValue: fmt(state.input.perimeter * 100),
        onChanged: (v) => notifier.setPerimeter(v / 100),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Piece length + Piece width row (for panel)
    if (config.fields.contains(CalcField.pieceLength) &&
        config.fields.contains(CalcField.pieceWidth)) {
      widgets.add(Row(
        children: [
          Expanded(
            child: DimensionInputField(
              label: 'طول اللوح',
              suffix: 'سم',
              initialValue: fmt(state.input.pieceLength * 100),
              onChanged: (v) => notifier.setPieceLength(v / 100),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DimensionInputField(
              label: 'عرض اللوح',
              suffix: 'سم',
              initialValue: fmt(state.input.pieceWidth * 100),
              onChanged: (v) => notifier.setPieceWidth(v / 100),
            ),
          ),
        ],
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Coverage width + Piece length row (for rod)
    if (config.fields.contains(CalcField.coverageWidth)) {
      widgets.add(Row(
        children: [
          Expanded(
            child: DimensionInputField(
              label: 'عرض العود الكلي',
              suffix: 'سم',
              initialValue: fmt(state.input.pieceWidth > 0 
                  ? state.input.pieceWidth * 100 
                  : state.input.effectiveCoverageWidth * 100),
              onChanged: (v) => notifier.setRodWidth(v),
            ),
          ),
          if (config.fields.contains(CalcField.pieceLength)) ...[
            const SizedBox(width: 12),
            Expanded(
              child: DimensionInputField(
                label: 'طول العود',
                suffix: 'سم',
                initialValue: fmt(state.input.pieceLength * 100),
                onChanged: (v) => notifier.setPieceLength(v / 100),
              ),
            ),
          ],
        ],
      ));
      widgets.add(const SizedBox(height: 12));
    } else if (config.fields.contains(CalcField.pieceLength) &&
        !config.fields.contains(CalcField.coverageWidth) &&
        !config.fields.contains(CalcField.pieceWidth)) {
      // Piece length alone (for linear/cornice)
      widgets.add(Row(
        children: [
          Expanded(
            child: DimensionInputField(
              label: 'طول القطعة',
              suffix: 'سم',
              initialValue: fmt(state.input.pieceLength * 100),
              onChanged: (v) => notifier.setPieceLength(v / 100),
            ),
          ),
          if (config.fields.contains(CalcField.cornerCount)) ...[
            const SizedBox(width: 12),
            Expanded(
              child: DimensionInputField(
                label: 'عدد الزوايا',
                suffix: '',
                isInteger: true,
                initialValue: fmtInt(state.input.cornerCount),
                onChanged: (v) => notifier.setCornerCount(v.toInt()),
              ),
            ),
          ],
        ],
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Coverage area (for panel)
    if (config.fields.contains(CalcField.coverageArea)) {
      widgets.add(DimensionInputField(
        label: 'مساحة تغطية اللوح',
        suffix: 'م²',
        initialValue: fmt(state.input.effectiveCoverageArea),
        onChanged: (v) => notifier.setCoverageArea(v),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Roll dimensions (for wallpaper)
    if (config.fields.contains(CalcField.rollWidth)) {
      widgets.add(Row(
        children: [
          Expanded(
            child: DimensionInputField(
              label: 'عرض الرول',
              suffix: 'سم',
              initialValue: fmt(state.input.rollWidth),
              onChanged: (v) => notifier.setRollWidth(v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DimensionInputField(
              label: 'طول الرول',
              suffix: 'سم',
              initialValue: fmt(state.input.rollLength * 100),
              onChanged: (v) => notifier.setRollLength(v / 100),
            ),
          ),
        ],
      ));
      widgets.add(const SizedBox(height: 12));

      if (config.fields.contains(CalcField.rapportRepeat)) {
        widgets.add(DimensionInputField(
          label: 'تكرار النقشة (رابور)',
          suffix: 'سم',
          initialValue: fmt(state.input.rapportRepeat),
          onChanged: (v) => notifier.setRapportRepeat(v),
        ));
        widgets.add(const SizedBox(height: 12));
      }
    }

    // Coverage per unit (for putty/paint)
    if (config.fields.contains(CalcField.coveragePerUnit)) {
      widgets.add(DimensionInputField(
        label: 'تغطية العبوة',
        suffix: 'م²',
        initialValue: fmt(state.input.coveragePerUnit),
        onChanged: (v) => notifier.setCoveragePerUnit(v),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Wall count
    if (config.fields.contains(CalcField.wallCount)) {
      widgets.add(DimensionInputField(
        label: 'عدد الحوائط',
        suffix: '',
        isInteger: true,
        initialValue: state.input.wallCount > 0 ? state.input.wallCount.toString() : '1',
        onChanged: (v) => notifier.setWallCount(v.toInt()),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Frames (Wainscoting)
    if (config.fields.contains(CalcField.frameWidth) &&
        config.fields.contains(CalcField.frameHeight)) {
      widgets.add(Row(
        children: [
          Expanded(
            child: DimensionInputField(
              label: 'عرض البرواز',
              suffix: 'سم',
              initialValue: fmt(state.input.frameWidth * 100),
              onChanged: (v) => notifier.setFrameWidth(v / 100),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DimensionInputField(
              label: 'ارتفاع البرواز',
              suffix: 'سم',
              initialValue: fmt(state.input.frameHeight * 100),
              onChanged: (v) => notifier.setFrameHeight(v / 100),
            ),
          ),
        ],
      ));
      widgets.add(const SizedBox(height: 12));
      
      if (config.fields.contains(CalcField.frameCount)) {
        widgets.add(DimensionInputField(
          label: 'عدد البراويز',
          suffix: '',
          isInteger: true,
          initialValue: fmtInt(state.input.frameCount),
          onChanged: (v) => notifier.setFrameCount(v.toInt()),
        ));
        widgets.add(const SizedBox(height: 12));
      }
      
      if (config.fields.contains(CalcField.pieceLength)) {
        widgets.add(DimensionInputField(
          label: 'طول العود',
          suffix: 'سم',
          initialValue: fmt(state.input.pieceLength * 100),
          onChanged: (v) => notifier.setPieceLength(v / 100),
        ));
        widgets.add(const SizedBox(height: 12));
      }
    }

    // Quantity (for Pieces)
    if (config.fields.contains(CalcField.quantity)) {
      widgets.add(DimensionInputField(
        label: 'الكمية المطلوبة',
        suffix: 'قطعة',
        isInteger: true,
        initialValue: state.input.quantity > 0 ? state.input.quantity.toString() : '1',
        onChanged: (v) => notifier.setQuantity(v > 0 ? v.toInt() : 1),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Corner count (standalone, not in row)
    if (config.fields.contains(CalcField.cornerCount) &&
        !config.fields.contains(CalcField.pieceLength)) {
      widgets.add(DimensionInputField(
        label: 'عدد الزوايا',
        suffix: '',
        isInteger: true,
        initialValue: fmtInt(state.input.cornerCount),
        onChanged: (v) => notifier.setCornerCount(v.toInt()),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Pieces per box (Carton)
    if (config.fields.contains(CalcField.piecesPerBox)) {
      widgets.add(DimensionInputField(
        label: 'عدد القطع بالكرتونة',
        suffix: 'قطعة',
        isInteger: true,
        initialValue: state.input.piecesPerBox > 1 ? state.input.piecesPerBox.toString() : '1',
        onChanged: (v) => notifier.setPiecesPerBox(v > 0 ? v.toInt() : 1),
      ));
      widgets.add(const SizedBox(height: 12));
    }

    // Waste slider
    if (config.fields.contains(CalcField.waste)) {
      widgets.add(_buildWasteSlider(state, notifier));
    }

    if (state.mode == CalcMode.rod) {
      widgets.add(const SizedBox(height: 16));
      widgets.add(_buildSmartLayoutCard(state, notifier));
    }

    return widgets;
  }

  Widget _buildOrientationToggle(
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    return Row(
      children: [
        Text('اتجاه التركيب:', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: SegmentedButton<InstallationOrientation>(
            segments: const [
              ButtonSegment(
                value: InstallationOrientation.vertical,
                label: Text('رأسي'),
                icon: Icon(Icons.swap_vert, size: 18),
              ),
              ButtonSegment(
                value: InstallationOrientation.horizontal,
                label: Text('أفقي'),
                icon: Icon(Icons.swap_horiz, size: 18),
              ),
            ],
            selected: {state.input.orientation},
            onSelectionChanged: (set) => notifier.setOrientation(set.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
      ],
    );
  }

  Widget _buildWasteSlider(CalculatorState state, CalculatorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('نسبة الهالك:', style: TextStyle(fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.calcWaste.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(state.input.wastePercent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.calcWaste,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: state.input.wastePercent,
          min: 0,
          max: 0.30,
          divisions: 30,
          activeColor: AppColors.calcWaste,
          onChanged: (v) => notifier.setWastePercent(v),
        ),
      ],
    );
  }

  Widget _buildSmartLayoutCard(CalculatorState state, CalculatorNotifier notifier) {
    final useSmart = state.input.useSmartLayout;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: useSmart 
              ? AppColors.primary.withValues(alpha: 0.3) 
              : AppColors.border,
          width: useSmart ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Switch
          SwitchListTile(
            title: Row(
              children: [
                const Icon(Icons.architecture_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'مخطط الجدار الذكي',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: useSmart 
                        ? AppColors.primary.withValues(alpha: 0.15) 
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    useSmart ? 'مفعل' : 'غير مفعل',
                    style: TextStyle(
                      color: useSmart ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: const Text(
              'لحساب التقطيع الموفر وخصم الشاشات والكمرات الخرسانية',
              style: TextStyle(fontSize: 11),
            ),
            value: useSmart,
            activeColor: AppColors.primary,
            onChanged: (val) => notifier.setUseSmartLayout(val),
          ),
          
          if (useSmart) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Concrete Beam Section
                  const Text(
                    'الكمرة الخرسانية (في أعلى الجدار)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DimensionInputField(
                          label: 'ارتفاع الكمرة',
                          suffix: 'سم',
                          initialValue: state.input.smartBeamHeight > 0 
                              ? _fmt(state.input.smartBeamHeight * 100) 
                              : null,
                          onChanged: (v) => notifier.setSmartBeamHeight(v / 100),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              const Text(
                                'تغطية بالخشب؟',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.input.smartCoverBeam ? '(مفعل)' : '(معطل)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: state.input.smartCoverBeam ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          value: state.input.smartCoverBeam,
                          activeColor: AppColors.primary,
                          onChanged: (val) => notifier.setSmartCoverBeam(val),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // 2. TV Screen Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'شاشة التلفزيون (فتحة خصم)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: state.input.smartHasTv
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.textSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state.input.smartHasTv ? 'مفعل' : 'غير مفعل',
                              style: TextStyle(
                                color: state.input.smartHasTv ? AppColors.primary : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: state.input.smartHasTv,
                        activeColor: AppColors.primary,
                        onChanged: (val) => notifier.setSmartHasTv(val),
                      ),
                    ],
                  ),
                  
                  if (state.input.smartHasTv) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DimensionInputField(
                            label: 'عرض الشاشة',
                            suffix: 'سم',
                            initialValue: state.input.smartTvWidth > 0 
                                ? _fmt(state.input.smartTvWidth * 100) 
                                : '120',
                            onChanged: (v) => notifier.setSmartTvWidth(v / 100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DimensionInputField(
                            label: 'ارتفاع الشاشة',
                            suffix: 'سم',
                            initialValue: state.input.smartTvHeight > 0 
                                ? _fmt(state.input.smartTvHeight * 100) 
                                : '80',
                            onChanged: (v) => notifier.setSmartTvHeight(v / 100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DimensionInputField(
                            label: 'البعد من اليسار (0 للوسط)',
                            suffix: 'سم',
                            initialValue: state.input.smartTvPosX != 0 
                                ? _fmt(state.input.smartTvPosX * 100) 
                                : '0',
                            onChanged: (v) => notifier.setSmartTvPosX(v / 100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DimensionInputField(
                            label: 'الارتفاع عن الأرض (0 للوسط)',
                            suffix: 'سم',
                            initialValue: state.input.smartTvPosY != 0 
                                ? _fmt(state.input.smartTvPosY * 100) 
                                : '0',
                            onChanged: (v) => notifier.setSmartTvPosY(v / 100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('تغطية أسفل الشاشة', style: TextStyle(fontSize: 11)),
                            value: state.input.smartCoverBelowTv,
                            activeColor: AppColors.primary,
                            onChanged: (val) => notifier.setSmartCoverBelowTv(val ?? true),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('تغطية أعلى الشاشة', style: TextStyle(fontSize: 11)),
                            value: state.input.smartCoverAboveTv,
                            activeColor: AppColors.primary,
                            onChanged: (val) => notifier.setSmartCoverAboveTv(val ?? true),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Product Picker ────────────────────────────────────────

  Widget _buildProductPicker(
    BuildContext context,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    if (state.hasLinkedProduct) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.productDisplayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تم تحميل الأبعاد والسعر تلقائياً ✓',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18,
                  color: AppColors.textTertiary),
              onPressed: () => notifier.unlinkProduct(),
              tooltip: 'إلغاء الربط',
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        final result = await showProductPicker(context, categoryFilter: state.categoryName);
        if (result != null) {
          notifier.linkProduct(
            product: result['product'],
            variant: result['variant'],
          );
        }
      },
      icon: const Icon(Icons.inventory_2_outlined, size: 20),
      label: Text(state.hasCategory ? 'تحديد ${state.categoryName} من الكتالوج' : 'اختيار منتج من الكتالوج'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ─── Pricing ───────────────────────────────────────────────

  Widget _buildPricingSection(
    BuildContext context,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final currentDiscounts = state.discounts;
    final activePercent = currentDiscounts.isNotEmpty && currentDiscounts.first.isPercentage
        ? (currentDiscounts.first.value * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: ValueKey('pricing_${state.resetCount}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التسعير والخصومات', style: Theme.of(context).textTheme.titleMedium),
                if (state.priceOutput.finalTotal > 0)
                  Text(
                    'الإجمالي: ${state.priceOutput.finalTotal.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DimensionInputField(
              label: 'سعر الوحدة (ليستة)',
              suffix: 'ج.م',
              step: 50.0,
              showStepButtons: true,
              initialValue: state.listPrice > 0
                  ? (state.listPrice == state.listPrice.toInt()
                      ? state.listPrice.toInt().toString()
                      : state.listPrice.toString())
                  : null,
              onChanged: (v) => notifier.setListPrice(v),
            ),
            const SizedBox(height: 14),
            const Text(
              'نسب الخصم السريعة:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [0, 5, 10, 15, 20, 25, 30].map((pct) {
                final isSelected = activePercent == pct && (pct > 0 ? currentDiscounts.isNotEmpty : currentDiscounts.isEmpty);
                return ChoiceChip(
                  label: Text(pct == 0 ? 'بدون خصم' : '$pct%'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    AppHaptics.light();
                    // Clear previous discounts
                    for (int i = state.discounts.length - 1; i >= 0; i--) {
                      notifier.removeDiscount(i);
                    }
                    if (pct > 0) {
                      notifier.addDiscount(
                        Discount(name: 'خصم $pct%', value: pct / 100),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddDiscountDialog(context, notifier),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('خصم مخصص'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            if (state.discounts.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...state.discounts.asMap().entries.map(
                (entry) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.value.isPercentage
                            ? '${(entry.value.value * 100).toStringAsFixed(0)}%'
                            : '${entry.value.value} ج.م',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.error,
                        ),
                        onPressed: () {
                          AppHaptics.light();
                          notifier.removeDiscount(entry.key);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Validation Errors ─────────────────────────────────────

  Widget _buildValidationErrors(BuildContext context, List<String> errors) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: errors
              .map(
                (e) => Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────

  String _generateCalculationSummaryText(CalculatorState state) {
    final buffer = StringBuffer();
    buffer.writeln('📋 *تفاصيل المقايسة والحساب:*');
    buffer.writeln('• الصنف: ${state.productDisplayName} (${state.categoryName})');
    if (state.input.wallLength > 0 && state.input.wallHeight > 0) {
      buffer.writeln('• المقاسات: ${(state.input.wallLength * 100).toStringAsFixed(0)} سم × ${(state.input.wallHeight * 100).toStringAsFixed(0)} سم');
    }
    if (state.output.baseQuantity > 0) {
      buffer.writeln('• الكمية المطلوبة الصافية: ${state.output.baseQuantity.toStringAsFixed(1)} ${state.output.unitLabel}');
    }
    if (state.output.unitsNeeded > 0) {
      buffer.writeln('• إجمالي الوحدات/الألواح المطلوبة: ${state.output.unitsNeeded} وحدة');
    } else if (state.output.quantityWithWaste > 0) {
      buffer.writeln('• إجمالي الكمية مع الهالك: ${state.output.quantityWithWaste.toStringAsFixed(1)}');
    }
    if (state.priceOutput.finalTotal > 0) {
      buffer.writeln('• السعر الصافي للوحدة: ${state.priceOutput.netUnitPrice.toStringAsFixed(0)} ج.م');
      buffer.writeln('• *الإجمالي الكلي: ${state.priceOutput.finalTotal.toStringAsFixed(0)} ج.م*');
    }
    buffer.writeln('\n✨ تم الحساب عبر نظام السويدي للديكور');
    return buffer.toString();
  }

  Widget _buildActions(BuildContext context, CalculatorState state) {
    final hasLinkedProduct = state.hasLinkedProduct && state.selectedVariantId != null;
    return Column(
      children: [
        // Top Quick Utility Row (Copy / Share WhatsApp)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  AppHaptics.light();
                  final text = _generateCalculationSummaryText(state);
                  Clipboard.setData(ClipboardData(text: text));
                  AppToast.showSuccess(context, 'تم نسخ تفاصيل المقايسة بنجاح ✓');
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('نسخ الملخص'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  AppHaptics.light();
                  final text = _generateCalculationSummaryText(state);
                  AppContactActions.launchWhatsApp(
                    context: context,
                    phone: '',
                    text: text,
                  );
                },
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('مشاركة واتساب'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        // Instant POS Sale Invoice
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _createInstantSaleInvoice(context),
            icon: const Icon(Icons.bolt_rounded, size: 22, color: Colors.amber),
            label: const Text(
              'تحويل إلى فاتورة بيع فورية ⚡',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Add to quote
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _addToQuote(context),
            icon: const Icon(Icons.add_shopping_cart, size: 20),
            label: const Text('أضف لعرض السعر', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Save calculation
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _saveCalc(context),
            icon: const Icon(Icons.save_outlined, size: 20),
            label: const Text('حفظ الحساب في السجل'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),

        // Direct stock deduction (only if product is linked)
        if (hasLinkedProduct) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _directStockDeduct(context, state),
              icon: const Icon(Icons.remove_shopping_cart_rounded, size: 20, color: AppColors.warning),
              label: const Text('خصم مباشر من المخزون', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _saveCalc(BuildContext context) async {
    AppHaptics.light();
    final ref = ProviderScope.containerOf(context);
    final notifier = ref.read(calculatorProvider.notifier);
    final id = await notifier.saveCalculation();
    if (context.mounted) {
      if (id != null) {
        AppToast.showSuccess(context, 'تم حفظ الحساب في السجل بنجاح ✓');
      } else {
        AppToast.showError(context, 'فشل حفظ الحساب');
      }
    }
  }

  void _directStockDeduct(BuildContext context, CalculatorState state) async {
    final variantId = state.selectedVariantId;
    if (variantId == null) return;

    final double quantity = state.output.unitsNeeded > 0
        ? state.output.unitsNeeded.toDouble()
        : state.output.quantityWithWaste;

    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'خصم مباشر من المخزون',
      message: 'سيتم خصم ${quantity.toStringAsFixed(1)} وحدة من المخزون مباشرة بدون فاتورة.\n\nهل تريد المتابعة؟',
      confirmLabel: 'خصم الآن',
      isDanger: true,
      icon: Icons.remove_shopping_cart_rounded,
    );

    if (!confirmed || !context.mounted) return;

    try {
      final invRepo = ref.read(inventoryRepositoryProvider);
      final invItem = await invRepo.getInventoryItemByVariantId(variantId);

      if (invItem == null) {
        if (context.mounted) {
          AppToast.showError(context, 'هذا الصنف غير موجود في المخزون');
        }
        return;
      }

      await invRepo.recordMovement(
        inventoryItemId: invItem['id'],
        type: 'out',
        quantity: quantity,
        referenceType: 'direct_deduction',
        notes: 'خصم مباشر من الحاسبة — ${state.productDisplayName}',
      );

      ref.invalidate(inventoryProvider);
      ref.read(catalogHubProvider.notifier).invalidate();

      if (context.mounted) {
        AppToast.showSuccess(context, 'تم خصم ${quantity.toStringAsFixed(1)} من المخزون بنجاح ✓');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, 'خطأ: $e');
      }
    }
  }

  void _addToQuote(BuildContext context) {
    AppHaptics.light();
    final ref = ProviderScope.containerOf(context);
    final state = ref.read(calculatorProvider);
    
    if (!state.output.hasResults) {
      if (context.mounted) {
        AppToast.showInfo(context, 'الرجاء حساب الكمية أولاً');
      }
      return;
    }

    final String description = '${state.categoryName} - ${state.productDisplayName}';
    final double quantity = state.output.unitsNeeded > 0 ? state.output.unitsNeeded.toDouble() : state.output.quantityWithWaste;
    final double totalCost = state.priceOutput.finalTotal;
    final double unitPrice = state.priceOutput.netUnitPrice;

    final initialItem = {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalCost,
      if (state.selectedVariantId != null)
        'product_variant_id': state.selectedVariantId,
    };

    GoRouter.of(context).push('/quote-builder', extra: {'initialItem': initialItem});
  }

  void _createInstantSaleInvoice(BuildContext context) {
    AppHaptics.medium();
    final ref = ProviderScope.containerOf(context);
    final state = ref.read(calculatorProvider);

    if (!state.output.hasResults) {
      if (context.mounted) {
        AppToast.showInfo(context, 'الرجاء حساب الكمية أولاً');
      }
      return;
    }

    final String displayName = state.productDisplayName.isNotEmpty
        ? state.productDisplayName
        : state.categoryName;
    final double quantity = state.output.unitsNeeded > 0
        ? state.output.unitsNeeded.toDouble()
        : state.output.quantityWithWaste;
    final double unitPrice = state.priceOutput.netUnitPrice;
    final double totalCost = state.priceOutput.finalTotal;

    final String selectedVarName = state.selectedVariant?['label'] as String? ??
        state.selectedVariant?['variant_name'] as String? ??
        '';

    final List<Map<String, dynamic>> items = [
      {
        'product_name': displayName,
        'variant_name': selectedVarName,
        'product_variant_id': state.selectedVariantId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalCost,
        'unit': state.categoryConfig?.unitLabel ?? 'قطعة',
      }
    ];

    // Append enabled accessories
    for (final acc in state.output.accessories) {
      if (acc.isEnabled && acc.quantity > 0) {
        items.add({
          'product_name': acc.name,
          'variant_name': '',
          'quantity': acc.quantity,
          'unit_price': acc.unitPrice,
          'total_price': acc.lineTotal,
          'unit': acc.unitLabel,
        });
      }
    }

    GoRouter.of(context).push(
      '/smart-invoice',
      extra: {
        'customerName': 'عميل نقدي (من الحاسبة)',
        'initialItems': items,
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, CalculatorNotifier notifier) {
    final nameController = TextEditingController();
    CalcMode selectedMode = CalcMode.panel;

    AppBottomSheet.show(
      context: context,
      title: 'إضافة مادة وحاسبة جديدة',
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'اسم المادة (مثلاً: جبس بورد، ورق حائط)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CalcMode>(
                  value: selectedMode,
                  decoration: InputDecoration(
                    labelText: 'طريقة الحساب الهندسية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  items: const [
                    DropdownMenuItem(value: CalcMode.panel, child: Text('ألواح (مثل بديل الرخام/الشيبورد)')),
                    DropdownMenuItem(value: CalcMode.rod, child: Text('عيدان (مثل بديل الخشب/البانوهات)')),
                    DropdownMenuItem(value: CalcMode.linearMeter, child: Text('متر طولي (مثل الكرانيش/الوزرات)')),
                    DropdownMenuItem(value: CalcMode.coverage, child: Text('عبوات / تغطية (مثل المعجون)')),
                    DropdownMenuItem(value: CalcMode.squareMeter, child: Text('مساحة (بالمتر المربع)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedMode = val);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    AppHaptics.medium();
                    final newConfig = CategoryCalcRegistry.addCustomCategory(
                      nameController.text.trim(),
                      selectedMode,
                    );
                    notifier.setCategory(newConfig);
                    Navigator.pop(ctx);
                    AppToast.showSuccess(context, 'تمت إضافة مادة ${nameController.text.trim()} بنجاح');
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('إضافة المادة وتفعيل الحاسبة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDiscountDialog(
    BuildContext context,
    CalculatorNotifier notifier,
  ) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    AppBottomSheet.show(
      context: context,
      title: 'إضافة خصم مخصص',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'اسم الخصم (اختياري)',
              hintText: 'مثلاً: خصم مقاول، عرض موسمي',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: valueController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'النسبة المئوية (%)',
              suffixText: '%',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(valueController.text);
              if (value != null && value > 0) {
                AppHaptics.light();
                notifier.addDiscount(
                  Discount(
                    name: nameController.text.isEmpty
                        ? 'خصم ${value.toStringAsFixed(0)}%'
                        : nameController.text,
                    value: value / 100,
                  ),
                );
                Navigator.pop(ctx);
                AppToast.showSuccess(context, 'تم تطبيق الخصم');
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('تطبيق الخصم'),
          ),
        ],
      ),
    );
  }
}
