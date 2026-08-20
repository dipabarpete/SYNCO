import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/backend.dart';
import '../../../models/cycle_log.dart';
import '../../../models/cycle_data.dart';
import '../../../models/symptom_log.dart';
import '../../../models/period_record.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cycle/services/cycle_calculation_service.dart';
import '../../cycle/services/period_repository.dart';

// -----------------------------------------------------------------------------
// CYCLE STATE
// -----------------------------------------------------------------------------

class CycleState {
  final bool isLoading;
  final bool hasHistory;
  final CycleLog? activeCycle;
  final int currentDay;
  final int totalDays;
  final int daysUntilNextPeriod;
  final String currentPhase;
  final String fertilityWindow;
  final int daysUntilOvulation;

  const CycleState({
    this.isLoading = false,
    this.hasHistory = false,
    this.activeCycle,
    this.currentDay = 1,
    this.totalDays = 28,
    this.daysUntilNextPeriod = 28,
    this.currentPhase = 'Follicular Phase',
    this.fertilityWindow = 'Days 11–16',
    this.daysUntilOvulation = 6,
  });

  CycleState copyWith({
    bool? isLoading,
    bool? hasHistory,
    CycleLog? activeCycle,
    int? currentDay,
    int? totalDays,
    int? daysUntilNextPeriod,
    String? currentPhase,
    String? fertilityWindow,
    int? daysUntilOvulation,
  }) {
    return CycleState(
      isLoading: isLoading ?? this.isLoading,
      hasHistory: hasHistory ?? this.hasHistory,
      activeCycle: activeCycle ?? this.activeCycle,
      currentDay: currentDay ?? this.currentDay,
      totalDays: totalDays ?? this.totalDays,
      daysUntilNextPeriod: daysUntilNextPeriod ?? this.daysUntilNextPeriod,
      currentPhase: currentPhase ?? this.currentPhase,
      fertilityWindow: fertilityWindow ?? this.fertilityWindow,
      daysUntilOvulation: daysUntilOvulation ?? this.daysUntilOvulation,
    );
  }
}

class CycleStateNotifier extends StateNotifier<CycleState> {
  final Ref ref;
  StreamSubscription? _subscription;
  final CycleCalculationService _calculationService = CycleCalculationService();

  CycleStateNotifier(this.ref) : super(const CycleState()) {
    init();
  }

