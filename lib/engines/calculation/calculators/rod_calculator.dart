import 'package:stream_pay/core/constants/unit_types.dart';
import '../models/calc_input.dart';
import '../models/calc_output.dart';

/// Helper class to represent a vertical or horizontal segment interval.
class _Interval {
  final double start;
  final double end;
  _Interval(this.start, this.end);
  double get length => end - start;
}

/// Calculator for rod/plank products (بديل خشب، WPC، PVC).
///
/// Supports both vertical and horizontal installation orientations.
/// Implements a 1D Bin Packing (Best-Fit Decreasing) optimization algorithm
/// when smart wall layout is enabled, allowing TV and concrete beam deductions.
class RodCalculator {
  CalcOutput calculate(CalcInput input) {
    if (input.effectiveCoverageWidth <= 0 || input.pieceLength <= 0) {
      return const CalcOutput(warnings: ['يرجى إدخال عرض التغطية وطول العود']);
    }

    if (input.useSmartLayout) {
      return _calculateSmart(input);
    }

    final steps = <String>[];
    final warnings = <String>[];

    // Calculate gross area per wall
    final grossAreaPerWall = input.wallLength * input.wallHeight;
    final totalGrossArea = grossAreaPerWall * input.wallCount;
    steps.add(
      'المساحة الإجمالية = ${(input.wallLength * 100).toStringAsFixed(0)}سم × ${(input.wallHeight * 100).toStringAsFixed(0)}سم × ${input.wallCount} = ${totalGrossArea.toStringAsFixed(2)} م²',
    );

    // Calculate openings area
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

    int totalRods;

    if (input.orientation == InstallationOrientation.vertical) {
      // Vertical installation — PRD formula 11.4:
      final linesPerWall = (input.wallLength / input.effectiveCoverageWidth)
          .ceil();
      final rodsPerLine = (input.wallHeight / input.pieceLength).ceil();
      totalRods = linesPerWall * rodsPerLine * input.wallCount;

      steps.add(
        'تركيب رأسي: عدد الخطوط = ${(input.wallLength * 100).toStringAsFixed(0)}سم ÷ ${(input.effectiveCoverageWidth * 100).toStringAsFixed(1)}سم = $linesPerWall',
      );
      steps.add(
        'أعواد لكل خط = ${(input.wallHeight * 100).toStringAsFixed(0)}سم ÷ ${(input.pieceLength * 100).toStringAsFixed(0)}سم = $rodsPerLine',
      );
      steps.add(
        'الإجمالي = $linesPerWall × $rodsPerLine × ${input.wallCount} = $totalRods عود',
      );
    } else {
      // Horizontal installation — PRD formula 11.5:
      final rowsPerWall = (input.wallHeight / input.effectiveCoverageWidth)
          .ceil();
      final rodsPerRow = (input.wallLength / input.pieceLength).ceil();
      totalRods = rowsPerWall * rodsPerRow * input.wallCount;

      steps.add(
        'تركيب أفقي: عدد الصفوف = ${(input.wallHeight * 100).toStringAsFixed(0)}سم ÷ ${(input.effectiveCoverageWidth * 100).toStringAsFixed(1)}سم = $rowsPerWall',
      );
      steps.add(
        'أعواد لكل صف = ${(input.wallLength * 100).toStringAsFixed(0)}سم ÷ ${(input.pieceLength * 100).toStringAsFixed(0)}سم = $rodsPerRow',
      );
      steps.add(
        'الإجمالي = $rowsPerWall × $rodsPerRow × ${input.wallCount} = $totalRods عود',
      );
    }

    // Apply waste
    final wasteRods = (totalRods * input.wastePercent).ceil();
    final totalWithWaste = totalRods + wasteRods;
    steps.add(
      'الهالك (${(input.wastePercent * 100).toStringAsFixed(0)}%) = $wasteRods عود',
    );
    steps.add('الإجمالي بعد الهالك = $totalWithWaste عود');

    // Calculate boxes if applicable
    int boxesNeeded = totalWithWaste;
    String unitLabel = 'عود';
    if (input.piecesPerBox > 1) {
      boxesNeeded = (totalWithWaste / input.piecesPerBox).ceil();
      steps.add(
          'عدد الكراتين = $totalWithWaste ÷ ${input.piecesPerBox} = $boxesNeeded كرتونة');
      unitLabel = 'عود ($boxesNeeded كرتونة)';
    }

    // Calculate coverage
    final totalCoverage =
        totalWithWaste * input.pieceLength * input.effectiveCoverageWidth;

    // Warnings
    if (input.wastePercent < 0.05) {
      warnings.add('⚠️ نسبة الهالك منخفضة جدًا، قد لا تكفي الكمية');
    }
    if (input.pieceLength < input.wallHeight &&
        input.orientation == InstallationOrientation.vertical) {
      warnings.add(
        'ℹ️ طول العود أقل من ارتفاع الحائط — سيتم استخدام أكثر من عود لكل خط',
      );
    }

    return CalcOutput(
      grossArea: totalGrossArea,
      openingsArea: openingsArea,
      netArea: totalGrossArea - openingsArea,
      baseQuantity: totalRods.toDouble(),
      quantityWithWaste: totalWithWaste.toDouble(),
      unitsNeeded: totalWithWaste,
      unitLabel: unitLabel,
      wastePercent: input.wastePercent,
      wasteQuantity: wasteRods.toDouble(),
      totalCoverage: totalCoverage,
      warnings: warnings,
      calculationSteps: steps,
    );
  }

