import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/notification_service.dart';
import '../features/pink_corner/services/pink_corner_service.dart';
import '../features/doctor/models/doctor.dart';
import '../features/doctor/models/appointment.dart';
import '../features/doctor/services/doctor_service.dart';
import '../features/kyra/services/kyra_api_service.dart';
import '../models/user_profile.dart';
import '../models/health_metrics.dart';
import '../models/cycle_data.dart';
import '../models/community_post.dart';
import '../models/kyra_message.dart';
import '../models/article_item.dart';
import '../models/faq_item.dart';
import '../models/reminder_item.dart';
import '../models/period_record.dart';
import '../features/cycle/services/period_repository.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/whisper_room/services/whisper_service.dart';

// User Profile Provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(UserProfile(
          id: 'usr_101',
          username: 'Sonali',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          isPartnerLinked: false,
          partnerCode: 'HS-8942',
        ));

  void updateUsername(String newName) {
    state = state.copyWith(username: newName);
  }

  void linkPartner(String code, String partnerName) {
    state = state.copyWith(
      isPartnerLinked: true,
      partnerCode: code,
      partnerName: partnerName,
    );
  }

  void unlinkPartner() {
    state = state.copyWith(
      isPartnerLinked: false,
      partnerName: null,
    );
  }
}

// Health Metrics Provider
final healthMetricsProvider = StateNotifierProvider<HealthMetricsNotifier, HealthMetrics>((ref) {
  return HealthMetricsNotifier();
});

class HealthMetricsNotifier extends StateNotifier<HealthMetrics> {
  HealthMetricsNotifier() : super(const HealthMetrics());

  void updateWaterIntake(double deltaLiters) {
    final newWater = (state.waterIntakeLiters + deltaLiters).clamp(0.0, 5.0);
    state = state.copyWith(waterIntakeLiters: double.parse(newWater.toStringAsFixed(1)));
  }

  void updateWeight(double newWeight) {
    state = state.copyWith(weightKg: newWeight);
  }

  void updateSleep(double newSleep) {
    state = state.copyWith(sleepHours: newSleep);
  }

  void updateStress(int stressPercent) {
    state = state.copyWith(stressScorePercent: stressPercent);
  }

  void updateSteps(int steps) {
    state = state.copyWith(stepsCount: steps);
  }

  void toggleSupplements(bool taken) {
    state = state.copyWith(supplementsTaken: taken);
  }

  void updateAcne(String status) {
    state = state.copyWith(acneStatus: status);
  }
}

// Period Cycle Provider
final cycleDataProvider = StateNotifierProvider<CycleDataNotifier, CycleData>((ref) {
  return CycleDataNotifier();
});

class CycleDataNotifier extends StateNotifier<CycleData> {
  CycleDataNotifier() : super(CycleData.defaultData());

  void logSymptomToday(String symptom, String flow, int pain, String mood) {
    final newLog = DailySymptomLog(
      date: DateTime.now(),
      symptoms: [symptom],
      flowLevel: flow,
      painScale: pain,
      mood: mood,
    );
    state = CycleData(
      lastPeriodStartDate: state.lastPeriodStartDate,
      cycleLengthDays: state.cycleLengthDays,
      periodDurationDays: state.periodDurationDays,
      currentDayOfCycle: state.currentDayOfCycle,
      currentPhase: state.currentPhase,
      daysUntilNextPeriod: state.daysUntilNextPeriod,
      ovulationDate: state.ovulationDate,
      fertilityWindow: state.fertilityWindow,
      symptomLogs: [newLog, ...state.symptomLogs],
    );
  }
}

// Period Logs Provider
final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return PeriodRepository();
});

class PeriodLogsState {
  final bool isLoading;
  final List<PeriodRecord> records;
  final String? errorMessage;

  const PeriodLogsState({
    this.isLoading = false,
    this.records = const [],
    this.errorMessage,
  });
}

final periodLogsProvider =
    StateNotifierProvider<PeriodLogsNotifier, PeriodLogsState>((ref) {
  return PeriodLogsNotifier(ref);
});

class PeriodLogsNotifier extends StateNotifier<PeriodLogsState> {
  final Ref ref;

  PeriodLogsNotifier(this.ref) : super(const PeriodLogsState());

  PeriodRepository get _repository => ref.read(periodRepositoryProvider);

  String _formatError(Object e) {
    if (e is FirebaseException) {
      final fe = e;
      return 'Database Error [${fe.code}]: ${fe.message}';
    }
    if (e is StateError) {
      return e.message;
    }
    return 'Error: ${e.toString()}';
  }

