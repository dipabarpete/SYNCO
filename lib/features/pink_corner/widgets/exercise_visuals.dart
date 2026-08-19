import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../data/exercise_topic.dart';

/// Blue accent shared across the Exercise & Movement Learn card.
const Color exerciseBlueDeep = Color(0xFF5B7FFF);
const Color exerciseBlueBorder = Color(0xFFC7CEEA);
const Color exerciseBlueLight = Color(0xFFE5EBFF);
const Color exerciseBlueCardBg = Color(0xFFF0F4FF);

/// Top-level educational visual for an Exercise topic.
///
/// Renders the visual chosen by [topic.visualType] inside a clean card,
/// with a text caption so every visual concept also has a text alternative.
class ExerciseTopicVisual extends StatelessWidget {
  final ExerciseTopic topic;

  const ExerciseTopicVisual({super.key, required this.topic});

  static const Map<ExerciseVisualType, String> _captions = {
    ExerciseVisualType.benefitsWheel:
        'A movement benefits wheel. Each benefit lights up one at a time as '
        'you explore — strength, energy, mood, sleep, mobility and heart health '
        'all sit around one shared centre: movement.',
    ExerciseVisualType.squatSequence:
        'A beginner performing a slow, controlled squat with simple movement '
        'arrows — down slowly, then back up slowly. Form matters more than speed.',
    ExerciseVisualType.walkingPath:
        'A character walks along a short path while small wellness icons appear '
        '— mood, energy, fresh air and movement.',
    ExerciseVisualType.cardioIntensity:
        'A gentle intensity scale — Gentle, Moderate, More challenging. Every '
        'level counts; a gentler choice is a real choice, not a fallback.',
    ExerciseVisualType.jointMovement:
        'A simple body diagram highlighting joints — shoulders, spine, hips and '
        'ankles — each showing a small, gentle movement arc.',
    ExerciseVisualType.yogaPoses:
        'A calm transition between two beginner-friendly poses — Child\u2019s pose '
        'and a slow Cat–Cow — with an easy breathing circle.',
    ExerciseVisualType.pilatesSequence:
        'A slow, controlled Pilates sequence: breathe in, roll down, pelvic tilt '
        'and a small bridge lift.',
    ExerciseVisualType.cycleWheel:
        'An interactive cycle wheel with movement suggestions for each phase — '
        'gentle flexible suggestions, not rules.',
    ExerciseVisualType.pcosBenefitMap:
        'A Movement + PCOS/PCOD benefit map — strength, activity, energy, '
        'well-being and consistency around one centre: movement.',
  };

  @override
  Widget build(BuildContext context) {
    final Widget visual = switch (topic.visualType) {
      ExerciseVisualType.benefitsWheel => const MovementBenefitsWheelVisual(),
      ExerciseVisualType.squatSequence => const SquatSequenceVisual(),
      ExerciseVisualType.walkingPath => const WalkingPathVisual(),
      ExerciseVisualType.cardioIntensity => const CardioIntensityScaleVisual(),
      ExerciseVisualType.jointMovement => const JointMovementVisual(),
      ExerciseVisualType.yogaPoses => const YogaPoseTransitionVisual(),
      ExerciseVisualType.pilatesSequence => const PilatesSequenceVisual(),
      ExerciseVisualType.cycleWheel => const CycleMovementWheelVisual(),
      ExerciseVisualType.pcosBenefitMap => const PcosBenefitMapVisual(),
    };

    return _ExerciseVisualCard(
      caption: _captions[topic.visualType]!,
      child: Semantics(
        label: _captions[topic.visualType],
        child: visual,
      ),
    );
  }
}

/// Shared white card shell with the "Visual guide" header and caption.
class _ExerciseVisualCard extends StatelessWidget {
  final String caption;
  final Widget child;