  /// Calculates wall cladding using 1D Cutting Stock optimization (Smart Wall Layout).
  CalcOutput _calculateSmart(CalcInput input) {
    final steps = <String>[];
    final warnings = <String>[];

    // Compute gross dimensions and area
    final grossArea = input.wallLength * input.wallHeight * input.wallCount;
    steps.add(
      'مخطط ذكي: المساحة الإجمالية = ${(input.wallLength * 100).toStringAsFixed(0)}سم × ${(input.wallHeight * 100).toStringAsFixed(0)}سم × ${input.wallCount} = ${grossArea.toStringAsFixed(2)} م²',
    );

    // Setup TV coordinates
    final hasTv = input.smartHasTv && input.smartTvWidth > 0 && input.smartTvHeight > 0;
    double tvWidth = input.smartTvWidth;
    double tvHeight = input.smartTvHeight;
    double tvPosX = input.smartTvPosX;
    double tvPosY = input.smartTvPosY;

    // Default positions if centered
    if (hasTv) {
      if (tvPosX <= 0) {
        tvPosX = (input.wallLength - tvWidth) / 2;
        if (tvPosX < 0) tvPosX = 0;
      }
      if (tvPosY <= 0) {
        // Center vertically in the wall (excluding beam)
        final availableHeight = input.wallHeight - input.smartBeamHeight;
        tvPosY = (availableHeight - tvHeight) / 2;
        if (tvPosY < 0) tvPosY = 0;
      }
      steps.add(
        'الشاشة المكتشفة: عرض ${(tvWidth * 100).toStringAsFixed(0)}سم × ارتفاع ${(tvHeight * 100).toStringAsFixed(0)}سم في الموضع (س=${(tvPosX * 100).toStringAsFixed(0)}سم، ص=${(tvPosY * 100).toStringAsFixed(0)}سم)',
      );
    }

    // Setup Beam coordinates
    final beamHeight = input.smartBeamHeight;
    final beamStart = input.wallHeight - beamHeight;
    final beamEnd = input.wallHeight;
    if (beamHeight > 0) {
      steps.add(
        'الكمرة الخرسانية: ارتفاع ${(beamHeight * 100).toStringAsFixed(0)}سم في أعلى الحائط ${input.smartCoverBeam ? "(مغطاة)" : "(غير مغطاة)"}',
      );
    }

    final rawRequiredPieces = <double>[];

    if (input.orientation == InstallationOrientation.vertical) {
      // 1. Divider for vertical columns
      final cols = (input.wallLength / input.effectiveCoverageWidth).ceil();
      steps.add(
        'التركيب رأسي: تقسيم الحائط إلى $cols عمود بعرض ${(input.effectiveCoverageWidth * 100).toStringAsFixed(1)}سم',
      );

      for (int c = 0; c < cols; c++) {
        final colStart = c * input.effectiveCoverageWidth;
        final colEnd = colStart + input.effectiveCoverageWidth;

        // Base active span is floor to top of wall
        var activeSpans = [_Interval(0, input.wallHeight)];

        // A. Handle concrete beam deduction if not covered
        if (beamHeight > 0 && !input.smartCoverBeam) {
          activeSpans = _deductInterval(activeSpans, beamStart, beamEnd);
        }

        // B. Handle TV overlap
        final overlapsTv = hasTv && colStart < tvPosX + tvWidth && colEnd > tvPosX;
        if (overlapsTv) {
          // Always deduct the TV screen itself
          activeSpans = _deductInterval(activeSpans, tvPosY, tvPosY + tvHeight);

          // If cover below screen is false, deduct below screen
          if (!input.smartCoverBelowTv) {
            activeSpans = _deductInterval(activeSpans, 0, tvPosY);
          }
          // If cover above screen is false, deduct above screen to beam
          if (!input.smartCoverAboveTv) {
            activeSpans = _deductInterval(activeSpans, tvPosY + tvHeight, beamStart);
          }
        }

        // Add calculated spans to required pieces list
        for (final span in activeSpans) {
          if (span.length > 0.01) {
            rawRequiredPieces.add(span.length);
          }
        }
      }
    } else {
      // 2. Divider for horizontal rows
      final rows = (input.wallHeight / input.effectiveCoverageWidth).ceil();
      steps.add(
        'التركيب أفقي: تقسيم الحائط إلى $rows صف بارتفاع ${(input.effectiveCoverageWidth * 100).toStringAsFixed(1)}سم',
      );

      for (int r = 0; r < rows; r++) {
        final rowStart = r * input.effectiveCoverageWidth;
        final rowEnd = rowStart + input.effectiveCoverageWidth;

        // Base horizontal span
        var activeSpans = [_Interval(0, input.wallLength)];

        // A. Handle concrete beam deduction
        final overlapsBeam = rowStart < beamEnd && rowEnd > beamStart;
        if (overlapsBeam && !input.smartCoverBeam) {
          // Deduct full width since beam spans the entire wall length
          activeSpans = [];
        }

        // B. Handle TV overlap
        final overlapsTvY = hasTv && rowStart < tvPosY + tvHeight && rowEnd > tvPosY;
        if (overlapsTvY) {
          activeSpans = _deductInterval(activeSpans, tvPosX, tvPosX + tvWidth);
        }

        // C. Check below / above TV visibility constraints
        if (hasTv) {
          final isBelowTv = rowEnd <= tvPosY;
          final isAboveTv = rowStart >= tvPosY + tvHeight && rowEnd <= beamStart;
          if (isBelowTv && !input.smartCoverBelowTv) {
            activeSpans = [];
          }
          if (isAboveTv && !input.smartCoverAboveTv) {
            activeSpans = [];
          }
        }

        // Add calculated spans to required pieces list
        for (final span in activeSpans) {
          if (span.length > 0.01) {
            rawRequiredPieces.add(span.length);
          }
        }
      }
    }

    // Duplicate pieces for wallCount
    final allRequiredPieces = <double>[];
    for (int w = 0; w < input.wallCount; w++) {
      allRequiredPieces.addAll(rawRequiredPieces);
    }

    // Preprocess: split any piece longer than the raw rod length
    final finalizedPieces = <double>[];
    int splitCount = 0;
    for (final piece in allRequiredPieces) {
      if (piece > input.pieceLength) {
        splitCount++;
        double remaining = piece;
        while (remaining > input.pieceLength) {
          finalizedPieces.add(input.pieceLength);
          remaining -= input.pieceLength;
        }
        if (remaining > 0.01) {
          finalizedPieces.add(remaining);
        }
      } else {
        finalizedPieces.add(piece);
      }
    }

    if (splitCount > 0) {
      warnings.add(
        'ℹ️ تم تقسيم $splitCount قطعة لأن طولها يتجاوز طول العود الخام (${(input.pieceLength * 100).toStringAsFixed(0)}سم)',
      );
    }

    // Calculate net cladding area
    final double netCladdingArea = allRequiredPieces.fold(0.0, (sum, p) => sum + p) * input.effectiveCoverageWidth;
    final double openingsArea = grossArea - netCladdingArea;

    // Run Bin Packing Optimization
    final bins = _optimizeCuts(finalizedPieces, input.pieceLength);

    steps.add(
      'تحسين التقطيع: إجمالي القطع المطلوبة = ${finalizedPieces.length} قطعة، تم توزيعها على ${bins.length} عود خام.',
    );

    // Apply safety waste percent
    final wasteRods = (bins.length * input.wastePercent).ceil();
    final totalRods = bins.length + wasteRods;

    if (wasteRods > 0) {
      steps.add(
        'هالك أمان إضافي (${(input.wastePercent * 100).toStringAsFixed(0)}%) = $wasteRods عود',
      );
      steps.add('إجمالي الأعواد المطلوبة = $totalRods عود');
    } else {
      steps.add('إجمالي الأعواد المطلوبة = $totalRods عود (بدون هالك أمان إضافي)');
    }

    // Calculate boxes if applicable
    int boxesNeeded = totalRods;
    String unitLabel = 'عود';
    if (input.piecesPerBox > 1) {
      boxesNeeded = (totalRods / input.piecesPerBox).ceil();
      steps.add(
          'عدد الكراتين = $totalRods ÷ ${input.piecesPerBox} = $boxesNeeded كرتونة');
      unitLabel = 'عود ($boxesNeeded كرتونة)';
    }

    // Calculate coverage
    final totalCoverage = totalRods * input.pieceLength * input.effectiveCoverageWidth;

    // Generate detailed cutting instructions
    final cuttingInstructions = <String>[];
    for (int i = 0; i < bins.length; i++) {
      final cuts = bins[i];
      final sumCuts = cuts.fold(0.0, (sum, c) => sum + c);
      final leftover = input.pieceLength - sumCuts;
      final cutsString = cuts.map((c) => '${(c * 100).toStringAsFixed(0)}سم').join(' + ');
      cuttingInstructions.add(
        'العود ${i + 1}: قطع [$cutsString] (المتبقي: ${(leftover * 100).toStringAsFixed(0)}سم)',
      );
    }

    // Calculate efficiency (Total needed length / Total purchased raw length of optimized rods)
    final double totalNeededLength = finalizedPieces.fold(0.0, (sum, p) => sum + p);
    final double totalOptimizedRawLength = bins.length * input.pieceLength;
    final double efficiency = totalOptimizedRawLength > 0 ? totalNeededLength / totalOptimizedRawLength : 0.0;

    return CalcOutput(
      grossArea: grossArea,
      openingsArea: openingsArea,
      netArea: netCladdingArea,
      baseQuantity: bins.length.toDouble(),
      quantityWithWaste: totalRods.toDouble(),
      unitsNeeded: totalRods,
      unitLabel: unitLabel,
      wastePercent: input.wastePercent,
      wasteQuantity: wasteRods.toDouble(),
      totalCoverage: totalCoverage,
      warnings: warnings,
      calculationSteps: steps,
      cuttingInstructions: cuttingInstructions,
      rodCuts: bins,
      optimizationEfficiency: efficiency,
    );
  }

