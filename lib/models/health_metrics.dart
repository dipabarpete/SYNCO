class HealthMetrics {
  final double weightKg;
  final double targetWeightKg;
  final double sleepHours;
  final double targetSleepHours;
  final double waterIntakeLiters;
  final double targetWaterLiters;
  final String acneStatus; // Mild, Clear, Moderate, Severe
  final int stressScorePercent; // 0 - 100
  final String sugarCravingsLevel; // Low, Moderate, High
  final int stepsCount;
  final int targetSteps;
  final int symptomsLoggedToday;
  final bool supplementsTaken;
  final bool healthyFoodHabitsLogged;
  final bool periodLoggedThisCycle;

  const HealthMetrics({
    this.weightKg = 54.5,
    this.targetWeightKg = 55.0,
    this.sleepHours = 7.8,
    this.targetSleepHours = 8.0,
    this.waterIntakeLiters = 2.1,
    this.targetWaterLiters = 2.5,
    this.acneStatus = 'Mild',
    this.stressScorePercent = 25,
    this.sugarCravingsLevel = 'Low',
    this.stepsCount = 6420,
    this.targetSteps = 8000,
    this.symptomsLoggedToday = 2,
    this.supplementsTaken = true,
    this.healthyFoodHabitsLogged = true,
    this.periodLoggedThisCycle = true,
  });

  /// Dynamic Health Score Algorithm (0 to 100)
  /// Calculates score based on sleep, water intake, stress, exercise, weight, period logs, symptoms, supplements, food habits
  int get calculatedScore {
    double score = 0.0;

    // Sleep contribution (Max 15 points)
    final sleepRatio = (sleepHours / targetSleepHours).clamp(0.0, 1.0);
    score += sleepRatio * 15;

    // Water Intake contribution (Max 15 points)
    final waterRatio = (waterIntakeLiters / targetWaterLiters).clamp(0.0, 1.0);
    score += waterRatio * 15;

    // Stress contribution (Lower is better, Max 15 points)
    final stressFactor = (100 - stressScorePercent) / 100.0;
    score += stressFactor * 15;

    // Steps / Exercise contribution (Max 15 points)
    final stepsRatio = (stepsCount / targetSteps).clamp(0.0, 1.0);
    score += stepsRatio * 15;

    // Period Logs & Symptom Tracking (Max 10 points)
    if (periodLoggedThisCycle) score += 5;
    if (symptomsLoggedToday > 0) score += 5;

    // Supplements (Max 10 points)
    if (supplementsTaken) score += 10;

    // Food Habits & Sugar Control (Max 10 points)
    if (healthyFoodHabitsLogged) score += 6;
    if (sugarCravingsLevel == 'Low') score += 4;

    // Acne / Skin Health (Max 10 points)
    if (acneStatus == 'Clear') {
      score += 10;
    } else if (acneStatus == 'Mild') {
      score += 7;
    } else {
      score += 4;
    }

    return score.round().clamp(0, 100);
  }

  HealthMetrics copyWith({
    double? weightKg,
    double? targetWeightKg,
    double? sleepHours,
    double? targetSleepHours,
    double? waterIntakeLiters,
    double? targetWaterLiters,
    String? acneStatus,
    int? stressScorePercent,
    String? sugarCravingsLevel,
    int? stepsCount,
    int? targetSteps,
    int? symptomsLoggedToday,
    bool? supplementsTaken,
    bool? healthyFoodHabitsLogged,
    bool? periodLoggedThisCycle,
  }) {
    return HealthMetrics(
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      sleepHours: sleepHours ?? this.sleepHours,
      targetSleepHours: targetSleepHours ?? this.targetSleepHours,
      waterIntakeLiters: waterIntakeLiters ?? this.waterIntakeLiters,
      targetWaterLiters: targetWaterLiters ?? this.targetWaterLiters,
      acneStatus: acneStatus ?? this.acneStatus,
      stressScorePercent: stressScorePercent ?? this.stressScorePercent,
      sugarCravingsLevel: sugarCravingsLevel ?? this.sugarCravingsLevel,
      stepsCount: stepsCount ?? this.stepsCount,
      targetSteps: targetSteps ?? this.targetSteps,
      symptomsLoggedToday: symptomsLoggedToday ?? this.symptomsLoggedToday,
      supplementsTaken: supplementsTaken ?? this.supplementsTaken,
      healthyFoodHabitsLogged:
          healthyFoodHabitsLogged ?? this.healthyFoodHabitsLogged,
      periodLoggedThisCycle:
          periodLoggedThisCycle ?? this.periodLoggedThisCycle,
    );
  }
}
