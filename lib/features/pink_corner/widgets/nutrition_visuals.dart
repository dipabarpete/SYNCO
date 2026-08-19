import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/nutrition_topic.dart';
import 'nutrition_visual_widgets.dart';
import 'nutrition_visuals_part2.dart';

/// Top-level educational visual for a Nutrition topic.
///
/// Renders the visual chosen by [topic.visualType] inside a clean card,
/// with a text caption so every visual concept also has a text alternative.
class NutritionTopicVisual extends StatelessWidget {
  final NutritionTopic topic;

  const NutritionTopicVisual({super.key, required this.topic});

  static const Map<NutritionVisualType, String> _captions = {
    NutritionVisualType.plateProtein:
        'A balanced plate with the protein portion highlighted, and a few everyday protein foods appearing around it.',
    NutritionVisualType.carbComparison:
        'A balanced plate showing everyday carbohydrate foods — rice, roti, oats, potatoes, fruit and whole grains — together, not in competition.',
    NutritionVisualType.fatWheel:
        'A simple comparison: unsaturated fats from plants and fish are everyday sources, while some packaged or animal fats are used in mindful amounts.',
    NutritionVisualType.fibreWheel:
        'Foods rich in fibre — vegetables, fruit, beans, lentils, whole grains, nuts and seeds — joining a circle around a digestion icon.',
    NutritionVisualType.nutrientGrid:
        'A colourful grid of everyday nutrient-rich foods — a simple variety-is-enough visual.',
    NutritionVisualType.waterBottle:
        'A gentle water-bottle visual: tap hydration choices and watch the water level rise. Your own thirst is the best guide.',
    NutritionVisualType.plateBuilder:
        'An interactive plate builder. Tap food groups and watch the plate gradually become more balanced.',
    NutritionVisualType.pairingComparison:
        'A two-part visual: protein on one side, fibre on the other, with simple example meals combining the two.',
    NutritionVisualType.grainTimeline:
        'A simple grain transformation: the whole kernel, what refining removes, and whole grains that keep all parts.',
    NutritionVisualType.vegPlate:
        'Familiar vegetables sliding into a plate one by one, creating a colourful meal.',
    NutritionVisualType.fruitBowl:
        'A fruit bowl with simple context cards — whole fruit, with curd, or with nuts and seeds.',
    NutritionVisualType.healthyFatWheel:
        'A small wheel of everyday fats — nuts, seeds, oils and fish — with a gentle portion reminder.',
    NutritionVisualType.adjustablePlate:
        'An adjustable plate visual — move the slider to explore portion sizes, without any numbers or calorie counting.',
    NutritionVisualType.noSingleDiet:
        'Different plates for different lives — a visual reminder that no single PCOS diet fits everyone.',
    NutritionVisualType.buildBreakfast:
        'An interactive build-your-breakfast card — start with a familiar Indian breakfast, then add one protein, one fibre-rich side, and one fruit or vegetable.',
    NutritionVisualType.lunchPlate:
        'An Indian lunch plate builder — pick a familiar combo and add curd, salad or extra sabzi.',
    NutritionVisualType.budgetProteinCards:
        'Everyday budget-friendly protein foods in India — dal, chana, rajma, soy chunks, peanuts, eggs and curd.',
    NutritionVisualType.cravingCards:
        'Craving comparison cards — want something sweet, crunchy or salty — with practical ideas for each.',
    NutritionVisualType.snackComparison:
        'Side-by-side snack cards: a common snack on one side, and a try-this-more-often idea on the other.',
  };

