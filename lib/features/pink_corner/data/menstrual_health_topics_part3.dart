import 'package:flutter/material.dart';
import 'menstrual_health_topic.dart';

/// Topics 8–10 of the Menstrual Health educational series.
const List<MenstrualHealthTopic> menstrualHealthTopicsPart3 = [
  // ---------------------------------------------------------------------
  // 8. Period Colors
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'period-colors',
    title: 'Period Colors',
    pageTitle: 'Period colors',
    subtitle: 'Why color changes',
    icon: Icons.palette_rounded,
    accentColor: Color(0xFFE892A2),
    backgroundColor: Color(0xFFFFF0F5),
    visualType: MenstrualTopicVisualType.colorTimeline,
    visualData: {
      'colors': [
        {
          'name': 'Bright Red',
          'value': 0xFFE4577A,
          'info': 'Fresh blood. Common at the start of a period, when flow is faster.',
        },
        {
          'name': 'Dark Red',
          'value': 0xFFB03A5B,
          'info': 'Blood that has taken a little longer to leave the body. Very common.',
        },
        {
          'name': 'Brown',
          'value': 0xFF8D5A45,
          'info': 'Older blood. Often seen at the start or end of a period.',
        },
        {
          'name': 'Pinkish',
          'value': 0xFFF3B5C3,
          'info': 'Can appear with lighter flow, or mixed with discharge.',
        },
      ],
    },
    whatIsIt:
        'Period blood can look bright red, dark red, brown, or occasionally pinkish. '
        'These color changes are normal as blood moves through the body and over time.',
    whatHappensInBody: [
      'Fresh blood is usually bright red.',
      'As blood takes longer to leave the body, it darkens.',
      'Older blood can look dark red or brown.',
      'Pinkish discharge can appear with light flow, or at the start or end of a period.',
    ],
    generallyNormal:
        'Color often changes within one period — bright at the start, darker later — and it can differ between cycles. '
        'Color alone does not diagnose a condition.',
    whatToNotice: [
      'Whether color changes fit your usual pattern',
      'Color together with your flow amount',
      'Discharge that is very different from your usual period blood',
      'New symptoms like strong odor, itching, or pain',
    ],
    whatCanHelp: [
      'Notice color without comparing to others',
      'Track if a color is new for you',
      'Pair color with the rest of your pattern',
    ],
    myths: [
      MenstrualMyth(
        myth: 'Dark blood means "bad" or infected blood.',
        fact: 'Dark red or brown blood is usually just older blood leaving the body — a normal part of periods.',
      ),
      MenstrualMyth(
        myth: 'The color of period blood can diagnose a disease.',
        fact: 'Color alone does not diagnose anything. Persistent unusual discharge or new symptoms are what a professional can help assess.',
      ),
    ],
    whenToSeeDoctor:
        'Color alone is usually not a reason to worry. Do talk to a healthcare professional if you notice discharge '
        'that is very different from your usual pattern, if it comes with odor, itching, or pain, or if you have '
        'concerns during pregnancy or after any procedure.',
    quickTakeaway: 'Color changes are normal — compare with your own pattern, not with anyone else\u2019s.',
  ),

  // ---------------------------------------------------------------------
  // 9. Period Pain
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'period-pain',
    title: 'Period Pain',
    pageTitle: 'Period pain',
    subtitle: 'Cramps and how to ease them',
    icon: Icons.healing_rounded,
    accentColor: Color(0xFFFFB085),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: MenstrualTopicVisualType.painAnimation,
    whatIsIt:
        'Period pain, often called cramps, is a dull or sharp ache in the lower belly before or during a period. '
        'It is very common, and there are gentle ways to feel more comfortable.',
    whatHappensInBody: [
      'The uterus has muscles that gently contract to shed its lining.',
      'These contractions can cause pain or cramping.',
      'Some people feel cramps more strongly than others.',
      'Pain often settles after the first couple of days.',
    ],
    generallyNormal:
        'Many people feel some cramping around their period. How strong it feels varies from person to person '
        'and from cycle to cycle. Pain that follows your usual pattern and settles is often normal.',
    whatToNotice: [
      'Whether pain follows your usual pattern',
      'How strong the pain is and how long it lasts',
      'Pain that stops you from normal activities',
      'New kinds of pelvic pain, or pain outside your period',
      'Pain that keeps getting worse over several cycles',
    ],
    whatCanHelp: [
      'Heat — a warm pad or bottle on the lower belly',
      'Gentle movement, like walking or light stretching',
      'Rest and downtime',
      'Pain-relief medicines — always following the instructions and the advice of a healthcare professional',
    ],
    myths: [
      MenstrualMyth(
        myth: 'Period pain is normal, so you just have to endure it.',
        fact: 'Some pain is common, but you do not have to "just endure" severe pain. If pain is severe or affects your life, professional help can make a real difference.',
      ),
      MenstrualMyth(
        myth: 'Strong pain always means a serious condition.',
        fact: 'Not necessarily — but severe, worsening, or unusual pain deserves evaluation. A healthcare professional can help you understand what is going on.',
      ),
    ],
    whenToSeeDoctor:
        'Talk to a healthcare professional if pain is severe, keeps getting worse over cycles, '
        'does not respond to usual self-care, or happens outside your period. '
        'Sudden, severe pelvic pain should be evaluated promptly.',
    quickTakeaway: 'Cramps are common — but severe, worsening, or unusual pain deserves attention, not endurance.',
  ),

  // ---------------------------------------------------------------------
  // 10. When Should I Visit a Doctor?
  // ---------------------------------------------------------------------
  MenstrualHealthTopic(
    id: 'when-to-see-a-doctor',
    title: 'When Should I Visit a Doctor?',
    pageTitle: 'When should I see a doctor about my period?',
    subtitle: 'A calm, clear guide',
    icon: Icons.local_hospital_rounded,
    accentColor: Color(0xFF2E8B76),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: MenstrualTopicVisualType.trafficLight,
    visualData: {
      'levels': [
        {
          'level': 0,
          'name': 'Monitor & Track',
          'items': [
            'Keep tracking your cycle and symptoms as usual',
            'Occasional changes in flow or timing',
            'Usual cramps that settle within a couple of days',
            'Continue your normal routine and note any shifts',
          ],
        },
        {
          'level': 1,
          'name': 'Talk to a Doctor Soon',
          'items': [
            'Very heavy bleeding that is a change from your usual pattern',
            'Periods that stop for several months without explanation',
            'Severe pain that keeps getting worse or affects daily activities',
            'Repeated major changes in cycle length',
            'Persistent unusual bleeding between periods',
          ],
        },
        {
          'level': 2,
          'name': 'Seek Urgent Medical Care',
          'items': [
            'Suddenly very heavy bleeding with feeling faint, dizzy, or weak',
            'Sudden, severe pelvic or abdominal pain',
            'Bleeding while pregnant',
            'Any symptom that feels severe and came on suddenly',
          ],
        },
      ],
    },
    whatIsIt:
        'This guide helps you think about when to keep tracking, when to talk to a doctor, and when to seek urgent care. '
        'It is educational — it is not a diagnosis.',
    whatHappensInBody: [
      'Your period follows its own pattern most of the time.',
      'Sometimes your body sends signals — through changes in flow, pain, or timing.',
      'Most signals are harmless, and many changes are just variation.',
      'A few patterns are worth discussing, and rare ones need urgent care.',
    ],
    generallyNormal:
        'Cycles vary widely, and occasional changes are normal. '
        'What matters most is a change from your own pattern and how much it affects your daily life.',
    whatToNotice: [
      'Very heavy bleeding',
      'Severe or worsening pain',
      'Repeated major cycle changes',
      'Persistent unusual bleeding',
      'Prolonged absence of periods',
      'Symptoms that significantly affect normal daily activities',
    ],
    whatCanHelp: [
      'Track your cycle and symptoms carefully',
      'Note how patterns affect your daily life',
      'Bring your notes to conversations with professionals',
      'Trust your own experience — you are the expert on your body',
    ],
    myths: [
      MenstrualMyth(
        myth: 'If something is not on the urgent list, it is nothing.',
        fact: 'Not at all. "Monitor" and "talk to a doctor soon" are both normal, sensible steps. Many people discuss patterns that are not urgent.',
      ),
      MenstrualMyth(
        myth: 'You should only see a doctor at the last minute.',
        fact: 'You can see a professional for reassurance, questions, or persistent patterns — anytime that helps you feel sure.',
      ),
    ],
    whenToSeeDoctor:
        'Use the traffic-light guide below: monitor and track, talk to a doctor soon, or seek urgent medical care. '
        'Trust your judgment — if something feels very wrong, do not wait.',
    quickTakeaway: 'You know your body best — monitor your pattern, talk to a doctor about changes, and seek urgent care when it feels warranted.',
  ),
];