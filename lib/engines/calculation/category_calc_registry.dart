import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_pay/core/constants/unit_types.dart';

/// Configuration for how a specific product category should be calculated.
///
/// Each decor category (بديل خشب, بديل رخام, كرانيش, etc.) has its own
/// calculation mode, required input fields, default waste, and display settings.
class CategoryCalcConfig {
  /// The product category name (matches DB `products.category`).
  final String category;

  /// The calculation mode to use.
  final CalcMode defaultMode;

  /// Arabic display label for the category.
  final String label;

  /// Icon code point (Material Icons).
  final int iconCodePoint;

  /// Required input fields for this category.
  final List<CalcField> fields;

  /// Default waste percentage.
  final double defaultWaste;

  /// Whether this category supports orientation toggle (vertical/horizontal).
  final bool supportsOrientation;

  /// The unit label for results.
  final String unitLabel;

  /// Short description for the user.
  final String hint;

  /// Whether this category is a non-calculable category (accessories, materials).
  final bool isNonCalculable;

  const CategoryCalcConfig({
    required this.category,
    required this.defaultMode,
    required this.label,
    required this.iconCodePoint,
    required this.fields,
    required this.defaultWaste,
    this.supportsOrientation = false,
    required this.unitLabel,
    this.hint = '',
    this.isNonCalculable = false,
  });
}

/// Input fields that the calculator UI can show.
enum CalcField {
  wallLength('طول الحائط', 'سم'),
  wallHeight('ارتفاع الحائط', 'سم'),
  wallCount('عدد الحوائط', ''),
  coverageWidth('عرض التغطية', 'سم'),
  pieceLength('طول اللوح / العود', 'سم'),
  pieceWidth('عرض اللوح / القطعة', 'سم'),
  coverageArea('مساحة تغطية اللوح', 'م²'),
  perimeter('المحيط / الطول الإجمالي', 'سم'),
  cornerCount('عدد الزوايا', ''),
  orientation('اتجاه التركيب', ''),
  rollWidth('عرض الرول', 'سم'),
  rollLength('طول الرول', 'سم'),
  rapportRepeat('تكرار النقشة (رابور)', 'سم'),
  directArea('المساحة مباشرة', 'م²'),
  coveragePerUnit('تغطية العبوة', 'م²'),
  waste('نسبة الهالك', '%'),
  piecesPerBox('عدد القطع بالكرتونة', ''),
  quantity('الكمية', ''),
  frameWidth('عرض البرواز', 'سم'),
  frameHeight('ارتفاع البرواز', 'سم'),
  frameCount('عدد البراويز', '');

  final String label;
  final String suffix;
  const CalcField(this.label, this.suffix);
}

/// Registry of all supported product categories and their calculation configs.
///
/// Categories are organized in 4 groups matching the real business structure:
/// 1. ديكورات الحوائط والأسقف (كرانيش, بانوهات, بيت نور, صرر)
/// 2. بدائل التشطيبات (بديل خشب, بديل رخام, شيبورد, بديل حجر)
/// 3. الوزرات والإكسسوارات (وزرات, إكسسوارات)
/// 4. الخامات المساعدة (خامات مساعدة)
class CategoryCalcRegistry {
  CategoryCalcRegistry._();

