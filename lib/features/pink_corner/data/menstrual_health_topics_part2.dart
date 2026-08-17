import 'package:flutter/material.dart';
import 'menstrual_health_topic.dart';

/// Topics 5–7 of the Menstrual Health educational series.
const List<MenstrualHealthTopic> menstrualHealthTopicsPart2 = [
  // ---------------------------------------------------------------------
  // 5. Spotting
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'spotting',
    title: 'Spotting',
    pageTitle: 'Spotting',
    subtitle: 'Light bleeding between periods',
    icon: Icons.grain_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: MenstrualTopicVisualType.spottingComparison,
    visualData: {
      'spotting': [
        'Much lighter — often just a few drops',
        'Usually does not fill a pad or tampon',
        'Can appear between periods, or at the start or end of a period',
      ],
      'period': [
        'A steady flow over a few days',
        'Usually needs a pad, tampon, or cup',
        'Follows your cycle\u2019s usual rhythm',
      ],
    },
    whatIsIt:
        'Spotting is light bleeding between periods. It is much lighter than a period, '
        'and it usually does not need a pad, tampon, or cup — though a panty liner can help.',
    whatHappensInBody: [
      'Spotting can happen when hormone levels shift.',
      'It can occur around ovulation, before a period, or near the start or end of a period.',
      'Stress, illness, or changes in routine can also play a part.',
      'Occasional spotting is common and often harmless.',
    ],
    generallyNormal:
        'Many people spot occasionally — around ovulation, just before a period, or after changes in routine or medication. '
        'Light, occasional spotting is often normal. Repeated or unexpected spotting is a different pattern.',
    whatToNotice: [
      'How often spotting happens',
      'Whether it happens between periods regularly',
      'Whether it comes with pain, itchiness, or unusual discharge',
      'Whether spotting is new before or after sex',
      'Whether it started after beginning, stopping, or changing a medication or method',
    ],
    whatCanHelp: [
      'Note spotting days on your calendar',
      'Use a panty liner for comfort',
      'Track whether spotting is one-off or repeated',
    ],
    myths: [
      MenstrualMyth(
        myth: 'Spotting always means something is wrong.',
        fact: 'Occasional spotting is common and often harmless. Persistent or unexpected patterns are what a professional can help you understand.',
      ),
      MenstrualMyth(
        myth: 'Spotting is the same as a period.',
        fact: 'Spotting is much lighter and shorter. A period is the steady shedding of the uterine lining that follows a full cycle.',
      ),
    ],
    whenToSeeDoctor:
        'It is a good idea to discuss spotting with a healthcare professional if it happens regularly between periods, '
        'keeps coming back, lasts several days, comes with pain or discomfort, or happens alongside other unusual symptoms. '
        'Spotting during pregnancy should always be discussed with a professional.',
    quickTakeaway: 'Occasional spotting is often normal — repeated or unexpected spotting deserves a conversation.',
  ),

  // ---------------------------------------------------------------------
  // 6. PMS vs PMDD
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'pms-vs-pmdd',
    title: 'PMS vs PMDD',
    pageTitle: 'PMS vs PMDD',
    subtitle: 'Two different experiences',
    icon: Icons.balance_rounded,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF8F0FF),
    visualType: MenstrualTopicVisualType.pmsPmddComparison,
    visualData: {
      'pms': {
        'tagline': 'Milder symptoms that may affect comfort and routine.',
        'physical': [
          'Bloating, breast tenderness, headaches',
          'Mild tiredness or sleep changes',
        ],
        'emotional': [
          'Mood changes, mild irritability',
          'Usually manageable day to day',
        ],
        'behavioral': [
          'Cravings, small changes in routine',
        ],
        'life': 'Symptoms may be noticeable but usually do not stop everyday activities.',
        'severity': 30,
      },
      'pmdd': {
        'tagline': 'More severe symptoms that can significantly affect daily life.',
        'physical': [
          'Strong tiredness, sleep or appetite changes',
          'Physical symptoms that feel harder to manage',
        ],
        'emotional': [
          'Strong low mood, irritability, or anxiety',
          'Feeling overwhelmed or losing interest in usual things',
        ],
        'behavioral': [
          'Symptoms that disrupt work, study, or relationships',
        ],
        'life': 'Symptoms are severe enough to affect daily life, and they ease after the period begins.',
        'severity': 75,
      },
    },
    whatIsIt:
        'PMS (premenstrual syndrome) and PMDD (premenstrual dysphoric disorder) both involve symptoms before a period. '
        'PMDD is a distinct condition with much more severe emotional symptoms — it is not simply "very bad PMS".',
    whatHappensInBody: [
      'Hormone levels change after ovulation, in the luteal phase.',
      'These changes can affect mood, energy, and how the body feels.',
      'Most people feel some effect; how strong it is varies a lot.',
      'In PMDD, the emotional symptoms are severe enough to affect daily life.',
    ],
    generallyNormal:
        'Mild to moderate changes in mood and energy before a period are very common. '
        'What matters is how much symptoms affect your daily life, and how regularly they follow your cycle.',
    whatToNotice: [
      'When symptoms start and when they ease (often after the period begins)',
      'Physical symptoms like bloating, breast tenderness, or headaches',
      'Emotional symptoms like irritability, low mood, or anxiety',
      'How much symptoms affect work, study, or relationships',
    ],
    whatCanHelp: [
      'Track symptoms daily for a few cycles to see your pattern',
      'Gentle movement, enough sleep, and balanced meals help some people',
      'Regular routines and stress management may ease symptoms',
      'PMDD has recognized treatments — discussing symptoms with a professional can help',
    ],
    myths: [
      MenstrualMyth(
        myth: 'PMDD is just "bad PMS".',
        fact: 'PMDD is a distinct condition. Its emotional symptoms are severe and can affect daily life, and it has its own recognized criteria and treatments.',
      ),
      MenstrualMyth(
        myth: 'Everyone has the same pre-period symptoms, so severe ones are exaggerated.',
        fact: 'People differ greatly. Severe, repeating symptoms deserve proper assessment and support, not dismissal.',
      ),
    ],
    whenToSeeDoctor:
        'Consider talking to a healthcare professional if emotional symptoms before your period are severe, '
        'repeat every cycle, last more than a few days, or significantly affect your work, study, or relationships. '
        'There are effective, recognized ways to help.',
    quickTakeaway: 'Mild PMS is common — but severe, repeating symptoms that affect your life deserve real help.',
  ),

  // ---------------------------------------------------------------------
  // 7. Blood Clots
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'blood-clots',
    title: 'Blood Clots',
    pageTitle: 'Blood clots',
    subtitle: 'Small clumps during a period',
    icon: Icons.blur_circular_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: MenstrualTopicVisualType.clotDiagram,
    whatIsIt:
        'Menstrual clots are clumps of tissue and blood that are shed during a period. '
        'Small, occasional clots are common and usually harmless.',
    whatHappensInBody: [
      'Your body releases natural chemicals that keep period blood flowing.',
      'When flow is faster or heavier, these chemicals may not act fast enough.',
      'Blood can form small clumps, which leave the body as clots.',
      'Clots are more common on heavier days.',
    ],
    generallyNormal:
        'Small clots — around the size of a coin or smaller — are common, especially on heavier days. '
        'What matters is size, frequency, and whether they come with very heavy flow.',
    whatToNotice: [
      'How big the clots usually are',
      'How often they happen',
      'Whether they come with very heavy flow',
      'Whether clot size or frequency has changed from your usual pattern',
    ],
    whatCanHelp: [
      'Track heavy days and clots in a simple log',
      'Use protection suited to your flow',
      'Stay hydrated and rest on heavy days',
    ],
    myths: [
      MenstrualMyth(
        myth: 'Any blood clot means a miscarriage or a condition.',
        fact: 'Small, occasional clots are a normal part of periods for many people. Size, frequency, and heavy flow together matter more than any single clot.',
      ),
      MenstrualMyth(
        myth: 'Clots always mean you are losing too much blood.',
        fact: 'Not always. Small occasional clots are common. Larger or frequent clots alongside heavy bleeding are the pattern to discuss.',
      ),
    ],
    whenToSeeDoctor:
        'Talk to a healthcare professional if clots become larger or more frequent than usual, '
        'or if they come with very heavy bleeding, dizziness, or a significant drop in energy. '
        'Repeated patterns like these are worth assessing.',
    quickTakeaway: 'Small, occasional clots are common — larger or frequent ones with heavy flow are worth a check-in.',
  ),
];