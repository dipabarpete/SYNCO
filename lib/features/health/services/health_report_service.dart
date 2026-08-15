import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/cycle_data.dart';
import '../../../models/period_record.dart';
import '../../cycle/services/cycle_calculation_service.dart';
import '../../home/providers/dashboard_provider.dart';
import '../../symptoms_assessment/models/saved_screening_result.dart';
import '../models/ai_insight.dart';
import '../models/health_entries.dart';
import '../models/health_report_data.dart';
import '../providers/health_data_provider.dart';
import 'health_analytics.dart';
import 'health_report_pdf_generator.dart';
import 'health_score_status.dart';

/// Aggregates the authenticated user's stored SYNCO health data into a
/// [HealthReportData] and handles PDF generation, saving, opening and sharing.
///
/// All data comes from the app's existing providers (already scoped to the
/// signed-in user). The PDF is generated locally on the device and never sent
/// to an external service.
class HealthReportService {
  const HealthReportService._();

  static final DateFormat _shortDate = DateFormat('d MMM yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  // ---------------------------------------------------------------------------
  // AGGREGATION
  // ---------------------------------------------------------------------------

  /// Builds the full report snapshot for the chosen period from the app's
  /// existing, user-scoped data. [now] is injectable for testing.
  static HealthReportData buildReport({
    required HealthReportPeriodType periodType,
    required HealthDataState healthData,
    required HealthScoreState healthScore,
    required CycleInsights cycleInsights,
    required List<PeriodRecord> periodRecords,
    required List<AiInsight> aiInsights,
    required Map<ScreeningAssessmentType, SavedScreeningResult> screenings,
    String userName = '',
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final start = periodType == HealthReportPeriodType.weekly
        ? HealthAnalytics.addDays(reference, -6)
        : HealthAnalytics.firstOfMonth(reference);
    final end = HealthAnalytics.startOfDay(reference);

    final stats = HealthAnalytics.period(
      all: healthData.allEntries,
      start: start,
      end: end,
    );

    final status = getHealthScoreStatus(healthScore.score);

    return HealthReportData(
      periodType: periodType,
      periodLabel: periodType == HealthReportPeriodType.weekly
          ? 'Weekly Health Report'
          : 'Monthly Health Report',
      dateRangeLabel: periodType == HealthReportPeriodType.weekly
          ? '${_shortDate.format(start)} – ${_shortDate.format(end)}'
          : _monthYear.format(start),
      startDate: start,
      endDate: end,
      generatedAt: reference,
      userName: userName.trim(),
      healthScore: healthScore.score,
      percentile: healthScore.percentile,
      healthStatus: status.status,
      healthMessage: status.message,
      healthColorArgb: status.color.toARGB32(),
      breakdown: _buildBreakdown(stats),
      tracking: _buildTracking(stats, healthData, start, end),
      cycle: _buildCycle(cycleInsights, periodRecords, start, end),
      assessments: _buildAssessments(screenings),
      insights: [
        for (final insight in aiInsights)
          AiInsightReportData(
            kindLabel: insight.kind.label,
            categoryLabel: insight.category.label,
            title: insight.title,
            summary: insight.summary,
            detail: insight.detail,
            periodLabel: insight.periodLabel,
            basisLabel: insight.basisLabel,
          ),
      ],
      summaryNote: _buildSummaryNote(
        periodType: periodType,
        percentile: healthScore.percentile,
        daysWithData: stats.daysWithData,
      ),
    );
  }

  /// Mirrors the score-breakdown grades shown on the Full Health Report screen
  /// so the PDF always matches the app.
  static List<ScoreBreakdownRow> _buildBreakdown(PeriodStats stats) {
    List<ScoreBreakdownRow> rows = [];

    void add({
      required String title,
      required String value,
      required bool good,
      required bool fair,
      required bool logged,
    }) {
      final (label, color) = _grade(good: good, fair: fair, logged: logged);
      rows.add(ScoreBreakdownRow(
        title: title,
        value: value,
        statusLabel: label,
        statusColorArgb: color.toARGB32(),
      ));
    }

    add(
      title: 'Sleep',
      value: _formatSleep(stats.avgSleepMinutes),
      good: stats.avgSleepMinutes != null &&
          stats.avgSleepMinutes! >= 420 &&
          stats.avgSleepMinutes! <= 540,
      fair: stats.avgSleepMinutes != null,
      logged: stats.avgSleepMinutes != null,
    );
    add(
      title: 'Activity',
      value: _formatSteps(stats.avgSteps),
      good: stats.avgSteps != null && stats.avgSteps! >= 7500,
      fair: stats.avgSteps != null && stats.avgSteps! >= 5000,
      logged: stats.avgSteps != null,
    );
    add(
      title: 'Hydration',
      value: _formatWater(stats.avgWaterFlOz),
      good: stats.avgWaterFlOz != null && stats.avgWaterFlOz! >= 64,
      fair: stats.avgWaterFlOz != null && stats.avgWaterFlOz! >= 40,
      logged: stats.avgWaterFlOz != null,
    );
    add(
      title: 'Mental Wellbeing',
      value: _formatStress(stats.avgStress),
      good: stats.avgStress != null && stats.avgStress! <= 2,
      fair: stats.avgStress != null && stats.avgStress! <= 3.5,
      logged: stats.avgStress != null,
    );
    add(
      title: 'Nutrition',
      value: _formatMeals(stats.mealCount),
      good: stats.mealCount >= 14,
      fair: stats.mealCount >= 7,
      logged: stats.mealCount > 0,
    );
    add(
      title: 'Medication Adherence',
      value: _formatSupplements(stats.supplementDays),
      good: stats.supplementDays >= 6,
      fair: stats.supplementDays >= 3,
      logged: stats.supplementDays > 0,
    );

    return rows;
  }

  /// Only includes trackers that actually contain data in the period.
  static List<TrackingSection> _buildTracking(
    PeriodStats stats,
    HealthDataState data,
    DateTime start,
    DateTime end,
  ) {
    final inPeriod = data.allEntries
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();

    final sections = <TrackingSection>[];

    final sleep = inPeriod.whereType<SleepEntry>().toList();
    if (sleep.isNotEmpty) {
      final avg = sleep.map((e) => e.durationMinutes).reduce((a, b) => a + b) /
          sleep.length;
      final quality = <String, int>{};
      for (final entry in sleep) {
        quality[entry.quality] = (quality[entry.quality] ?? 0) + 1;
      }
      final qualityText = quality.entries
          .map((e) => '${e.key} x${e.value}')
          .join(', ');
      sections.add(TrackingSection(
        title: 'Sleep',
        summary: 'Avg ${_formatDuration(avg)} / night',
        details: [
          '${sleep.length} night(s) logged'
              '${qualityText.isEmpty ? '' : ' · Quality: $qualityText'}',
        ],
      ));
    }

    final water = inPeriod.whereType<WaterEntry>().toList();
    if (water.isNotEmpty) {
      final perDay = <String, double>{};
      for (final entry in water) {
        perDay[healthDateKey(entry.date)] =
            (perDay[healthDateKey(entry.date)] ?? 0) + entry.quantityFlOz;
      }
      final avgCups = perDay.values.reduce((a, b) => a + b) / perDay.length / 8;
      sections.add(TrackingSection(
        title: 'Hydration',
        summary: 'Avg ${avgCups.toStringAsFixed(1)} cups / day',
        details: ['${water.length} glass(es) logged on ${perDay.length} day(s)'],
      ));
    }

    final steps = inPeriod.whereType<StepEntry>().toList();
    if (steps.isNotEmpty) {
      final avg = steps.map((e) => e.count).reduce((a, b) => a + b) /
          steps.length;
      sections.add(TrackingSection(
        title: 'Activity',
        summary: 'Avg ${avg.round()} steps / day',
        details: ['${steps.length} day(s) logged'],
      ));
    }

    final cravings = inPeriod.whereType<SugarCravingEntry>().toList();
    if (cravings.isNotEmpty) {
      final levels = <String, int>{};
      for (final entry in cravings) {
        levels[entry.level] = (levels[entry.level] ?? 0) + 1;
      }
      final levelText =
          levels.entries.map((e) => '${e.key} x${e.value}').join(', ');
      sections.add(TrackingSection(
        title: 'Sugar Cravings',
        summary: '${cravings.length} craving(s) logged',
        details: [
          if (levelText.isNotEmpty) 'Level: $levelText',
        ],
      ));
    }

    final supplements = inPeriod.whereType<SupplementEntry>().toList();
    if (supplements.isNotEmpty) {
      final days = supplements.map((e) => healthDateKey(e.date)).toSet().length;
      final names = supplements.map((e) => e.name).toSet().take(3).join(', ');
      sections.add(TrackingSection(
        title: 'Supplements',
        summary: '${supplements.length} intake(s) on $days day(s)',
        details: [
          if (names.isNotEmpty) 'Recorded: $names',
        ],
      ));
    }

    final wellness = inPeriod.whereType<MentalWellnessEntry>().toList();
    if (wellness.isNotEmpty) {
      final moods = <String, int>{};
      for (final entry in wellness) {
        moods[entry.mood] = (moods[entry.mood] ?? 0) + 1;
      }
      final moodText =
          moods.entries.map((e) => '${e.key} x${e.value}').join(', ');
      sections.add(TrackingSection(
        title: 'Mental Wellness',
        summary: 'Stress ${_avgLevel(wellness, (e) => e.stressLevel)}/5 · '
            'Energy ${_avgLevel(wellness, (e) => e.energyLevel)}/5',
        details: [
          '${wellness.length} check-in(s)'
              '${moodText.isEmpty ? '' : ' · Moods: $moodText'}',
        ],
      ));
    }

    final food = inPeriod.whereType<FoodEntry>().toList();
    if (food.isNotEmpty) {
      final mealTypes = <String, int>{};
      for (final entry in food) {
        mealTypes[entry.mealType] = (mealTypes[entry.mealType] ?? 0) + 1;
      }
      final mealText =
          mealTypes.entries.map((e) => '${e.key} x${e.value}').join(', ');
      final favorites = food.where((e) => e.isFavorite).length;
      sections.add(TrackingSection(
        title: 'Nutrition',
        summary: '${food.length} meal(s) logged',
        details: [
          if (mealText.isNotEmpty) mealText,
          if (favorites > 0) '$favorites favourite meal(s)',
        ],
      ));
    }

    final weight = inPeriod.whereType<WeightEntry>().toList();
    if (weight.isNotEmpty) {
      weight.sort((a, b) => a.date.compareTo(b.date));
      final first = weight.first;
      final last = weight.last;
      final change = last.weightKg - first.weightKg;
      final changeText = change.abs() < 0.01
          ? 'No change'
          : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg'
              ' (${change > 0 ? 'gain' : 'loss'})';
      sections.add(TrackingSection(
        title: 'Weight',
        summary: 'Latest ${last.weight.toStringAsFixed(1)} ${last.unit}',
        details: [
          '${weight.length} weigh-in(s) · $changeText over the period',
        ],
      ));
    }

    return sections;
  }

  static CycleReportData _buildCycle(
    CycleInsights insights,
    List<PeriodRecord> records,
    DateTime start,
    DateTime end,
  ) {
    final inPeriod = records
        .where((r) =>
            !r.startDate.isBefore(start) && !r.startDate.isAfter(end))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return CycleReportData(
      hasHistory: insights.hasHistory,
      averageCycleLength: insights.averageCycleLength,
      averagePeriodDuration: insights.averagePeriodDuration,
      lastPeriodStartDate: insights.lastPeriodStartDate,
      currentPhaseLabel: insights.currentPhase.displayName,
      currentDayOfCycle: insights.currentDayOfCycle,
      predictedNextPeriod: insights.predictedNextPeriod,
      daysUntilNextPeriod: insights.daysUntilNextPeriod,
      estimatedOvulation: insights.estimatedOvulation,
      fertileWindowStart: insights.fertileWindowStart,
      fertileWindowEnd: insights.fertileWindowEnd,
      cycleNumber: insights.cycleNumber,
      periodHistoryLines: [
        for (final record in inPeriod)
          _periodHistoryLine(record),
      ],
    );
  }

  static String _periodHistoryLine(PeriodRecord record) {
    final buffer = StringBuffer(DateFormat('d MMM yyyy').format(record.startDate));
    final end = record.endDate;
    if (end != null && !end.isBefore(record.startDate)) {
      buffer.write(' – ${DateFormat('d MMM yyyy').format(end)}');
    }
    final flow = record.flowLevelDisplay;
    final pain = record.painLevel;
    if (flow != null) buffer.write(' · Flow: $flow');
    if (pain != null) buffer.write(' · Pain: $pain/5');
    if (record.moods.isNotEmpty) {
      buffer.write(' · Mood: ${record.moods.take(2).join(', ')}');
    }
    return buffer.toString();
  }

  static List<AssessmentReportData> _buildAssessments(
    Map<ScreeningAssessmentType, SavedScreeningResult> screenings,
  ) {
    return [
      for (final result in screenings.values)
        AssessmentReportData(
          title: result.categoryTitle,
          scoreLabel: 'Score ${result.rawScore}',
          levelLabel: result.levelLabel,
          completedLabel:
              'Completed ${DateFormat('d MMM yyyy').format(result.completedAt)}',
        ),
    ];
  }

  static String _buildSummaryNote({
    required HealthReportPeriodType periodType,
    required int percentile,
    required int daysWithData,
  }) {
    final windowLabel =
        periodType == HealthReportPeriodType.weekly ? 'this week' : 'this month';
    final dayWord = daysWithData == 1 ? 'day' : 'days';
    return 'You are in the top $percentile% of users with similar cycle '
        'profiles $windowLabel.\n'
        'You logged health data on $daysWithData $dayWord in this period. '
        'Keep up your daily tracking so your health report stays complete '
        'and accurate.';
  }

  // ---------------------------------------------------------------------------
  // GRADE HELPERS (mirror the Full Health Report screen)
  // ---------------------------------------------------------------------------

  static (String, Color) _grade({
    required bool good,
    required bool fair,
    required bool logged,
  }) {
    if (good) return ('On Track', AppColors.confirmedGreen);
    if (fair) return ('Needs Work', AppColors.pendingAmber);
    if (logged) return ('Needs Attention', AppColors.deepRose);
    return ('Not Logged', AppColors.textLight);
  }

  // ---------------------------------------------------------------------------
  // FORMATTING HELPERS
  // ---------------------------------------------------------------------------

  static String _formatSleep(double? minutes) {
    if (minutes == null) return 'Not logged';
    return 'Avg ${_formatDuration(minutes)} / night';
  }

  static String _formatDuration(double minutes) {
    final h = minutes ~/ 60;
    final m = (minutes % 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String _formatSteps(double? steps) {
    if (steps == null) return 'Not logged';
    return 'Avg ${steps.round()} steps / day';
  }

  static String _formatWater(double? flOz) {
    if (flOz == null) return 'Not logged';
    return 'Avg ${(flOz / 8).toStringAsFixed(1)} cups / day';
  }

  static String _formatStress(double? stress) {
    if (stress == null) return 'Not logged';
    final level = stress <= 2.0
        ? 'Low'
        : stress <= 3.5
            ? 'Moderate'
            : 'High';
    return 'Avg stress: $level (${stress.toStringAsFixed(1)}/5)';
  }

  static String _formatMeals(int count) {
    if (count == 0) return 'Not logged';
    return '$count meal(s) logged';
  }

  static String _formatSupplements(int days) {
    if (days == 0) return 'Not logged';
    return 'Logged on $days day(s)';
  }

  static double _avgLevel(
    List<MentalWellnessEntry> entries,
    int Function(MentalWellnessEntry) selector,
  ) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<int>(0, (acc, e) => acc + selector(e));
    final avg = sum / entries.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  // ---------------------------------------------------------------------------
  // PDF LIFE-CYCLE
  // ---------------------------------------------------------------------------

  /// File name such as `synco_health_report_weekly-2026-08-10.pdf`.
  static String reportFileName(HealthReportData data) {
    final prefix = data.periodType == HealthReportPeriodType.weekly
        ? 'weekly'
        : 'monthly';
    return 'synco_health_report_$prefix-'
        '${DateFormat('yyyy-MM-dd').format(data.startDate)}.pdf';
  }

  /// Generates the PDF bytes locally on the device.
  static Future<Uint8List> generatePdfBytes(HealthReportData data) {
    return HealthReportPdfGenerator().generate(data);
  }

  /// Persists the PDF in the app's documents directory and returns the path.
  static Future<String> saveToDevice(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Opens the platform share sheet so the user can save or send the PDF.
  static Future<bool> sharePdf(Uint8List bytes, String fileName) {
    return Printing.sharePdf(
      bytes: bytes,
      filename: fileName,
      subject: 'SYNCO Health Report',
      body: 'Your personal health report from SYNCO.',
    );
  }

  /// Opens the saved PDF with the device's default viewer.
  static Future<void> openPdf(String path) => OpenFilex.open(path);
}