  static List<CategoryCalcConfig> categories = [
    // ═══════════════════════════════════════════════════════════
    // ─── Group 1: ديكورات الحوائط والأسقف ──────────────────────
    // ═══════════════════════════════════════════════════════════

    // ─── كرانيش (فيوتك) ─────────────────────────────────────
    CategoryCalcConfig(
      category: 'كرانيش',
      defaultMode: CalcMode.linearMeter,
      label: 'كرانيش',
      iconCodePoint: 0xe30c, // architecture
      fields: [
        CalcField.perimeter,
        CalcField.pieceLength,
        CalcField.cornerCount,
        CalcField.waste,
      ],
      defaultWaste: 0.12,
      unitLabel: 'عود',
      hint: 'كرانيش فيوتك — حساب بالمتر الطولي',
    ),

    // ─── بانوهات (فيوتك + بي إس + زوايا بانوه) ──────────────
    CategoryCalcConfig(
      category: 'بانوهات',
      defaultMode: CalcMode.frames,
      label: 'بانوهات',
      iconCodePoint: 0xe8e8, // view_column
      fields: [
        CalcField.frameWidth,
        CalcField.frameHeight,
        CalcField.frameCount,
        CalcField.pieceLength,
        CalcField.waste,
      ],
      defaultWaste: 0.10,
      supportsOrientation: false,
      unitLabel: 'عود',
      hint: 'بانوهات فيوتك / بي إس — حساب بعدد ومقاس البراويز',
    ),

    // ─── بيت نور (فيوتك) ────────────────────────────────────
    CategoryCalcConfig(
      category: 'بيت نور',
      defaultMode: CalcMode.linearMeter,
      label: 'بيت نور',
      iconCodePoint: 0xe518, // light_mode
      fields: [
        CalcField.perimeter,
        CalcField.pieceLength,
        CalcField.cornerCount,
        CalcField.waste,
      ],
      defaultWaste: 0.10,
      unitLabel: 'عود',
      hint: 'بيت نور فيوتك — حساب بالمتر الطولي',
    ),

    // ─── صرر (فيوتك) ────────────────────────────────────────
    CategoryCalcConfig(
      category: 'صرر',
      defaultMode: CalcMode.pieces,
      label: 'صرر',
      iconCodePoint: 0xe25e, // horizontal_rule
      fields: [
        CalcField.quantity,
      ],
      defaultWaste: 0.0,
      unitLabel: 'قطعة',
      hint: 'صرر فيوتك — تُباع بالقطعة',
    ),

    // ═══════════════════════════════════════════════════════════
    // ─── Group 2: بدائل التشطيبات (التجليد) ────────────────────
    // ═══════════════════════════════════════════════════════════

    // ─── بديل خشب ───────────────────────────────────────────
    // يُباع بالكرتونة (عدد الألواح مرن حسب الشركة)
    // المصري: 2.80م | المستورد: 2.90م
    CategoryCalcConfig(
      category: 'بديل خشب',
      defaultMode: CalcMode.rod,
      label: 'بديل خشب',
      iconCodePoint: 0xe1a0, // forest
      fields: [
        CalcField.wallLength,
        CalcField.wallHeight,
        CalcField.coverageWidth,
        CalcField.pieceLength,
        CalcField.wallCount,
        CalcField.orientation,
        CalcField.waste,
      ],
      defaultWaste: 0.10,
      supportsOrientation: true,
      unitLabel: 'لوح',
      hint: 'بديل خشب PVC / بي إس / فيوتك — يُباع بالكرتونة',
    ),

    // ─── بديل رخام ──────────────────────────────────────────
    // عادي + ريزن 2.4 مللي | 1.22م × 2.80م
    CategoryCalcConfig(
      category: 'بديل رخام',
      defaultMode: CalcMode.panel,
      label: 'بديل رخام',
      iconCodePoint: 0xe84c, // diamond
      fields: [
        CalcField.wallLength,
        CalcField.wallHeight,
        CalcField.pieceLength,
        CalcField.pieceWidth,
        CalcField.wallCount,
        CalcField.waste,
      ],
      defaultWaste: 0.0,
      unitLabel: 'لوح',
      hint: 'بديل رخام عادي / ريزن — 1.22×2.80م',
    ),

    // ─── شيبورد ─────────────────────────────────────────────
    // 5 مللي | 1.22م × 2.80م
    CategoryCalcConfig(
      category: 'شيبورد',
      defaultMode: CalcMode.panel,
      label: 'شيبورد',
      iconCodePoint: 0xef68, // grid_view
      fields: [
        CalcField.wallLength,
        CalcField.wallHeight,
        CalcField.pieceLength,
        CalcField.pieceWidth,
        CalcField.wallCount,
        CalcField.waste,
      ],
      defaultWaste: 0.0,
      unitLabel: 'لوح',
      hint: 'شيبورد 5 مللي — 1.22×2.80م',
    ),

    // ─── بديل حجر ───────────────────────────────────────────
    // فيوتك 60×120 أو 60×2.80
    CategoryCalcConfig(
      category: 'بديل حجر',
      defaultMode: CalcMode.panel,
      label: 'بديل حجر',
      iconCodePoint: 0xe564, // landscape
      fields: [
        CalcField.wallLength,
        CalcField.wallHeight,
        CalcField.pieceLength,
        CalcField.pieceWidth,
        CalcField.wallCount,
        CalcField.waste,
      ],
      defaultWaste: 0.0,
      unitLabel: 'لوح',
      hint: 'بديل حجر فيوتك 60×120 أو 60×2.80',
    ),

    // ═══════════════════════════════════════════════════════════
    // ─── Group 3: الوزرات والإكسسوارات ─────────────────────────
    // ═══════════════════════════════════════════════════════════

    // ─── وزرات ──────────────────────────────────────────────
    // بي إس / فيوتك بالمتر | PVC بالقطعة
    CategoryCalcConfig(
      category: 'وزرات',
      defaultMode: CalcMode.linearMeter,
      label: 'وزرات',
      iconCodePoint: 0xe3e0, // view_day
      fields: [
        CalcField.perimeter,
        CalcField.pieceLength,
        CalcField.cornerCount,
        CalcField.waste,
      ],
      defaultWaste: 0.10,
      unitLabel: 'عود',
      hint: 'وزرة أرضية بي إس / فيوتك / سادة / ليد',
    ),

    // ─── إكسسوارات (لا تحتاج حساب) ─────────────────────────
    // زوايا استانلس، زوايا PVC، فواصل شيبورد، فواصل رخام
    CategoryCalcConfig(
      category: 'إكسسوارات',
      defaultMode: CalcMode.pieces,
      label: 'إكسسوارات',
      iconCodePoint: 0xe87b, // extension
      fields: [
        CalcField.quantity,
      ],
      defaultWaste: 0.0,
      unitLabel: 'قطعة',
      hint: 'زوايا / فواصل / نهايات — تُباع بالقطعة',
      isNonCalculable: false,
    ),

    // ═══════════════════════════════════════════════════════════
    // ─── Group 4: الخامات المساعدة ──────────────────────────────
    // ═══════════════════════════════════════════════════════════

    // ─── خامات مساعدة (لا تحتاج حساب) ──────────────────────
    // معجون فيوتك، لاصق سريع، سيليكون عظم
    CategoryCalcConfig(
      category: 'خامات مساعدة',
      defaultMode: CalcMode.coverage, // for معجون if needed
      label: 'خامات مساعدة',
      iconCodePoint: 0xe869, // build
      fields: [
        CalcField.wallLength,
        CalcField.wallHeight,
        CalcField.wallCount,
        CalcField.coveragePerUnit,
      ],
      defaultWaste: 0.0,
      unitLabel: 'عبوة',
      hint: 'معجون / لاصق / سيليكون — مواد تكميلية',
    ),
  ];

