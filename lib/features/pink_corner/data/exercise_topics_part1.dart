import 'package:flutter/material.dart';
import 'exercise_topic.dart';

/// Exercise & Movement educational topics.
///
/// Group 1 — Why Movement Matters (1 topic)
/// Group 2 — Types of Movement (6 topics)
/// Group 3 — Movement & Your Cycle (1 topic)
/// Group 4 — Movement & PCOS/PCOD (1 topic)
///
/// All copy is short, friendly, and non-judgmental. Physical activity is
/// never presented as a cure for any medical condition, and rest is always
/// framed as a normal part of a healthy routine.
const List<ExerciseTopic> exerciseTopicsPart1 = [
  // -------------------------------------------------------------------------
  // GROUP 1 — WHY MOVEMENT MATTERS
  // -------------------------------------------------------------------------
  ExerciseTopic(
    id: 'why-physical-activity-matters',
    title: 'Why Movement Matters',
    pageTitle: 'Why Does Physical Activity Matter?',
    subtitle: 'Moving your body, your way — small steps count too.',
    category: 'Why Movement Matters',
    shortDescription: 'How regular movement supports your body and mind',
    icon: Icons.emoji_people_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    whatIsIt:
        'Physical activity simply means moving your body in ways that feel okay for you — a walk, '
        'gentle strength movements, dancing, or even everyday tasks like climbing stairs. '
        'It does not have to be "a workout" to count.',
    whyItMatters: [
      'Moves your heart and lungs, supporting cardiovascular health over time.',
      'Helps build and keep muscle strength, which supports everyday tasks like carrying groceries or getting up from the floor.',
      'Supports mobility — comfortable movement keeps your joints and muscles feeling capable.',
      'Many people notice better energy, sleep, and mood with regular movement.',
      'Movement is one part of overall well-being. It supports health — it does not cure any condition or replace medical care.',
    ],
    whatItCanLookLike: [
      'A 10-minute walk after dinner.',
      'A few wall push-ups during a study break.',
      'Dancing to two songs in the kitchen.',
      'Gentle stretches before bed.',
    ],
    howToStart: [
      'Start with a few minutes at a level that feels comfortable.',
      'Choose movement you actually like — it is easier to repeat things you enjoy.',
      'Add small amounts gradually: an extra minute, an extra block, one more day.',
      'Notice what your body is telling you, and adjust.',
    ],
    whatToNotice: [
      'Comfort: movement should feel okay, not painful.',
      'Energy: some days feel easy, some days feel heavier — both are normal.',
      'Soreness: mild tiredness can be normal; sharp pain is a stop-and-check signal.',
      'Time: busy days can still include 5 gentle minutes.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'You need to exercise intensely to get any benefit.',
        fact: 'Gentle, regular movement supports health too. Consistency matters far more than intensity.',
      ),
      ExerciseMyth(
        myth: 'If you miss a day, you have ruined everything.',
        fact: 'A missed day is just a missed day. You can start again anytime — no guilt needed.',
      ),
    ],
    whenToSeekHelp:
        'Talk to a qualified healthcare professional if movement causes sharp or lasting pain, '
        'you have a health condition or injury, you are recovering from illness or surgery, '
        'or you are unsure whether an activity is safe for you.',
    quickTakeaway:
        'Movement is a way to support your body — start small, move in ways that feel good, and be kind to yourself along the way.',
    visualType: ExerciseVisualType.benefitsWheel,
  ),

  // -------------------------------------------------------------------------
  // GROUP 2 — TYPES OF MOVEMENT
  // -------------------------------------------------------------------------
  ExerciseTopic(
    id: 'strength-training',
    title: 'Strength Training',
    pageTitle: 'Strength Training',
    subtitle: 'Using your muscles — bodyweight is a perfect start.',
    category: 'Types of Movement',
    shortDescription: 'Build strength with simple bodyweight movements',
    icon: Icons.fitness_center_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    whatIsIt:
        'Strength training means using your muscles against some kind of resistance — and your own body weight '
        'is a perfectly good resistance to begin with. Squats, wall push-ups, and glute bridges are all strength training.',
    whyItMatters: [
      'Builds muscle strength and physical capacity over time.',
      'Supports everyday things — standing up from a chair, lifting bags, playing with children.',
      'Can support bone health and metabolism as part of overall health.',
      'Many people notice more confidence and energy in daily tasks.',
    ],
    whatItCanLookLike: [
      'Chair squats: sit toward a chair edge, then stand back up slowly.',
      'Wall push-ups: hands on a wall, push gently away.',
      'Glute bridges: lying on the floor, lift your hips up and lower slowly.',
      'Light resistance bands or small household items, if you have them.',
    ],
    howToStart: [
      'Start with a few repetitions and stop while it still feels doable.',
      'Move slowly and in control — form matters more than speed.',
      'One or two short sessions a week is a great beginning.',
      'Rest between sessions: muscles adapt during rest, not during work.',
    ],
    whatToNotice: [
      'Keep breathing — do not hold your breath during a movement.',
      'Comfort in your joints — choose an easier variation if something feels off.',
      'Muscle tiredness the next day can be normal; sharp pain is not.',
      'Progress is slow, and that is completely expected.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'Strength training will make you bulky.',
        fact: 'Building noticeable muscle takes years of deliberate effort. Beginner strength training simply makes you stronger and more capable.',
      ),
      ExerciseMyth(
        myth: 'You need a gym and weights.',
        fact: 'Bodyweight and wall movements are real strength training for beginners — no equipment required.',
      ),
    ],
    whenToSeekHelp:
        'Talk to a qualified healthcare professional if you feel sharp pain during an exercise, '
        'have a joint or back condition, are recovering from an injury, or are unsure which variation suits you.',
    quickTakeaway:
        'Strength can grow anywhere — your body weight is enough to begin.',
    visualType: ExerciseVisualType.squatSequence,
  ),

  ExerciseTopic(
    id: 'walking',
    title: 'Walking',
    pageTitle: 'Walking',
    subtitle: 'The most accessible movement there is.',
    category: 'Types of Movement',
    shortDescription: 'A comfortable pace, short walks, steady habit',
    icon: Icons.directions_walk_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFE2F5EE),
    whatIsIt:
        'Walking is exactly what it sounds like — moving at your own comfortable pace, on your own schedule. '
        'No equipment, no preparation, no skill required.',
    whyItMatters: [
      'An easy starting point for movement — most people can begin today.',
      'The pace is entirely up to you, from a slow stroll to a brisk walk.',
      'Short walks genuinely add up across a week.',
      'Walking outside can add fresh air, sunlight, and a change of scene.',
    ],
    whatItCanLookLike: [
      'Ten minutes around the block.',
      'Walking while on a phone call.',
      'A short stroll in a park or garden.',
      'Walking in place indoors on a rainy day.',
    ],
    howToStart: [
      'Start with a short, comfortable walk — even 5–10 minutes is a real start.',
      'Walk at a pace where you can still talk easily.',
      'Aim to repeat it on days that work for you; consistency beats distance.',
      'Gradually add a minute or two when it feels right — no rush.',
    ],
    whatToNotice: [
      'A pace that feels comfortable — this is your walk, not a race.',
      'How your body feels during the walk.',
      'How you feel afterwards — many people feel calmer and more settled.',
      'Any pain that does not settle — stop and check in with your body.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'Walking only counts if you hit a big step number.',
        fact: 'There is no magic number. A comfortable short walk is still meaningful movement.',
      ),
      ExerciseMyth(
        myth: 'Only fast walking counts as exercise.',
        fact: 'Comfortable, steady walking supports health at any pace you enjoy.',
      ),
    ],
    whenToSeekHelp:
        'If walking triggers chest pain, dizziness, unusual shortness of breath, or joint pain that keeps coming back, '
        'talk to a healthcare professional before continuing.',
    quickTakeaway:
        'A short walk at your pace is real movement — it counts.',
    visualType: ExerciseVisualType.walkingPath,
  ),

  ExerciseTopic(
    id: 'cardio',
    title: 'Cardio',
    pageTitle: 'Cardio',
    subtitle: 'Gentle activity for your heart and lungs.',
    category: 'Types of Movement',
    shortDescription: 'Brisk walking, cycling, dancing, swimming — at any intensity',
    icon: Icons.favorite_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    whatIsIt:
        'Cardio (short for cardiovascular exercise) is activity that gently gets your heart and lungs working — '
        'brisk walking, cycling, dancing, or swimming. It can be as light or as challenging as you choose.',
    whyItMatters: [
      'Supports heart and lung health over time.',
      'Many people notice steadier energy and better mood.',
      'It comes in many forms, so it is easy to find one you enjoy.',
      'Intensity is a decision you make — not a standard everyone must meet.',
    ],
    whatItCanLookLike: [
      'A brisk walk where you are breathing a little faster.',
      'Dancing to your favourite songs at home.',
      'A gentle bike ride.',
      'Low-impact options like swimming or indoor aerobics.',
    ],
    howToStart: [
      'Choose a gentle-to-moderate level first — comfort comes before challenge.',
      'Keep sessions short at the beginning: 5–10 minutes is plenty.',
      'Build up slowly over weeks, not days.',
      'Remember: more challenging is optional, never required.',
    ],
    whatToNotice: [
      'A guideline: can you talk? Comfortable. Breathing deeper but still talking? Moderate. Hard to talk? A bigger effort — only if it is right for you.',
      'Comfort versus pain — stop if something hurts.',
      'Chest discomfort, dizziness, or unusual breathlessness — stop and seek professional guidance.',
      'How you feel afterwards: energy should move toward you, not drain you.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'Cardio must leave you exhausted to count.',
        fact: 'Comfortable, steady cardio supports health — exhaustion is not a scoreboard.',
      ),
      ExerciseMyth(
        myth: 'Everyone needs high-intensity exercise.',
        fact: 'Higher intensity is optional and does not suit everyone. Gentle options are fully valid cardio.',
      ),
    ],
    whenToSeekHelp:
        'Stop and talk to a healthcare professional if you feel chest discomfort, dizziness, unusual breathlessness, '
        'or pain during activity — especially if you have any existing health condition.',
    quickTakeaway:
        'Any pace is a pace — gentle cardio genuinely counts.',
    visualType: ExerciseVisualType.cardioIntensity,
  ),

  ExerciseTopic(
    id: 'mobility',
    title: 'Mobility',
    pageTitle: 'Mobility',
    subtitle: 'Moving comfortably through your joints\u2019 range.',
    category: 'Types of Movement',
    shortDescription: 'Shoulder circles, hip swings, gentle spine waves, ankle rolls',
    icon: Icons.accessibility_new_rounded,
    accentColor: Color(0xFF6495ED),
    backgroundColor: Color(0xFFEDF3FF),
    whatIsIt:
        'Mobility is moving comfortably through a joint\u2019s available range — like rotating your shoulders fully, '
        'or lifting your knees gently. It is about comfortable, free movement, not extreme stretching.',
    whyItMatters: [
      'Keeps everyday movement comfortable — reaching, bending, turning.',
      'Can help reduce that stiff feeling after sitting for a long time.',
      'Supports balance and makes other movement feel easier.',
      'Takes only a few gentle minutes and fits almost any day.',
    ],
    whatItCanLookLike: [
      'Shoulder circles: slow, full circles rolled backwards and forwards.',
      'Hip swings: standing, gently swing one leg forward and back while holding support.',
      'Gentle spine waves: like a slow cat–cow, sitting or on all fours.',
      'Ankle rolls: rotating each ankle in slow circles.',
    ],
    howToStart: [
      'Use small, gentle motions — never push to the point of strain.',
      'Moves within comfort: a "soft and easy" feeling, never sharp pain.',
      'A few minutes most days is a great routine.',
      'Breathe normally and relax your shoulders while you move.',
    ],
    whatToNotice: [
      'Movement should feel smooth, not painful.',
      'Stiffness may ease as you repeat movements — slowly.',
      'Sharp pain or clicking with pain means stop and check.',
      'How your body feels after a session versus before.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'More stretching is always better.',
        fact: 'Gentle movement within comfort is the goal; extreme stretching is not necessary for good mobility.',
      ),
      ExerciseMyth(
        myth: 'You need to feel burning to improve mobility.',
        fact: 'Comfortable, repeated gentle movement improves mobility over time — burning is not a required signal.',
      ),
    ],
    whenToSeekHelp:
        'If a joint hurts consistently, locks, or feels unstable, talk to a qualified professional before continuing.',
    quickTakeaway:
        'Move within comfort — mobility grows gently, not forcefully.',
    visualType: ExerciseVisualType.jointMovement,
  ),

  ExerciseTopic(
    id: 'yoga',
    title: 'Yoga',
    pageTitle: 'Yoga',
    subtitle: 'Movement, breathing, balance and relaxation.',
    category: 'Types of Movement',
    shortDescription: 'A broad, gentle practice that meets you where you are',
    icon: Icons.self_improvement_rounded,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF5EEFC),
    whatIsIt:
        'Yoga is a broad movement practice that may combine movement, breathing, balance, flexibility, and relaxation. '
        'It can look completely different from person to person — and that is the point.',
    whyItMatters: [
      'Combines gentle movement with breathing, which many people find calming.',
      'Builds body awareness and balance at a gentle pace.',
      'Very adjustable — poses can be modified with walls, chairs, or cushions.',
      'Short yoga moments can fit into busy days.',
    ],
    whatItCanLookLike: [
      'Breathing slowly while holding easy seated poses.',
      'Child\u2019s pose as a resting stretch.',
      'Slow seated twists and gentle neck circles.',
      'A very slow cat–cow on a mat, towel, or bed.',
    ],
    howToStart: [
      'Start with a few gentle poses — 10 minutes is plenty.',
      'Breathe naturally and calmly throughout.',
      'Use cushions, a wall, or a chair for support whenever helpful.',
      'Choose versions of poses that feel comfortable for your body today.',
    ],
    whatToNotice: [
      'Breathing stays calm — if you are holding your breath, soften the pose.',
      'Comfort in each position; nothing should feel like a strain.',
      'Soreness versus stretch — gentle only.',
      'Working within your own range, whatever it is today.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'You must be flexible to do yoga.',
        fact: 'Yoga meets you where you are. Flexibility may grow slowly — or not at all — and that is fine.',
      ),
      ExerciseMyth(
        myth: 'Yoga cures PCOS or mental-health conditions.',
        fact: 'Yoga is a supportive practice, not a treatment or cure for any condition.',
      ),
    ],
    whenToSeekHelp:
        'If a pose causes sharp pain, dizziness, or you have a condition affecting your joints, balance, or pregnancy, '
        'check with a qualified professional before continuing.',
    quickTakeaway:
        'Yoga is not a cure — it is a kind way to move and breathe.',
    visualType: ExerciseVisualType.yogaPoses,
  ),

  ExerciseTopic(
    id: 'pilates',
    title: 'Pilates',
    pageTitle: 'Pilates',
    subtitle: 'Slow, controlled movement with core awareness.',
    category: 'Types of Movement',
    shortDescription: 'Core strength, posture, balance and body awareness',
    icon: Icons.sports_gymnastics_rounded,
    accentColor: Color(0xFF2E8B76),
    backgroundColor: Color(0xFFE9F7F1),
    whatIsIt:
        'Pilates is a movement style built on controlled, precise movement — with a focus on the core, posture, '
        'balance, and body awareness. It is naturally low-impact and very beginner-friendly.',
    whyItMatters: [
      'Core strength supports posture and everyday tasks like lifting and carrying.',
      'Slow, controlled movement builds body awareness.',
      'Low-impact by nature — gentle on joints.',
      'Short sessions are effective; minutes matter more than marathon sessions.',
    ],
    whatItCanLookLike: [
      'Gentle pelvic tilts on a mat.',
      'Small bridge lifts — hips rising and lowering slowly.',
      'Slow leg slides lying on the floor.',
      'Seated posture check-ins: tall spine, relaxed shoulders, soft breathing.',
    ],
    howToStart: [
      'Focus on one simple movement at a time.',
      'Slow and steady beats fast — control is the goal.',
      'Breathe naturally as you move.',
      'Short sessions of 10 minutes or less are a perfect start.',
    ],
    whatToNotice: [
      'Control over speed — moving slowly and deliberately.',
      'Your breathing pattern — keep it relaxed.',
      'Tension in your neck or shoulders — drop them down gently.',
      'Comfort in your lower back — if anything pinches, stop.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'Pilates is only for people who are already fit.',
        fact: 'Pilates is very adjustable and works for beginners — control matters more than performance.',
      ),
      ExerciseMyth(
        myth: 'You need a Pilates studio to do it.',
        fact: 'Many beginner movements only need a mat or a comfortable floor.',
      ),
    ],
    whenToSeekHelp:
        'If back or joint pain appears or worsens during practice, or you are recovering from an injury, '
        'check with a qualified professional before continuing.',
    quickTakeaway:
        'Slow, controlled movement is the heart of Pilates — and it is beginner-friendly.',
    visualType: ExerciseVisualType.pilatesSequence,
  ),

  // -------------------------------------------------------------------------
  // GROUP 3 — MOVEMENT & YOUR CYCLE
  // -------------------------------------------------------------------------
  ExerciseTopic(
    id: 'movement-across-menstrual-cycle',
    title: 'Movement & Your Cycle',
    pageTitle: 'Movement Across the Menstrual Cycle',
    subtitle: 'Flexible suggestions, not rules — your signals guide you.',
    category: 'Movement & Your Cycle',
    shortDescription: 'Adjusting movement to energy across your cycle',
    icon: Icons.calendar_month_rounded,
    accentColor: Color(0xFFE892A2),
    backgroundColor: Color(0xFFFFF3F6),
    whatIsIt:
        'Energy, symptoms, comfort, and preferences can change at different points of a menstrual cycle. '
        'Movement across the cycle simply means choosing movement that matches how you feel that day.',
    whyItMatters: [
      'Some people notice lower energy or more discomfort during menstruation or the luteal phase — that is common and okay.',
      'Using your own signals helps you adjust movement to what feels appropriate, with no rigid schedule needed.',
      'Choosing a gentler option on harder days supports consistency without burnout.',
      'Movement is about how you feel — not performing on a fixed calendar.',
    ],
    whatItCanLookLike: [
      'Menstruation: gentle movement or rest as needed — walking, stretching, breathing.',
      'Follicular (after your period): build up activity if your energy feels good.',
      'Ovulation: choose comfortable activity based on how you feel.',
      'Luteal (before your period): adjust intensity according to energy and symptoms.',
    ],
    howToStart: [
      'Notice how you feel each day and let that guide your choice.',
      'Keep a few "gentle day" options ready — walking, mobility, stretching.',
      'It is okay for the same week to look different from cycle to cycle.',
      'No phase requires a specific exercise — these are flexible suggestions, not rules.',
    ],
    whatToNotice: [
      'Energy levels across the cycle — they can change week to week.',
      'Cramps or bloating — a lighter version of movement may feel better.',
      'Fatigue — a lighter version of movement is still movement.',
      'What felt good one day may differ the next — that is normal.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'You must synchronize every workout to your cycle phase.',
        fact: 'Most people do not need a strict cycle-syncing plan — flexible adjustments based on how you feel work well.',
      ),
      ExerciseMyth(
        myth: 'You should never exercise during your period.',
        fact: 'Many people enjoy gentle movement during menstruation — and rest is fine too. It is your choice.',
      ),
    ],
    whenToSeekHelp:
        'If period pain is severe, movement feels consistently unmanageable, or you are unsure what is appropriate '
        'for your cycle and health, talk to a healthcare professional.',
    quickTakeaway:
        'Your signals are the best guide — movement can flex with your cycle, not fight it.',
    visualType: ExerciseVisualType.cycleWheel,
  ),

  // -------------------------------------------------------------------------
  // GROUP 4 — MOVEMENT & PCOS/PCOD
  // -------------------------------------------------------------------------
  ExerciseTopic(
    id: 'movement-and-pcos',
    title: 'Movement & PCOS/PCOD',
    pageTitle: 'Movement & PCOS/PCOD',
    subtitle: 'A supportive part of overall health — not a cure.',
    category: 'Movement & PCOS/PCOD',
    shortDescription: 'Strength, fitness, energy and sustainable routines',
    icon: Icons.eco_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFE5EBFF),
    whatIsIt:
        'This topic is about how regular physical activity can be part of overall health and symptom management '
        'for people with PCOS/PCOD — as one supportive piece of a bigger picture that includes medical care.',
    whyItMatters: [
      'Regular movement supports strength and cardiovascular fitness.',
      'Many people with PCOS/PCOD find consistent movement helps their energy and overall well-being.',
      'Strength work can support muscle, metabolism, and daily capacity.',
      'Sustainable routines you enjoy are more helpful than "perfect" routines you cannot repeat.',
    ],
    whatItCanLookLike: [
      'A simple mix: a couple of strength sessions, walking, and gentle movement.',
      'A few short sessions a week instead of long ones.',
      'Movement that flexes with your energy on different cycle days.',
      'Rest days without guilt — recovery is part of the routine.',
    ],
    howToStart: [
      'Start with what you can already do — a walk, bodyweight strength, or yoga.',
      'Build one small habit at a time, like moving on 2–3 chosen days a week.',
      'Add variety slowly so it stays interesting.',
      'Remember: exercise alone does not cure PCOS/PCOD — it works alongside professional care, not instead of it.',
    ],
    whatToNotice: [
      'How your body responds — comfort, energy, and enjoyment are useful signals.',
      'Consistency over perfection: missed days need no guilt.',
      'Whether movement helps your energy or drains it — adjust accordingly.',
      'Any new or worrying symptoms — share them with your healthcare team.',
    ],
    myths: [
      ExerciseMyth(
        myth: 'Exercise alone reverses PCOS.',
        fact: 'No single habit cures PCOS/PCOD. Movement is a supportive part of overall health and should sit alongside professional care.',
      ),
      ExerciseMyth(
        myth: 'Only intense exercise helps PCOS.',
        fact: 'Consistent, sustainable movement at any level supports health — intensity is not a requirement.',
      ),
    ],
    whenToSeekHelp:
        'For PCOS/PCOD, talk to your healthcare team about what activity suits your situation — especially if you '
        'have other conditions, take medications, or are unsure what is appropriate for you.',
    quickTakeaway:
        'Movement supports your health — it partners with medical care, it does not replace it.',
    visualType: ExerciseVisualType.pcosBenefitMap,
  ),
];