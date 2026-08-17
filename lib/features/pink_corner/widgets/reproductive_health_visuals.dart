import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/reproductive_health_topic.dart';

/// Dispatches the correct educational visual for a Reproductive Health topic.
class ReproductiveHealthVisual extends StatelessWidget {
  final ReproductiveHealthTopic topic;

  const ReproductiveHealthVisual({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    switch (topic.visualType) {
      case ReproductiveVisualType.anatomyDiagram:
        return AnatomyDiagramFrame(topic: topic);
      case ReproductiveVisualType.vulvaDiagram:
        return VulvaDiagramFrame(accentColor: topic.accentColor);
      case ReproductiveVisualType.hormoneCycleTimeline:
        return HormoneCycleTimelineFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.eggReleaseAnimation:
        return EggReleaseAnimationFrame(accentColor: topic.accentColor);
      case ReproductiveVisualType.eggSpermPathway:
        return EggSpermPathwayFrame(accentColor: topic.accentColor);
      case ReproductiveVisualType.fertileWindowTimeline:
        return FertileWindowTimelineFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.cycleComparison:
        return CycleComparisonFrame(accentColor: topic.accentColor);
      case ReproductiveVisualType.mythFactCards:
        return MythFactCards(myths: topic.myths);
      case ReproductiveVisualType.consentGuide:
        return ConsentGuideFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.safeSexIcons:
        return SafeSexIconsFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.testingAwareness:
        return TestingAwarenessFrame();
      case ReproductiveVisualType.methodComparison:
        return MethodComparisonFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.medicalCareGuide:
        return MedicalCareGuideFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.symptomComparison:
        return SymptomComparisonFrame(data: topic.visualData);
      case ReproductiveVisualType.bodyLocationMap:
        return BodyLocationMapFrame(accentColor: topic.accentColor);
      case ReproductiveVisualType.bleedingPatterns:
        return BleedingPatternsFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.careGuidance:
        return CareGuidanceFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.symptomChecklist:
        return SymptomChecklistFrame(data: topic.visualData, accentColor: topic.accentColor);
      case ReproductiveVisualType.trafficLightGuide:
        return TrafficLightGuideFrame(data: topic.visualData);
    }
  }
}

/// ---------------------------------------------------------------------------
/// Shared building blocks
/// ---------------------------------------------------------------------------

/// Card wrapper used by every educational visual, matching the app's
/// ArticleImageCard treatment (rounded 20 card + caption strip).
class _VisualCard extends StatelessWidget {
  final Widget child;
  final String? caption;

