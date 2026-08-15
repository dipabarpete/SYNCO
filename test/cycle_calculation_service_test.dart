import 'package:flutter_test/flutter_test.dart';

import 'package:hersync/features/cycle/services/cycle_calculation_service.dart';
import 'package:hersync/models/cycle_data.dart';
import 'package:hersync/models/period_day_log.dart';
import 'package:hersync/models/period_record.dart';

void main() {
  final service = CycleCalculationService();

  PeriodRecord period({
    required String id,
    required DateTime start,
    DateTime? end,
    String? flow,
    List<String> moods = const [],
    List<String> symptoms = const [],
    String? discharge,
    List<String> digestion = const [],
    List<String> otherFactors = const [],
    Map<String, PeriodDayLog> dailyLogs = const {},
  }) {
    return PeriodRecord(
      id: id,
      userId: 'user-1',
      startDate: start,
      endDate: end,
      flowLevel: flow,
      moods: moods,
      symptoms: symptoms,
      discharge: discharge,
      digestion: digestion,
      otherFactors: otherFactors,
      dailyLogs: dailyLogs,
    );
  }

  group('CycleCalculationService', () {
    test('returns hasHistory=false for empty history', () {
      final insights = service.computeInsights(const [], today: DateTime(2026, 8, 16));
      expect(insights.hasHistory, isFalse);
      expect(insights.periodDays, isEmpty);
      expect(insights.ovulationDay, isNull);
    });

    test('average cycle length from consecutive start dates', () {
      final records = [
        period(id: '1', start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 5)),
        period(id: '2', start: DateTime(2026, 6, 29), end: DateTime(2026, 7, 3)),
        period(id: '3', start: DateTime(2026, 7, 27), end: DateTime(2026, 7, 31)),
      ];
      final insights = service.computeInsights(records, today: DateTime(2026, 8, 16));
      expect(insights.hasHistory, isTrue);
      expect(insights.averageCycleLength, 28);
      expect(insights.averagePeriodDuration, 5);
    });

    test('next period, ovulation and fertile window are computed', () {
      final records = [
        period(id: '1', start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 5)),
        period(id: '2', start: DateTime(2026, 6, 29), end: DateTime(2026, 7, 3)),
      ];
      final insights = service.computeInsights(records, today: DateTime(2026, 7, 4));
      expect(insights.averageCycleLength, 28);
      // Current cycle started 29 Jun; ovulation ~ 13 Jul (28 - 14 after start).
      expect(insights.estimatedOvulation, DateTime(2026, 7, 13));
      expect(insights.fertileWindowStart, DateTime(2026, 7, 8));
      expect(insights.fertileWindowEnd, DateTime(2026, 7, 13));
      expect(insights.predictedNextPeriod, DateTime(2026, 7, 27));
      expect(insights.daysUntilNextPeriod, -23);
      expect(insights.fertileDays, contains(DateTime(2026, 7, 8)));
      expect(insights.fertileDays, contains(DateTime(2026, 7, 13)));
      expect(insights.ovulationDay, DateTime(2026, 7, 13));
    });

    test('phase detection across cycle days', () {
      final records = [
        period(id: '1', start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 5)),
      ];
      // Day 3 of cycle -> menstrual
      final menstrual = service.computeInsights(records, today: DateTime(2026, 8, 3));
      expect(menstrual.currentPhase, CyclePhase.menstrual);
      expect(menstrual.currentDayOfCycle, 3);

      // Day 10 -> follicular
      final follicular = service.computeInsights(records, today: DateTime(2026, 8, 10));
      expect(follicular.currentPhase, CyclePhase.follicular);

      // Day 14 -> ovulation
      final ovulation = service.computeInsights(records, today: DateTime(2026, 8, 14));
      expect(ovulation.currentPhase, CyclePhase.ovulation);

      // Day 20 -> luteal
      final luteal = service.computeInsights(records, today: DateTime(2026, 8, 20));
      expect(luteal.currentPhase, CyclePhase.luteal);
    });

    test('period days marker set covers the full range', () {
      final records = [
        period(id: '1', start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 16)),
      ];
      final insights = service.computeInsights(records, today: DateTime(2026, 8, 20));
      expect(insights.periodDays, {
        DateTime(2026, 8, 12),
        DateTime(2026, 8, 13),
        DateTime(2026, 8, 14),
        DateTime(2026, 8, 15),
        DateTime(2026, 8, 16),
      });
    });

    test('daily logs are flattened date-linked and newest first', () {
      final dayLogs = {
        '2026-08-13': PeriodDayLog(
          date: DateTime(2026, 8, 13),
          flowLevel: 'medium',
          moods: const ['Sad'],
          symptoms: const ['Brain Fog'],
          discharge: 'Watery',
        ),
      };
      final records = [
        period(
          id: '1',
          start: DateTime(2026, 8, 12),
          end: DateTime(2026, 8, 13),
          flow: 'heavy',
          moods: const ['Tired'],
          symptoms: const ['Cramps'],
          dailyLogs: dayLogs,
        ),
      ];
      final insights = service.computeInsights(records, today: DateTime(2026, 8, 20));
      expect(insights.dailySymptomLogs.length, 2);
      // Newest first: 13 Aug (customized day) then 12 Aug (inherited).
      expect(insights.dailySymptomLogs.first.date, DateTime(2026, 8, 13));
      expect(insights.dailySymptomLogs.first.mood, 'Sad');
      expect(insights.dailySymptomLogs.first.symptoms, contains('Brain Fog'));
      expect(insights.dailySymptomLogs.first.discharge, 'Watery');
      expect(insights.dailySymptomLogs.last.mood, 'Tired');
      expect(insights.dailySymptomLogs.last.flowLevel, 'heavy');
    });

    test('single record falls back to default cycle length', () {
      final records = [
        period(id: '1', start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 16)),
      ];
      final insights = service.computeInsights(records, today: DateTime(2026, 8, 16));
      expect(insights.averageCycleLength, 28);
      expect(insights.averagePeriodDuration, 5);
      expect(insights.currentPhase, CyclePhase.menstrual);
      expect(insights.predictedNextPeriod, DateTime(2026, 9, 9));
    });

    test('overdue cycle reports negative days until next period', () {
      final records = [
        period(id: '1', start: DateTime(2026, 7, 1), end: DateTime(2026, 7, 5)),
      ];
      final insights = service.computeInsights(records, today: DateTime(2026, 8, 16));
      expect(insights.daysUntilNextPeriod, isNegative);
      expect(insights.currentPhase, CyclePhase.luteal);
    });
  });

  group('PeriodRecord extended fields round-trip', () {
    test('serializes and deserializes all logged fields', () {
      final dayLogs = {
        '2026-08-12': PeriodDayLog(
          date: DateTime(2026, 8, 12),
          flowLevel: 'heavy',
          painLevel: 3,
          moods: const ['Tired'],
          symptoms: const ['Abdominal Pain'],
          discharge: 'Watery',
          digestion: const ['Cravings'],
          otherFactors: const ['Insomnia'],
        ),
      };
      final record = PeriodRecord.fromMap({
        'id': 'r1',
        'user_id': 'u1',
        'start_date': '2026-08-12',
        'end_date': '2026-08-16',
        'flow_level': 'heavy',
        'pain_level': 4,
        'moods': ['Tired', 'Sad'],
        'symptoms': ['Cramps', 'Headache'],
        'discharge': 'Watery',
        'digestion': ['Constipation'],
        'other_factors': ['Tender Breasts'],
        'daily_logs': dayLogs.map((k, v) => MapEntry(k, v.toMap())),
        'notes': 'Heavy flow day 1',
      });

      expect(record.moods, ['Tired', 'Sad']);
      expect(record.mood, 'Tired');
      expect(record.symptoms, ['Cramps', 'Headache']);
      expect(record.discharge, 'Watery');
      expect(record.digestion, ['Constipation']);
      expect(record.otherFactors, ['Tender Breasts']);
      expect(record.dailyLogs.keys, ['2026-08-12']);
      final dayLog = record.logForDate(DateTime(2026, 8, 12))!;
      expect(dayLog.moods, ['Tired']);
      expect(dayLog.symptoms, ['Abdominal Pain']);
      expect(dayLog.discharge, 'Watery');
      expect(dayLog.digestion, ['Cravings']);
      expect(dayLog.otherFactors, ['Insomnia']);
      expect(record.periodDates.length, 5);
    });

    test('legacy single mood row still deserializes', () {
      final record = PeriodRecord.fromMap({
        'id': 'r1',
        'user_id': 'u1',
        'start_date': '2026-08-11',
        'end_date': '2026-08-15',
        'flow_level': 'heavy',
        'pain_level': 4,
        'mood': 'Tired',
        'symptoms': ['Cramps'],
      });
      expect(record.moods, ['Tired']);
      expect(record.mood, 'Tired');
      expect(record.dailyLogs, isEmpty);
    });
  });
}
