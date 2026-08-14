import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeditationSession {
  final String id;
  final DateTime date;
  final int durationMinutes;

  MeditationSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
  });
}

class MeditationNotifier extends StateNotifier<List<MeditationSession>> {
  MeditationNotifier() : super([
    // Initial mock data
    MeditationSession(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      durationMinutes: 10,
    ),
    MeditationSession(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 15,
    ),
  ]);

  void addSession(int minutes) {
    final newSession = MeditationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      durationMinutes: minutes,
    );
    state = [newSession, ...state];
  }

  int get totalMeditationMinutes {
    return state.fold(0, (sum, session) => sum + session.durationMinutes);
  }
}

final meditationProvider = StateNotifierProvider<MeditationNotifier, List<MeditationSession>>((ref) {
  return MeditationNotifier();
});
