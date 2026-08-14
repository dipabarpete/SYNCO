import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_health_data_repository.dart';
import '../models/ai_insight.dart';
import '../models/health_entries.dart';
import '../services/ai_pattern_service.dart';

/// State for all health tracker entries belonging to the signed-in user.
class HealthDataState {
  final bool isLoading;
  final String? errorMessage;

  final List<SleepEntry> sleep;
  final List<WaterEntry> water;
  final List<StepEntry> steps;
  final List<SugarCravingEntry> sugarCravings;
  final List<SupplementEntry> supplements;
  final List<MentalWellnessEntry> wellness;
  final List<FoodEntry> food;
  final List<WeightEntry> weight;

  const HealthDataState({
    this.isLoading = false,
    this.errorMessage,
    this.sleep = const [],
    this.water = const [],
    this.steps = const [],
    this.sugarCravings = const [],
    this.supplements = const [],
    this.wellness = const [],
    this.food = const [],
    this.weight = const [],
  });

  HealthDataState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SleepEntry>? sleep,
    List<WaterEntry>? water,
    List<StepEntry>? steps,
    List<SugarCravingEntry>? sugarCravings,
    List<SupplementEntry>? supplements,
    List<MentalWellnessEntry>? wellness,
    List<FoodEntry>? food,
    List<WeightEntry>? weight,
  }) {
    return HealthDataState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sleep: sleep ?? this.sleep,
      water: water ?? this.water,
      steps: steps ?? this.steps,
      sugarCravings: sugarCravings ?? this.sugarCravings,
      supplements: supplements ?? this.supplements,
      wellness: wellness ?? this.wellness,
      food: food ?? this.food,
      weight: weight ?? this.weight,
    );
  }

  List<HealthEntry> get allEntries => <HealthEntry>[
        ...sleep,
        ...water,
        ...steps,
        ...sugarCravings,
        ...supplements,
        ...wellness,
        ...food,
        ...weight,
      ];

  List<SleepEntry> sleepOn(DateTime date) =>
      sleep.where((e) => sameDay(e.date, date)).toList();

  List<WaterEntry> waterOn(DateTime date) =>
      water.where((e) => sameDay(e.date, date)).toList();

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

final healthRepositoryProvider = Provider<HealthDataRepository>((ref) {
  return LocalHealthDataRepository();
});

final healthDataProvider =
    StateNotifierProvider<HealthDataNotifier, HealthDataState>((ref) {
  return HealthDataNotifier(ref.read(healthRepositoryProvider));
});

/// AI insights recomputed from the user's stored health data whenever any
/// health entry changes.
final aiInsightsProvider = Provider<List<AiInsight>>((ref) {
  final data = ref.watch(healthDataProvider);
  return const AiPatternService().detect(all: data.allEntries);
});

class HealthDataNotifier extends StateNotifier<HealthDataState> {
  final HealthDataRepository _repository;

  HealthDataNotifier(this._repository) : super(const HealthDataState());