  @override
  Widget build(BuildContext context) {
    final Widget visual = switch (topic.visualType) {
      NutritionVisualType.plateProtein => PlateProteinVisual(topic: topic),
      NutritionVisualType.carbComparison => CarbComparisonVisual(topic: topic),
      NutritionVisualType.fatWheel => FatWheelVisual(topic: topic),
      NutritionVisualType.fibreWheel => FibreWheelVisual(topic: topic),
      NutritionVisualType.nutrientGrid => NutrientGridVisual(topic: topic),
      NutritionVisualType.waterBottle => WaterBottleVisual(topic: topic),
      NutritionVisualType.plateBuilder => PlateBuilderVisual(topic: topic),
      NutritionVisualType.pairingComparison =>
        PairingComparisonVisual(topic: topic),
      NutritionVisualType.grainTimeline => GrainTimelineVisual(topic: topic),
      NutritionVisualType.vegPlate => VegPlateVisual(topic: topic),
      NutritionVisualType.fruitBowl => FruitBowlVisual(topic: topic),
      NutritionVisualType.healthyFatWheel =>
        HealthyFatWheelVisual(topic: topic),
      NutritionVisualType.adjustablePlate =>
        AdjustablePlateVisual(topic: topic),
      NutritionVisualType.noSingleDiet => NoSingleDietVisual(topic: topic),
      NutritionVisualType.buildBreakfast => BuildBreakfastVisual(topic: topic),
      NutritionVisualType.lunchPlate => LunchPlateVisual(topic: topic),
      NutritionVisualType.budgetProteinCards =>
        BudgetProteinCardsVisual(topic: topic),
      NutritionVisualType.cravingCards => CravingCardsVisual(topic: topic),
      NutritionVisualType.snackComparison =>
        SnackComparisonVisual(topic: topic),
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
                color: NutritionPalette.peach,
              ),
              const SizedBox(width: 8),
              Text(
                'Visual guide',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: NutritionPalette.peach,
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

// ---------------------------------------------------------------------------
// 1. Protein — balanced plate with the protein portion highlighted
// ---------------------------------------------------------------------------
class PlateProteinVisual extends StatefulWidget {
  final NutritionTopic topic;

  const PlateProteinVisual({super.key, required this.topic});

  @override
  State<PlateProteinVisual> createState() => _PlateProteinVisualState();
}

class _PlateProteinVisualState extends NutritionEnterState<PlateProteinVisual> {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  static const List<(String, IconData, Color)> _items = [
    ('Dal', Icons.soup_kitchen_rounded, NutritionPalette.protein),
    ('Chana', Icons.rice_bowl_rounded, NutritionPalette.protein),
    ('Paneer', Icons.set_meal_rounded, NutritionPalette.protein),
    ('Curd', Icons.local_cafe_rounded, NutritionPalette.dairy),
    ('Eggs', Icons.egg_alt_rounded, NutritionPalette.protein),
    ('Fish', Icons.water_rounded, NutritionPalette.dairy),
  ];

  Offset _position(int index) {
    final angle = -math.pi / 2 + index * math.pi / 3;
    return Offset(100 * math.cos(angle), 100 * math.sin(angle));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NutritionReveal(
                controller: enterController,
                index: 0,
                total: _items.length + 1,
                child: FadeTransition(
                  opacity: _pulseController.drive(
                    Tween(begin: 0.6, end: 1.0),
                  ),
                  child: NutritionPlate(
                    size: 152,
                    rimColor: const Color(0xFFF1E8E2),
                    sections: const [
                      NutritionPalette.protein,
                      NutritionPalette.carb,
                      NutritionPalette.veg,
                    ],
                    center: const Icon(
                      Icons.egg_alt_rounded,
                      size: 30,
                      color: NutritionPalette.protein,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < _items.length; i++)
                NutritionReveal(
                  controller: enterController,
                  index: i + 1,
                  total: _items.length + 1,
                  child: Transform.translate(
                    offset: _position(i),
                    child: FoodTile(
                      icon: _items[i].$2,
                      label: _items[i].$1,
                      color: _items[i].$3,
                      background: const Color(0xFFFFF7ED),
                      size: 46,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Protein sits beside the other food groups — not instead of them.',
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
// 2. Carbohydrates — balanced plate of everyday carb foods
// ---------------------------------------------------------------------------
class CarbComparisonVisual extends StatefulWidget {
  final NutritionTopic topic;

  const CarbComparisonVisual({super.key, required this.topic});

  @override
  State<CarbComparisonVisual> createState() => _CarbComparisonVisualState();
}

class _CarbComparisonVisualState extends NutritionEnterState<CarbComparisonVisual> {
  static const List<(String, IconData, Color)> _foods = [
    ('Rice', Icons.rice_bowl_rounded, NutritionPalette.carb),
    ('Roti', Icons.cake_rounded, NutritionPalette.grain),
    ('Oats', Icons.rice_bowl_rounded, NutritionPalette.grain),
    ('Potato', Icons.local_florist_rounded, NutritionPalette.carb),
    ('Fruit', Icons.apple_rounded, NutritionPalette.fruit),
    ('Whole grains', Icons.grain_rounded, NutritionPalette.grain),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: NutritionReveal(
            controller: enterController,
            index: 0,
            total: 2,
            child: NutritionPlate(
              size: 168,
              rimColor: const Color(0xFFF4ECD9),
              sections: const [
                NutritionPalette.carb,
                NutritionPalette.grain,
                NutritionPalette.fruit,
                NutritionPalette.veg,
              ],
              center: const Icon(
                Icons.rice_bowl_rounded,
                size: 30,
                color: NutritionPalette.carb,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _foods.length; i++)
              NutritionReveal(
                controller: enterController,
                index: i + 1,
                total: _foods.length + 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _foods[i].$3.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_foods[i].$2, size: 13, color: _foods[i].$3),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _foods[i].$1,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const NutritionNoteChip(
          icon: Icons.auto_awesome_rounded,
          text:
              'No food here is "good" or "bad" — they all sit together on the plate, in portions that suit you.',
          color: NutritionPalette.carb,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Fats — types of fats comparison
// ---------------------------------------------------------------------------
class FatWheelVisual extends StatefulWidget {
  final NutritionTopic topic;

  const FatWheelVisual({super.key, required this.topic});

  @override
  State<FatWheelVisual> createState() => _FatWheelVisualState();
}

class _FatWheelVisualState extends NutritionEnterState<FatWheelVisual> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 0,
                total: 3,
                child: const _FatCard(
                  title: 'Unsaturated fats',
                  caption: 'Everyday sources for most meals',
                  color: NutritionPalette.seed,
                  items: ['Nuts', 'Seeds', 'Oils', 'Fatty fish'],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 1,
                total: 3,
                child: const _FatCard(
                  title: 'Mindful amounts',
                  caption: 'Still allowed — just noticed',
                  color: NutritionPalette.protein,
                  items: [
                    'Ghee & butter',
                    'Packaged fried snacks',
                    'Processed foods',
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NutritionReveal(
          controller: enterController,
          index: 2,
          total: 3,
          child: const NutritionNoteChip(
            icon: Icons.balance_rounded,
            text:
                'All fats are energy-dense — a little often goes a long way. No fat needs to be feared or banned.',
            color: NutritionPalette.fat,
          ),
        ),
      ],
    );
  }
}

class _FatCard extends StatelessWidget {
  final String title;
  final String caption;
  final Color color;
  final List<String> items;

  const _FatCard({
    required this.title,
    required this.caption,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              height: 1.35,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 12, color: color),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        height: 1.3,
                        color: AppColors.textDark,
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

// ---------------------------------------------------------------------------
// 4. Fibre — food icons joining a circle around a digestion icon
// ---------------------------------------------------------------------------
class FibreWheelVisual extends StatefulWidget {
  final NutritionTopic topic;

  const FibreWheelVisual({super.key, required this.topic});

  @override
  State<FibreWheelVisual> createState() => _FibreWheelVisualState();
}

class _FibreWheelVisualState extends NutritionEnterState<FibreWheelVisual> {
  static const List<(String, IconData, Color)> _foods = [
    ('Vegetables', Icons.eco_rounded, NutritionPalette.veg),
    ('Fruit', Icons.apple_rounded, NutritionPalette.fruit),
    ('Beans', Icons.rice_bowl_rounded, NutritionPalette.protein),
    ('Lentils', Icons.soup_kitchen_rounded, NutritionPalette.protein),
    ('Whole grains', Icons.grain_rounded, NutritionPalette.grain),
    ('Nuts & seeds', Icons.energy_savings_leaf_rounded, NutritionPalette.seed),
  ];

  Offset _position(int index) {
    final angle = -math.pi / 2 + index * math.pi / 3;
    return Offset(90 * math.cos(angle), 90 * math.sin(angle));
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
                width: 186,
                height: 186,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NutritionPalette.veg.withValues(alpha: 0.35),
                    width: 1.4,
                  ),
                ),
              ),
              NutritionReveal(
                controller: enterController,
                index: 0,
                total: _foods.length + 1,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F8F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NutritionPalette.veg.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.soup_kitchen_rounded,
                        size: 26,
                        color: NutritionPalette.veg,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Digestion',
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
              for (var i = 0; i < _foods.length; i++)
                NutritionReveal(
                  controller: enterController,
                  index: i + 1,
                  total: _foods.length + 1,
                  child: Transform.translate(
                    offset: _position(i),
                    child: FoodTile(
                      icon: _foods[i].$2,
                      label: _foods[i].$1,
                      color: _foods[i].$3,
                      background: _foods[i].$3.withValues(alpha: 0.12),
                      size: 42,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fibre foods join together to support everyday digestion — added gradually, with fluids.',
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
// 5. Micronutrients — colourful nutrient food grid
// ---------------------------------------------------------------------------
class NutrientGridVisual extends StatefulWidget {
  final NutritionTopic topic;

  const NutrientGridVisual({super.key, required this.topic});

  @override
  State<NutrientGridVisual> createState() => _NutrientGridVisualState();
}

class _NutrientGridVisualState extends NutritionEnterState<NutrientGridVisual> {
  static const List<(String, IconData, Color)> _foods = [
    ('Leafy greens', Icons.eco_rounded, NutritionPalette.veg),
    ('Carrots', Icons.local_florist_rounded, NutritionPalette.carb),
    ('Tomatoes', Icons.local_florist_rounded, NutritionPalette.fruit),
    ('Citrus fruit', Icons.apple_rounded, NutritionPalette.fruit),
    ('Beans & dal', Icons.rice_bowl_rounded, NutritionPalette.protein),
    ('Nuts & seeds', Icons.energy_savings_leaf_rounded, NutritionPalette.seed),
    ('Eggs', Icons.egg_alt_rounded, NutritionPalette.protein),
    ('Curd & milk', Icons.local_cafe_rounded, NutritionPalette.dairy),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF0F3),
                Color(0xFFFFF7E8),
                Color(0xFFF0FDF4),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _foods.length; i++)
                NutritionReveal(
                  controller: enterController,
                  index: i,
                  total: _foods.length,
                  child: FoodTile(
                    icon: _foods[i].$2,
                    label: _foods[i].$1,
                    color: _foods[i].$3,
                    background: _foods[i].$3.withValues(alpha: 0.12),
                    size: 48,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const NutritionNoteChip(
          icon: Icons.palette_rounded,
          text:
              'Different colours, different nutrients — a varied week is all you need. No single food is "super".',
          color: NutritionPalette.fruit,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Hydration — animated water bottle
// ---------------------------------------------------------------------------
class WaterBottleVisual extends StatefulWidget {
  final NutritionTopic topic;

  const WaterBottleVisual({super.key, required this.topic});

  @override
  State<WaterBottleVisual> createState() => _WaterBottleVisualState();
}

class _WaterBottleVisualState extends State<WaterBottleVisual>
    with SingleTickerProviderStateMixin {
  int _drops = 0;
  static const int _maxDrops = 4;
  late final AnimationController _dropController;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  String get _levelLabel => switch (_drops) {
        0 => 'Just starting',
        1 => 'Good start',
        2 => 'Getting there',
        3 => 'Almost full',
        _ => 'Nice and hydrated',
      };

  void _addDrop() {
    if (_drops >= _maxDrops) return;
    setState(() => _drops++);
    _dropController.forward(from: 0);
  }

  void _reset() {
    setState(() => _drops = 0);
    _dropController.reset();
  }

  @override
  Widget build(BuildContext context) {
    const bottleWidth = 96.0;
    const bottleHeight = 170.0;
    const waterBottom = 14.0;
    final waterHeight =
        waterBottom + 0.22 * bottleHeight * _drops / _maxDrops;

    return Column(
      children: [
        SizedBox(
          height: 236,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 34),
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 18,
                      decoration: BoxDecoration(
                        color: NutritionPalette.dairy.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: bottleWidth,
                      height: bottleHeight,
                      decoration: BoxDecoration(
                        color: NutritionPalette.dairy.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: NutritionPalette.dairy.withValues(alpha: 0.45),
                          width: 1.6,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            width: bottleWidth,
                            height: waterHeight,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFAED4F5),
                                  Color(0xFF6495ED),
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
              AnimatedBuilder(
                animation: _dropController,
                builder: (context, child) {
                  final t = Curves.easeIn.transform(_dropController.value);
                  return Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 40 + t * 85),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 26,
                        color: Color(0xFF6495ED),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: NutritionPalette.dairy.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _levelLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: NutritionPalette.dairy,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in const [
              'With meals',
              'Hot day',
              'After activity',
              'Evening',
            ])
              GestureDetector(
                onTap: _addDrop,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: NutritionPalette.dairy.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 15,
                        color: NutritionPalette.dairy,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
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
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _drops == 0 ? null : _reset,
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Start again'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMedium,
                textStyle: GoogleFonts.inter(fontSize: 11.5),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'A playful visual, not a rule — your own thirst, weather and activity are the real guides.',
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
// 7. Balanced Meals — interactive plate builder
// ---------------------------------------------------------------------------
class PlateBuilderVisual extends StatefulWidget {
  final NutritionTopic topic;

  const PlateBuilderVisual({super.key, required this.topic});

  @override
  State<PlateBuilderVisual> createState() => _PlateBuilderVisualState();
}

class _PlateBuilderVisualState extends State<PlateBuilderVisual> {
  static const List<(String, IconData, Color)> _groups = [
    ('Protein', Icons.egg_alt_rounded, NutritionPalette.protein),
    ('Carbohydrate', Icons.rice_bowl_rounded, NutritionPalette.carb),
    ('Vegetables', Icons.eco_rounded, NutritionPalette.veg),
    ('Healthy fat', Icons.energy_savings_leaf_rounded, NutritionPalette.fat),
  ];

  final Set<int> _selected = {0, 1};

  @override
  Widget build(BuildContext context) {
    final sections = [
      for (var i = 0; i < _groups.length; i++)
        if (_selected.contains(i)) _groups[i].$3,
    ];
    final count = sections.length;
    final message = count == 0
        ? 'Tap a food group to build your plate.'
        : count == 1
            ? 'A start — add a little more variety.'
            : count == 2
                ? 'Getting there — happy to build on it.'
                : count == 3
                    ? 'That looks nicely balanced.'
                    : 'A balanced meal, your way.';

    return Column(
      children: [
        NutritionPlate(
          size: 170,
          rimColor: const Color(0xFFF4ECD9),
          sections: sections,
          center: Icon(
            sections.isEmpty
                ? Icons.lunch_dining_rounded
                : Icons.dinner_dining_rounded,
            size: 30,
            color: sections.isNotEmpty
                ? NutritionPalette.protein
                : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _groups.length; i++)
              NutritionTapChip(
                label: _groups[i].$1,
                icon: _groups[i].$2,
                color: _groups[i].$3,
                selected: _selected.contains(i),
                onTap: () => setState(() {
                  if (!_selected.add(i)) _selected.remove(i);
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(count),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.babyPink.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Protein + Fibre — two-part meal comparison
// ---------------------------------------------------------------------------
class PairingComparisonVisual extends StatefulWidget {
  final NutritionTopic topic;

  const PairingComparisonVisual({super.key, required this.topic});

  @override
  State<PairingComparisonVisual> createState() =>
      _PairingComparisonVisualState();
}

class _PairingComparisonVisualState
    extends NutritionEnterState<PairingComparisonVisual> {
  List<String> get _pairings {
    final data = widget.topic.visualData?['pairings'];
    if (data == null) {
      return ['Dal + vegetables', 'Curd + fruit + seeds', 'Chana + salad'];
    }
    return nutritionStringList(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 0,
                total: 3,
                child: const _PairingCard(
                  title: 'Protein',
                  icon: Icons.egg_alt_rounded,
                  color: NutritionPalette.protein,
                  foods: ['Dal', 'Paneer', 'Curd', 'Eggs'],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 34),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: NutritionPalette.protein,
                  ),
                ),
              ),
            ),
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 1,
                total: 3,
                child: const _PairingCard(
                  title: 'Fibre',
                  icon: Icons.eco_rounded,
                  color: NutritionPalette.veg,
                  foods: ['Vegetables', 'Fruit', 'Beans', 'Whole grains'],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        NutritionReveal(
          controller: enterController,
          index: 2,
          total: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: NutritionPalette.veg.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example pairings',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: NutritionPalette.veg,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final pairing in _pairings)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: NutritionPalette.veg.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          pairing,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PairingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> foods;

  const _PairingCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final food in foods)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 12, color: color),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      food,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        height: 1.3,
                        color: AppColors.textDark,
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

// ---------------------------------------------------------------------------
// 9. Whole Grains — grain transformation timeline
// ---------------------------------------------------------------------------
class GrainTimelineVisual extends StatefulWidget {
  final NutritionTopic topic;

  const GrainTimelineVisual({super.key, required this.topic});

  @override
  State<GrainTimelineVisual> createState() => _GrainTimelineVisualState();
}

class _GrainTimelineVisualState extends NutritionEnterState<GrainTimelineVisual> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 0,
                total: 3,
                child: const _GrainStep(
                  icon: Icons.grain_rounded,
                  title: 'The grain',
                  caption: 'The whole kernel at the start',
                  color: NutritionPalette.grain,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.textLight,
            ),
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 1,
                total: 3,
                child: const _GrainStep(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Refining',
                  caption: 'Milling removes some parts',
                  color: AppColors.textLight,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.textLight,
            ),
            Expanded(
              child: NutritionReveal(
                controller: enterController,
                index: 2,
                total: 3,
                child: const _GrainStep(
                  icon: Icons.eco_rounded,
                  title: 'Whole grain',
                  caption: 'Keeps all parts — oats, millets, brown rice',
                  color: NutritionPalette.veg,
                  highlighted: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const NutritionNoteChip(
          icon: Icons.auto_awesome_rounded,
          text:
              'Whole grains are one useful option — your usual roti and rice still fit your plate whenever they suit you.',
          color: NutritionPalette.grain,
        ),
      ],
    );
  }
}

class _GrainStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  final Color color;
  final bool highlighted;

  const _GrainStep({
    required this.icon,
    required this.title,
    required this.caption,
    required this.color,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? color
              : AppColors.borderGrey.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
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
// 10. Vegetables — sliding into the plate one by one
// ---------------------------------------------------------------------------
class VegPlateVisual extends StatefulWidget {
  final NutritionTopic topic;

  const VegPlateVisual({super.key, required this.topic});

  @override
  State<VegPlateVisual> createState() => _VegPlateVisualState();
}

class _VegPlateVisualState extends NutritionEnterState<VegPlateVisual> {
  static const List<(String, IconData, Color)> _vegetables = [
    ('Palak', Icons.eco_rounded, NutritionPalette.veg),
    ('Lauki', Icons.local_florist_rounded, NutritionPalette.veg),
    ('Tori', Icons.local_florist_rounded, NutritionPalette.veg),
    ('Carrot', Icons.local_florist_rounded, NutritionPalette.carb),
    ('Beans', Icons.grass_rounded, NutritionPalette.veg),
    ('Capsicum', Icons.eco_rounded, NutritionPalette.veg),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 240,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NutritionReveal(
                controller: enterController,
                index: 0,
                total: _vegetables.length + 1,
                child: NutritionPlate(
                  size: 168,
                  rimColor: const Color(0xFFE9F2E9),
                  sections: const [
                    NutritionPalette.veg,
                    NutritionPalette.veg,
                    NutritionPalette.veg,
                  ],
                  center: const Icon(
                    Icons.eco_rounded,
                    size: 30,
                    color: NutritionPalette.veg,
                  ),
                ),
              ),
              for (var i = 0; i < _vegetables.length; i++)
                NutritionReveal(
                  controller: enterController,
                  index: i + 1,
                  total: _vegetables.length + 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i.isEven ? 98 : 0,
                      left: i.isOdd ? 98 : 0,
                    ),
                    child: FoodTile(
                      icon: _vegetables[i].$2,
                      label: _vegetables[i].$1,
                      color: _vegetables[i].$3,
                      background: _vegetables[i].$3.withValues(alpha: 0.12),
                      size: 38,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Each vegetable slides in beside the others — more colours, more variety, your usual sabzis.',
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