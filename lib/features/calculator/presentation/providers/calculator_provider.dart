import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/constants/unit_types.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/engines/calculation/calculation_engine.dart';
import 'package:stream_pay/engines/calculation/category_calc_registry.dart';
import 'package:stream_pay/engines/calculation/accessories_engine.dart';
import 'package:stream_pay/engines/calculation/models/calc_input.dart';
import 'package:stream_pay/engines/calculation/models/calc_output.dart';
import 'package:stream_pay/engines/pricing/pricing_engine.dart';
import 'package:stream_pay/engines/pricing/models/price_models.dart';
import 'package:stream_pay/engines/advisor/mix_advisor_engine.dart';
import 'package:stream_pay/engines/advisor/models/mix_models.dart';

/// State for the fast calculator screen.
class CalculatorState {
  final CalcMode mode;
  final CalcInput input;
  final CalcOutput output;
  final double listPrice;
  final List<Discount> discounts;
  final PriceOutput priceOutput;
  final List<String> validationErrors;

  /// Current category config (auto-determines mode + fields).
  final CategoryCalcConfig? categoryConfig;

  /// Linked product info (from catalog).
  final Map<String, dynamic>? selectedProduct;
  final Map<String, dynamic>? selectedVariant;
  final String? selectedProductId;
  final String? selectedVariantId;

  /// Assemblies data for accessories calculation.
  final List<Map<String, dynamic>> assemblies;

  /// Mix proposals from the advisor.
  final List<MixProposal> mixProposals;

  /// Counter used to force UI inputs to clear when category changes or reset is pressed.
  final int resetCount;

  const CalculatorState({
    this.mode = CalcMode.rod,
    this.input = const CalcInput(mode: CalcMode.rod),
    this.output = CalcOutput.empty,
    this.listPrice = 0,
    this.discounts = const [],
    this.priceOutput = PriceOutput.empty,
    this.validationErrors = const [],
    this.categoryConfig,
    this.selectedProduct,
    this.selectedVariant,
    this.selectedProductId,
    this.selectedVariantId,
    this.assemblies = const [],
    this.mixProposals = const [],
    this.resetCount = 0,
  });

  /// Whether a product is linked to this calculation.
  bool get hasLinkedProduct => selectedProduct != null;

  /// Whether a category is selected.
  bool get hasCategory => categoryConfig != null;

  /// Current category name.
  String get categoryName => categoryConfig?.category ?? '';

  /// Linked product display name.
  String get productDisplayName {
    if (selectedProduct == null) return '';
    final name = selectedProduct!['name'] ?? '';
    final variant = selectedVariant?['label'] ??
        selectedVariant?['variant_name'] ?? '';
    return variant.toString().isNotEmpty ? '$name — $variant' : name.toString();
  }

  CalculatorState copyWith({
    CalcMode? mode,
    CalcInput? input,
    CalcOutput? output,
    double? listPrice,
    List<Discount>? discounts,
    PriceOutput? priceOutput,
    List<String>? validationErrors,
    CategoryCalcConfig? categoryConfig,
    Map<String, dynamic>? selectedProduct,
    Map<String, dynamic>? selectedVariant,
    String? selectedProductId,
    String? selectedVariantId,
    List<Map<String, dynamic>>? assemblies,
    List<MixProposal>? mixProposals,
    int? resetCount,
    bool clearProduct = false,
    bool clearCategory = false,
  }) {
    return CalculatorState(
      mode: mode ?? this.mode,
      input: input ?? this.input,
      output: output ?? this.output,
      listPrice: listPrice ?? this.listPrice,
      discounts: discounts ?? this.discounts,
      priceOutput: priceOutput ?? this.priceOutput,
      validationErrors: validationErrors ?? this.validationErrors,
      categoryConfig: clearCategory
          ? null
          : (categoryConfig ?? this.categoryConfig),
      selectedProduct: clearProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),
      selectedVariant: clearProduct
          ? null
          : (selectedVariant ?? this.selectedVariant),
      selectedProductId: clearProduct
          ? null
          : (selectedProductId ?? this.selectedProductId),
      selectedVariantId: clearProduct
          ? null
          : (selectedVariantId ?? this.selectedVariantId),
      assemblies: assemblies ?? this.assemblies,
      mixProposals: mixProposals ?? this.mixProposals,
      resetCount: resetCount ?? this.resetCount,
    );
  }
}

/// Provider for the fast calculator — handles live recalculation.
class CalculatorNotifier extends Notifier<CalculatorState> {
  late final CalculationEngine _calcEngine;
  late final PricingEngine _pricingEngine;
  late final AccessoriesEngine _accessoriesEngine;
  late final MixAdvisorEngine _mixAdvisor;

