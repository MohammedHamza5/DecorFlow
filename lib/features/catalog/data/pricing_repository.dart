import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:uuid/uuid.dart';

/// نتيجة حل السعر لأي صنف
class ResolvedPriceInfo {
  final double costPrice;
  final double sellingPrice;
  final double technicianPrice;
  final double minSellingPrice;
  final bool isCustomOverride;
  final String sourceLabel;
  final String? ruleId;

  const ResolvedPriceInfo({
    required this.costPrice,
    required this.sellingPrice,
    required this.technicianPrice,
    required this.minSellingPrice,
    required this.isCustomOverride,
    required this.sourceLabel,
    this.ruleId,
  });

  /// هامش الربح بالجنيه للقطاعي
  double get retailProfit => (sellingPrice - costPrice).clamp(0, double.infinity);

  /// نسبة هامش الربح للقطاعي (0 - 100%)
  double get retailProfitMarginPercent =>
      sellingPrice > 0 ? (retailProfit / sellingPrice) * 100 : 0;

  /// هامش الربح للفنيين بالجنيه
  double get technicianProfit => (technicianPrice - costPrice).clamp(0, double.infinity);

  static const empty = ResolvedPriceInfo(
    costPrice: 0.0,
    sellingPrice: 0.0,
    technicianPrice: 0.0,
    minSellingPrice: 0.0,
    isCustomOverride: false,
    sourceLabel: 'غير مسعر',
  );
}

class PricingRepository {
  final AppDatabase _db;

  PricingRepository(this._db);