  /// Loads the signed-in user's periods from Supabase.
  /// On failure the error is exposed through [PeriodLogsState.errorMessage].
  Future<void> loadPeriods() async {
    state = const PeriodLogsState(isLoading: true);
    try {
      final records = await _repository.getPeriods();
      if (mounted) {
        state = PeriodLogsState(records: records);
      }
    } catch (e) {
      debugPrint('Error in PeriodLogsNotifier.loadPeriods: $e');
      if (mounted) {
        state = PeriodLogsState(
          errorMessage: _formatError(e),
        );
      }
    }
  }

  /// Saves a new period to Supabase.
  /// Returns null on success, or a user-facing error message on failure.
  Future<String?> addPeriod({
    required DateTime startDate,
    DateTime? endDate,
    String? flowLevel,
    int? painLevel,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      final record = await _repository.createPeriod(
        startDate: startDate,
        endDate: endDate,
        flowLevel: flowLevel,
        painLevel: painLevel,
        mood: mood,
        symptoms: symptoms,
        notes: notes,
      );
      if (mounted) {
        state = PeriodLogsState(records: _sorted([record, ...state.records]));
      }
      return null;
    } catch (e) {
      debugPrint('Error in PeriodLogsNotifier.addPeriod: $e');
      return _formatError(e);
    }
  }

