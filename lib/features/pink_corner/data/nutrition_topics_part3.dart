import 'package:flutter/material.dart';
import 'nutrition_topic.dart';

/// Indian Everyday Guides — practical articles that build on familiar foods
/// and realistic, budget-friendly habits.
const List<NutritionTopic> indianEverydayTopics = [
  // ---------------------------------------------------------------------
  // 1. How to make your normal Indian breakfast more balanced
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'balanced-breakfast',
    title: 'Balanced Indian Breakfasts',
    pageTitle: 'How to make your normal Indian breakfast more balanced',
    subtitle: 'Add to the foods you already love',
    category: 'Indian Everyday Guides',
    shortDescription:
        'Idli, poha, paratha, upma and dosa — balanced with small additions, not replaced.',
    icon: Icons.breakfast_dining_rounded,
    accentColor: Color(0xFFE8A33D),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: NutritionVisualType.buildBreakfast,
    visualData: {
      'bases': [
        {'label': 'Idli', 'sides': 'Sambar with vegetables, chutney, curd'},
        {'label': 'Poha', 'sides': 'Peanuts, vegetables, curd on the side'},
        {'label': 'Paratha', 'sides': 'Curd, vegetables, salad'},
        {'label': 'Upma', 'sides': 'Vegetables, curd, chana or eggs'},
        {'label': 'Dosa', 'sides': 'Sambar, a protein side'},
      ],
    },
    whatIsIt:
        'Balancing your breakfast does not mean changing what you eat — it means adding to the foods you already love. '
        'Idli, poha, paratha, upma and dosa can all become fuller, more balanced meals.',
    whyItMatters: [
      'Breakfast sets up your energy for the day.',
      'Small additions can make familiar meals more filling.',
      'You do not need new recipes — just small tweaks.',
      'Breakfasts that fit your routine are the ones you will keep.',
    ],
    whatCanYouChoose: [
      'Idli → add sambar with vegetables or a side of curd',
      'Poha → add peanuts + vegetables + a side of curd',
      'Paratha → pair with curd + vegetable salad',
      'Upma → add vegetables + a protein side like curd, chana or eggs',
      'Dosa → pair with sambar + a protein side',
    ],
    whatToNotice: [
      'Whether breakfast currently has protein, fibre and vegetables',
      'How long breakfast keeps you comfortable — not hungry too soon',
      'What is practical on busy mornings',
      'Foods your family already enjoys — build on those',
    ],
    howToMakeItBalanced: [
      'Add one protein — curd, dal, egg or chana',
      'Add one fibre-rich side — sambar, vegetables, fruit',
      'Add fruit or vegetables where you can',
      'Keep the foods you love — balance is an addition, not a replacement',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Indian breakfasts like idli or poha are unhealthy and should be stopped.',
        fact: 'These are beloved, nourishing meals. Balancing them — not stopping them — is the practical idea.',
      ),
      NutritionMyth(
        myth: 'Breakfast must be the biggest meal of the day.',
        fact: 'Appetite and routines vary. What matters is a breakfast that works for you.',
      ),
    ],
    quickTakeaway:
        'Keep your idli and poha — add a little protein, fibre and colour, and breakfast becomes more balanced.',
  ),

  // ---------------------------------------------------------------------
  // 2. PCOS-conscious Indian lunch ideas
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'indian-lunch',
    title: 'Indian Lunch Ideas',
    pageTitle: 'PCOS-conscious Indian lunch ideas',
    subtitle: 'Everyday combinations, simply balanced',
    category: 'Indian Everyday Guides',
    shortDescription:
        'Dal-chawal, roti-sabzi and familiar combos — with vegetables, curd and salad.',
    icon: Icons.set_meal_rounded,
    accentColor: Color(0xFFE07A5F),
    backgroundColor: Color(0xFFFFF1EA),
    visualType: NutritionVisualType.lunchPlate,
    visualData: {
      'combos': [
        'Dal + rice + vegetables',
        'Roti + sabzi + curd',
        'Rajma + rice + salad',
        'Chole + roti + vegetables',
        'Fish/chicken + rice or roti + vegetables',
        'Paneer + roti + salad',
      ],
    },
    whatIsIt:
        'A balanced Indian lunch does not need to be special — dal-chawal, roti-sabzi and familiar '
        'combinations already have the pieces. The idea is putting them together thoughtfully.',
    whyItMatters: [
      'Dal + rice, roti + sabzi and similar combos are naturally versatile.',
      'Adding vegetables, curd and salad increases balance without new recipes.',
      'Lunch can carry you comfortably through the afternoon.',
      'It can fit any budget because it uses everyday foods.',
    ],
    whatCanYouChoose: [
      'Dal + rice + vegetables + a bowl of curd',
      'Roti + sabzi + curd + salad',
      'Rajma + rice + salad',
      'Chole + roti + vegetables',
      'Fish/chicken + rice or roti + vegetables',
      'Paneer + roti + salad',
    ],
    whatToNotice: [
      'Which lunch combinations your household already makes',
      'Whether lunch includes vegetables or salad most days',
      'How you feel after lunch — energy, comfort, digestion',
      'Meals that fit the time you actually have at lunch',
    ],
    howToMakeItBalanced: [
      'Keep your usual base — rice or roti — and add sabzi or salad',
      'Add curd or dal for protein',
      'Prepare extra for dinner or next-day lunch',
      'Rotate proteins across the week — dal, chana, rajma, curd, eggs, fish, chicken',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'A "complete" lunch requires several separate dishes cooked fresh daily.',
        fact: 'Leftovers, one-pot meals and simple combinations are completely fine — planning over perfection.',
      ),
      NutritionMyth(
        myth: 'Rice at lunch is unhealthy.',
        fact: 'Rice is a normal part of Indian meals. With dal, vegetables and curd, it is a balanced meal.',
      ),
    ],
    quickTakeaway:
        'Your usual lunch is a great starting point — add vegetables, curd or salad and it becomes more balanced.',
  ),

  // ---------------------------------------------------------------------
  // 3. Budget-friendly protein sources in India
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'budget-protein',
    title: 'Budget-Friendly Protein',
    pageTitle: 'Budget-friendly protein sources in India',
    subtitle: 'Everyday staples, affordable choices',
    category: 'Indian Everyday Guides',
    shortDescription:
        'Dal, chana, rajma, soy chunks, peanuts, eggs and curd — protein that fits any budget.',
    icon: Icons.savings_rounded,
    accentColor: Color(0xFF2E8B76),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: NutritionVisualType.budgetProteinCards,
    visualData: {
      'sources': [
        {'label': 'Dal', 'note': 'Everyday staple'},
        {'label': 'Chana & rajma', 'note': 'Soak and cook at home'},
        {'label': 'Soy chunks', 'note': 'Great in curries'},
        {'label': 'Peanuts', 'note': 'Roasted or in chutneys'},
        {'label': 'Eggs', 'note': 'Quick and versatile'},
        {'label': 'Curd & milk', 'note': 'Already at home'},
      ],
    },
    whatIsIt:
        'Getting enough protein does not have to be expensive. Many affordable Indian foods — '
        'dal, chana, rajma, soy chunks, peanuts, eggs, curd — are excellent everyday protein sources.',
    whyItMatters: [
      'Protein can fit any budget with simple staples.',
      'Rotating proteins adds variety without adding cost.',
      'Planning around sales and seasons can help.',
      'Protein is not only about expensive foods like meat or cheese.',
    ],
    whatCanYouChoose: [
      'Dal, moong, masoor, toor — everyday staples',
      'Chana and rajma — soaked and cooked at home',
      'Soy chunks — soya bhurji, soya curry',
      'Peanuts — roasted or in chutneys',
      'Eggs — one of the most budget-friendly options where available',
      'Curd and milk',
    ],
    whatToNotice: [
      'Your regular grocery staples — most already include protein',
      'Which proteins are cheapest in your local market',
      'Your cooking time and routine — dried beans need soaking, eggs are quick',
      'Any specific dietary needs or conditions',
    ],
    howToMakeItBalanced: [
      'Cook larger batches of dal or chana to use across meals',
      'Keep boiled eggs or roasted chana as grab-and-go protein',
      'Use leftover dal in wraps, chillas or soups',
      'Mix protein sources — dal with rice, curd with meals',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Protein on a budget means compromising on health.',
        fact: 'Dal, chana, rajma, eggs and curd are wholesome, affordable protein foods — no compromise needed.',
      ),
      NutritionMyth(
        myth: 'Vegetarian meals can never have enough protein.',
        fact: 'A varied vegetarian diet of dal, beans, curd, milk and nuts provides plenty of protein for most people.',
      ),
    ],
    quickTakeaway:
        'Protein is within reach on any budget — your dal, chana and eggs already count.',
  ),

  // ---------------------------------------------------------------------
  // 4. What can I eat when I have cravings?
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'cravings',
    title: 'Cravings',
    pageTitle: 'What can I eat when I have cravings?',
    subtitle: 'Noticing them kindly, choosing freely',
    category: 'Indian Everyday Guides',
    shortDescription:
        'Sweet, crunchy or salty cravings — practical ideas, and full permission to enjoy food.',
    icon: Icons.restaurant_rounded,
    accentColor: Color(0xFFE892A2),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: NutritionVisualType.cravingCards,
    visualData: {
      'cravings': [
        {
          'label': 'Sweet',
          'icon': 'icecream',
          'ideas': ['Fruit + curd', 'Dates + nuts', 'Dark chocolate in a small portion'],
        },
        {
          'label': 'Crunchy',
          'icon': 'cookie',
          'ideas': ['Roasted chana', 'Makhana', 'Peanuts'],
        },
        {
          'label': 'Salty',
          'icon': 'set_meal',
          'ideas': ['Chana chaat', 'Home-made snack mixes', 'A small portion of your favourite'],
        },
      ],
    },
    whatIsIt:
        'Cravings happen to everyone, and they are not a personal failure. '
        'They can come from hunger, habits, emotions, hormones, or simply enjoying food. '
        'Cravings are a normal part of being human.',
    whyItMatters: [
      'Labelling cravings "bad" makes them heavier than they need to be.',
      'Noticing cravings without judgment helps you respond kindly.',
      'Practical alternatives can satisfy the same want, sometimes with more balance.',
      'Sometimes the kindest answer is the food you are actually craving, in a reasonable portion.',
    ],
    whatCanYouChoose: [
      'Sweet craving → fruit + curd, dates + nuts, or a small piece of dark chocolate',
      'Crunchy craving → roasted chana, makhana, peanuts',
      'Salty craving → chana chaat, home-made snack combinations',
      'And sometimes: the actual food you want, enjoyed without guilt',
    ],
    whatToNotice: [
      'Whether cravings come with real hunger or without it',
      'Times of day or situations where cravings tend to appear',
      'How you feel after eating when very hungry versus just wanting taste',
      'Any pattern of cravings that feels distressing — support is available',
    ],
    howToMakeItBalanced: [
      'Eat regularly enough that cravings do not come from extreme hunger',
      'Keep a satisfying alternative nearby',
      'Give yourself full permission to enjoy treats sometimes — permission reduces obsession',
      'Move, rest and manage stress — cravings often fade when tiredness or stress eases',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Having cravings means you lack willpower.',
        fact: 'Cravings are normal and human — hormones, habits, hunger and emotions all play a part.',
      ),
      NutritionMyth(
        myth: 'You must always replace cravings with "healthy" alternatives.',
        fact: 'Alternatives are options, not orders. Sometimes enjoying the real thing, mindfully, is the most balanced choice.',
      ),
    ],
    quickTakeaway:
        'Cravings are not failures — notice them kindly, and choose what truly satisfies you.',
  ),

  // ---------------------------------------------------------------------
  // 5. Healthy alternatives to common snacks
  // ---------------------------------------------------------------------
  NutritionTopic(
    id: 'snack-alternatives',
    title: 'Snack Swaps',
    pageTitle: 'Healthy alternatives to common snacks',
    subtitle: 'Try this more often, not restrict that',
    category: 'Indian Everyday Guides',
    shortDescription:
        'Small, kind switches for familiar snacks — no food is ever off-limits.',
    icon: Icons.swap_horiz_rounded,
    accentColor: Color(0xFFD9A62E),
    backgroundColor: Color(0xFFFFFAEB),
    visualType: NutritionVisualType.snackComparison,
    visualData: {
      'swaps': [
        {'usual': 'Chips', 'idea': 'Roasted chana or makhana'},
        {'usual': 'Sweets', 'idea': 'Fruit + curd, or dates + nuts'},
        {'usual': 'Biscuits', 'idea': 'Peanuts + raisins, or toast with peanut butter'},
        {'usual': 'Fried namkeen', 'idea': 'Roasted or air-fried snack mixes'},
      ],
    },
    whatIsIt:
        'Snacking is a normal part of eating. The idea is not to ban familiar snacks, '
        'but to taste small switches — "try this more often" instead of "restrict this".',
    whyItMatters: [
      'Food should not come with guilt.',
      'Small switches add up without changing your life.',
      'Snacks can contribute useful nutrients — not just fill time.',
      'Keeping your favourites makes balance sustainable.',
    ],
    whatCanYouChoose: [
      'Chips → roasted chana or makhana',
      'Sweets → fruit + curd, or dates + nuts',
      'Biscuits → peanuts + raisins, or a slice of toast with peanut butter',
      'Fried namkeen → roasted or air-fried snack mixes',
      'And remember: the original snack is still allowed — no food is off-limits',
    ],
    whatToNotice: [
      'Snacks that are mostly repetitive and mindless',
      'Whether you are eating snacks on autopilot or enjoying them',
      'Which alternatives you genuinely like — no point in ones you hate',
      'Portions that leave you satisfied, not stuffed',
    ],
    howToMakeItBalanced: [
      'Keep alternatives visible and ready — roasted chana in a bowl',
      'Portion snacks into small bowls instead of eating from the packet',
      'Pair a snack with something filling if hunger is real',
      'Enjoy your favourite snacks openly — nothing is "bad"',
    ],
    mythFact: [
      NutritionMyth(
        myth: 'Snacking ruins your health, so snacks must be eliminated.',
        fact: 'Snacking is normal. The focus is on variety and portions, not elimination.',
      ),
      NutritionMyth(
        myth: 'One snack choice defines how healthy your eating is.',
        fact: 'Overall patterns matter far more than any single snack.',
      ),
    ],
    quickTakeaway:
        'Try this more often, not restrict that — small, kind switches beat strict rules.',
  ),
];