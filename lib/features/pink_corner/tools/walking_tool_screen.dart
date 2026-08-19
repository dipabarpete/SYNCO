import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Walking tool — explains gentle walking with a calm animated path.
///
/// Walking is presented as a simple way some people find helpful for
/// movement, routine, and well-being — never as an excessive prescription.
class WalkingToolScreen extends StatefulWidget {
  const WalkingToolScreen({super.key});

  @override
  State<WalkingToolScreen> createState() => _WalkingToolScreenState();
}

const _mintDeep = Color(0xFF2E8B76);
const _mintLight = Color(0xFFE9F7F1);

class _WalkingToolScreenState extends State<WalkingToolScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _tips = [
    ('Start small', 'Even 5–10 minutes counts. A little, often, beats a lot, rarely.'),
    ('A comfortable pace', 'A pace where you can still talk easily is perfect.'),
    ('No gear needed', 'Comfortable shoes and a regular path are more than enough.'),
    ('Notice as you go', 'Look around, feel the air, let thoughts drift.'),
    ('Pair it with breathing', 'A few slow breaths in rhythm with your steps feels lovely.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Walking',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animated calm path
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _mintLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _mintDeep.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'A gentle stroll',
                    style: GoogleFonts.outfit(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: _mintDeep,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Watch the dot make its way along the path. Your walk can look exactly like this — easy and unhurried.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 150,
                    child: CustomPaint(
                      painter: _PathPainter(progress: _controller),
                      size: const Size(double.infinity, 150),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Why walking can help',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Walking is simple movement with a quiet rhythm. Many people find it helps clear '
              'their thoughts, give structure to a day, and make stress feel a little lighter — '
              'and it works as well outdoors as it does around the house.',
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Tips
            for (var i = 0; i < _tips.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.7),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _mintLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: _mintDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tips[i].$1,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tips[i].$2,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              height: 1.45,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD8B4F8).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.softPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'There\u2019s no required distance or pace. Listen to your body — '
                      'any comfortable movement counts.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.45,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a calm winding path with a small walker-dot that travels along it.
class _PathPainter extends CustomPainter {
  final Animation<double> progress;

  _PathPainter({required this.progress}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final grass = Paint()..color = _mintLight;
    canvas.drawRect(Offset.zero & size, grass);

    final path = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(
        size.width * 0.25, size.height * 0.3,
        size.width * 0.5, size.height * 0.9,
        size.width * 0.75, size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.88, size.height * 0.38,
        size.width * 0.95, size.height * 0.42,
        size.width, size.height * 0.34,
      );

    final trailPaint = Paint()
      ..color = const Color(0xFFB5EAD7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, trailPaint);

    final metric = path.computeMetrics().first;
    final linePaint = Paint()
      ..color = const Color(0xFF45B69C).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Dashed centre line
    const dash = 8.0;
    const gap = 7.0;
    var distance = 0.0;
    while (distance < metric.length) {
      final end = math.min(distance + dash, metric.length);
      final startTangent = metric.getTangentForOffset(distance);
      final endTangent = metric.getTangentForOffset(end);
      if (startTangent != null && endTangent != null) {
        canvas.drawLine(startTangent.position, endTangent.position, linePaint);
      }
      distance += dash + gap;
    }

    // Trees along the path
    _drawTree(canvas, size.width * 0.12, size.height * 0.22);
    _drawTree(canvas, size.width * 0.85, size.height * 0.1);

    // Walk = soft, warm sun
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.06),
      14,
      Paint()..color = const Color(0xFFFFB085).withValues(alpha: 0.5),
    );

    // Walker dot along the path
    final walkDistance = metric.length * progress.value;
    final walkTangent = metric.getTangentForOffset(walkDistance);
    final position = walkTangent?.position ?? Offset.zero;
    canvas.drawCircle(position, 12, Paint()..color = _mintDeep.withValues(alpha: 0.25));
    canvas.drawCircle(position, 8, Paint()..color = const Color(0xFF2E8B76));
  }

  void _drawTree(Canvas canvas, double x, double y) {
    final trunk = Paint()..color = const Color(0xFFD8B4A0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y + 10),
          width: 5,
          height: 14,
        ),
        const Radius.circular(2),
      ),
      trunk,
    );
    final leaf = Paint()..color = const Color(0xFF7BC47F).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(x, y), 9, leaf);
    canvas.drawCircle(Offset(x - 6, y + 4), 6, leaf);
    canvas.drawCircle(Offset(x + 6, y + 4), 6, leaf);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => true;
}