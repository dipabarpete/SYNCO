import 'package:flutter/material.dart';
import 'nutrition_topic.dart';

/// Nutrition Basics educational topics — simple, practical, non-judgmental
/// introductions to everyday food groups.
const List<NutritionTopic> nutritionBasicsTopics = [
  // ---------------------------------------------------------------------
  // 1. Protein
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'protein',
    title: 'Protein',
    pageTitle: 'What is protein?',
    subtitle: 'A building block for everyday meals',
    category: 'Nutrition Basics',
    shortDescription:
        'What protein is, why your body uses it, and simple everyday sources.',
    icon: Icons.egg_alt_rounded,
    accentColor: Color(0xFFE07A5F),
    backgroundColor: Color(0xFFFFF1EA),
    visualType: NutritionVisualType.plateProtein,
    visualData: {
      'ingredients': ['Dal', 'Chana', 'Paneer', 'Curd', 'Eggs', 'Fish'],
    },
    whatIsIt:
        'Protein is one of the building blocks your body uses every day. '
        'It helps build and repair muscle, skin, hair and nails, and takes part in many everyday jobs in the body. '
        'You do not need one special protein — plenty of everyday foods count.',
    whyItMatters: [
      'Your body uses it for repair and growth — including muscle and skin.',
      'It can help meals feel more filling and satisfying.',
      'Many Indian meals already include protein — dal, chana, paneer, curd, eggs, fish or chicken.',
      'It is helpful to include a source of protein at meals when it suits you.',
    ],
    whatCanYouChoose: [
      'Dal, rajma, chana and other beans and lentils',
      'Paneer, curd and milk',
      'Eggs, fish and chicken',
      'Soy chunks or tofu',
      'Peanuts and other nuts',
    ],
    whatToNotice: [
      'Which protein foods you already enjoy and eat regularly',
      'How your body feels after a meal with protein — satisfied or hungry again soon?',
      'How protein foods fit your budget and routine',
      'Any food allergies, intolerances or preferences that matter for you',
    ],
    howToMakeItBalanced: [
      'Add dal or a bowl of curd to a familiar meal',
      'Pair protein with vegetables for a fuller meal',
      'Keep simple proteins handy — boiled eggs, roasted chana, or curd in the fridge',
      'Try one new protein source at a time, if you like',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'You must eat a "complete" protein at every single meal.',
        fact: 'Most people get enough protein from a varied everyday diet — your body combines protein from many foods over the day.',
      ),
      NutritionMyth(
        myth: 'Plant proteins are the only "good" option.',
        fact: 'Both plant and animal proteins can be part of a balanced diet. What matters is variety, what you enjoy, and what works for you.',
      ),
    ],
    quickTakeaway:
        'Protein is not about one perfect food — it is about a little variety across the day, in ways that fit you.',
  ),

  // ---------------------------------------------------------------------
  // 2. Carbohydrates
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'carbohydrates',
    title: 'Carbohydrates',
    pageTitle: 'What are carbohydrates?',
    subtitle: 'Your body\u2019s everyday energy',
    category: 'Nutrition Basics',
    shortDescription:
        'Why carbs matter for energy, and how everyday sources fit into meals.',
    icon: Icons.rice_bowl_rounded,
    accentColor: Color(0xFFE8A33D),
    backgroundColor: Color(0xFFFFF7E8),
    visualType: NutritionVisualType.carbComparison,
    visualData: {
      'foods': ['Rice', 'Roti', 'Oats', 'Potato', 'Fruit', 'Whole grains'],
    },
    whatIsIt:
        'Carbohydrates are the body\u2019s main everyday source of energy. '
        'They are found in grains, starchy vegetables, fruits and milk. '
        'They are a normal part of eating — not something to fear.',
    whyItMatters: [
      'Your body and brain use carbohydrates for everyday energy.',
      'Whole-food carbohydrate sources also bring fibre, vitamins and minerals.',
      'Carbs help meals feel satisfying and complete.',
      'The type and amount that suits you depends on you — there is no single "right" rule.',
    ],
    whatCanYouChoose: [
      'Rice and roti — your usual staples',
      'Oats and millets',
      'Potatoes and other starchy vegetables',
      'Fruit',
      'Whole grains, where available',
    ],
    whatToNotice: [
      'Which grains you already eat and enjoy',
      'How portions feel in your body — comfortable, too much, or not enough',
      'How your energy feels through the day',
      'Availability and cost — the best choice is one you can actually keep up',
    ],
    howToMakeItBalanced: [
      'Keep your usual roti or rice and add dal, sabzi or curd alongside',
      'When you can, choose whole grains like oats, brown rice, millets or whole-wheat roti',
      'Add vegetables or fruit to meals that are mostly carbohydrate',
      'Notice portion sizes that feel right for you',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Carbohydrates make you gain weight, so cut them out.',
        fact: 'Carbohydrates are a normal energy source. Weight is affected by many things — patterns, portions, activity and more. Removing a whole food group is rarely needed.',
      ),
      NutritionMyth(
        myth: 'White rice and roti are "bad" and must be replaced.',
        fact: 'Refined grains are not all-or-nothing — they fit into meals nicely with other foods. Whole grains are one useful option, not a rule.',
      ),
    ],
    quickTakeaway:
        'Carbohydrates give you energy — enjoy the foods you like, and let balance and portions guide you.',
  ),

  // ---------------------------------------------------------------------
  // 3. Fats
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'fats',
    title: 'Fats',
    pageTitle: 'What are fats?',
    subtitle: 'Essential in sensible amounts',
    category: 'Nutrition Basics',
    shortDescription:
        'Why your body needs fats, common everyday sources, and portion awareness.',
    icon: Icons.lunch_dining_rounded,
    accentColor: Color(0xFFD9A62E),
    backgroundColor: Color(0xFFFFFAEB),
    visualType: NutritionVisualType.fatWheel,
    whatIsIt:
        'Fats are an essential part of your diet. Your body needs them for energy, '
        'for absorbing certain vitamins, and for many everyday functions. '
        'There are different types of fat — the main idea is variety and sensible portions, not avoidance.',
    whyItMatters: [
      'The body needs fat for normal functioning — it is not optional.',
      'Unsaturated fats are commonly found in nuts, seeds, oils and fish.',
      'Fats help your body absorb vitamins like A, D, E and K.',
      'Fats are energy-dense, so a little often goes a long way.',
    ],
    whatCanYouChoose: [
      'Nuts — almonds, walnuts, peanuts, cashews',
      'Seeds — sesame, pumpkin, flax',
      'Groundnut, mustard and other vegetable oils used in cooking',
      'Avocado, where available',
      'Fatty fish like mackerel, where you eat fish',
    ],
    whatToNotice: [
      'How much oil you use in cooking',
      'Portion sizes of nuts and seeds — a small handful works for many people',
      'Which fats you enjoy and can afford consistently',
      'Labels like "trans fat" if you buy packaged snacks',
    ],
    howToMakeItBalanced: [
      'Use oil in measured amounts rather than pouring freely',
      'Add a few nuts or seeds to breakfast, curd or salads',
      'Vary the oils you use over the week',
      'If you have high cholesterol or other conditions, a professional can guide you',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'All fats are unhealthy.',
        fact: 'Your body needs fat. Unsaturated fats from nuts, seeds, oils and fish are a normal part of eating — portions and variety matter.',
      ),
      NutritionMyth(
        myth: 'Cutting all oil from cooking is the healthy option.',
        fact: 'Cooking oils are part of everyday Indian meals. Reducing excess is fine, but removing all fats is not needed for most people.',
      ),
    ],
    quickTakeaway:
        'Fats are friends in sensible portions — varied sources, measured amounts, no fear.',
  ),

  // ---------------------------------------------------------------------
  // 4. Fibre
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'fibre',
    title: 'Fibre',
    pageTitle: 'What is fibre?',
    subtitle: 'Your everyday digestion helper',
    category: 'Nutrition Basics',
    shortDescription:
        'What fibre is, why it supports digestion, and where to find it.',
    icon: Icons.grass_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: NutritionVisualType.fibreWheel,
    whatIsIt:
        'Fibre is the part of plant foods your body cannot fully digest. '
        'It is found in vegetables, fruits, beans, lentils, whole grains, nuts and seeds — '
        'and it quietly does useful work for your digestion.',
    whyItMatters: [
      'It supports regular digestion and comfortable bowel habits.',
      'It helps meals feel filling and satisfying.',
      'It is found naturally in many everyday Indian foods — dal, sabzi, fruits, roti.',
      'A gradual increase, along with fluids, is often most comfortable.',
    ],
    whatCanYouChoose: [
      'Vegetables — all kinds, including leafy greens',
      'Fruits — whole fruit rather than only juice where possible',
      'Beans and lentils — dal, rajma, chana',
      'Whole grains — oats, millets, brown rice, whole-wheat roti',
      'Nuts and seeds in small amounts',
    ],
    whatToNotice: [
      'Your usual digestion patterns — be gentle with yourself about regularity',
      'How your body feels when you add fibre-rich foods',
      'Whether you drink enough fluids alongside higher-fibre foods',
      'Any bloating or discomfort that keeps repeating — a professional can help',
    ],
    howToMakeItBalanced: [
      'Add fibre gradually if you are not used to it',
      'Keep vegetables in your usual meals — sabzi, curry, salads',
      'Choose whole fruit most of the time',
      'Drink water along with fibre-rich meals',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Fibre only matters if you are constipated.',
        fact: 'Fibre is part of everyday healthy eating — it supports digestion as a normal part of a varied diet.',
      ),
      NutritionMyth(
        myth: 'More fibre is always better.',
        fact: 'Very sudden large increases can cause bloating or discomfort. Gradual, steady additions are often more comfortable.',
      ),
    ],
    quickTakeaway:
        'Fibre is your everyday helper — a little variety, added gradually, goes a long way.',
  ),

  // ---------------------------------------------------------------------
  // 5. Micronutrients
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'micronutrients',
    title: 'Micronutrients',
    pageTitle: 'What are vitamins & minerals?',
    subtitle: 'Small helpers, found across foods',
    category: 'Nutrition Basics',
    shortDescription:
        'Why vitamins and minerals matter, and how a varied diet covers them.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFFE892A2),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: NutritionVisualType.nutrientGrid,
    whatIsIt:
        'Vitamins and minerals are small helpers your body needs in tiny amounts. '
        'Each one has its own job — from keeping bones strong to helping your body use energy. '
        'You do not need to memorize long lists of them.',
    whyItMatters: [
      'They support energy, bones, skin, immunity and more.',
      'Different foods carry different nutrients — no single food has them all.',
      'A varied diet is the simplest way to get a mix of them.',
      'Most needs can be met with everyday foods.',
    ],
    whatCanYouChoose: [
      'Dark leafy greens — palak, methi, saag',
      'Colourful vegetables — carrots, tomatoes, capsicum, beetroot',
      'Fruits — oranges, bananas, guava, papaya',
      'Beans, lentils and nuts',
      'Dairy, eggs, fish and chicken',
    ],
    whatToNotice: [
      'How varied your week of meals looks — different colours, different foods',
      'Any long-term symptoms like unusual tiredness that keep repeating',
      'Whether you can regularly access certain foods',
      'Life stages, pregnancy or conditions can change nutrient needs — a conversation for a professional',
    ],
    howToMakeItBalanced: [
      'Add one extra vegetable or fruit to meals you already make',
      'Rotate foods across the week — different daals, different sabzis',
      'Do not chase "superfoods" — variety beats any single food',
      'If you are considering supplements, a healthcare professional can advise',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'You need a supplement for every vitamin.',
        fact: 'A varied diet covers most needs for most people. Supplements are sometimes useful — a professional can help you decide.',
      ),
      NutritionMyth(
        myth: 'A single "superfood" can give you everything you need.',
        fact: 'No single food has all nutrients. Variety across foods is the practical approach.',
      ),
    ],
    quickTakeaway:
        'Micronutrients come from a colourful, varied plate — not from chasing one magic food.',
  ),

  // ---------------------------------------------------------------------
  // 6. Hydration
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'hydration',
    title: 'Hydration',
    pageTitle: 'Why does hydration matter?',
    subtitle: 'Simple, everyday fluid habits',
    category: 'Nutrition Basics',
    shortDescription:
        'Why fluids matter, everyday hydration habits, and letting your body guide you.',
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFF6495ED),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: NutritionVisualType.waterBottle,
    whatIsIt:
        'Water helps every part of your body work — from digestion to circulation to temperature control. '
        'Staying reasonably hydrated is simple, everyday care.',
    whyItMatters: [
      'Fluids help digestion and comfortable bowel habits.',
      'They support energy and focus.',
      'Hydration needs vary — with activity, weather and your own body.',
      'Thirst is a reasonable everyday guide for many people.',
    ],
    whatCanYouChoose: [
      'Water — plain, or with a slice of lemon',
      'Buttermilk, coconut water and light soups',
      'Milk and curd-based drinks where you enjoy them',
      'Regular fluids through the day, not only when very thirsty',
    ],
    whatToNotice: [
      'Thirst, especially in hot weather or after activity',
      'Urine colour as a rough everyday cue — pale is commonly a good sign',
      'Times you forget to drink — link water to routines like meals',
      'If you have kidney or heart conditions, fluid advice is individual — ask a professional',
    ],
    howToMakeItBalanced: [
      'Keep a bottle or glass nearby and refill it',
      'Drink with meals',
      'Add more fluids on hot days or after exercise',
      'Notice your own cues — rigid targets are not necessary for everyone',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Everyone must drink exactly eight glasses of water a day.',
        fact: 'Needs vary by person, activity, weather and health. Thirst and simple routines usually work well as everyday guides.',
      ),
      NutritionMyth(
        myth: 'Only plain water counts as hydration.',
        fact: 'Many fluids — buttermilk, milk, soups, coconut water — all contribute to hydration.',
      ),
    ],
    quickTakeaway:
        'Hydration is a daily habit — drink when thirsty, refill the bottle, and let your body guide you.',
  ),
];