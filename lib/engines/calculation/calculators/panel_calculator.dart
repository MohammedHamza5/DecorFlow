import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for panel/board products (بديل رخام، ألواح).
///
/// Follows the formula from PRD section 11.6:
/// panels = ceil(netArea / panelCoverageArea) + waste
class PanelCalculator {
  CalcOutput calculate(CalcInput input) {
    double coverageArea = input.effectiveCoverageArea;
    if (coverageArea <= 0 && input.pieceLength > 0 && input.pieceWidth > 0) {
      coverageArea = input.pieceLength * input.pieceWidth;
    }

    if (coverageArea <= 0) {
      return const CalcOutput(
        warnings: ['يرجى إدخال أبعاد اللوح أو مساحة تغطية اللوح'],
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
      grossArea = input.wallLength * input.wallHeight * input.wallCount;
      steps.add(
          'المساحة الإجمالية = ${(input.wallLength * 100).toStringAsFixed(0)}سم × ${(input.wallHeight * 100).toStringAsFixed(0)}سم × ${input.wallCount} = ${grossArea.toStringAsFixed(2)} م²');
    }

    if (input.pieceLength > 0 && input.pieceWidth > 0) {
      steps.add(
          'مقاس اللوح = ${(input.pieceWidth * 100).toStringAsFixed(0)}سم × ${(input.pieceLength * 100).toStringAsFixed(0)}سم = ${coverageArea.toStringAsFixed(4)} م²');
    } else {
      steps.add('مساحة تغطية اللوح = ${coverageArea.toStringAsFixed(4)} م²');
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

    // Apply waste to area first
    final areaWithWaste = netArea * (1 + input.wastePercent);
    steps.add(
        'المساحة بعد الهالك (${(input.wastePercent * 100).toStringAsFixed(0)}%) = ${areaWithWaste.toStringAsFixed(2)} م²');

    // Calculate panels needed
    final panelsNeeded = (areaWithWaste / coverageArea).ceil();
    steps.add(
        'عدد الألواح = ${areaWithWaste.toStringAsFixed(2)} م² ÷ ${coverageArea.toStringAsFixed(4)} م² = $panelsNeeded لوح');

    // Calculate boxes if applicable
    int boxesNeeded = panelsNeeded;
    if (input.piecesPerBox > 1) {
      boxesNeeded = (panelsNeeded / input.piecesPerBox).ceil();
      steps.add(
          'عدد الكراتين = $panelsNeeded ÷ ${input.piecesPerBox} = $boxesNeeded كرتونة');
    }

    final totalCoverage = panelsNeeded * coverageArea;
    final wasteQty =
        (netArea * input.wastePercent / coverageArea).ceil();

    // Warnings
    if (netArea <= 0) {
      warnings.add('⚠️ المساحة الصافية صفر أو سالبة — تحقق من المقاسات');
    }

    return CalcOutput(
      grossArea: grossArea,
      openingsArea: openingsArea,
      netArea: netArea,
      baseQuantity: (netArea / coverageArea).ceilToDouble(),
      quantityWithWaste: panelsNeeded.toDouble(),
      unitsNeeded: panelsNeeded,
      unitLabel: input.piecesPerBox > 1 ? 'لوح ($boxesNeeded كرتونة)' : 'لوح',
      wastePercent: input.wastePercent,
      wasteQuantity: wasteQty.toDouble(),
      totalCoverage: totalCoverage,
      warnings: warnings,
      calculationSteps: steps,
    );
  }
}
