import 'package:flutter/material.dart';

/// Visual type used by the reusable topic-detail screen to pick which
/// educational visual to render for a topic.
enum MenstrualTopicVisualType {
  cycleWheel,
  flowScale,
  heavyBleedingComparison,
  spottingComparison,
  pmsPmddComparison,
  clotDiagram,
  colorTimeline,
  painAnimation,
  trafficLight,
}

/// A single myth / fact pair shown in the "Myth vs Fact" section.
class MenstrualMyth {
  final String myth;
  final String fact;

  const MenstrualMyth({required this.myth, required this.fact});
}

/// Structured educational content for one Menstrual Health topic.
///
/// Every topic follows the same A–I structure:
/// whatIsIt, whatHappensInBody, generallyNormal, whatToNotice, whatCanHelp,
/// myths, whenToSeeDoctor and quickTakeaway, plus a [visualType] with
/// optional [visualData] consumed by the matching visual widget.
class MenstrualHealthTopic {
  final String id;
  final String title;
  final String pageTitle;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  final String whatIsIt;
  final List<String> whatHappensInBody;
  final String generallyNormal;
  final List<String> whatToNotice;
  final List<String> whatCanHelp;
  final List<MenstrualMyth> myths;
  final String whenToSeeDoctor;
  final String quickTakeaway;

  final MenstrualTopicVisualType visualType;
  final Map<String, dynamic>? visualData;

  const MenstrualHealthTopic({
    required this.id,
    required this.title,
    required this.pageTitle,
    required this.subtitle,
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