  @override
  CalculatorState build() {
    _calcEngine = CalculationEngine();
    _pricingEngine = PricingEngine();
    _accessoriesEngine = AccessoriesEngine();
    _mixAdvisor = MixAdvisorEngine();
    return const CalculatorState();
  }

  // ─── Category Selection ────────────────────────────────────

  /// Set category — this auto-determines mode, fields, and waste.
  void setCategory(CategoryCalcConfig config) {
    final newInput = CalcInput(
      mode: config.defaultMode,
      wastePercent: config.defaultWaste,
      category: config.category,
    );
    state = state.copyWith(
      mode: config.defaultMode,
      categoryConfig: config,
      input: newInput,
      output: CalcOutput.empty,
      priceOutput: PriceOutput.empty,
      validationErrors: [],
      mixProposals: [],
      clearProduct: true,
      assemblies: const [],
      resetCount: state.resetCount + 1,
    );
  }

  /// Legacy: set mode directly (still supported for backward compat).
  void setMode(CalcMode mode) {
    final config = CategoryCalcRegistry.categories.firstWhere(
      (c) => c.defaultMode == mode,
      orElse: () => CategoryCalcRegistry.categories.last,
    );
    setCategory(config);
  }

  // ─── Input Setters ─────────────────────────────────────────

  void setWallLength(double value) =>
      _updateInput(state.input.copyWith(wallLength: value));

  void setWallHeight(double value) =>
      _updateInput(state.input.copyWith(wallHeight: value));

  void setWallCount(int value) =>
      _updateInput(state.input.copyWith(wallCount: value));

  void setCoverageWidth(double value) =>
      _updateInput(state.input.copyWith(effectiveCoverageWidth: value));

  /// Smart setter for Rod Width (e.g. 17cm WPC). 
  void setRodWidth(double value) {
    if (value <= 0) {
      _updateInput(state.input.copyWith(effectiveCoverageWidth: 0, pieceWidth: 0));
      return;
    }
    // The UI explicitly uses 'سم' (cm). We should always convert it to meters.
    double widthM = value / 100.0;

    _updateInput(state.input.copyWith(
      pieceWidth: widthM,
      effectiveCoverageWidth: widthM,
    ));
  }

  void setPieceLength(double value) {
    var newInput = state.input.copyWith(pieceLength: value);
    if (state.mode == CalcMode.panel && value > 0 && state.input.pieceWidth > 0) {
      newInput = newInput.copyWith(effectiveCoverageArea: value * state.input.pieceWidth);
    }
    _updateInput(newInput);
  }

  void setPieceWidth(double value) {
    var newInput = state.input.copyWith(pieceWidth: value);
    if (state.mode == CalcMode.panel && value > 0 && state.input.pieceLength > 0) {
      newInput = newInput.copyWith(effectiveCoverageArea: value * state.input.pieceLength);
    }
    _updateInput(newInput);
  }

  void setCoverageArea(double value) =>
      _updateInput(state.input.copyWith(effectiveCoverageArea: value));

  void setOrientation(InstallationOrientation orientation) =>
      _updateInput(state.input.copyWith(orientation: orientation));

  void setWastePercent(double value) =>
      _updateInput(state.input.copyWith(wastePercent: value));

  void setPerimeter(double value) =>
      _updateInput(state.input.copyWith(perimeter: value));

  void setCornerCount(int value) =>
      _updateInput(state.input.copyWith(cornerCount: value));

  void setDirectArea(double value) =>
      _updateInput(state.input.copyWith(directArea: value));

  void setPiecesPerBox(int value) =>
      _updateInput(state.input.copyWith(piecesPerBox: value));

  void setDeductOpenings(bool value) =>
      _updateInput(state.input.copyWith(deductOpenings: value));

  void setUseSmartLayout(bool value) =>
      _updateInput(state.input.copyWith(useSmartLayout: value));

  void setSmartBeamHeight(double value) =>
      _updateInput(state.input.copyWith(smartBeamHeight: value));

  void setSmartCoverBeam(bool value) =>
      _updateInput(state.input.copyWith(smartCoverBeam: value));

  void setSmartHasTv(bool value) =>
      _updateInput(state.input.copyWith(smartHasTv: value));

  void setSmartTvWidth(double value) =>
      _updateInput(state.input.copyWith(smartTvWidth: value));

  void setSmartTvHeight(double value) =>
      _updateInput(state.input.copyWith(smartTvHeight: value));

