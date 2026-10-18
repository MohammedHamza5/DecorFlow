import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for square meter products (ورق حائط، بلاط).
///
/// Follows the formula from PRD section 11.8:
/// netArea = sum(length × height) - openings
/// quantity = netArea × (1 + wastePercent)
class AreaCalculator {
  CalcOutput calculate(CalcInput input) {
    final steps = <String>[];
    final warnings = <String>[];

    // Calculate total area
    double grossArea;
    if (input.directArea != null && input.directArea! > 0) {
      grossArea = input.directArea!;
      steps.add('المساحة المُدخلة مباشرة = ${grossArea.toStringAsFixed(2)} م²');
    } else {
      grossArea = input.wallLength * input.wallHeight * input.wallCount;
      steps.add(
          'المساحة الإجمالية = ${(input.wallLength * 100).toStringAsFixed(0)}سم × ${(input.wallHeight * 100).toStringAsFixed(0)}سم × ${input.wallCount} = ${grossArea.toStringAsFixed(2)} م²');
    }

    // Deduct openings
    double openingsArea = 0;
    if (input.deductOpenings) {
      for (final opening in input.openings) {
        if (opening.deduct) {
          openingsArea += opening.area;
        }
      }
      if (openingsArea > 0) {
        steps.add('مساحة الفتحات = ${openingsArea.toStringAsFixed(2)} م²');
      }
    }

    final netArea = grossArea - openingsArea;
    steps.add('المساحة الصافية = ${netArea.toStringAsFixed(2)} م²');

    // Apply waste
    final areaWithWaste = netArea * (1 + input.wastePercent);
    final wasteArea = netArea * input.wastePercent;
    steps.add(
        'الكمية بعد الهالك (${(input.wastePercent * 100).toStringAsFixed(0)}%) = ${areaWithWaste.toStringAsFixed(2)} م²');

    // Convert to rolls if applicable
    int unitsNeeded;
    String unitLabel;
    if (input.effectiveCoverageArea > 0) {
      unitsNeeded = (areaWithWaste / input.effectiveCoverageArea).ceil();
      if (input.piecesPerBox > 1) {
        final boxes = (unitsNeeded / input.piecesPerBox).ceil();
        unitLabel = 'قطعة ($boxes كرتونة)';
      } else {
        unitLabel = 'قطعة';
      }
      steps.add(
          'عدد القطع = ${areaWithWaste.toStringAsFixed(2)} م² ÷ ${input.effectiveCoverageArea} م² = $unitsNeeded');
    } else {
      unitsNeeded = areaWithWaste.ceil();
      unitLabel = 'م²';
    }

    // Warnings
    if (netArea <= 0) {
      warnings.add('⚠️ المساحة الصافية صفر أو سالبة — تحقق من المقاسات');
    }
    if (openingsArea > grossArea * 0.5) {
      warnings.add('ℹ️ مساحة الفتحات أكثر من نصف المساحة الإجمالية — تحقق من القياسات');
    }

    return CalcOutput(
      grossArea: grossArea,
      openingsArea: openingsArea,
      netArea: netArea,
      baseQuantity: netArea,
      quantityWithWaste: areaWithWaste,
      unitsNeeded: unitsNeeded,
      unitLabel: unitLabel,
      wastePercent: input.wastePercent,
      wasteQuantity: wasteArea,
      totalCoverage: areaWithWaste,
      warnings: warnings,
      calculationSteps: steps,
    );
  }
}
