import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/nutrition_topic.dart';
import 'nutrition_visual_widgets.dart';

// ---------------------------------------------------------------------------
// 11. Fruits — fruit bowl with context cards
// ---------------------------------------------------------------------------
class FruitBowlVisual extends StatefulWidget {
  final NutritionTopic topic;

  const FruitBowlVisual({super.key, required this.topic});

  @override
  State<FruitBowlVisual> createState() => _FruitBowlVisualState();
}

class _FruitBowlVisualState extends NutritionEnterState<FruitBowlVisual> {
  static const List<(IconData, Color)> _fruits = [
    (Icons.apple_rounded, NutritionPalette.fruit),
    (Icons.circle_rounded, NutritionPalette.carb),
    (Icons.local_florist_rounded, NutritionPalette.veg),
    (Icons.apple_rounded, NutritionPalette.seed),
    (Icons.circle_rounded, NutritionPalette.fruit),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: const Alignment(0, 0.72),
                child: NutritionReveal(
                  controller: enterController,
                  index: 1,
                  total: 4,
                  child: Container(
                    width: 180,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(90),
                      ),
                      border: Border.all(
                        color: NutritionPalette.fruit.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < _fruits.length; i++)
                Align(
                  alignment: Alignment(
                    -0.7 + i * 0.35,
                    0.18 - (i.isEven ? 0.16 : 0.02),
                  ),
                  child: NutritionReveal(
                    controller: enterController,
                    index: 0,
                    total: 4,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _fruits[i].$2.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _fruits[i].$2.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        _fruits[i].$1,
                        size: 18,
                        color: _fruits[i].$2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 2,
                total: 4,
                child: const _FruitContextCard(
                  icon: Icons.apple_rounded,
                  label: 'Whole fruit',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 3,
                total: 4,
                child: const _FruitContextCard(
                  icon: Icons.local_cafe_rounded,
                  label: 'With curd',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 3,
                total: 4,
                child: const _FruitContextCard(
                  icon: Icons.energy_savings_leaf_rounded,
                  label: 'With nuts\n& seeds',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const NutritionNoteChip(
          icon: Icons.auto_awesome_rounded,
          text:
              'Whole fruit brings fibre and water along with its natural sweetness — portions follow your own appetite.',
          color: NutritionPalette.fruit,
        ),
      ],
    );
  }
}

class _FruitContextCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FruitContextCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: NutritionPalette.fruit.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NutritionPalette.fruit.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: NutritionPalette.fruit),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 12. Healthy Fats — ingredient wheel
// ---------------------------------------------------------------------------
class HealthyFatWheelVisual extends StatefulWidget {
  final NutritionTopic topic;

  const HealthyFatWheelVisual({super.key, required this.topic});

  @override
  State<HealthyFatWheelVisual> createState() => _HealthyFatWheelVisualState();
}

class _HealthyFatWheelVisualState
    extends NutritionEnterState<HealthyFatWheelVisual> {
  static const List<(String, IconData, Color)> _ingredients = [
    ('Nuts', Icons.energy_savings_leaf_rounded, NutritionPalette.seed),
    ('Seeds', Icons.grain_rounded, NutritionPalette.seed),
    ('Oils', Icons.lunch_dining_rounded, NutritionPalette.fat),
    ('Fish', Icons.water_rounded, NutritionPalette.dairy),
    ('Avocado', Icons.apple_rounded, NutritionPalette.veg),
  ];

  Offset _position(int index) {
    final angle = -math.pi / 2 + index * 2 * math.pi / 5;
    return Offset(92 * math.cos(angle), 92 * math.sin(angle));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NutritionPalette.fat.withValues(alpha: 0.3),
                    width: 1.4,
                  ),
                ),
              ),
              NutritionReveal(
                controller: enterController,
                index: 0,
                total: _ingredients.length + 1,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAEB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NutritionPalette.fat.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.adjust_rounded, size: 26, color: NutritionPalette.fat),
                      SizedBox(height: 2),
                      Text(
                        'Portions',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (var i = 0; i < _ingredients.length; i++)
                NutritionReveal(
                  controller: enterController,
                  index: i + 1,
                  total: _ingredients.length + 1,
                  child: Transform.translate(
                    offset: _position(i),
                    child: FoodTile(
                      icon: _ingredients[i].$2,
                      label: _ingredients[i].$1,
                      color: _ingredients[i].$3,
                      background: _ingredients[i].$3.withValues(alpha: 0.12),
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A small handful of nuts, a spoon of oil — mindful amounts, no fear.',
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

// ---------------------------------------------------------------------------
// 13. Portion Awareness — adjustable plate
// ---------------------------------------------------------------------------
class AdjustablePlateVisual extends StatefulWidget {
  final NutritionTopic topic;

  const AdjustablePlateVisual({super.key, required this.topic});

  @override
  State<AdjustablePlateVisual> createState() => _AdjustablePlateVisualState();
}

class _AdjustablePlateVisualState extends State<AdjustablePlateVisual> {
  double _value = 0.55;

  String get _label => _value < 0.4
      ? 'Smaller portion'
      : _value < 0.75
          ? 'Balanced'
          : 'Larger portion';

  @override
  Widget build(BuildContext context) {
    final innerFraction = 0.45 + _value * 0.45;

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Center(
            child: CustomPaint(
              size: const Size(170, 170),
              painter: _PortionPlatePainter(
                innerFraction: innerFraction,
                accent: NutritionPalette.peach,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: NutritionPalette.peach,
          ),
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: NutritionPalette.peach,
            inactiveTrackColor: NutritionPalette.peach.withValues(alpha: 0.2),
            thumbColor: NutritionPalette.peach,
            overlayColor: NutritionPalette.peach.withValues(alpha: 0.15),
            trackHeight: 5,
          ),
          child: Slider(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
        const SizedBox(height: 4),
        const NutritionNoteChip(
          icon: Icons.lightbulb_outline_rounded,
          text:
              'Just a feel for sizing — no numbers, no calorie counting. What feels right is different for everyone.',
          color: NutritionPalette.peach,
        ),
      ],
    );
  }
}

class _PortionPlatePainter extends CustomPainter {
  final double innerFraction;
  final Color accent;

  const _PortionPlatePainter({required this.innerFraction, required this.accent});

  static const _sections = [
    NutritionPalette.protein,
    NutritionPalette.carb,
    NutritionPalette.veg,
    NutritionPalette.fat,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rimPaint = Paint()..color = const Color(0xFFF6EFE7);
    canvas.drawCircle(center, radius, rimPaint);

    final innerRadius = radius * innerFraction;
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, innerRadius, innerPaint);

    final wedgePaint = Paint();
    final arc = 2 * math.pi / _sections.length;
    for (var i = 0; i < _sections.length; i++) {
      wedgePaint.color = _sections[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -math.pi / 2 + i * arc + 0.03,
        arc - 0.06,
        true,
        wedgePaint,
      );
    }

    final outlinePaint = Paint()
      ..color = accent.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, innerRadius, outlinePaint);

    final dotPaint = Paint()..color = accent;
    canvas.drawCircle(center, 9, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _PortionPlatePainter oldDelegate) =>
      oldDelegate.innerFraction != innerFraction;
}

// ---------------------------------------------------------------------------
// 14. There is no single PCOS diet — varied plates
// ---------------------------------------------------------------------------
class NoSingleDietVisual extends StatefulWidget {
  final NutritionTopic topic;

  const NoSingleDietVisual({super.key, required this.topic});

  @override
  State<NoSingleDietVisual> createState() => _NoSingleDietVisualState();
}

class _NoSingleDietVisualState extends NutritionEnterState<NoSingleDietVisual> {
  static const List<(List<Color>, String)> _plates = [
    ([NutritionPalette.protein, NutritionPalette.carb], 'Family'),
    ([NutritionPalette.veg, NutritionPalette.carb, NutritionPalette.protein], 'Cultural'),
    ([NutritionPalette.fruit, NutritionPalette.veg, NutritionPalette.carb], 'Budget'),
    (
      [
        NutritionPalette.carb,
        NutritionPalette.veg,
        NutritionPalette.protein,
        NutritionPalette.fat,
      ],
      'Health needs',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NutritionReveal(
          controller: enterController,
          index: 0,
          total: _plates.length + 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: NutritionPalette.lavender.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.diversity_3_rounded,
                  size: 16,
                  color: NutritionPalette.lavender,
                ),
                const SizedBox(width: 6),
                Text(
                  'One size does not fit all',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: NutritionPalette.lavender,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < _plates.length; i++)
              NutritionReveal(
                controller: enterController,
                index: i + 1,
                total: _plates.length + 2,
                child: Column(
                  children: [
                    NutritionPlate(
                      size: 58,
                      rimColor: const Color(0xFFF6EFE7),
                      sections: _plates[i].$1,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _plates[i].$2,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        NutritionReveal(
          controller: enterController,
          index: _plates.length + 1,
          total: _plates.length + 2,
          child: const NutritionNoteChip(
            icon: Icons.auto_awesome_rounded,
            text:
                'Every person\u2019s plate can look different — culture, budget, preferences and health needs all shape it. That is completely normal.',
            color: NutritionPalette.lavender,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 15. Build your breakfast — interactive
// ---------------------------------------------------------------------------
class BuildBreakfastVisual extends StatefulWidget {
  final NutritionTopic topic;

  const BuildBreakfastVisual({super.key, required this.topic});

  @override
  State<BuildBreakfastVisual> createState() => _BuildBreakfastVisualState();
}

class _BuildBreakfastVisualState extends State<BuildBreakfastVisual> {
  static const List<String> _bases = ['Idli', 'Poha', 'Paratha', 'Upma', 'Dosa'];

  int _selectedBase = 0;
  final Set<String> _added = {};

  static const List<(String, String, IconData, Color)> _addOns = [
    ('protein', 'Protein', Icons.egg_alt_rounded, NutritionPalette.protein),
    ('fibre', 'Fibre side', Icons.grass_rounded, NutritionPalette.veg),
    ('fruit', 'Fruit or veg', Icons.apple_rounded, NutritionPalette.fruit),
  ];

  @override
  Widget build(BuildContext context) {
    final complete = _added.length == _addOns.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1 — pick your breakfast',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _bases.length; i++)
                NutritionTapChip(
                  label: _bases[i],
                  color: NutritionPalette.peach,
                  selected: _selectedBase == i,
                  onTap: () => setState(() => _selectedBase = i),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NutritionPalette.peach.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.breakfast_dining_rounded,
                    size: 18,
                    color: NutritionPalette.peach,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your plate: ${_bases[_selectedBase]}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 2 — add to it',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final addOn in _addOns)
                    NutritionTapChip(
                      label: addOn.$2,
                      icon: addOn.$3,
                      color: addOn.$4,
                      selected: _added.contains(addOn.$1),
                      onTap: () => setState(() {
                        if (!_added.add(addOn.$1)) _added.remove(addOn.$1);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(complete),
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: complete
                        ? const Color(0xFFE2F5EE)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: complete
                          ? NutritionPalette.veg.withValues(alpha: 0.5)
                          : AppColors.borderGrey.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    complete
                        ? 'A more balanced breakfast, still yours!'
                        : 'Keep the foods you love — balance is an addition, not a replacement.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.4,
                      fontWeight: complete ? FontWeight.w600 : FontWeight.w400,
                      color: complete
                          ? NutritionPalette.veg
                          : AppColors.textMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 16. Indian lunch — lunch plate builder
// ---------------------------------------------------------------------------
class LunchPlateVisual extends StatefulWidget {
  final NutritionTopic topic;

  const LunchPlateVisual({super.key, required this.topic});

  @override
  State<LunchPlateVisual> createState() => _LunchPlateVisualState();
}

class _LunchPlateVisualState extends State<LunchPlateVisual> {
  List<String> get _combos {
    final data = widget.topic.visualData?['combos'];
    if (data == null) {
      return ['Dal + rice + vegetables', 'Roti + sabzi + curd'];
    }
    return nutritionStringList(data);
  }

  int _selectedCombo = 0;
  final Set<String> _addOns = {'Curd', 'Salad', 'Extra sabzi'};

  static const List<(String, IconData, Color)> _addOnMeta = [
    ('Curd', Icons.local_cafe_rounded, NutritionPalette.dairy),
    ('Salad', Icons.eco_rounded, NutritionPalette.veg),
    ('Extra sabzi', Icons.local_florist_rounded, NutritionPalette.veg),
  ];

  @override
  Widget build(BuildContext context) {
    final combos = _combos;
    final combo = combos[_selectedCombo.clamp(0, combos.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick your usual combo',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < combos.length; i++)
              NutritionTapChip(
                label: combos[i],
                color: NutritionPalette.protein,
                selected: _selectedCombo == i,
                onTap: () => setState(() => _selectedCombo = i),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NutritionPalette.protein.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.set_meal_rounded,
                    size: 18,
                    color: NutritionPalette.protein,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      combo,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add or remove',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final addOn in _addOnMeta)
                    NutritionTapChip(
                      label: addOn.$1,
                      icon: addOn.$2,
                      color: addOn.$3,
                      selected: _addOns.contains(addOn.$1),
                      onTap: () => setState(() {
                        if (!_addOns.add(addOn.$1)) _addOns.remove(addOn.$1);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_addOns.length),
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderGrey.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    _addOns.isEmpty
                        ? 'Add a side or two when it suits you.'
                        : 'A fuller lunch — same foods you know, with a little more balance.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 17. Budget-friendly protein — cards without invented prices
// ---------------------------------------------------------------------------
class BudgetProteinCardsVisual extends StatefulWidget {
  final NutritionTopic topic;

  const BudgetProteinCardsVisual({super.key, required this.topic});

  @override
  State<BudgetProteinCardsVisual> createState() =>
      _BudgetProteinCardsVisualState();
}

class _BudgetProteinCardsVisualState
    extends NutritionEnterState<BudgetProteinCardsVisual> {
  static const List<(String, IconData, String, Color)> _sources = [
    ('Dal', Icons.soup_kitchen_rounded, 'Everyday staple', NutritionPalette.protein),
    ('Chana & rajma', Icons.rice_bowl_rounded, 'Soak and cook at home', NutritionPalette.protein),
    ('Soy chunks', Icons.set_meal_rounded, 'Great in curries', NutritionPalette.seed),
    ('Peanuts', Icons.energy_savings_leaf_rounded, 'Roasted or in chutneys', NutritionPalette.fat),
    ('Eggs', Icons.egg_alt_rounded, 'Quick and versatile', NutritionPalette.protein),
    ('Curd & milk', Icons.local_cafe_rounded, 'Already at home', NutritionPalette.dairy),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NutritionPalette.veg.withValues(alpha: 0.4),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _sources.length; i++)
                NutritionReveal(
                  controller: enterController,
                  index: i,
                  total: _sources.length,
                  child: _BudgetProteinCard(
                    label: _sources[i].$1,
                    icon: _sources[i].$2,
                    note: _sources[i].$3,
                    color: _sources[i].$4,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const NutritionNoteChip(
          icon: Icons.savings_rounded,
          text:
              'Prices vary by market, season and region — but these everyday staples are among the most affordable protein choices in India.',
          color: NutritionPalette.veg,
        ),
      ],
    );
  }
}

class _BudgetProteinCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String note;
  final Color color;

  const _BudgetProteinCard({
    required this.label,
    required this.icon,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              height: 1.3,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 18. Cravings — tappable craving cards
// ---------------------------------------------------------------------------
class CravingCardsVisual extends StatefulWidget {
  final NutritionTopic topic;

  const CravingCardsVisual({super.key, required this.topic});

  @override
  State<CravingCardsVisual> createState() => _CravingCardsVisualState();
}

class _CravingCardsVisualState extends NutritionEnterState<CravingCardsVisual> {
  static const List<(String, IconData, Color, List<String>)> _cravings = [
    (
      'Want something sweet?',
      Icons.icecream_rounded,
      NutritionPalette.fruit,
      ['Fruit + curd', 'Dates + nuts', 'Dark chocolate, small portion'],
    ),
    (
      'Want something crunchy?',
      Icons.cookie_rounded,
      NutritionPalette.carb,
      ['Roasted chana', 'Makhana', 'Peanuts'],
    ),
    (
      'Want something salty?',
      Icons.set_meal_rounded,
      NutritionPalette.seed,
      ['Chana chaat', 'Home-made snack mixes', 'A small portion of your favourite'],
    ),
  ];

  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _cravings.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NutritionReveal(
              controller: enterController,
              index: i,
              total: _cravings.length,
              child: _CravingCard(
                title: _cravings[i].$1,
                icon: _cravings[i].$2,
                color: _cravings[i].$3,
                ideas: _cravings[i].$4,
                open: _openIndex == i,
                onTap: () => setState(
                  () => _openIndex = _openIndex == i ? null : i,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        const NutritionNoteChip(
          icon: Icons.auto_awesome_rounded,
          text:
              'Alternatives are options, not orders — sometimes the real thing, enjoyed without guilt, is the most balanced choice.',
          color: NutritionPalette.fruit,
        ),
      ],
    );
  }
}

class _CravingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> ideas;
  final bool open;
  final VoidCallback onTap;

  const _CravingCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.ideas,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: open ? 0.10 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: open ? color : color.withValues(alpha: 0.35),
            width: open ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: open
                  ? Column(
                      children: [
                        const SizedBox(height: 10),
                        for (final idea in ideas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: color,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    idea,
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
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 19. Snack swaps — side-by-side cards
// ---------------------------------------------------------------------------
class SnackComparisonVisual extends StatefulWidget {
  final NutritionTopic topic;

  const SnackComparisonVisual({super.key, required this.topic});

  @override
  State<SnackComparisonVisual> createState() => _SnackComparisonVisualState();
}

class _SnackComparisonVisualState
    extends NutritionEnterState<SnackComparisonVisual> {
  List<(String, String)> get _swaps {
    final data = widget.topic.visualData?['swaps'];
    if (data == null) {
      return [('Chips', 'Roasted chana'), ('Sweets', 'Fruit + curd')];
    }
    return (data as List).map((e) {
      final map = (e as Map).cast<String, dynamic>();
      return (map['usual'] as String, map['idea'] as String);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final swaps = _swaps;
    return Column(
      children: [
        for (var i = 0; i < swaps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NutritionReveal(
              controller: enterController,
              index: i,
              total: swaps.length,
              child: Row(
                children: [
                  Expanded(
                    child: _SwapCard(
                      label: swaps[i].$1,
                      color: AppColors.textLight,
                      backgroundColor: const Color(0xFFF7F5F2),
                      prefix: 'You usually reach for',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 20,
                      color: NutritionPalette.peach,
                    ),
                  ),
                  Expanded(
                    child: _SwapCard(
                      label: swaps[i].$2,
                      color: NutritionPalette.veg,
                      backgroundColor: const Color(0xFFF0FDF4),
                      prefix: 'Try this more often',
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        const NutritionNoteChip(
          icon: Icons.auto_awesome_rounded,
          text:
              '"Try this more often" — not "never eat that". Your favourites still belong on your plate.',
          color: NutritionPalette.peach,
        ),
      ],
    );
  }
}

class _SwapCard extends StatelessWidget {
  final String label;
  final String prefix;
  final Color color;
  final Color backgroundColor;

  const _SwapCard({
    required this.label,
    required this.prefix,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prefix,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}