import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for items sold simply by pieces without complex dimensions.
class PiecesCalculator {
  CalcOutput calculate(CalcInput input) {
    return CalcOutput(
      grossArea: 0,
      netArea: 0,
      baseQuantity: input.quantity.toDouble(),
      quantityWithWaste: input.quantity.toDouble(), // Usually pieces don't have waste, or waste is just extra pieces added manually
      unitsNeeded: input.quantity,
      unitLabel: 'قطعة',
      wastePercent: input.wastePercent,
      wasteQuantity: 0,
      totalCoverage: 0,
      calculationSteps: [
        'الكمية المطلوبة: ${input.quantity} قطعة',
      ],
    );
  }
}