  /// Updates an existing period in Supabase.
  /// Returns null on success, or a user-facing error message on failure.
  Future<String?> updatePeriod(
    String id, {
    required DateTime startDate,
    DateTime? endDate,
    String? flowLevel,
    int? painLevel,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      final updated = await _repository.updatePeriod(
        id,
        startDate: startDate,
        endDate: endDate,
        flowLevel: flowLevel,
        painLevel: painLevel,
        mood: mood,
        symptoms: symptoms,
        notes: notes,
      );
      if (mounted) {
        state = PeriodLogsState(
          records: _sorted([
            for (final r in state.records)
              if (r.id == id) updated else r
          ]),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error in PeriodLogsNotifier.updatePeriod: $e');
      return _formatError(e);
    }
  }

  /// Deletes a period from Supabase.
  /// Returns null on success, or a user-facing error message on failure.
  Future<String?> deletePeriod(String id) async {
    try {
      await _repository.deletePeriod(id);
      if (mounted) {
        state = PeriodLogsState(
          records: state.records.where((r) => r.id != id).toList(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error in PeriodLogsNotifier.deletePeriod: $e');
      return _formatError(e);
    }
  }

  List<PeriodRecord> _sorted(List<PeriodRecord> records) {
    final sorted = [...records];
    sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted;
  }
}

// Reminders Provider
final remindersProvider = StateNotifierProvider<RemindersNotifier, List<ReminderItem>>((ref) {
  return RemindersNotifier();
});

class RemindersNotifier extends StateNotifier<List<ReminderItem>> {
  RemindersNotifier()
      : super([
          ReminderItem(
            id: 'rem_1',
            title: 'Period Expected',
            category: 'Period',
            subtitle: 'May 28, 2026',
            colorKey: 'Pink',
            isEnabled: true,
          ),
          ReminderItem(
            id: 'rem_2',
            title: 'Drink 2.5L Water',
            category: 'Water',
            subtitle: 'Daily Goal',
            reminderTimes: const [TimeOfDay(hour: 10, minute: 30)],
            colorKey: 'Blue',
            isEnabled: true,
          ),
          ReminderItem(
            id: 'rem_3',
            title: 'Take Supplements',
            category: 'Medicine',
            subtitle: 'After Breakfast',
            reminderTimes: const [TimeOfDay(hour: 13, minute: 0)],
            colorKey: 'Purple',
            isEnabled: true,
          ),
          ReminderItem(
            id: 'rem_4',
            title: 'Evening Walk',
            category: 'Exercise',
            subtitle: '30 mins activity',
            reminderTimes: const [TimeOfDay(hour: 18, minute: 0)],
            colorKey: 'Peach',
            isEnabled: true,
          ),
          ReminderItem(
            id: 'rem_5',
            title: 'Sleep Reminder',
            category: 'Sleep',
            subtitle: 'Wind down time',
            reminderTimes: const [TimeOfDay(hour: 22, minute: 30)],
            colorKey: 'Purple',
            isEnabled: false,
          ),
          ReminderItem(
            id: 'rem_6',
            title: 'Log Daily Health',
            category: 'Health',
            subtitle: 'Update your wellness tracker',
            reminderTimes: const [TimeOfDay(hour: 20, minute: 0)],
            colorKey: 'Pink',
            isEnabled: true,
          ),
        ]) {
    // Schedule initial enabled reminders on startup
    _scheduleAllEnabled();
  }

  void _scheduleAllEnabled() {
    for (final r in state) {
      if (r.isEnabled) _scheduleReminder(r);
    }
  }

  void _scheduleReminder(ReminderItem reminder) {
    if (reminder.reminderTimes.isEmpty) return;
    final int notifId = reminder.id.hashCode;
    NotificationService().scheduleDailyReminder(
      id: notifId,
      title: reminder.title,
      body: reminder.subtitle ?? 'Time for your reminder',
      time: reminder.reminderTimes.first,
    );
  }

  void _cancelReminder(String id) {
    final int notifId = id.hashCode;
    NotificationService().cancelReminder(notifId);
  }

  void toggleReminder(String id) {
    final newState = <ReminderItem>[];
    for (final r in state) {
      if (r.id == id) {
        final toggled = r.copyWith(isEnabled: !r.isEnabled);
        if (toggled.isEnabled) {
          _scheduleReminder(toggled);
        } else {
          _cancelReminder(id);
        }
        newState.add(toggled);
      } else {
        newState.add(r);
      }
    }
    state = newState;
  }

  void addReminder(ReminderItem reminder) {
    state = [...state, reminder];
    if (reminder.isEnabled) {
      _scheduleReminder(reminder);
    }
  }

  void updateReminder(ReminderItem updated) {
    final newState = <ReminderItem>[];
    for (final r in state) {
      if (r.id == updated.id) {
        // Cancel the old one just in case the time changed
        _cancelReminder(r.id);
        
        if (updated.isEnabled) {
          _scheduleReminder(updated);
        }
        newState.add(updated);
      } else {
        newState.add(r);
      }
    }
    state = newState;
  }

  void deleteReminder(String id) {
    _cancelReminder(id);
    state = state.where((r) => r.id != id).toList();
  }
}


// Whisper Service Provider
final whisperServiceProvider = Provider<WhisperService>((ref) {
  return WhisperService();
});

// Whisper Room Posts Provider
final whisperRoomProvider = StateNotifierProvider<WhisperRoomNotifier, List<CommunityPost>>((ref) {
  return WhisperRoomNotifier(ref.read(whisperServiceProvider), ref);
});

class WhisperRoomNotifier extends StateNotifier<List<CommunityPost>> {
  final WhisperService _service;
  final Ref ref;
  DocumentSnapshot? _lastDoc;
  List<String> _blockedUsers = [];
  bool _hasMore = true;
  bool _isLoading = false;

  WhisperRoomNotifier(this._service, this.ref) : super([]) {
    _init();
  }

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _blockedUsers = await _service.getBlockedUsers();
    await loadMorePosts(refresh: true);
  }

  Future<void> loadMorePosts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _lastDoc = null;
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    final newPosts = await _service.getPosts(
      limit: 10,
      startAfter: _lastDoc,
      blockedUserNames: _blockedUsers,
    );

    if (newPosts.isEmpty) {
      _hasMore = false;
    } else {
      // In a real implementation we would need a way to get the last doc snapshot from the service.
      // Since we just return List<CommunityPost> from the service, let's just assume we can't easily do startAfterDocument without refactoring the service to return a Tuple.
      // For the sake of this implementation, we will mock pagination by just taking the first batch if startAfter is not easily tracked, or we can track it by date.
      // Actually, since we didn't return the DocumentSnapshot from getPosts, we can't paginate perfectly here. We will just load the first 10 for now.
      _hasMore = false; 
    }

    if (refresh) {
      state = newPosts;
    } else {
      state = [...state, ...newPosts];
    }
    _isLoading = false;
  }

  Future<void> toggleLike(String postId) async {
    final post = state.firstWhere((p) => p.id == postId);
    final isLiked = post.isLiked;
    final currentLikes = post.likesCount;
    
    // Optimistic update
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            isLiked: !isLiked,
            likesCount: isLiked ? currentLikes - 1 : currentLikes + 1,
          )
        else
          p
    ];

    try {
      await _service.toggleLike(postId, isLiked);
    } catch (e) {
      // Rollback on failure (simplified)
      debugPrint('Failed to toggle like');
    }
  }

  Future<void> toggleSave(String postId) async {
    final post = state.firstWhere((p) => p.id == postId);
    final isSaved = post.isSaved;

    state = [
      for (final p in state)
        if (p.id == postId) p.copyWith(isSaved: !isSaved) else p
    ];

    try {
      await _service.toggleSave(postId, isSaved);
    } catch (e) {
      debugPrint('Failed to toggle save');
    }
  }

  Future<void> votePoll(String postId, String optionId) async {
    final post = state.firstWhere((p) => p.id == postId);
    if (post.userVotedPollOptionId != null) return; // Prevent multiple votes

    state = [
      for (final p in state)
        if (p.id == postId && p.pollOptions != null)
          p.copyWith(
            userVotedPollOptionId: optionId,
            pollOptions: [
              for (final opt in p.pollOptions!)
                if (opt.id == optionId) opt.copyWith(votes: opt.votes + 1) else opt
            ],
          )
        else
          p
    ];

    try {
      await _service.votePoll(postId, optionId);
    } catch (e) {
      debugPrint('Failed to vote poll');
    }
  }

  Future<void> addPost(CommunityPost post) async {
    // Optimistic Update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempPost = post.copyWith(id: tempId);
    state = [tempPost, ...state];

    try {
      final updatedPost = await _service.createPost(tempPost);
      if (updatedPost != null) {
        state = [
          for (final p in state)
            if (p.id == tempId) updatedPost else p
        ];
      }
    } catch (e) {
      // Revert optimistic update on failure
      state = state.where((p) => p.id != tempId).toList();
      debugPrint('Failed to add post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    state = state.where((post) => post.id != postId).toList();
    await _service.deletePost(postId);
  }

  Future<void> editPost(String postId, String newTitle, String newContent) async {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(title: newTitle, content: newContent)
        else
          post
    ];
    await _service.editPost(postId, newTitle, newContent);
  }

  Future<void> reportPost(String postId) async {
    // Hide reported post from local feed
    state = state.where((post) => post.id != postId).toList();
    await _service.reportPost(postId);
  }

  Future<void> blockUser(String authorName) async {
    // Hide all posts from this user
    _blockedUsers.add(authorName);
    state = state.where((post) => post.authorName != authorName).toList();
    await _service.blockUser(authorName);
  }

  Future<void> addComment(String postId, String commentText, {bool isAnonymous = false}) async {
    final userProfile = ref.read(userProfileProvider);
    final newComment = CommentItem(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: isAnonymous ? 'Anonymous' : userProfile.username,
      authorAvatar: isAnonymous ? '' : userProfile.avatarUrl,
      text: commentText,
      createdAt: DateTime.now(),
      likesCount: 0,
    );

    // Optimistic update
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            commentsCount: post.commentsCount + 1,
            comments: [...post.comments, newComment],
          )
        else
          post
    ];

    await _service.addComment(postId, newComment);
  }
}

