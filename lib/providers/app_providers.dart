import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/pink_corner/services/pink_corner_service.dart';
import '../features/doctor/models/doctor.dart';
import '../features/doctor/services/doctor_service.dart';
import '../features/kyra/services/kyra_api_service.dart';
import '../models/user_profile.dart';
import '../models/health_metrics.dart';
import '../models/cycle_data.dart';
import '../models/community_post.dart';
import '../models/kyra_message.dart';
import '../models/article_item.dart';
import '../models/reminder_item.dart';
import '../models/period_record.dart';
import '../features/cycle/services/period_repository.dart';

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
        ]);

  void toggleReminder(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isEnabled: !r.isEnabled) else r
    ];
  }

  void addReminder(ReminderItem reminder) {
    state = [...state, reminder];
  }

  void updateReminder(ReminderItem updated) {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r
    ];
  }

  void deleteReminder(String id) {
    state = state.where((r) => r.id != id).toList();
  }
}

// Whisper Room Posts Provider
final whisperRoomProvider = StateNotifierProvider<WhisperRoomNotifier, List<CommunityPost>>((ref) {
  return WhisperRoomNotifier();
});

class WhisperRoomNotifier extends StateNotifier<List<CommunityPost>> {
  WhisperRoomNotifier()
      : super([
          CommunityPost(
            id: 'post_1',
            authorName: 'Anonymous Butterfly',
            authorAvatar: '🌸',
            isAnonymous: true,
            category: 'PCOS/PCOD Support',
            title: 'Managing PCOS cravings naturally - what worked for me!',
            content:
                'Adding spearmint tea and cinnamon morning water helped reduce my sweet cravings significantly during follicular phase. Has anyone else tried this?',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            likesCount: 142,
            commentsCount: 28,
            isLiked: true,
            comments: [
              CommentItem(
                id: 'c1',
                authorName: 'Sarah M.',
                authorAvatar: '🌺',
                createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                text: 'Spearmint tea helped my hormonal acne so much as well!',
                likesCount: 12,
              )
            ],
          ),
          CommunityPost(
            id: 'post_2',
            authorName: 'Wellness Sister',
            authorAvatar: '✨',
            isAnonymous: false,
            category: 'Periods & Flow Talk',
            title: 'POLL: How do you handle day 1 cramps?',
            content: 'Let us know your go-to ritual for comfort during day 1 of your cycle!',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            likesCount: 289,
            commentsCount: 64,
            pollOptions: [
              PollOption(id: 'p1', text: 'Heating Pad + Herbal Tea', votes: 142),
              PollOption(id: 'p2', text: 'Gentle Yoga & Stretching', votes: 86),
              PollOption(id: 'p3', text: 'Magnesium & Warm Shower', votes: 61),
            ],
          ),
          CommunityPost(
            id: 'post_3',
            authorName: 'Anonymous Rose',
            authorAvatar: '🌿',
            isAnonymous: true,
            category: 'Mental Wellness & Mood',
            title: 'Feeling anxious during ovulation phase? You are not alone.',
            content:
                'I used to think ovulation only brings high energy, but sometimes estrogen spikes cause mild anxiety for me. Be gentle with yourselves today ladies! 💖',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            likesCount: 412,
            commentsCount: 53,
          ),
          CommunityPost(
            id: 'post_4',
            authorName: 'Sonali',
            authorAvatar: '👑',
            isAnonymous: false,
            isMine: true,
            category: 'Exercise & Nutrition',
            title: 'My top 5 seed cycling tips for hormonal balance ✨',
            content:
                'Started seed cycling 3 months ago: pumpkin & flax seeds during follicular, sesame & sunflower during luteal. My cycle has been so much more regular!',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            likesCount: 198,
            commentsCount: 34,
            isSaved: true,
          ),
          CommunityPost(
            id: 'post_5',
            authorName: 'Dr. Priya M.',
            authorAvatar: '🩺',
            isAnonymous: false,
            category: 'Sex Education',
            title: 'Understanding intimacy & cycle phase changes',
            content:
                'Libido and energy change dynamically across your menstrual cycle due to fluctuating estrogen and progesterone. Knowing your cycle helps build confidence.',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            likesCount: 320,
            commentsCount: 42,
          ),
          CommunityPost(
            id: 'post_6',
            authorName: 'MommyToBee',
            authorAvatar: '🤰',
            isAnonymous: false,
            category: 'Pregnancy & Motherhood',
            title: 'First trimester morning sickness relief ideas 🍼',
            content:
                'Small frequent meals, ginger water, and vitamin B6 made a huge difference during weeks 6-10!',
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
            likesCount: 156,
            commentsCount: 19,
          ),
          CommunityPost(
            id: 'post_7',
            authorName: 'Sonali',
            authorAvatar: '👑',
            isAnonymous: false,
            isMine: true,
            category: 'General',
            title: 'Welcome to Whisper Room! Safe space for all of us 💬',
            content:
                'Feel free to ask any question, share your wins, or seek support from this amazing community.',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            likesCount: 530,
            commentsCount: 88,
          ),
        ]);

