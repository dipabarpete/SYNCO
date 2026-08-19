import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Small helpers to read the typed [visualData] map of a Nutrition topic.
Map<String, dynamic> nutritionVisualDataAsMap(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<String> nutritionStringList(dynamic value) =>
    (value as List).map((e) => e.toString()).toList();

/// Nutrition palette used across all Nutrition visuals.
class NutritionPalette {
  static const Color protein = Color(0xFFE07A5F);
  static const Color carb = Color(0xFFE8A33D);
  static const Color veg = Color(0xFF66A06B);
  static const Color fat = Color(0xFFD9A62E);
  static const Color fruit = Color(0xFFE892A2);
  static const Color dairy = Color(0xFF6495ED);
  static const Color grain = Color(0xFFC98F3B);
  static const Color seed = Color(0xFFB08A3E);
  static const Color peach = Color(0xFFFFB085);
  static const Color lavender = Color(0xFF9D76C1);
}

/// Base state for visuals with a one-time staggered entrance animation.
abstract class NutritionEnterState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  late final AnimationController enterController;

  @override
  void initState() {
    super.initState();
    enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    enterController.dispose();
    super.dispose();
  }
}

/// Small staggered reveal: fades + lifts each child in one by one.
class NutritionReveal extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int total;
  final Widget child;

  const NutritionReveal({
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

/// Small pastel icon tile with optional label.
class FoodTile extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final Color background;
  final double size;

  const FoodTile({
    super.key,
    required this.icon,
    this.label,
    required this.color,
    required this.background,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, size: size * 0.46, color: color),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: size + 18,
            child: Text(
              label!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Chip used for small notes inside visuals.
class NutritionNoteChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const NutritionNoteChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plate painter: rim + inner disc + optional coloured wedges.
class NutritionPlatePainter extends CustomPainter {
  final List<Color> sections;
  final Color rimColor;

  const NutritionPlatePainter({required this.sections, required this.rimColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rimPaint = Paint()
      ..color = rimColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, rimPaint);
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.78, innerPaint);

    if (sections.isNotEmpty) {
      final wedgePaint = Paint();
      final wedgeRadius = radius * 0.78;
      final arc = 2 * math.pi / sections.length;
      for (var i = 0; i < sections.length; i++) {
        wedgePaint.color = sections[i];
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: wedgeRadius),
          -math.pi / 2 + i * arc + 0.03,
          arc - 0.06,
          true,
          wedgePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NutritionPlatePainter oldDelegate) =>
      oldDelegate.sections != sections || oldDelegate.rimColor != rimColor;
}

/// Plain plate on a soft shadowed disc, size in logical pixels.
class NutritionPlate extends StatelessWidget {
  final List<Color> sections;
  final Color rimColor;
  final double size;
  final Widget? center;

  const NutritionPlate({
    super.key,
    required this.sections,
    required this.rimColor,
    required this.size,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ]),
      child: CustomPaint(
        painter: NutritionPlatePainter(sections: sections, rimColor: rimColor),
        child: center != null
            ? Center(child: SizedBox(width: size * 0.6, child: center))
            : null,
      ),
    );
  }
}

/// A small tappable chip row item used in interactive visuals.
class NutritionTapChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const NutritionTapChip({
    super.key,
    required this.label,
    this.icon,
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.borderGrey.withValues(alpha: 0.8),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? color : AppColors.textLight,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}