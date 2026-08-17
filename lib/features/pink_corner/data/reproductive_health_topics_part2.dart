import 'package:flutter/material.dart';
import 'reproductive_health_topic.dart';

/// Group 2 — Ovulation & Fertility (topics 8–12).
const List<ReproductiveHealthTopic> reproductiveHealthTopicsPart2 = [
  // ---------------------------------------------------------------------
  // 8. What Is Ovulation?
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'what-is-ovulation',
    title: 'What Is Ovulation?',
    pageTitle: 'What is ovulation?',
    subtitle: 'The quiet moment an egg is released',
    category: 'Ovulation & Fertility',
    shortDescription: 'When an ovary releases an egg — and why the day can vary.',
    icon: Icons.flare_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: ReproductiveVisualType.eggReleaseAnimation,
    whatIsIt:
        'Ovulation is the moment an ovary releases a mature egg. It usually happens around the middle of '
        'a cycle, but the exact day varies from person to person and from cycle to cycle.',
    whatHappensInBody: [
      'A group of eggs begins maturing early in the cycle.',
      'Usually, one egg matures fully.',
      'The mature egg is released and picked up by the fallopian tube.',
      'If it is not fertilised, it passes through the uterus with the lining.',
    ],
    generallyNormal:
        'Ovulation can happen on different days in different cycles, and not every cycle includes '
        'ovulation. That is normal — especially during stress, illness, or big life changes.',
    whatToNotice: [
      'Whether your cycle is roughly regular for you',
      'Signs like mucus changes or mild mid-cycle twinges, if you notice them',
      'Big changes in cycle length over several months',
    ],
    whatCanHelp: [
      'Track your cycle with a simple calendar or app',
      'Note body signs like mucus changes if you want to learn your rhythm',
      'Remember no method predicts ovulation with certainty — and that is okay',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Ovulation always happens on day 14.',
        fact: 'Day 14 is only an average. Many people ovulate earlier or later, and it can shift between cycles.',
      ),
    ],
    whenToSeeDoctor:
        'If you are trying to understand your cycle for pregnancy planning, or cycles are very irregular, '
        'a healthcare professional can guide you.',
    quickTakeaway: 'Ovulation is your body releasing an egg — a quiet, invisible event that makes a cycle possible.',
  ),

  // ---------------------------------------------------------------------
  // 9. How Ovulation Relates to Pregnancy
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'ovulation-and-pregnancy',
    title: 'How Ovulation Relates to Pregnancy',
    pageTitle: 'How does ovulation relate to pregnancy?',
    subtitle: 'Sperm meets egg — and timing matters',
    category: 'Ovulation & Fertility',
    shortDescription: 'Pregnancy happens when sperm meets an egg around the fertile part of the cycle.',
    icon: Icons.route_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: ReproductiveVisualType.eggSpermPathway,
    whatIsIt:
        'Pregnancy can happen when sperm meets an egg around the fertile part of the cycle. The egg '
        'survives only a short time after ovulation, which is why timing matters.',
    whatHappensInBody: [
      'An egg is released at ovulation and travels along the fallopian tube.',
      'Sperm can survive in the body for several days after sex.',
      'If sperm meets the egg in the tube, fertilisation can happen.',
      'A fertilised egg travels to the uterus, where it can implant.',
    ],
    generallyNormal:
        'Getting pregnant takes time for most people, and there is a wide range of what is normal. It is '
        'not a race, and cycles do not follow a fixed script.',
    whatToNotice: [
      'How regular your cycles are, if pregnancy is a goal or a worry for you',
      'Whether you have reliable information about your fertile days',
      'Any question you have been meaning to ask a professional',
    ],
    whatCanHelp: [
      'Understanding your own cycle and tracking signs are safe first steps',
      'Ask professionals questions instead of relying on estimates',
      'Both partners can learn and plan together',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Pregnancy can happen on any day of the cycle.',
        fact: 'Pregnancy is only possible around the fertile window — roughly the days near ovulation — because the egg survives only a short time.',
      ),
    ],
    whenToSeeDoctor:
        'If you are trying to conceive and cycles are very irregular, or you need contraception advice, '
        'speak to a healthcare professional.',
    quickTakeaway: 'Pregnancy needs an egg and sperm to meet at the right time — biology, not a calendar alone, decides.',
  ),

  // ---------------------------------------------------------------------
  // 10. Fertile Window
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'fertile-window',
    title: 'Fertile Window',
    pageTitle: 'What is the fertile window?',
    subtitle: 'An estimate, not a guarantee',
    category: 'Ovulation & Fertility',
    shortDescription: 'The days around ovulation when pregnancy is possible — approximately.',
    icon: Icons.calendar_view_week_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: ReproductiveVisualType.fertileWindowTimeline,
    visualData: {
      'softStart': 8,
      'softEnd': 19,
      'peakStart': 12,
      'peakEnd': 16,
    },
    whatIsIt:
        'The fertile window is the stretch of days in a cycle when pregnancy is possible — the days '
        'leading up to ovulation and the day itself. It is an estimate, not a guarantee.',
    whatHappensInBody: [
      'Sperm can survive for several days inside the body.',
      'The egg survives only a short time after release.',
      'Together, this creates a window of roughly a week around ovulation.',
      'The window differs between people and between cycles.',
    ],
    generallyNormal:
        'Estimates from apps and calendars are averages, not certainties. Many people ovulate outside the '
        '“typical” window, especially with irregular cycles.',
    whatToNotice: [
      'How regular your cycles are',
      'Body signs like mucus changes can give more personal clues than calendar averages',
      'No estimate is exact — and that is completely normal',
    ],
    whatCanHelp: [
      'Combine cycle tracking with body signs for a fuller picture',
      'Use calendar estimates as a range, not a verdict',
      'Talk to a professional if the timing really matters to you',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Apps can tell you your exact fertile days.',
        fact: 'Apps use averages. They give a helpful range, but they cannot know your body’s exact timing.',
      ),
    ],
    whenToSeeDoctor:
        'If you are planning or avoiding pregnancy and need reliable information, a healthcare professional '
        'can explain options that fit your situation.',
    quickTakeaway: 'The fertile window is a helpful estimate — your body is the only real calendar.',
  ),

  // ---------------------------------------------------------------------
  // 11. PCOS / PCOD and Ovulation
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'pcos-pcod-ovulation',
    title: 'PCOS / PCOD & Ovulation',
    pageTitle: 'How can PCOS / PCOD affect ovulation?',
    subtitle: 'One condition, many different experiences',
    category: 'Ovulation & Fertility',
    shortDescription: 'Hormonal changes linked to PCOS / PCOD can affect whether and when ovulation happens.',
    icon: Icons.compare_arrows_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: ReproductiveVisualType.cycleComparison,
    whatIsIt:
        'PCOS (polycystic ovary syndrome) and PCOD (polycystic ovarian disease) are common hormonal '
        'conditions. The hormonal changes associated with them can sometimes affect whether and when ovulation happens.',
    whatHappensInBody: [
      'Hormonal changes can slow or interrupt the usual egg-maturing process.',
      'This can make ovulation happen later, less often, or not at all in some cycles.',
      'When ovulation is less frequent, periods can become irregular.',
      'Every person’s experience is different — patterns vary widely.',
    ],
    generallyNormal:
        'There is no single “PCOS experience”. Some people have regular cycles, others do not. Symptoms '
        'and cycles can change over time and with care.',
    whatToNotice: [
      'Whether cycles are becoming more or less regular for you',
      'Patterns in symptoms like acne, hair changes, or weight',
      'Any changes that concern you — write them down',
    ],
    whatCanHelp: [
      'Routine, gentle movement, balanced meals, and consistent sleep support hormone health',
      'Regular check-ups give you a clear picture over time',
      'Lifestyle care and medical support can work together',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Everyone with PCOS / PCOD has the same fertility experience.',
        fact: 'Fertility experiences vary greatly from person to person. Many people with PCOS / PCOD conceive — often with support and care.',
      ),
      ReproductiveMyth(
        myth: 'Irregular periods automatically mean PCOS.',
        fact: 'Many things can cause irregular periods. A healthcare professional can help determine the cause.',
      ),
    ],
    whenToSeeDoctor:
        'If cycles are very irregular, symptoms bother you, or you are planning pregnancy, a healthcare '
        'professional can offer guidance and support.',
    quickTakeaway: 'PCOS / PCOD affects each person differently — understanding your own body is the first step.',
  ),

  // ---------------------------------------------------------------------
  // 12. Fertility Myths
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'fertility-myths',
    title: 'Fertility Myths',
    pageTitle: 'Fertility myths vs facts',
    subtitle: 'What is true — and what is just a story',
    category: 'Ovulation & Fertility',
    shortDescription: 'Common misconceptions about fertility, gently corrected.',
    icon: Icons.fact_check_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: ReproductiveVisualType.mythFactCards,
    whatIsIt:
        'Fertility simply means the ability of a body to conceive. Many common beliefs about it are not '
        'accurate — and can cause unnecessary worry.',
    whatHappensInBody: [
      'Fertility involves many factors working together.',
      'Age, health, cycles, and partners all play a role.',
      'No single habit or “rule” decides fertility.',
      'Fertility naturally changes over time.',
    ],
    generallyNormal:
        'Fertility varies naturally between people and across ages. What is true for one person is not a '
        'rule for another.',
    whatToNotice: [
      'Cycles becoming very irregular over several months',
      'Difficulty conceiving after trying for some time',
      'Questions that keep coming back — they deserve an answer',
    ],
    whatCanHelp: [
      'Accurate information from professionals, not assumptions',
      'Regular check-ups and open conversations',
      'Talking with your partner as a team',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Certain foods or positions make you fertile.',
        fact: 'No food or position guarantees pregnancy. Balanced living supports overall health, but fertility is complex.',
      ),
      ReproductiveMyth(
        myth: 'Irregular periods mean you are infertile.',
        fact: 'Irregular cycles can make timing harder, but they do not mean infertility. Many people with irregular cycles conceive.',
      ),
      ReproductiveMyth(
        myth: 'Fertility is only a woman’s concern.',
        fact: 'Both partners contribute to conception. Couples’ health matters together.',
      ),
    ],
    whenToSeeDoctor:
        'After a year of trying without pregnancy (or six months if you are 35 or older), many professionals '
        'suggest a check-up — and earlier if cycles are very irregular.',
    quickTakeaway: 'Most fertility “rules” are myths — your body is not a test score.',
  ),
];
