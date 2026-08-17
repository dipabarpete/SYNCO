import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/pink_corner/data/reproductive_health_topic.dart';
import 'package:hersync/features/pink_corner/data/reproductive_health_topics.dart';
import 'package:hersync/features/pink_corner/reproductive_health_screen.dart';
import 'package:hersync/features/pink_corner/reproductive_health_topic_screen.dart';

void main() {
  test('All 23 reproductive health topics exist with complete A-H structure',
      () {
    expect(allReproductiveHealthTopics.length, 23);

    expect(reproductiveHealthGroups.length, 5);
    expect(reproductiveHealthGroups[0].name, 'Know Your Body');
    expect(reproductiveHealthGroups[0].topics.length, 7);
    expect(reproductiveHealthGroups[1].name, 'Ovulation & Fertility');
    expect(reproductiveHealthGroups[1].topics.length, 5);
    expect(reproductiveHealthGroups[2].name, 'Sexual & Reproductive Health');
    expect(reproductiveHealthGroups[2].topics.length, 5);
    expect(reproductiveHealthGroups[3].name, 'Important Symptoms');
    expect(reproductiveHealthGroups[3].topics.length, 5);
    expect(reproductiveHealthGroups[4].name, 'When to See a Gynecologist');
    expect(reproductiveHealthGroups[4].topics.length, 1);

    for (final group in reproductiveHealthGroups) {
      expect(group.topics, isNotEmpty);
    }

    for (final topic in allReproductiveHealthTopics) {
      expect(topic.id, isNotEmpty);
      expect(topic.title, isNotEmpty);
      expect(topic.pageTitle, isNotEmpty);
      expect(topic.whatIsIt, isNotEmpty);
      expect(topic.whatHappensInBody.length, greaterThanOrEqualTo(3));
      expect(topic.generallyNormal, isNotEmpty);
      expect(topic.whatToNotice, isNotEmpty);
      expect(topic.whatCanHelp, isNotEmpty);
      expect(topic.whenToSeeDoctor, isNotEmpty);
      expect(topic.quickTakeaway, isNotEmpty);
    }
  });

  test('No topic claims a specific diagnosis', () {
    const claimPatterns = [
      'you have PCOS',
      'means PCOS',
      'you have PCOD',
      'means PCOD',
      'you have endometriosis',
      'means endometriosis',
      'you have fibroids',
      'means fibroids',
      'you have an STI',
      'means an STI',
      'you have chlamydia',
      'you have gonorrhea',
      'means cancer',
      'means pregnancy',
    ];

    for (final topic in allReproductiveHealthTopics) {
      final allText = [
        topic.whatIsIt,
        topic.generallyNormal,
        topic.whenToSeeDoctor,
        topic.quickTakeaway,
        ...topic.whatHappensInBody,
        ...topic.whatToNotice,
        ...topic.whatCanHelp,
        ...topic.myths.map((m) => '${m.myth} ${m.fact}'),
      ].join(' ').toLowerCase();

      for (final pattern in claimPatterns) {
        expect(
          allText.contains(pattern),
          isFalse,
          reason: 'Topic "${topic.id}" contains disallowed claim: $pattern',
        );
      }
    }
  });

  test('Every topic declares a valid visual type', () {
    for (final topic in allReproductiveHealthTopics) {
      expect(
        ReproductiveVisualType.values.contains(topic.visualType),
        isTrue,
        reason: 'Topic "${topic.id}" has an invalid visual type',
      );
    }
  });

  testWidgets('Reproductive Health list shows all 23 topic cards',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ReproductiveHealthScreen()),
    );
    await tester.pump();

    for (final topic in allReproductiveHealthTopics) {
      expect(find.text(topic.title), findsWidgets);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('Every topic detail screen renders all sections',
      (tester) async {
    for (final topic in allReproductiveHealthTopics) {
      await tester.pumpWidget(
        MaterialApp(home: ReproductiveHealthTopicScreen(topic: topic)),
      );
      await tester.pump();

      expect(find.text(topic.pageTitle), findsWidgets);
      expect(find.text('What is it?'), findsOneWidget);
      expect(find.text('What happens in the body?'), findsOneWidget);
      expect(find.text('What is generally normal?'), findsOneWidget);
      expect(find.text('What should I notice?'), findsOneWidget);
      expect(find.text('What can help?'), findsOneWidget);

      if (topic.visualType != ReproductiveVisualType.mythFactCards) {
        expect(find.text('Myth vs fact'), findsOneWidget,
            reason: 'Topic "${topic.id}" should render the myth section');
      }

      expect(find.text('When should I see a doctor?'), findsOneWidget);
      expect(find.text('Quick takeaway'), findsOneWidget);

      expect(tester.takeException(), isNull,
          reason: 'Layout overflow for topic "${topic.id}"');
    }
  });
}