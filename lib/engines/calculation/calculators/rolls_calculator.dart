import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for wallpaper rolls (ورق حائط رولات).
///
/// Formula:
///   effectiveHeight = wallHeight + rapportRepeat
///   strips = ceil(wallLength / rollWidth) × wallCount
///   stripsPerRoll = floor(rollLength / effectiveHeight)
///   rolls = ceil(strips / stripsPerRoll)
///   + waste
class RollsCalculator {
  CalcOutput calculate(CalcInput input) {
    if (input.rollWidth <= 0 || input.rollLength <= 0) {
      return const CalcOutput(
        warnings: ['يرجى إدخال عرض وطول الرول'],
      );
    }

    final steps = <String>[];
    final warnings = <String>[];

    // Roll width is in cm in the DB, convert to meters
    final rollWidthM = input.rollWidth > 1 ? input.rollWidth / 100 : input.rollWidth;

    // Wall dimensions
    final wallLength = input.wallLength;
    final wallHeight = input.wallHeight;

    if (wallLength <= 0 || wallHeight <= 0) {
      return const CalcOutput(
        warnings: ['يجب إدخال طول وارتفاع الحائط'],
      );
    }

    // Rapport repeat (pattern matching waste) — in cm, convert to meters
    final rapportM = input.rapportRepeat > 1
        ? input.rapportRepeat / 100
        : input.rapportRepeat;

    // Effective height per strip (wall height + rapport adjustment)
    final effectiveHeight = rapportM > 0
        ? wallHeight + rapportM - (wallHeight % rapportM == 0 ? 0 : (rapportM - (wallHeight % rapportM)))
        : wallHeight;

    steps.add(
      'ارتفاع الشريحة الفعلي = ${(effectiveHeight * 100).toStringAsFixed(0)} سم'
      '${rapportM > 0 ? " (يشمل الرابور ${(rapportM * 100).toStringAsFixed(0)} سم)" : ""}',
    );

    // Strips needed per wall
    final stripsPerWall = (wallLength / rollWidthM).ceil();
    final totalStrips = stripsPerWall * input.wallCount;
    steps.add(
      'عدد الشرائح = ${(wallLength * 100).toStringAsFixed(0)} سم ÷ ${(rollWidthM * 100).toStringAsFixed(0)} سم = $stripsPerWall × ${input.wallCount} حائط = $totalStrips شريحة',
    );

    // Strips per roll
    final stripsPerRoll = (input.rollLength / effectiveHeight).floor();
    if (stripsPerRoll <= 0) {
      warnings.add('⚠️ طول الرول أقصر من ارتفاع الحائط — لن يكفي');
      return CalcOutput(
        warnings: warnings,
        calculationSteps: steps,
      );
    }
    steps.add(
      'شرائح لكل رول = ${(input.rollLength * 100).toStringAsFixed(0)} سم ÷ ${(effectiveHeight * 100).toStringAsFixed(0)} سم = $stripsPerRoll شريحة',
    );

    // Rolls needed (before waste)
    final baseRolls = (totalStrips / stripsPerRoll).ceil();
    steps.add('عدد الرولات = $totalStrips ÷ $stripsPerRoll = $baseRolls رول');

    // Apply waste
    final wasteRolls = (baseRolls * input.wastePercent).ceil();
    final totalRolls = baseRolls + wasteRolls;
    steps.add(
      'الهالك (${(input.wastePercent * 100).toStringAsFixed(0)}%) = $wasteRolls رول',
    );
    steps.add('الإجمالي بعد الهالك = $totalRolls رول');

    // Coverage
    final grossArea = wallLength * wallHeight * input.wallCount;
    final totalCoverage = totalRolls * input.rollLength * rollWidthM;

    // Deduct openings
    double openingsArea = 0;
    if (input.deductOpenings) {
      for (final opening in input.openings) {
        if (opening.deduct) openingsArea += opening.area;
      }
    }

    // Warnings
    if (rapportM > 0.3) {
      warnings.add('ℹ️ الرابور كبير (${(rapportM * 100).toStringAsFixed(0)} سم) — قد يزيد الهالك');
    }

    return CalcOutput(
      grossArea: grossArea,
      openingsArea: openingsArea,
      netArea: grossArea - openingsArea,
      baseQuantity: baseRolls.toDouble(),
      quantityWithWaste: totalRolls.toDouble(),
      unitsNeeded: totalRolls,
      unitLabel: 'رول',
      wastePercent: input.wastePercent,
      wasteQuantity: wasteRolls.toDouble(),
      totalCoverage: totalCoverage,
      warnings: warnings,
      calculationSteps: steps,
    );
  }
}
