import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/health_metrics.dart';
import '../models/cycle_data.dart';
import '../models/community_post.dart';
import '../models/kyra_message.dart';
import '../models/article_item.dart';
import '../models/reminder_item.dart';

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
            category: 'PCOS/PCOD',
            title: 'Managing PCOS cravings naturally - what worked for me!',
            content:
                'Adding spearmint tea and cinnamon morning water helped reduce my sweet cravings significantly during follicular phase. Has anyone else tried this?',
            timeAgo: '2h ago',
            likesCount: 142,
            commentsCount: 28,
            isLiked: true,
            comments: [
              CommentItem(
                id: 'c1',
                authorName: 'Sarah M.',
                authorAvatar: '🌺',
                text: 'Spearmint tea helped my hormonal acne so much as well!',
                timeAgo: '1h ago',
                likesCount: 12,
              )
            ],
          ),
          CommunityPost(
            id: 'post_2',
            authorName: 'Wellness Sister',
            authorAvatar: '✨',
            isAnonymous: false,
            category: 'Period Talk',
            title: 'POLL: How do you handle day 1 cramps?',
            content: 'Let us know your go-to ritual for comfort during day 1 of your cycle!',
            timeAgo: '5h ago',
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
            category: 'Mental Wellness',
            title: 'Feeling anxious during ovulation phase? You are not alone.',
            content:
                'I used to think ovulation only brings high energy, but sometimes estrogen spikes cause mild anxiety for me. Be gentle with yourselves today ladies! 💖',
            timeAgo: '1d ago',
            likesCount: 412,
            commentsCount: 53,
          )
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

  void addComment(String postId, String commentText) {
    final newComment = CommentItem(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Sonali',
      authorAvatar: '👑',
      text: commentText,
      timeAgo: 'Just now',
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

  void sendMessage(String userText) {
    final userMsg = KyraMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      sender: KyraSender.user,
      text: userText,
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg];

    // Generate Contextual Intelligent Response from Kyra
    Future.delayed(const Duration(milliseconds: 1000), () {
      final health = ref.read(healthMetricsProvider);
      final cycle = ref.read(cycleDataProvider);

      String replyText = '';
      String? labInsight;
      String? foodSuggestion;

      final lower = userText.toLowerCase();
      if (lower.contains('lab') || lower.contains('report')) {
        replyText =
            'I have scanned your recent hormonal panel! Your Vitamin D and Iron levels are within healthy ranges. Thyroid (TSH 2.1 mIU/L) is optimal for your follicular phase.';
        labInsight =
            '📊 Lab Report Insight:\n• LH/FSH Ratio: 1.1 (Normal)\n• Hemoglobin: 13.2 g/dL\n• Vitamin D: 42 ng/mL (Sufficient)\n\nTip: Maintain leafy greens & vitamin C intake to support iron absorption.';
      } else if (lower.contains('pcos') || lower.contains('meal') || lower.contains('food')) {
        replyText =
            'Since you are in Day ${cycle.currentDayOfCycle} (Follicular Phase), your metabolic rate is rising. Focusing on complex carbs, anti-inflammatory greens, and healthy fats will keep your energy steady!';
        foodSuggestion =
            '🥗 Kyra\'s Follicular Meal Plan:\n• Breakfast: Avocado toast on sourdough with poached eggs\n• Lunch: Quinoa bowl with roasted sweet potato & chickpea\n• Evening Snack: Handful of pumpkin seeds & spearmint tea';
      } else if (lower.contains('anxious') || lower.contains('stress') || lower.contains('mood')) {
        replyText =
            'Your stress score is currently at ${health.stressScorePercent}%. Mild anxiety during follicular transition is common due to surging estrogen. Try 5 minutes of box breathing!';
      } else {
        replyText =
            'Based on your period cycle data and health score of ${health.calculatedScore}/100, your body is responding wonderfully to your hydration (2.1L today) and sleep routine!';
      }

      final kyraReply = KyraMessage(
        id: 'k_${DateTime.now().millisecondsSinceEpoch}',
        sender: KyraSender.kyra,
        text: replyText,
        timestamp: DateTime.now(),
        labReportInsight: labInsight,
        foodRecommendation: foodSuggestion,
        actionButtons: [
          'Hydration Advice',
          'Sleep Optimization',
          'Track Symptoms'
        ],
      );

      state = [...state, kyraReply];
    });
  }
}

// Pink Corner Educational Articles Provider
final articlesProvider = Provider<List<ArticleItem>>((ref) {
  return [
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
});
