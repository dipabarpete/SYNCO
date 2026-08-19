import 'package:flutter/material.dart';
import 'stress_wellbeing_topic.dart';

/// Group 2 — Mental Well-being (topics 5–11, incl. the dedicated
/// "When should I seek professional help?" guide).
const List<StressWellbeingTopic> stressWellbeingTopicsPart2 = [
  // ---------------------------------------------------------------------
  // 5. Anxiety
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'anxiety',
    title: 'Anxiety',
    pageTitle: 'Anxiety — what it can feel like',
    subtitle: 'Worry and worry-thoughts, in plain words',
    category: 'Mental Well-being',
    shortDescription: 'Occasional worry is human — and when it persists, support helps.',
    icon: Icons.psychology_outlined,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: StressVisualType.anxiousThoughts,
    whatIsIt:
        'Anxiety is a natural response to uncertainty — the mind goes into \u201cwatch\u201d mode. '
        'Everyone feels anxious sometimes. It becomes a conversation worth having when it shows up often, '
        'sticks around, and starts shaping daily life.',
    bodyMindProcess: [
      'The body can go on alert: heart speeds up, breathing quickens, muscles tense.',
      'Thoughts can race ahead to \u201cwhat if\u201d scenarios.',
      'Focus narrows onto the thing that feels risky.',
      'It is a human response — not a character flaw.',
    ],
    commonExperiences: [
      'Persistent worry about things big and small',
      'Feeling restless, on edge, or unable to relax',
      'Racing thoughts, especially at bedtime',
      'Tension in the chest, shoulders, or stomach',
    ],
    practicalTips: [
      'Slow, long breathing can signal your body that it\u2019s safe to settle.',
      'Ground yourself — notice 3 things you can see, feel, and hear.',
      'Write worrisome thoughts down — naming them often shrinks their grip.',
      'Limit caffeine and late-night scrolling if they fuel the buzz.',
    ],
    myths: [
      StressMyth(
        myth: 'Feeling anxious means you have an anxiety disorder.',
        fact: 'Occasional anxiety is universal. Diagnosis is a professional\u2019s job — feeling anxious alone does not label you.',
      ),
      StressMyth(
        myth: 'You should just stop worrying.',
        fact: 'Worry isn\u2019t switched off by willpower. Gentle patterns — and often support — are what actually help.',
      ),
    ],
    whenToSeekHelp:
        'When anxious feelings are frequent, intense, or interfering with school, work, sleep, or relationships, '
        'connecting with a counsellor or healthcare professional is a healthy, strong step.',
    quickTakeaway: 'An anxious moment is human; when anxiety becomes persistent, support — not self-judgement — is the next step.',
  ),

  // ---------------------------------------------------------------------
  // 6. Low Mood
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'low-mood',
    title: 'Low Mood',
    pageTitle: 'Low mood — and when it deserves support',
    subtitle: 'Not a label — just an honest look',
    category: 'Mental Well-being',
    shortDescription: 'Everyone has low stretches; persistent ones deserve support.',
    icon: Icons.cloud_outlined,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF8F0FF),
    visualType: StressVisualType.moodScale,
    whatIsIt:
        'Everyone has stretches when they feel low, tired, disconnected, or less interested in the things '
        'they usually enjoy. Low mood usually lifts with time and care. When it lingers, worsens, or starts '
        'interfering with everyday life, it\u2019s worth professional support — not a label.',
    bodyMindProcess: [
      'Mood naturally dips and rises with rest, hormones, seasons, and events.',
      'Low days are common and usually shift within days to weeks.',
      'Persistent low mood can drain energy, focus, and interest in usual things.',
      'Everyone\u2019s rhythm is different — compare with your own baseline.',
    ],
    commonExperiences: [
      'Heavy or flat feelings that come and go',
      'Less interest in things you usually enjoy',
      'Low energy even after rest',
      'Feeling disconnected or \u201cgoing through the motions\u201d',
    ],
    practicalTips: [
      'Keep small routines — meals, showers, short walks — as gentle anchors.',
      'Stay connected: a brief chat or message to someone you trust.',
      'Notice one small positive moment each day and jot it down.',
      'Move gently — even 5–10 minutes can lift mood a little.',
    ],
    myths: [
      StressMyth(
        myth: 'Feeling low for a while automatically means depression.',
        fact: 'Low mood is universal and often passes. Depression is a specific condition that only a professional can assess.',
      ),
      StressMyth(
        myth: 'Positive thinking alone fixes persistent low mood.',
        fact: 'Self-compassion helps, and professional support helps even more when low mood persists.',
      ),
    ],
    whenToSeekHelp:
        'If low mood has lasted more than a few weeks, keeps coming back, or makes school, work, or relationships '
        'hard, talking with a professional is a supportive next step.',
    quickTakeaway: 'Low days are part of being human — and persistent lows deserve support, not shame.',
  ),

  // ---------------------------------------------------------------------
  // 7. Body Image
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'body-image',
    title: 'Body Image',
    pageTitle: 'Body image — a kinder way to relate',
    subtitle: 'Beyond comparison, toward neutrality and respect',
    category: 'Mental Well-being',
    shortDescription: 'Feeling uncomfortable about appearance is common — kindness helps more than criticism.',
    icon: Icons.favorite_border_rounded,
    accentColor: Color(0xFFE892A2),
    backgroundColor: Color(0xFFFFF3F6),
    visualType: StressVisualType.bodyImage,
    whatIsIt:
        'Body image is how you think and feel about your appearance. Many people go through phases of being '
        'unhappy, uncomfortable, or overly focused on how they look — it\u2019s common, and it isn\u2019t your fault. '
        'Feeds and comparisons quietly feed it.',
    bodyMindProcess: [
      'Social media constantly invites comparison with edited, curated images.',
      'The more we compare, the more attention narrows onto perceived flaws.',
      'Comments and culture can quietly pressure how we judge our bodies.',
      'Our bodies are doing far more than being looked at.',
    ],
    commonExperiences: [
      'Looking in the mirror and focusing only on what you dislike',
      'Avoiding photos or events because of appearance',
      'Comparing your body to others and feeling \u201cless than\u201d',
      'Mood shifting after scrolling',
    ],
    practicalTips: [
      'Practice neutrality: \u201cThis is my body, and it deserves kind care\u201d — not praise, not criticism.',
      'Unfollow accounts that make you feel small.',
      'Notice what your body does for you today — breathing, moving, resting.',
      'Shift attention to people and activities you value, beyond looks.',
    ],
    myths: [
      StressMyth(
        myth: 'Feeling bad about your body is normal, so you just have to live with it.',
        fact: 'It\u2019s common, but it isn\u2019t something you have to accept quietly — support exists and it helps.',
      ),
      StressMyth(
        myth: 'There is one \u201cright\u201d body that guarantees happiness.',
        fact: 'No body type guarantees happiness. Health and wellbeing look different on everyone.',
      ),
    ],
    whenToSeekHelp:
        'If body-image thoughts feel constant, distressing, or are driving unhealthy eating or exercise patterns, '
        'a counsellor or dietitian can help — you deserve support, not another diet.',
    quickTakeaway: 'Your body deserves neutrality and respect — comparison shrinks, self-respect grows.',
  ),

  // ---------------------------------------------------------------------
  // 8. Self-Esteem
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'self-esteem',
    title: 'Self-Esteem',
    pageTitle: 'Self-esteem — a gentle foundation',
    subtitle: 'Built from small, repeated acts of kindness toward yourself',
    category: 'Mental Well-being',
    shortDescription: 'Self-talk, strengths, boundaries, and small wins that add up.',
    icon: Icons.layers_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: StressVisualType.selfEsteemBlocks,
    whatIsIt:
        'Self-esteem is how you tend to view and value yourself. It isn\u2019t fixed — it grows through small daily '
        'actions: how you speak to yourself, the boundaries you set, and the tiny wins you notice.',
    bodyMindProcess: [
      'Harsh self-talk wears esteem down over time.',
      'Noticing your strengths reinforces it.',
      'Boundaries protect it from other people\u2019s demands.',
      'Small achievements — done repeatedly — build it steadily.',
    ],
    commonExperiences: [
      'An inner critic that loops in your head',
      'Difficulty accepting compliments',
      'Feeling you must be perfect to be \u201cenough\u201d',
      'Trouble saying no or asking for help',
    ],
    practicalTips: [
      'Talk to yourself like you\u2019d talk to a friend.',
      'List three everyday things you did well today — however small.',
      'Say one kind, true thing to yourself each morning.',
      'Notice a boundary you can set this week, and set it gently.',
    ],
    myths: [
      StressMyth(
        myth: 'Self-esteem comes from achievements and praise.',
        fact: 'It grows from self-acceptance and self-compassion — achievements help, but they aren\u2019t the root.',
      ),
      StressMyth(
        myth: 'Thinking positively solves all mental-health problems.',
        fact: 'Self-kindness supports wellbeing; serious struggles deserve professional support too.',
      ),
    ],
    whenToSeekHelp:
        'If feelings of low worth are deep, constant, or tied to very low mood or harmful habits, professional '
        'support can help you rebuild from a steadier place.',
    quickTakeaway: 'Self-esteem is built like a foundation — one small kind action at a time.',
  ),

  // ---------------------------------------------------------------------
  // 9. Emotional Eating
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'emotional-eating',
    title: 'Emotional Eating',
    pageTitle: 'Emotional eating — understanding it kindly',
    subtitle: 'Food meets feelings — no judgement needed',
    category: 'Mental Well-being',
    shortDescription: 'Eating in response to emotions is human — pausing helps, shame doesn\u2019t.',
    icon: Icons.restaurant_rounded,
    accentColor: Color(0xFFFFB085),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: StressVisualType.emotionalEatingWheel,
    whatIsIt:
        'People sometimes eat in response to emotions — stress, boredom, sadness, or tiredness — rather than '
        'physical hunger. It\u2019s a very human habit, a way of seeking comfort, distraction, or stimulation. '
        'It isn\u2019t weakness or failure.',
    bodyMindProcess: [
      'Strong feelings can pull us toward quick comfort — and food is readily comforting.',
      'Boredom and tiredness are common quiet triggers.',
      'Eating can soothe for a moment, then bring guilt — which can loop the pattern.',
      'Physical hunger grows slowly; emotional cravings often feel sudden and specific.',
    ],
    commonExperiences: [
      'Snacking while stressed without really tasting',
      'Craving specific foods when low or anxious',
      'Eating past fullness because it feels good in the moment',
      'Feeling guilty after emotional eating',
    ],
    practicalTips: [
      'Pause for 60 seconds before opening the fridge: \u201cWhat am I feeling right now?\u201d',
      'Check physical hunger — would plain water or an apple satisfy? If not, it may be emotional.',
      'Find alternative comforts: a warm drink, a walk, a call, music, or rest.',
      'Keep food choices neutral — no \u201cgood\u201d or \u201cbad\u201d labels.',
    ],
    myths: [
      StressMyth(
        myth: 'Emotional eating means you lack willpower.',
        fact: 'It\u2019s a common coping strategy — a signal that you\u2019re human, not weak.',
      ),
      StressMyth(
        myth: 'The fix is strict dieting and calorie counting.',
        fact: 'Restriction often fuels the loop. Gentle awareness and support do more.',
      ),
    ],
    whenToSeekHelp:
        'If eating feels out of control, is accompanied by strong guilt or distress, or is affecting your health, '
        'a dietitian, counsellor, or healthcare professional can help — without judgement.',
    quickTakeaway: 'Food can meet feelings — pause, notice the need, and choose a kind response, whatever it is.',
  ),

  // ---------------------------------------------------------------------
  // 10. Living With a Chronic Condition
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'chronic-condition',
    title: 'Living With a Chronic Condition',
    pageTitle: 'Living with a chronic condition like PCOS/PCOD',
    subtitle: 'You\u2019re managing a lot — that matters',
    category: 'Mental Well-being',
    shortDescription: 'The emotional ups and downs of ongoing conditions — and why support is normal.',
    icon: Icons.route_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF6F0FB),
    visualType: StressVisualType.healthJourney,
    whatIsIt:
        'Living with an ongoing condition like PCOS/PCOD comes with more than medical details — there are '
        'emotional ups and downs, treatment fatigue, frustration, and uncertainty. None of that is a personal '
        'failing; it\u2019s a normal part of the journey.',
    bodyMindProcess: [
      'Daily tracking and treatment can become tiring — sometimes called \u201ctracking fatigue\u201d.',
      'Symptoms can fluctuate, which brings uncertainty.',
      'Feeling unseen or unheard can make the load heavier.',
      'Hope and frustration often sit side by side — that\u2019s human.',
    ],
    commonExperiences: [
      'Feeling drained by appointments, medications, and tracking',
      'Frustration when progress feels slow or invisible',
      'Worry about the future or about fertility',
      'Mixed feelings about the condition and its label',
    ],
    practicalTips: [
      'Build small routines that reduce decision fatigue — pill, walk, meal, log.',
      'Celebrate process wins, not just outcome wins (\u201clogged every day this week\u201d).',
      'Give yourself permission to rest, and to feel frustrated sometimes.',
      'Keep a written list of questions for appointments.',
    ],
    myths: [
      StressMyth(
        myth: 'You should be able to manage a chronic condition on your own.',
        fact: 'No one truly manages chronic conditions alone — professionals, family, and communities are part of the picture.',
      ),
      StressMyth(
        myth: 'Struggling with it sometimes means you\u2019re coping badly.',
        fact: 'Emotional ups and downs are a normal response to an ongoing condition.',
      ),
    ],
    whenToSeekHelp:
        'If the emotional load around your condition feels heavy or persistent, mental-health support — a counsellor '
        'or psychologist — is a completely reasonable part of your care team.',
    quickTakeaway: 'Living with a chronic condition is a journey — and you\u2019re allowed company on it.',
  ),

  // ---------------------------------------------------------------------
  // 11. When Should I Seek Professional Help?
  // (Rendered prominently on the list screen; category not shown in the grid.)
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'when-to-seek-professional-help',
    title: 'When Should I Seek Professional Help?',
    pageTitle: 'When should I seek professional help?',
    subtitle: 'A calm guide, not a judgement',
    category: 'When to Seek Support',
    shortDescription: 'A clear, calm three-level guide — self-care, considering support, and urgent help.',
    icon: Icons.volunteer_activism_rounded,
    accentColor: Color(0xFFE8A33D),
    backgroundColor: Color(0xFFFFF7E8),
    visualType: StressVisualType.seekHelpTrafficLight,
    visualData: {
      'zones': [
        {
          'label': 'Self-care & monitor',
          'items': [
            'Mood dips that lift within days',
            'Stress that settles with rest or sleep',
            'Still enjoying things you usually enjoy',
            'A few tough days in an otherwise calm stretch',
          ],
        },
        {
          'label': 'Consider talking to a professional',
          'items': [
            'Low mood or worry lasting more than a few weeks',
            'Stress that feels overwhelming most days',
            'Sleep, appetite, or energy clearly affected',
            'Eating or body-image thoughts that feel distressing',
            'Struggling to cope with everyday life',
          ],
        },
        {
          'label': 'Seek urgent professional help',
          'items': [
            'Thoughts of harming yourself or ending your life',
            'Feeling unable to keep yourself safe',
            'Sudden, severe changes in mood or behaviour',
          ],
        },
      ],
    },
    whatIsIt:
        'Professional support — a counsellor, psychologist, doctor, or similar — can help when emotional '
        'difficulties persist or interfere with daily life. Reaching out is a strength, and it doesn\u2019t mean '
        'anything is \u201cwrong\u201d with you. You don\u2019t need to be in crisis to deserve support.',
    bodyMindProcess: [
      'Low mood or anxiety that persists for weeks',
      'Stress that feels overwhelming most of the time',
      'Sleep or daily functioning significantly affected',
      'Eating or body-image concerns that become distressing',
    ],
    commonExperiences: [
      'Struggling to cope with everyday demands',
      'Emotional difficulties interfering with work, study, or relationships',
      'A sense that you can\u2019t manage on your own',
      'Feelings that keep you from the life you used to enjoy',
    ],
    practicalTips: [
      'Start with a trusted adult, family doctor, or school counsellor.',
      'You can bring one honest sentence: \u201cI\u2019ve been struggling with stress and sleep lately.\u201d',
      'Support takes many forms — talk therapy, medication, lifestyle guidance, or simply a listening ear.',
      'If you\u2019re unsure, asking \u201ccould talking to someone help me?\u201d is a valid first question.',
    ],
    myths: [
      StressMyth(
        myth: 'Needing support means you\u2019re weak or broken.',
        fact: 'Seeking help is a normal, strong way people take care of themselves — no judgement attached.',
      ),
      StressMyth(
        myth: 'Only crises deserve professional help.',
        fact: 'Support can help at any point — most people benefit long before a crisis.',
      ),
    ],
    whenToSeekHelp:
        'If you\u2019re having thoughts of harming yourself or ending your life, reach out right away to a trusted '
        'person, a crisis line, or local emergency services. You deserve to be safe — help is available, and '
        'asking for it takes courage.',
    quickTakeaway: 'Support is for anyone, at any time — and asking for it is one of the strongest things you can do.',
  ),
];