  const _VisualCard({required this.child, this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
          if (caption != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.babyPink.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.softPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      caption!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

IconData _iconForKey(String key) {
  switch (key) {
    case 'thumb':
      return Icons.thumb_up_alt_rounded;
    case 'hand':
      return Icons.front_hand_rounded;
    case 'change':
      return Icons.autorenew_rounded;
    case 'repeat':
      return Icons.replay_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'test':
      return Icons.biotech_rounded;
    case 'chat':
      return Icons.chat_bubble_outline_rounded;
    case 'consistent':
      return Icons.event_repeat_rounded;
    case 'pill':
      return Icons.medication_rounded;
    case 'iud':
      return Icons.track_changes_rounded;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'heavier':
      return Icons.water_drop_rounded;
    case 'between':
      return Icons.schedule_rounded;
    case 'after':
      return Icons.favorite_rounded;
    case 'longer':
      return Icons.calendar_month_rounded;
    default:
      return Icons.check_circle_outline_rounded;
  }
}

/// Small titled card used inside grids (safe sex, contraception, patterns…).
class _GridIconCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _GridIconCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 11, height: 1.35, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

/// Two-column grid of [_GridIconCard]s.
class _IconGrid extends StatelessWidget {
  final List<({IconData icon, String title, String description})> items;
  final Color accentColor;

  const _IconGrid({required this.items, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _GridIconCard(
                  icon: item.icon,
                  title: item.title,
                  description: item.description,
                  accentColor: accentColor,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Small "chip" used inside guides and legends.
class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const _Chip({required this.text, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.16) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// Myth vs Fact card — same treatment as the PMOS article.
class MythFactCards extends StatelessWidget {
  final List<ReproductiveMyth> myths;

  const MythFactCards({super.key, required this.myths});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final m in myths)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        m.myth,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.redAccent,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        m.fact,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Anatomy diagram (highlighted part, softly visible labels)
/// ---------------------------------------------------------------------------

class AnatomyDiagramFrame extends StatelessWidget {
  final ReproductiveHealthTopic topic;

  const AnatomyDiagramFrame({super.key, required this.topic});

  static const _parts = [
    ('Ovaries', 'ovaries'),
    ('Fallopian tubes', 'tubes'),
    ('Uterus', 'uterus'),
    ('Cervix', 'cervix'),
    ('Vagina', 'vagina'),
  ];

  @override
  Widget build(BuildContext context) {
    final highlight = topic.visualData?['highlight'] as String? ?? 'uterus';
    final partName = _parts.firstWhere(
      (p) => p.$2 == highlight,
      orElse: () => ('this part', highlight),
    ).$1;

    return _VisualCard(
      caption: 'A simple, labeled look at where the $partName sits in the reproductive system.',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: _PulsingCanvas(
              builder: (context, pulse) => CustomPaint(
                painter: _AnatomyPainter(highlight: highlight, accent: topic.accentColor, pulse: pulse),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final part in _parts)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: part.$2 == highlight
                        ? topic.accentColor.withValues(alpha: 0.14)
                        : const Color(0xFFF4EFFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: part.$2 == highlight
                          ? topic.accentColor.withValues(alpha: 0.6)
                          : AppColors.softPurple.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: part.$2 == highlight ? topic.accentColor : AppColors.softPurple.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        part.$1,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: part.$2 == highlight ? FontWeight.bold : FontWeight.w500,
                          color: part.$2 == highlight ? topic.accentColor : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingCanvas extends StatefulWidget {
  final Widget Function(BuildContext context, double pulse) builder;

  const _PulsingCanvas({required this.builder});

  @override
  State<_PulsingCanvas> createState() => _PulsingCanvasState();
}

class _PulsingCanvasState extends State<_PulsingCanvas> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => widget.builder(context, _controller.value),
    );
  }
}

/// Painter for the simplified internal-anatomy diagram.
///
/// Geometry is defined in fractional (0..1) coordinates so it scales safely
/// on any screen width.
class _AnatomyPainter extends CustomPainter {
  final String highlight;
  final Color accent;
  final double pulse;

  const _AnatomyPainter({required this.highlight, required this.accent, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    double fx(double x) => x * size.width;
    double fy(double y) => y * size.height;
    Offset p(double x, double y) => Offset(fx(x), fy(y));
    const strokeW = 1.6;

    Color fill(String part) => part == highlight
        ? accent.withValues(alpha: 0.30 + 0.14 * pulse)
        : const Color(0xFFE8DFF5);
    Color stroke(String part) => part == highlight
        ? accent.withValues(alpha: 0.80)
        : AppColors.softPurple.withValues(alpha: 0.35);

    // Fallopian tubes (behind everything else)
    final tubePaint = Paint()
      ..color = stroke('tubes')
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.014
      ..strokeCap = StrokeCap.round;
    final tubePath = Path()
      ..moveTo(fx(0.41), fy(0.46))
      ..quadraticBezierTo(fx(0.32), fy(0.42), fx(0.27), fy(0.39));
    canvas.drawPath(tubePath, tubePaint);
    final tubePath2 = Path()
      ..moveTo(fx(0.59), fy(0.46))
      ..quadraticBezierTo(fx(0.68), fy(0.42), fx(0.73), fy(0.39));
    canvas.drawPath(tubePath2, tubePaint);

    // Ovaries
    for (final ox in [0.24, 0.76]) {
      canvas.drawCircle(
        p(ox, 0.38),
        size.width * 0.05,
        Paint()..color = fill('ovaries'),
      );
      canvas.drawCircle(
        p(ox, 0.38),
        size.width * 0.05,
        Paint()
          ..color = stroke('ovaries')
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }

    // Uterus (inverted rounded triangle)
    final uterus = Path()
      ..moveTo(fx(0.40), fy(0.44))
      ..quadraticBezierTo(fx(0.42), fy(0.58), fx(0.50), fy(0.66))
      ..quadraticBezierTo(fx(0.58), fy(0.58), fx(0.60), fy(0.44))
      ..quadraticBezierTo(fx(0.50), fy(0.41), fx(0.40), fy(0.44))
      ..close();
    canvas.drawPath(uterus, Paint()..color = fill('uterus'));
    canvas.drawPath(
      uterus,
      Paint()
        ..color = stroke('uterus')
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Cervix
    final cervixRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(fx(0.465), fy(0.66), fx(0.535), fy(0.76)),
      Radius.circular(size.width * 0.012),
    );
    canvas.drawRRect(cervixRect, Paint()..color = fill('cervix'));
    canvas.drawRRect(
      cervixRect,
      Paint()
        ..color = stroke('cervix')
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Vagina (gentle funnel)
    final vagina = Path()
      ..moveTo(fx(0.47), fy(0.77))
      ..quadraticBezierTo(fx(0.44), fy(0.86), fx(0.45), fy(0.93))
      ..quadraticBezierTo(fx(0.50), fy(0.95), fx(0.55), fy(0.93))
      ..quadraticBezierTo(fx(0.56), fy(0.86), fx(0.53), fy(0.77))
      ..close();
    canvas.drawPath(vagina, Paint()..color = fill('vagina'));
    canvas.drawPath(
      vagina,
      Paint()
        ..color = stroke('vagina')
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Labels
    bool isHi(String key) => key == highlight;
    _drawLabel(
      canvas, size,
      text: 'Fallopian tubes',
      center: p(0.50, 0.09),
      anchor: p(0.42, 0.33),
      color: isHi('tubes') ? accent : AppColors.textMedium,
      bold: isHi('tubes'),
    );
    _drawLabel(
      canvas, size,
      text: 'Ovaries',
      center: p(0.13, 0.19),
      anchor: p(0.18, 0.35),
      color: isHi('ovaries') ? accent : AppColors.textMedium,
      bold: isHi('ovaries'),
    );
    _drawLabel(
      canvas, size,
      text: 'Uterus',
      center: p(0.88, 0.47),
      anchor: p(0.63, 0.51),
      color: isHi('uterus') ? accent : AppColors.textMedium,
      bold: isHi('uterus'),
    );
    _drawLabel(
      canvas, size,
      text: 'Cervix',
      center: p(0.11, 0.62),
      anchor: p(0.43, 0.69),
      color: isHi('cervix') ? accent : AppColors.textMedium,
      bold: isHi('cervix'),
    );
    _drawLabel(
      canvas, size,
      text: 'Vagina',
      center: p(0.89, 0.83),
      anchor: p(0.56, 0.82),
      color: isHi('vagina') ? accent : AppColors.textMedium,
      bold: isHi('vagina'),
    );
  }

  @override
  bool shouldRepaint(covariant _AnatomyPainter oldDelegate) =>
      oldDelegate.highlight != highlight ||
      oldDelegate.accent != accent ||
      oldDelegate.pulse != pulse;
}

/// Draws a small text label with a leader line pointing at [anchor].
void _drawLabel(
  Canvas canvas,
  Size size, {
  required String text,
  required Offset center,
  required Offset anchor,
  required Color color,
  required bool bold,
}) {
  final fs = (size.width * 0.028).clamp(9.0, 12.0);
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: GoogleFonts.inter(
        fontSize: fs,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final anchorPx = Offset(anchor.dx * size.width, anchor.dy * size.height);
  final centerPx = Offset(center.dx * size.width, center.dy * size.height);
  final textRect = Rect.fromCenter(center: centerPx, width: tp.width, height: tp.height);

  final end = _rayToBox(anchorPx, textRect);
  if (end != null) {
    canvas.drawLine(
      anchorPx,
      end,
      Paint()
        ..color = AppColors.textLight.withValues(alpha: 0.75)
        ..strokeWidth = 1.1,
    );
  }
  tp.paint(canvas, textRect.topLeft);
}

/// First intersection of the ray from [origin] toward the rect centre with
/// the rect border (minus a small gap).
Offset? _rayToBox(Offset origin, Rect rect) {
  final center = rect.center;
  final dir = center - origin;
  if (dir.distance < 0.001) return null;
  final u = dir / dir.distance;
  const eps = 1e-9;
  double tmin = 0;
  double tmax = double.infinity;

  void slab(double t1, double t2) {
    var lo = t1;
    var hi = t2;
    if (lo > hi) {
      final tmp = lo;
      lo = hi;
      hi = tmp;
    }
    tmin = math.max(tmin, lo);
    tmax = math.min(tmax, hi);
  }

  if (u.dx.abs() > eps) {
    slab((rect.left - origin.dx) / u.dx, (rect.right - origin.dx) / u.dx);
  }
  if (u.dy.abs() > eps) {
    slab((rect.top - origin.dy) / u.dy, (rect.bottom - origin.dy) / u.dy);
  }
  if (tmin > tmax) return null;
  final t = tmin > 0 ? tmin : (tmax.isFinite ? tmax : 1);
  final end = origin + u * (t * dir.distance - 6);
  return (t * dir.distance - 6) > 1 ? end : origin + u * (t * dir.distance * 0.6);
}

/// ---------------------------------------------------------------------------
/// Vulva (external anatomy) diagram
/// ---------------------------------------------------------------------------

class VulvaDiagramFrame extends StatelessWidget {
  final Color accentColor;

  const VulvaDiagramFrame({super.key, required this.accentColor});

  static const _parts = ['Clitoris', 'Labia', 'Urethral opening', 'Vaginal opening'];

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      caption: 'A simple, labeled look at the external anatomy — every vulva is different, and all of it is normal.',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: CustomPaint(
              painter: _VulvaPainter(accent: accentColor),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final part in _parts)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        part,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VulvaPainter extends CustomPainter {
  final Color accent;

  const _VulvaPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    double fx(double x) => x * size.width;
    double fy(double y) => y * size.height;
    Offset p(double x, double y) => Offset(fx(x), fy(y));
    const strokeW = 1.6;

    // Labia majora (outer)
    final majora = Rect.fromCenter(center: p(0.5, 0.52), width: fx(0.38), height: fy(0.56));
    canvas.drawOval(
      majora,
      Paint()..color = const Color(0xFFE8DFF5),
    );
    canvas.drawOval(
      majora,
      Paint()
        ..color = accent.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Labia minora (inner)
    final minora = Rect.fromCenter(center: p(0.5, 0.56), width: fx(0.20), height: fy(0.42));
    canvas.drawOval(
      minora,
      Paint()..color = accent.withValues(alpha: 0.16),
    );
    canvas.drawOval(
      minora,
      Paint()
        ..color = accent.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Clitoris + hood
    canvas.drawCircle(p(0.5, 0.29), size.width * 0.030, Paint()..color = accent);
    canvas.drawCircle(
      p(0.5, 0.29),
      size.width * 0.030,
      Paint()
        ..color = accent.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );
    canvas.drawCircle(
      p(0.5, 0.245),
      size.width * 0.020,
      Paint()
        ..color = accent.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Urethral opening
    final urethra = Rect.fromCenter(center: p(0.5, 0.485), width: fx(0.036), height: fy(0.022));
    canvas.drawOval(urethra, Paint()..color = accent.withValues(alpha: 0.5));
    canvas.drawOval(
      urethra,
      Paint()
        ..color = accent.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Vaginal opening
    final opening = Rect.fromCenter(center: p(0.5, 0.62), width: fx(0.084), height: fy(0.11));
    canvas.drawOval(opening, Paint()..color = accent.withValues(alpha: 0.22));
    canvas.drawOval(
      opening,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Labels
    _drawLabel(
      canvas, size,
      text: 'Clitoris',
      center: p(0.85, 0.13),
      anchor: p(0.545, 0.29),
      color: accent,
      bold: true,
    );
    _drawLabel(
      canvas, size,
      text: 'Labia',
      center: p(0.10, 0.42),
      anchor: p(0.29, 0.50),
      color: accent,
      bold: true,
    );
    _drawLabel(
      canvas, size,
      text: 'Urethral opening',
      center: p(0.86, 0.50),
      anchor: p(0.53, 0.49),
      color: accent,
      bold: true,
    );
    _drawLabel(
      canvas, size,
      text: 'Vaginal opening',
      center: p(0.50, 0.89),
      anchor: p(0.50, 0.68),
      color: accent,
      bold: true,
    );
  }

  @override
  bool shouldRepaint(covariant _VulvaPainter oldDelegate) => oldDelegate.accent != accent;
}

/// ---------------------------------------------------------------------------
/// Hormonal cycle timeline (animated indicator)
/// ---------------------------------------------------------------------------

class HormoneCycleTimelineFrame extends StatefulWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const HormoneCycleTimelineFrame({super.key, required this.data, required this.accentColor});

  @override
  State<HormoneCycleTimelineFrame> createState() => _HormoneCycleTimelineFrameState();
}

class _HormoneCycleTimelineFrameState extends State<HormoneCycleTimelineFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();
  bool _playing = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _activePhaseIndex(List<Map<String, dynamic>> phases, int day) {
    for (final phase in phases) {
      final start = (phase['start'] as num).toInt();
      final end = (phase['end'] as num).toInt();
      if (day >= start && day <= end) {
        return phases.indexOf(phase);
      }
    }
    return 0;
  }

  void _toggle() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phases = (widget.data?['phases'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'A 28-day average — real cycles vary, and that is normal.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final cellWidth = (width - 56) / 28;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: t * (width - 14),
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.accentColor,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  for (var day = 1; day <= 28; day++)
                    Container(
                      width: cellWidth,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _phaseColorForDay(phases, day).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Day 1', style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textLight)),
                  Text('Day 28', style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textLight)),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final day = (_controller.value * 28).floor() + 1;
                  final idx = _activePhaseIndex(phases, day);
                  final phase = idx < phases.length ? phases[idx] : phases.first;
                  final color = Color(phase['color'] as int);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase['label'] as String? ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phase['note'] as String? ?? '',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium, height: 1.35),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: _toggle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: widget.accentColor,
                      size: 22,
                    ),
                  ),
                  Text(
                    _playing ? 'Watch the cycle move' : 'Paused — tap to resume',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMedium),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Color _phaseColorForDay(List<Map<String, dynamic>> phases, int day) {
    for (final phase in phases) {
      final start = (phase['start'] as num).toInt();
      final end = (phase['end'] as num).toInt();
      if (day >= start && day <= end) {
        return Color(phase['color'] as int);
      }
    }
    return const Color(0xFFF4EFFB);
  }
}

/// ---------------------------------------------------------------------------
/// Fertile window timeline (soft highlight + gentle pulse)
/// ---------------------------------------------------------------------------

class FertileWindowTimelineFrame extends StatefulWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const FertileWindowTimelineFrame({super.key, required this.data, required this.accentColor});

  @override
  State<FertileWindowTimelineFrame> createState() => _FertileWindowTimelineFrameState();
}

class _FertileWindowTimelineFrameState extends State<FertileWindowTimelineFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final softStart = ((widget.data?['softStart'] as num?) ?? 8).toInt();
    final softEnd = ((widget.data?['softEnd'] as num?) ?? 19).toInt();
    final peakStart = ((widget.data?['peakStart'] as num?) ?? 12).toInt();
    final peakEnd = ((widget.data?['peakEnd'] as num?) ?? 16).toInt();

    return _VisualCard(
      caption: 'Averages, not guarantees — the window differs from person to person and cycle to cycle.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cellWidth = (width - 56) / 28;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulse = _controller.value;
                  return Row(
                    children: [
                      for (var day = 1; day <= 28; day++)
                        Container(
                          width: cellWidth,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: day >= peakStart && day <= peakEnd
                                ? widget.accentColor.withValues(alpha: 0.45 + 0.20 * pulse)
                                : (day >= softStart && day <= softEnd
                                    ? widget.accentColor.withValues(alpha: 0.20)
                                    : const Color(0xFFF4EFFB)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day 1', style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textLight)),
              Text('Day 14', style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textLight)),
              Text('Day 28', style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(text: 'Fertile window (approx.)', color: widget.accentColor),
              _Chip(text: 'Ovulation likely (approx.)', color: widget.accentColor, filled: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Ovulation — follicle growth + egg release animation
/// ---------------------------------------------------------------------------

class EggReleaseAnimationFrame extends StatefulWidget {
  final Color accentColor;

  const EggReleaseAnimationFrame({super.key, required this.accentColor});

  @override
  State<EggReleaseAnimationFrame> createState() => _EggReleaseAnimationFrameState();
}

class _EggReleaseAnimationFrameState extends State<EggReleaseAnimationFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();
  bool _playing = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      caption: 'An egg matures inside the ovary, then travels down the tube toward the uterus.',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => CustomPaint(
                painter: _EggReleasePainter(accent: widget.accentColor, t: _controller.value),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _toggle,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: widget.accentColor,
                  size: 22,
                ),
              ),
              Text(
                _playing ? 'Egg release in motion' : 'Paused — tap to resume',
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EggReleasePainter extends CustomPainter {
  final Color accent;
  final double t;

  const _EggReleasePainter({required this.accent, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    double fx(double x) => x * size.width;
    double fy(double y) => y * size.height;
    Offset p(double x, double y) => Offset(fx(x), fy(y));

    // Fallopian tube path (left ovary → uterus)
    final tube = Path()
      ..moveTo(fx(0.27), fy(0.42))
      ..quadraticBezierTo(fx(0.37), fy(0.34), fx(0.47), fy(0.46));
    canvas.drawPath(
      tube,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.016
        ..strokeCap = StrokeCap.round,
    );

    // Ovary
    canvas.drawCircle(p(0.22, 0.42), size.width * 0.062, Paint()..color = const Color(0xFFE8DFF5));
    canvas.drawCircle(
      p(0.22, 0.42),
      size.width * 0.062,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Follicle growing inside the ovary
    final growth = t < 0.35 ? t / 0.35 : 1.0;
    canvas.drawCircle(
      p(0.22, 0.42),
      size.width * (0.014 + 0.026 * growth),
      Paint()..color = accent.withValues(alpha: 0.75),
    );

    // Egg travelling along the tube
    final release = ((t - 0.35) / 0.55).clamp(0.0, 1.0);
    final metrics = tube.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final pos = metric.getTangentForOffset(metric.length * release)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, size.width * 0.019, Paint()..color = accent);
      }
    }

    // Uterus (right side)
    final uterus = Path()
      ..moveTo(fx(0.47), fy(0.50))
      ..quadraticBezierTo(fx(0.49), fy(0.62), fx(0.55), fy(0.68))
      ..quadraticBezierTo(fx(0.61), fy(0.62), fx(0.63), fy(0.50))
      ..quadraticBezierTo(fx(0.55), fy(0.47), fx(0.47), fy(0.50))
      ..close();
    canvas.drawPath(uterus, Paint()..color = const Color(0xFFE8DFF5));
    canvas.drawPath(
      uterus,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Stage label
    final stage = t < 0.35
        ? '1 · The egg matures'
        : (t < 0.90 ? '2 · The egg travels' : '3 · Reaching the uterus');
    final stageTp = TextPainter(
      text: TextSpan(
        text: stage,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: accent),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    stageTp.paint(canvas, p(0.0, 0.06));
  }

  @override
  bool shouldRepaint(covariant _EggReleasePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.t != t;
}

/// ---------------------------------------------------------------------------
/// Ovulation & pregnancy — egg + sperm pathway illustration
/// ---------------------------------------------------------------------------

class EggSpermPathwayFrame extends StatelessWidget {
  final Color accentColor;

  const EggSpermPathwayFrame({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      caption: 'Pregnancy can happen when sperm meets an egg around the fertile part of the cycle.',
      child: AspectRatio(
        aspectRatio: 1.35,
        child: CustomPaint(
          painter: _EggSpermPathwayPainter(accent: accentColor),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _EggSpermPathwayPainter extends CustomPainter {
  final Color accent;

  const _EggSpermPathwayPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    double fx(double x) => x * size.width;
    double fy(double y) => y * size.height;
    Offset p(double x, double y) => Offset(fx(x), fy(y));

    // Tube
    final tube = Path()
      ..moveTo(fx(0.24), fy(0.34))
      ..quadraticBezierTo(fx(0.35), fy(0.28), fx(0.46), fy(0.40));
    canvas.drawPath(
      tube,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.016
        ..strokeCap = StrokeCap.round,
    );

    // Ovary
    canvas.drawCircle(p(0.19, 0.34), size.width * 0.058, Paint()..color = const Color(0xFFE8DFF5));
    canvas.drawCircle(
      p(0.19, 0.34),
      size.width * 0.058,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Uterus
    final uterus = Path()
      ..moveTo(fx(0.53), fy(0.48))
      ..quadraticBezierTo(fx(0.55), fy(0.60), fx(0.61), fy(0.66))
      ..quadraticBezierTo(fx(0.67), fy(0.60), fx(0.69), fy(0.48))
      ..quadraticBezierTo(fx(0.61), fy(0.45), fx(0.53), fy(0.48))
      ..close();
    canvas.drawPath(uterus, Paint()..color = const Color(0xFFE8DFF5));
    canvas.drawPath(
      uterus,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Egg on the tube
    canvas.drawCircle(p(0.33, 0.32), size.width * 0.02, Paint()..color = accent);

    // Sperm approaching the egg
    final spermPositions = [
      (Offset(0.27, 0.44), -0.5),
      (Offset(0.30, 0.50), -0.15),
      (Offset(0.34, 0.41), -1.0),
    ];
    for (final (pos, angle) in spermPositions) {
      canvas.save();
      canvas.translate(fx(pos.dx), fy(pos.dy));
      canvas.rotate(angle);
      final head = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size.width * 0.03, height: size.height * 0.016),
        Radius.circular(size.width * 0.008),
      );
      canvas.drawRRect(head, Paint()..color = accent.withValues(alpha: 0.85));
      final tail = Path()
        ..moveTo(size.width * 0.014, 0)
        ..quadraticBezierTo(size.width * 0.02, size.height * 0.02, size.width * 0.026, 0);
      canvas.drawPath(
        tail,
        Paint()
          ..color = accent.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _EggSpermPathwayPainter oldDelegate) => oldDelegate.accent != accent;
}

/// ---------------------------------------------------------------------------
/// PCOS / PCOD cycle comparison
/// ---------------------------------------------------------------------------

class CycleComparisonFrame extends StatelessWidget {
  final Color accentColor;

  const CycleComparisonFrame({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      caption: 'Cycle patterns vary widely between people — these are simple examples, not predictions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(
            title: 'A usual cycle',
            subtitle: 'Phases and ovulation follow a rough rhythm',
            markerDay: 14,
            markerColor: accentColor,
            markerLabel: 'Ovulation',
            dashed: false,
          ),
          const SizedBox(height: 16),
          _buildRow(
            title: 'With PCOS / PCOD',
            subtitle: 'Ovulation can be later, less often, or absent',
            markerDay: 20,
            markerColor: const Color(0xFFE8A33D),
            markerLabel: 'May be delayed or missed',
            dashed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required String subtitle,
    required int markerDay,
    required Color markerColor,
    required String markerLabel,
    required bool dashed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMedium),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cellWidth = (width - 56) / 28;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    for (var day = 1; day <= 28; day++)
                      Container(
                        width: cellWidth,
                        height: 26,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _cellColor(day, dashed),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                Positioned(
                  left: ((markerDay - 1) / 28) * width + (width / 28) * 0.5 - 9,
                  top: -14,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: markerColor.withValues(alpha: 0.15),
                      border: Border.all(color: markerColor, width: 1.4),
                    ),
                    child: Icon(
                      dashed ? Icons.help_rounded : Icons.flare_rounded,
                      size: 11,
                      color: markerColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
            ),
            const SizedBox(width: 6),
            Text(
              markerLabel,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: markerColor),
            ),
          ],
        ),
      ],
    );
  }

  Color _cellColor(int day, bool dashed) {
    if (dashed) {
      return day % 2 == 0
          ? AppColors.softPurple.withValues(alpha: 0.22)
          : AppColors.softPurple.withValues(alpha: 0.12);
    }
    if (day >= 1 && day <= 5) return const Color(0xFFC94A6E).withValues(alpha: 0.75);
    if (day >= 6 && day <= 13) return const Color(0xFF9D76C1).withValues(alpha: 0.55);
    if (day >= 14 && day <= 16) return const Color(0xFF7B4397).withValues(alpha: 0.8);
    return const Color(0xFFFFB085).withValues(alpha: 0.6);
  }
}

/// ---------------------------------------------------------------------------
/// Consent guide (icon-based interaction)
/// ---------------------------------------------------------------------------

class ConsentGuideFrame extends StatefulWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const ConsentGuideFrame({super.key, required this.data, required this.accentColor});

  @override
  State<ConsentGuideFrame> createState() => _ConsentGuideFrameState();
}

class _ConsentGuideFrameState extends State<ConsentGuideFrame> {
  late final List<bool> _checked =
      List.generate((widget.data?['points'] as List<dynamic>? ?? const []).length, (_) => false);

  @override
  Widget build(BuildContext context) {
    final points = (widget.data?['points'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'Tap each point as you read it — consent is an active, ongoing conversation.',
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < points.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: () => setState(() => _checked[i] = !_checked[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _checked[i]
                                ? widget.accentColor.withValues(alpha: 0.08)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _checked[i]
                                  ? widget.accentColor.withValues(alpha: 0.7)
                                  : widget.accentColor.withValues(alpha: 0.3),
                              width: _checked[i] ? 1.6 : 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: widget.accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconForKey(points[i]['icon'] as String? ?? ''),
                                      size: 18,
                                      color: widget.accentColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
                                    opacity: _checked[i] ? 1 : 0,
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                points[i]['title'] as String? ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                points[i]['desc'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  height: 1.35,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.accentColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.favorite_rounded, size: 16, color: widget.accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A “yes” that is pressured, unclear, or cannot be withdrawn is not consent.',
                    style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Safe sex icon cards
/// ---------------------------------------------------------------------------

class SafeSexIconsFrame extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const SafeSexIconsFrame({super.key, required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final items = (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'Protection is a habit, not an event.',
      child: _IconGrid(
        accentColor: accentColor,
        items: [
          for (final item in items)
            (
              icon: _iconForKey(item['icon'] as String? ?? ''),
              title: item['title'] as String? ?? '',
              description: item['desc'] as String? ?? '',
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// STI awareness — testing visual
/// ---------------------------------------------------------------------------

class TestingAwarenessFrame extends StatelessWidget {
  const TestingAwarenessFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      caption: 'Testing is confidential and helps you and your partners stay healthy.',
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: _miniCard(
                  icon: Icons.visibility_off_rounded,
                  title: 'Some STIs are silent',
                  desc: 'Many have no obvious symptoms at all.',
                  color: const Color(0xFF9D76C1),
                  bg: const Color(0xFFF8F0FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniCard(
                  icon: Icons.biotech_rounded,
                  title: 'Testing is the way to know',
                  desc: 'Quick, confidential, and usually simple.',
                  color: const Color(0xFF5B7FFF),
                  bg: const Color(0xFFF0F4FF),
                ),
              ),
            ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB5EAD7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF2E8B76)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Noticing a possible sign is common and not a judgment. Testing turns uncertainty into clarity.',
                    style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: GoogleFonts.inter(fontSize: 11, height: 1.35, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Contraception method comparison
/// ---------------------------------------------------------------------------

class MethodComparisonFrame extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const MethodComparisonFrame({super.key, required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final items = (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'Every option works differently — this is information, not a prescription.',
      child: Column(
        children: [
          _IconGrid(
            accentColor: accentColor,
            items: [
              for (final item in items)
                (
                  icon: _iconForKey(item['icon'] as String? ?? ''),
                  title: item['title'] as String? ?? '',
                  description: item['desc'] as String? ?? '',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD8B4F8).withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_hospital_rounded, size: 16, color: AppColors.softPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A healthcare professional can help you choose an option that fits your body, health history, and life.',
                    style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// When to seek care — 3-step pathway
/// ---------------------------------------------------------------------------

class MedicalCareGuideFrame extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const MedicalCareGuideFrame({super.key, required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final steps = (data?['steps'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'You do not need a “serious” reason — any question is a good reason to book.',
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Container(
                width: 2,
                height: 14,
                margin: const EdgeInsets.only(left: 13),
                color: accentColor.withValues(alpha: 0.35),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i]['title'] as String? ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[i]['desc'] as String? ?? '',
                          style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Unusual discharge — natural vs worth-discussing comparison
/// ---------------------------------------------------------------------------

class SymptomComparisonFrame extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SymptomComparisonFrame({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final naturalTitle = data?['naturalTitle'] as String? ?? 'Can vary naturally';
    final natural = (data?['natural'] as List<dynamic>? ?? const []).cast<String>();
    final checkTitle = data?['checkTitle'] as String? ?? 'Worth discussing';
    final check = (data?['check'] as List<dynamic>? ?? const []).cast<String>();

    return _VisualCard(
      caption: 'Persistent changes with other symptoms are worth discussing — not single days.',
      child: Column(
        children: [
          _sideCard(
            icon: Icons.check_circle_outline_rounded,
            title: naturalTitle,
            items: natural,
            color: const Color(0xFF2E8B76),
            bg: const Color(0xFFF0FDF4),
          ),
          const SizedBox(height: 10),
          _sideCard(
            icon: Icons.info_outline_rounded,
            title: checkTitle,
            items: check,
            color: const Color(0xFFE8A33D),
            bg: const Color(0xFFFBF0DF),
          ),
        ],
      ),
    );
  }

  Widget _sideCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Pelvic pain — body location illustration
/// ---------------------------------------------------------------------------

class BodyLocationMapFrame extends StatelessWidget {
  final Color accentColor;

  const BodyLocationMapFrame({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return _VisualCard(
      caption: 'Pelvic pain is felt in the lower belly or pelvis — the area below the navel.',
      child: AspectRatio(
        aspectRatio: 1.1,
        child: _PulsingCanvas(
          builder: (context, pulse) => CustomPaint(
            painter: _BodyPainter(accent: accentColor, pulse: pulse),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final Color accent;
  final double pulse;

  const _BodyPainter({required this.accent, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    double fx(double x) => x * size.width;
    double fy(double y) => y * size.height;

    // Head
    canvas.drawCircle(
      Offset(fx(0.5), fy(0.11)),
      size.width * 0.065,
      Paint()..color = const Color(0xFFE8DFF5),
    );

    // Torso
    final torso = RRect.fromRectAndRadius(
      Rect.fromLTRB(fx(0.35), fy(0.22), fx(0.65), fy(0.80)),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(torso, Paint()..color = const Color(0xFFF4EFFB));
    canvas.drawRRect(
      torso,
      Paint()
        ..color = AppColors.softPurple.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Legs
    final legPaint = Paint()..color = const Color(0xFFF4EFFB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(fx(0.38), fy(0.80), fx(0.48), fy(0.94)),
        Radius.circular(size.width * 0.03),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(fx(0.52), fy(0.80), fx(0.62), fy(0.94)),
        Radius.circular(size.width * 0.03),
      ),
      legPaint,
    );

    // Pelvis highlight (pulsing)
    final pelvis = RRect.fromRectAndRadius(
      Rect.fromLTRB(fx(0.42), fy(0.52), fx(0.58), fy(0.72)),
      Radius.circular(size.width * 0.03),
    );
    canvas.drawRRect(
      pelvis,
      Paint()..color = accent.withValues(alpha: 0.25 + 0.15 * pulse),
    );
    canvas.drawRRect(
      pelvis,
      Paint()
        ..color = accent.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Label
    final labelTp = TextPainter(
      text: TextSpan(
        text: 'Pelvis',
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: accent),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTp.paint(canvas, Offset(fx(0.58) - labelTp.width / 2, fy(0.40)));
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.pulse != pulse;
}

/// ---------------------------------------------------------------------------
/// Abnormal bleeding — pattern cards
/// ---------------------------------------------------------------------------

class BleedingPatternsFrame extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const BleedingPatternsFrame({super.key, required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final items = (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'One episode is usually not a worry — repeated patterns are worth discussing.',
      child: _IconGrid(
        accentColor: accentColor,
        items: [
          for (final item in items)
            (
              icon: _iconForKey(item['icon'] as String? ?? ''),
              title: item['title'] as String? ?? '',
              description: item['desc'] as String? ?? '',
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Pain during intercourse — feel / help two-card visual
/// ---------------------------------------------------------------------------

class CareGuidanceFrame extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const CareGuidanceFrame({super.key, required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final feelTitle = data?['feelTitle'] as String? ?? 'What it can feel like';
    final feel = (data?['feel'] as List<dynamic>? ?? const []).cast<String>();
    final helpTitle = data?['helpTitle'] as String? ?? 'What can help';
    final help = (data?['help'] as List<dynamic>? ?? const []).cast<String>();

    return _VisualCard(
      caption: 'Persistent pain during sex is worth addressing — it is not something to endure silently.',
      child: Column(
        children: [
          _sideCard(
            icon: Icons.visibility_rounded,
            title: feelTitle,
            items: feel,
            color: accentColor,
          ),
          const SizedBox(height: 10),
          _sideCard(
            icon: Icons.spa_rounded,
            title: helpTitle,
            items: help,
            color: const Color(0xFF2E8B76),
          ),
        ],
      ),
    );
  }

  Widget _sideCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Possible STI symptoms — interactive checklist
/// ---------------------------------------------------------------------------

class SymptomChecklistFrame extends StatefulWidget {
  final Map<String, dynamic>? data;
  final Color accentColor;

  const SymptomChecklistFrame({super.key, required this.data, required this.accentColor});

  @override
  State<SymptomChecklistFrame> createState() => _SymptomChecklistFrameState();
}

class _SymptomChecklistFrameState extends State<SymptomChecklistFrame> {
  late final List<bool> _checked =
      List.generate((widget.data?['items'] as List<dynamic>? ?? const []).length, (_) => false);

  @override
  Widget build(BuildContext context) {
    final items = (widget.data?['items'] as List<dynamic>? ?? const []).cast<String>();

    return _VisualCard(
      caption: 'Any single sign can have many causes — only testing and professional evaluation can tell what is happening.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _checked[i] = !_checked[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: _checked[i]
                        ? widget.accentColor.withValues(alpha: 0.08)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _checked[i]
                          ? widget.accentColor.withValues(alpha: 0.6)
                          : AppColors.borderGrey.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _checked[i] ? widget.accentColor : Colors.transparent,
                          border: Border.all(
                            color: _checked[i] ? widget.accentColor : AppColors.textLight,
                            width: 1.6,
                          ),
                        ),
                        child: _checked[i]
                            ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          items[i],
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.35,
                            color: _checked[i] ? widget.accentColor : AppColors.textDark,
                            fontWeight: _checked[i] ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.biotech_rounded, size: 15, color: widget.accentColor),
              const SizedBox(width: 6),
              Text(
                'Testing is the only way to know',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: widget.accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// When to see a gynecologist — traffic-light guide
/// ---------------------------------------------------------------------------

class TrafficLightGuideFrame extends StatefulWidget {
  final Map<String, dynamic>? data;

  const TrafficLightGuideFrame({super.key, required this.data});

  @override
  State<TrafficLightGuideFrame> createState() => _TrafficLightGuideFrameState();
}

class _TrafficLightGuideFrameState extends State<TrafficLightGuideFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _zoneStyles = [
    (key: 'green', color: Color(0xFF2E8B76), bg: Color(0xFFE9F7F1), dot: Colors.green),
    (key: 'yellow', color: Color(0xFFE8A33D), bg: Color(0xFFFBF0DF), dot: Colors.amber),
    (key: 'red', color: Color(0xFFC94A6E), bg: Color(0xFFFFF0F3), dot: Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    final zones = (widget.data?['zones'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return _VisualCard(
      caption: 'Use this as a general guide — your own judgement plus a professional’s opinion is the best pair.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final v = _controller.value * zones.length;
          return Column(
            children: [
              for (var i = 0; i < zones.length; i++)
                _buildZone(
                  context,
                  zones[i],
                  _zoneStyles[i],
                  active: v >= i && v < i + 1,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildZone(
    BuildContext context,
    Map<String, dynamic> zone,
    ({String key, Color color, Color bg, Color dot}) style, {
    required bool active,
  }) {
    final items = (zone['items'] as List<dynamic>? ?? const []).cast<String>();
    final color = style.color;
    final bg = style.bg;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: active ? bg : bg.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color : color.withValues(alpha: 0.25),
          width: active ? 1.8 : 1.0,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: active ? 1 : 0.55,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: style.dot),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: active ? 1 : 0.75,
                child: Text(
                  zone['label'] as String? ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textDark),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}