  /// Loads every tracker for the signed-in user, newest date first.
  Future<void> loadAll() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _repository.fetch(HealthTrackerType.sleep).then((rows) =>
            rows.map((m) => SleepEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.water).then((rows) =>
            rows.map((m) => WaterEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.steps).then((rows) =>
            rows.map((m) => StepEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.sugarCravings).then((rows) =>
            rows.map((m) => SugarCravingEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.supplements).then((rows) =>
            rows.map((m) => SupplementEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.mentalWellness).then((rows) =>
            rows.map((m) => MentalWellnessEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.food).then(
            (rows) => rows.map((m) => FoodEntry.fromMap(m)).toList()),
        _repository.fetch(HealthTrackerType.weight).then(
            (rows) => rows.map((m) => WeightEntry.fromMap(m)).toList()),
      ]);

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        sleep: results[0] as List<SleepEntry>,
        water: results[1] as List<WaterEntry>,
        steps: results[2] as List<StepEntry>,
        sugarCravings: results[3] as List<SugarCravingEntry>,
        supplements: results[4] as List<SupplementEntry>,
        wellness: results[5] as List<MentalWellnessEntry>,
        food: results[6] as List<FoodEntry>,
        weight: results[7] as List<WeightEntry>,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load your health data: $e',
      );
    }
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  static List<T> _sortedByDateDesc<T extends HealthEntry>(Iterable<T> items) {
    final list = items.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static String _nowIso() => DateTime.now().toIso8601String();

  String? _formatError(Object e) {
    debugPrint('[health] provider error: $e');
    if (e is StateError) return e.message;
    return 'Something went wrong. Please try again. ($e)';
  }

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (e) {
      return _formatError(e);
    }
  }

  // -------------------------------------------------------------------------
  // SLEEP
  // -------------------------------------------------------------------------

  Future<String?> saveSleep({
    SleepEntry? existing,
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required int durationMinutes,
    required String quality,
    required List<String> factors,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'start_minutes': startMinutes,
        'end_minutes': endMinutes,
        'duration_minutes': durationMinutes,
        'quality': quality,
        'factors': factors,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored =
            await _repository.create(HealthTrackerType.sleep, base);
        state = state.copyWith(
          sleep: _sortedByDateDesc([...state.sleep, SleepEntry.fromMap(stored)]),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.sleep,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = SleepEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          sleep: state.sleep.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      }
    });
  }

  Future<String?> deleteSleep(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.sleep, id);
      state = state.copyWith(
        sleep: state.sleep.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // WATER
  // -------------------------------------------------------------------------

  Future<String?> saveWater({
    WaterEntry? existing,
    required DateTime date,
    required double quantity,
    required String unit,
    required String hydrationLevel,
    int? timeMinutes,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'quantity': quantity,
        'unit': unit,
        'hydration_level': hydrationLevel,
        'time_minutes': timeMinutes,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored =
            await _repository.create(HealthTrackerType.water, base);
        state = state.copyWith(
          water: _sortedByDateDesc([...state.water, WaterEntry.fromMap(stored)]),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.water,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = WaterEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          water: state.water.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      }
    });
  }

  Future<String?> deleteWater(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.water, id);
      state = state.copyWith(
        water: state.water.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // STEPS
  // -------------------------------------------------------------------------

  Future<String?> saveSteps({
    StepEntry? existing,
    required DateTime date,
    required int count,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'count': count,
        'source': 'manual',
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored = await _repository.create(HealthTrackerType.steps, base);
        state = state.copyWith(
          steps: _sortedByDateDesc([...state.steps, StepEntry.fromMap(stored)]),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.steps,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = StepEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          steps: state.steps.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      }
    });
  }

  Future<String?> deleteSteps(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.steps, id);
      state = state.copyWith(
        steps: state.steps.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // SUGAR CRAVINGS
  // -------------------------------------------------------------------------

  Future<String?> saveSugarCraving({
    SugarCravingEntry? existing,
    required DateTime date,
    required String craving,
    required String level,
    int? timeMinutes,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'craving': craving,
        'level': level,
        'time_minutes': timeMinutes,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored = await _repository.create(
          HealthTrackerType.sugarCravings,
          base,
        );
        state = state.copyWith(
          sugarCravings: _sortedByDateDesc(
            [...state.sugarCravings, SugarCravingEntry.fromMap(stored)],
          ),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.sugarCravings,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = SugarCravingEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          sugarCravings: state.sugarCravings
              .map((e) => e.id == updated.id ? updated : e)
              .toList(),
        );
      }
    });
  }

