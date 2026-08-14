import '../models/health_entries.dart';

/// Aggregation layer that turns raw stored health entries into usable daily,
/// weekly and monthly statistics.
///
/// All methods are pure and operate on in-memory lists with no I/O.
class HealthAnalytics {
  const HealthAnalytics._();

  // -------------------------------------------------------------------------
  // DATE HELPERS
  // -------------------------------------------------------------------------

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime addDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  static DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime firstOfPrevMonth(DateTime d) =>
      DateTime(d.year, d.month - 1, 1);

  static DateTime lastOfPrevMonth(DateTime d) =>
      DateTime(d.year, d.month, 0);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // -------------------------------------------------------------------------
  // DAILY SNAPSHOT ("Today" card)
  // -------------------------------------------------------------------------

  static DailySnapshot daily({
    required List<HealthEntry> all,
    required DateTime date,
  }) {
    final onDay =
        all.where((e) => sameDay(e.date, date)).toList();
    final water = onDay.whereType<WaterEntry>().toList();
    final meals = onDay.whereType<FoodEntry>().toList();
    final cravings = onDay.whereType<SugarCravingEntry>().toList();

    List<WeightEntry> weights = onDay.whereType<WeightEntry>().toList();
    weights.sort((a, b) => a.date.compareTo(b.date));

    return DailySnapshot(
      date: date,
      sleep: onDay.whereType<SleepEntry>().firstOrNull,
      water: water,
      steps: onDay.whereType<StepEntry>().firstOrNull,
      cravings: cravings,
      supplements: onDay.whereType<SupplementEntry>().toList(),
      wellness: onDay.whereType<MentalWellnessEntry>().firstOrNull,
      meals: meals,
      weight: weights.isNotEmpty ? weights.last : null,
    );
  }

  // -------------------------------------------------------------------------
  // PERIOD (week / month) STATS
  // -------------------------------------------------------------------------

  static PeriodStats period({
    required List<HealthEntry> all,
    required DateTime start,
    required DateTime end,
  }) {
    final s = startOfDay(start);
    final e = startOfDay(end);

    final inPeriod = all
        .where((entry) =>
            !entry.date.isBefore(s) && !entry.date.isAfter(e))
        .toList();

    final days = <String>{};
    for (final entry in inPeriod) {
      days.add(healthDateKey(entry.date));
    }

    // Sleep: one value per day.
    final sleepByDay = <String, SleepEntry>{};
    for (final entry in inPeriod.whereType<SleepEntry>()) {
      sleepByDay[healthDateKey(entry.date)] = entry;
    }
    final sleepDays = sleepByDay.values.toList();
    final sleepQuality = <String, int>{};
    for (final entry in sleepDays) {
      sleepQuality[entry.quality] = (sleepQuality[entry.quality] ?? 0) + 1;
    }

    // Water: sum per day, then average across days.
    final waterPerDay = <String, double>{};
    for (final entry in inPeriod.whereType<WaterEntry>()) {
      waterPerDay[healthDateKey(entry.date)] =
          (waterPerDay[healthDateKey(entry.date)] ?? 0) + entry.quantityFlOz;
    }

    // Steps: one value per day.
    final stepsByDay = <String, StepEntry>{};
    for (final entry in inPeriod.whereType<StepEntry>()) {
      stepsByDay[healthDateKey(entry.date)] = entry;
    }

    // Wellness: one value per day.
    final wellnessByDay = <String, MentalWellnessEntry>{};
    for (final entry in inPeriod.whereType<MentalWellnessEntry>()) {
      wellnessByDay[healthDateKey(entry.date)] = entry;
    }
    final wellnessDays = wellnessByDay.values.toList();
    final moodDistribution = <String, int>{};
    for (final entry in wellnessDays) {
      moodDistribution[entry.mood] = (moodDistribution[entry.mood] ?? 0) + 1;
    }

    // Cravings.
    final cravingDaysSet = <String>{};
    final cravingLevelCounts = <String, int>{};
    for (final entry in inPeriod.whereType<SugarCravingEntry>()) {
      cravingDaysSet.add(healthDateKey(entry.date));
      cravingLevelCounts[entry.level] =
          (cravingLevelCounts[entry.level] ?? 0) + 1;
    }

    // Food.
    final foodEntries = inPeriod.whereType<FoodEntry>().toList();
    final foodTagFrequency = <String, int>{};
    final mealTypeCounts = <String, int>{};
    int favoriteCount = 0;
    for (final meal in foodEntries) {
      mealTypeCounts[meal.mealType] = (mealTypeCounts[meal.mealType] ?? 0) + 1;
      if (meal.isFavorite) favoriteCount++;
      for (final tag in meal.tags) {
        foodTagFrequency[tag] = (foodTagFrequency[tag] ?? 0) + 1;
      }
    }

    // Supplements.
    final supplementDaysSet = <String>{};
    int supplementCount = 0;
    for (final entry in inPeriod.whereType<SupplementEntry>()) {
      supplementDaysSet.add(healthDateKey(entry.date));
      supplementCount++;
    }

    // Weight history within the period.
    var weights = inPeriod.whereType<WeightEntry>().toList();
    weights.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
    });

    return PeriodStats(
      start: s,
      end: e,
      daysWithData: days.length,
      avgSleepMinutes: sleepDays.isEmpty
          ? null
          : sleepDays.map((x) => x.durationMinutes).reduce((a, b) => a + b) /
              sleepDays.length,
      sleepQualityDistribution: sleepQuality,
      avgWaterFlOz: waterPerDay.isEmpty
          ? null
          : waterPerDay.values.reduce((a, b) => a + b) / waterPerDay.length,
      avgSteps: stepsByDay.isEmpty
          ? null
          : stepsByDay.values
                  .map((x) => x.count)
                  .reduce((a, b) => a + b) /
              stepsByDay.length,
      avgStress: _avg(wellnessDays.map((x) => x.stressLevel.toDouble())),
      avgAnxiety: _avg(wellnessDays.map((x) => x.anxietyLevel.toDouble())),
      avgEnergy: _avg(wellnessDays.map((x) => x.energyLevel.toDouble())),
      moodDistribution: moodDistribution,
      cravingDays: cravingDaysSet.length,
      cravingCount: inPeriod.whereType<SugarCravingEntry>().length,
      cravingLevelCounts: cravingLevelCounts,
      foodTagFrequency: foodTagFrequency,
      mealCount: foodEntries.length,
      mealTypeCounts: mealTypeCounts,
      favoriteMealCount: favoriteCount,
      supplementCount: supplementCount,
      supplementDays: supplementDaysSet.length,
      firstWeight: weights.isNotEmpty ? weights.first : null,
      lastWeight: weights.isNotEmpty ? weights.last : null,
    );
  }

  static double? _avg(Iterable<double> values) {
    final list = values.toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a + b) / list.length;
  }

  // -------------------------------------------------------------------------
  // CONVENIENCE WINDOWS
  // -------------------------------------------------------------------------

  static PeriodStats thisWeek(List<HealthEntry> all, DateTime now) =>
      period(all: all, start: addDays(now, -6), end: now);

  static PeriodStats lastWeek(List<HealthEntry> all, DateTime now) =>
      period(all: all, start: addDays(now, -13), end: addDays(now, -7));

  static PeriodStats thisMonth(List<HealthEntry> all, DateTime now) =>
      period(all: all, start: firstOfMonth(now), end: now);

  static PeriodStats lastMonth(List<HealthEntry> all, DateTime now) =>
      period(all: all, start: firstOfPrevMonth(now), end: lastOfPrevMonth(now));

  /// Distinct days with any health data within the last [days] days.
  static int dataDaysLastDays(
    List<HealthEntry> all,
    DateTime now, {
    int days = 30,
  }) {
    return period(all: all, start: addDays(now, -(days - 1)), end: now)
        .daysWithData;
  }
}