  /// Find config for a given category name.
  static CategoryCalcConfig? configFor(String category) {
    for (final config in categories) {
      if (config.category == category) return config;
    }
    return null;
  }

  /// Find the best config for a product based on its category and unit_type.
  static CategoryCalcConfig configForProduct(
    String category,
    String? unitType,
  ) {
    // Try exact category match first
    final exact = configFor(category);
    if (exact != null) return exact;

    // Fallback based on unit_type
    if (unitType == 'rod') return categories.firstWhere((c) => c.category == 'بديل خشب');
    if (unitType == 'panel') return categories.firstWhere((c) => c.category == 'بديل رخام');
    if (unitType == 'linear_meter') return categories.firstWhere((c) => c.category == 'كرانيش');
    if (unitType == 'piece') return categories.firstWhere((c) => c.category == 'إكسسوارات');
    if (unitType == 'container' || unitType == 'tube') {
      return categories.firstWhere((c) => c.category == 'خامات مساعدة');
    }
    if (unitType == 'box') return categories.firstWhere((c) => c.category == 'إكسسوارات');

    // Ultimate fallback — خامات مساعدة
    return categories.last;
  }

  /// All categories that support calculations (non-accessories/materials).
  static List<CategoryCalcConfig> get calculableCategories =>
      categories.where((c) => !c.isNonCalculable && c.fields.isNotEmpty).toList();

