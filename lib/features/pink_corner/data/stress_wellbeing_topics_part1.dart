import 'package:flutter/material.dart';
import 'stress_wellbeing_topic.dart';

/// Group 1 — Understanding Stress (topics 1–4).
const List<StressWellbeingTopic> stressWellbeingTopicsPart1 = [
  // ---------------------------------------------------------------------
  // 1. What Is Stress?
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'what-is-stress',
    title: 'What Is Stress?',
    pageTitle: 'What is stress, really?',
    subtitle: 'A normal response — not a personal failing',
    category: 'Understanding Stress',
    shortDescription: 'The body and mind\u2019s answer to demands — and what happens when it lingers.',
    icon: Icons.self_improvement_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: StressVisualType.stressResponse,
    whatIsIt:
        'Stress is your body and mind\u2019s response to a demand or challenge — a deadline, a big change, '
        'or a tough moment. A little stress is a normal part of life, and it can even help you focus. '
        'When stress is ongoing or overwhelming, it can start to affect how you feel and function.',
    bodyMindProcess: [
      'Your body releases energy signals that get you ready to respond.',
      'Your heartbeat and breathing can speed up, and your muscles may tense.',
      'Thoughts can narrow onto the challenge in front of you.',
      'Once the situation passes, these responses usually settle back down on their own.',
    ],
    commonExperiences: [
      'A racing heartbeat or shallow breathing',
      'Tense shoulders, jaw, or stomach',
      'Racing or repetitive thoughts',
      'Feeling irritable, restless, or drained',
    ],
    practicalTips: [
      'Name it — \u201cI\u2019m under stress right now\u201d can take some of its weight away.',
      'Slow your breathing — a few long, gentle breaths help your body settle.',
      'Move a little — a short walk can help release tension.',
      'Talk to someone you trust about what\u2019s on your mind.',
    ],
    myths: [
      StressMyth(
        myth: 'Stress means you\u2019re weak or doing something wrong.',
        fact: 'Stress is a normal human response to demands. It says nothing about your strength or worth.',
      ),
      StressMyth(
        myth: 'You can always get rid of stress completely.',
        fact: 'Some stress is a part of life. The goal is usually to manage and recover, not to eliminate it all.',
      ),
    ],
    whenToSeekHelp:
        'If stress feels overwhelming most days, keeps you up at night, or makes daily life hard to manage, '
        'talking to a healthcare professional or counsellor can help — you don\u2019t have to figure it out alone.',
    quickTakeaway: 'Stress is a normal response — and with small everyday steps, it can usually settle back down.',
  ),

  // ---------------------------------------------------------------------
  // 2. Acute vs Chronic Stress
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'acute-vs-chronic-stress',
    title: 'Acute vs Chronic Stress',
    pageTitle: 'Short-term stress vs ongoing stress',
    subtitle: 'Two different feelings, two different rhythms',
    category: 'Understanding Stress',
    shortDescription: 'A short wave that passes, or a steady current that lingers.',
    icon: Icons.timeline_rounded,
    accentColor: Color(0xFF2E8B76),
    backgroundColor: Color(0xFFE9F7F1),
    visualType: StressVisualType.stressDurationComparison,
    whatIsIt:
        'Short-term (acute) stress is the burst you feel around a specific event — an exam, a presentation, '
        'or a sudden surprise. Ongoing (chronic) stress is a longer stretch of pressure that can feel harder '
        'to switch off — like months of deadlines, caregiving, or uncertainty.',
    bodyMindProcess: [
      'Short-term stress rises quickly, then usually settles once the event passes.',
      'Ongoing stress can stay elevated for a long time, even without a single big event.',
      'Persistent stress can sometimes be linked with changes in sleep, mood, energy, and concentration.',
      'Everyone recovers differently — there is no single \u201cright\u201d pattern.',
    ],
    commonExperiences: [
      'Acute: butterflies, a quickened heartbeat, then calm once it\u2019s over',
      'Chronic: a low-grade \u201calways on\u201d feeling that\u2019s hard to switch off',
      'Chronic: fatigue, irritability, or scattered focus that builds up over time',
      'Chronic: sleep that feels restless or less refreshing',
    ],
    practicalTips: [
      'For short bursts: breathe slowly, take a 5-minute break, and let the moment pass.',
      'For longer stretches: build small daily anchors — rest, movement, connection.',
      'Break big demands into tiny next steps you can actually take.',
      'Watch your own pattern over weeks, not isolated days.',
    ],
    myths: [
      StressMyth(
        myth: 'Long-term stress always causes a serious illness.',
        fact: 'Stress affects people differently. Ongoing stress may be linked to health changes, but it does not predict any specific illness.',
      ),
      StressMyth(
        myth: 'Only \u201cmajor\u201d events cause real stress.',
        fact: 'Small daily pressures can add up too — and they are just as valid.',
      ),
    ],
    whenToSeekHelp:
        'If you\u2019ve felt tense or worn down for weeks and it\u2019s affecting your sleep, mood, or daily life, '
        'a professional can help you find workable, individual strategies.',
    quickTakeaway: 'Short bursts usually pass; ongoing pressure deserves gentle, steady care.',
  ),

  // ---------------------------------------------------------------------
  // 3. Stress, Sleep, Mood & Well-being
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'stress-sleep-mood',
    title: 'Stress, Sleep & Mood',
    pageTitle: 'How stress can affect sleep, mood & well-being',
    subtitle: 'A gentle look at the connection',
    category: 'Understanding Stress',
    shortDescription: 'How stress can sometimes show up in sleep, mood, energy, and focus.',
    icon: Icons.bedtime_outlined,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: StressVisualType.connectedParts,
    whatIsIt:
        'Stress and well-being are connected, like neighbours who share a wall. When stress rises, changes '
        'can sometimes show up in sleep, mood, energy, appetite, and how clearly you can think. '
        'The word to hold onto is \u201csometimes\u201d — stress doesn\u2019t always affect everything.',
    bodyMindProcess: [
      'Sleep: stress can sometimes make it harder to fall asleep, stay asleep, or feel rested.',
      'Mood: stress can sometimes bring irritability, worry, or low mood.',
      'Energy: stress can sometimes drain energy or leave you feeling wired.',
      'Focus: stress can sometimes scatter attention or make small tasks feel big.',
    ],
    commonExperiences: [
      'Tossing and turning at night',
      'Snapping at small things more than usual',
      'Feeling tired even after rest',
      'Losing track of what you were doing',
    ],
    practicalTips: [
      'Tie sleep to your routine — a consistent bedtime and a wind-down hour help.',
      'Keep a small mood-and-sleep note — patterns become clearer over time.',
      'Get daylight and gentle movement during the day.',
      'Lower screens near bedtime if they keep your mind running.',
    ],
    myths: [
      StressMyth(
        myth: 'A single bad night means stress is out of control.',
        fact: 'One rough night is normal. Patterns over weeks are the more useful signal.',
      ),
      StressMyth(
        myth: 'Feeling moody means something is wrong with you.',
        fact: 'Mood naturally shifts with stress, hormones, rest, and life events — it\u2019s part of being human.',
      ),
    ],
    whenToSeekHelp:
        'If stress has been linked with poor sleep, low mood, or day-to-day difficulties for several weeks, '
        'a healthcare professional can help you explore gentle, practical ways forward.',
    quickTakeaway: 'Stress, sleep, and mood move together — steadying one can help steady the others.',
  ),

  // ---------------------------------------------------------------------
  // 4. Stress & Menstrual Symptoms
  // ---------------------------------------------------------------------
  StressWellbeingTopic(
    id: 'stress-menstrual-symptoms',
    title: 'Stress & Menstrual Symptoms',
    pageTitle: 'Stress and menstrual symptoms',
    subtitle: 'Noticing patterns — not proving cause',
    category: 'Understanding Stress',
    shortDescription: 'How stress may be linked to period changes — and why patterns matter.',
    icon: Icons.calendar_month_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: StressVisualType.cycleTracking,
    whatIsIt:
        'For some people, stress may be associated with changes in how they experience menstrual symptoms — '
        'cramping, flow, or cycle timing. The link is complex and personal; stress doesn\u2019t explain every '
        'cycle change for everyone.',
    bodyMindProcess: [
      'Stress can sometimes affect how intensely period symptoms are felt.',
      'Cycles can occasionally shift in timing during a particularly stressful stretch.',
      'Changes are usually best understood as patterns over several cycles.',
      'Many factors — hormones, sleep, weight, age — also shape the cycle.',
    ],
    commonExperiences: [
      'A period that feels more painful or heavier than usual',
      'A cycle that arrives early or late now and then',
      'Stronger PMS-type symptoms in a stressful month',
      'No change at all — which is also normal',
    ],
    practicalTips: [
      'Track your cycle, symptoms, stress, and sleep — the app helps you do this.',
      'Compare patterns across cycles before drawing any conclusion.',
      'Keep heat, gentle movement, and rest handy during tougher days.',
      'Share your pattern with a healthcare professional if changes persist.',
    ],
    myths: [
      StressMyth(
        myth: 'Stress \u201ccauses\u201d every missed or late period.',
        fact: 'Cycles vary for many reasons. Stress is one possible influence, not the sole cause.',
      ),
      StressMyth(
        myth: 'Every unusual cycle means something serious.',
        fact: 'Occasional shifts are common. Persistent or major changes are what deserve a professional conversation.',
      ),
    ],
    whenToSeekHelp:
        'If periods are persistently very painful, unusually heavy, or repeatedly absent, or if a major cycle '
        'change lasts for several cycles, talk to a healthcare professional.',
    quickTakeaway: 'Stress and cycles can interact — watch your own pattern over time, and seek help when changes persist.',
  ),
];