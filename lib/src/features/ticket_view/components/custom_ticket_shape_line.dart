import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../styles/styles.dart';

class CustomTicketShapeLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ticket shape
    final path_0 = Path()
      ..moveTo(0, size.height)
      ..cubicTo(
        size.width * 0.03052839,
        size.height,
        size.width * 0.05527638,
        size.height * 0.7761432,
        size.width * 0.05527638,
        size.height * 0.5000000,
      )
      ..cubicTo(
        size.width * 0.05527638,
        size.height * 0.2238577,
        size.width * 0.03052839,
        0,
        0,
        0,
      )
      ..lineTo(size.width, 0)
      ..cubicTo(
        size.width * 0.9694724,
        0,
        size.width * 0.9447236,
        size.height * 0.2238577,
        size.width * 0.9447236,
        size.height * 0.5000000,
      )
      ..cubicTo(
        size.width * 0.9447236,
        size.height * 0.7761432,
        size.width * 0.9694724,
        size.height,
        size.width,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    // Fill ticket
    final paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = AppColor.periwinkleBlue;
    canvas.drawPath(path_0, paint0Fill);

    // Dashed (hyphen) center divider
    DashedLinePainter(
      padding: 40,
      dashLength: 8, // length of each hyphen
      dashGap: 6, // gap between hyphens
      strokeWidth: 1,
      alignToEnds: true,
      color: Shades.s0,
      cap: StrokeCap.butt, // use .round if you want rounded hyphens
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DashedLinePainter extends CustomPainter {
  final double padding;
  final double dashLength;
  final double dashGap;
  final double strokeWidth;
  final bool alignToEnds;
  final StrokeCap cap;
  final Paint linePaint;

  DashedLinePainter({
    this.padding = 0.0,
    this.dashLength = 8.0,
    this.dashGap = 6.0,
    this.strokeWidth = 1.0,
    this.alignToEnds = true,
    this.cap = StrokeCap.butt,
    Color? color,
  }) : linePaint = Paint()
          ..color = color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = cap
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal center
    final double y = size.height / 2;

    // Keep within padding
    final double xStart = padding.clamp(0.0, size.width);
    final double xEnd = (size.width - padding).clamp(0.0, size.width);
    if (xEnd <= xStart || dashLength <= 0) return;

    final double step = dashLength + dashGap;
    final double length = xEnd - xStart;

    if (alignToEnds) {
      // Compute a centered sequence so the hyphens look even at both ends
      final int count = math.max(1, ((length + dashGap) / step).floor());
      final double used = (count * dashLength) + ((count - 1) * dashGap);
      final double offset = (length - used) / 2.0;

      for (int i = 0; i < count; i++) {
        final double sx = xStart + offset + (i * step);
        final double ex = math.min(sx + dashLength, xEnd);
        canvas.drawLine(Offset(sx, y), Offset(ex, y), linePaint);
      }
    } else {
      for (double sx = xStart; sx < xEnd; sx += step) {
        final double ex = math.min(sx + dashLength, xEnd);
        canvas.drawLine(Offset(sx, y), Offset(ex, y), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter old) =>
      padding != old.padding ||
      dashLength != old.dashLength ||
      dashGap != old.dashGap ||
      strokeWidth != old.strokeWidth ||
      alignToEnds != old.alignToEnds ||
      cap != old.cap ||
      linePaint.color != old.linePaint.color;
}
