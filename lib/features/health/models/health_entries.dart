/// Health tracker entry models.
///
/// Every entry is owned by one authenticated user (`userId`) and is stored
/// against a calendar date (`date`). Multi-entry trackers (water, sugar
/// cravings, supplements, food, weight) allow several rows per day, while
/// single-entry trackers (sleep, steps, mental wellness) keep one row per
/// day and editing updates that row.
library;

/// The eight health trackers supported by SYNCO.
enum HealthTrackerType {
  sleep(
    collection: 'sleep_entries',
    label: 'Sleep',
    saveLabel: 'Save Sleep',
  ),
  water(
    collection: 'water_entries',
    label: 'Water Intake',
    saveLabel: 'Save Water Intake',
  ),
  steps(
    collection: 'step_entries',
    label: 'Step Count',
    saveLabel: 'Save Steps',
  ),
  sugarCravings(
    collection: 'sugar_craving_entries',
    label: 'Sugar Cravings',
    saveLabel: 'Save Craving',
  ),
  supplements(
    collection: 'supplement_entries',
    label: 'Supplements',
    saveLabel: 'Add Supplement',
  ),
  mentalWellness(
    collection: 'mental_wellness_entries',
    label: 'Mental Wellness',
    saveLabel: 'Save Wellness',
  ),
  food(
    collection: 'food_entries',
    label: 'Food & Nutrition',
    saveLabel: 'Save Meal',
  ),
  weight(
    collection: 'weight_entries',
    label: 'Weight',
    saveLabel: 'Save Weight',
  );

  final String collection;
  final String label;
  final String saveLabel;

  const HealthTrackerType({
    required this.collection,
    required this.label,
    required this.saveLabel,
  });
}

/// Shared quality scales used across trackers.
const List<String> kHealthQualityOptions = ['Poor', 'Okay', 'Good'];

/// Sleep factors that can be selected together.
const List<String> kSleepFactorOptions = [
  'Device in bed',
  'Earplugs',
  'Early bedtime',
  'Late bedtime',
  'Nap time',
];

/// Craving intensity scale.
const List<String> kCravingLevelOptions = ['Low', 'Medium', 'High'];

/// Meal type options.
const List<String> kMealTypeOptions = [
  'Breakfast',
  'Lunch',
  'Dinner',
  'Snack',
];

/// Built-in quick tags offered when logging a meal.
const List<String> kFoodTagOptions = [
  'Dairy',
  'Gluten',
  'Sugar',
  'Caffeine',
  'Alcohol',
  'Soya',
  'Processed Food',
  'Fried',
  'Spice',
  'Red Meat',
  'High Fiber',
  'Protein Rich',
  'Leafy Green',
  'Omega-3',
  'Berries',
  'Nuts',
  'Whole Grain',
  'Fish',
  'Cinnamon',
  'Turmeric',
  'Water',
  'Roti',
];

/// Mood options for the daily mental wellness entry.
const List<String> kMoodOptions = [
  'Happy',
  'Sad',
  'Calm',
  'Tired',
  'Energetic',
  'Angry',
  'Irritated',
];

/// Formats a date as `yyyy-MM-dd` for storage and range queries.
String healthDateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Parses a `yyyy-MM-dd` date key back into a [DateTime].
DateTime parseHealthDate(String key) => DateTime.parse(key);

/// Normalises a [DateTime] to its calendar date (local midnight).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Formats a duration in minutes as `7h 30m`.
String formatDurationMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

/// Minutes of the day (0..1439) for a [TimeOfDay]-like pair.
int minutesOfDay(int hour, int minute) => hour * 60 + minute;

abstract class HealthEntry {
  const HealthEntry();

  String get id;
  String get userId;
  DateTime get date;
  String get createdAt;
  String get updatedAt;

  Map<String, dynamic> toMap();
}

// ---------------------------------------------------------------------------
// SLEEP
// ---------------------------------------------------------------------------

class SleepEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final int startMinutes; // minutes of the day when sleep started
  final int endMinutes; // minutes of the day when the user woke up
  final int durationMinutes; // cross-midnight aware
  final String quality; // Poor | Okay | Good
  final List<String> factors;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const SleepEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.durationMinutes,
    required this.quality,
    required this.factors,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computes duration handling bedtime after midnight (e.g. 23:30 -> 07:00).
  static int computeDurationMinutes(int startMinutes, int endMinutes) {
    if (endMinutes == startMinutes) return 0;
    final duration = endMinutes > startMinutes
        ? endMinutes - startMinutes
        : (24 * 60 - startMinutes) + endMinutes;
    if (duration <= 0 || duration > 16 * 60) return 0;
    return duration;
  }

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      startMinutes: (map['start_minutes'] as num?)?.toInt() ?? 0,
      endMinutes: (map['end_minutes'] as num?)?.toInt() ?? 0,
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
      quality: map['quality'] as String? ?? '',
      factors: (map['factors'] as List?)?.cast<String>() ?? const [],
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'start_minutes': startMinutes,
      'end_minutes': endMinutes,
      'duration_minutes': durationMinutes,
      'quality': quality,
      'factors': factors,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// WATER
// ---------------------------------------------------------------------------

class WaterEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final double quantity;
  final String unit; // cups | fl oz
  final String hydrationLevel; // Poor | Okay | Good
  final int? timeMinutes; // minutes of the day when this glass was logged
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const WaterEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.quantity,
    required this.unit,
    required this.hydrationLevel,
    this.timeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  static const double cupsPerFlOz = 1 / 8;

  double get quantityFlOz =>
      unit == 'fl oz' ? quantity : quantity / cupsPerFlOz;

  double get quantityCups => unit == 'cups' ? quantity : quantity * cupsPerFlOz;

  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    return WaterEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'cups',
      hydrationLevel: map['hydration_level'] as String? ?? '',
      timeMinutes: (map['time_minutes'] as num?)?.toInt(),
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'quantity': quantity,
      'unit': unit,
      'hydration_level': hydrationLevel,
      'time_minutes': timeMinutes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// STEPS
// ---------------------------------------------------------------------------

class StepEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final int count;
  final String source; // manual | device (wearable sync ready)
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const StepEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.count,
    this.source = 'manual',
    required this.createdAt,
    required this.updatedAt,
  });

  factory StepEntry.fromMap(Map<String, dynamic> map) {
    return StepEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      count: (map['count'] as num?)?.toInt() ?? 0,
      source: map['source'] as String? ?? 'manual',
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'count': count,
      'source': source,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// SUGAR CRAVINGS
// ---------------------------------------------------------------------------

class SugarCravingEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final String craving;
  final String level; // Low | Medium | High
  final int? timeMinutes; // minutes of the day when the craving hit
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const SugarCravingEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.craving,
    required this.level,
    this.timeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SugarCravingEntry.fromMap(Map<String, dynamic> map) {
    return SugarCravingEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      craving: map['craving'] as String? ?? '',
      level: map['level'] as String? ?? '',
      timeMinutes: (map['time_minutes'] as num?)?.toInt(),
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'craving': craving,
      'level': level,
      'time_minutes': timeMinutes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// SUPPLEMENTS
// ---------------------------------------------------------------------------

class SupplementEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final String name;
  final int? timeMinutes; // minutes of the day when it was taken
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const SupplementEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.name,
    this.timeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplementEntry.fromMap(Map<String, dynamic> map) {
    return SupplementEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      name: map['name'] as String? ?? '',
      timeMinutes: (map['time_minutes'] as num?)?.toInt(),
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'name': name,
      'time_minutes': timeMinutes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// MENTAL WELLNESS
// ---------------------------------------------------------------------------

class MentalWellnessEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final int stressLevel; // 1..5
  final int anxietyLevel; // 1..5
  final int energyLevel; // 1..5
  final String sleepQuality; // Poor | Okay | Good
  final String mood;
  final int? timeMinutes; // minutes of the day of the check-in
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const MentalWellnessEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.stressLevel,
    required this.anxietyLevel,
    required this.energyLevel,
    required this.sleepQuality,
    required this.mood,
    this.timeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MentalWellnessEntry.fromMap(Map<String, dynamic> map) {
    return MentalWellnessEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      stressLevel: (map['stress_level'] as num?)?.toInt() ?? 0,
      anxietyLevel: (map['anxiety_level'] as num?)?.toInt() ?? 0,
      energyLevel: (map['energy_level'] as num?)?.toInt() ?? 0,
      sleepQuality: map['sleep_quality'] as String? ?? '',
      mood: map['mood'] as String? ?? '',
      timeMinutes: (map['time_minutes'] as num?)?.toInt(),
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'stress_level': stressLevel,
      'anxiety_level': anxietyLevel,
      'energy_level': energyLevel,
      'sleep_quality': sleepQuality,
      'mood': mood,
      'time_minutes': timeMinutes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// FOOD & NUTRITION
// ---------------------------------------------------------------------------

class FoodEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final String description;
  final String mealType; // Breakfast | Lunch | Dinner | Snack
  final List<String> tags;
  final bool isFavorite;
  final int? timeMinutes; // minutes of the day when the meal was eaten
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const FoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.description,
    required this.mealType,
    required this.tags,
    required this.isFavorite,
    this.timeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      description: map['description'] as String? ?? '',
      mealType: map['meal_type'] as String? ?? '',
      tags: (map['tags'] as List?)?.cast<String>() ?? const [],
      isFavorite: map['is_favorite'] as bool? ?? false,
      timeMinutes: (map['time_minutes'] as num?)?.toInt(),
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  /// A throwaway copy used to prefill the food form from a favourite meal.
  FoodEntry copyForFill() => FoodEntry(
        id: 'fill_${DateTime.now().microsecondsSinceEpoch}',
        userId: userId,
        date: DateTime.now(),
        description: description,
        mealType: mealType,
        tags: tags,
        isFavorite: isFavorite,
        createdAt: '',
        updatedAt: '',
      );

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'description': description,
      'meal_type': mealType,
      'tags': tags,
      'is_favorite': isFavorite,
      'time_minutes': timeMinutes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// WEIGHT
// ---------------------------------------------------------------------------

class WeightEntry extends HealthEntry {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final double weight;
  final String unit; // kg | lb
  @override
  final String createdAt;
  @override
  final String updatedAt;

  const WeightEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.weight,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts the stored value to kg for consistent trend math.
  double get weightKg => unit == 'kg' ? weight : weight * 0.45359237;

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      date: parseHealthDate(map['date'] as String),
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': healthDateKey(date),
      'weight': weight,
      'unit': unit,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}