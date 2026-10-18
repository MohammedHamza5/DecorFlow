import 'package:flutter/material.dart';

class CutPiece {
  final double width;
  final double height;
  final String label;

  CutPiece({
    required this.width,
    required this.height,
    required this.label,
  });
}

class PlacedPiece {
  final CutPiece piece;
  final Rect rect; // Position and size on the sheet

  PlacedPiece({
    required this.piece,
    required this.rect,
  });
}

class SheetResult {
  final double width;
  final double height;
  final List<PlacedPiece> placedPieces;
  final List<Rect> freeRects;
  final double wasteArea;
  final double efficiency;

  SheetResult({
    required this.width,
    required this.height,
    required this.placedPieces,
    required this.freeRects,
    required this.wasteArea,
    required this.efficiency,
  });
}

class CuttingOptimizer {
  /// Optimizes the cutting of a list of pieces from standard sheets of size [sheetWidth] x [sheetHeight].
  /// Returns a list of [SheetResult] objects, where each represents a standard sheet and how it is cut.
  static List<SheetResult> optimize({
    required double sheetWidth,
    required double sheetHeight,
    required List<CutPiece> piecesToCut,
  }) {
    final List<SheetResult> sheets = [];
    
    // Sort pieces by area descending for a better pack rate (First-Fit Decreasing)
    final List<CutPiece> remainingPieces = List.from(piecesToCut)
      ..sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));

    while (remainingPieces.isNotEmpty) {
      final List<PlacedPiece> placed = [];
      final List<Rect> freeSpaces = [Rect.fromLTWH(0, 0, sheetWidth, sheetHeight)];

      // Try to pack as many pieces as possible in the current sheet
      for (int i = 0; i < remainingPieces.length; i++) {
        final piece = remainingPieces[i];
        int bestSpaceIndex = -1;
        bool rotate = false;

        // Try to find a space that fits the piece (either normal or rotated)
        for (int j = 0; j < freeSpaces.length; j++) {
          final space = freeSpaces[j];
          if (space.width >= piece.width && space.height >= piece.height) {
            bestSpaceIndex = j;
            rotate = false;
            break;
          } else if (space.width >= piece.height && space.height >= piece.width) {
            bestSpaceIndex = j;
            rotate = true;
            break;
          }
        }

        if (bestSpaceIndex != -1) {
          final space = freeSpaces.removeAt(bestSpaceIndex);
          final pWidth = rotate ? piece.height : piece.width;
          final pHeight = rotate ? piece.width : piece.height;

          // Place the piece
          placed.add(
            PlacedPiece(
              piece: piece,
              rect: Rect.fromLTWH(space.left, space.top, pWidth, pHeight),
            ),
          );

          // Perform Guillotine Split of the remaining space
          // We split the remainder of the rectangle into two sub-rectangles:
          // one to the right, and one to the bottom of the placed piece.
          final rightSpace = Rect.fromLTWH(
            space.left + pWidth,
            space.top,
            space.width - pWidth,
            pHeight,
          );
          final bottomSpace = Rect.fromLTWH(
            space.left,
            space.top + pHeight,
            space.width,
            space.height - pHeight,
          );

          if (rightSpace.width > 0.1 && rightSpace.height > 0.1) {
            freeSpaces.add(rightSpace);
          }
          if (bottomSpace.width > 0.1 && bottomSpace.height > 0.1) {
            freeSpaces.add(bottomSpace);
          }

          // Sort free spaces to prioritize smaller/thinner spaces first (Best-Fit)
          freeSpaces.sort((a, b) => (a.width * a.height).compareTo(b.width * b.height));

          // Remove the piece from remaining list
          remainingPieces.removeAt(i);
          i--; // Adjust index due to removal
        }
      }

      // Calculate sheet metrics
      final sheetArea = sheetWidth * sheetHeight;
      double placedArea = 0.0;
      for (final p in placed) {
        placedArea += p.rect.width * p.rect.height;
      }
      final wasteArea = sheetArea - placedArea;
      final efficiency = placedArea / sheetArea;

      sheets.add(
        SheetResult(
          width: sheetWidth,
          height: sheetHeight,
          placedPieces: placed,
          freeRects: freeSpaces,
          wasteArea: wasteArea,
          efficiency: efficiency,
        ),
      );

      // Safety check: if no pieces could be placed, break to avoid infinite loop
      if (placed.isEmpty && remainingPieces.isNotEmpty) {
        // This piece is larger than the sheet, skip it
        remainingPieces.removeAt(0);
      }
    }

    return sheets;
  }
}
