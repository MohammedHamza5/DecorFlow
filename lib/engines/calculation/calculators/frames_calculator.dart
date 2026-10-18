import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Calculator for frames (Wainscoting/Panels frames - بانوهات).
class FramesCalculator {
  CalcOutput calculate(CalcInput input) {
    // Each frame requires (width + height) * 2
    final double perimeterPerFrame = (input.frameWidth + input.frameHeight) * 2;
    final double totalPerimeter = perimeterPerFrame * input.frameCount;
    
    // Total length with waste
    final double wasteQuantity = totalPerimeter * input.wastePercent;
    
    // Additional waste for corners is implicit or could be added. 
    // Usually, cornices use 0.1m per corner. Frames might use it too.
    final int totalCorners = 4 * input.frameCount;
    final double cornersWaste = totalCorners * 0.10; // 10cm per corner for miter cuts
    
    final double totalRequiredLength = totalPerimeter + wasteQuantity + cornersWaste;
    
    int unitsNeeded = 0;
    List<String> steps = [
      'عدد البراويز: ${input.frameCount}',
      'مقاس البرواز: ${(input.frameWidth * 100).toStringAsFixed(0)}سم × ${(input.frameHeight * 100).toStringAsFixed(0)}سم',
      'محيط البرواز الواحد: ${(perimeterPerFrame * 100).toStringAsFixed(0)} سم',
      'إجمالي المحيط الصافي: ${(totalPerimeter * 100).toStringAsFixed(0)} سم',
    ];

    if (wasteQuantity > 0) {
      steps.add('الهالك العادي (${(input.wastePercent * 100).toStringAsFixed(0)}%): ${(wasteQuantity * 100).toStringAsFixed(0)} سم');
    }
    steps.add('هالك الزوايا (4 زوايا للبرواز): ${(cornersWaste * 100).toStringAsFixed(0)} سم');
    steps.add('إجمالي الطول المطلوب (بالهالك): ${(totalRequiredLength * 100).toStringAsFixed(0)} سم');

    if (input.pieceLength > 0) {
      final double piecesExact = totalRequiredLength / input.pieceLength;
      unitsNeeded = piecesExact.ceil();
      steps.add('الأعواد المطلوبة (طول ${(input.pieceLength * 100).toStringAsFixed(0)}سم): $unitsNeeded عود');
    } else {
      unitsNeeded = (totalRequiredLength * 100).ceil();
      steps.add('الطول التقريبي المطلوب: $unitsNeeded سم');
    }
    
    return CalcOutput(
      grossArea: totalPerimeter, 
      netArea: totalPerimeter,
      baseQuantity: totalPerimeter,
      quantityWithWaste: totalRequiredLength,
      unitsNeeded: unitsNeeded,
      unitLabel: 'عود',
      wastePercent: input.wastePercent,
      wasteQuantity: wasteQuantity + cornersWaste,
      totalCoverage: totalPerimeter,
      calculationSteps: steps,
    );
  }
}