  void setSmartTvPosX(double value) =>
      _updateInput(state.input.copyWith(smartTvPosX: value));

  void setSmartTvPosY(double value) =>
      _updateInput(state.input.copyWith(smartTvPosY: value));

  void setSmartCoverBelowTv(bool value) =>
      _updateInput(state.input.copyWith(smartCoverBelowTv: value));

  void setSmartCoverAboveTv(bool value) =>
      _updateInput(state.input.copyWith(smartCoverAboveTv: value));

  void setRollWidth(double value) =>
      _updateInput(state.input.copyWith(rollWidth: value));

  void setRollLength(double value) =>
      _updateInput(state.input.copyWith(rollLength: value));

  void setRapportRepeat(double value) =>
      _updateInput(state.input.copyWith(rapportRepeat: value));

  void setCoveragePerUnit(double value) =>
      _updateInput(state.input.copyWith(coveragePerUnit: value));

  void setQuantity(int value) =>
      _updateInput(state.input.copyWith(quantity: value));

  void setFrameWidth(double value) =>
      _updateInput(state.input.copyWith(frameWidth: value));

  void setFrameHeight(double value) =>
      _updateInput(state.input.copyWith(frameHeight: value));

  void setFrameCount(int value) =>
      _updateInput(state.input.copyWith(frameCount: value));

  void addOpening(OpeningInput opening) {
    final newOpenings = [...state.input.openings, opening];
    _updateInput(state.input.copyWith(openings: newOpenings));
  }

  void removeOpening(int index) {
    final newOpenings = [...state.input.openings]..removeAt(index);
    _updateInput(state.input.copyWith(openings: newOpenings));
  }

  // ─── Pricing ───────────────────────────────────────────────

  void setListPrice(double value) {
    state = state.copyWith(listPrice: value);
    _recalculatePrice();
    _generateMixProposals();
  }

  void addDiscount(Discount discount) {
    state = state.copyWith(discounts: [...state.discounts, discount]);
    _recalculatePrice();
  }

  void removeDiscount(int index) {
    final newDiscounts = [...state.discounts]..removeAt(index);
    state = state.copyWith(discounts: newDiscounts);
    _recalculatePrice();
  }

  // ─── Accessory Toggle ──────────────────────────────────────

  void toggleAccessory(int index, bool enabled) {
    if (!state.output.hasResults) return;
    final accessories = state.output.accessories.toList();
    if (index < 0 || index >= accessories.length) return;
    accessories[index] = accessories[index].copyWith(isEnabled: enabled);
    state = state.copyWith(
      output: state.output.withAccessories(accessories),
    );
    _recalculatePrice();
  }

  // ─── Product Linking ───────────────────────────────────────

