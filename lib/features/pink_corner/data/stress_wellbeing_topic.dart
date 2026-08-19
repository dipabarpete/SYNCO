import 'package:flutter/material.dart';

/// Visual type used by the reusable Stress & Well-being topic-detail screen
/// to pick which educational visual to render for a topic.
enum StressVisualType {
  /// Challenge → body/mind response → feelings/thoughts → recovery animation.
  stressResponse,

  /// Short-term (acute) vs ongoing (chronic) wave comparison.
  stressDurationComparison,

  /// Stress connected to sleep, mood and energy — tap to explore.
  connectedParts,

  /// Stress / well-being → tracking over time → notice menstrual patterns.
  cycleTracking,

  /// Racing-thought bubbles gently spaced by a slow-breathing circle.
  anxiousThoughts,

  /// Gentle, non-diagnostic three-step mood scale.
  moodScale,

  /// Comparison icons fading away while a self-care message grows.
  bodyImage,

  /// Small positive actions stacking into a stable foundation.
  selfEsteemBlocks,

  /// Feeling → pause → "what do I need?" support wheel.
  emotionalEatingWheel,

  /// Understand → Track → Adjust → Ask for help → Continue journey timeline.
  healthJourney,

  /// Calm green / yellow / red guide for seeking professional help.
  seekHelpTrafficLight,
}

/// A single myth / fact pair shown in the "Myth vs Fact" section.
class StressMyth {
  final String myth;
  final String fact;

  const StressMyth({required this.myth, required this.fact});
}

/// Structured educational content for one Stress & Well-being topic.
///
/// Every topic follows the same structure: whatIsIt, bodyMindProcess,
/// commonExperiences, practicalTips, myths, whenToSeekHelp and
/// quickTakeaway, plus a [visualType] with optional [visualData] consumed by
/// the matching visual widget.
class StressWellbeingTopic {
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
  final List<String> bodyMindProcess;
  final List<String> commonExperiences;
  final List<String> practicalTips;
  final List<StressMyth> myths;
  final String whenToSeekHelp;
  final String quickTakeaway;

  final StressVisualType visualType;
  final Map<String, dynamic>? visualData;

  const StressWellbeingTopic({
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
    required this.bodyMindProcess,
    required this.commonExperiences,
    required this.practicalTips,
    required this.myths,
    required this.whenToSeekHelp,
    required this.quickTakeaway,
    required this.visualType,
    this.visualData,
  });
}