  const _ExerciseVisualCard({required this.caption, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                size: 16,
                color: AppColors.softPurple,
              ),
              const SizedBox(width: 8),
              Text(
                'Visual guide',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
          const SizedBox(height: 12),
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              height: 1.45,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps animated visuals that share the same content-based staggered reveal.
class ExerciseEnter extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int total;
  final Widget child;

  const ExerciseEnter({
    super.key,
    required this.controller,
    required this.index,
    required this.total,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index / total) * 0.65;
    const span = 0.35;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final raw = ((controller.value - start) / span).clamp(0.0, 1.0);
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// 1. WHY MOVEMENT MATTERS — movement benefits wheel
//    + shared wheel used by the PCOS/PCOD benefit map
// ---------------------------------------------------------------------------

/// Shared animated "benefit wheel" used by the movement benefits visual and
/// the PCOS/PCOD benefit map. Each item lights up one at a time around the
/// centre.
class _BenefitWheel extends StatefulWidget {
  final String centerTitle;
  final IconData centerIcon;
  final List<({IconData icon, String label, Color color})> items;

  const _BenefitWheel({
    required this.centerTitle,
    required this.centerIcon,
    required this.items,
  });

  @override
  State<_BenefitWheel> createState() => _BenefitWheelState();
}

class _BenefitWheelState extends State<_BenefitWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 300.0);
        final cx = size / 2;
        final cy = size / 2 + 6;
        final radius = size / 2 - 46;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final active = (_controller.value * widget.items.length).floor();
            return SizedBox(
              width: size,
              height: size + 12,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size + 12),
                    painter: _WheelRingPainter(
                      color: exerciseBlueDeep,
                      active: active,
                      total: widget.items.length,
                      progress: _controller.value,
                    ),
                  ),
                  for (var i = 0; i < widget.items.length; i++)
                    _buildNode(i, active, cx, cy, radius),
                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: exerciseBlueDeep.withValues(alpha: 0.5),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: exerciseBlueDeep.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.centerIcon,
                            size: 24,
                            color: exerciseBlueDeep,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.centerTitle,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNode(int index, int active, double cx, double cy, double r) {
    final item = widget.items[index];
    final angle = -math.pi / 2 + (index * 2 * math.pi / widget.items.length);
    final isActive = index == active;
    final x = cx + r * math.cos(angle);
    final y = cy + r * math.sin(angle);

    return Positioned(
      left: x - 40,
      top: y - 52,
      child: SizedBox(
        width: 80,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: isActive ? 1.0 : 0.55,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? item.color
                      : item.color.withValues(alpha: 0.18),
                  border: Border.all(
                    color: item.color.withValues(
                      alpha: isActive ? 1.0 : 0.4,
                    ),
                    width: isActive ? 1.8 : 1,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 19,
                  color: isActive ? Colors.white : item.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelRingPainter extends CustomPainter {
  final Color color;
  final int active;
  final int total;
  final double progress;

  _WheelRingPainter({
    required this.color,
    required this.active,
    required this.total,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 46;

    // Soft background disc.
    canvas.drawCircle(
      center,
      radius + 6,
      Paint()..color = exerciseBlueCardBg.withValues(alpha: 0.55),
    );

    // Static ring.
    final ringPaint = Paint()
      ..color = exerciseBlueBorder.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, ringPaint);

    // Rotating highlight arc for the active segment.
    final segment = 2 * math.pi / total;
    final start = -math.pi / 2 + active * segment;
    final highlight = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final arcProgress =
        ((progress * total) - active).clamp(0.0, 1.0) * segment;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start - 0.05,
      math.min(segment * 0.55, math.max(0.1, arcProgress)),
      false,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelRingPainter oldDelegate) =>
      oldDelegate.active != active ||
      oldDelegate.progress != progress ||
      oldDelegate.color != color;
}

/// Movement benefits wheel — centre "Movement", six benefits around it.
class MovementBenefitsWheelVisual extends StatelessWidget {
  const MovementBenefitsWheelVisual({super.key});

  static const _items = [
    (
      icon: Icons.fitness_center_rounded,
      label: 'Strength',
      color: Color(0xFF7B4397),
    ),
    (
      icon: Icons.bolt_rounded,
      label: 'Energy',
      color: Color(0xFFE8A33D),
    ),
    (
      icon: Icons.mood_rounded,
      label: 'Mood',
      color: Color(0xFFE892A2),
    ),
    (
      icon: Icons.bedtime_outlined,
      label: 'Sleep',
      color: Color(0xFF6495ED),
    ),
    (
      icon: Icons.accessibility_new_rounded,
      label: 'Mobility',
      color: Color(0xFF45B69C),
    ),
    (
      icon: Icons.favorite_rounded,
      label: 'Heart health',
      color: Color(0xFFC94A6E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BenefitWheel(
          centerTitle: 'Movement',
          centerIcon: Icons.directions_run_rounded,
          items: _items,
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: exerciseBlueCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: exerciseBlueBorder.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            'Each benefit lights up one at a time — movement touches them all.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
        ),
      ],
    );
  }
}

/// Movement + PCOS/PCOD benefit map — centre "Movement", five benefits around.
class PcosBenefitMapVisual extends StatelessWidget {
  const PcosBenefitMapVisual({super.key});

  static const _items = [
    (
      icon: Icons.fitness_center_rounded,
      label: 'Strength',
      color: Color(0xFF7B4397),
    ),
    (
      icon: Icons.directions_run_rounded,
      label: 'Activity',
      color: Color(0xFF45B69C),
    ),
    (
      icon: Icons.bolt_rounded,
      label: 'Energy',
      color: Color(0xFFE8A33D),
    ),
    (
      icon: Icons.favorite_rounded,
      label: 'Well-being',
      color: Color(0xFFE892A2),
    ),
    (
      icon: Icons.loop_rounded,
      label: 'Consistency',
      color: Color(0xFF6495ED),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BenefitWheel(
          centerTitle: 'Movement',
          centerIcon: Icons.eco_rounded,
          items: _items,
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE9F7F1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB5EAD7).withValues(alpha: 0.7),
            ),
          ),
          child: Text(
            'Movement supports health — it partners with medical care, it does not replace it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2. STRENGTH TRAINING — slow, controlled squat with movement arrows
// ---------------------------------------------------------------------------
class SquatSequenceVisual extends StatefulWidget {
  const SquatSequenceVisual({super.key});

  @override
  State<SquatSequenceVisual> createState() => _SquatSequenceVisualState();
}

class _SquatSequenceVisualState extends State<SquatSequenceVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
          decoration: BoxDecoration(
            color: exerciseBlueCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: exerciseBlueBorder.withValues(alpha: 0.6),
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = _controller.value;
              // Smooth down → up cycle (0..1..0).
              final t = (1 - math.cos(2 * math.pi * value)) / 2;
              final descent = value < 0.5;
              final phase =
                  value < 0.5 ? value / 0.5 : (value - 0.5) / 0.5;
              final fade = math.sin(phase * math.pi);
              return SizedBox(
                height: 185,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SquatFigurePainter(
                    t: t,
                    descent: descent,
                    arrowFade: fade,
                    color: exerciseBlueDeep,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SquatChip(
              icon: Icons.arrow_downward_rounded,
              label: 'Down slowly',
              color: const Color(0xFF45B69C),
            ),
            const SizedBox(width: 8),
            _SquatChip(
              icon: Icons.arrow_upward_rounded,
              label: 'Up slowly',
              color: const Color(0xFF7B4397),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Slow and controlled — form matters more than speed.',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }
}

class _SquatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SquatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SquatFigurePainter extends CustomPainter {
  final double t;
  final bool descent;
  final double arrowFade;
  final Color color;

  _SquatFigurePainter({
    required this.t,
    required this.descent,
    required this.arrowFade,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final ground = h - 22;
    final s = math.min(w / 170, h / 175);

    final limbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s
      ..strokeCap = StrokeCap.round;

    // Squat pose values.
    final hipY = (62 + 36 * t) * s + ground - 160 * s;
    final kneeY = (96 + 30 * t) * s + ground - 160 * s;
    final kneeX = (16 + 12 * t) * s;
    final hipSpread = 6 * t * s;
    final lean = 5 * t * s;

    // Torso.
    final neck = Offset(cx + lean, hipY - 36 * s);
    canvas.drawLine(
      Offset(cx, hipY),
      neck,
      limbPaint,
    );

    // Head.
    canvas.drawCircle(
      Offset(cx + lean + 2 * s, hipY - 50 * s),
      10.5 * s,
      Paint()..color = color,
    );

    // Arms reaching gently forward.
    final shoulder = Offset(cx + lean, hipY - 30 * s);
    canvas.drawLine(
      shoulder,
      Offset(shoulder.dx + 15 * s, shoulder.dy - 4 * s),
      limbPaint,
    );
    canvas.drawLine(
      Offset(shoulder.dx + 15 * s, shoulder.dy - 4 * s),
      Offset(shoulder.dx + 28 * s, shoulder.dy + 6 * s),
      limbPaint,
    );

    // Legs.
    final groundY = ground + 2 * s;
    canvas.drawLine(
      Offset(cx - hipSpread, hipY),
      Offset(cx - kneeX, kneeY),
      limbPaint,
    );
    canvas.drawLine(
      Offset(cx + hipSpread, hipY),
      Offset(cx + kneeX, kneeY),
      limbPaint,
    );
    canvas.drawLine(
      Offset(cx - kneeX, kneeY),
      Offset(cx - 24 * s, groundY),
      limbPaint,
    );
    canvas.drawLine(
      Offset(cx + kneeX, kneeY),
      Offset(cx + 24 * s, groundY),
      limbPaint,
    );

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY + 5 * s),
        width: 74 * s,
        height: 8 * s,
      ),
      Paint()..color = color.withValues(alpha: 0.1),
    );

    // Movement arrows.
    final arrowPaint = Paint()
      ..color = descent ? const Color(0xFF45B69C) : const Color(0xFF7B4397)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;

    final arrowX = cx - 46 * s;
    final arrowY = hipY - 6 * s;
    final arrowLen = 26 * s;
    if (descent) {
      _drawArrow(
        canvas,
        Offset(arrowX, arrowY),
        Offset(arrowX, arrowY + arrowLen),
        arrowPaint,
        arrowFade,
      );
    } else {
      _drawArrow(
        canvas,
        Offset(cx + 46 * s, arrowY + arrowLen),
        Offset(cx + 46 * s, arrowY),
        arrowPaint,
        arrowFade,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    double opacity,
  ) {
    canvas.save();
    canvas.drawLine(from, to, paint..color = paint.color.withValues(alpha: opacity));
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final head = Paint()
      ..color = paint.color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - 9 * math.cos(angle - 0.45),
        to.dy - 9 * math.sin(angle - 0.45),
      )
      ..lineTo(
        to.dx - 9 * math.cos(angle + 0.45),
        to.dy - 9 * math.sin(angle + 0.45),
      )
      ..close();
    canvas.drawPath(path, head);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SquatFigurePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.descent != descent ||
      oldDelegate.arrowFade != arrowFade;
}

// ---------------------------------------------------------------------------
// 3. WALKING — character walking along a path, wellness icons appear
// ---------------------------------------------------------------------------
class WalkingPathVisual extends StatefulWidget {
  const WalkingPathVisual({super.key});

  @override
  State<WalkingPathVisual> createState() => _WalkingPathVisualState();
}

class _WalkingPathVisualState extends State<WalkingPathVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _markers = [
    (
      icon: Icons.mood_rounded,
      label: 'Mood',
      t: 0.2,
      color: Color(0xFFE892A2),
      above: true,
    ),
    (
      icon: Icons.bolt_rounded,
      label: 'Energy',
      t: 0.42,
      color: Color(0xFFE8A33D),
      above: false,
    ),
    (
      icon: Icons.air_rounded,
      label: 'Fresh air',
      t: 0.64,
      color: Color(0xFF45B69C),
      above: true,
    ),
    (
      icon: Icons.directions_walk_rounded,
      label: 'Movement',
      t: 0.86,
      color: Color(0xFF5B7FFF),
      above: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = math.min(constraints.maxWidth, 320.0);
        const h = 150.0;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;

            return SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WalkingPathPainter(
                        progress: progress,
                        color: exerciseBlueDeep,
                      ),
                    ),
                  ),
                  // Wellness icons appearing as the walker passes.
                  for (final marker in _markers)
                    _buildMarker(marker, progress, w, h),
                  _buildWalker(progress, w, h),
                  Positioned(
                    left: 4,
                    top: h - 26,
                    child: _PathTag(
                      label: 'Start',
                      icon: Icons.play_circle_outline_rounded,
                      color: const Color(0xFF45B69C),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: h - 26,
                    child: _PathTag(
                      label: 'Done',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF7B4397),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Offset _pointAt(double t, double w, double h) {
    // Cubic bezier P0..P3 for the path.
    final p0 = Offset(8, h - 16);
    final p1 = Offset(w * 0.28, 8);
    final p2 = Offset(w * 0.62, h - 6);
    final p3 = Offset(w - 8, h - 14);
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx +
          3 * u * u * t * p1.dx +
          3 * u * t * t * p2.dx +
          t * t * t * p3.dx,
      u * u * u * p0.dy +
          3 * u * u * t * p1.dy +
          3 * u * t * t * p2.dy +
          t * t * t * p3.dy,
    );
  }

  Widget _buildWalker(double progress, double w, double h) {
    final pos = _pointAt(progress, w, h);
    final step = math.sin(progress * 2 * math.pi * 3);
    return Positioned(
      left: pos.dx - 13,
      top: pos.dy - 30,
      child: SizedBox(
        width: 26,
        height: 34,
        child: CustomPaint(
          painter: _WalkerPainter(
            step: step,
            color: exerciseBlueDeep,
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(
    ({IconData icon, String label, double t, Color color, bool above}) marker,
    double progress,
    double w,
    double h,
  ) {
    final pos = _pointAt(marker.t, w, h);
    final opacity = ((progress - marker.t) / 0.12).clamp(0.0, 1.0);
    final y = marker.above ? pos.dy - 46 : pos.dy + 6;
    return Positioned(
      left: pos.dx - 26,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: marker.color.withValues(alpha: 0.14),
                border: Border.all(
                  color: marker.color.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(marker.icon, size: 17, color: marker.color),
            ),
            const SizedBox(height: 2),
            Text(
              marker.label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _PathTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkingPathPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WalkingPathPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p0 = Offset(8, h - 16);
    final p1 = Offset(w * 0.28, 8);
    final p2 = Offset(w * 0.62, h - 6);
    final p3 = Offset(w - 8, h - 14);

    final fullPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    canvas.drawPath(
      fullPath,
      Paint()
        ..color = exerciseBlueBorder.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Progressed part in a brighter colour.
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isNotEmpty && progress > 0) {
      final metric = metrics.first;
      final segmentPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(
        segmentPath,
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Little pebbles along the sides.
    final pebble = Paint()..color = AppColors.textLight.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(w * 0.16, h - 26), 2.4, pebble);
    canvas.drawCircle(Offset(w * 0.48, h - 20), 2, pebble);
    canvas.drawCircle(Offset(w * 0.72, h - 30), 2.6, pebble);
    canvas.drawCircle(Offset(w * 0.9, h - 24), 2, pebble);
  }

  @override
  bool shouldRepaint(covariant _WalkingPathPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _WalkerPainter extends CustomPainter {
  final double step;
  final Color color;

  _WalkerPainter({required this.step, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;

    // Head.
    canvas.drawCircle(
      Offset(size.width / 2, 7),
      5.5,
      Paint()..color = color,
    );
    // Torso.
    canvas.drawLine(
      Offset(size.width / 2, 14),
      Offset(size.width / 2, 24),
      paint,
    );
    // Legs (swing while walking).
    final legAngle = step * 0.5;
    canvas.drawLine(
      Offset(size.width / 2, 23),
      Offset(size.width / 2 + 7 * math.sin(legAngle), 32),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 23),
      Offset(size.width / 2 - 7 * math.sin(legAngle), 32),
      paint,
    );
    // Arms (opposite swing).
    canvas.drawLine(
      Offset(size.width / 2, 16),
      Offset(size.width / 2 + 5 * math.sin(-legAngle), 22),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 16),
      Offset(size.width / 2 - 5 * math.sin(-legAngle), 22),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _WalkerPainter oldDelegate) =>
      oldDelegate.step != step;
}

// ---------------------------------------------------------------------------
// 4. CARDIO — gentle intensity scale
// ---------------------------------------------------------------------------
class CardioIntensityScaleVisual extends StatefulWidget {
  const CardioIntensityScaleVisual({super.key});

  @override
  State<CardioIntensityScaleVisual> createState() =>
      _CardioIntensityScaleVisualState();
}

class _CardioIntensityScaleVisualState extends State<CardioIntensityScaleVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _levels = [
    (
      icon: Icons.spa_outlined,
      label: 'Gentle',
      caption: 'Light effort, easy breathing — a slow stroll, easy stretching, gentle movement.',
      color: Color(0xFF45B69C),
      bg: Color(0xFFE2F5EE),
    ),
    (
      icon: Icons.speed_rounded,
      label: 'Moderate',
      caption: 'Noticeably warmer, breathing a little deeper — brisk walking, gentle cycling, dancing.',
      color: Color(0xFF5B7FFF),
      bg: Color(0xFFF0F4FF),
    ),
    (
      icon: Icons.trending_up_rounded,
      label: 'More challenging',
      caption: 'Optional — effortful but still talkable. Only if it feels right for you.',
      color: Color(0xFFC94A6E),
      bg: Color(0xFFFFF0F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _levels.length; i++) ...[
          ExerciseEnter(
            controller: _controller,
            index: i,
            total: _levels.length,
            child: _CardioLevelCard(level: _levels[i]),
          ),
          if (i < _levels.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: AppColors.textLight,
              ),
            ),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EFFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD8B4F8).withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            'Every level counts. A gentler choice is a real choice — not a fallback.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              height: 1.4,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardioLevelCard extends StatelessWidget {
  final ({IconData icon, String label, String caption, Color color, Color bg})
      level;

  const _CardioLevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: level.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: level.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(level.icon, size: 20, color: level.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  level.caption,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textMedium,
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

// ---------------------------------------------------------------------------
// 5. MOBILITY — body diagram with joints and gentle movement arcs
// ---------------------------------------------------------------------------
class JointMovementVisual extends StatefulWidget {
  const JointMovementVisual({super.key});

  @override
  State<JointMovementVisual> createState() => _JointMovementVisualState();
}

class _JointMovementVisualState extends State<JointMovementVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  int? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _joints = [
    (
      label: 'Shoulders',
      example: 'Slow shoulder circles, one direction at a time.',
      icon: Icons.autorenew_rounded,
      color: Color(0xFF5B7FFF),
    ),
    (
      label: 'Spine',
      example: 'Gentle spine waves — soft curves, never forced.',
      icon: Icons.waves_rounded,
      color: Color(0xFF9D76C1),
    ),
    (
      label: 'Hips',
      example: 'Small hip swings or gentle tilts — easy and light.',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF45B69C),
    ),
    (
      label: 'Ankles',
      example: 'Slow ankle rolls in each direction.',
      icon: Icons.rotate_right_rounded,
      color: Color(0xFFE8A33D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC7CEEA).withValues(alpha: 0.7),
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final auto = _selected == null
                  ? (_controller.value * _joints.length).floor()
                  : _selected!;
              final pulse =
                  0.35 + 0.65 * (0.5 + 0.5 * math.sin(2 * math.pi * _controller.value));
              return SizedBox(
                height: 190,
                width: double.infinity,
                child: CustomPaint(
                  painter: _JointBodyPainter(
                    selected: auto,
                    pulse: pulse,
                    joints: _joints.map((j) => j.color).toList(),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _joints.length; i++)
              GestureDetector(
                onTap: () =>
                    setState(() => _selected = _selected == i ? null : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selected == i
                        ? _joints[i].color.withValues(alpha: 0.14)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selected == i
                          ? _joints[i].color
                          : AppColors.borderGrey.withValues(alpha: 0.8),
                      width: _selected == i ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _joints[i].icon,
                        size: 14,
                        color: _selected == i
                            ? _joints[i].color
                            : AppColors.textLight,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _joints[i].label,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _selected == i
                              ? _joints[i].color
                              : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(_selected),
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selected == null
                    ? exerciseBlueBorder.withValues(alpha: 0.6)
                    : _joints[_selected!].color.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selected == null
                      ? Icons.touch_app_outlined
                      : _joints[_selected!].icon,
                  size: 16,
                  color: _selected == null
                      ? exerciseBlueDeep
                      : _joints[_selected!].color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selected == null
                        ? 'Each joint lights up in turn — tap one to focus on it.'
                        : _joints[_selected!].example,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JointBodyPainter extends CustomPainter {
  final int selected;
  final double pulse;
  final List<Color> joints;

  _JointBodyPainter({
    required this.selected,
    required this.pulse,
    required this.joints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w / 180, h / 180);
    final cx = w / 2;
    final top = (h - 170 * s) / 2;

    final limb = Paint()
      ..color = const Color(0xFF5B7FFF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * s
      ..strokeCap = StrokeCap.round;

    Offset offset(double dx, double dy) =>
        Offset(cx + dx * s, top + dy * s);

    // Head.
    canvas.drawCircle(offset(0, 26), 13 * s, Paint()..color = limb.color);

    // Neck.
    canvas.drawLine(offset(0, 40), offset(0, 50), limb);

    // Torso.
    canvas.drawLine(offset(0, 50), offset(0, 96), limb);

    // Arms.
    canvas.drawLine(offset(-20, 52), offset(-16, 70), limb);
    canvas.drawLine(offset(-16, 70), offset(-18, 88), limb);
    canvas.drawLine(offset(20, 52), offset(16, 70), limb);
    canvas.drawLine(offset(16, 70), offset(18, 88), limb);

    // Legs.
    canvas.drawLine(offset(-12, 96), offset(-8, 124), limb);
    canvas.drawLine(offset(-8, 124), offset(-10, 150), limb);
    canvas.drawLine(offset(-10, 150), offset(-2, 150), limb);
    canvas.drawLine(offset(12, 96), offset(8, 124), limb);
    canvas.drawLine(offset(8, 124), offset(10, 150), limb);
    canvas.drawLine(offset(10, 150), offset(2, 150), limb);

    // Joint points.
    final jointPositions = [
      offset(-20, 52), // shoulders (left used for the highlight point)
      offset(0, 72), // spine
      offset(-12, 96), // hips
      offset(-10, 150), // ankles
    ];

    for (var i = 0; i < jointPositions.length; i++) {
      final pos = jointPositions[i];
      final color = joints[i];
      final isSelected = i == selected;
      final fill = Paint()
        ..color = isSelected ? color : color.withValues(alpha: 0.25);
      canvas.drawCircle(pos, 7 * s, fill);

      // Movement arc for the selected joint.
      if (isSelected) {
        final arcPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * s
          ..strokeCap = StrokeCap.round;
        final arcRect = Rect.fromCircle(center: pos, radius: 15 * s);
        final startAngles = [
          -math.pi * 0.9,
          -math.pi * 0.1,
          -math.pi * 0.9,
          -math.pi * 0.1,
        ];
        canvas.drawArc(
          arcRect,
          startAngles[i],
          1.4 * math.pi * pulse,
          false,
          arcPaint,
        );
        canvas.drawCircle(
          pos,
          15 * s * (1 + 0.06 * pulse),
          Paint()
            ..color = color.withValues(alpha: 0.12)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5 * s,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JointBodyPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.pulse != pulse;
}

// ---------------------------------------------------------------------------
// 6. YOGA — calm transition between two beginner poses
// ---------------------------------------------------------------------------
class YogaPoseTransitionVisual extends StatefulWidget {
  const YogaPoseTransitionVisual({super.key});

  @override
  State<YogaPoseTransitionVisual> createState() =>
      _YogaPoseTransitionVisualState();
}

class _YogaPoseTransitionVisualState extends State<YogaPoseTransitionVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final showCatCow = (_controller.value % 1) >= 0.5;
        final breath =
            1.0 + 0.1 * math.sin(2 * math.pi * _controller.value * 2);
        final spinePhase = _controller.value;

        return Column(
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Breathing circle.
                  Transform.scale(
                    scale: breath,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9D76C1).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF9D76C1).withValues(alpha: 0.45),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 900),
                    child: showCatCow
                        ? CustomPaint(
                            key: const ValueKey('catcow'),
                            size: const Size(200, 150),
                            painter: _CatCowPainter(
                              phase: spinePhase,
                              color: const Color(0xFF5B7FFF),
                            ),
                          )
                        : CustomPaint(
                            key: const ValueKey('childs'),
                            size: const Size(200, 150),
                            painter: _ChildsPosePainter(
                              color: const Color(0xFF5B7FFF),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Row(
                key: ValueKey(showCatCow),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EEFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD8B4F8).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showCatCow
                              ? Icons.waves_rounded
                              : Icons.self_improvement_rounded,
                          size: 14,
                          color: const Color(0xFF7B4397),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          showCatCow
                              ? 'Cat–Cow — slow spine waves'
                              : 'Child\u2019s pose — rest & breathe',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7B4397),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Two gentle poses, one calm rhythm — move only as far as feels comfortable.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChildsPosePainter extends CustomPainter {
  final Color color;

  _ChildsPosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w / 200, h / 150);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s
      ..strokeCap = StrokeCap.round;

    // Kneeling block (hips and folded legs).
    final bodyPaint = Paint()..color = color.withValues(alpha: 0.16);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(46 * s, 92 * s, 88 * s, 40 * s),
      Radius.circular(22 * s),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Rounded back (spine curve from hips to shoulders).
    final backPath = Path()
      ..moveTo(60 * s, 96 * s)
      ..quadraticBezierTo(88 * s, 52 * s, 126 * s, 78 * s);
    canvas.drawPath(backPath, paint);

    // Head resting at the end.
    canvas.drawCircle(
      Offset(136 * s, 62 * s),
      12 * s,
      Paint()..color = color,
    );

    // Arms stretched forward along the floor.
    canvas.drawLine(
      Offset(112 * s, 92 * s),
      Offset(134 * s, 96 * s),
      paint,
    );
    canvas.drawLine(
      Offset(134 * s, 96 * s),
      Offset(152 * s, 98 * s),
      paint,
    );
    canvas.drawLine(
      Offset(100 * s, 98 * s),
      Offset(120 * s, 102 * s),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChildsPosePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CatCowPainter extends CustomPainter {
  final double phase;
  final Color color;

  _CatCowPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w / 200, h / 150);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s
      ..strokeCap = StrokeCap.round;

    // Spine with a slow wave (cat → cow → cat…).
    final wave = math.sin(phase * 2 * math.pi * 2) * 10 * s;
    final spine = Path()
      ..moveTo(92 * s, 60 * s)
      ..quadraticBezierTo(
        100 * s,
        78 * s + wave,
        88 * s,
        98 * s,
      );
    canvas.drawPath(spine, paint);

    // Head.
    canvas.drawCircle(
      Offset(112 * s, 52 * s),
      11 * s,
      Paint()..color = color,
    );

    // Legs.
    canvas.drawLine(Offset(92 * s, 94 * s), Offset(64 * s, 128 * s), paint);
    canvas.drawLine(Offset(64 * s, 128 * s), Offset(56 * s, 132 * s), paint);
    canvas.drawLine(Offset(88 * s, 96 * s), Offset(116 * s, 128 * s), paint);
    canvas.drawLine(Offset(116 * s, 128 * s), Offset(124 * s, 132 * s), paint);

    // Arms.
    canvas.drawLine(Offset(92 * s, 64 * s), Offset(60 * s, 104 * s), paint);
    canvas.drawLine(Offset(60 * s, 104 * s), Offset(52 * s, 108 * s), paint);
    canvas.drawLine(Offset(94 * s, 64 * s), Offset(126 * s, 102 * s), paint);
    canvas.drawLine(Offset(126 * s, 102 * s), Offset(134 * s, 106 * s), paint);
  }

  @override
  bool shouldRepaint(covariant _CatCowPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

// ---------------------------------------------------------------------------
// 7. PILATES — controlled movement sequence
// ---------------------------------------------------------------------------
class PilatesSequenceVisual extends StatefulWidget {
  const PilatesSequenceVisual({super.key});

  @override
  State<PilatesSequenceVisual> createState() => _PilatesSequenceVisualState();
}

class _PilatesSequenceVisualState extends State<PilatesSequenceVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 8000),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _steps = [
    (
      icon: Icons.air_rounded,
      title: 'Breathe in',
      caption: 'Settle into neutral — soft ribs, relaxed shoulders',
      color: Color(0xFF5B7FFF),
      bg: Color(0xFFF0F4FF),
    ),
    (
      icon: Icons.expand_more_rounded,
      title: 'Roll down',
      caption: 'Slowly round the spine down, then roll back up',
      color: Color(0xFF2E8B76),
      bg: Color(0xFFE9F7F1),
    ),
    (
      icon: Icons.rotate_left_rounded,
      title: 'Pelvic tilt',
      caption: 'A tiny back tilt on an easy exhale',
      color: Color(0xFF9D76C1),
      bg: Color(0xFFF5EEFC),
    ),
    (
      icon: Icons.arrow_upward_rounded,
      title: 'Small bridge lift',
      caption: 'Hips rise a hand\u2019s width, then lower with control',
      color: Color(0xFFE8A33D),
      bg: Color(0xFFFFF7E8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value * _steps.length;
        final active = math.min(_steps.length - 1, v.floor());
        final stepProgress = v - v.floor();
        return Column(
          children: [
            for (var i = 0; i < _steps.length; i++)
              _buildStep(i, active, stepProgress),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB5EAD7).withValues(alpha: 0.7),
                ),
              ),
              child: Text(
                'Slow, controlled movement — control matters more than speed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  height: 1.4,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(int index, int active, double stepProgress) {
    final step = _steps[index];
    final isActive = index == active;
    final isPast = index < active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive || isPast
                    ? step.bg
                    : step.bg.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? step.color
                      : step.color.withValues(alpha: 0.35),
                  width: isActive ? 1.8 : 1,
                ),
              ),
              child: Icon(
                step.icon,
                size: 20,
                color: isActive || isPast
                    ? step.color
                    : step.color.withValues(alpha: 0.5),
              ),
            ),
            if (index < _steps.length - 1)
              Container(
                width: 2,
                height: 14,
                color: AppColors.borderGrey.withValues(alpha: 0.7),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? step.bg : step.bg.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? step.color.withValues(alpha: 0.55)
                    : step.color.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.caption,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textMedium,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: stepProgress,
                      minHeight: 4,
                      backgroundColor: step.color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(step.color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 8. CYCLE — interactive menstrual-cycle movement wheel
// ---------------------------------------------------------------------------
class CycleMovementWheelVisual extends StatefulWidget {
  const CycleMovementWheelVisual({super.key});

  @override
  State<CycleMovementWheelVisual> createState() =>
      _CycleMovementWheelVisualState();
}

class _CycleMovementWheelVisualState extends State<CycleMovementWheelVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  int? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _phases = [
    (
      label: 'Menstruation',
      suggestion: 'Gentle movement or rest as needed — walking, stretching, breathing.',
      color: Color(0xFFE892A2),
      bg: Color(0xFFFFF0F3),
      icon: Icons.water_drop_rounded,
    ),
    (
      label: 'Follicular',
      suggestion: 'Build up activity if energy feels good.',
      color: Color(0xFF5B7FFF),
      bg: Color(0xFFF0F4FF),
      icon: Icons.eco_rounded,
    ),
    (
      label: 'Ovulation',
      suggestion: 'Choose comfortable activity based on how you feel.',
      color: Color(0xFF45B69C),
      bg: Color(0xFFE2F5EE),
      icon: Icons.wb_sunny_rounded,
    ),
    (
      label: 'Luteal',
      suggestion: 'Adjust intensity according to energy and symptoms.',
      color: Color(0xFFE8A33D),
      bg: Color(0xFFFFF7E8),
      icon: Icons.nights_stay_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 280.0);
        final cx = size / 2;
        final cy = size / 2;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final auto = _selected ??
                (_controller.value * _phases.length).floor();
            return Column(
              children: [
                SizedBox(
                  width: size,
                  height: size + 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: _CycleWheelPainter(
                          colors: _phases.map((p) => p.color).toList(),
                          highlight: auto,
                        ),
                      ),
                      for (var i = 0; i < _phases.length; i++)
                        _buildPhaseLabel(i, cx, cy, size, auto),
                      Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: exerciseBlueDeep.withValues(alpha: 0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                size: 20,
                                color: exerciseBlueDeep,
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  'Your choice',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _phases[auto].bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _phases[auto].color.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _phases[auto].icon,
                        size: 18,
                        color: _phases[auto].color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _phases[auto].label,
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _phases[auto].suggestion,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                height: 1.4,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Flexible suggestions, not rules — listen to how you feel.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPhaseLabel(
    int index,
    double cx,
    double cy,
    double size,
    int highlight,
  ) {
    final phase = _phases[index];
    final angle = -math.pi / 2 + (index * 2 * math.pi / _phases.length);
    final radius = size / 2 - 24;
    final x = cx + radius * math.cos(angle);
    final y = cy + radius * math.sin(angle);
    final isHighlight = index == highlight;

    return Positioned(
      left: x - 42,
      top: y - 42,
      child: GestureDetector(
        onTap: () => setState(() => _selected = _selected == index ? null : index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHighlight
                ? phase.color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.85),
            border: Border.all(
              color: isHighlight
                  ? phase.color
                  : phase.color.withValues(alpha: 0.45),
              width: isHighlight ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                phase.icon,
                size: 20,
                color: isHighlight ? phase.color : phase.color.withValues(alpha: 0.75),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  phase.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleWheelPainter extends CustomPainter {
  final List<Color> colors;
  final int highlight;

  _CycleWheelPainter({
    required this.colors,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final inner = size.width / 2 - 54;
    final outer = size.width / 2 - 2;
    final strokeWidth = outer - inner;
    final rect = Rect.fromCircle(center: center, radius: (inner + outer) / 2);

    final segment = 2 * math.pi / colors.length;
    for (var i = 0; i < colors.length; i++) {
      final start = -math.pi / 2 + i * segment;
      final paint = Paint()
        ..color = i == highlight
            ? colors[i]
            : colors[i].withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == highlight ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, segment - 0.04, false, paint);
    }

    // Inner soft disc.
    canvas.drawCircle(
      center,
      inner,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _CycleWheelPainter oldDelegate) =>
      oldDelegate.highlight != highlight;
}

// ---------------------------------------------------------------------------
// Workout mini-visuals (shared by workout screens)
// ---------------------------------------------------------------------------

/// Low-impact marching figure — no jumping, one foot always grounded.
class LowImpactMarchVisual extends StatefulWidget {
  const LowImpactMarchVisual({super.key});

  @override
  State<LowImpactMarchVisual> createState() => _LowImpactMarchVisualState();
}

class _LowImpactMarchVisualState extends State<LowImpactMarchVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F5EE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFB5EAD7).withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: CustomPaint(
                  painter: _MarchPainter(
                    phase: _controller.value,
                    color: const Color(0xFF45B69C),
                  ),
                ),
              ),
              Text(
                'No jumping — one foot stays grounded',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E8B76),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MarchPainter extends CustomPainter {
  final double phase;
  final Color color;

  _MarchPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 18;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Gentle body sway (very small bounce).
    final sway = math.sin(phase * 2 * math.pi) * 1.5;

    // Head.
    canvas.drawCircle(
      Offset(cx, 22 + sway),
      9,
      Paint()..color = color,
    );
    // Torso.
    canvas.drawLine(
      Offset(cx, 32 + sway),
      Offset(cx, 54 + sway),
      paint,
    );

    // Legs — alternate small marches (soft knee lifts).
    final legAngle = math.sin(phase * 2 * math.pi) * 0.45;
    canvas.drawLine(
      Offset(cx, 52 + sway),
      Offset(cx + 9 * math.sin(legAngle), groundY - 4),
      paint,
    );
    canvas.drawLine(
      Offset(cx, 52 + sway),
      Offset(cx - 9 * math.sin(legAngle), groundY - 4),
      paint,
    );

    // Arms — opposite swing.
    canvas.drawLine(
      Offset(cx, 36 + sway),
      Offset(cx + 7 * math.sin(-legAngle), 48 + sway),
      paint,
    );
    canvas.drawLine(
      Offset(cx, 36 + sway),
      Offset(cx - 7 * math.sin(-legAngle), 48 + sway),
      paint,
    );

    // Ground line.
    canvas.drawLine(
      Offset(cx - 40, groundY),
      Offset(cx + 40, groundY),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MarchPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// Calm breathing ring used by relaxation-style workouts.
class BreathRingVisual extends StatefulWidget {
  final Color color;
  final Color lightBackground;

  const BreathRingVisual({
    super.key,
    this.color = const Color(0xFF9D76C1),
    this.lightBackground = const Color(0xFFF5EEFC),
  });

  @override
  State<BreathRingVisual> createState() => _BreathRingVisualState();
}

class _BreathRingVisualState extends State<BreathRingVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        final inPhase = (v % 1) < 0.5;
        final breath = 1.0 + 0.12 * math.sin(2 * math.pi * v);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.lightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Center(
                  child: Transform.scale(
                    scale: breath,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withValues(alpha: 0.14),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                inPhase ? 'Breathe in\u2026' : 'Breathe out\u2026',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Let your breath move at its own calm pace.',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}