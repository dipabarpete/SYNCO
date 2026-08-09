import 'package:flutter/material.dart';

/// Crisp native Google 'G' icon component with official brand colors.
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({
    super.key,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double strokeWidth = width * 0.22;
    final Offset center = Offset(width / 2, height / 2);
    final double radius = (width - strokeWidth) / 2;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red arc (top-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.356, // -135 degrees in radians
      1.57,   // 90 degrees
      false,
      paint,
    );

    // Yellow arc (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.785, // -45 degrees
      -1.57,  // -90 degrees
      false,
      paint,
    );

    // Green arc (bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.785,  // 45 degrees
      1.57,   // 90 degrees
      false,
      paint,
    );

    // Blue arc & bar (right side)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.785, // -45 degrees
      0.785,  // 45 degrees
      false,
      paint,
    );

    // Blue horizontal bar
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final double barWidth = width * 0.45;
    final double barHeight = strokeWidth * 0.9;
    final Rect barRect = Rect.fromLTWH(
      center.dx,
      center.dy - barHeight / 2,
      barWidth,
      barHeight,
    );
    canvas.drawRect(barRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
