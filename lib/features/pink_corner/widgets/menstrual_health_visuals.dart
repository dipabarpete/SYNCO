import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/menstrual_health_topic.dart';
import 'menstrual_health_comparison_visuals.dart';
import 'menstrual_uterus_painter.dart';

/// Top-level educational visual for a Menstrual Health topic.
///
/// Renders the visual chosen by [topic.visualType] inside a clean card,
/// with a text caption so every visual concept also has a text alternative.
class MenstrualTopicVisual extends StatelessWidget {
  final MenstrualHealthTopic topic;

  const MenstrualTopicVisual({super.key, required this.topic});

  static const Map<MenstrualTopicVisualType, String> _captions = {
    MenstrualTopicVisualType.cycleWheel:
        'An animated wheel showing the four phases of the cycle — Menstruation, Follicular, Ovulation and Luteal — with the ovary, uterus and uterine lining labeled.',
    MenstrualTopicVisualType.flowScale:
        'An interactive flow scale. Tap each level to explore what light, moderate and heavier flow can feel like.',
    MenstrualTopicVisualType.heavyBleedingComparison:
        'A simple comparison between typical variation and potentially heavy bleeding, with a gentle reminder to talk to a professional when a pattern repeats.',
    MenstrualTopicVisualType.spottingComparison:
        'A side-by-side comparison between spotting and a typical menstrual flow.',
    MenstrualTopicVisualType.pmsPmddComparison:
        'An interactive comparison between PMS and PMDD. Tap each card to explore symptoms, severity and effect on daily life.',
    MenstrualTopicVisualType.clotDiagram:
        'A simple diagram comparing small, occasional clots with larger or frequent ones.',
    MenstrualTopicVisualType.colorTimeline:
        'An animated timeline of common period blood colors: Bright Red, Dark Red, Brown and Pinkish.',
    MenstrualTopicVisualType.painAnimation:
        'A gentle animation of the uterus with common comfort measures — heat, gentle movement and rest.',
    MenstrualTopicVisualType.trafficLight:
        'A traffic-light guide with three levels: Monitor & Track, Talk to a Doctor Soon, and Seek Urgent Medical Care.',
  };