  /// Link a product variant from catalog to this calculator.
  /// Auto-fills dimensions, price, category, and assemblies.
  void linkProduct({
    required Map<String, dynamic> product,
    required Map<String, dynamic> variant,
  }) {
    final category = product['category'] as String? ?? '';
    final unitType = product['unit_type'] as String? ?? '';

    // Auto-detect category config
    final config = CategoryCalcRegistry.configForProduct(category, unitType);

    // Extract dimensions from variant
    final pieceLength = _toDouble(variant['piece_length']);
    final pieceWidth = _toDouble(variant['piece_width']);
    final coverageWidth = _toDouble(variant['effective_coverage_width']);
    final coverageArea = _toDouble(variant['effective_coverage_area']);
    final waste = _toDouble(variant['default_waste_percent']);
    final piecesPerBox = variant['pieces_per_box'] as int? ?? 1;

    // Build input with auto-filled dimensions
    CalcInput newInput = CalcInput(
      mode: config.defaultMode,
      wastePercent: waste ?? config.defaultWaste,
      category: category,
    );

    // Fill dimensions based on mode
    switch (config.defaultMode) {
      case CalcMode.rod:
        if (pieceLength != null) newInput = newInput.copyWith(pieceLength: pieceLength);
        if (coverageWidth != null) {
          newInput = newInput.copyWith(effectiveCoverageWidth: coverageWidth);
        } else if (pieceWidth != null) {
          newInput = newInput.copyWith(
            pieceWidth: pieceWidth,
            effectiveCoverageWidth: pieceWidth,
          );
        }
        break;
      case CalcMode.panel:
        if (pieceLength != null) newInput = newInput.copyWith(pieceLength: pieceLength);
        if (pieceWidth != null) newInput = newInput.copyWith(pieceWidth: pieceWidth);
        if (coverageArea != null) {
          newInput = newInput.copyWith(effectiveCoverageArea: coverageArea);
        } else if (pieceLength != null && pieceWidth != null) {
          newInput = newInput.copyWith(
            effectiveCoverageArea: pieceLength * pieceWidth,
          );
        }
        if (piecesPerBox > 1) {
          newInput = newInput.copyWith(piecesPerBox: piecesPerBox);
        }
        break;
      case CalcMode.linearMeter:
        if (pieceLength != null) newInput = newInput.copyWith(pieceLength: pieceLength);
        if (pieceWidth != null) newInput = newInput.copyWith(pieceWidth: pieceWidth);
        break;
      case CalcMode.rolls:
        if (pieceWidth != null) newInput = newInput.copyWith(rollWidth: pieceWidth);
        if (pieceLength != null) newInput = newInput.copyWith(rollLength: pieceLength);
        break;
      case CalcMode.coverage:
        if (coverageArea != null) {
          newInput = newInput.copyWith(coveragePerUnit: coverageArea);
        }
        break;
      default:
        break;
    }

    // Extract assemblies for accessories
    final assemblies = (variant['product_assemblies'] as List?)
        ?.map((a) => Map<String, dynamic>.from(a as Map))
        .toList() ?? [];

    state = state.copyWith(
      mode: config.defaultMode,
      categoryConfig: config,
      selectedProduct: product,
      selectedVariant: variant,
      selectedProductId: product['id'] as String?,
      selectedVariantId: variant['id'] as String?,
      assemblies: assemblies,
      mixProposals: [],
    );

    _updateInput(newInput);

    // Auto-fill price from pricing data
    double? price;
    final pricings = variant['supplier_product_pricings'] as List?;
    if (pricings != null && pricings.isNotEmpty) {
      final preferred = pricings.where((p) => (p as Map)['is_preferred'] == true);
      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
      final netPrice = _toDouble(pref['net_price']);
      final listPrice = _toDouble(pref['list_price']);
      price = netPrice ?? listPrice;
    } else {
      final netPrice = _toDouble(variant['net_price']);
      final listPrice = _toDouble(variant['list_price']);
      price = netPrice ?? listPrice;
    }
    
    if (price != null && price > 0) {
      setListPrice(price);
    }
  }

  /// Unlink product.
  void unlinkProduct() {
    state = state.copyWith(
      clearProduct: true,
      assemblies: const [],
      mixProposals: [],
    );
  }

  // ─── Save & Quote ──────────────────────────────────────────