/// Aggregated view of everything logged on a single date.
class DailySnapshot {
  final DateTime date;
  final SleepEntry? sleep;
  final List<WaterEntry> water;
  final StepEntry? steps;
  final List<SugarCravingEntry> cravings;
  final List<SupplementEntry> supplements;
  final MentalWellnessEntry? wellness;
  final List<FoodEntry> meals;
  final WeightEntry? weight;

  const DailySnapshot({
    required this.date,
    this.sleep,
    required this.water,
    this.steps,
    required this.cravings,
    required this.supplements,
    this.wellness,
    required this.meals,
    this.weight,
  });

  double get totalWaterFlOz => water.fold(0.0, (sum, w) => sum + w.quantityFlOz);

  double get totalWaterCups => totalWaterFlOz / 8;

  int get mealCount => meals.length;

  int get supplementCount => supplements.length;

  String? get topCravingLevel {
    if (cravings.isEmpty) return null;
    final ranked = ['High', 'Medium', 'Low'];
    for (final level in ranked) {
      if (cravings.any((c) => c.level == level)) return level;
    }
    return cravings.first.level;
  }
}

/// Structured statistics for a window of dates (week or month).
class PeriodStats {
  final DateTime start;
  final DateTime end;
  final int daysWithData;

  final double? avgSleepMinutes;
  final Map<String, int> sleepQualityDistribution;

  final double? avgWaterFlOz;

  final double? avgSteps;

  final double? avgStress;
  final double? avgAnxiety;
  final double? avgEnergy;
  final Map<String, int> moodDistribution;

  final int cravingDays;
  final int cravingCount;
  final Map<String, int> cravingLevelCounts;

  final Map<String, int> foodTagFrequency;
  final int mealCount;
  final Map<String, int> mealTypeCounts;
  final int favoriteMealCount;

  final int supplementCount;
  final int supplementDays;

  final WeightEntry? firstWeight;
  final WeightEntry? lastWeight;

  const PeriodStats({
    required this.start,
    required this.end,
    required this.daysWithData,
    this.avgSleepMinutes,
    this.sleepQualityDistribution = const {},
    this.avgWaterFlOz,
    this.avgSteps,
    this.avgStress,
    this.avgAnxiety,
    this.avgEnergy,
    this.moodDistribution = const {},
    this.cravingDays = 0,
    this.cravingCount = 0,
    this.cravingLevelCounts = const {},
    this.foodTagFrequency = const {},
    this.mealCount = 0,
    this.mealTypeCounts = const {},
    this.favoriteMealCount = 0,
    this.supplementCount = 0,
    this.supplementDays = 0,
    this.firstWeight,
    this.lastWeight,
  });

  /// Weight change across the period in kg (may be null when < 2 points).
  double? get weightChangeKg {
    final first = firstWeight;
    final last = lastWeight;
    if (first == null || last == null) return null;
    if (first.id == last.id) return null;
    return last.weightKg - first.weightKg;
  }
}