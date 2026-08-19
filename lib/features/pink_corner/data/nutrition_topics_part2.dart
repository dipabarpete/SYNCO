import 'package:flutter/material.dart';
import 'nutrition_topic.dart';

/// PCOS-Conscious Eating educational topics — practical, flexible principles
/// that fit everyday Indian meals, without rigid "PCOS diet" rules.
const List<NutritionTopic> pcosConsciousTopics = [
  // ---------------------------------------------------------------------
  // 1. Balanced Meals
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'balanced-meals',
    title: 'Balanced Meals',
    pageTitle: 'What does a balanced meal look like?',
    subtitle: 'Combining food groups, your way',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'A flexible idea — protein + carbohydrate + vegetables + fat, in foods you already eat.',
    icon: Icons.dinner_dining_rounded,
    accentColor: Color(0xFFE07A5F),
    backgroundColor: Color(0xFFFFF1EA),
    visualType: NutritionVisualType.plateBuilder,
    whatIsIt:
        'A balanced meal simply includes different food groups together — for example, '
        'a protein, a carbohydrate, vegetables or fruit, and perhaps some healthy fat. '
        'It is a flexible idea, not a strict formula.',
    whyItMatters: [
      'Combining foods can help a meal feel satisfying and complete.',
      'It naturally brings a mix of nutrients without extra effort.',
      'It works with the foods you already eat — no special meals needed.',
      'For people with PCOS, steady, balanced meals are a practical everyday habit.',
    ],
    whatCanYouChoose: [
      'Dal + rice + sabzi + a bowl of curd',
      'Roti + sabzi + curd',
      'Oats + milk + fruit + a few nuts',
      'Eggs + toast + vegetables',
    ],
    whatToNotice: [
      'Whether your usual meals already combine food groups',
      'Which foods you enjoy — balance should not mean food you dislike',
      'Portions that feel comfortable for you',
      'Meals that keep you comfortable until the next one',
    ],
    howToMakeItBalanced: [
      'Add one missing piece to a familiar meal — a bowl of curd, an extra sabzi',
      'Start from meals you already eat instead of building a new menu',
      'Balance across the day too — not every single meal must be perfect',
      'Include foods you love — balance includes enjoyment',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'A balanced plate must follow one exact ratio, like half vegetables.',
        fact: 'Plates vary by person, hunger, culture and budget. The idea of balance — not one fixed ratio — is what matters.',
      ),
      NutritionMyth(
        myth: 'A balanced meal will fix PCOS.',
        fact: 'Balanced eating is a supportive habit, not a cure. PCOS care is about whole-of-life habits and, when needed, professional guidance.',
      ),
    ],
    quickTakeaway:
        'Balance is a direction, not a ruler — combine food groups in ways that fit your life.',
  ),

  // ---------------------------------------------------------------------
  // 2. Protein + Fibre
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'protein-fibre',
    title: 'Protein + Fibre',
    pageTitle: 'Why pair protein and fibre?',
    subtitle: 'A simple, satisfying meal idea',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'Pairing protein with fibre-rich foods for satisfying, everyday meals.',
    icon: Icons.link_rounded,
    accentColor: Color(0xFF2E8B76),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: NutritionVisualType.pairingComparison,
    visualData: {
      'pairings': [
        'Dal + vegetables',
        'Curd + fruit + seeds',
        'Chana + salad',
        'Paneer + vegetables',
        'Eggs + whole-grain toast',
      ],
    },
    whatIsIt:
        'Pairing a protein with a fibre-rich food is a simple, practical meal idea. '
        'Together they can make a meal more satisfying and steady.',
    whyItMatters: [
      'The combination can help a meal feel filling for longer.',
      'It often brings a wider mix of nutrients.',
      'It fits everyday Indian meals naturally.',
      'Results vary between people — it is a useful idea, not a guaranteed formula.',
    ],
    whatCanYouChoose: [
      'Dal + vegetables',
      'Curd + fruit + seeds',
      'Chana + salad',
      'Paneer + vegetables',
      'Eggs + whole-grain toast',
    ],
    whatToNotice: [
      'How you feel after protein-plus-fibre meals — this is your own experiment',
      'Meals where you feel hungry again quickly',
      'Combinations that are convenient to make regularly',
      'Your energy through the day',
    ],
    howToMakeItBalanced: [
      'Add curd or dal to meals that are mostly vegetables or grains',
      'Keep prepped basics — boiled chana, chopped salad, curd in the fridge',
      'Try one new pairing at a time',
      'Pairing is not a promise — if a meal feels better differently, that is fine',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'This pairing guarantees a specific blood-sugar response for everyone.',
        fact: 'Responses vary by person, food, portion and context. It is a practical habit, not a guarantee.',
      ),
      NutritionMyth(
        myth: 'Protein or fibre should not be eaten alone.',
        fact: 'Any meal is fine. Pairing is one useful idea, not a rule for all meals.',
      ),
    ],
    quickTakeaway:
        'Protein plus fibre is a simple pairing that can make meals more satisfying — try it where it fits.',
  ),

  // ---------------------------------------------------------------------
  // 3. Whole Grains
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'whole-grains',
    title: 'Whole Grains',
    pageTitle: 'What are whole grains?',
    subtitle: 'A useful variety, not a rule',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'Oats, brown rice, whole-wheat roti and millets — options to add, not foods to fear.',
    icon: Icons.grain_rounded,
    accentColor: Color(0xFFE8A33D),
    backgroundColor: Color(0xFFFFF7E8),
    visualType: NutritionVisualType.grainTimeline,
    whatIsIt:
        'Whole grains are grains that keep their whole kernel — including parts that are '
        'removed in refined grains. Oats, brown rice, millets and whole-wheat roti are common examples.',
    whyItMatters: [
      'They bring more fibre, vitamins and minerals than refined grains gram-for-gram.',
      'They help meals feel filling.',
      'They fit Indian cooking easily — millets, bajra and jowar are traditional foods.',
      'Swapping is about variety, not about labelling any grain "bad".',
    ],
    whatCanYouChoose: [
      'Oats — in porridge or added to batters',
      'Brown rice — instead of white rice sometimes',
      'Whole-wheat roti or mixed-grain roti',
      'Millets — ragi, jowar, bajra',
      'Other whole grains available locally',
    ],
    whatToNotice: [
      'Which whole grains you actually enjoy — there is no required one',
      'How they feel in your digestion when introduced gradually',
      'Cost and availability in your area',
      'Context — a refined grain in a meal with dal and sabzi is still a normal meal',
    ],
    howToMakeItBalanced: [
      'Swap gradually — one meal at a time',
      'Mix flours — like adding a little ragi or jowar to roti atta',
      'Keep white rice or regular roti when they suit you — neither is "wrong"',
      'Pair grains with protein, vegetables and fat for a fuller meal',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Refined grains are always unhealthy, so stop eating them completely.',
        fact: 'Refined grains are part of normal eating for many people. Whole grains are one useful choice among many — context and variety matter.',
      ),
      NutritionMyth(
        myth: 'Whole grains taste bad or are hard to cook.',
        fact: 'Many whole grains — like millets — are traditional Indian foods with simple preparations. Start with one you like.',
      ),
    ],
    quickTakeaway:
        'Whole grains are a variety to add, not a food family to be afraid of.',
  ),

  // ---------------------------------------------------------------------
  // 4. Vegetables
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'vegetables',
    title: 'Vegetables',
    pageTitle: 'Why do vegetables matter?',
    subtitle: 'Colour, fibre and variety',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'Familiar Indian vegetables and simple ways to add more colour to meals.',
    icon: Icons.eco_rounded,
    accentColor: Color(0xFF66A06B),
    backgroundColor: Color(0xFFF0F8F0),
    visualType: NutritionVisualType.vegPlate,
    visualData: {
      'vegetables': [
        'Palak',
        'Lauki',
        'Tori',
        'Carrot',
        'Beans',
        'Capsicum',
      ],
    },
    whatIsIt:
        'Vegetables bring colour, water, fibre and micronutrients to meals. '
        'Across a week, different vegetables build variety — and variety is the point.',
    whyItMatters: [
      'They add fibre and micronutrients without much effort.',
      'They make plates more colourful and meals more interesting.',
      'Familiar Indian vegetables fit every cooking style — sabzi, dal, curry, salad.',
      'They help meals feel filling while leaving room for other foods.',
    ],
    whatCanYouChoose: [
      'Leafy greens — palak, methi, saag',
      'Bottle gourd (lauki), ridge gourd (tori), snake gourd',
      'Brinjal, capsicum, tomato, carrot, beans, cauliflower',
      'Cucumber, onion, radish — raw in salads or raita',
      'Frozen vegetables where fresh is not practical',
    ],
    whatToNotice: [
      'How many colours appear on your plate across the week',
      'Which vegetables your household actually enjoys',
      'Season — eating what is available and affordable in season',
      'Cooking style — boiled, roasted, curried, raw: all count',
    ],
    howToMakeItBalanced: [
      'Add one extra vegetable to a familiar dish',
      'Keep a salad or kachumber with lunch or dinner',
      'Cook extra sabzi to use the next day',
      'Add vegetables to dal, rice, upma, poha or paratha stuffing',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Only "exotic" vegetables are healthy.',
        fact: 'Everyday desi sabzis — lauki, tori, palak, beans — are excellent choices. Familiar is great.',
      ),
      NutritionMyth(
        myth: 'Cooked vegetables lose all their nutrition.',
        fact: 'Cooking can actually help your body use some nutrients. Both cooked and raw vegetables are useful.',
      ),
    ],
    quickTakeaway:
        'Vegetables are a variety game — more colours and familiar favourites are all it takes.',
  ),

  // ---------------------------------------------------------------------
  // 5. Fruits
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'fruits',
    title: 'Fruits',
    pageTitle: 'Can fruit be part of balance?',
    subtitle: 'Naturally sweet and nourishing',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'Whole fruit in practical portions — with curd, nuts, or as a snack.',
    icon: Icons.apple_rounded,
    accentColor: Color(0xFFE892A2),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: NutritionVisualType.fruitBowl,
    whatIsIt:
        'Fruits are naturally sweet, juicy and packed with micronutrients and fibre. '
        'They can be a lovely part of a varied eating pattern.',
    whyItMatters: [
      'They bring vitamins, minerals, fibre and water.',
      'They can satisfy sweet cravings with whole food.',
      'Natural sugar in whole fruit comes with fibre and water — different from added sugar.',
      'No fruit is "off-limits" in a balanced pattern.',
    ],
    whatCanYouChoose: [
      'Whole fruit — guava, apple, banana, papaya, orange, seasonal fruit',
      'Fruit with curd',
      'Fruit with a few nuts or seeds',
      'Fruit as a snack between meals',
    ],
    whatToNotice: [
      'Which fruits are in season and affordable near you',
      'How a piece of fruit makes you feel — as a snack, dessert or with a meal',
      'Your own portions — fruit is nourishing, and your body is your guide',
      'If you have conditions like diabetes, a professional can help you fit fruit in a way that suits you',
    ],
    howToMakeItBalanced: [
      'Keep fruit visible where you will reach for it',
      'Pair fruit with curd or nuts for a more filling snack',
      'Choose whole fruit more often than juice',
      'Enjoy fruit desserts — fruit with curd or nuts is a simple one',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Fruit is too sugary for PCOS and should be avoided.',
        fact: 'Whole fruit is a normal, nourishing food. Fear of the natural sugar in fruit is not necessary for most people.',
      ),
      NutritionMyth(
        myth: 'Juice is just as good as whole fruit.',
        fact: 'Whole fruit brings fibre and keeps you fuller. Juice is fine sometimes — it just is not the same as the whole fruit.',
      ),
    ],
    quickTakeaway:
        'Fruit is not the enemy — whole fruit, in portions that suit you, is a sweet part of balance.',
  ),

  // ---------------------------------------------------------------------
  // 6. Healthy Fats
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'healthy-fats',
    title: 'Healthy Fats',
    pageTitle: 'Which fats can I choose?',
    subtitle: 'Nuts, seeds and oils, mindfully',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'Everyday unsaturated fats and why portions can matter.',
    icon: Icons.energy_savings_leaf_rounded,
    accentColor: Color(0xFFD9A62E),
    backgroundColor: Color(0xFFFFFAEB),
    visualType: NutritionVisualType.healthyFatWheel,
    whatIsIt:
        'Unsaturated fats — found in nuts, seeds, oils and fish — are a normal part of eating. '
        'They support your heart, skin and nutrient absorption.',
    whyItMatters: [
      'Unsaturated fats are commonly recommended as everyday fats.',
      'Nuts and seeds are easy to add to meals and snacks.',
      'Fats help your body absorb vitamins.',
      'Because fats are energy-dense, small portions often work well.',
    ],
    whatCanYouChoose: [
      'Nuts — almonds, walnuts, peanuts, cashews',
      'Seeds — sesame (til), pumpkin, flax',
      'Groundnut, mustard, sunflower and other vegetable oils',
      'Fatty fish, where you eat fish',
    ],
    whatToNotice: [
      'Portion sizes — a small handful of nuts is a good place to start',
      'The oil used in cooking — varying oils across the week has value',
      'How much packaged fried food you eat regularly — if you want, gradually reduce',
      'Any allergy or medical condition that changes fat advice for you',
    ],
    howToMakeItBalanced: [
      'Sprinkle seeds on curd, salad or upma',
      'Keep a small box of nuts for snacks',
      'Measure oil with a spoon while cooking',
      'Include fish like mackerel or sardines occasionally if you eat fish',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'All fats cause heart disease.',
        fact: 'Unsaturated fats from plants and fish are part of a normal diet. Portions and types matter more than fat itself.',
      ),
      NutritionMyth(
        myth: 'Zero-oil cooking is the healthiest option.',
        fact: 'Some oil in cooking is normal and useful. The goal is mindful amounts, not zero.',
      ),
    ],
    quickTakeaway:
        'Healthy fats are everyday friends — nuts, seeds and oils in mindful amounts.',
  ),

  // ---------------------------------------------------------------------
  // 7. Portion Awareness
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'portion-awareness',
    title: 'Portion Awareness',
    pageTitle: 'What is portion awareness?',
    subtitle: 'Noticing, not measuring',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'Understanding how much food feels right for you — hunger, fullness and enjoyment.',
    icon: Icons.adjust_rounded,
    accentColor: Color(0xFFFFB085),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: NutritionVisualType.adjustablePlate,
    whatIsIt:
        'Portion awareness is understanding how much food feels appropriate for you '
        'and how different foods fit into the whole meal. It is about noticing — not measuring or punishing.',
    whyItMatters: [
      'Portions that suit you help you feel comfortable after meals.',
      'You can enjoy all foods when portions are flexible.',
      'It frees you from rigid rules and "good/bad" labels.',
      'It works differently for different people — there is no universal portion.',
    ],
    whatCanYouChoose: [
      'Your usual meals, adjusted to your hunger',
      'Second helpings when genuinely hungry — and stopping when comfortably full',
      'Snacks sized by your appetite, not by the packet',
      'Smaller starter portions, then more if still hungry',
    ],
    whatToNotice: [
      'Hunger before meals and fullness after',
      'When you eat quickly — slowing down can help you notice',
      'Meals that leave you too full or too hungry',
      'Situations like parties or festivals — it is okay to eat differently sometimes',
    ],
    howToMakeItBalanced: [
      'Serve yourself a reasonable portion first, then decide if you want more',
      'Include the foods you love so no food feels strictly off-limits',
      'Eat without distraction when you can, so you notice fullness',
      'Be kind — portions change with activity, hormones, stress and seasons',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Portion awareness means counting calories or weighing food.',
        fact: 'It means noticing hunger, fullness and how a meal feels — not chasing numbers.',
      ),
      NutritionMyth(
        myth: 'You must always finish everything on your plate.',
        fact: 'Leaving food when you are comfortably full is normal and okay. Listen to your body.',
      ),
    ],
    quickTakeaway:
        'Portion awareness is self-kindness — noticing what feels right, not following strict numbers.',
  ),

  // ---------------------------------------------------------------------
  // 8. There is no single PCOS diet
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'no-single-pcos-diet',
    title: 'There is no single PCOS diet',
    pageTitle: 'There is no single PCOS diet',
    subtitle: 'Your plan is one that fits your life',
    category: 'PCOS-Conscious Eating',
    shortDescription:
        'PCOS affects people differently — no one meal plan works for everyone.',
    icon: Icons.restaurant_menu_rounded,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: NutritionVisualType.noSingleDiet,
    whatIsIt:
        'PCOS affects people differently. There is no one meal plan that works for everyone. '
        'A balanced eating pattern that fits your culture, preferences, budget and health needs '
        'can be more realistic and sustainable.',
    whyItMatters: [
      'Generic "PCOS diet" rules can be stressful and hard to follow.',
      'Your needs can differ from others with PCOS.',
      'Sustainability beats perfection — habits you can keep matter most.',
      'A doctor or dietitian can personalise advice if you want it.',
    ],
    whatCanYouChoose: [
      'Your familiar foods, balanced in simple ways',
      'A pattern that includes foods you enjoy',
      'Gradual changes you can actually maintain',
      'Guidance from a qualified professional when you want personalisation',
    ],
    whatToNotice: [
      'Advice that promises cures or bans many foods — treat it with care',
      'How your energy, mood and comfort respond to your eating pattern',
      'Your own budget, culture, cooking routine and preferences',
      'Things beyond food — sleep, movement, stress and medical care are part of PCOS care',
    ],
    howToMakeItBalanced: [
      'Base meals on foods you already eat',
      'Add variety little by little',
      'Treat food as one part of your overall care',
      'Ask a healthcare professional before big diet changes, especially with other medical conditions',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'There is one "PCOS diet" that helps everyone.',
        fact: 'PCOS is different for different people. There is no single diet — individual needs vary.',
      ),
      NutritionMyth(
        myth: 'Certain foods can reverse or eliminate PCOS.',
        fact: 'No single food eliminates PCOS. Balanced nutrition may support overall health and symptom management, alongside medical guidance, movement, sleep and stress management.',
      ),
    ],
    quickTakeaway:
        'There is no single PCOS diet — your best plan is one that fits your life, your food and your needs.',
  ),
];