  Future<String?> deleteSugarCraving(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.sugarCravings, id);
      state = state.copyWith(
        sugarCravings:
            state.sugarCravings.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // SUPPLEMENTS
  // -------------------------------------------------------------------------

  Future<String?> saveSupplement({
    SupplementEntry? existing,
    required DateTime date,
    required String name,
    int? timeMinutes,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'name': name,
        'time_minutes': timeMinutes,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored = await _repository.create(
          HealthTrackerType.supplements,
          base,
        );
        state = state.copyWith(
          supplements: _sortedByDateDesc(
            [...state.supplements, SupplementEntry.fromMap(stored)],
          ),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.supplements,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = SupplementEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          supplements: state.supplements
              .map((e) => e.id == updated.id ? updated : e)
              .toList(),
        );
      }
    });
  }

  Future<String?> deleteSupplement(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.supplements, id);
      state = state.copyWith(
        supplements: state.supplements.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // MENTAL WELLNESS
  // -------------------------------------------------------------------------

  Future<String?> saveWellness({
    MentalWellnessEntry? existing,
    required DateTime date,
    required int stressLevel,
    required int anxietyLevel,
    required int energyLevel,
    required String sleepQuality,
    required String mood,
    int? timeMinutes,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'stress_level': stressLevel,
        'anxiety_level': anxietyLevel,
        'energy_level': energyLevel,
        'sleep_quality': sleepQuality,
        'mood': mood,
        'time_minutes': timeMinutes,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored = await _repository.create(
          HealthTrackerType.mentalWellness,
          base,
        );
        state = state.copyWith(
          wellness: _sortedByDateDesc(
            [...state.wellness, MentalWellnessEntry.fromMap(stored)],
          ),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.mentalWellness,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = MentalWellnessEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          wellness: state.wellness
              .map((e) => e.id == updated.id ? updated : e)
              .toList(),
        );
      }
    });
  }

  Future<String?> deleteWellness(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.mentalWellness, id);
      state = state.copyWith(
        wellness: state.wellness.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // FOOD & NUTRITION
  // -------------------------------------------------------------------------

  Future<String?> saveFood({
    FoodEntry? existing,
    required DateTime date,
    required String description,
    required String mealType,
    required List<String> tags,
    required bool isFavorite,
    int? timeMinutes,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'description': description,
        'meal_type': mealType,
        'tags': tags,
        'is_favorite': isFavorite,
        'time_minutes': timeMinutes,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored = await _repository.create(HealthTrackerType.food, base);
        state = state.copyWith(
          food: _sortedByDateDesc([...state.food, FoodEntry.fromMap(stored)]),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.food,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = FoodEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          food: state.food.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      }
    });
  }

  Future<String?> deleteFood(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.food, id);
      state = state.copyWith(
        food: state.food.where((e) => e.id != id).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // WEIGHT
  // -------------------------------------------------------------------------

  Future<String?> saveWeight({
    WeightEntry? existing,
    required DateTime date,
    required double weight,
    required String unit,
  }) {
    return _run(() async {
      final now = _nowIso();
      final base = <String, dynamic>{
        'date': healthDateKey(date),
        'weight': weight,
        'unit': unit,
      };
      if (existing == null) {
        base['created_at'] = now;
        base['updated_at'] = now;
        final stored =
            await _repository.create(HealthTrackerType.weight, base);
        state = state.copyWith(
          weight: _sortedByDateDesc([...state.weight, WeightEntry.fromMap(stored)]),
        );
      } else {
        final stored = await _repository.update(
          HealthTrackerType.weight,
          existing.id,
          {...base, 'updated_at': now},
        );
        final updated = WeightEntry.fromMap(
          <String, dynamic>{
            'id': existing.id,
            'user_id': existing.userId,
            ...stored,
          },
        );
        state = state.copyWith(
          weight: state.weight.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      }
    });
  }

  Future<String?> deleteWeight(String id) {
    return _run(() async {
      await _repository.delete(HealthTrackerType.weight, id);
      state = state.copyWith(
        weight: state.weight.where((e) => e.id != id).toList(),
      );
    });
  }
}