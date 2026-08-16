import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/models/health_entries.dart';
import 'package:hersync/features/health/models/health_report_data.dart';
import 'package:hersync/features/health/providers/health_data_provider.dart';
import 'package:hersync/features/health/services/health_report_pdf_generator.dart';
import 'package:hersync/features/health/services/health_report_service.dart';
import 'package:hersync/features/home/providers/dashboard_provider.dart';
import 'package:hersync/features/symptoms_assessment/models/saved_screening_result.dart';
import 'package:hersync/models/period_record.dart';

import 'package:hersync/features/cycle/services/cycle_calculation_service.dart';
import 'package:hersync/features/health/models/ai_insight.dart';

void main() {
  final now = DateTime(2026, 8, 16);

  HealthDataState sampleHealthData() {
    return HealthDataState(
      sleep: [
        SleepEntry(
          id: 's1',
          userId: 'u1',
          date: DateTime(2026, 8, 14),
          startMinutes: 23 * 60,
          endMinutes: 7 * 60,
          durationMinutes: 480,
          quality: 'Good',
          factors: const [],
          createdAt: '',
          updatedAt: '',
        ),
      ],
      water: [
        WaterEntry(
          id: 'w1',
          userId: 'u1',
          date: DateTime(2026, 8, 14),
          quantity: 4,
          unit: 'cups',
          hydrationLevel: 'Good',
          createdAt: '',
          updatedAt: '',
        ),
        WaterEntry(
          id: 'w2',
          userId: 'u1',
          date: DateTime(2026, 8, 15),
          quantity: 4,
          unit: 'cups',
          hydrationLevel: 'Good',
          createdAt: '',
          updatedAt: '',
        ),
      ],
      steps: [
        StepEntry(
          id: 'st1',
          userId: 'u1',
          date: DateTime(2026, 8, 14),
          count: 8000,
          createdAt: '',
          updatedAt: '',
        ),
      ],
      wellness: [
        MentalWellnessEntry(
          id: 'm1',
          userId: 'u1',
          date: DateTime(2026, 8, 14),
          stressLevel: 2,
          anxietyLevel: 3,
          energyLevel: 4,
          sleepQuality: 'Good',
          mood: 'Happy',
          createdAt: '',
          updatedAt: '',
        ),
      ],
      food: [
        FoodEntry(
          id: 'f1',
          userId: 'u1',
          date: DateTime(2026, 8, 14),
          description: 'Salad',
          mealType: 'Lunch',
          tags: const ['Leafy Green'],
          isFavorite: true,
          createdAt: '',
          updatedAt: '',
        ),
      ],
      supplements: [
        SupplementEntry(
          id: 'su1',
          userId: 'u1',
          date: DateTime(2026, 8, 14),
          name: 'Vitamin D',
          createdAt: '',
          updatedAt: '',
        ),
      ],
    );
  }

  HealthScoreState sampleScore() =>
      const HealthScoreState(score: 85, percentile: 78);

  CycleInsights sampleCycle() {
    final records = [
      PeriodRecord(
        id: 'p1',
        userId: 'u1',
        startDate: DateTime(2026, 8, 3),
        endDate: DateTime(2026, 8, 7),
        flowLevel: 'medium',
        painLevel: 3,
        moods: const ['Calm'],
      ),
    ];
    return CycleCalculationService().computeInsights(records, today: now);
  }

  List<AiInsight> sampleInsights() => [
        AiInsight(
          id: 'i1',
          title: 'Sleep is on track',
          summary: 'You averaged 8h of sleep this week.',
          detail: 'Keep your consistent bedtime.',
          periodLabel: 'This week',
          basisLabel: 'Based on 1 day of data',
          kind: InsightKind.sleep,
          category: InsightCategory.observation,
        ),
      ];

  Map<ScreeningAssessmentType, SavedScreeningResult> sampleScreenings() => {
        ScreeningAssessmentType.pcos: SavedScreeningResult(
          assessmentType: ScreeningAssessmentType.pcos,
          categoryTitle: 'PCOS Assessment',
          levelLabel: 'Low Risk',
          rawScore: 2,
          isCompleted: true,
          completedAt: DateTime(2026, 8, 10),
        ),
      };

  group('HealthReportService.buildReport', () {
    test('weekly report uses the last 7 days and correct labels', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: [
          PeriodRecord(
            id: 'p2',
            userId: 'u1',
            startDate: DateTime(2026, 8, 3),
            endDate: DateTime(2026, 8, 7),
          ),
        ],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        userName: 'Sonali',
        now: now,
      );

      expect(report.periodLabel, 'Weekly Health Report');
      expect(report.dateRangeLabel, '10 Aug 2026 – 16 Aug 2026');
      expect(report.startDate, DateTime(2026, 8, 10));
      expect(report.endDate, DateTime(2026, 8, 16));
      expect(report.userName, 'Sonali');
      expect(report.healthScore, 85);
      expect(report.healthStatus, 'ON TRACK');
    });

    test('monthly report uses the current month label', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.monthly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        now: now,
      );

      expect(report.periodLabel, 'Monthly Health Report');
      expect(report.dateRangeLabel, 'August 2026');
      expect(report.startDate, DateTime(2026, 8, 1));
    });

    test('breakdown mirrors the report screen with 6 rows', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        now: now,
      );

      expect(report.breakdown.length, 6);
      final sleep = report.breakdown.firstWhere((r) => r.title == 'Sleep');
      expect(sleep.statusLabel, 'On Track');
      expect(sleep.value, contains('8h'));
      final nutrition =
          report.breakdown.firstWhere((r) => r.title == 'Nutrition');
      expect(nutrition.statusLabel, 'Needs Attention');
    });

    test('tracking includes only trackers with data', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        now: now,
      );

      final titles = report.tracking.map((t) => t.title).toSet();
      expect(titles, {
        'Sleep',
        'Hydration',
        'Activity',
        'Mental Wellness',
        'Nutrition',
        'Supplements',
      });
      expect(titles.contains('Weight'), isFalse);
    });

    test('cycle section labels ovulation and fertility as estimates', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: [
          PeriodRecord(
            id: 'p2',
            userId: 'u1',
            startDate: DateTime(2026, 8, 12),
            endDate: DateTime(2026, 8, 14),
            flowLevel: 'medium',
            painLevel: 3,
          ),
        ],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        now: now,
      );

      expect(report.cycle.hasHistory, isTrue);
      expect(report.cycle.averageCycleLength, 28);
      expect(report.cycle.currentPhaseLabel, isNotEmpty);
      expect(report.cycle.estimatedOvulation, isNotNull);
      expect(report.cycle.fertileWindowStart, isNotNull);
      expect(report.cycle.periodHistoryLines, hasLength(1));
      expect(report.cycle.periodHistoryLines.first, contains('12 Aug 2026'));
      expect(report.cycle.periodHistoryLines.first, contains('Flow: Medium'));
      expect(report.cycle.periodHistoryLines.first, contains('Pain: 3/5'));
    });

    test('assessments and insights are included', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        now: now,
      );

      expect(report.assessments, hasLength(1));
      expect(report.assessments.first.title, 'PCOS Assessment');
      expect(report.assessments.first.scoreLabel, 'Score 2');
      expect(report.insights, hasLength(1));
      expect(report.insights.first.title, 'Sleep is on track');
      expect(report.insights.first.kindLabel, 'Sleep');
    });

    test('empty data still produces a complete report', () {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: const HealthDataState(),
        healthScore: const HealthScoreState(score: 60),
        cycleInsights:
            CycleCalculationService().computeInsights(const [], today: now),
        periodRecords: const [],
        aiInsights: const [],
        screenings: const {},
        now: now,
      );

      expect(report.breakdown, hasLength(6));
      expect(report.tracking, isEmpty);
      expect(report.cycle.hasHistory, isFalse);
      expect(report.assessments, isEmpty);
      expect(report.insights, isEmpty);
      expect(report.summaryNote, contains('top 75%'));
    });
  });

  group('HealthReportPdfGenerator', () {
    test('generates a real PDF document', () async {
      final report = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: sampleInsights(),
        screenings: sampleScreenings(),
        now: now,
      );

      final Uint8List bytes =
          await HealthReportPdfGenerator().generate(report);

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(1000));
      expect(
        String.fromCharCodes(bytes.take(4)),
        '%PDF',
        reason: 'output must start with the PDF magic header',
      );
    });

    test('report file name encodes the period', () {
      final weekly = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.weekly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: const [],
        screenings: const {},
        now: now,
      );
      expect(
        HealthReportService.reportFileName(weekly),
        'synco_health_report_weekly-2026-08-10.pdf',
      );

      final monthly = HealthReportService.buildReport(
        periodType: HealthReportPeriodType.monthly,
        healthData: sampleHealthData(),
        healthScore: sampleScore(),
        cycleInsights: sampleCycle(),
        periodRecords: const [],
        aiInsights: const [],
        screenings: const {},
        now: now,
      );
      expect(
        HealthReportService.reportFileName(monthly),
        'synco_health_report_monthly-2026-08-01.pdf',
      );
    });
  });
}
