import 'package:flutter/material.dart';
import '../../domain/cutting_optimizer.dart';

class CuttingCanvas extends StatelessWidget {
  final SheetResult result;

  const CuttingCanvas({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: result.width / result.height,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CuttingPainter(result: result),
        ),
      ),
    );
  }
}

class _CuttingPainter extends CustomPainter {
  final SheetResult result;

  _CuttingPainter({required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    // Scales to map the coordinates (in cm) to size (pixels)
    final scaleX = size.width / result.width;
    final scaleY = size.height / result.height;

    // Paints
    final borderPaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final piecePaint = Paint()
      ..color = Colors.blue.shade100
      ..style = PaintingStyle.fill;

    final wastePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
    );

    // 1. Draw waste/free spaces (gray background)
    for (final rect in result.freeRects) {
      final scaledRect = Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );
      canvas.drawRect(scaledRect, wastePaint);
      
      // Draw a thin gray border around free spaces
      final freeBorderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRect(scaledRect, freeBorderPaint);
    }

    // 2. Draw placed pieces (blue sheets)
    for (final placed in result.placedPieces) {
      final rect = placed.rect;
      final scaledRect = Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );

      // Fill piece
      canvas.drawRect(scaledRect, piecePaint);
      // Stroke border
      canvas.drawRect(scaledRect, borderPaint);

      // Label & Dimensions
      final textSpan = TextSpan(
        style: TextStyle(
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
          fontSize: size.width > 200 ? 10 : 8,
        ),
        text: '${placed.piece.label}\n${rect.width.toStringAsFixed(0)}x${rect.height.toStringAsFixed(0)} سم',
      );
      
      textPainter.text = textSpan;
      textPainter.layout(
        minWidth: 0,
        maxWidth: scaledRect.width - 4,
      );

      // Draw text in center of piece
      final textOffset = Offset(
        scaledRect.left + (scaledRect.width - textPainter.width) / 2,
        scaledRect.top + (scaledRect.height - textPainter.height) / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