  /// Save calculation record to Supabase and return the record ID.
  Future<String?> saveCalculation() async {
    if (!state.output.hasResults) return null;

    try {
      final client = ref.read(supabaseProvider);
      final result = await client
          .from('calculation_records')
          .insert({
            'calculation_mode': state.mode.name,
            'input_payload': state.input.toJson(),
            'output_payload': {
              ...state.output.toJson(),
              'list_price': state.listPrice,
              'discounts': state.discounts
                  .map(
                    (d) => {
                      'name': d.name,
                      'value': d.value,
                      'isPercentage': d.isPercentage,
                    },
                  )
                  .toList(),
              'price_output': {
                'listPrice': state.priceOutput.listPrice,
                'netUnitPrice': state.priceOutput.netUnitPrice,
                'totalBeforeDiscount': state.priceOutput.totalBeforeDiscount,
                'finalTotal': state.priceOutput.finalTotal,
              },
            },
            if (state.selectedVariantId != null)
              'product_variant_id': state.selectedVariantId,
          })
          .select()
          .single();

      return result['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Add current calculation as a quote item.
  Future<bool> addToQuote(String quoteId) async {
    if (!state.output.hasResults) return false;

    try {
      // Save calculation first
      final calcId = await saveCalculation();

      final quoteRepo = ref.read(quoteRepositoryProvider);
      await quoteRepo.addQuoteItem(quoteId, {
        'product_name': state.hasLinkedProduct
            ? state.productDisplayName
            : 'حساب ${state.categoryName.isNotEmpty ? state.categoryName : _modeLabel(state.mode)}',
        'qty': state.output.quantityWithWaste,
        'unit': state.output.unitLabel,
        'unit_price': state.listPrice,
        'discount': state.priceOutput.totalDiscount,
        'final_unit_price': state.priceOutput.netUnitPrice,
        'accessories_total': state.output.totalAccessoriesCost,
        'final_line_total': state.priceOutput.finalTotal,
        'waste_percent': state.output.wastePercent,
        if (state.selectedVariantId != null)
          'product_variant_id': state.selectedVariantId,
        'calculation_id': calcId,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = CalculatorState(
      mode: state.mode,
      categoryConfig: state.categoryConfig,
      input: CalcInput(
        mode: state.mode,
        wastePercent: state.categoryConfig?.defaultWaste ?? 0.10,
        category: state.categoryConfig?.category,
      ),
      resetCount: state.resetCount + 1,
    );
  }

  // ─── Internal ──────────────────────────────────────────────

  void _updateInput(CalcInput newInput) {
    final errors = _calcEngine.validateInput(newInput);
    CalcOutput output;
    if (errors.isEmpty) {
      output = _calcEngine.calculate(newInput);

      // Auto-calculate accessories if assemblies exist
      if (state.assemblies.isNotEmpty && output.hasResults) {
        final accessories = _accessoriesEngine.calculate(
          assemblies: state.assemblies,
          primaryQty: output.quantityWithWaste,
          netArea: output.netArea,
          totalLength: newInput.perimeter > 0
              ? newInput.perimeter
              : newInput.wallLength * newInput.wallCount,
          wallCount: newInput.wallCount,
          cornerCount: newInput.cornerCount,
        );
        output = output.withAccessories(accessories);
      }
    } else {
      output = CalcOutput.empty;
    }
    state = state.copyWith(
      input: newInput,
      output: output,
      validationErrors: errors,
    );
    if (output.hasResults && state.listPrice > 0) {
      _recalculatePrice();
      _generateMixProposals();
    }
  }

  void _recalculatePrice() {
    if (!state.output.hasResults || state.listPrice <= 0) {
      state = state.copyWith(priceOutput: PriceOutput.empty);
      return;
    }

    // Build accessories price list from calculated accessories
    final accessoryPrices = state.output.accessories
        .where((a) => a.isEnabled && a.unitPrice > 0)
        .map((a) => AccessoryPrice(
              name: a.name,
              quantity: a.quantity,
              unitPrice: a.unitPrice,
              unit: a.unitLabel,
            ))
        .toList();

    final priceInput = PriceInput(
      quantity: state.output.quantityWithWaste,
      unitLabel: state.output.unitLabel,
      listPrice: state.listPrice,
      discounts: state.discounts,
      accessories: accessoryPrices,
    );
    final priceOutput = _pricingEngine.calculatePrice(priceInput);
    state = state.copyWith(priceOutput: priceOutput);
  }

  void _generateMixProposals() {
    if (!state.output.hasResults ||
        state.listPrice <= 0 ||
        state.categoryName.isEmpty) {
      state = state.copyWith(mixProposals: []);
      return;
    }

    // Build approximate category prices from catalog data
    // For now, use rule-of-thumb prices. In production, query from DB.
    final categoryAvgPrices = <String, double>{
      'بديل خشب': state.categoryName == 'بديل خشب' ? state.listPrice : state.listPrice * 0.6,
      'بديل رخام': state.categoryName == 'بديل رخام' ? state.listPrice : state.listPrice * 0.4,
      'بانوهات': state.categoryName == 'بانوهات' ? state.listPrice : state.listPrice * 0.5,
      'شيبورد': state.categoryName == 'شيبورد' ? state.listPrice : state.listPrice * 0.35,
      'بديل حجر': state.categoryName == 'بديل حجر' ? state.listPrice : state.listPrice * 0.45,
    };

    // Calculate per-m² price for the current material
    final perSqm = state.output.netArea > 0
        ? state.priceOutput.subtotalAfterDiscount / state.output.netArea
        : state.listPrice;

    final proposals = _mixAdvisor.suggest(
      originalCategory: state.categoryName,
      netArea: state.output.netArea,
      originalUnitPrice: perSqm,
      originalTotalCost: state.priceOutput.subtotalAfterDiscount,
      categoryAvgPrices: categoryAvgPrices,
    );

    state = state.copyWith(mixProposals: proposals);
  }

  String _modeLabel(CalcMode mode) {
    switch (mode) {
      case CalcMode.rod:
        return 'عيدان';
      case CalcMode.panel:
        return 'ألواح';
      case CalcMode.linearMeter:
        return 'متري';
      case CalcMode.squareMeter:
        return 'مساحة';
      case CalcMode.mixed:
        return 'مختلطة';
      case CalcMode.rolls:
        return 'رولات';
      case CalcMode.coverage:
        return 'تغطية';
      case CalcMode.pieces:
        return 'قطع';
      case CalcMode.frames:
        return 'براويز';
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// The main calculator provider.
final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
      CalculatorNotifier.new,
    );
