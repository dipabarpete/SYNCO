import 'package:flutter/material.dart';
import 'menstrual_health_topic.dart';

/// Topics 1–4 of the Menstrual Health educational series.
const List<MenstrualHealthTopic> menstrualHealthTopicsPart1 = [
  // ---------------------------------------------------------------------
  // 1. Menstrual Cycle
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'menstrual-cycle',
    title: 'Menstrual Cycle',
    pageTitle: 'What is a menstrual cycle?',
    subtitle: 'Your cycle, phase by phase',
    icon: Icons.autorenew_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: MenstrualTopicVisualType.cycleWheel,
    whatIsIt:
        'Your menstrual cycle is the journey your body takes each month to prepare for a possible pregnancy. '
        'It starts on the first day of your period and ends the day before your next period starts.',
    whatHappensInBody: [
      'Menstruation — the uterus sheds its lining. This is your period.',
      'Follicular phase — an egg matures in the ovary, and the uterine lining starts to rebuild.',
      'Ovulation — a mature egg is released from the ovary. This often happens around the middle of the cycle.',
      'Luteal phase — the uterine lining thickens to prepare in case of pregnancy. If pregnancy does not happen, the cycle starts again.',
    ],
    generallyNormal:
        'Cycle length can vary between people and between cycles. A cycle of roughly 21–35 days is common, '
        'but your own pattern matters most. What is normal for you may not be normal for someone else.',
    whatToNotice: [
      'When your period usually starts',
      'How long your cycle usually lasts',
      'Changes in cycle length over a few cycles',
      'Big shifts from your usual pattern, especially with other symptoms',
    ],
    whatCanHelp: [
      'Track your cycle with a simple calendar or app',
      'Note how you feel in each phase',
      'Be patient — stress, travel, sleep changes, and life changes can shift a cycle',
    ],
    myths: [
      MenstrualMyth(
        myth: 'A 28-day cycle is the only "normal" cycle.',
        fact: 'Cycles of roughly 21–35 days are common. Your own steady pattern matters more than any fixed number.',
      ),
      MenstrualMyth(
        myth: 'A late or missed period always means pregnancy.',
        fact: 'Many things can shift a period — stress, illness, sleep changes, or hormonal changes. A healthcare professional can help you understand what is happening.',
      ),
    ],
    whenToSeeDoctor:
        'It can be helpful to talk to a healthcare professional if your cycle changes a lot from your usual pattern, '
        'if periods stop for several months without explanation, or if you have very painful or very heavy bleeding. '
        'These are patterns worth checking — not reasons to panic.',
    quickTakeaway: 'Your cycle is your own — learn your pattern, and notice changes without fearing them.',
  ),

  // ---------------------------------------------------------------------
  // 2. Period Flow
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'period-flow',
    title: 'Period Flow',
    pageTitle: 'Period flow',
    subtitle: 'Light, moderate, or heavier',
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: MenstrualTopicVisualType.flowScale,
    visualData: {
      'levels': [
        {
          'label': 'Light',
          'caption':
              'A lighter flow, common at the start or end of a period. You may change protection only a couple of times a day.',
        },
        {
          'label': 'Moderate',
          'caption':
              'A typical flow for many people. Protection is usually changed a few times a day, and daily activities carry on as usual.',
        },
        {
          'label': 'Heavier',
          'caption':
              'A faster flow, often in the first couple of days. You may need to change protection more often.',
        },
      ],
    },
    whatIsIt:
        'Period flow is how much blood your body releases during your period. '
        'It can be light, moderate, or heavier — and many people move between these through their lives.',
    whatHappensInBody: [
      'The lining of your uterus builds up during the cycle.',
      'If pregnancy does not happen, your body sheds this lining.',
      'How much lining there is, and how quickly it sheds, affects your flow.',
      'Flow is often heaviest in the first couple of days, then eases off.',
    ],
    generallyNormal:
        'Flow can change during the same period — heavier at the start, lighter later. '
        'It can also change from one cycle to another and between different people. '
        'There is a wide range of what is normal; your own pattern is your best reference.',
    whatToNotice: [
      'Which days feel heaviest',
      'How often you need to change your pad, tampon, or cup',
      'Whether flow has changed compared to your usual pattern',
      'Whether heavy flow keeps you from everyday activities',
    ],
    whatCanHelp: [
      'Keep pads, tampons, or a cup handy for sudden changes',
      'Note your flow on a calendar so patterns are easy to spot',
      'Choose protection that suits how your flow actually feels',
    ],
    myths: [
      MenstrualMyth(
        myth: 'Everyone should bleed roughly the same amount.',
        fact: 'Flow varies widely between people. Your own pattern is the best reference, not anyone else\u2019s.',
      ),
      MenstrualMyth(
        myth: 'A heavier period automatically means something is wrong.',
        fact: 'Some people naturally have heavier periods. It is a change from your own pattern — especially one that affects daily life — that is worth discussing.',
      ),
    ],
    whenToSeeDoctor:
        'Talk to a healthcare professional if your flow is much heavier than your usual pattern, '
        'if you are soaking through protection very quickly, or if heavy bleeding keeps you from normal daily activities. '
        'Repeated changes are worth a conversation.',
    quickTakeaway: 'Flow has a wide normal range — compare with your own pattern, not with others.',
  ),

  // ---------------------------------------------------------------------
  // 3. Heavy Bleeding
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'heavy-bleeding',
    title: 'Heavy Bleeding',
    pageTitle: 'Heavy bleeding',
    subtitle: 'When flow feels unusually heavy',
    icon: Icons.warning_amber_rounded,
    accentColor: Color(0xFFE8A33D),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: MenstrualTopicVisualType.heavyBleedingComparison,
    visualData: {
      'typical': [
        'Heavier at times, but overall similar to your usual pattern',
        'Heavy days settle quickly',
        'Does not stop you from everyday activities',
      ],
      'potentiallyHeavy': [
        'Much heavier than your usual pattern',
        'Soaking through protection very quickly',
        'Needing to change protection during the night',
        'Repeated heavy cycles that affect your energy or daily life',
      ],
      'alertTitle': 'Repeated heavy bleeding is worth a conversation',
      'alertBody':
          'A healthcare professional can help assess patterns and talk about options. This guide is educational, not a diagnosis.',
    },
    whatIsIt:
        'Heavy menstrual bleeding means your period is much heavier, or lasts much longer, than your usual pattern. '
        'It is common, and there are effective ways to help.',
    whatHappensInBody: [
      'The uterine lining builds up and is shed each cycle.',
      'A thicker lining, or changes in how it sheds, can mean heavier flow.',
      'Hormones guide this process, and hormones vary between people and across life stages.',
      'Heavy bleeding can happen once, or it can become a repeated pattern.',
    ],
    generallyNormal:
        'Some people naturally have heavier periods than others, and flow can vary between cycles. '
        'What matters is your own pattern, how often heavy bleeding happens, and how much it affects your daily life.',
    whatToNotice: [
      'Soaking through a pad or tampon very quickly',
      'Needing to change protection during the night',
      'Bleeding for much longer than your usual pattern',
      'Passing large clots often, alongside heavy flow',
      'Feeling very tired, dizzy, or low on energy around heavy days',
    ],
    whatCanHelp: [
      'Track heavy days on a calendar',
      'Keep extra protection nearby',
      'Rest and stay hydrated on heavy days',
      'Talk to a healthcare professional — effective options exist',
    ],
    myths: [
      MenstrualMyth(
        myth: 'Heavy bleeding is just "normal" and there is nothing to do about it.',
        fact: 'Heavy bleeding is common, but repeated heavy bleeding can affect your health and everyday life — and there are many effective, recognized options to help.',
      ),
      MenstrualMyth(
        myth: 'The amount of blood alone tells you what is wrong.',
        fact: 'Bleeding amount alone does not point to any one cause. Patterns and how bleeding affects your life are what a professional can help you assess.',
      ),
    ],
    whenToSeeDoctor:
        'It is worth seeing a healthcare professional if heavy bleeding is a repeated pattern, '
        'if you soak through protection very quickly, or if heavy periods affect your daily activities, energy, or iron levels. '
        'If you ever feel faint, or bleeding suddenly becomes much heavier than ever before, seek medical care.',
    quickTakeaway: 'Heavy is not the same as "normal for you" — repeated heavy bleeding is worth a conversation.',
  ),

  // ---------------------------------------------------------------------
  // 4. Light Periods
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'light-periods',
    title: 'Light Periods',
    pageTitle: 'Light periods',
    subtitle: 'When flow is lighter than usual',
    icon: Icons.opacity_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: MenstrualTopicVisualType.flowScale,
    visualData: {
      'levels': [
        {
          'label': 'Lighter',
          'caption':
              'A flow that is lighter than your usual pattern. It can be normal variation, especially some cycles.',
        },
        {
          'label': 'About usual',
          'caption':
              'A flow similar to what you usually experience. This is the pattern to compare other cycles against.',
        },
        {
          'label': 'Heavier',
          'caption':
              'A flow heavier than your usual pattern. Everyone\u2019s usual is different.',
        },
      ],
    },
    whatIsIt:
        'A light period means your flow is lighter or shorter than your usual pattern. '
        'For many people, light flow is simply how their body works.',
    whatHappensInBody: [
      'The uterine lining builds up during the cycle.',
      'A thinner lining usually means a lighter period.',
      'Hormonal changes, stress, and life stages can affect how the lining builds.',
      'Flow that has always been light is simply your body\u2019s pattern.',
    ],
    generallyNormal:
        'Some people have naturally light periods. Flow can also be lighter in some cycles than others. '
        'Light flow matters most when it is a change from your own pattern, or when it comes with other symptoms.',
    whatToNotice: [
      'Whether light flow is new or your usual pattern',
      'How long the period lasts',
      'Whether cycles are getting further apart',
      'Other symptoms, like new pain or unusual discharge',
    ],
    whatCanHelp: [
      'Track cycle length and flow on a calendar',
      'Note any change from your usual pattern',
      'Keep a simple record to share with a professional if needed',
    ],
    myths: [
      MenstrualMyth(
        myth: 'A light period always means pregnancy or a health condition.',
        fact: 'Not at all. Light flow is often normal variation. Persistent or sudden changes from your own pattern are what a professional can help assess.',
      ),
      MenstrualMyth(
        myth: 'A light period means your body is "not working".',
        fact: 'Every body has its own rhythm. Patterns — not amounts alone — guide conversations with healthcare professionals.',
      ),
    ],
    whenToSeeDoctor:
        'Consider speaking with a healthcare professional if lighter periods are a change from your usual pattern, '
        'if periods become very infrequent or stop for several months, or if light flow comes with new pain or other symptoms.',
    quickTakeaway: 'A light period is often just your body\u2019s way — changes in your own pattern are what to watch.',
  ),
];