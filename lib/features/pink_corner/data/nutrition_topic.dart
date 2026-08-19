import 'package:flutter/material.dart';

/// Visual type used by the Nutrition topic-detail screen to pick which
/// educational visual to render for a topic.
enum NutritionVisualType {
  plateProtein,
  carbComparison,
  fatWheel,
  fibreWheel,
  nutrientGrid,
  waterBottle,
  plateBuilder,
  pairingComparison,
  grainTimeline,
  vegPlate,
  fruitBowl,
  healthyFatWheel,
  adjustablePlate,
  noSingleDiet,
  buildBreakfast,
  lunchPlate,
  budgetProteinCards,
  cravingCards,
  snackComparison,
}

/// A single myth / fact pair shown in the "Myth vs Fact" section.
class NutritionMyth {
  final String myth;
  final String fact;

  const NutritionMyth({required this.myth, required this.fact});
}

/// Structured educational content for one Nutrition topic.
///
/// Every topic follows the same A–G structure: whatIsIt, whyItMatters,
/// whatCanYouChoose, whatToNotice, howToMakeItBalanced, mythFact and
/// quickTakeaway, plus a [visualType] with optional [visualData] consumed by
/// the matching visual widget.
class NutritionTopic {
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
  final List<String> whyItMatters;
  final List<String> whatCanYouChoose;
  final List<String> whatToNotice;
  final List<String> howToMakeItBalanced;
  final List<NutritionMyth> mythFact;
  final String quickTakeaway;

  final NutritionVisualType visualType;
  final Map<String, dynamic>? visualData;

  const NutritionTopic({
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
    required this.whatCanYouChoose,
    required this.whatToNotice,
    required this.howToMakeItBalanced,
    required this.mythFact,
    required this.quickTakeaway,
    required this.visualType,
    this.visualData,
  });
}

/// A simple, practical recipe shown inside the Nutrition section.
///
/// [categories] holds every category the recipe belongs to, with the primary
/// category first (Breakfast, Lunch, Dinner, Snacks, Drinks,
/// Period-friendly, High-Protein, High-Fibre, Budget-Friendly, 10-Minute).
class NutritionRecipe {
  final String id;
  final String name;
  final List<String> categories;
  final String prepTime;
  final String difficulty;
  final IconData icon;
  final List<String> ingredients;
  final List<String> steps;
  final String? nutritionNote;

  const NutritionRecipe({
    required this.id,
    required this.name,
    required this.categories,
    required this.prepTime,
    required this.difficulty,
    required this.icon,
    required this.ingredients,
    required this.steps,
    this.nutritionNote,
  });
}

/// Categories used for recipe filtering, in display order.
const List<String> nutritionRecipeCategories = [
  'All',
  'Breakfast',
  'Lunch',
  'Dinner',
  'Snacks',
  'Drinks',
  'Period-friendly',
  'High-Protein',
  'High-Fibre',
  'Budget-Friendly',
  '10-Minute',
];