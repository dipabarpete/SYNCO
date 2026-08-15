import 'package:intl/intl.dart';

import '../../../models/cycle_data.dart';
import '../../../models/period_day_log.dart';
import '../../../models/period_record.dart';

/// Result of running the cycle prediction over the user's logged periods.
///
/// All dates here are ESTIMATES derived from the user's logged history.
/// They are predictions, not guaranteed biological dates.
class CycleInsights {
  /// True when the user has at least one logged period to base estimates on.
  final bool hasHistory;

  final int averageCycleLength;
  final int averagePeriodDuration;

  final DateTime? lastPeriodStartDate;
  final int currentDayOfCycle;
  final CyclePhase currentPhase;

  /// Predicted next period start (may be in the past when overdue).
  final DateTime? predictedNextPeriod;
  final int? daysUntilNextPeriod;

  /// Estimated ovulation for the current cycle.
  final DateTime? estimatedOvulation;

  /// Estimated fertile window (inclusive).
  final DateTime? fertileWindowStart;
  final DateTime? fertileWindowEnd;

  /// Calendar marker date sets.
  final Set<DateTime> periodDays;
  final Set<DateTime> fertileDays;
  final DateTime? ovulationDay;

  /// Next few predicted period starts after the current cycle.
  final List<DateTime> predictedPeriodStarts;

  /// Sequential number of the current cycle (from the oldest logged cycle).
  final int cycleNumber;

  /// Flattened per-day logs from all records, newest first.
  final List<DailySymptomLog> dailySymptomLogs;

  const CycleInsights({
    required this.hasHistory,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    required this.lastPeriodStartDate,
    required this.currentDayOfCycle,
    required this.currentPhase,
    required this.predictedNextPeriod,
    required this.daysUntilNextPeriod,
    required this.estimatedOvulation,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.periodDays,
    required this.fertileDays,
    required this.ovulationDay,
    required this.predictedPeriodStarts,
    required this.cycleNumber,
    required this.dailySymptomLogs,
  });
}

/// Centralized cycle prediction logic.
///
/// Single source of truth for cycle calculations: the UI never duplicates
/// this logic. Pass the user's [PeriodRecord]s and get back [CycleInsights].
class CycleCalculationService {
  static const int defaultCycleLength = 28;
  static const int defaultPeriodDuration = 5;

  /// Number of days before ovulation considered part of the fertile window.
  static const int fertileWindowLeadDays = 5;

  /// Standard luteal phase length used for the ovulation estimate.
  static const int lutealPhaseDays = 14;

  /// Computes cycle insights from the user's saved period history.
  CycleInsights computeInsights(
    List<PeriodRecord> records, {
    DateTime? today,
  }) {
    final now = _dateOnly(today ?? DateTime.now());
    final sorted = _normalize(records);

    if (sorted.isEmpty) {
      return _emptyInsights(now);
    }

    final averageCycle = _averageCycleLength(sorted);
    final averagePeriod = _averagePeriodDuration(sorted);

    final lastStart = _dateOnly(sorted.last.startDate);
    final elapsedDays = now.difference(lastStart).inDays;

    // Number of full cycles that have elapsed since the last logged start.
    final elapsedCycles =
        elapsedDays >= 0 ? elapsedDays ~/ averageCycle : 0;
    final cycleStart =
        lastStart.add(Duration(days: elapsedCycles * averageCycle));
    final dayOfCycle = now.difference(cycleStart).inDays + 1;

    final predictedNext = cycleStart.add(Duration(days: averageCycle));
    final daysUntilNext = now.difference(predictedNext).inDays;

    final ovulation =
        cycleStart.add(Duration(days: averageCycle - lutealPhaseDays));
    final fertileStart =
        ovulation.subtract(Duration(days: fertileWindowLeadDays));
    final fertileEnd = ovulation;

    final periodDays = <DateTime>{};
    final fertileDays = <DateTime>{};
    for (final record in sorted) {
      periodDays.addAll(record.periodDates);
    }
    var fertileDay = fertileStart;
    while (!fertileDay.isAfter(fertileEnd)) {
      fertileDays.add(_dateOnly(fertileDay));
      fertileDay = fertileDay.add(const Duration(days: 1));
    }
    final ovulationDay = _dateOnly(ovulation);

    final predictedStarts = <DateTime>[];
    for (var i = 1; i <= 3; i++) {
      predictedStarts.add(cycleStart.add(Duration(days: averageCycle * i)));
    }

    final phase = _phaseForDay(
      dayOfCycle: dayOfCycle,
      averagePeriod: averagePeriod,
      ovulationDay: averageCycle - lutealPhaseDays,
      averageCycle: averageCycle,
    );

    return CycleInsights(
      hasHistory: true,
      averageCycleLength: averageCycle,
      averagePeriodDuration: averagePeriod,
      lastPeriodStartDate: lastStart,
      currentDayOfCycle: dayOfCycle,
      currentPhase: phase,
      predictedNextPeriod: predictedNext,
      daysUntilNextPeriod: daysUntilNext,
      estimatedOvulation: _dateOnly(ovulation),
      fertileWindowStart: _dateOnly(fertileStart),
      fertileWindowEnd: _dateOnly(fertileEnd),
      periodDays: periodDays,
      fertileDays: fertileDays,
      ovulationDay: ovulationDay,
      predictedPeriodStarts: predictedStarts,
      cycleNumber: sorted.length + elapsedCycles,
      dailySymptomLogs: _flattenDailyLogs(sorted),
    );
  }

