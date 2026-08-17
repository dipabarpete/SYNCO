import 'menstrual_health_topic.dart';
import 'menstrual_health_topics_part1.dart';
import 'menstrual_health_topics_part2.dart';
import 'menstrual_health_topics_part3.dart';

/// All 10 Menstrual Health educational topics.
///
/// Content is written in easy, friendly, non-diagnostic language.
/// It explains normal variation separately from patterns that may
/// deserve medical evaluation, and never claims a symptom means a
/// specific condition.
final List<MenstrualHealthTopic> allMenstrualHealthTopics = [
  ...menstrualHealthTopicsPart1,
  ...menstrualHealthTopicsPart2,
  ...menstrualHealthTopicsPart3,
];