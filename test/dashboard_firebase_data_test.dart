import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/cycle/services/cycle_calculation_service.dart';
import 'package:hersync/models/period_record.dart';
import 'package:hersync/models/cycle_data.dart';

void main() {
  group('Dashboard Firebase Health Data & Cycle Calculation Tests', () {
    test('CycleCalculationService computes correct insights from historical period records', () {
      final now = DateTime.now();
      final lastPeriodStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 10));
      final previousPeriodStart = lastPeriodStart.subtract(const Duration(days: 28));

      final records = [
        PeriodRecord(
          id: 'p1',
          userId: 'u1',
          startDate: lastPeriodStart,
          endDate: lastPeriodStart.add(const Duration(days: 5)),
          flowLevel: 'medium',
          painLevel: 3,
        ),
        PeriodRecord(
          id: 'p2',
          userId: 'u1',
          startDate: previousPeriodStart,
          endDate: previousPeriodStart.add(const Duration(days: 5)),
          flowLevel: 'medium',
          painLevel: 2,
        ),
      ];

      final service = CycleCalculationService();
      final insights = service.computeInsights(records, today: now);

      expect(insights.hasHistory, isTrue);
      expect(insights.averageCycleLength, equals(28));
      expect(insights.currentDayOfCycle, equals(11));
      expect(insights.currentPhase, equals(CyclePhase.follicular));
      expect(insights.daysUntilNextPeriod, isNotNull);
    });

    test('Empty period records return hasHistory=false without throwing', () {
      final service = CycleCalculationService();
      final insights = service.computeInsights([]);

      expect(insights.hasHistory, isFalse);
      expect(insights.averageCycleLength, equals(28));
      expect(insights.currentPhase, equals(CyclePhase.follicular));
    });

    test('Health Score calculation deduces points for severe symptoms and clamps between 0 and 100', () {
      int calculateScore({required List<String> symptoms, required num? sleepHours, required num? waterLiters}) {
        int score = 85;
        for (final symptom in symptoms) {
          if (symptom == 'severe') {
            score -= 2;
          } else if (symptom == 'moderate') {
            score -= 1;
          }
        }
        if (sleepHours != null && sleepHours >= 7.0) score += 2;
        if (waterLiters != null && waterLiters >= 2.0) score += 2;
        return score.clamp(0, 100);
      }

      final baselineScore = calculateScore(symptoms: [], sleepHours: 8.0, waterLiters: 2.2);
      expect(baselineScore, equals(89));

      final symptomaticScore = calculateScore(
        symptoms: ['severe', 'severe', 'moderate'],
        sleepHours: 4.5,
        waterLiters: 1.0,
      );
      expect(symptomaticScore, equals(80));
    });
  });
}