  /// مراقبة جميع قواعد التسعير
  Stream<List<LocalPricingRule>> watchRules() {
    return (_db.select(_db.localPricingRules)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.category)]))
        .watch();
  }

  static bool _hasPurgedMockRules = false;

  /// تنظيف أي أسعار افتراضية وهمية سابقة لتبدأ الشاشة صفرية وفارغة تماماً لصاحب المعرض
  Future<void> clearDummyMockRules() async {
    try {
      await (_db.delete(_db.localPricingRules)
            ..where((t) =>
                t.notes.like('%سعر موحد لجميع أكواد%') |
                t.notes.like('%سعر بديل الخشب المعالج%') |
                t.notes.like('%ألواح بديل الرخام%') |
                t.notes.like('%ألواح أوبن بوك%') |
                t.notes.like('%سعر عود البانوه%')))
          .go();
    } catch (e) {
      debugPrint('Error clearing dummy mock rules: $e');
    }
  }

  /// جلب جميع القواعد المسجلة
  Future<List<LocalPricingRule>> getAllRules() async {
    if (!_hasPurgedMockRules) {
      _hasPurgedMockRules = true;
      await clearDummyMockRules();
    }

    final rules = await (_db.select(_db.localPricingRules)
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    return rules;
  }

  /// جلب قواعد التسعير لفئة معينة
  Future<List<LocalPricingRule>> getRulesForCategory(String category) async {
    final all = await getAllRules();
    return all.where((r) => r.category.toLowerCase().trim() == category.toLowerCase().trim()).toList();
  }

  /// إضافة أو تحديث قاعدة تسعير
  Future<LocalPricingRule> upsertRule({
    String? id,
    required String category,
    String? subcategory,
    String? material,
    String? variantType,
    String? dimensionSpec,
    required double costPrice,
    required double sellingPrice,
    required double technicianPrice,
    required double minSellingPrice,
    String? notes,
  }) async {
    final now = DateTime.now();
    if (id != null && id.isNotEmpty) {
      final comp = LocalPricingRulesCompanion(
        category: Value(category),
        subcategory: Value(subcategory),
        material: Value(material),
        variantType: Value(variantType),
        dimensionSpec: Value(dimensionSpec),
        costPrice: Value(costPrice),
        sellingPrice: Value(sellingPrice),
        technicianPrice: Value(technicianPrice),
        minSellingPrice: Value(minSellingPrice),
        notes: Value(notes),
        syncStatus: const Value('pending_update'),
        updatedAt: Value(now),
      );
      await (_db.update(_db.localPricingRules)..where((t) => t.id.equals(id)))
          .write(comp);
      return (_db.select(_db.localPricingRules)..where((t) => t.id.equals(id)))
          .getSingle();
    } else {
      final newId = const Uuid().v4();
      final comp = LocalPricingRulesCompanion(
        id: Value(newId),
        category: Value(category),
        subcategory: Value(subcategory),
        material: Value(material),
        variantType: Value(variantType),
        dimensionSpec: Value(dimensionSpec),
        costPrice: Value(costPrice),
        sellingPrice: Value(sellingPrice),
        technicianPrice: Value(technicianPrice),
        minSellingPrice: Value(minSellingPrice),
        notes: Value(notes),
        syncStatus: const Value('pending_insert'),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      return _db.into(_db.localPricingRules).insertReturning(comp);
    }
  }

  /// حذف قاعدة تسعير (حذف منطقي)
  Future<void> deleteRule(String id) async {
    await (_db.update(_db.localPricingRules)..where((t) => t.id.equals(id))).write(
      LocalPricingRulesCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending_update'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// استنتاج السعر الذكي لأي صنف بناء على (الاستثناء أولاً -> ثم المصفوفة -> ثم الفئة)
  ResolvedPriceInfo resolveVariantPrice({
    required String category,
    String? subcategory,
    String? material,
    String? variantName,
    String? variantType,
    String? dimensions,
    String? dimensionSpec,
    double? pieceLength,
    double? pieceWidth,
    double? thickness,
    double? costOverride,
    double? sellingOverride,
    double? technicianOverride,
    double? minSellingOverride,
    List<LocalPricingRule>? cachedRules,
  }) {
    return resolveVariantPriceStatic(
      category: category,
      subcategory: subcategory,
      material: material,
      variantName: variantName,
      variantType: variantType,
      dimensions: dimensions ?? dimensionSpec,
      dimensionSpec: dimensionSpec ?? dimensions,
      pieceLength: pieceLength,
      pieceWidth: pieceWidth,
      thickness: thickness,
      costOverride: costOverride,
      sellingOverride: sellingOverride,
      technicianOverride: technicianOverride,
      minSellingOverride: minSellingOverride,
      cachedRules: cachedRules,
    );
  }

  static List<num> _extractNumbers(String text) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    return regex.allMatches(text).map((m) => num.tryParse(m.group(1)!) ?? 0).where((n) => n > 0).toList();
  }

  /// الدالة الستاتيكية لحساب السعر
  static ResolvedPriceInfo resolveVariantPriceStatic({
    required String category,
    String? subcategory,
    String? material,
    String? variantName,
    String? variantType,
    String? dimensions,
    String? dimensionSpec,
    double? pieceLength,
    double? pieceWidth,
    double? thickness,
    double? costOverride,
    double? sellingOverride,
    double? technicianOverride,
    double? minSellingOverride,
    List<LocalPricingRule>? cachedRules,
  }) {
    final effectiveDim = (dimensions ?? dimensionSpec ?? '').trim();
    // 1. هل يوجد استثناء يدوي مخصص للصنف؟
    if (sellingOverride != null && sellingOverride > 0) {
      final cost = costOverride ?? 0.0;
      final tech = technicianOverride != null && technicianOverride > 0
          ? technicianOverride
          : (sellingOverride * 0.90); // افتراضي 10% خصم فني إذا لم يحدد
      final minP = minSellingOverride != null && minSellingOverride > 0
          ? minSellingOverride
          : (cost > 0 ? cost * 1.05 : sellingOverride * 0.85);

      return ResolvedPriceInfo(
        costPrice: cost,
        sellingPrice: sellingOverride,
        technicianPrice: tech,
        minSellingPrice: minP,
        isCustomOverride: true,
        sourceLabel: 'سعر استثنائي مخصص',
      );
    }

    // 2. البحث في قواعد المصفوفة
    final rules = cachedRules ?? [];
    if (rules.isEmpty) {
      return ResolvedPriceInfo.empty;
    }

    final catClean = category.trim().toLowerCase();
    final nameClean = (variantName ?? '').trim().toLowerCase();
    final dimClean = effectiveDim.toLowerCase();
    final matClean = (material ?? '').trim().toLowerCase();
    final typeClean = (variantType ?? '').trim().toLowerCase();

    // فرز القواعد المطابقة لنفس الفئة
    final categoryRules = rules.where((r) {
      final rCat = r.category.trim().toLowerCase();
      return catClean.contains(rCat) || rCat.contains(catClean);
    }).toList();

    if (categoryRules.isEmpty) {
      return ResolvedPriceInfo.empty;
    }

    // أرقام المقاسات في هذا الصنف
    final variantNums = _extractNumbers('$dimClean $nameClean');
    final pWidthCm = pieceWidth != null && pieceWidth > 0 ? (pieceWidth * 100).round() : null;
    final pLengthCm = pieceLength != null && pieceLength > 0 ? (pieceLength * 100).round() : null;

    // أ. مطابقة دقيقة بالأبعاد والخامة والتشطيب
    for (final rule in categoryRules) {
      final rSpec = (rule.dimensionSpec ?? '').trim().toLowerCase();
      final rMat = (rule.material ?? '').trim().toLowerCase();
      final rType = (rule.variantType ?? '').trim().toLowerCase();

      // فحص تطابق الخامة
      bool matchesMat = true;
      if (rMat.isNotEmpty) {
        matchesMat = matClean.contains(rMat) || rMat.contains(matClean) || nameClean.contains(rMat);
      }

      // فحص تطابق النوع / التشطيب
      bool matchesType = true;
      if (rType.isNotEmpty) {
        matchesType = typeClean.contains(rType) || rType.contains(typeClean) || nameClean.contains(rType);
      }

      if (!matchesMat || !matchesType) continue;

      // فحص تطابق الأبعاد والمقاسات
      bool matchesSpec = false;
      if (rSpec.isNotEmpty) {
        final ruleNums = _extractNumbers(rSpec);
        if (ruleNums.isNotEmpty) {
          // إذا كانت القاعدة تحتوي على طول وعرض محددين (مثال: 290 و 16)
          if (ruleNums.length >= 2 && (pLengthCm != null || pWidthCm != null || variantNums.length >= 2)) {
            final hasLength = ruleNums.any((n) => n == pLengthCm || variantNums.contains(n));
            final hasWidth = ruleNums.any((n) => n == pWidthCm || variantNums.contains(n));
            if (hasLength && hasWidth) {
              matchesSpec = true;
            }
          } else if (pWidthCm != null && ruleNums.contains(pWidthCm)) {
            // تطابق العرض (مثال: عرض 16 سم أو 17 سم)
            matchesSpec = true;
          } else if (ruleNums.every((n) => variantNums.contains(n))) {
            matchesSpec = true;
          } else if (dimClean.contains(rSpec) || rSpec.contains(dimClean)) {
            matchesSpec = true;
          }
        } else if (dimClean.contains(rSpec) || rSpec.contains(dimClean)) {
          matchesSpec = true;
        }
      } else {
        // قاعدة عامة بدون تحديد أبعاد
        matchesSpec = true;
      }

      if (matchesSpec && (rSpec.isNotEmpty || rMat.isNotEmpty || rType.isNotEmpty)) {
        return ResolvedPriceInfo(
          costPrice: rule.costPrice,
          sellingPrice: rule.sellingPrice,
          technicianPrice: rule.technicianPrice,
          minSellingPrice: rule.minSellingPrice,
          isCustomOverride: false,
          sourceLabel: '${rule.category} ${rule.material ?? ""} ${rule.dimensionSpec ?? ""} ${rule.variantType ?? ""}'.trim(),
          ruleId: rule.id,
        );
      }
    }

    // ب. مطابقة بالنوع / التشطيب (لأصناف مثل بديل الرخام: عادي، ريزن، أوبن بوك)
    for (final rule in categoryRules) {
      final rType = (rule.variantType ?? '').trim().toLowerCase();
      if (rType.isNotEmpty) {
        if (rType.contains('ريزن') && (nameClean.contains('ريزن') || matClean.contains('ريزن'))) {
          return ResolvedPriceInfo(
            costPrice: rule.costPrice,
            sellingPrice: rule.sellingPrice,
            technicianPrice: rule.technicianPrice,
            minSellingPrice: rule.minSellingPrice,
            isCustomOverride: false,
            sourceLabel: '${rule.category} (${rule.variantType})',
            ruleId: rule.id,
          );
        }
        if ((rType.contains('اوبن') || rType.contains('أوبن') || rType.contains('بوك')) &&
            (nameClean.contains('اوبن') || nameClean.contains('أوبن') || nameClean.contains('بوك'))) {
          return ResolvedPriceInfo(
            costPrice: rule.costPrice,
            sellingPrice: rule.sellingPrice,
            technicianPrice: rule.technicianPrice,
            minSellingPrice: rule.minSellingPrice,
            isCustomOverride: false,
            sourceLabel: '${rule.category} (${rule.variantType})',
            ruleId: rule.id,
          );
        }
        if (rType.contains('عادي') && !nameClean.contains('ريزن') && !nameClean.contains('بوك')) {
          return ResolvedPriceInfo(
            costPrice: rule.costPrice,
            sellingPrice: rule.sellingPrice,
            technicianPrice: rule.technicianPrice,
            minSellingPrice: rule.minSellingPrice,
            isCustomOverride: false,
            sourceLabel: '${rule.category} (${rule.variantType})',
            ruleId: rule.id,
          );
        }
      }
    }

    // ج. مطابقة عامة للفئة (مثل الشيبورد أو أول قاعدة في الفئة)
    final generalRule = categoryRules.first;
    return ResolvedPriceInfo(
      costPrice: generalRule.costPrice,
      sellingPrice: generalRule.sellingPrice,
      technicianPrice: generalRule.technicianPrice,
      minSellingPrice: generalRule.minSellingPrice,
      isCustomOverride: false,
      sourceLabel: generalRule.category,
      ruleId: generalRule.id,
    );
  }

  /// حفظ أو تحديث قاعدة تسعير لمواصفة محددة من قبل صاحب المعرض
  Future<LocalPricingRule> saveRuleForSpec({
    required String category,
    String? subcategory,
    String? material,
    String? dimensionSpec,
    String? variantType,
    required double costPrice,
    required double sellingPrice,
    required double technicianPrice,
    required double minSellingPrice,
    String? notes,
  }) async {
    final all = await getAllRules();
    final catClean = category.trim().toLowerCase();
    final matClean = (material ?? '').trim().toLowerCase();
    final dimClean = (dimensionSpec ?? '').trim().toLowerCase();
    final typeClean = (variantType ?? '').trim().toLowerCase();

    LocalPricingRule? existing;
    for (final r in all) {
      final rCat = r.category.trim().toLowerCase();
      final rMat = (r.material ?? '').trim().toLowerCase();
      final rDim = (r.dimensionSpec ?? '').trim().toLowerCase();
      final rType = (r.variantType ?? '').trim().toLowerCase();

      bool matchesCat = rCat == catClean || rCat.contains(catClean) || catClean.contains(rCat);
      bool matchesMat = (matClean.isEmpty && rMat.isEmpty) ||
          (matClean.isNotEmpty && (rMat == matClean || rMat.contains(matClean) || matClean.contains(rMat)));
      bool matchesDim = (dimClean.isEmpty && rDim.isEmpty) ||
          (dimClean.isNotEmpty && (rDim == dimClean || rDim.contains(dimClean) || dimClean.contains(rDim)));
      bool matchesType = (typeClean.isEmpty && rType.isEmpty) ||
          (typeClean.isNotEmpty && (rType == typeClean || rType.contains(typeClean) || typeClean.contains(rType)));

      if (matchesCat && matchesMat && matchesDim && matchesType) {
        existing = r;
        break;
      }
    }

    return upsertRule(
      id: existing?.id,
      category: category,
      subcategory: subcategory,
      material: material,
      dimensionSpec: dimensionSpec,
      variantType: variantType,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      technicianPrice: technicianPrice,
      minSellingPrice: minSellingPrice,
      notes: notes ?? 'تسعير معتمد بواسطة صاحب المعرض',
    );
  }
}

/// موفر مستودع قواعد التسعير
final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PricingRepository(db);
});

/// موفر قائمة قواعد التسعير اللحظية
final pricingRulesStreamProvider = StreamProvider<List<LocalPricingRule>>((ref) {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.watchRules();
});