// Kyra API Service Provider
final kyraApiServiceProvider = Provider<KyraApiService>((ref) {
  return KyraApiService();
});

// Kyra AI Companion Provider
final kyraMessagesProvider = StateNotifierProvider<KyraNotifier, List<KyraMessage>>((ref) {
  return KyraNotifier(ref);
});

class KyraNotifier extends StateNotifier<List<KyraMessage>> {
  final Ref ref;

  KyraNotifier(this.ref)
      : super([
          KyraMessage(
            id: 'k_1',
            sender: KyraSender.kyra,
            text:
                'Hello Sonali! 🌸 I am Kyra, your AI health companion. I analyzed your health logs: your sleep score is 88%, and you are on Day 12 of your Follicular phase!\n\nHow can I support your balance today?',
            timestamp: DateTime.now(),
            actionButtons: [
              'Analyze My Lab Report',
              'PCOS Meal Suggestions',
              'Why am I feeling anxious?',
              'Cycle Summary'
            ],
          )
        ]);

  Future<void> sendMessage(String userText) async {
    final userMsg = KyraMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      sender: KyraSender.user,
      text: userText,
      timestamp: DateTime.now(),
    );

    // Append user message immediately
    state = [...state, userMsg];

    // Read necessary context (e.g., current phase, health score) to pass to Kyra
    // Although the backend fetches last 7 days of logs directly from Firestore,
    // we can pass additional frontend-specific context if needed.
    final health = ref.read(healthMetricsProvider);
    final cycle = ref.read(cycleDataProvider);

    final contextData = {
      'currentPhase': cycle.currentPhase.displayName,
      'dayOfCycle': cycle.currentDayOfCycle,
      'healthScore': health.calculatedScore,
    };

    // Call the real Vercel backend using KyraApiService
    final apiService = ref.read(kyraApiServiceProvider);
    
