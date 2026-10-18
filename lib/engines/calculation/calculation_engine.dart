import 'package:stream_pay/engines/calculation/models/calc_input.dart';
import 'package:stream_pay/engines/calculation/models/calc_output.dart';
import '../../core/constants/unit_types.dart';
import 'calculators/rod_calculator.dart';
import 'calculators/panel_calculator.dart';
import 'calculators/linear_calculator.dart';
import 'calculators/area_calculator.dart';
import 'calculators/rolls_calculator.dart';
import 'calculators/coverage_calculator.dart';

import 'calculators/pieces_calculator.dart';
import 'calculators/frames_calculator.dart';

/// The main calculation engine — routes to the appropriate calculator.
///
/// This is the single entry point for all calculations.
/// Designed to be independent of UI — pure Dart, no Flutter dependencies.
///
/// Usage:
/// ```dart
/// final engine = CalculationEngine();
/// final result = engine.calculate(CalcInput(
///   mode: CalcMode.rod,
///   wallLength: 4,
///   wallHeight: 3,
///   effectiveCoverageWidth: 0.16,
///   pieceLength: 2.9,
///   orientation: InstallationOrientation.vertical,
///   wastePercent: 0.10,
/// ));
/// print(result.unitsNeeded); // 55
/// ```
class CalculationEngine {
  final _rodCalculator = RodCalculator();
  final _panelCalculator = PanelCalculator();
  final _linearCalculator = LinearCalculator();
  final _areaCalculator = AreaCalculator();
  final _rollsCalculator = RollsCalculator();
  final _coverageCalculator = CoverageCalculator();
  final _piecesCalculator = PiecesCalculator();
  final _framesCalculator = FramesCalculator();

  /// Calculate based on the input mode.
  CalcOutput calculate(CalcInput input) {
    return switch (input.mode) {
      CalcMode.rod => _rodCalculator.calculate(input),
      CalcMode.panel => _panelCalculator.calculate(input),
      CalcMode.linearMeter => _linearCalculator.calculate(input),
      CalcMode.squareMeter => _areaCalculator.calculate(input),
      CalcMode.mixed => _calculateMixed(input),
      CalcMode.rolls => _rollsCalculator.calculate(input),
      CalcMode.coverage => _coverageCalculator.calculate(input),
      CalcMode.pieces => _piecesCalculator.calculate(input),
      CalcMode.frames => _framesCalculator.calculate(input),
    };
  }

  /// Mixed calculator — calculates main product + accessories.
  CalcOutput _calculateMixed(CalcInput input) {
    // For mixed mode, determine the best calculator based on available inputs
    if (input.effectiveCoverageWidth > 0 && input.pieceLength > 0) {
      return _rodCalculator.calculate(input);
    } else if (input.effectiveCoverageArea > 0) {
      return _panelCalculator.calculate(input);
    } else if (input.rollWidth > 0 && input.rollLength > 0) {
      return _rollsCalculator.calculate(input);
    } else if (input.coveragePerUnit > 0) {
      return _coverageCalculator.calculate(input);
    } else if (input.perimeter > 0) {
      return _linearCalculator.calculate(input);
    } else {
      return _areaCalculator.calculate(input);
    }
  }

  /// Determine the best CalcMode for a given product category.
  static CalcMode modeForCategory(String category) {
    switch (category) {
      // بدائل التشطيبات
      case 'بديل خشب':
        return CalcMode.rod;
      case 'بديل رخام':
      case 'شيبورد':
      case 'بديل حجر':
        return CalcMode.panel;
      
      // الخطي (الطولي)
      case 'كرانيش':
      case 'بيت نور':
      case 'وزرات':
      case 'إكسسوارات شيبورد':
      case 'فاصل شيبورد':
      case 'نهاية شيبورد':
      case 'فاصل رخام':
      case 'زوايا استانلس':
      case 'زوايا PVC':
        return CalcMode.linearMeter;

      // الخامات والتغطية
      case 'معجون':
      case 'لاصق سريع':
      case 'سيليكون عظم':
      case 'خامات مساعدة':
        return CalcMode.coverage;

      // البراويز (Frames)
      case 'بانوهات':
        return CalcMode.frames;

      // القطع (Pieces)
      case 'صرر':
      case 'إكسسوارات':
      case 'زوايا بانوه':
        return CalcMode.pieces;

      default:
        return CalcMode.squareMeter;
    }
  }

