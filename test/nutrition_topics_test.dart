import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/pink_corner/data/nutrition_recipes.dart';
import 'package:hersync/features/pink_corner/data/nutrition_topic.dart';
import 'package:hersync/features/pink_corner/data/nutrition_topics.dart';
import 'package:hersync/features/pink_corner/nutrition_screen.dart';
import 'package:hersync/features/pink_corner/nutrition_topic_detail_screen.dart';
import 'package:hersync/features/pink_corner/nutrition_recipe_screen.dart';

String _topicText(NutritionTopic topic) => [
      topic.title,
      topic.pageTitle,
      topic.subtitle,
      topic.shortDescription,
      topic.whatIsIt,
      topic.quickTakeaway,
      ...topic.whyItMatters,
      ...topic.whatCanYouChoose,
      ...topic.whatToNotice,
      ...topic.howToMakeItBalanced,
      ...topic.mythFact.map((m) => '${m.myth} ${m.fact}'),
    ].join(' ').toLowerCase();

void main() {
  test('All nutrition topics exist with complete A-G structure', () {
    expect(allNutritionTopics.length, 19);

    for (final topic in allNutritionTopics) {
      expect(topic.id, isNotEmpty);
      expect(topic.title, isNotEmpty);
      expect(topic.pageTitle, isNotEmpty);
      expect(topic.category, isNotEmpty);
      expect(topic.shortDescription, isNotEmpty);
      expect(topic.whatIsIt, isNotEmpty);
      expect(topic.whyItMatters.length, greaterThanOrEqualTo(2));
      expect(topic.whatCanYouChoose.length, greaterThanOrEqualTo(1));
      expect(topic.whatToNotice.length, greaterThanOrEqualTo(3));
      expect(topic.howToMakeItBalanced.length, greaterThanOrEqualTo(1));
      expect(topic.mythFact.length, greaterThanOrEqualTo(1));
      expect(topic.quickTakeaway, isNotEmpty);
      expect(topic.visualType, isNotNull);
    }
  });

  test('Grouped topics preserve the reading order', () {
    for (final group in nutritionGroups) {
      expect(group.name, isNotEmpty);
      expect(group.topics, isNotEmpty);
      for (final topic in group.topics) {
        expect(topic.category, group.name);
      }
    }

    final flat = nutritionGroups
        .expand((group) => group.topics)
        .map((t) => t.id)
        .toList();
    expect(flat, allNutritionTopics.map((t) => t.id).toList());
  });

  test('No topic claims a cure, a universal diet, or a guaranteed response',
      () {
    const disallowedPatterns = [
      'cures pcos',
      'cure for pcos',
      'cure pcos',
      'cures polycystic',
      'guarantees lower blood sugar',
      'guaranteed blood-sugar',
      'balances your hormones automatically',
      'works for everyone with pcos',
      'works for every person',
      'one diet for everyone',
      'treats pcos',
      'treats menstrual disorders',
      'treats pms',
    ];

    for (final topic in allNutritionTopics) {
      final text = _topicText(topic);
      for (final pattern in disallowedPatterns) {
        expect(
          text.contains(pattern),
          isFalse,
          reason: 'Topic "${topic.id}" contains disallowed claim: $pattern',
        );
      }
    }
  });

  test('No topic uses fear-based or restrictive messaging', () {
    const fearPatterns = [
      'never eat',
      'must avoid',
      'banned',
      'forbidden',
      'bad food',
      'kill your cravings',
      'fat making',
    ];

    for (final topic in allNutritionTopics) {
      final text = _topicText(topic);
      for (final pattern in fearPatterns) {
        expect(
          text.contains(pattern),
          isFalse,
          reason: 'Topic "${topic.id}" contains fear/restriction phrase: '
              '$pattern',
        );
      }
    }
  });

  test('There is no single universal PCOS diet is clearly communicated', () {
    final positioning = allNutritionTopics
        .firstWhere((t) => t.id == 'no-single-pcos-diet');
    final text = _topicText(positioning);

    expect(text.contains('there is no one meal plan'), isTrue);
    expect(text.contains('no single diet'), isTrue);
    expect(text.contains('fits your life'), isTrue);
  });

  test('Recipe categories cover every required category and data is complete',
      () {
    expect(nutritionRecipes.length, greaterThanOrEqualTo(10));

    const requiredCategories = [
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

    final covered = <String>{};
    for (final recipe in nutritionRecipes) {
      expect(recipe.id, isNotEmpty);
      expect(recipe.name, isNotEmpty);
      expect(recipe.categories, isNotEmpty);
      expect(recipe.prepTime, isNotEmpty);
      expect(recipe.difficulty, isNotEmpty);
      expect(recipe.ingredients.length, greaterThanOrEqualTo(3));
      expect(recipe.steps.length, greaterThanOrEqualTo(3));
      covered.addAll(recipe.categories);
    }

    for (final category in requiredCategories) {
      expect(
        covered.contains(category),
        isTrue,
        reason: 'No recipe covers category: $category',
      );
    }
  });

  test('Period-friendly recipes avoid medical treatment claims', () {
    final periodFriendly = nutritionRecipes
        .where((r) => r.categories.contains('Period-friendly'));
    expect(periodFriendly, isNotEmpty);

    for (final recipe in periodFriendly) {
      final text =
          '${recipe.name} ${recipe.nutritionNote ?? ''} ${recipe.steps.join(' ')}'
              .toLowerCase();
      final claims = ['treats', 'cures', 'reduces cramps', 'stops pain'];
      for (final claim in claims) {
        expect(
          text.contains(claim),
          isFalse,
          reason: 'Period-friendly recipe "${recipe.id}" makes a treatment '
              'claim: $claim',
        );
      }
    }
  });

  testWidgets('Nutrition list shows all 19 topic cards', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NutritionScreen()));

    for (final topic in allNutritionTopics) {
      expect(find.text(topic.title), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Every topic detail screen renders all sections',
      (tester) async {
    for (final topic in allNutritionTopics) {
      await tester.pumpWidget(
        MaterialApp(home: NutritionTopicDetailScreen(topic: topic)),
      );
      await tester.pump();

      expect(find.text(topic.pageTitle), findsWidgets);
      expect(find.text('What is it?'), findsOneWidget);
      expect(find.text('Why does it matter?'), findsOneWidget);
      expect(find.text('What can I choose?'), findsOneWidget);
      expect(find.text('What should I notice?'), findsOneWidget);
      expect(find.text('How can I make it more balanced?'), findsOneWidget);
      expect(find.text('Myth vs Fact'), findsOneWidget);
      expect(find.text('Quick takeaway'), findsOneWidget);

      expect(tester.takeException(), isNull,
          reason: 'Layout overflow for topic "${topic.id}"');
    }
  });

  testWidgets('Every recipe detail screen renders without overflow',
      (tester) async {
    for (final recipe in nutritionRecipes) {
      await tester.pumpWidget(
        MaterialApp(home: NutritionRecipeScreen(recipe: recipe)),
      );
      await tester.pump();

      expect(find.text(recipe.name), findsWidgets);
      expect(find.text('What you need'), findsOneWidget);
      expect(find.text('How to make it'), findsOneWidget);

      expect(tester.takeException(), isNull,
          reason: 'Layout overflow for recipe "${recipe.id}"');
    }
  });
}