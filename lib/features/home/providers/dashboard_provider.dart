import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/backend.dart';
import '../../../models/cycle_log.dart';
import '../../../models/symptom_log.dart';
import '../../auth/providers/auth_provider.dart';

// -----------------------------------------------------------------------------
// CYCLE STATE
// -----------------------------------------------------------------------------

class CycleState {
  final bool isLoading;
  final CycleLog? activeCycle;
  final int currentDay;
  final int daysUntilNextPeriod;
  final String currentPhase;

  const CycleState({
    this.isLoading = false,
    this.activeCycle,
    this.currentDay = 1,
    this.daysUntilNextPeriod = 28,
    this.currentPhase = 'Follicular Phase',
  });

  CycleState copyWith({
    bool? isLoading,
    CycleLog? activeCycle,
    int? currentDay,
    int? daysUntilNextPeriod,
    String? currentPhase,
  }) {
    return CycleState(
      isLoading: isLoading ?? this.isLoading,
      activeCycle: activeCycle ?? this.activeCycle,
      currentDay: currentDay ?? this.currentDay,
      daysUntilNextPeriod: daysUntilNextPeriod ?? this.daysUntilNextPeriod,
      currentPhase: currentPhase ?? this.currentPhase,
    );
  }
}

class CycleStateNotifier extends StateNotifier<CycleState> {
  final Ref ref;
  StreamSubscription? _subscription;

  CycleStateNotifier(this.ref) : super(const CycleState()) {
    _init();
  }

  void _init() {
    final user = ref.read(authNotifierProvider).user;
    if (user == null || Backend.firestore == null) {
      // Provide a mock default state if no user or backend
      state = state.copyWith(isLoading: false, currentDay: 8, daysUntilNextPeriod: 16);
      return;
    }

    state = state.copyWith(isLoading: true);

    _subscription = Backend.firestore!
        .collection('users')
        .doc(user.id)
        .collection('period_logs')
        .orderBy('start_date', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        
        final startDateStr = data['start_date'] as String;
        final startDate = DateTime.parse(startDateStr);
        final cycleLength = 28; // Default cycle length
        final periodLength = 5; // Default period length
        
        final now = DateTime.now();
        final diff = now.difference(startDate).inDays;
        final currentDay = diff >= 0 ? diff + 1 : 1;
        
        final expectedNextDate = startDate.add(Duration(days: cycleLength));
        final daysUntil = expectedNextDate.difference(now).inDays;
        
        String phase = 'Follicular Phase';
        if (currentDay <= periodLength) {
          phase = 'Menstrual Phase';
        } else if (currentDay >= cycleLength - 14 && currentDay <= cycleLength - 12) {
          phase = 'Ovulation Phase';
        } else if (currentDay > cycleLength - 12) {
          phase = 'Luteal Phase';
        }

        // We use a mock CycleLog since we don't have all data in period_logs
        final activeCycle = CycleLog(
          id: doc.id,
          startDate: startDate,
          cycleLength: cycleLength,
          periodLength: periodLength,
        );

        state = state.copyWith(
          isLoading: false,
          activeCycle: activeCycle,
          currentDay: currentDay,
          daysUntilNextPeriod: daysUntil > 0 ? daysUntil : 0,
          currentPhase: phase,
        );
      } else {
        // No logs found, use safe defaults
        state = state.copyWith(isLoading: false, currentDay: 1, daysUntilNextPeriod: 28, currentPhase: 'Follicular Phase');
      }
    }, onError: (_) {
      state = state.copyWith(isLoading: false);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final cycleProvider = StateNotifierProvider<CycleStateNotifier, CycleState>((ref) {
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
    this.score = 85, // Base mock score
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
  StreamSubscription? _subscription;

  HealthScoreNotifier(this.ref) : super(const HealthScoreState()) {
    _init();
  }

  void _init() {
    final user = ref.read(authNotifierProvider).user;
    if (user == null || Backend.firestore == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    // Fetch the last 7 days of symptom logs to calculate score
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    _subscription = Backend.firestore!
        .collection('users')
        .doc(user.id)
        .collection('symptom_logs')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .snapshots()
        .listen((snapshot) {
      int baseScore = 85;
      
      for (var doc in snapshot.docs) {
        final log = SymptomLog.fromMap(doc.id, doc.data());
        // For each log, if there is a severe symptom, decrease score slightly
        log.symptoms.forEach((key, value) {
          if (value == 'severe' || value == 'high') {
            baseScore -= 2;
          } else if (value == 'moderate') {
            baseScore -= 1;
          }
        });
      }

      // Keep score between 0 and 100
      baseScore = baseScore.clamp(0, 100);
      
      state = state.copyWith(
        isLoading: false,
        score: baseScore,
        percentile: (baseScore * 0.9).toInt(), // Simplified mock percentile
      );
    }, onError: (_) {
      state = state.copyWith(isLoading: false);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final healthScoreProvider = StateNotifierProvider<HealthScoreStateNotifier, HealthScoreState>((ref) {
  return HealthScoreNotifier(ref);
});

// Alias for provider
typedef HealthScoreStateNotifier = HealthScoreNotifier;