  /// Deducts an interval [dStart, dEnd] from a list of active intervals.
  List<_Interval> _deductInterval(List<_Interval> active, double dStart, double dEnd) {
    final result = <_Interval>[];
    for (final interval in active) {
      if (dEnd <= interval.start || dStart >= interval.end) {
        // No overlap
        result.add(interval);
      } else if (dStart <= interval.start && dEnd >= interval.end) {
        // Complete overlap (fully removed)
      } else if (dStart > interval.start && dEnd < interval.end) {
        // Split into two intervals
        result.add(_Interval(interval.start, dStart));
        result.add(_Interval(dEnd, interval.end));
      } else if (dStart > interval.start && dStart < interval.end) {
        // Deduct from end
        result.add(_Interval(interval.start, dStart));
      } else if (dEnd > interval.start && dEnd < interval.end) {
        // Deduct from start
        result.add(_Interval(dEnd, interval.end));
      }
    }
    return result;
  }

  /// 1D Bin Packing (Best-Fit Decreasing) Algorithm.
  List<List<double>> _optimizeCuts(List<double> requiredPieces, double binCapacity) {
    // Sort required pieces in descending order
    final pieces = List<double>.from(requiredPieces)..sort((a, b) => b.compareTo(a));

    final bins = <List<double>>[];
    final binRemaining = <double>[];

    for (final piece in pieces) {
      if (piece <= 0) continue;

      // Find the best bin (smallest remaining capacity that can still fit the piece)
      int bestBinIndex = -1;
      double minRemainingAfter = double.infinity;

      for (int i = 0; i < bins.length; i++) {
        if (binRemaining[i] >= piece - 0.001) {
          final remainingAfter = binRemaining[i] - piece;
          if (remainingAfter < minRemainingAfter) {
            minRemainingAfter = remainingAfter;
            bestBinIndex = i;
          }
        }
      }

      if (bestBinIndex != -1) {
        bins[bestBinIndex].add(piece);
        binRemaining[bestBinIndex] -= piece;
      } else {
        bins.add([piece]);
        binRemaining.add(binCapacity - piece);
      }
    }

    return bins;
  }
}
