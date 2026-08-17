import 'package:flutter/material.dart';
import 'reproductive_health_topic.dart';

/// Group 4 — Important Symptoms (topics 18–22) and the final
/// "When should I see a gynecologist?" guide (topic 23).
const List<ReproductiveHealthTopic> reproductiveHealthTopicsPart4 = [
  // ---------------------------------------------------------------------
  // 18. Unusual Discharge
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'unusual-discharge',
    title: 'Unusual Discharge',
    pageTitle: 'When is discharge “unusual”?',
    subtitle: 'Know your baseline, notice persistent change',
    category: 'Important Symptoms',
    shortDescription: 'How discharge varies naturally — and when a change is worth discussing.',
    icon: Icons.water_rounded,
    accentColor: Color(0xFFFFB085),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: ReproductiveVisualType.symptomComparison,
    visualData: {
      'naturalTitle': 'Can vary naturally',
      'natural': [
        'Amount and texture change through the cycle',
        'Clear to white, odourless or mild-smelling',
        'Shifts with stress, age, and hormones',
      ],
      'checkTitle': 'Worth discussing',
      'check': [
        'Persistent change in colour or smell',
        'Discharge with pain, itching, or sores',
        'A change that lasts across cycles',
      ],
    },
    whatIsIt:
        'Discharge is how the vagina cleans itself, and it naturally varies in amount, colour, and texture '
        'through the cycle. “Unusual” means a persistent change from what is typical for you.',
    whatHappensInBody: [
      'Discharge changes with hormones, cycle phase, stress, and age.',
      'Clear to white, mild-smelling discharge is common.',
      'Persistent unusual changes — especially with pain, itching, a strong odour, or sores — may need medical evaluation.',
      'One unusual day is rarely a concern; patterns matter more.',
    ],
    generallyNormal:
        'There is a wide range of normal discharge. What matters most is your own baseline and any '
        'persistent change from it.',
    whatToNotice: [
      'A lasting change in colour, amount, or texture',
      'A strong or unusual odour that persists',
      'Discharge along with itching, burning, pain, or sores',
      'Discharge that follows sex with a new partner',
    ],
    whatCanHelp: [
      'Wash gently with water; avoid douches and strong soaps',
      'Note the pattern — a short symptom diary helps if you see a professional',
      'Cotton underwear and comfortable clothing',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Any unusual-looking discharge means an infection.',
        fact: 'Discharge varies naturally. Persistent changes with other symptoms are worth checking — but they are not an automatic diagnosis.',
      ),
    ],
    whenToSeeDoctor:
        'Persistent unusual discharge with pain, itching, a strong odour, or sores can have several possible '
        'causes. A healthcare professional can help determine the cause.',
    quickTakeaway: 'Your baseline is the best reference — persistent changes, not single days, are worth attention.',
  ),

  // ---------------------------------------------------------------------
  // 19. Persistent Pelvic Pain
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'persistent-pelvic-pain',
    title: 'Persistent Pelvic Pain',
    pageTitle: 'What does persistent pelvic pain mean?',
    subtitle: 'Pain that lasts deserves attention',
    category: 'Important Symptoms',
    shortDescription: 'When pain is more than a bad day — and what patterns to track.',
    icon: Icons.healing_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: ReproductiveVisualType.bodyLocationMap,
    whatIsIt:
        'Pelvic pain is pain felt in the lower belly or pelvis — the area below the navel. Occasional '
        'twinges happen, but pain that is persistent, severe, or disruptive deserves attention.',
    whatHappensInBody: [
      'Pain can be linked to periods, ovulation, or the cycle.',
      'It can also have digestive, muscular, or other causes.',
      'Pain is real whenever you feel it — intensity is personal.',
      'Persistent pain is different from a single bad day.',
    ],
    generallyNormal:
        'Many people feel some cramping around their period or ovulation. What matters is how pain compares '
        'to your usual experience and whether it interferes with life.',
    whatToNotice: [
      'Pain that lasts or keeps coming back',
      'Pain worse than your usual period cramps',
      'Pain during sex, with urination, or with bowel movements',
      'Pain along with fever, heavy bleeding, or nausea',
    ],
    whatCanHelp: [
      'Heat, rest, and gentle movement can ease discomfort',
      'Track the pattern — what makes it better or worse',
      'A symptom diary makes any consultation far more useful',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Pain is just something women have to bear.',
        fact: 'Persistent or severe pain deserves attention. You are not exaggerating — you are asking for care.',
      ),
    ],
    whenToSeeDoctor:
        'Pain that persists, worsens, or interferes with daily life should be evaluated. Pain with fever or '
        'very heavy bleeding needs prompt care.',
    quickTakeaway: 'Persistent pain is information — a signal worth taking to a professional, not a badge to endure.',
  ),

  // ---------------------------------------------------------------------
  // 20. Abnormal Bleeding
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'abnormal-bleeding',
    title: 'Abnormal Bleeding',
    pageTitle: 'What counts as “abnormal” bleeding?',
    subtitle: 'Bleeding outside your usual pattern',
    category: 'Important Symptoms',
    shortDescription: 'Patterns like spotting, heavier flow, or bleeding after sex — what to track.',
    icon: Icons.event_note_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: ReproductiveVisualType.bleedingPatterns,
    visualData: {
      'items': [
        {
          'icon': 'heavier',
          'title': 'Heavier than usual',
          'desc': 'A clear change from your typical flow',
        },
        {
          'icon': 'between',
          'title': 'Between periods',
          'desc': 'Spotting or bleeding outside your cycle',
        },
        {
          'icon': 'after',
          'title': 'After intercourse',
          'desc': 'Bleeding after sex — worth mentioning',
        },
        {
          'icon': 'longer',
          'title': 'Much longer than usual',
          'desc': 'Periods that drag well past your pattern',
        },
      ],
    },
    whatIsIt:
        '“Abnormal” bleeding simply means bleeding outside your usual pattern — between periods, after sex, '
        'heavier or longer than usual, or after menopause.',
    whatHappensInBody: [
      'Many factors can shift bleeding: hormones, stress, cycle changes, medications, or other causes.',
      'A single unusual episode is usually nothing to worry about.',
      'Repeated or significant changes are worth discussing.',
      'Bleeding after menopause is always worth mentioning.',
    ],
    generallyNormal:
        'Periods naturally vary — heavier some months, lighter others. “Abnormal” means a clear change from '
        'what is typical for you, especially if it repeats.',
    whatToNotice: [
      'Bleeding between periods',
      'Bleeding after intercourse',
      'Much heavier or longer periods than usual for you',
      'Any bleeding after menopause',
    ],
    whatCanHelp: [
      'Track bleeding on a calendar — dates, heaviness, and context',
      'A simple record makes any consultation far more useful',
      'Remember: patterns matter more than single episodes',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Bleeding between periods is always serious.',
        fact: 'It can have many causes, some minor. It is still worth mentioning — patterns, not panic.',
      ),
    ],
    whenToSeeDoctor:
        'Repeated unusual bleeding, bleeding after menopause, or bleeding that makes you feel unwell should '
        'be evaluated by a healthcare professional.',
    quickTakeaway: 'Your bleeding pattern is your baseline — any persistent shift from it is worth a conversation.',
  ),

  // ---------------------------------------------------------------------
  // 21. Pain During Intercourse
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'pain-during-intercourse',
    title: 'Pain During Intercourse',
    pageTitle: 'Pain during intercourse — what now?',
    subtitle: 'Common, under-discussed, and often manageable',
    category: 'Important Symptoms',
    shortDescription: 'Possible causes and patterns worth tracking — help exists.',
    icon: Icons.medical_information_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: ReproductiveVisualType.careGuidance,
    visualData: {
      'feelTitle': 'What it can feel like',
      'feel': [
        'Pain at the entrance or deeper inside',
        'Always, sometimes, or with certain situations',
        'May come with dryness or burning',
      ],
      'helpTitle': 'What can help',
      'help': [
        'Lubricant and gentler pacing',
        'Open conversations with your partner',
        'A professional can help find causes and options',
      ],
    },
    whatIsIt:
        'Pain during sex is common and under-discussed. It can have many possible causes — physical, '
        'hormonal, muscular, or emotional — and it is not something you simply have to accept.',
    whatHappensInBody: [
      'Pain can be at the entrance or deeper inside.',
      'Causes can include dryness, hormonal changes, tightness, infections, or other factors.',
      'It can appear suddenly or build over time.',
      'It can also change with partners or situations.',
    ],
    generallyNormal:
        'A little discomfort occasionally can happen. Persistent or significant pain during intercourse is '
        'worth addressing — it is not “just how it is”.',
    whatToNotice: [
      'Whether pain is at the entrance or deeper',
      'When it happens — always, sometimes, or in certain situations',
      'Associated dryness, burning, or bleeding',
      'Whether it affects how you feel about intimacy',
    ],
    whatCanHelp: [
      'Lubricant, gentler pacing, and open conversations with your partner',
      'A short note of when it hurts helps a professional understand',
      'Pain is not something to endure silently',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Pain during sex means something is wrong with your body.',
        fact: 'It can have many causes, most of them manageable — and it is never something you must silently endure.',
      ),
    ],
    whenToSeeDoctor:
        'Persistent or significant pain during intercourse can have several possible causes. A healthcare '
        'professional can help determine the cause and suggest options.',
    quickTakeaway: 'Intimacy should not hurt — if it does, help exists and it starts with one conversation.',
  ),

  // ---------------------------------------------------------------------
  // 22. Possible STI Symptoms
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'possible-sti-symptoms',
    title: 'Possible STI Symptoms',
    pageTitle: 'Possible STI symptoms — what should I know?',
    subtitle: 'Signs can be quiet; testing speaks clearly',
    category: 'Important Symptoms',
    shortDescription: 'Possible signs to notice — and why only testing can tell for sure.',
    icon: Icons.checklist_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: ReproductiveVisualType.symptomChecklist,
    visualData: {
      'items': [
        'Unusual discharge or a strong odour',
        'Burning while urinating',
        'Sores, bumps, or itching in the genital area',
        'Pain during sex or in the pelvis',
        'Possible exposure with a new or untested partner',
      ],
    },
    whatIsIt:
        'Some STIs cause signs like discharge, sores, burning, or itching — but many cause no symptoms at '
        'all. Any single sign can have many causes; only testing tells you what is happening.',
    whatHappensInBody: [
      'Possible signs vary and overlap with non-STI causes.',
      'Some STIs can be present with no obvious symptoms.',
      'Untreated STIs can affect long-term health — early testing helps.',
      'Most STIs are easily treated once known.',
    ],
    generallyNormal:
        'Noticing a possible sign is common and not a judgment. The healthy response is curiosity and '
        'testing, not shame or guessing.',
    whatToNotice: [
      'Unusual discharge or a strong odour',
      'Burning while urinating',
      'Sores, bumps, or itching in the genital area',
      'Pain during sex or in the pelvis',
      'Possible exposure with a new or untested partner',
    ],
    whatCanHelp: [
      'Testing after symptoms or possible exposure',
      'Using condoms consistently',
      'Testing is quick, often painless, and confidential',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'If I feel fine, I definitely don’t have an STI.',
        fact: 'Many STIs are silent. Testing is the only way to know for sure.',
      ),
    ],
    whenToSeeDoctor:
        'If you have possible symptoms or possible exposure, testing is the clear next step — the sooner, '
        'the better for you and anyone else.',
    quickTakeaway: 'Symptoms can be quiet — testing speaks clearly where signs stay silent.',
  ),

  // ---------------------------------------------------------------------
  // 23. When Should I See a Gynecologist?
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'when-to-see-gynecologist',
    title: 'When Should I See a Gynecologist?',
    pageTitle: 'When should I see a gynecologist?',
    subtitle: 'A calm, practical guide',
    category: 'When to See a Gynecologist',
    shortDescription: 'A traffic-light guide: track, consider booking, or seek prompt care.',
    icon: Icons.monitor_heart_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: ReproductiveVisualType.trafficLightGuide,
    visualData: {
      'zones': [
        {
          'key': 'green',
          'label': 'Track & Monitor',
          'items': [
            'Mild spotting mid-cycle',
            'A single heavier period',
            'Mild cramps that settle',
            'Mood changes with the cycle',
          ],
        },
        {
          'key': 'yellow',
          'label': 'Consider Booking a Consultation',
          'items': [
            'Persistent pelvic pain',
            'Repeated unusual bleeding',
            'Significant cycle changes',
            'Ongoing unusual discharge',
            'Pain during intercourse',
            'Possible STI exposure or symptoms',
            'Symptoms that interfere with everyday life',
          ],
        },
        {
          'key': 'red',
          'label': 'Seek Prompt / Urgent Medical Care',
          'items': [
            'Severe sudden pain',
            'Very heavy bleeding',
            'Fever with pelvic pain',
            'Bleeding after menopause',
          ],
        },
      ],
    },
    whatIsIt:
        'A gynecologist is a doctor who specialises in reproductive health. You do not need to be in crisis '
        'to visit — but some situations deserve quicker care.',
    whatHappensInBody: [
      'Routine visits help you understand your body and catch things early.',
      'Many changes are normal variation — track them first.',
      'Some patterns are worth booking a consultation for.',
      'A few situations deserve prompt care — not panic, just promptness.',
    ],
    generallyNormal:
        'Your own baseline is the reference. Most people benefit from a routine visit even when everything '
        'feels fine.',
    whatToNotice: [
      'This topic is the guide itself — the traffic-light visual below helps you place your own situation.',
    ],
    whatCanHelp: [
      'Use the traffic-light guide below',
      'Keep a simple symptom diary before any visit',
      'Bring a list of questions with you',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'You only need a gynecologist when pregnant or unwell.',
        fact: 'Routine, preventive visits are an important part of care for everyone.',
      ),
    ],
    whenToSeeDoctor: 'See the traffic-light guide below for examples at each level.',
    quickTakeaway: 'Gynecological care is not for crises only — it is for every stage and question along the way.',
  ),
];
