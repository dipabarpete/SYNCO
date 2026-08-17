import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/pink_corner/data/menstrual_health_topics.dart';
import 'package:hersync/features/pink_corner/menstrual_health_screen.dart';
import 'package:hersync/features/pink_corner/menstrual_health_topic_detail_screen.dart';

void main() {
  test('All 10 menstrual health topics exist with complete A-I structure',
      () {
    expect(allMenstrualHealthTopics.length, 10);

    for (final topic in allMenstrualHealthTopics) {
      expect(topic.id, isNotEmpty);
      expect(topic.title, isNotEmpty);
      expect(topic.pageTitle, isNotEmpty);
      expect(topic.whatIsIt, isNotEmpty);
      expect(topic.whatHappensInBody.length, greaterThanOrEqualTo(3));
      expect(topic.generallyNormal, isNotEmpty);
      expect(topic.whatToNotice.length, greaterThanOrEqualTo(3));
      expect(topic.whatCanHelp, isNotEmpty);
      expect(topic.myths.length, greaterThanOrEqualTo(1));
      expect(topic.whenToSeeDoctor, isNotEmpty);
      expect(topic.quickTakeaway, isNotEmpty);
    }
  });

  test('No topic claims a specific diagnosis', () {
    const claimPatterns = [
      'you have PCOS',
      'means PCOS',
      'you have endometriosis',
      'means endometriosis',
      'you have fibroids',
      'means fibroids',
      'you have PMDD',
      'means PMDD',
    ];

    for (final topic in allMenstrualHealthTopics) {
      final allText = [
        topic.whatIsIt,
        topic.generallyNormal,
        topic.whenToSeeDoctor,
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

  testWidgets('Menstrual Health list shows all 10 topic cards',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MenstrualHealthScreen()),
    );

    for (final topic in allMenstrualHealthTopics) {
      expect(find.text(topic.title), findsWidgets);
    }
  });

  testWidgets('Every topic detail screen renders all sections',
      (tester) async {
    for (final topic in allMenstrualHealthTopics) {
      await tester.pumpWidget(
        MaterialApp(home: MenstrualHealthTopicDetailScreen(topic: topic)),
      );
      await tester.pump();

      expect(find.text(topic.pageTitle), findsWidgets);
      expect(find.text('What is it?'), findsOneWidget);
      expect(find.text('What happens in the body?'), findsOneWidget);
      expect(find.text('What is generally normal?'), findsOneWidget);
      expect(find.text('What should I notice?'), findsOneWidget);
      expect(find.text('What can help?'), findsOneWidget);
      expect(find.text('Myth vs Fact'), findsOneWidget);
      expect(find.text('When should I see a doctor?'), findsOneWidget);
      expect(find.text('Quick takeaway'), findsOneWidget);

      expect(tester.takeException(), isNull,
          reason: 'Layout overflow for topic "${topic.id}"');
    }
  });
}