  /// All category names (for dropdowns, filters).
  static List<String> get categoryNames =>
      categories.map((c) => c.category).toList();

  /// Adds a custom category dynamically.
  static CategoryCalcConfig addCustomCategory(String name, CalcMode mode) {
    // Determine fields based on mode
    List<CalcField> fields;
    String unitLabel;
    int iconCodePoint;
    
    switch (mode) {
      case CalcMode.rod:
        fields = [
          CalcField.wallLength,
          CalcField.wallHeight,
          CalcField.coverageWidth,
          CalcField.pieceLength,
          CalcField.wallCount,
          CalcField.waste,
        ];
        unitLabel = 'عود';
        iconCodePoint = 0xe1a0; // forest
        break;
      case CalcMode.panel:
        fields = [
          CalcField.wallLength,
          CalcField.wallHeight,
          CalcField.pieceLength,
          CalcField.pieceWidth,
          CalcField.wallCount,
          CalcField.waste,
        ];
        unitLabel = 'لوح';
        iconCodePoint = 0xef68; // grid_view
        break;
      case CalcMode.linearMeter:
        fields = [
          CalcField.perimeter,
          CalcField.pieceLength,
          CalcField.cornerCount,
          CalcField.waste,
        ];
        unitLabel = 'عود/قطعة';
        iconCodePoint = 0xe25e; // horizontal_rule
        break;
      case CalcMode.rolls:
        fields = [
          CalcField.wallLength,
          CalcField.wallHeight,
          CalcField.rollWidth,
          CalcField.rollLength,
          CalcField.rapportRepeat,
          CalcField.wallCount,
          CalcField.waste,
        ];
        unitLabel = 'رول';
        iconCodePoint = 0xe8dc; // wallpaper
        break;
      case CalcMode.coverage:
        fields = [
          CalcField.wallLength,
          CalcField.wallHeight,
          CalcField.wallCount,
          CalcField.coveragePerUnit,
        ];
        unitLabel = 'عبوة';
        iconCodePoint = 0xef49; // format_paint
        break;
      case CalcMode.squareMeter:
      default:
        fields = [
          CalcField.wallLength,
          CalcField.wallHeight,
          CalcField.wallCount,
          CalcField.waste,
        ];
        unitLabel = 'م²';
        iconCodePoint = 0xe922; // square_foot
        break;
    }

    final newConfig = CategoryCalcConfig(
      category: name,
      defaultMode: mode,
      label: name,
      iconCodePoint: iconCodePoint,
      fields: fields,
      defaultWaste: 0.10,
      unitLabel: unitLabel,
      hint: 'مادة مضافة يدوياً',
    );

    // Insert before last category
    categories.insert(categories.length - 1, newConfig);

    _saveCustomCategories();
    return newConfig;
  }

  static const _prefsKey = 'custom_calc_categories';

  /// Loads saved custom categories from local storage.
  static Future<void> loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_prefsKey);
      if (data == null || data.isEmpty) return;

      for (final item in data) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final name = map['name'] as String;
        final modeName = map['mode'] as String;
        
        final mode = CalcMode.values.firstWhere(
          (m) => m.name == modeName,
          orElse: () => CalcMode.squareMeter,
        );

        // Avoid duplicates if initialized multiple times
        if (!categories.any((c) => c.category == name)) {
          addCustomCategory(name, mode);
        }
      }
    } catch (e) {
      print('[CategoryCalcRegistry] Error loading custom categories: $e');
    }
  }

  /// Saves current custom categories to local storage.
  static Future<void> _saveCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Filter only custom categories (hint: 'مادة مضافة يدوياً')
      final customConfigs = categories.where((c) => c.hint == 'مادة مضافة يدوياً').toList();
      
      final data = customConfigs.map((c) {
        return jsonEncode({
          'name': c.category,
          'mode': c.defaultMode.name,
        });
      }).toList();

      await prefs.setStringList(_prefsKey, data);
    } catch (e) {
      print('[CategoryCalcRegistry] Error saving custom categories: $e');
    }
  }
}
