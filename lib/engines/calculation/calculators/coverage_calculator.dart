import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for coverage-based products (معجون، بطانة، دهان).
///
/// Formula:
///   totalArea = wallLength × wallHeight × wallCount
///   units = ceil(totalArea / coveragePerUnit)
class CoverageCalculator {
  CalcOutput calculate(CalcInput input) {
    if (input.coveragePerUnit <= 0) {
      return const CalcOutput(
        warnings: ['يرجى إدخال مساحة تغطية العبوة'],
      );
    }

    final steps = <String>[];
    final warnings = <String>[];

    // Calculate total area
    double grossArea;
    if (input.directArea != null && input.directArea! > 0) {
      grossArea = input.directArea!;
      steps.add('المساحة المُدخلة مباشرة = ${grossArea.toStringAsFixed(2)} م²');
    } else {
      if (input.wallLength <= 0 || input.wallHeight <= 0) {
        return const CalcOutput(
          warnings: ['يجب إدخال طول وارتفاع الحائط أو المساحة مباشرة'],
        );
      }
      grossArea = input.wallLength * input.wallHeight * input.wallCount;
      steps.add(
        'المساحة الإجمالية = ${(input.wallLength * 100).toStringAsFixed(0)}سم × ${(input.wallHeight * 100).toStringAsFixed(0)}سم × ${input.wallCount} = ${grossArea.toStringAsFixed(2)} م²',
      );
    }

    // Deduct openings
    double openingsArea = 0;
    if (input.deductOpenings) {
      for (final opening in input.openings) {
        if (opening.deduct) openingsArea += opening.area;
      }
      if (openingsArea > 0) {
        steps.add('مساحة الفتحات = ${openingsArea.toStringAsFixed(2)} م²');
      }
    }

    final netArea = grossArea - openingsArea;
    steps.add('المساحة الصافية = ${netArea.toStringAsFixed(2)} م²');

    // Calculate units needed (no waste for coverage products typically)
    final unitsNeeded = (netArea / input.coveragePerUnit).ceil();
    steps.add(
      'عدد العبوات = ${netArea.toStringAsFixed(2)} م² ÷ ${input.coveragePerUnit} م² = $unitsNeeded عبوة',
    );

    final totalCoverage = unitsNeeded * input.coveragePerUnit;
    final surplus = totalCoverage - netArea;
    steps.add('التغطية الفعلية = ${totalCoverage.toStringAsFixed(2)} م² (فائض ${surplus.toStringAsFixed(2)} م²)');

    if (netArea <= 0) {
      warnings.add('⚠️ المساحة الصافية صفر أو سالبة — تحقق من المقاسات');
    }

    return CalcOutput(
      grossArea: grossArea,
      openingsArea: openingsArea,
      netArea: netArea,
      baseQuantity: netArea,
      quantityWithWaste: netArea, // No waste for coverage products
      unitsNeeded: unitsNeeded,
      unitLabel: 'عبوة',
      wastePercent: 0,
      wasteQuantity: 0,
      totalCoverage: totalCoverage,
      warnings: warnings,
      calculationSteps: steps,
    );
  }
}
