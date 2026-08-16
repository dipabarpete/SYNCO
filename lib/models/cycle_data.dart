enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}

extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Period flow, rest, replenish iron & hydration.';
      case CyclePhase.follicular:
        return 'Energy rising, high focus, great time for workouts.';
      case CyclePhase.ovulation:
        return 'Peak fertility, vibrant energy, glowing skin.';
      case CyclePhase.luteal:
        return 'Pre-menstrual prep, light exercise, self-care.';
    }
  }
}

class DailySymptomLog {
  final DateTime date;
  final List<String> symptoms; // e.g., Cramps, Bloating, Acne, Fatigue
  final String flowLevel; // Light, Medium, Heavy, Spotting, None
  final int painScale; // 0 - 5
  final String mood; // Happy, Calm, Anxious, Moody, Tired

  // Extended fields persisted with the period record (date-linked).
  final List<String> moods;
  final String? discharge;
  final List<String> digestion;
  final List<String> otherFactors;

  DailySymptomLog({
    required this.date,
    required this.symptoms,
    required this.flowLevel,
    required this.painScale,
    required this.mood,
    this.moods = const [],
    this.discharge,
    this.digestion = const [],
    this.otherFactors = const [],
  });
}

class CycleData {
  final DateTime lastPeriodStartDate;
  final int cycleLengthDays; // e.g. 28
  final int periodDurationDays; // e.g. 5
  final int currentDayOfCycle; // e.g. 12
  final CyclePhase currentPhase;
  final int daysUntilNextPeriod;
  final DateTime ovulationDate;
  final List<DateTime> fertilityWindow;
  final List<DailySymptomLog> symptomLogs;

  CycleData({
    required this.lastPeriodStartDate,
    this.cycleLengthDays = 28,
    this.periodDurationDays = 5,
    this.currentDayOfCycle = 12,
    this.currentPhase = CyclePhase.follicular,
    this.daysUntilNextPeriod = 14,
    required this.ovulationDate,
    required this.fertilityWindow,
    required this.symptomLogs,
  });

  factory CycleData.defaultData() {
    final now = DateTime.now();
    final lastPeriod = now.subtract(const Duration(days: 11)); // Day 12 of cycle
    final ovulation = lastPeriod.add(const Duration(days: 14));
    
    final fertility = [
      ovulation.subtract(const Duration(days: 3)),
      ovulation.subtract(const Duration(days: 2)),
      ovulation.subtract(const Duration(days: 1)),
      ovulation,
      ovulation.add(const Duration(days: 1)),
    ];

    return CycleData(
      lastPeriodStartDate: lastPeriod,
      cycleLengthDays: 28,
      periodDurationDays: 5,
      currentDayOfCycle: 12,
      currentPhase: CyclePhase.follicular,
      daysUntilNextPeriod: 16,
      ovulationDate: ovulation,
      fertilityWindow: fertility,
      symptomLogs: [
        DailySymptomLog(
          date: now,
          symptoms: ['Mild Cramps', 'Glowing Skin'],
          flowLevel: 'None',
          painScale: 1,
          mood: 'Energetic',
        )
      ],
    );
  }
}
