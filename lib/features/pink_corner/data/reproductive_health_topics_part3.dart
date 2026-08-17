import 'package:flutter/material.dart';
import 'reproductive_health_topic.dart';

/// Group 3 — Sexual & Reproductive Health (topics 13–17).
const List<ReproductiveHealthTopic> reproductiveHealthTopicsPart3 = [
  // ---------------------------------------------------------------------
  // 13. Consent
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'consent',
    title: 'Consent',
    pageTitle: 'What does consent really mean?',
    subtitle: 'A clear, free, ongoing yes',
    category: 'Sexual & Reproductive Health',
    shortDescription: 'Consent is clear, freely given, can change anytime, and is needed every time.',
    icon: Icons.volunteer_activism_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: ReproductiveVisualType.consentGuide,
    visualData: {
      'points': [
        {
          'icon': 'thumb',
          'title': 'Clear',
          'desc': 'A real, enthusiastic yes — not silence or guessing.',
        },
        {
          'icon': 'hand',
          'title': 'Freely given',
          'desc': 'Given without pressure, obligation, or expectation.',
        },
        {
          'icon': 'change',
          'title': 'Can change anytime',
          'desc': 'Anyone can change their mind — at any moment.',
        },
        {
          'icon': 'repeat',
          'title': 'Needed every time',
          'desc': 'Every occasion and every partner needs fresh consent.',
        },
      ],
    },
    whatIsIt:
        'Consent means agreeing freely and clearly to sexual activity. It is not a one-time yes — it is '
        'an ongoing conversation.',
    whatHappensInBody: [
      'Consent should be clear — a real “yes”, not silence or guessing.',
      'It should be freely given — not pressured, expected, or assumed.',
      'Anyone can change their mind at any time, even mid-way.',
      'Consent is needed every time, with every partner.',
    ],
    generallyNormal:
        'Consent can be given in words, actions, or both — but it must be comfortable and enthusiastic. '
        'Hesitation or confusion is a signal to check in, not to continue.',
    whatToNotice: [
      'Whether you feel safe and able to say no at any moment',
      'Whether your partner seems equally comfortable',
      'Whether “yes” is enthusiastic — not reluctant or pressured',
    ],
    whatCanHelp: [
      'Check in with simple questions: “Are you okay with this?”',
      'Respect every “no” or “maybe” without argument',
      'Speaking up about boundaries is healthy, not awkward',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Marriage or a previous “yes” means consent forever.',
        fact: 'Consent is needed every single time — a past yes does not count as a present yes.',
      ),
      ReproductiveMyth(
        myth: 'Silence or not resisting means consent.',
        fact: 'Consent must be clear and freely given. Silence is not consent.',
      ),
    ],
    whenToSeeDoctor:
        'If you have experienced pressure, coercion, or assault, a professional can help — this is not '
        'your fault, and you deserve support.',
    quickTakeaway: 'A clear, free, enthusiastic yes — every time — is the only yes that counts.',
  ),

  // ---------------------------------------------------------------------
  // 14. Safe Sex
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'safe-sex',
    title: 'Safe Sex',
    pageTitle: 'What does safe sex mean?',
    subtitle: 'Small habits, meaningful protection',
    category: 'Sexual & Reproductive Health',
    shortDescription: 'Practical ways to reduce STI and unintended-pregnancy risk.',
    icon: Icons.shield_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: ReproductiveVisualType.safeSexIcons,
    visualData: {
      'items': [
        {
          'icon': 'shield',
          'title': 'Condoms',
          'desc': 'Reduce STI and pregnancy risk when used correctly.',
        },
        {
          'icon': 'test',
          'title': 'Regular testing',
          'desc': 'Know your status — and ask partners to know theirs.',
        },
        {
          'icon': 'chat',
          'title': 'Open conversations',
          'desc': 'Talk about protection before, not after.',
        },
        {
          'icon': 'consistent',
          'title': 'Consistency',
          'desc': 'Using protection every time makes it most effective.',
        },
      ],
    },
    whatIsIt:
        'Safe sex means practices that reduce the risk of STIs and unintended pregnancy. Small, consistent '
        'habits can make a big difference.',
    whatHappensInBody: [
      'Condoms reduce the risk of most STIs and of pregnancy when used correctly.',
      'Regular STI testing helps people know their status.',
      'Talking openly with partners about protection builds trust and lowers risk.',
      'Combining methods — like condoms with another form of contraception — adds extra protection.',
    ],
    generallyNormal:
        'There is no one “right” way to have sex. Choosing protection that fits you, your partner, and '
        'your situation is the healthy way.',
    whatToNotice: [
      'Whether protection is part of the conversation with new partners',
      'Keeping up with regular testing',
      'Which methods suit your routine — so they actually get used',
    ],
    whatCanHelp: [
      'Keep condoms nearby so protection is always an option',
      'Make testing part of normal, routine care',
      'Have short, honest conversations about protection before things start',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'The pull-out method is reliable protection.',
        fact: 'Withdrawal is not reliable for pregnancy or STI prevention. Condoms and other methods offer much stronger protection.',
      ),
    ],
    whenToSeeDoctor:
        'Testing is recommended for anyone who is sexually active with new partners. If you have any '
        'concern about exposure, testing early is the caring thing to do for yourself.',
    quickTakeaway: 'Protection is a habit, not an event — small consistent choices keep you and your partners safe.',
  ),

  // ---------------------------------------------------------------------
  // 15. STI Awareness
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'sti-awareness',
    title: 'STI Awareness',
    pageTitle: 'What should I know about STIs?',
    subtitle: 'Common, often silent, mostly treatable',
    category: 'Sexual & Reproductive Health',
    shortDescription: 'What STIs are, why some have no symptoms, and why testing matters.',
    icon: Icons.biotech_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: ReproductiveVisualType.testingAwareness,
    whatIsIt:
        'STIs (sexually transmitted infections) are infections passed mainly through sexual contact. Some '
        'show obvious signs — but many have no obvious symptoms at all.',
    whatHappensInBody: [
      'STIs spread through certain sexual activities.',
      'Some STIs can be present without any visible or felt symptoms.',
      'Untreated, some can affect long-term health — which is why testing matters.',
      'Most STIs are treatable, and many are curable.',
    ],
    generallyNormal:
        'Having an STI is not a moral judgment or a rare event — many people have one at some point. '
        'Testing and treatment are simply part of caring for yourself.',
    whatToNotice: [
      'Possible signs like unusual discharge, sores, burning, or itching',
      'The absence of signs does not mean the absence of an STI',
      'Any new or untested partner means testing is a good idea',
    ],
    whatCanHelp: [
      'Regular testing — confidential, quick, and usually simple',
      'Using condoms consistently',
      'Open conversations with partners about testing and status',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'If I have no symptoms, I don’t have an STI.',
        fact: 'Many STIs can be silent. Testing is the only reliable way to know.',
      ),
      ReproductiveMyth(
        myth: 'Only “certain kinds of people” get STIs.',
        fact: 'STIs can affect anyone who is sexually active. It is about exposure, not identity.',
      ),
    ],
    whenToSeeDoctor:
        'If you have new partners, notice any possible signs, or are concerned about exposure, testing is '
        'a healthy next step — early testing protects you and others.',
    quickTakeaway: 'STIs are common and mostly treatable — testing turns uncertainty into clarity.',
  ),

  // ---------------------------------------------------------------------
  // 16. Contraception Basics
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'contraception-basics',
    title: 'Contraception Basics',
    pageTitle: 'Contraception, simply explained',
    subtitle: 'Know the options, then choose',
    category: 'Sexual & Reproductive Health',
    shortDescription: 'Major contraception categories at a glance — informational, not prescriptive.',
    icon: Icons.medication_rounded,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF8F0FF),
    visualType: ReproductiveVisualType.methodComparison,
    visualData: {
      'items': [
        {
          'icon': 'shield',
          'title': 'Condoms',
          'desc': 'A barrier method you use each time. Also protects against STIs.',
        },
        {
          'icon': 'pill',
          'title': 'Hormonal methods',
          'desc': 'Pills, patches, rings, or injections that change hormonal patterns.',
        },
        {
          'icon': 'iud',
          'title': 'Intrauterine devices (IUDs)',
          'desc': 'Small devices placed in the uterus by a professional.',
        },
        {
          'icon': 'bolt',
          'title': 'Emergency contraception',
          'desc': 'A backup option after unprotected sex — not a routine method.',
        },
      ],
    },
    whatIsIt:
        'Contraception is the use of methods that reduce the chance of pregnancy. There are several major '
        'categories, and each one works differently.',
    whatHappensInBody: [
      'Condoms are barrier methods you use every time.',
      'Hormonal methods change hormonal patterns to reduce pregnancy risk.',
      'Intrauterine devices (IUDs) are small devices placed in the uterus by a professional.',
      'Emergency contraception is used after unprotected sex, as a backup — not as a regular method.',
    ],
    generallyNormal:
        'There is no “best” method for everyone. Effectiveness, side effects, and fit depend on your body, '
        'health history, and preferences.',
    whatToNotice: [
      'Your lifestyle and how regular you can be with a method',
      'What feels comfortable for you — all starting points are valid',
      'That only condoms also protect against STIs',
    ],
    whatCanHelp: [
      'Discussing options with a healthcare professional',
      'Asking how each method works and what fits your circumstances',
      'Planning a backup method for missed doses or slips',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Hormonal contraception makes you permanently infertile.',
        fact: 'Once stopped, fertility typically returns over time. Permanent effects are not the norm.',
      ),
      ReproductiveMyth(
        myth: 'Emergency contraception works as a regular method.',
        fact: 'Emergency contraception is a backup for emergencies, not a routine method — and it does not protect against STIs.',
      ),
    ],
    whenToSeeDoctor:
        'Before starting or switching methods, a consultation helps you choose safely. Emergency '
        'contraception should be used as soon as possible after unprotected sex.',
    quickTakeaway: 'Contraception is a choice, not one-size-fits-all — professionals help you find your fit.',
  ),

  // ---------------------------------------------------------------------
  // 17. When to Seek Medical Care
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'when-to-seek-care',
    title: 'When to Seek Medical Care',
    pageTitle: 'When should I seek care?',
    subtitle: 'You do not need a “serious” reason',
    category: 'Sexual & Reproductive Health',
    shortDescription: 'Check-ups, questions, and early conversations are all normal care.',
    icon: Icons.local_hospital_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: ReproductiveVisualType.medicalCareGuide,
    visualData: {
      'steps': [
        {
          'title': 'Start with routine care',
          'desc': 'Check-ups are normal care — not a response to a crisis.',
        },
        {
          'title': 'Notice changes',
          'desc': 'Track any new symptom or concern in a simple diary.',
        },
        {
          'title': 'Discuss with a professional',
          'desc': 'Book a consultation — care is confidential and non-judgmental.',
        },
      ],
    },
    whatIsIt:
        'Sexual and reproductive health care is normal care — check-ups, questions, and early conversations '
        'are all part of it. You do not need a “serious” reason to see a professional.',
    whatHappensInBody: [
      'Regular check-ups help catch things early.',
      'New partners, new symptoms, or new questions are all good reasons to visit.',
      'Care is confidential — professionals are trained to be non-judgmental.',
      'You can ask for a specific check or just general advice.',
    ],
    generallyNormal:
        'It is completely normal to feel nervous about appointments. Professionals are used to all kinds '
        'of questions, and nothing you say is unusual to them.',
    whatToNotice: [
      'Any new symptom, however small',
      'Any concern about exposure you have been sitting on',
      'Any question you have postponed for a while',
    ],
    whatCanHelp: [
      'Write your questions down before the visit',
      'Bring a friend for support if it helps',
      'Ask for more explanation any time — it is your right',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'I need to wait until symptoms are “serious” before seeing a professional.',
        fact: 'Early conversations are the most helpful kind. You do not need to wait for a crisis.',
      ),
    ],
    whenToSeeDoctor:
        'Right now, if you have been putting it off. Routine care, new concerns, or plain curiosity are '
        'all perfectly good reasons to book.',
    quickTakeaway: 'Your reproductive health deserves regular care — no “serious” reason needed.',
  ),
];