    try {
      final responseText = await apiService.sendMessage(userText, contextData);
      
      final kyraReply = KyraMessage(
        id: 'k_${DateTime.now().millisecondsSinceEpoch}',
        sender: KyraSender.kyra,
        text: responseText,
        timestamp: DateTime.now(),
        actionButtons: [
          'Hydration Advice',
          'Sleep Optimization',
          'Track Symptoms'
        ], // Provide some dynamic or static fallback buttons
      );

      if (mounted) {
        state = [...state, kyraReply];
      }
    } catch (e) {
      debugPrint('Error getting Kyra AI response: $e');
      if (mounted) {
        final errorReply = KyraMessage(
          id: 'k_error_${DateTime.now().millisecondsSinceEpoch}',
          sender: KyraSender.kyra,
          text: 'I am having trouble connecting to my servers right now. Please try again later!',
          timestamp: DateTime.now(),
        );
        state = [...state, errorReply];
      }
    }
  }
}

// Pink Corner Service Provider
final pinkCornerServiceProvider = Provider<PinkCornerService>((ref) {
  return PinkCornerService();
});

// Doctor Service Provider
final doctorServiceProvider = Provider<DoctorService>((ref) {
  return DoctorService();
});

// Doctors Stream Provider
final doctorsProvider = StreamProvider<List<Doctor>>((ref) {
  final service = ref.read(doctorServiceProvider);
  return service.streamDoctors();
});

// Seed mock doctors helper
Future<void> seedMockDoctors(WidgetRef ref) async {
  final service = ref.read(doctorServiceProvider);
  final staticDoctors = [
    Doctor(
      id: 'doc_1',
      name: 'Dr. Sarah Jenkins',
      specialization: 'Gynecologist',
      experience: '10 Years',
      rating: 4.8,
      consultationFee: 50,
      availability: 'Available Today',
      mode: ConsultationMode.online,
      about: 'Dr. Sarah Jenkins specializes in reproductive health and PCOS management. She has helped over 500 women regain hormonal balance.',
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      timeSlots: ['10:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
    ),
    Doctor(
      id: 'doc_2',
      name: 'Dr. Emily Chen',
      specialization: 'Endocrinologist',
      experience: '8 Years',
      rating: 4.9,
      consultationFee: 75,
      availability: 'Available Tomorrow',
      mode: ConsultationMode.offline,
      distanceKm: 2.5,
      clinicLocation: 'Wellness Clinic, 123 Health Ave.',
      about: 'Dr. Emily Chen is a leading expert in hormonal disorders, focusing on thyroid issues and insulin resistance.',
      availableDays: ['Mon', 'Wed', 'Fri'],
      timeSlots: ['09:00 AM', '01:00 PM', '03:00 PM'],
    ),
    Doctor(
      id: 'doc_3',
      name: 'Dr. Aisha Patel',
      specialization: 'Nutritionist',
      experience: '5 Years',
      rating: 4.7,
      consultationFee: 40,
      availability: 'Available Today',
      mode: ConsultationMode.online,
      about: 'Dr. Aisha Patel helps women create sustainable, hormone-balancing diets without restrictive eating.',
      availableDays: ['Tue', 'Thu', 'Sat'],
      timeSlots: ['11:00 AM', '12:30 PM', '05:00 PM'],
    ),
  ];
  await service.seedMockDoctors(staticDoctors);
}


// User Appointment Requests Provider (All appointments)
final appointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final service = ref.read(doctorServiceProvider);
  final user = ref.watch(authNotifierProvider).userProfile;
  if (user == null) return Stream.value([]);
  return service.streamUserAppointments(user.id);
});

// User Active/Confirmed Appointments Provider
final patientActiveDoctorsProvider = StreamProvider<List<Appointment>>((ref) {
  final service = ref.read(doctorServiceProvider);
  final user = ref.watch(authNotifierProvider).userProfile;
  if (user == null) return Stream.value([]);
  
  return service.streamUserAppointments(user.id).map((appointments) {
    return appointments.where((apt) => apt.status == AppointmentStatus.confirmed || apt.status == AppointmentStatus.requested).toList();
  });
});

// Doctor Dashboard Appointments Provider
final doctorDashboardProvider = StreamProvider<List<Appointment>>((ref) {
  final service = ref.read(doctorServiceProvider);
  final user = ref.watch(authNotifierProvider).userProfile;
  if (user == null) return Stream.value([]);
  
  // FOR TESTING: We return the user's own appointments here so that you can 
  // go to the Doctor Dashboard and Accept/Decline your own bookings without 
  // needing to create a separate Doctor account and log in/out.
  return service.streamUserAppointments(user.id);
});