  /// Validate inputs before calculation.
  List<String> validateInput(CalcInput input) {
    final errors = <String>[];

    switch (input.mode) {
      case CalcMode.rod:
        if (input.wallLength <= 0) errors.add('يجب إدخال طول الحائط');
        if (input.wallHeight <= 0) errors.add('يجب إدخال ارتفاع الحائط');
        if (input.effectiveCoverageWidth <= 0) {
          errors.add('يجب إدخال عرض التغطية الفعلي');
        }
        if (input.pieceLength <= 0) errors.add('يجب إدخال طول العود');
        break;

      case CalcMode.panel:
        if (input.directArea == null || input.directArea! <= 0) {
          if (input.wallLength <= 0) {
            errors.add('يجب إدخال طول الحائط أو المساحة');
          }
          if (input.wallHeight <= 0) {
            errors.add('يجب إدخال ارتفاع الحائط أو المساحة');
          }
        }
        if (input.effectiveCoverageArea <= 0 && (input.pieceLength <= 0 || input.pieceWidth <= 0)) {
          errors.add('يجب إدخال أبعاد اللوح (الطول والعرض) أو مساحة تغطية اللوح');
        }
        break;

      case CalcMode.linearMeter:
        if (input.perimeter <= 0 && input.wallLength <= 0) {
          errors.add('يجب إدخال المحيط أو طول الحائط');
        }
        break;

      case CalcMode.squareMeter:
        if (input.directArea == null || input.directArea! <= 0) {
          if (input.wallLength <= 0) {
            errors.add('يجب إدخال طول الحائط أو المساحة');
          }
          if (input.wallHeight <= 0) {
            errors.add('يجب إدخال ارتفاع الحائط أو المساحة');
          }
        }
        break;

      case CalcMode.rolls:
        if (input.wallLength <= 0) errors.add('يجب إدخال طول الحائط');
        if (input.wallHeight <= 0) errors.add('يجب إدخال ارتفاع الحائط');
        if (input.rollWidth <= 0) errors.add('يجب إدخال عرض الرول');
        if (input.rollLength <= 0) errors.add('يجب إدخال طول الرول');
        break;

      case CalcMode.coverage:
        if ((input.directArea == null || input.directArea! <= 0) &&
            (input.wallLength <= 0 || input.wallHeight <= 0)) {
          errors.add('يجب إدخال المساحة أو أبعاد الحائط');
        }
        if (input.coveragePerUnit <= 0) {
          errors.add('يجب إدخال مساحة تغطية العبوة');
        }
        break;

      case CalcMode.frames:
        if (input.frameWidth <= 0) errors.add('يجب إدخال عرض البرواز');
        if (input.frameHeight <= 0) errors.add('يجب إدخال ارتفاع البرواز');
        if (input.frameCount <= 0) errors.add('يجب إدخال عدد البراويز');
        if (input.pieceLength <= 0) errors.add('يجب إدخال طول العود');
        break;
        
      case CalcMode.pieces:
        if (input.quantity <= 0) errors.add('يجب إدخال الكمية');
        break;

      case CalcMode.mixed:
        // Minimal validation for mixed mode
        break;
    }

    if (input.wastePercent < 0 || input.wastePercent > 0.5) {
      errors.add('نسبة الهالك يجب أن تكون بين 0% و 50%');
    }

    return errors;
  }
}
