import 'package:flutter/material.dart';
import 'reproductive_health_topic.dart';

/// Group 1 — Know Your Body (topics 1–7).
const List<ReproductiveHealthTopic> reproductiveHealthTopicsPart1 = [
  // ---------------------------------------------------------------------
  // 1. Uterus
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'uterus',
    title: 'Uterus',
    pageTitle: 'What is the uterus?',
    subtitle: 'The muscle behind your period',
    category: 'Know Your Body',
    shortDescription: 'What it does, why its lining changes, and what its cycle means for you.',
    icon: Icons.favorite_rounded,
    accentColor: Color(0xFFC94A6E),
    backgroundColor: Color(0xFFFFF0F3),
    visualType: ReproductiveVisualType.anatomyDiagram,
    visualData: {'highlight': 'uterus'},
    whatIsIt:
        'The uterus is a muscular organ in your lower belly, shaped a little like an upside-down pear. '
        'It is where a pregnancy can develop, and its inner lining changes throughout your menstrual cycle.',
    whatHappensInBody: [
      'Each cycle, the inner lining of the uterus thickens to prepare for a possible pregnancy.',
      'If pregnancy does not happen, the lining is shed — this is your period.',
      'If pregnancy does happen, the uterus stretches and grows with the baby.',
      'Its position and tilt vary slightly from person to person, which is normal.',
    ],
    generallyNormal:
        'Uteruses come in many normal shapes, sizes, and tilts. A tilted uterus, for example, is common '
        'and usually has no effect on health or pregnancy.',
    whatToNotice: [
      'Changes in your usual period pattern',
      'Persistent pain or pressure in the lower belly',
      'Very heavy or very painful periods that affect daily life',
      'Any new or unusual discomfort that does not go away',
    ],
    whatCanHelp: [
      'Track your cycle so changes are easy to spot',
      'Gentle movement and heat can ease period discomfort',
      'Ask questions about anything new at regular check-ups',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'The uterus only matters if you want children.',
        fact: 'The uterus is part of your everyday health — its cycle affects periods, hormones, and how your body feels.',
      ),
      ReproductiveMyth(
        myth: 'A tilted uterus means something is wrong.',
        fact: 'A tilted uterus is common and usually has no effect on health or fertility.',
      ),
    ],
    whenToSeeDoctor:
        'Talk to a healthcare professional if you notice persistent pelvic pain, very heavy or very painful '
        'periods, or any change from your usual pattern that concerns you. These are patterns worth checking — not reasons to panic.',
    quickTakeaway: 'Your uterus has a rhythm of its own — learning it is one of the best ways to know your body.',
  ),

  // ---------------------------------------------------------------------
  // 2. Ovaries
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'ovaries',
    title: 'Ovaries',
    pageTitle: 'What do the ovaries do?',
    subtitle: 'Where eggs and key hormones come from',
    category: 'Know Your Body',
    shortDescription: 'How the ovaries store eggs, release hormones, and guide your cycle.',
    icon: Icons.bubble_chart_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: ReproductiveVisualType.anatomyDiagram,
    visualData: {'highlight': 'ovaries'},
    whatIsIt:
        'The ovaries are two small organs, one on each side of the uterus. They store eggs and produce '
        'hormones — mainly estrogen and progesterone — that help guide your cycle.',
    whatHappensInBody: [
      'Each cycle, a small number of eggs begin to mature.',
      'Usually one egg matures fully and is released — this is ovulation.',
      'The ovaries also produce hormones that help regulate periods and many other body processes.',
      'Hormone levels rise and fall naturally across the cycle.',
    ],
    generallyNormal:
        'Ovaries vary in size through the cycle and at different ages. Small natural changes from month '
        'to month are common.',
    whatToNotice: [
      'Large changes in your usual cycle length or period pattern',
      'Persistent one-sided pelvic pain that does not pass',
      'Hormone-related changes like new acne or hair changes',
      'Any symptom that is new and ongoing for you',
    ],
    whatCanHelp: [
      'Track your cycle length and any symptoms',
      'Eat regularly and rest enough — hormones respond to overall care',
      'Bring a short symptom log to appointments',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Missing one ovulation means your ovaries are failing.',
        fact: 'It is normal to have an occasional cycle without ovulation. Patterns matter more than single events.',
      ),
      ReproductiveMyth(
        myth: 'Ovaries "shut down" at a fixed age for everyone.',
        fact: 'Hormone changes happen gradually across life, and timelines differ. A healthcare professional is the best guide for your own body.',
      ),
    ],
    whenToSeeDoctor:
        'Seek evaluation for persistent pelvic pain, repeated very painful cycles, or major changes in your '
        'cycle pattern. A healthcare professional can help find the cause.',
    quickTakeaway: 'Your ovaries quietly run the rhythm of your cycle — and small variations are part of normal life.',
  ),

  // ---------------------------------------------------------------------
  // 3. Fallopian Tubes
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'fallopian-tubes',
    title: 'Fallopian Tubes',
    pageTitle: 'What are the fallopian tubes?',
    subtitle: 'The quiet bridge between ovary and uterus',
    category: 'Know Your Body',
    shortDescription: 'How an egg travels after ovulation — and where sperm usually meets it.',
    icon: Icons.timeline_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    visualType: ReproductiveVisualType.anatomyDiagram,
    visualData: {'highlight': 'tubes'},
    whatIsIt:
        'The fallopian tubes are two thin tubes that connect each ovary to the uterus. After ovulation, '
        'an egg travels through a tube toward the uterus — and this is usually where sperm meets the egg.',
    whatHappensInBody: [
      'An egg is released from the ovary and enters the tube.',
      'Tiny movements in the tube help the egg travel toward the uterus.',
      'If sperm is present, fertilisation usually happens inside the tube.',
      'A fertilised egg then continues its journey to the uterus.',
    ],
    generallyNormal:
        'Tubes come in many shapes and positions. You cannot feel them — they work quietly in the background '
        'throughout your cycle.',
    whatToNotice: [
      'There are usually no symptoms linked to the tubes themselves',
      'Persistent pelvic pain or pain with periods is worth mentioning',
      'Discomfort that feels new or different from your usual pattern',
    ],
    whatCanHelp: [
      'Routine gynecological check-ups are how tube health is looked at',
      'There is nothing to track on your own beyond your usual cycle notes',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'You can feel your fallopian tubes working.',
        fact: 'The tubes work quietly — they are not something you can sense day to day.',
      ),
      ReproductiveMyth(
        myth: 'If a tube is blocked, pregnancy is impossible.',
        fact: 'Tubal concerns are something healthcare professionals can evaluate, and many options exist to discuss with them.',
      ),
    ],
    whenToSeeDoctor:
        'Persistent pelvic pain, pain during sex, or difficulty conceiving after trying for some time are '
        'all good reasons to talk to a healthcare professional.',
    quickTakeaway: 'Your fallopian tubes are the quiet bridge between ovary and uterus.',
  ),

  // ---------------------------------------------------------------------
  // 4. Cervix
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'cervix',
    title: 'Cervix',
    pageTitle: 'What is the cervix?',
    subtitle: 'The gentle gateway of your uterus',
    category: 'Know Your Body',
    shortDescription: 'Its role, why its mucus changes, and the signals worth knowing.',
    icon: Icons.radio_button_checked_rounded,
    accentColor: Color(0xFFFFB085),
    backgroundColor: Color(0xFFFFF7ED),
    visualType: ReproductiveVisualType.anatomyDiagram,
    visualData: {'highlight': 'cervix'},
    whatIsIt:
        'The cervix is the lower, narrow part of the uterus that opens into the vagina. It has a small '
        'opening, and its mucus changes across the cycle — which is why some people notice changes near ovulation.',
    whatHappensInBody: [
      'The cervix produces mucus that changes in amount and texture through the cycle.',
      'Around ovulation, mucus often becomes clear, slippery, and stretchy.',
      'After ovulation, mucus usually becomes thicker and creamier.',
      'For most of life, the cervix simply protects the uterus — its opening is small.',
    ],
    generallyNormal:
        'Cervical mucus changes are a normal part of the cycle, and no two people are identical. These '
        'changes are useful signals, not something to judge yourself by.',
    whatToNotice: [
      'Unusual discharge with pain, itching, a strong odour, or sores',
      'Bleeding after intercourse — worth mentioning',
      'Discomfort that feels new or different',
    ],
    whatCanHelp: [
      'Regular check-ups and screening visits keep the cervix healthy',
      'Noting mucus changes can help you understand your cycle, if you want to track it',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Cervical mucus that changes means something is wrong.',
        fact: 'Changes in mucus across the cycle are a normal hormonal signal, not a sign of illness.',
      ),
    ],
    whenToSeeDoctor:
        'Mention any new or persistent unusual discharge, bleeding after sex, or pelvic discomfort at your '
        'next consultation — sooner if it comes with pain.',
    quickTakeaway: 'The cervix is the gentle gateway of your uterus — its mucus gives quiet clues about your cycle.',
  ),

  // ---------------------------------------------------------------------
  // 5. Vagina
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'vagina',
    title: 'Vagina',
    pageTitle: 'What is the vagina?',
    subtitle: 'A self-cleaning, resilient passage',
    category: 'Know Your Body',
    shortDescription: 'Why discharge is normal, and when a change is worth discussing.',
    icon: Icons.view_agenda_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFF0FDF4),
    visualType: ReproductiveVisualType.anatomyDiagram,
    visualData: {'highlight': 'vagina'},
    whatIsIt:
        'The vagina is a flexible muscular passage that connects the cervix to the outside of the body. '
        'It is self-cleaning — discharge is its natural way of staying clean and healthy.',
    whatHappensInBody: [
      'Discharge changes with hormones, cycle phase, and other natural factors.',
      'The vagina cleans itself with healthy discharge and natural bacteria.',
      'Its tissue is flexible and generally very resilient.',
      'Moisture and pH change naturally across the cycle and with age.',
    ],
    generallyNormal:
        'Vaginal discharge varies in amount, colour, and texture from person to person and from day to day. '
        'Clear to white, odourless or mild-smelling discharge is common.',
    whatToNotice: [
      'Persistent change in discharge with pain, itching, a strong odour, or sores',
      'Burning or irritation that does not settle',
      'Bleeding after intercourse',
      'Any new discomfort in the area',
    ],
    whatCanHelp: [
      'Wash gently with water only — avoid strong soaps and douches',
      'Cotton underwear and comfortable clothing can help',
      'Trust your body’s natural self-cleaning',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'The vagina needs regular internal cleaning.',
        fact: 'The vagina cleans itself. Douching can remove healthy bacteria and cause irritation.',
      ),
      ReproductiveMyth(
        myth: 'Every change in discharge means an infection.',
        fact: 'Discharge naturally varies through the cycle. Persistent changes with other symptoms are worth discussing.',
      ),
    ],
    whenToSeeDoctor:
        'Persistent unusual discharge, itching, odour, sores, or pain in the area can have several possible '
        'causes — a healthcare professional can help determine the cause.',
    quickTakeaway: 'Your vagina is self-cleaning and resilient — gentle care is all it needs.',
  ),

  // ---------------------------------------------------------------------
  // 6. Vulva
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'vulva',
    title: 'Vulva',
    pageTitle: 'What is the vulva?',
    subtitle: 'Your external anatomy — unique, like everything else',
    category: 'Know Your Body',
    shortDescription: 'The labia, clitoris, and openings — and why every vulva is different.',
    icon: Icons.panorama_fish_eye_rounded,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF8F0FF),
    visualType: ReproductiveVisualType.vulvaDiagram,
    whatIsIt:
        'The vulva is the name for the external parts of your genital area — the outer and inner lips '
        '(labia), the clitoris, and the openings to the urethra and vagina.',
    whatHappensInBody: [
      'The labia protect the inner openings.',
      'The clitoris is a sensitive area involved in sexual sensation.',
      'The skin here is sensitive and responds to hormones, products, and friction.',
      'Appearance naturally varies from person to person.',
    ],
    generallyNormal:
        'Vulvas come in every size, shape, and shade — there is no single “normal” look. Differences '
        'between the left and right side are also common.',
    whatToNotice: [
      'Itching, burning, or soreness that persists',
      'New sores, bumps, or changes that do not heal',
      'Pain with touch or during intercourse',
      'Skin changes or unusual discharge alongside',
    ],
    whatCanHelp: [
      'Wash with warm water; avoid harsh soaps and tight synthetic underwear',
      'Give sensitive skin a break — gentle, fragrance-free products help',
      'Avoid comparing yourself to images; they are not a measure of health',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'A vulva should look a particular way.',
        fact: 'Vulvas vary widely and naturally. How it looks says very little about health.',
      ),
    ],
    whenToSeeDoctor:
        'Persistent itching, pain, sores, or changes that do not settle can have several possible causes — '
        'a healthcare professional can help.',
    quickTakeaway: 'Your vulva is unique, like every other part of you — gentle care beats harsh products.',
  ),

  // ---------------------------------------------------------------------
  // 7. Hormonal Cycle
  // ---------------------------------------------------------------------
  ReproductiveHealthTopic(
    id: 'hormonal-cycle',
    title: 'Hormonal Cycle',
    pageTitle: 'What is the hormonal cycle?',
    subtitle: 'A full-month rhythm, not just a period',
    category: 'Know Your Body',
    shortDescription: 'The four phases of your cycle and how hormones move through them.',
    icon: Icons.sync_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    visualType: ReproductiveVisualType.hormoneCycleTimeline,
    visualData: {
      'phases': [
        {
          'label': 'Menstrual',
          'start': 1,
          'end': 5,
          'color': 0xFFC94A6E,
          'note': 'The lining is shed — your period',
        },
        {
          'label': 'Follicular',
          'start': 6,
          'end': 13,
          'color': 0xFF9D76C1,
          'note': 'An egg matures, estrogen rises',
        },
        {
          'label': 'Ovulation',
          'start': 14,
          'end': 16,
          'color': 0xFF7B4397,
          'note': 'A mature egg is released',
        },
        {
          'label': 'Luteal',
          'start': 17,
          'end': 28,
          'color': 0xFFFFB085,
          'note': 'The lining thickens, progesterone rises',
        },
      ],
    },
    whatIsIt:
        'Your hormonal cycle is the monthly rhythm in which hormones rise and fall, preparing the body '
        'for a possible pregnancy. Your period is just one visible part of it.',
    whatHappensInBody: [
      'Menstrual phase — the uterine lining is shed (your period).',
      'Follicular phase — an egg matures and estrogen rises.',
      'Ovulation — a mature egg is released.',
      'Luteal phase — the lining thickens; if no pregnancy, the cycle begins again.',
    ],
    generallyNormal:
        'Hormones do not move in perfect straight lines. Cycles vary in length, and emotions and energy '
        'can vary with them — all of this is common.',
    whatToNotice: [
      'Your usual cycle length and how it changes',
      'Patterns in mood, energy, or symptoms across phases',
      'Major shifts that persist over several cycles',
    ],
    whatCanHelp: [
      'Cycle tracking helps you learn your own rhythm',
      'Consistent sleep and regular meals support your body’s rhythm',
      'Knowing your phases helps you understand how you feel',
    ],
    myths: [
      ReproductiveMyth(
        myth: 'Hormones only matter during your period.',
        fact: 'Hormones rise and fall across the whole cycle and influence mood, energy, skin, and more.',
      ),
    ],
    whenToSeeDoctor:
        'If cycles become very irregular, stop, or change a lot along with other symptoms, a healthcare '
        'professional can help you understand why.',
    quickTakeaway: 'Hormones run a full-month rhythm — your period is just the visible finale.',
  ),
];
