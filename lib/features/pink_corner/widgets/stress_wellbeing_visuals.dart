import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/stress_wellbeing_topic.dart';

/// Mint accent shared across the Stress & Well-being Learn card.
const Color stressMintDeep = Color(0xFF45B69C);
const Color stressMintBorder = Color(0xFFB5EAD7);
const Color stressMintLight = Color(0xFFE2F5EE);
const Color stressMintCardBg = Color(0xFFF0FDF4);

/// Top-level educational visual for a Stress & Well-being topic.
///
/// Renders the visual chosen by [topic.visualType] inside a clean card,
/// with a text caption so every visual concept also has a text alternative.
class StressTopicVisual extends StatelessWidget {
  final StressWellbeingTopic topic;

  const StressTopicVisual({super.key, required this.topic});

  static const Map<StressVisualType, String> _captions = {
    StressVisualType.stressResponse:
        'A gentle cycle of four steps: a challenge appears, the body and mind respond, '
        'feelings and thoughts change, and recovery slowly settles everything down again.',
    StressVisualType.stressDurationComparison:
        'Two simple waves: a short, quick burst of acute stress, and a longer, sustained line '
        'of ongoing stress. Both are common experiences — not predictions of illness.',
    StressVisualType.connectedParts:
        'A small relationship diagram connecting stress with sleep, mood, and energy. '
        'Tap each area to explore how stress can sometimes be linked with it.',
    StressVisualType.cycleTracking:
        'A three-step timeline: stress and well-being change over time, tracking helps you '
        'notice patterns, and patterns can show links with your menstrual cycle — not proof of cause.',
    StressVisualType.anxiousThoughts:
        'Thought bubbles circling a slow-breathing ring. As you breathe out, the bubbles drift '
        'a little further apart, giving racing thoughts more space.',
    StressVisualType.moodScale:
        'A gentle, non-diagnostic three-step guide — feeling okay, feeling low, and needing '
        'more support. It is a conversation aid, not a test.',
    StressVisualType.bodyImage:
        'Comparison figures gently fade into the background while a simple self-care message '
        'becomes more prominent: your body deserves kindness, not comparison.',
    StressVisualType.selfEsteemBlocks:
        'Small positive actions stacking one by one into a stable foundation — built slowly, '
        'block by block, with self-compassion.',
    StressVisualType.emotionalEatingWheel:
        'An interactive support wheel: pause, ask \u201cwhat do I need?\u201d, then choose between '
        'food, rest, connection, movement, or support — no labels, no judgement.',
    StressVisualType.healthJourney:
        'A gentle five-step journey — understand, track, adjust, ask for help, continue. '
        'A chronic-condition journey is a loop with stops and turns, not a straight line.',
    StressVisualType.seekHelpTrafficLight:
        'A calm three-level guide: green for self-care and monitoring, yellow for considering '
        'professional support, and red for seeking urgent professional help.',
  };

  @override
  Widget build(BuildContext context) {
    final Widget visual = switch (topic.visualType) {
      StressVisualType.stressResponse => const StressResponseVisual(),
      StressVisualType.stressDurationComparison =>
        const StressDurationComparisonVisual(),
      StressVisualType.connectedParts => ConnectedPartsVisual(topic: topic),
      StressVisualType.cycleTracking => const CycleTrackingVisual(),
      StressVisualType.anxiousThoughts => const AnxiousThoughtsVisual(),
      StressVisualType.moodScale => const GentleMoodScaleVisual(),
      StressVisualType.bodyImage => const BodyImageVisual(),
      StressVisualType.selfEsteemBlocks => const SelfEsteemBlocksVisual(),
      StressVisualType.emotionalEatingWheel => const EmotionalEatingWheelVisual(),
      StressVisualType.healthJourney => const HealthJourneyVisual(),
      StressVisualType.seekHelpTrafficLight =>
        SeekHelpTrafficLightVisual(data: topic.visualData),
    };

    return _StressVisualCard(
      caption: _captions[topic.visualType]!,
      child: Semantics(
        label: _captions[topic.visualType],
        child: visual,
      ),
    );
  }
}

/// Shared white card shell with the "Visual guide" header and caption.
class _StressVisualCard extends StatelessWidget {
  final String caption;
  final Widget child;

