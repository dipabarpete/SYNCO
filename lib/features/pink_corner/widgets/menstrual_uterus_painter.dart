import 'package:flutter/material.dart';

/// A simplified, friendly uterus diagram (non-graphic).
///
/// Draws the uterus body with two small ovaries and gentle connecting
/// lines, entirely in pastel colors with rounded shapes.
class SimpleUterusPainter extends CustomPainter {
  final Color bodyColor;
  final Color outlineColor;
  final Color ovaryColor;

  const SimpleUterusPainter({
    this.bodyColor = const Color(0xFFFFC9D6),
    this.outlineColor = const Color(0xFFC94A6E),
    this.ovaryColor = const Color(0xFFE8A33D),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    final ovaryPaint = Paint()..color = ovaryColor;

    // Ovaries
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.18, h * 0.34),
        width: w * 0.20,
        height: h * 0.13,
      ),
      ovaryPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.82, h * 0.34),
        width: w * 0.20,
        height: h * 0.13,
      ),
      ovaryPaint,
    );

    // Fallopian tubes (gentle lines to the uterus)
    final tubePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.032
      ..strokeCap = StrokeCap.round;
    final leftTube = Path()
      ..moveTo(w * 0.28, h * 0.33)
      ..quadraticBezierTo(w * 0.36, h * 0.22, w * 0.42, h * 0.26);
    final rightTube = Path()
      ..moveTo(w * 0.72, h * 0.33)
      ..quadraticBezierTo(w * 0.64, h * 0.22, w * 0.58, h * 0.26);
    canvas.drawPath(leftTube, tubePaint);
    canvas.drawPath(rightTube, tubePaint);

    // Uterus body (inverted pear)
    final body = Path()
      ..moveTo(w * 0.42, h * 0.26)
      ..quadraticBezierTo(w * 0.46, h * 0.10, w * 0.50, h * 0.10)
      ..quadraticBezierTo(w * 0.54, h * 0.10, w * 0.58, h * 0.26)
      ..quadraticBezierTo(w * 0.90, h * 0.40, w * 0.78, h * 0.62)
      ..quadraticBezierTo(w * 0.72, h * 0.80, w * 0.50, h * 0.86)
      ..quadraticBezierTo(w * 0.28, h * 0.80, w * 0.22, h * 0.62)
      ..quadraticBezierTo(w * 0.10, h * 0.40, w * 0.42, h * 0.26)
      ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, outlinePaint);

    // Gentle lining highlight inside the uterus
    final liningPaint = Paint()
      ..color = bodyColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final lining = Path()
      ..moveTo(w * 0.38, h * 0.30)
      ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.62, h * 0.30)
      ..quadraticBezierTo(w * 0.66, h * 0.55, w * 0.50, h * 0.66)
      ..quadraticBezierTo(w * 0.34, h * 0.55, w * 0.38, h * 0.30)
      ..close();
    canvas.drawPath(lining, liningPaint);
  }

  @override
  bool shouldRepaint(covariant SimpleUterusPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.outlineColor != outlineColor ||
      oldDelegate.ovaryColor != ovaryColor;
}