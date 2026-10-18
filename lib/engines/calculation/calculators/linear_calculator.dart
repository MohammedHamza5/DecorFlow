import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for linear meter products (وزر، كرانيش، إطارات).
///
/// Follows the formula from PRD section 11.5:
/// length = perimeter - deductions + waste
class LinearCalculator {
  CalcOutput calculate(CalcInput input) {
    final steps = <String>[];
    final warnings = <String>[];

    // Calculate perimeter
    double totalLength;
    if (input.perimeter > 0) {
      totalLength = input.perimeter;
      steps.add('المحيط المُدخل = ${(totalLength * 100).toStringAsFixed(0)} سم');
    } else {
      // Calculate from wall dimensions
      totalLength = input.wallLength * input.wallCount;
      steps.add(
          'الطول الإجمالي = ${(input.wallLength * 100).toStringAsFixed(0)}سم × ${input.wallCount} = ${(totalLength * 100).toStringAsFixed(0)} سم');
    }

    // Deduct openings (as linear deductions)
    double deductions = 0;
    if (input.deductOpenings) {
      for (final opening in input.openings) {
        if (opening.deduct) {
          deductions += opening.width;
        }
      }
      if (deductions > 0) {
        steps.add('خصم الفتحات = ${(deductions * 100).toStringAsFixed(0)} سم');
      }
    }

    final netLength = totalLength - deductions;
    steps.add('الطول الصافي = ${(netLength * 100).toStringAsFixed(0)} سم');

    // Apply waste (includes cutting waste + corner waste)
    final cornerWaste = input.cornerCount * 0.05; // 5cm waste per corner
    final percentWaste = netLength * input.wastePercent;
    final totalWaste = percentWaste + cornerWaste;

    final lengthWithWaste = netLength + totalWaste;
    steps.add(
        'هالك القص (${(input.wastePercent * 100).toStringAsFixed(0)}%) = ${(percentWaste * 100).toStringAsFixed(0)} سم');
    if (input.cornerCount > 0) {
      steps.add(
          'هالك الزوايا (${input.cornerCount} زاوية × 5 سم) = ${(cornerWaste * 100).toStringAsFixed(0)} سم');
    }
    steps.add('الطول بعد الهالك = ${(lengthWithWaste * 100).toStringAsFixed(0)} سم');

    // Convert to rods if piece length is specified
    int unitsNeeded;
    String unitLabel;
    if (input.pieceLength > 0) {
      unitsNeeded = (lengthWithWaste / input.pieceLength).ceil();
      unitLabel = 'عود';
      steps.add(
          'عدد الأعواد = ${(lengthWithWaste * 100).toStringAsFixed(0)}سم ÷ ${(input.pieceLength * 100).toStringAsFixed(0)}سم = $unitsNeeded عود');
      
      // Calculate boxes if applicable
      if (input.piecesPerBox > 1) {
        final boxesNeeded = (unitsNeeded / input.piecesPerBox).ceil();
        steps.add(
            'عدد الكراتين = $unitsNeeded ÷ ${input.piecesPerBox} = $boxesNeeded كرتونة');
        unitLabel = 'عود ($boxesNeeded كرتونة)';
      }
    } else {
      unitsNeeded = lengthWithWaste.ceil();
      unitLabel = 'م.ط';
    }

    // Warnings
    if (netLength <= 0) {
      warnings.add('⚠️ الطول الصافي صفر أو سالب — تحقق من المقاسات');
    }

    return CalcOutput(
      grossArea: totalLength,
      openingsArea: deductions,
      netArea: netLength,
      baseQuantity: netLength,
      quantityWithWaste: lengthWithWaste,
      unitsNeeded: unitsNeeded,
      unitLabel: unitLabel,
      wastePercent: input.wastePercent,
      wasteQuantity: totalWaste,
      totalCoverage: unitsNeeded * (input.pieceLength > 0 ? input.pieceLength : 1),
      warnings: warnings,
      calculationSteps: steps,
    );
  }
}
