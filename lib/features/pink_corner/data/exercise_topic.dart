import 'package:flutter/material.dart';

/// Visual type used by the reusable Exercise topic-detail screen to pick
/// which educational visual to render for a topic.
enum ExerciseVisualType {
  /// Movement benefit wheel with a rotating highlight around the center.
  benefitsWheel,

  /// Beginner performing a slow, controlled squat with movement arrows.
  squatSequence,

  /// A character walking along a short path while wellness icons appear.
  walkingPath,

  /// Gentle → Moderate → More challenging intensity scale.
  cardioIntensity,

  /// Body diagram highlighting joints with gentle movement arcs.
  jointMovement,

  /// Calm transition between two beginner-friendly yoga poses.
  yogaPoses,

  /// Controlled Pilates movement sequence.
  pilatesSequence,

  /// Interactive menstrual-cycle wheel with flexible movement suggestions.
  cycleWheel,

  /// Movement + PCOS/PCOD benefit map.
  pcosBenefitMap,
}

/// A single myth / fact pair shown in the "Myth vs Fact" section.
class ExerciseMyth {
  final String myth;
  final String fact;

  const ExerciseMyth({required this.myth, required this.fact});
}

/// Structured educational content for one Exercise & Movement topic.
///
/// Every topic follows the same structure: whatIsIt, whyItMatters,
/// whatItCanLookLike, howToStart, whatToNotice, myths, whenToSeekHelp and
/// quickTakeaway, plus a [visualType] with optional [visualData] consumed by
/// the matching visual widget.
class ExerciseTopic {
  final String id;
  final String title;
  final String pageTitle;
  final String subtitle;
  final String category;
  final String shortDescription;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  /// A. What is it? — 2–3 simple sentences.
  final String whatIsIt;

  /// B. Why does it matter? — short, encouraging points.
  final List<String> whyItMatters;

  /// C. What can it look like? — practical, everyday examples.
  final List<String> whatItCanLookLike;

  /// D. How can I start? — beginner-friendly guidance.
  final List<String> howToStart;

  /// E. What should I notice? — comfort, energy, soreness signals.
  final List<String> whatToNotice;

  /// F. Myth vs Fact — 1–2 misconceptions.
  final List<ExerciseMyth> myths;

  /// G. When should I get professional guidance?
  final String whenToSeekHelp;

  /// H. Quick takeaway — one memorable sentence.
  final String quickTakeaway;

  final ExerciseVisualType visualType;
  final Map<String, dynamic>? visualData;

  const ExerciseTopic({
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
    required this.whyItMatters,
    required this.whatItCanLookLike,
    required this.howToStart,
    required this.whatToNotice,
    required this.myths,
    required this.whenToSeekHelp,
    required this.quickTakeaway,
    required this.visualType,
    this.visualData,
  });
}