  /// Safe fallback used when the user has not logged any period yet.
  CycleInsights _emptyInsights(DateTime now) {
    final lastStart = now.subtract(const Duration(days: 11));
    final ovulation =
        lastStart.add(Duration(days: defaultCycleLength - lutealPhaseDays));
    final fertileStart =
        ovulation.subtract(Duration(days: fertileWindowLeadDays));
    final predictedNext = lastStart.add(const Duration(days: defaultCycleLength));

    return CycleInsights(
      hasHistory: false,
      averageCycleLength: defaultCycleLength,
      averagePeriodDuration: defaultPeriodDuration,
      lastPeriodStartDate: lastStart,
      currentDayOfCycle: 12,
      currentPhase: CyclePhase.follicular,
      predictedNextPeriod: predictedNext,
      daysUntilNextPeriod: now.difference(predictedNext).inDays,
      estimatedOvulation: ovulation,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: ovulation,
      periodDays: const {},
      fertileDays: const {},
      ovulationDay: null,
      predictedPeriodStarts: const [],
      cycleNumber: 0,
      dailySymptomLogs: const [],
    );
  }

  /// Phase estimate for a given day of the cycle.
  CyclePhase _phaseForDay({
    required int dayOfCycle,
    required int averagePeriod,
    required int ovulationDay,
    required int averageCycle,
  }) {
    if (dayOfCycle <= averagePeriod) return CyclePhase.menstrual;
    if (dayOfCycle < ovulationDay) return CyclePhase.follicular;
    if (dayOfCycle == ovulationDay) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  int _averageCycleLength(List<PeriodRecord> sorted) {
    final gaps = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final gap = _dateOnly(sorted[i].startDate)
          .difference(_dateOnly(sorted[i - 1].startDate))
          .inDays;
      if (gap > 0) gaps.add(gap);
    }
    if (gaps.isEmpty) return defaultCycleLength;
    final avg = gaps.reduce((a, b) => a + b) / gaps.length;
    return (avg.round()).clamp(21, 45);
  }

  int _averagePeriodDuration(List<PeriodRecord> sorted) {
    final lengths = <int>[];
    for (final record in sorted) {
      final end = record.endDate;
      if (end != null && !end.isBefore(record.startDate)) {
        lengths.add(
          _dateOnly(end).difference(_dateOnly(record.startDate)).inDays + 1,
        );
      }
    }
    if (lengths.isEmpty) return defaultPeriodDuration;
    final avg = lengths.reduce((a, b) => a + b) / lengths.length;
    return avg.round().clamp(2, 10);
  }

  /// Removes duplicate start dates and sorts chronologically.
  List<PeriodRecord> _normalize(List<PeriodRecord> records) {
    final byStart = <String, PeriodRecord>{};
    for (final record in records) {
      final key = PeriodDayLog.formatDateKey(record.startDate);
      final existing = byStart[key];
      if (existing == null ||
          (record.endDate != null && existing.endDate == null)) {
        byStart[key] = record;
      }
    }
    final sorted = byStart.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return sorted;
  }

  List<DailySymptomLog> _flattenDailyLogs(List<PeriodRecord> sorted) {
    final logs = <DailySymptomLog>[];
    final byDate = <DateTime, List<PeriodRecord>>{};
    for (final record in sorted) {
      for (final date in record.periodDates) {
        byDate.putIfAbsent(date, () => []).add(record);
      }
    }

    for (final record in sorted) {
      for (final date in record.periodDates) {
        final dayLog = record.logForDate(date);
        logs.add(DailySymptomLog(
          date: date,
          symptoms: dayLog?.symptoms.isNotEmpty == true
              ? dayLog!.symptoms
              : record.symptoms,
          flowLevel: dayLog?.flowLevel ?? record.flowLevel ?? 'None',
          painScale: dayLog?.painLevel ?? record.painLevel ?? 0,
          mood: dayLog?.moods.isNotEmpty == true
              ? dayLog!.moods.first
              : record.mood ?? 'Neutral',
          moods: dayLog?.moods.isNotEmpty == true
              ? dayLog!.moods
              : record.moods,
          discharge: dayLog?.discharge ?? record.discharge,
          digestion: dayLog?.digestion.isNotEmpty == true
              ? dayLog!.digestion
              : record.digestion,
          otherFactors: dayLog?.otherFactors.isNotEmpty == true
              ? dayLog!.otherFactors
              : record.otherFactors,
        ));
      }
    }

    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Formats a date as `12 Aug` for compact UI labels.
  static String shortDate(DateTime date) =>
      DateFormat('d MMM').format(date);
}