  @override
  Widget build(BuildContext context) {
    final Widget visual = switch (topic.visualType) {
      MenstrualTopicVisualType.cycleWheel => CycleWheelVisual(topic: topic),
      MenstrualTopicVisualType.flowScale => FlowScaleVisual(topic: topic),
      MenstrualTopicVisualType.heavyBleedingComparison =>
        HeavyBleedingComparisonVisual(topic: topic),
      MenstrualTopicVisualType.spottingComparison =>
        SpottingComparisonVisual(topic: topic),
      MenstrualTopicVisualType.pmsPmddComparison =>
        PmsPmddComparisonVisual(topic: topic),
      MenstrualTopicVisualType.clotDiagram => ClotDiagramVisual(topic: topic),
      MenstrualTopicVisualType.colorTimeline =>
        ColorTimelineVisual(topic: topic),
      MenstrualTopicVisualType.painAnimation =>
        PainAnimationVisual(topic: topic),
      MenstrualTopicVisualType.trafficLight => TrafficLightVisual(topic: topic),
    };

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
          Semantics(
            label: _captions[topic.visualType],
            child: visual,
          ),
          const SizedBox(height: 12),
          Text(
            _captions[topic.visualType]!,
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

/// Small helpers to read the typed [visualData] map.
Map<String, dynamic> _asMap(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<Map<String, dynamic>> _asMapList(dynamic value) =>
    (value as List).map((e) => _asMap(e)).toList();

// ---------------------------------------------------------------------------
// 1. Animated circular cycle wheel
// ---------------------------------------------------------------------------
class _CyclePhase {
  final String name;
  final String caption;
  final Color color;
  final IconData icon;

  const _CyclePhase({
    required this.name,
    required this.caption,
    required this.color,
    required this.icon,
  });
}

const _cyclePhases = [
  _CyclePhase(
    name: 'Menstruation',
    caption: 'The uterine lining sheds. This is your period.',
    color: Color(0xFFFFD1DC),
    icon: Icons.water_drop_rounded,
  ),
  _CyclePhase(
    name: 'Follicular Phase',
    caption: 'An egg matures in the ovary, and the lining starts to rebuild.',
    color: Color(0xFFD8B4F8),
    icon: Icons.blur_circular_rounded,
  ),
  _CyclePhase(
    name: 'Ovulation',
    caption: 'A mature egg is released. This often happens mid-cycle.',
    color: Color(0xFFB5EAD7),
    icon: Icons.flare_rounded,
  ),
  _CyclePhase(
    name: 'Luteal Phase',
    caption: 'The lining prepares in case of pregnancy. If not, your period begins.',
    color: Color(0xFFFFE0B2),
    icon: Icons.spa_rounded,
  ),
];

class CycleWheelVisual extends StatefulWidget {
  final MenstrualHealthTopic topic;

  const CycleWheelVisual({super.key, required this.topic});

  @override
  State<CycleWheelVisual> createState() => _CycleWheelVisualState();
}

class _CycleWheelVisualState extends State<CycleWheelVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ringRadius = 80.0;

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = _controller.value;
              final phaseIndex = (value * 4).floor() % 4;
              final phase = _cyclePhases[phaseIndex];
              final angle = value * math.pi * 2 - math.pi / 2;
              final pointerOffset = Offset(
                ringRadius * math.cos(angle),
                ringRadius * math.sin(angle),
              );

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Phase ring
                  CustomPaint(
                    size: const Size(ringRadius * 2, ringRadius * 2),
                    painter: _CycleRingPainter(
                      phases: _cyclePhases,
                      accent: widget.topic.accentColor,
                    ),
                  ),
                  // Center uterus diagram
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomPaint(
                        painter: const SimpleUterusPainter(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  // Rotating pointer
                  Transform.translate(
                    offset: pointerOffset,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.topic.accentColor,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  // Phase labels
                  _PhaseLabel(
                    label: 'Menstruation',
                    color: _cyclePhases[0].color,
                    align: const Alignment(0, -0.92),
                  ),
                  _PhaseLabel(
                    label: 'Follicular',
                    color: _cyclePhases[1].color,
                    align: const Alignment(0.98, -0.1),
                  ),
                  _PhaseLabel(
                    label: 'Ovulation',
                    color: _cyclePhases[2].color,
                    align: const Alignment(0, 0.94),
                  ),
                  _PhaseLabel(
                    label: 'Luteal',
                    color: _cyclePhases[3].color,
                    align: const Alignment(-0.98, -0.1),
                  ),
                  // Current phase caption chip
                  Align(
                    alignment: const Alignment(0.98, 0.98),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: phase.color.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: phase.color.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(phase.icon, size: 14, color: AppColors.textDark),
                          const SizedBox(width: 4),
                          Text(
                            phase.name,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
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
        const SizedBox(height: 4),
        // Phase explanation (switches as the wheel rotates)
        SizedBox(
          height: 92,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = _controller.value;
              final phaseIndex = (value * 4).floor() % 4;
              final phase = _cyclePhases[phaseIndex];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: phase.color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: phase.color.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    key: ValueKey(phaseIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            phase.icon,
                            size: 18,
                            color: widget.topic.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            phase.name,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phase.caption,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // Anatomy legend
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: const [
            _LegendChip(
              icon: Icons.lens_rounded,
              iconColor: Color(0xFFE8A33D),
              label: 'Ovary',
            ),
            _LegendChip(
              icon: Icons.favorite_rounded,
              iconColor: Color(0xFFC94A6E),
              label: 'Uterus',
            ),
            _LegendChip(
              icon: Icons.crop_landscape_rounded,
              iconColor: Color(0xFF7B4397),
              label: 'Uterine lining',
            ),
            _LegendChip(
              icon: Icons.blur_circular_rounded,
              iconColor: Color(0xFF45B69C),
              label: 'Egg',
            ),
          ],
        ),
      ],
    );
  }
}

class _PhaseLabel extends StatelessWidget {
  final String label;
  final Color color;
  final Alignment align;

  const _PhaseLabel({
    required this.label,
    required this.color,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _LegendChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.babyPink.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blushPinkLight.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final List<_CyclePhase> phases;
  final Color accent;

  const _CycleRingPainter({required this.phases, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    for (var i = 0; i < phases.length; i++) {
      final startAngle = -math.pi / 2 + i * math.pi / 2;
      final paint = Paint()
        ..color = phases[i].color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.06, // small gap between segments
        math.pi / 2 - 0.12,
        false,
        paint,
      );
    }

    // Subtle outer ring
    final outerPaint = Paint()
      ..color = accent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, outerPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

// ---------------------------------------------------------------------------
// 2. Interactive flow scale (used by Period Flow and Light Periods)
// ---------------------------------------------------------------------------
class FlowScaleVisual extends StatefulWidget {
  final MenstrualHealthTopic topic;

  const FlowScaleVisual({super.key, required this.topic});

  @override
  State<FlowScaleVisual> createState() => _FlowScaleVisualState();
}

class _FlowScaleVisualState extends State<FlowScaleVisual> {
  int _selected = 1;

  List<Map<String, dynamic>> get _levels {
    final data = widget.topic.visualData?['levels'];
    if (data == null) {
      return const [
        {'label': 'Light', 'caption': 'A lighter flow.'},
        {'label': 'Moderate', 'caption': 'A typical flow for many people.'},
        {'label': 'Heavier', 'caption': 'A faster flow.'},
      ];
    }
    return _asMapList(data);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.topic.accentColor;
    final levels = _levels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(levels.length, (index) {
            final level = levels[index];
            final selected = index == _selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selected = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(
                    right: index == levels.length - 1 ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? accent
                          : AppColors.borderGrey.withValues(alpha: 0.7),
                      width: selected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 18.0 + index * 9,
                        color: selected ? accent : AppColors.textLight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        level['label'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: selected ? accent : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        // Flow visualization bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 10,
            color: accent.withValues(alpha: 0.25),
            child: FractionallySizedBox(
              alignment: Alignment.topLeft,
              widthFactor: (_selected + 1) / (levels.length + 1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.5),
                      accent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_selected),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.babyPink.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              levels[_selected]['caption'] as String,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap each level to learn more. Your own pattern is the best reference.',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}