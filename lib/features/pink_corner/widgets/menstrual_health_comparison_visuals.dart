import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/menstrual_health_topic.dart';
import 'menstrual_uterus_painter.dart';

Map<String, dynamic> _asMap(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<String> _asStringList(dynamic value) =>
    (value as List).cast<String>();

// ---------------------------------------------------------------------------
// 3. Heavy bleeding comparison + gentle doctor alert
// ---------------------------------------------------------------------------
class HeavyBleedingComparisonVisual extends StatefulWidget {
  final MenstrualHealthTopic topic;

  const HeavyBleedingComparisonVisual({super.key, required this.topic});

  @override
  State<HeavyBleedingComparisonVisual> createState() =>
      _HeavyBleedingComparisonVisualState();
}

class _HeavyBleedingComparisonVisualState
    extends State<HeavyBleedingComparisonVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.topic.visualData ?? const {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _HeavyFlowCard(
                title: 'Typical variation',
                color: const Color(0xFF2E8B76),
                icon: Icons.check_circle_rounded,
                items: _asStringList(data['typical']),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HeavyFlowCard(
                title: 'Potentially heavy',
                color: const Color(0xFFE8A33D),
                icon: Icons.info_rounded,
                items: _asStringList(data['potentiallyHeavy']),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Opacity(
              opacity: 0.6 + 0.4 * _pulse.value,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE8A33D).withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 20,
                    color: Color(0xFFE8A33D),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['alertTitle'] as String? ?? 'Talk to a professional',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data['alertBody'] as String? ??
                            'A healthcare professional can help assess patterns.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          height: 1.4,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
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

class _HeavyFlowCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<String> items;

  const _HeavyFlowCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022  ',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        height: 1.35,
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
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Spotting vs period flow comparison
// ---------------------------------------------------------------------------
class SpottingComparisonVisual extends StatelessWidget {
  final MenstrualHealthTopic topic;

  const SpottingComparisonVisual({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final data = topic.visualData ?? const {};
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SpottingCard(
            title: 'Spotting',
            color: const Color(0xFF5B7FFF),
            icon: Icons.grain_rounded,
            illustration: const _SpottingIllustration(),
            items: _asStringList(data['spotting']),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SpottingCard(
            title: 'Typical period',
            color: const Color(0xFFC94A6E),
            icon: Icons.water_drop_rounded,
            illustration: const _PeriodIllustration(),
            items: _asStringList(data['period']),
          ),
        ),
      ],
    );
  }
}

class _SpottingIllustration extends StatelessWidget {
  const _SpottingIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(const Color(0xFF5B7FFF)),
              const SizedBox(width: 6),
              _dot(const Color(0xFF5B7FFF).withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              _dot(const Color(0xFF5B7FFF).withValues(alpha: 0.45)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'a few drops',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PeriodIllustration extends StatelessWidget {
  const _PeriodIllustration();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFC94A6E);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_rounded,
            size: 34,
            color: color.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 3),
          Container(
            width: 64,
            height: 7,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'steady flow for days',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpottingCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Widget illustration;
  final List<String> items;

  const _SpottingCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.illustration,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          illustration,
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022  ',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        height: 1.35,
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
    );
  }
}

// ---------------------------------------------------------------------------
// 5. PMS vs PMDD interactive comparison
// ---------------------------------------------------------------------------
class PmsPmddComparisonVisual extends StatefulWidget {
  final MenstrualHealthTopic topic;

  const PmsPmddComparisonVisual({super.key, required this.topic});

  @override
  State<PmsPmddComparisonVisual> createState() =>
      _PmsPmddComparisonVisualState();
}

class _PmsPmddComparisonVisualState extends State<PmsPmddComparisonVisual> {
  bool _showPmdd = false;

  Map<String, dynamic> get _data =>
      _asMap(widget.topic.visualData?['pms']);

  Map<String, dynamic> get _pmddData =>
      _asMap(widget.topic.visualData?['pmdd']);

  @override
  Widget build(BuildContext context) {
    final pms = _data;
    final pmdd = _pmddData;
    final Map<String, dynamic> selected = _showPmdd ? pmdd : pms;
    final Color accent = _showPmdd
        ? const Color(0xFF9D76C1)
        : const Color(0xFF45B69C);
    final double severity = (selected['severity'] as num).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tappable summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'PMS',
                tagline: pms['tagline'] as String,
                color: const Color(0xFF45B69C),
                selected: !_showPmdd,
                onTap: () => setState(() => _showPmdd = false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'PMDD',
                tagline: pmdd['tagline'] as String,
                color: const Color(0xFF9D76C1),
                selected: _showPmdd,
                onTap: () => setState(() => _showPmdd = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_showPmdd),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _symptomGroup('Physical', Icons.favorite_outline_rounded,
                    accent, _asStringList(selected['physical'])),
                const SizedBox(height: 12),
                _symptomGroup('Emotional', Icons.mood_rounded, accent,
                    _asStringList(selected['emotional'])),
                const SizedBox(height: 12),
                _symptomGroup('Behavioral', Icons.touch_app_rounded, accent,
                    _asStringList(selected['behavioral'])),
                const SizedBox(height: 12),
                Text(
                  'Everyday life',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selected['life'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 12),
                // Severity scale
                Row(
                  children: [
                    Text(
                      'Severity',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _showPmdd ? 'More severe' : 'Milder',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 10,
                    color: accent.withValues(alpha: 0.2),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: severity / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent.withValues(alpha: 0.6),
                              accent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F0FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF9D76C1).withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            'PMDD is not simply "very bad PMS". It is a distinct condition with its own recognized criteria. Severe, repeating symptoms deserve professional assessment.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              height: 1.45,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _symptomGroup(
    String title,
    IconData icon,
    Color accent,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2022  ',
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      height: 1.35,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String tagline;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.tagline,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.borderGrey,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: selected ? color : AppColors.textLight,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selected ? color : AppColors.textMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tagline,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                height: 1.35,
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
// 6. Blood clot non-graphic diagram
// ---------------------------------------------------------------------------
class ClotDiagramVisual extends StatelessWidget {
  final MenstrualHealthTopic topic;

  const ClotDiagramVisual({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ClotZone(
                title: 'Small & occasional',
                color: const Color(0xFF2E8B76),
                icon: Icons.check_circle_rounded,
                circles: const [5, 4, 4],
                caption: 'Common for many people, especially on heavier days.',
              ),
            ),
            Container(
              width: 1.2,
              height: 110,
              color: AppColors.borderGrey,
            ),
            Expanded(
              child: _ClotZone(
                title: 'Larger or frequent',
                color: const Color(0xFFE8A33D),
                icon: Icons.help_outline_rounded,
                circles: const [12, 10],
                caption: 'Worth discussing, especially alongside heavy flow.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Size and frequency matter more than any single clot. This diagram is educational, not a diagnosis.',
          textAlign: TextAlign.center,
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

class _ClotZone extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<double> circles;
  final String caption;

  const _ClotZone({
    required this.title,
    required this.color,
    required this.icon,
    required this.circles,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final radius in circles) ...[
                  Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              height: 1.35,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Animated period color timeline
// ---------------------------------------------------------------------------
class ColorTimelineVisual extends StatefulWidget {
  final MenstrualHealthTopic topic;

  const ColorTimelineVisual({super.key, required this.topic});

  @override
  State<ColorTimelineVisual> createState() => _ColorTimelineVisualState();
}

class _ColorTimelineVisualState extends State<ColorTimelineVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<Map<String, dynamic>> get _colors {
    final data = widget.topic.visualData?['colors'];
    if (data == null) return const [];
    return (data as List).map((e) => _asMap(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    if (colors.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final index = (_controller.value * colors.length).floor() % colors.length;
        final current = colors[index];
        final currentColor = Color(current['value'] as int);

        return Column(
          children: [
            // Timeline row
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  for (var i = 0; i < colors.length; i++)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: i == 0
                                    ? AppColors.borderGrey
                                    : Color(
                                        colors[i]['value'] as int,
                                      ).withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Swatches
            Row(
              children: [
                for (var i = 0; i < colors.length; i++)
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          width: i == index ? 42 : 34,
                          height: i == index ? 42 : 34,
                          decoration: BoxDecoration(
                            color: Color(colors[i]['value'] as int),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: i == index
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(colors[i]['value'] as int)
                                    .withValues(alpha: 0.35),
                                blurRadius: i == index ? 10 : 2,
                              ),
                            ],
                          ),
                          child: i == index
                              ? const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          colors[i]['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight:
                                i == index ? FontWeight.bold : FontWeight.w500,
                            color: i == index
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey(index),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: currentColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: currentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current['name'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            current['info'] as String,
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
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Uterus + comfort measures animation
// ---------------------------------------------------------------------------
class PainAnimationVisual extends StatefulWidget {
  final MenstrualHealthTopic topic;

  const PainAnimationVisual({super.key, required this.topic});

  @override
  State<PainAnimationVisual> createState() => _PainAnimationVisualState();
}

class _PainAnimationVisualState extends State<PainAnimationVisual>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const comfortItems = [
      (Icons.local_fire_department_rounded, 'Heat pad', Color(0xFFFF8A65), Color(0xFFFFF0E8)),
      (Icons.directions_walk_rounded, 'Gentle movement', Color(0xFF45B69C), Color(0xFFF0FDF4)),
      (Icons.bedtime_rounded, 'Rest', Color(0xFF5B7FFF), Color(0xFFF0F4FF)),
    ];

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + 0.05 * _pulse.value,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: widget.topic.accentColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: CustomPaint(
                    painter: const SimpleUterusPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
        ),
        Text(
          'The uterus gently contracts to shed its lining — this can cause cramps.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            height: 1.4,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < comfortItems.length; i++)
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _reveal,
                  curve: Interval(i * 0.18, 0.9, curve: Curves.easeOut),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: comfortItems[i].$4,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: comfortItems[i].$3.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        comfortItems[i].$1,
                        size: 22,
                        color: comfortItems[i].$3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comfortItems[i].$2,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Comfort measures like these can help many people. Medicines should always be used per instructions and professional advice.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontStyle: FontStyle.italic,
            height: 1.4,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Traffic-light doctor guide
// ---------------------------------------------------------------------------
class TrafficLightVisual extends StatelessWidget {
  final MenstrualHealthTopic topic;

  const TrafficLightVisual({super.key, required this.topic});

  static const _levelStyles = {
    0: (
      Color(0xFF2E8B76),
      Icons.assignment_turned_in_rounded,
      'Monitor & Track',
    ),
    1: (
      Color(0xFFE8A33D),
      Icons.medical_services_rounded,
      'Talk to a Doctor Soon',
    ),
    2: (
      Color(0xFFD9534F),
      Icons.local_hospital_rounded,
      'Seek Urgent Medical Care',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final levels = _asList(topic.visualData?['levels']);
    return Column(
      children: [
        for (final level in levels)
          _TrafficLevelCard(
            level: level,
            style: _levelStyles[level['level'] as int]!,
          ),
        const SizedBox(height: 8),
        Text(
          'You know your body best. If something feels very wrong, do not wait to seek care.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _asList(dynamic value) =>
      (value as List).map((e) => _asMap(e)).toList();
}

typedef _TrafficStyle = (Color, IconData, String);

class _TrafficLevelCard extends StatelessWidget {
  final Map<String, dynamic> level;
  final _TrafficStyle style;

  const _TrafficLevelCard({required this.level, required this.style});

  @override
  Widget build(BuildContext context) {
    final color = style.$1;
    final items = (level['items'] as List).cast<String>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(style.$2, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level['name'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u2022  ',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
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
            ),
          ),
        ],
      ),
    );
  }
}