import 'package:flutter/material.dart';

/// Visual type used by the Reproductive Health topic-detail screen to pick
/// which educational visual to render for a topic.
enum ReproductiveVisualType {
  /// Labeled internal-anatomy diagram with one part highlighted.
  anatomyDiagram,

  /// Simple external-anatomy (vulva) diagram.
  vulvaDiagram,

  /// Animated cycle timeline with a moving phase indicator.
  hormoneCycleTimeline,

  /// Follicle growth + egg-release animation.
  eggReleaseAnimation,

  /// Static egg + sperm pathway illustration.
  eggSpermPathway,

  /// Cycle timeline with the fertile days softly highlighted.
  fertileWindowTimeline,

  /// Comparison of a usual cycle vs a PCOS / PCOD cycle.
  cycleComparison,

  /// Myth vs Fact cards.
  mythFactCards,

  /// Icon-based consent interaction.
  consentGuide,

  /// Safe-sex protective-method icon cards.
  safeSexIcons,

  /// STI testing / awareness comparison visual.
  testingAwareness,

  /// Contraception method comparison cards.
  methodComparison,

  /// Track → Notice → Discuss care pathway.
  medicalCareGuide,

  /// Natural variation vs worth-discussing comparison card.
  symptomComparison,

  /// Simple body-location illustration with the pelvis highlighted.
  bodyLocationMap,

  /// Non-graphic bleeding-pattern calendar cards.
  bleedingPatterns,

  /// What it can feel like / what can help two-card visual.
  careGuidance,

  /// Interactive symptom checklist.
  symptomChecklist,

  /// Green / yellow / red traffic-light guide.
  trafficLightGuide,
}

/// A single myth / fact pair shown in the "Myth vs Fact" section.
class ReproductiveMyth {
  final String myth;
  final String fact;

  const ReproductiveMyth({required this.myth, required this.fact});
}

/// Structured educational content for one Reproductive Health topic.
///
/// Every topic follows the same A–H structure: whatIsIt,
/// whatHappensInBody, generallyNormal, whatToNotice, whatCanHelp, myths,
/// whenToSeeDoctor and quickTakeaway, plus a [visualType] with optional
/// [visualData] consumed by the matching visual widget.
class ReproductiveHealthTopic {
  final String id;
  final String title;
  final String pageTitle;
  final String subtitle;
  final String category;
  final String shortDescription;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  final String whatIsIt;
  final List<String> whatHappensInBody;
  final String generallyNormal;
  final List<String> whatToNotice;
  final List<String> whatCanHelp;
  final List<ReproductiveMyth> myths;
  final String whenToSeeDoctor;
  final String quickTakeaway;

  final ReproductiveVisualType visualType;
  final Map<String, dynamic>? visualData;

  const ReproductiveHealthTopic({
    required this.id,
    required this.title,
    required this.pageTitle,
    required this.subtitle,
    required this.category,
    required this.shortDescription,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.whatIsIt,
    required this.whatHappensInBody,
    required this.generallyNormal,
    required this.whatToNotice,
    required this.whatCanHelp,
    required this.myths,
    required this.whenToSeeDoctor,
    required this.quickTakeaway,
    required this.visualType,
    this.visualData,
  });
}