  void init() {
    _subscription?.cancel();
    final user = ref.read(authNotifierProvider).user;
    if (user == null || Backend.firestore == null) {
      state = state.copyWith(
        isLoading: false,
        hasHistory: false,
        currentDay: 1,
        totalDays: 28,
        daysUntilNextPeriod: 28,
        currentPhase: 'Follicular Phase',
        fertilityWindow: 'Days 11–16',
        daysUntilOvulation: 6,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final repository = PeriodRepository();
      _subscription = repository.streamPeriods().listen((records) {
        if (!mounted) return;
        _updateWithRecords(records);
      }, onError: (e) {
        debugPrint('[dashboard_provider] period stream error: $e');
        if (mounted) {
          state = state.copyWith(isLoading: false);
        }
      });
    } catch (e) {
      debugPrint('[dashboard_provider] init exception: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void _updateWithRecords(List<PeriodRecord> records) {
    if (records.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        hasHistory: false,
        currentDay: 1,
        totalDays: 28,
        daysUntilNextPeriod: 28,
        currentPhase: 'Follicular Phase',
        fertilityWindow: 'Days 11–16',
        daysUntilOvulation: 6,
      );
      return;
    }

    final insights = _calculationService.computeInsights(records);
    final now = DateTime.now();

    int daysUntilOvulation = 0;
    if (insights.estimatedOvulation != null) {
      final diff = insights.estimatedOvulation!.difference(now).inDays;
      daysUntilOvulation = diff > 0 ? diff : 0;
    }

    String fertilityWindowStr = 'Days 11–16';
    if (insights.fertileWindowStart != null && insights.fertileWindowEnd != null) {
      fertilityWindowStr =
          'Days ${insights.fertileWindowStart!.day}–${insights.fertileWindowEnd!.day}';
    }

    final activeCycle = CycleLog(
      id: records.first.id,
      startDate: insights.lastPeriodStartDate ?? now,
      cycleLength: insights.averageCycleLength,
      periodLength: insights.averagePeriodDuration,
    );

    state = state.copyWith(
      isLoading: false,
      hasHistory: insights.hasHistory,
      activeCycle: activeCycle,
      currentDay: insights.currentDayOfCycle,
      totalDays: insights.averageCycleLength,
      daysUntilNextPeriod: (insights.daysUntilNextPeriod ?? 0).clamp(0, 999),
      currentPhase: insights.currentPhase.displayName,
      fertilityWindow: fertilityWindowStr,
      daysUntilOvulation: daysUntilOvulation,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final cycleProvider =
    StateNotifierProvider<CycleStateNotifier, CycleState>((ref) {
  return CycleStateNotifier(ref);
});

// -----------------------------------------------------------------------------
// HEALTH SCORE STATE
// -----------------------------------------------------------------------------

class HealthScoreState {
  final bool isLoading;
  final int score;
  final int percentile;

  const HealthScoreState({
    this.isLoading = false,
    this.score = 85,
    this.percentile = 75,
  });

  HealthScoreState copyWith({
    bool? isLoading,
    int? score,
    int? percentile,
  }) {
    return HealthScoreState(
      isLoading: isLoading ?? this.isLoading,
      score: score ?? this.score,
      percentile: percentile ?? this.percentile,
    );
  }
}

class HealthScoreNotifier extends StateNotifier<HealthScoreState> {
  final Ref ref;
  StreamSubscription? _symptomSub;
  StreamSubscription? _dailyLogsSub;

  HealthScoreNotifier(this.ref) : super(const HealthScoreState()) {
    init();
  }

  void init() {
    _symptomSub?.cancel();
    _dailyLogsSub?.cancel();

    final user = ref.read(authNotifierProvider).user;
    if (user == null || Backend.firestore == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    final db = Backend.firestore!;
    final fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));
    final fourteenDaysAgoTimestamp = Timestamp.fromDate(fourteenDaysAgo);

    // Stream general symptom_logs
    _symptomSub = db
        .collection('users')
        .doc(user.id)
        .collection('symptom_logs')
        .where('date', isGreaterThanOrEqualTo: fourteenDaysAgoTimestamp)
        .snapshots()
        .listen((symptomSnap) {
      _recalculateScore(user.id, symptomSnap.docs);
    }, onError: (e) {
      debugPrint('[dashboard_provider] symptom_logs score error: $e');
      if (mounted) state = state.copyWith(isLoading: false);
    });

    // Also listen to daily_logs for real-time cycle/pain tracker additions
    _dailyLogsSub = db
        .collection('users')
        .doc(user.id)
        .collection('daily_logs')
        .snapshots()
        .listen((_) {
      // Re-trigger calculation on daily log updates
      final currentSymptomSnapDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      _recalculateScore(user.id, currentSymptomSnapDocs);
    }, onError: (_) {});
  }

  Future<void> _recalculateScore(
    String userId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> symptomDocs,
  ) async {
    try {
      int baseScore = 85;
      bool hasActiveTracking = symptomDocs.isNotEmpty;

      // 1. Symptom log deductions
      for (var doc in symptomDocs) {
        final data = doc.data();
        final log = SymptomLog.fromMap(doc.id, data);
        log.symptoms.forEach((key, value) {
          final v = value.toString().toLowerCase();
          if (v == 'severe' || v == 'high') {
            baseScore -= 2;
          } else if (v == 'moderate') {
            baseScore -= 1;
          }
        });
      }

      // 2. Daily logs tracking bonus & pain deductions
      final db = Backend.firestore;
      if (db != null) {
        final dailyLogsSnap = await db
            .collection('users')
            .doc(userId)
            .collection('daily_logs')
            .limit(14)
            .get();

        if (dailyLogsSnap.docs.isNotEmpty) {
          hasActiveTracking = true;
          for (var doc in dailyLogsSnap.docs) {
            final data = doc.data();
            final periodMap = data['period_logs'];
            if (periodMap is Map) {
              for (var val in periodMap.values) {
                if (val is Map) {
                  final pain = val['pain_level'] as num?;
                  if (pain != null && pain >= 7) {
                    baseScore -= 2;
                  } else if (pain != null && pain >= 4) {
                    baseScore -= 1;
                  }
                }
              }
            }
          }
        }

        // 3. Health Entries check (Sleep, Water, Stress)
        final healthEntriesSnap = await db
            .collection('users')
            .doc(userId)
            .collection('health_entries')
            .get();

        for (var doc in healthEntriesSnap.docs) {
          hasActiveTracking = true;
          final cat = doc.id.toLowerCase();
          final data = doc.data();
          if (cat == 'sleep') {
            final hours = (data['val'] ?? data['hours'] ?? data['value']) as num?;
            if (hours != null) {
              if (hours >= 7.0) baseScore += 2;
              if (hours < 5.0) baseScore -= 2;
            }
          } else if (cat == 'water') {
            final liters = (data['val'] ?? data['liters'] ?? data['value']) as num?;
            if (liters != null && liters >= 2.0) {
              baseScore += 2;
            }
          } else if (cat == 'stress') {
            final level = (data['val'] ?? data['level'] ?? data['value']) as num?;
            if (level != null) {
              if (level <= 30) baseScore += 2;
              if (level >= 70) baseScore -= 2;
            }
          }
        }
      }

      // Active logging bonus
      if (hasActiveTracking) {
        baseScore += 3;
      }

      final score = baseScore.clamp(0, 100);
      final percentile = (score * 0.9).round();

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          score: score,
          percentile: percentile,
        );
      }
    } catch (e) {
      debugPrint('[dashboard_provider] score recalculation error: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  @override
  void dispose() {
    _symptomSub?.cancel();
    _dailyLogsSub?.cancel();
    super.dispose();
  }
}

final healthScoreProvider =
    StateNotifierProvider<HealthScoreStateNotifier, HealthScoreState>((ref) {
  return HealthScoreStateNotifier(ref);
});

typedef HealthScoreStateNotifier = HealthScoreNotifier;
