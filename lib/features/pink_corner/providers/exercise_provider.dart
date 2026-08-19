import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_achievements.dart';
import '../services/exercise_local_store.dart';

/// Holds the user's real movement activity in memory and derives the streak
/// and achievement unlocks from it.
///
/// Achievements are only ever unlocked by [logSession] — which is only called
/// when a movement session is actually completed. No activity data is ever
/// invented.
class ExerciseProgressController extends ChangeNotifier {
  List<ExerciseSession> _sessions = const [];
  Set<String> _unlocked = {};

  List<ExerciseSession> get sessions => _sessions;
  Set<String> get unlocked => _unlocked;

  ExerciseStreak get streak => ExerciseLocalStore.computeStreak(_sessions);

  /// Total number of completed movement sessions.
  int get sessionCount => _sessions.length;

  /// Total movement minutes from completed sessions.
  int get totalMinutes =>
      _sessions.fold(0, (sum, s) => sum + s.durationMinutes);

  bool isUnlocked(String id) => _unlocked.contains(id);

  /// Loads stored sessions and unlocks from the device.
  Future<void> refresh() async {
    _sessions = await ExerciseLocalStore.loadSessions();
    _unlocked = await ExerciseLocalStore.loadUnlockedAchievements();
    _unlocked = _unlocked.union(_newlyEligibleIds());
    notifyListeners();
  }

  /// Records a genuinely completed movement session and unlocks any
  /// achievements the user has now earned.
  ///
  /// Returns the achievements that were just unlocked (empty if none).
  Future<List<ExerciseAchievement>> logSession({
    required String activityType,
    required int durationMinutes,
    String? workoutId,
  }) async {
    final now = DateTime.now();
    final session = ExerciseSession(
      id: 'local_${now.microsecondsSinceEpoch}',
      date: now,
      activityType: activityType,
      durationMinutes: durationMinutes,
      workoutId: workoutId,
      createdAt: now,
    );

    await ExerciseLocalStore.saveSession(session);
    _sessions = [session, ..._sessions];

    final justUnlocked = _newlyEligibleIds();
    if (justUnlocked.isNotEmpty) {
      _unlocked = _unlocked.union(justUnlocked);
      await ExerciseLocalStore.saveUnlockedAchievements(_unlocked);
    }

    notifyListeners();

    return exerciseAchievements
        .where((a) => justUnlocked.contains(a.id))
        .toList(growable: false);
  }

  /// Achievement ids that are now earned but not yet unlocked.
  Set<String> _newlyEligibleIds() {
    final streak = this.streak;
    final result = <String>{};

    if (sessions.isNotEmpty) result.add('first-movement');
    if (streak.current >= 3) result.add('streak-3');
    if (streak.current >= 7) result.add('streak-7');
    if (sessions.length >= 10) result.add('sessions-10');
    if (sessions.any((s) => s.activityType == 'strength')) {
      result.add('first-strength');
    }
    if (sessions.any((s) => s.activityType == 'walk')) {
      result.add('first-walk');
    }
    if (sessions.any((s) => s.activityType == 'yoga')) {
      result.add('first-yoga');
    }
    if (sessions.any((s) => s.activityType == 'mobility')) {
      result.add('first-mobility');
    }

    return result.difference(_unlocked);
  }
}

/// Global controller for Exercise & Movement progress.
final exerciseProgressProvider =
    ChangeNotifierProvider<ExerciseProgressController>((ref) {
  final controller = ExerciseProgressController();
  controller.refresh();
  return controller;
});