  void toggleLike(String postId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            isLiked: !post.isLiked,
            likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
          )
        else
          post
    ];
  }

  void toggleSave(String postId) {
    state = [
      for (final post in state)
        if (post.id == postId) post.copyWith(isSaved: !post.isSaved) else post
    ];
  }

  void votePoll(String postId, String optionId) {
    state = [
      for (final post in state)
        if (post.id == postId && post.pollOptions != null)
          post.copyWith(
            userVotedPollOptionId: optionId,
            pollOptions: [
              for (final opt in post.pollOptions!)
                if (opt.id == optionId) opt.copyWith(votes: opt.votes + 1) else opt
            ],
          )
        else
          post
    ];
  }

  void addPost(CommunityPost post) {
    state = [post, ...state];
  }

  void deletePost(String postId) {
    state = state.where((post) => post.id != postId).toList();
  }

  void editPost(String postId, String newTitle, String newContent) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(title: newTitle, content: newContent)
        else
          post
    ];
  }

  void addComment(String postId, String commentText, {bool isAnonymous = false}) {
    final newComment = CommentItem(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: isAnonymous ? 'Anonymous' : 'Sonali',
      authorAvatar: isAnonymous ? '🌸' : '👑',
      text: commentText,
      createdAt: DateTime.now(),
      likesCount: 0,
    );

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

// Pink Corner Educational Articles Provider
final articlesProvider = StreamProvider<List<ArticleItem>>((ref) {
  final service = ref.read(pinkCornerServiceProvider);
  return service.streamArticles();
});

// Seed mock articles helper
Future<void> seedMockArticles(WidgetRef ref) async {
  final service = ref.read(pinkCornerServiceProvider);
  final staticArticles = [
    ArticleItem(
      id: 'art_1',
      title: 'PCOS vs PCOD: Understanding the Key Differences & Daily Habits',
      category: 'PCOS & PCOD',
      readTime: '4 min read',
      summary:
          'Learn how hormonal balance, insulin sensitivity, and cycle tracking can help manage PCOS symptoms effectively.',
      fullBody:
          'PCOS (Polycystic Ovary Syndrome) and PCOD (Polycystic Ovarian Disease) are endocrine conditions affecting millions of women worldwide.\n\nWhile PCOD is primarily a metabolic imbalance causing ovaries to produce immature eggs, PCOS involves higher androgen levels leading to irregular cycles, acne, and hirsutism.\n\nKey Daily Habits to Balance Hormones:\n1. Seed Cycling: Pumpkin & flax seeds in follicular phase; sunflower & sesame in luteal phase.\n2. Spearmint Tea: 2 cups daily helps lower free testosterone levels.\n3. Strength Training: Builds muscle sensitivity to insulin.\n4. Prioritize Sleep: 7-8 hours prevents cortisol spikes.',
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600',
      isTrending: true,
    ),
    ArticleItem(
      id: 'art_2',
      title: 'Deciphering Cervical Mucus & Your Fertile Window',
      category: 'Fertility & Flow',
      readTime: '3 min read',
      summary: 'Identify egg-white discharge patterns to predict your exact ovulation day naturally.',
      fullBody:
          'Cervical mucus changes dynamically throughout your cycle under the influence of estrogen and progesterone.\n\n• Dry/Sticky: Right after your period.\n• Creamy: Early follicular phase.\n• Egg-White Clear & Stretchy: Peak fertile window right before ovulation!',
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600',
      isTrending: true,
    ),
    ArticleItem(
      id: 'art_3',
      title: 'The Science of PMS & Luteal Phase Nutrition',
      category: 'Body Changes',
      readTime: '5 min read',
      summary: 'Reduce mood swings and bloating with magnesium, B6, and complex carbohydrates.',
      fullBody:
          'During the luteal phase (days 15-28), progesterone rises while serotonin drops. This can cause cravings and mood dips.\n\nNourish your body with dark chocolate (70%+), spinach, bananas, and herbal chamomiles.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
      isTrending: false,
    ),
  ];
  await service.seedMockArticles(staticArticles);
}

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