  const _StressVisualCard({required this.caption, required this.child});

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

// ---------------------------------------------------------------------------
// 1. What Is Stress? — stress response cycle
// ---------------------------------------------------------------------------
class StressResponseVisual extends StatefulWidget {
  const StressResponseVisual({super.key});

  @override
  State<StressResponseVisual> createState() => _StressResponseVisualState();
}

class _StressResponseVisualState extends State<StressResponseVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5600),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _steps = [
    (
      icon: Icons.schedule_rounded,
      title: 'A challenge appears',
      caption: 'A deadline, a change, a tough moment',
      color: Color(0xFF5B7FFF),
      bg: Color(0xFFF0F4FF),
    ),
    (
      icon: Icons.monitor_heart_outlined,
      title: 'Body & mind respond',
      caption: 'Heartbeat quickens, muscles tense, thoughts race',
      color: Color(0xFF45B69C),
      bg: Color(0xFFE2F5EE),
    ),
    (
      icon: Icons.psychology_outlined,
      title: 'Feelings & thoughts shift',
      caption: 'Worry, irritation, shaky or heavy feelings',
      color: Color(0xFFE8A33D),
      bg: Color(0xFFFFF7E8),
    ),
    (
      icon: Icons.spa_outlined,
      title: 'Recovery',
      caption: 'With rest and support, this gradually settles',
      color: Color(0xFF7B4397),
      bg: Color(0xFFF4EFFB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value * _steps.length;
        final active = math.min(_steps.length - 1, v.floor());
        final progressInStep =
            (_controller.value * _steps.length) - v.floor();
        return Column(
          children: [
            for (var i = 0; i < _steps.length; i++) _buildStep(i, active, progressInStep),
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
              curve: Curves.easeOut,
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.caption,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
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
// 2. Acute vs Chronic Stress — short wave vs long sustained line
// ---------------------------------------------------------------------------
class StressDurationComparisonVisual extends StatefulWidget {
  const StressDurationComparisonVisual({super.key});

  @override
  State<StressDurationComparisonVisual> createState() =>
      _StressDurationComparisonVisualState();
}

class _StressDurationComparisonVisualState
    extends State<StressDurationComparisonVisual>
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _WaveCard(
            title: 'Short-term',
            tagline: 'Rises, then settles',
            color: stressMintDeep,
            bg: stressMintLight,
            painter: _ShortSpikePainter(color: stressMintDeep),
            animation: _controller,
            note: 'Often tied to a specific event, and usually settles after it passes.',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _WaveCard(
            title: 'Ongoing',
            tagline: 'Can feel harder to switch off',
            color: const Color(0xFF7B4397),
            bg: const Color(0xFFF4EFFB),
            painter: _LongWavePainter(color: const Color(0xFF7B4397)),
            animation: _controller,
            note: 'Persists over time and may affect sleep, mood, energy, and daily life.',
          ),
        ),
      ],
    );
  }
}

class _WaveCard extends StatelessWidget {
  final String title;
  final String tagline;
  final Color color;
  final Color bg;
  final CustomPainter painter;
  final Animation<double> animation;
  final String note;

  const _WaveCard({
    required this.title,
    required this.tagline,
    required this.color,
    required this.bg,
    required this.painter,
    required this.animation,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tagline,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) => CustomPaint(
                painter: painter,
                size: const Size(double.infinity, 64),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              height: 1.4,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortSpikePainter extends CustomPainter {
  final Color color;

  _ShortSpikePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(2, size.height - 8);
    // A quick hump that climbs and settles back down.
    path.cubicTo(
      size.width * 0.2, size.height - 8,
      size.width * 0.25, 6,
      size.width * 0.42, size.height - 8,
    );
    path.cubicTo(
      size.width * 0.55, size.height - 8,
      size.width * 0.58, 18,
      size.width * 0.68, size.height - 8,
    );
    path.lineTo(size.width - 2, size.height - 8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShortSpikePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LongWavePainter extends CustomPainter {
  final Color color;

  _LongWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(2, size.height - 8)
      ..cubicTo(
        size.width * 0.2, size.height - 8,
        size.width * 0.3, size.height * 0.55,
        size.width * 0.45, size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.6, size.height * 0.55,
        size.width * 0.7, size.height * 0.4,
        size.width * 0.85, size.height * 0.4,
      )
      ..lineTo(size.width - 2, size.height * 0.4);
    canvas.drawPath(path, paint);
    // Small moments of rest along the line.
    final restPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.55),
      2.5,
      restPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LongWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// 3. Stress, Sleep & Mood — connected parts (tap to explore)
// ---------------------------------------------------------------------------
class ConnectedPartsVisual extends StatefulWidget {
  final StressWellbeingTopic topic;

  const ConnectedPartsVisual({super.key, required this.topic});

  @override
  State<ConnectedPartsVisual> createState() => _ConnectedPartsVisualState();
}

class _ConnectedPartsVisualState extends State<ConnectedPartsVisual> {
  int? _selected;

  static const _parts = [
    (
      icon: Icons.bedtime_outlined,
      label: 'Sleep',
      fact: 'Stress can sometimes make it harder to fall asleep, stay asleep, or feel rested.',
    ),
    (
      icon: Icons.mood_rounded,
      label: 'Mood',
      fact: 'Stress can sometimes bring irritability, worry, or low mood for a while.',
    ),
    (
      icon: Icons.bolt_rounded,
      label: 'Energy',
      fact: 'Stress can sometimes drain energy — or, at other times, leave you feeling wired.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF43D1A8), Color(0xFF45B69C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: stressMintDeep.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.self_improvement_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'Stress',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 2,
          height: 18,
          color: AppColors.borderGrey.withValues(alpha: 0.8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < 3; i++) _buildPartNode(i),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selected == null
              ? Container(
                  key: const ValueKey('hint'),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: stressMintCardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stressMintBorder.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    'Tap an area to explore how stress can sometimes be connected with it.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.textMedium,
                    ),
                  ),
                )
              : Container(
                  key: ValueKey(_selected),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EFFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD8B4F8).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _parts[_selected!].icon,
                        size: 18,
                        color: AppColors.softPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _parts[_selected!].fact,
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
        ),
      ],
    );
  }

  Widget _buildPartNode(int index) {
    final part = _parts[index];
    final selected = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = selected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0F4FF)
              : const Color(0xFFF0F4FF).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B7FFF)
                : const Color(0xFF5B7FFF).withValues(alpha: 0.3),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              part.icon,
              size: 20,
              color: selected
                  ? const Color(0xFF5B7FFF)
                  : const Color(0xFF5B7FFF).withValues(alpha: 0.65),
            ),
            const SizedBox(height: 4),
            Text(
              part.label,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Stress & Menstrual Symptoms — tracking timeline
// ---------------------------------------------------------------------------
class CycleTrackingVisual extends StatefulWidget {
  const CycleTrackingVisual({super.key});

  @override
  State<CycleTrackingVisual> createState() => _CycleTrackingVisualState();
}

class _CycleTrackingVisualState extends State<CycleTrackingVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _steps = [
    (
      icon: Icons.self_improvement_rounded,
      title: 'Stress & well-being',
      caption: 'Feelings and pressures shift over days and weeks',
      color: Color(0xFF45B69C),
      bg: Color(0xFFE2F5EE),
    ),
    (
      icon: Icons.calendar_month_rounded,
      title: 'Tracking over time',
      caption: 'The app records your cycle, symptoms, stress, and sleep',
      color: Color(0xFF5B7FFF),
      bg: Color(0xFFF0F4FF),
    ),
    (
      icon: Icons.insights_rounded,
      title: 'Notice menstrual patterns',
      caption: 'Over cycles, patterns may become clearer — not proof, just patterns',
      color: Color(0xFFC94A6E),
      bg: Color(0xFFFFF0F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value * _steps.length;
        final active = math.min(_steps.length - 1, v.floor());
        final stepProgress = (_controller.value * _steps.length) - v.floor();
        return Column(
          children: [
            for (var i = 0; i < _steps.length; i++)
              _TimelineRow(
                step: _steps[i],
                index: i,
                isLast: i == _steps.length - 1,
                isActive: i == active,
                isPast: i < active,
                progress: stepProgress,
              ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8A33D).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFE8A33D),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The app helps you notice patterns — it does not prove that stress caused any cycle change.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final ({IconData icon, String title, String caption, Color color, Color bg})
      step;
  final int index;
  final bool isLast;
  final bool isActive;
  final bool isPast;
  final double progress;

  const _TimelineRow({
    required this.step,
    required this.index,
    required this.isLast,
    required this.isActive,
    required this.isPast,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive || isPast ? step.bg : step.bg.withValues(alpha: 0.45),
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
            if (!isLast)
              Container(
                width: 2,
                height: 16,
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
                      value: progress,
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
// 5. Anxiety — thought bubbles spaced by slow breathing
// ---------------------------------------------------------------------------
class AnxiousThoughtsVisual extends StatefulWidget {
  const AnxiousThoughtsVisual({super.key});

  @override
  State<AnxiousThoughtsVisual> createState() => _AnxiousThoughtsVisualState();
}

class _AnxiousThoughtsVisualState extends State<AnxiousThoughtsVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    _drift.dispose();
    super.dispose();
  }

  static const _thoughts = [
    'What if something goes wrong?',
    'Did I say the right thing?',
    'Why can\u2019t I relax?',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 300.0);
        return AnimatedBuilder(
          animation: Listenable.merge([_breath, _drift]),
          builder: (context, child) {
            final scale = 1.0 + (_breath.value * 0.30);
            final drift = _drift.value * 14.0;
            return SizedBox(
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: width * 0.10 - drift * 0.5,
                    child: _ThoughtBubble(text: _thoughts[0]),
                  ),
                  Positioned(
                    top: 30,
                    right: width * 0.06 + drift * 0.45,
                    child: _ThoughtBubble(text: _thoughts[1]),
                  ),
                  Positioned(
                    top: 92,
                    left: width * 0.04 + drift,
                    child: _ThoughtBubble(text: _thoughts[2]),
                  ),
                  Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stressMintDeep.withValues(alpha: 0.16),
                          border: Border.all(
                            color: stressMintDeep.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stressMintDeep.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: stressMintLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Thoughts drift apart as you breathe out',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: stressMintDeep,
                          fontWeight: FontWeight.w600,
                        ),
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
}

class _ThoughtBubble extends StatelessWidget {
  final String text;

  const _ThoughtBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD8B4F8).withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Low Mood — gentle, non-diagnostic mood scale
// ---------------------------------------------------------------------------
class GentleMoodScaleVisual extends StatelessWidget {
  const GentleMoodScaleVisual({super.key});

  static const _steps = [
    (
      icon: Icons.sentiment_satisfied_alt_rounded,
      label: 'Feeling okay',
      caption: 'Mood dips that lift within days',
      color: Color(0xFF2E8B76),
      bg: Color(0xFFE9F7F1),
    ),
    (
      icon: Icons.cloud_outlined,
      label: 'Feeling low',
      caption: 'Heavy days that come and go',
      color: Color(0xFFE8A33D),
      bg: Color(0xFFFFF7E8),
    ),
    (
      icon: Icons.volunteer_activism_rounded,
      label: 'Need more support',
      caption: 'When lows persist and daily life gets hard',
      color: Color(0xFFC94A6E),
      bg: Color(0xFFFFF0F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Column(
            children: [
              _MoodStep(step: _steps[i]),
              if (i < _steps.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 6),
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
            'This is a gentle guide for conversations — not a test, and not a diagnosis.',
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

class _MoodStep extends StatelessWidget {
  final ({IconData icon, String label, String caption, Color color, Color bg})
      step;

  const _MoodStep({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: step.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: step.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 20, color: step.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.caption,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.35,
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
// 7. Body Image — comparison fades, kind message grows
// ---------------------------------------------------------------------------
class BodyImageVisual extends StatefulWidget {
  const BodyImageVisual({super.key});

  @override
  State<BodyImageVisual> createState() => _BodyImageVisualState();
}

class _BodyImageVisualState extends State<BodyImageVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3800),
  )..forward();
  late final Animation<double> _fadeOut = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
  );
  late final Animation<double> _messageIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
  );

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
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Opacity(
                    opacity: 1 - _fadeOut.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 26,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Transform.scale(
              scale: 0.9 + (0.1 * _messageIn.value),
              child: Opacity(
                opacity: math.min(1.0, _messageIn.value * 1.4),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF0F5), Color(0xFFE8DFF5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD1DC).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 24,
                        color: AppColors.rosePink,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your body supports you every day.\nIt deserves kindness — not comparison.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: AppColors.textDark,
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
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Self-Esteem — blocks stacking into a foundation
// ---------------------------------------------------------------------------
class SelfEsteemBlocksVisual extends StatefulWidget {
  const SelfEsteemBlocksVisual({super.key});

  @override
  State<SelfEsteemBlocksVisual> createState() => _SelfEsteemBlocksVisualState();
}

class _SelfEsteemBlocksVisualState extends State<SelfEsteemBlocksVisual>
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

  static const _blocks = [
    'Speak kindly to yourself',
    'Notice small wins',
    'Set a gentle boundary',
    'Ask for help',
    'Rest without guilt',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            for (var i = 0; i < _blocks.length; i++)
              _buildBlock(i),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.insights_rounded, size: 18, color: stressMintDeep),
                const SizedBox(width: 6),
                Text(
                  'Small, repeated actions build a steady foundation',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: stressMintDeep,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlock(int index) {
    final start = index / _blocks.length;
    final end = (index + 1) / _blocks.length;
    final local = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );
    final visible = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, math.min(end, start + 0.15)),
    );
    final colors = [
      const Color(0xFF43D1A8),
      const Color(0xFF5B7FFF),
      const Color(0xFF9D76C1),
      const Color(0xFFE892A2),
      const Color(0xFF45B69C),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - local.value)),
        child: Opacity(
          opacity: visible.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors[index].withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _blocks[index],
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Emotional Eating — feelings / needs support wheel
// ---------------------------------------------------------------------------
class EmotionalEatingWheelVisual extends StatefulWidget {
  const EmotionalEatingWheelVisual({super.key});

  @override
  State<EmotionalEatingWheelVisual> createState() =>
      _EmotionalEatingWheelVisualState();
}

class _EmotionalEatingWheelVisualState extends State<EmotionalEatingWheelVisual> {
  int? _selected;

  static const _nodes = [
    (
      icon: Icons.restaurant_rounded,
      label: 'Food',
      fact: 'Food can comfort, nourish, or simply taste good — all of it is okay.',
      color: Color(0xFFE892A2),
      bg: Color(0xFFFFF3F6),
    ),
    (
      icon: Icons.bedtime_outlined,
      label: 'Rest',
      fact: 'A nap, a quiet moment, or an early night can soften heavy feelings.',
      color: Color(0xFF5B7FFF),
      bg: Color(0xFFF0F4FF),
    ),
    (
      icon: Icons.people_alt_rounded,
      label: 'Connection',
      fact: 'A call or message to someone who gets you.',
      color: Color(0xFF9D76C1),
      bg: Color(0xFFF8F0FF),
    ),
    (
      icon: Icons.directions_walk_rounded,
      label: 'Movement',
      fact: 'A short walk, gentle stretching, or dancing to one song.',
      color: Color(0xFF45B69C),
      bg: Color(0xFFE2F5EE),
    ),
    (
      icon: Icons.volunteer_activism_rounded,
      label: 'Support',
      fact: 'Talking to a professional about eating patterns is normal and helpful.',
      color: Color(0xFFE8A33D),
      bg: Color(0xFFFFF7E8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: stressMintCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: stressMintBorder.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  size: 22,
                  color: stressMintDeep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pause — what do I need right now?',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Not what should I eat — what do I need?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _nodes.length; i++)
              _WheelNode(
                node: _nodes[i],
                selected: _selected == i,
                onTap: () => setState(() => _selected = _selected == i ? null : i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selected == null
              ? Container(
                  key: const ValueKey('hint'),
                  padding: const EdgeInsets.all(11),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EFFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tap an option to see what it can look like — there is no right or wrong choice.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      height: 1.4,
                      color: AppColors.textMedium,
                    ),
                  ),
                )
              : Container(
                  key: ValueKey(_selected),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _nodes[_selected!].bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _nodes[_selected!].color.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _nodes[_selected!].icon,
                        size: 18,
                        color: _nodes[_selected!].color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _nodes[_selected!].fact,
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
        ),
      ],
    );
  }
}

class _WheelNode extends StatelessWidget {
  final ({IconData icon, String label, String fact, Color color, Color bg}) node;
  final bool selected;
  final VoidCallback onTap;

  const _WheelNode({required this.node, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? node.bg : node.bg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? node.color : node.color.withValues(alpha: 0.3),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              node.icon,
              size: 17,
              color: selected ? node.color : node.color.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 5),
            Text(
              node.label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 10. Living With a Chronic Condition — health journey loop
// ---------------------------------------------------------------------------
class HealthJourneyVisual extends StatefulWidget {
  const HealthJourneyVisual({super.key});

  @override
  State<HealthJourneyVisual> createState() => _HealthJourneyVisualState();
}

class _HealthJourneyVisualState extends State<HealthJourneyVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _steps = [
    (icon: Icons.lightbulb_outline_rounded, label: 'Understand', color: Color(0xFF45B69C), bg: Color(0xFFE2F5EE)),
    (icon: Icons.calendar_month_rounded, label: 'Track', color: Color(0xFF5B7FFF), bg: Color(0xFFF0F4FF)),
    (icon: Icons.tune_rounded, label: 'Adjust', color: Color(0xFFE8A33D), bg: Color(0xFFFFF7E8)),
    (icon: Icons.volunteer_activism_rounded, label: 'Ask for help', color: Color(0xFF9D76C1), bg: Color(0xFFF8F0FF)),
    (icon: Icons.refresh_rounded, label: 'Continue', color: Color(0xFF45B69C), bg: Color(0xFFE2F5EE)),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value * _steps.length;
        final active = math.min(_steps.length - 1, v.floor());
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    _JourneyNode(
                      step: _steps[i],
                      active: i == active,
                      past: i < active,
                    ),
                    if (i < _steps.length - 1)
                      Container(
                        width: 18,
                        height: 2,
                        color: i < active
                            ? _steps[i].color
                            : AppColors.borderGrey,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F0FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD8B4F8).withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'A health journey has stops and turns — and you don\u2019t have to manage it alone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
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
}

class _JourneyNode extends StatelessWidget {
  final ({IconData icon, String label, Color color, Color bg}) step;
  final bool active;
  final bool past;

  const _JourneyNode({required this.step, required this.active, required this.past});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active || past ? step.bg : step.bg.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? step.color : step.color.withValues(alpha: 0.35),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [BoxShadow(color: step.color.withValues(alpha: 0.2), blurRadius: 8)]
            : null,
      ),
      child: Column(
        children: [
          Icon(
            step.icon,
            size: 18,
            color: active || past
                ? step.color
                : step.color.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 3),
          Text(
            step.label,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11. When to Seek Professional Help — calm traffic-light guide
// ---------------------------------------------------------------------------
class SeekHelpTrafficLightVisual extends StatefulWidget {
  final Map<String, dynamic>? data;

  const SeekHelpTrafficLightVisual({super.key, required this.data});

  @override
  State<SeekHelpTrafficLightVisual> createState() =>
      _SeekHelpTrafficLightVisualState();
}

class _SeekHelpTrafficLightVisualState extends State<SeekHelpTrafficLightVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _zoneStyles = [
    (color: Color(0xFF2E8B76), bg: Color(0xFFE9F7F1), dot: Color(0xFF2E8B76)),
    (color: Color(0xFFE8A33D), bg: Color(0xFFFBF0DF), dot: Color(0xFFE8A33D)),
    (color: Color(0xFFC94A6E), bg: Color(0xFFFFF0F3), dot: Color(0xFFC94A6E)),
  ];

  @override
  Widget build(BuildContext context) {
    final zones = (widget.data?['zones'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final v = _controller.value * zones.length;
            return Column(
              children: [
                for (var i = 0; i < zones.length; i++)
                  _buildZone(context, zones[i], _zoneStyles[i],
                      active: v >= i && v < i + 1),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE8A33D).withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFE8A33D)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Use this as a general guide. This app is educational — it does not diagnose, and '
                  'it is not a substitute for professional care.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZone(
    BuildContext context,
    Map<String, dynamic> zone,
    ({Color color, Color bg, Color dot}) style, {
    required bool active,
  }) {
    final items = (zone['items'] as List<dynamic>? ?? const []).cast<String>();
    final color = style.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: active ? style.bg : style.bg.withValues(alpha: 0.55),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.dot,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: active ? 1 : 0.75,
                child: Expanded(
                  child: Text(
                    zone['label'] as String? ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
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
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}