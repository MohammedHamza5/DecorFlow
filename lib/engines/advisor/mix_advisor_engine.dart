import 'models/mix_models.dart';

/// Smart Mix Advisor — suggests material combinations to reduce cost.
///
/// When a user calculates a full wall with an expensive material,
/// this engine proposes alternative mixes that look better AND cost less.
///
/// Example: Instead of full wall بديل خشب, suggest:
///   - 2 panels بديل رخام in center (40%) + بديل خشب on sides (60%)
///   - Saves ~30% with a premium design look
class MixAdvisorEngine {
  /// Built-in mix rules based on Egyptian decor market knowledge.
  static const List<MixRule> _rules = [
    // بديل خشب → رخام + خشب
    MixRule(
      sourceCategory: 'بديل خشب',
      mixCategory: 'بديل رخام',
      secondaryRatio: 0.40,
      secondaryPlacement: 'وسط الحائط (فوكال بوينت)',
      primaryPlacement: 'الجوانب والإطار',
      expectedSavings: 0.25,
      designNote: 'لوحين رخام في المنتصف يعطي مظهر فخم، مع بديل خشب كإطار على الجانبين',
      title: 'ديزاين رخام + خشب',
    ),

    // بديل خشب → بانوهات PS كبير + خشب إطار
    MixRule(
      sourceCategory: 'بديل خشب',
      mixCategory: 'بانوهات',
      secondaryRatio: 0.50,
      secondaryPlacement: 'النصف السفلي أو المنتصف',
      primaryPlacement: 'النصف العلوي أو الإطار',
      expectedSavings: 0.20,
      designNote: 'بانوه PS مشجر في النص مع بديل خشب في الباقي — لمسة عصرية',
      title: 'ديزاين بانوه + خشب',
    ),

    // بديل رخام → رخام فوكال + خشب
    MixRule(
      sourceCategory: 'بديل رخام',
      mixCategory: 'بديل خشب',
      secondaryRatio: 0.60,
      secondaryPlacement: 'الجوانب',
      primaryPlacement: 'لوح فوكال في المنتصف',
      expectedSavings: 0.30,
      designNote: 'لوح رخام واحد كبير كفوكال بوينت والباقي بديل خشب — أنيق وموفر',
      title: 'فوكال رخام + خشب',
    ),

    // بديل رخام → رخام + بانوهات
    MixRule(
      sourceCategory: 'بديل رخام',
      mixCategory: 'بانوهات',
      secondaryRatio: 0.15,
      secondaryPlacement: 'شرائح فاصلة بين الألواح',
      primaryPlacement: 'الألواح الرئيسية',
      expectedSavings: 0.10,
      designNote: 'إضافة شرائح بانوه بين ألواح الرخام — مظهر مودرن فاخر',
      title: 'رخام + شرائح بانوه',
    ),

    // بديل خشب → خشب + شيبورد
    MixRule(
      sourceCategory: 'بديل خشب',
      mixCategory: 'شيبورد',
      secondaryRatio: 0.40,
      secondaryPlacement: 'حائط الأكسنت (فوكال بوينت)',
      primaryPlacement: 'باقي الحوائط',
      expectedSavings: 0.25,
      designNote: 'شيبورد على حائط واحدة كأكسنت مع بديل خشب للباقي — مظهر عصري',
      title: 'شيبورد + خشب',
    ),

    // بانوهات → بانوه نص + خشب
    MixRule(
      sourceCategory: 'بانوهات',
      mixCategory: 'بديل خشب',
      secondaryRatio: 0.50,
      secondaryPlacement: 'النصف السفلي',
      primaryPlacement: 'النصف العلوي',
      expectedSavings: 0.15,
      designNote: 'بانوه في النص العلوي مع بديل خشب في النص السفلي — تقسيم أنيق',
      title: 'بانوه + خشب (Two-Tone)',
    ),
  ];

  /// Generate mix proposals for the given calculation.
  ///
  /// Returns proposals sorted by savings (highest first).
  List<MixProposal> suggest({
    required String originalCategory,
    required double netArea,
    required double originalUnitPrice,
    required double originalTotalCost,
    required Map<String, double> categoryAvgPrices,
  }) {
    final proposals = <MixProposal>[];

    // Find applicable rules
    final applicableRules = _rules
        .where((r) => r.sourceCategory == originalCategory)
        .toList();

    for (final rule in applicableRules) {
      // Get the price of the secondary material
      final secondaryPrice = categoryAvgPrices[rule.mixCategory];
      if (secondaryPrice == null || secondaryPrice <= 0) continue;

      // Calculate areas
      final secondaryArea = netArea * rule.secondaryRatio;
      final primaryArea = netArea * (1 - rule.secondaryRatio);

      // Calculate costs
      final primaryCost = primaryArea * originalUnitPrice;
      final secondaryCost = secondaryArea * secondaryPrice;
      final mixTotalCost = primaryCost + secondaryCost;

      // Only suggest if it actually saves money
      if (mixTotalCost >= originalTotalCost) continue;

      proposals.add(MixProposal(
        title: rule.title,
        description: rule.designNote,
        designNote: rule.designNote,
        items: [
          MixItem(
            productName: originalCategory,
            category: originalCategory,
            placement: rule.primaryPlacement,
            coverageRatio: 1 - rule.secondaryRatio,
            coverageArea: primaryArea,
            quantity: primaryArea, // Simplified — actual calc would use engine
            unitLabel: 'م²',
            unitPrice: originalUnitPrice,
            lineTotal: primaryCost,
          ),
          MixItem(
            productName: rule.mixCategory,
            category: rule.mixCategory,
            placement: rule.secondaryPlacement,
            coverageRatio: rule.secondaryRatio,
            coverageArea: secondaryArea,
            quantity: secondaryArea,
            unitLabel: 'م²',
            unitPrice: secondaryPrice,
            lineTotal: secondaryCost,
          ),
        ],
        totalCost: mixTotalCost,
        originalCost: originalTotalCost,
      ));
    }

    // Sort by savings (highest first)
    proposals.sort((a, b) => b.savingsPercent.compareTo(a.savingsPercent));

    return proposals;
  }
}
