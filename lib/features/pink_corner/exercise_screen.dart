import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'data/exercise_achievements.dart';
import 'data/exercise_topic.dart';
import 'data/exercise_topics.dart';
import 'data/exercise_workout.dart';
import 'data/exercise_workouts.dart';
import 'exercise_topic_detail_screen.dart';
import 'exercise_workout_screen.dart';
import 'providers/exercise_provider.dart';
import 'services/exercise_local_store.dart';
import 'widgets/article_widgets.dart';
import 'widgets/exercise_visuals.dart';
import 'widgets/topic_card.dart';

/// Entry screen for the Exercise & Movement card inside Learn.
///
/// Shows educational topics (why movement matters, types of movement, cycle
/// movement, PCOS/PCOD movement), beginner workouts, and a real-data
/// gamification area — streak, progress timeline, achievements and
/// supportive motivation. All progress derives from completed sessions.
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  ExerciseAchievement? _celebration;
  Timer? _celebrationTimer;

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }

  void _openTopic(BuildContext context, ExerciseTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseTopicDetailScreen(topic: topic),
      ),
    );
  }

  void _openWorkout(BuildContext context, ExerciseWorkout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseWorkoutScreen(workout: workout),
      ),
    );
  }

  void _showLogActivitySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _LogActivitySheet(),
    );
  }

  void _onUnlockedChanged(Set<String> before, Set<String> after) {
    if (after.length <= before.length) return;
    final newlyUnlockedIds = after.difference(before);
    final newlyUnlocked = exerciseAchievements
        .where((a) => newlyUnlockedIds.contains(a.id))
        .toList();
    if (newlyUnlocked.isEmpty) return;

    _celebrationTimer?.cancel();
    setState(() => _celebration = newlyUnlocked.first);
    _celebrationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _celebration = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(exerciseProgressProvider);
    ref.listen(exerciseProgressProvider, (previous, next) {
      _onUnlockedChanged(
        previous?.unlocked ?? const {},
        next.unlocked,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Exercise & Movement',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                const SizedBox(height: 12),
                _buildDisclaimer(),
                const SizedBox(height: 20),

                // Your movement — real progress from completed sessions.
                _ProgressSection(
                  progress: progress,
                  onLogActivity: _showLogActivitySheet,
                ),
                const SizedBox(height: 24),

                // 1. Group — Why Movement Matters
                ArticleSectionHeading(
                  title: exerciseGroups[0].name,
                  icon: exerciseGroups[0].icon,
                ),
                _TopicGrid(
                  topics: exerciseGroups[0].topics,
                  onTap: (topic) => _openTopic(context, topic),
                ),
                const SizedBox(height: 22),

                // 2. Group — Types of Movement
                ArticleSectionHeading(
                  title: exerciseGroups[1].name,
                  icon: exerciseGroups[1].icon,
                ),
                _TopicGrid(
                  topics: exerciseGroups[1].topics,
                  onTap: (topic) => _openTopic(context, topic),
                ),
                const SizedBox(height: 22),

                // 3. Side-by-side row — Movement & Your Cycle + Movement & PCOS/PCOD
                ArticleSectionHeading(
                  title: 'Cycle & PCOS/PCOD',
                  icon: exerciseGroups[2].icon,
                ),
                _SideBySideTopicsRow(
                  topic1: exerciseGroups[2].topics.first,
                  topic2: exerciseGroups[3].topics.first,
                  onTap: (topic) => _openTopic(context, topic),
                ),
                const SizedBox(height: 22),

                // Beginner Workouts
                const ArticleSectionHeading(
                  title: 'Beginner Workouts',
                  icon: Icons.fitness_center_rounded,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F5EE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFB5EAD7).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.self_improvement_rounded,
                        size: 18,
                        color: Color(0xFF45B69C),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Simple routines you can realistically try — no equipment, '
                          'no experience needed, and rest is always welcome.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.5,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final workout in allExerciseWorkouts)
                  _WorkoutCard(
                    workout: workout,
                    onTap: () => _openWorkout(context, workout),
                  ),
                const SizedBox(height: 22),

                // Achievements
                const ArticleSectionHeading(
                  title: 'Achievements',
                  icon: Icons.emoji_events_rounded,
                ),
                Text(
                  'Badges unlock only when a movement session is actually completed. '
                  'No fakes, no pressure.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exerciseAchievements.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final achievement = exerciseAchievements[index];
                    return _AchievementBadge(
                      achievement: achievement,
                      unlocked: progress.isUnlocked(achievement.id),
                    );
                  },
                ),
                const SizedBox(height: 22),

                // Safety note (Move safely)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFB085).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.healing_rounded,
                            size: 18,
                            color: AppColors.peachCoral,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Move safely',
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stop if an exercise causes pain. Choose a lower-intensity option if you '
                        'are tired or uncomfortable. Rest is part of taking care of yourself — and '
                        'this app never replaces medical or physiotherapy advice.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Subtle celebration banner for newly unlocked achievements.
          if (_celebration != null)
            Positioned(
              top: 8,
              left: 24,
              right: 24,
              child: _CelebrationBanner(achievement: _celebration!),
            ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F4FF), Color(0xFFE5EBFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: exerciseBlueBorder.withValues(alpha: 0.7),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: exerciseBlueDeep,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Move your way',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Beginner-friendly guides to movement, realistic workouts, and gentle '
                  'encouragement — no pressure, no shame, and rest always allowed.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: exerciseBlueLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: exerciseBlueDeep.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: exerciseBlueDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Everything here is educational movement guidance — not a diagnosis, not '
              'medical advice, and never a replacement for professional care.',
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress section — streak, weekly timeline, session stats
// ---------------------------------------------------------------------------
class _ProgressSection extends StatelessWidget {
  final ExerciseProgressController progress;
  final VoidCallback onLogActivity;

  const _ProgressSection({
    required this.progress,
    required this.onLogActivity,
  });

  @override
  Widget build(BuildContext context) {
    final streak = progress.streak;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 18,
                color: exerciseBlueDeep,
              ),
              const SizedBox(width: 8),
              Text(
                'Your movement',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onLogActivity,
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text('Log activity'),
                style: TextButton.styleFrom(
                  foregroundColor: exerciseBlueDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: '${streak.current}',
                  color: const Color(0xFFFF7A59),
                  caption: streak.current > 0
                      ? 'day${streak.current == 1 ? '' : 's'} in a row'
                      : 'ready to start?',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.self_improvement_rounded,
                  label: 'Sessions',
                  value: '${progress.sessionCount}',
                  color: exerciseBlueDeep,
                  caption: 'completed',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  label: 'Minutes',
                  value: '${progress.totalMinutes}',
                  color: const Color(0xFF45B69C),
                  caption: 'of movement',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _WeeklyTimeline(sessions: progress.sessions),
          const SizedBox(height: 10),
          Text(
            streak.current == 0 && progress.sessionCount == 0
                ? 'Complete a workout or log an activity to begin your movement streak.'
                : streak.current == 0
                    ? 'Rest days are normal. Ready to start again when you are?'
                    : 'Nice work — consistency matters more than perfection.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple weekly movement timeline built from real session records.
class _WeeklyTimeline extends StatelessWidget {
  final List<ExerciseSession> sessions;

  const _WeeklyTimeline({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final byDay = <DateTime, int>{};
    for (final session in sessions) {
      final day = ExerciseLocalStore.dayOnly(session.date);
      byDay[day] = (byDay[day] ?? 0) + session.durationMinutes;
    }

    final today = ExerciseLocalStore.dayOnly(DateTime.now());
    final maxMinutes = byDay.values.fold<int>(0, mathMax);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 6; i >= 0; i--)
          Expanded(
            child: _DayBar(
              day: today.subtract(Duration(days: i)),
              minutes: byDay[today.subtract(Duration(days: i))] ?? 0,
              maxMinutes: maxMinutes,
            ),
          ),
      ],
    );
  }

  static int mathMax(int a, int b) => a > b ? a : b;
}

class _DayBar extends StatelessWidget {
  final DateTime day;
  final int minutes;
  final int maxMinutes;

  const _DayBar({
    required this.day,
    required this.minutes,
    required this.maxMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = ExerciseLocalStore.dayOnly(DateTime.now()) == day;
    final height = minutes == 0
        ? 6.0
        : 8.0 + (46.0 * (minutes / (maxMinutes == 0 ? 1 : maxMinutes)));

    return Column(
      children: [
        if (minutes > 0)
          Icon(
            Icons.local_fire_department_rounded,
            size: 13,
            color: const Color(0xFFFF7A59),
          )
        else
          const SizedBox(height: 13),
        const SizedBox(height: 3),
        Container(
          height: 56,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 14,
            height: height,
            decoration: BoxDecoration(
              color: minutes > 0
                  ? (isToday
                      ? exerciseBlueDeep
                      : const Color(0xFF5B7FFF).withValues(alpha: 0.55))
                  : AppColors.borderGrey,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _dayLabel(day),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? exerciseBlueDeep : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime day) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return weekdays[day.weekday - 1];
  }
}

// ---------------------------------------------------------------------------
// Topic + workout cards
// ---------------------------------------------------------------------------
class _TopicGrid extends StatelessWidget {
  final List<ExerciseTopic> topics;
  final void Function(ExerciseTopic) onTap;

  const _TopicGrid({required this.topics, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return TopicCard(
          title: topic.title,
          subtitle: null,
          icon: topic.icon,
          backgroundColor: topic.backgroundColor,
          borderColor: topic.accentColor.withValues(alpha: 0.35),
          iconColor: topic.accentColor,
          onTap: () => onTap(topic),
        );
      },
    );
  }
}

class _SideBySideTopicsRow extends StatelessWidget {
  final ExerciseTopic topic1;
  final ExerciseTopic topic2;
  final void Function(ExerciseTopic) onTap;

  const _SideBySideTopicsRow({
    required this.topic1,
    required this.topic2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              TopicCard(
                title: topic1.title,
                subtitle: null,
                icon: topic1.icon,
                backgroundColor: topic1.backgroundColor,
                borderColor: topic1.accentColor.withValues(alpha: 0.35),
                iconColor: topic1.accentColor,
                onTap: () => onTap(topic1),
              ),
              const SizedBox(height: 12),
              TopicCard(
                title: topic2.title,
                subtitle: null,
                icon: topic2.icon,
                backgroundColor: topic2.backgroundColor,
                borderColor: topic2.accentColor.withValues(alpha: 0.35),
                iconColor: topic2.accentColor,
                onTap: () => onTap(topic2),
              ),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TopicCard(
                  title: topic1.title,
                  subtitle: null,
                  icon: topic1.icon,
                  backgroundColor: topic1.backgroundColor,
                  borderColor: topic1.accentColor.withValues(alpha: 0.35),
                  iconColor: topic1.accentColor,
                  onTap: () => onTap(topic1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TopicCard(
                  title: topic2.title,
                  subtitle: null,
                  icon: topic2.icon,
                  backgroundColor: topic2.backgroundColor,
                  borderColor: topic2.accentColor.withValues(alpha: 0.35),
                  iconColor: topic2.accentColor,
                  onTap: () => onTap(topic2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final ExerciseWorkout workout;
  final VoidCallback onTap;

  const _WorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: workout.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: workout.accentColor.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(workout.icon, size: 22, color: workout.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    workout.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _WorkoutTag(
                        icon: Icons.schedule_rounded,
                        label: '${workout.durationMinutes} min',
                        color: workout.accentColor,
                      ),
                      _WorkoutTag(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: workout.difficulty,
                        color: workout.accentColor,
                      ),
                      _WorkoutTag(
                        icon: Icons.self_improvement_rounded,
                        label: workout.equipment,
                        color: const Color(0xFF45B69C),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _WorkoutTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Achievement badge with a one-time celebration animation on unlock
// ---------------------------------------------------------------------------
class _AchievementBadge extends StatefulWidget {
  final ExerciseAchievement achievement;
  final bool unlocked;

  const _AchievementBadge({
    required this.achievement,
    required this.unlocked,
  });

  @override
  State<_AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<_AchievementBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _celebrated = false;

  @override
  void didUpdateWidget(covariant _AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unlocked && !oldWidget.unlocked && !_celebrated) {
      _celebrated = true;
      _pop.forward();
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;
    final unlocked = widget.unlocked;

    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final t = _pop.value;
        final scale = unlocked && _pop.isAnimating
            ? 1.0 + 0.12 * math.sin(t * math.pi)
            : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: AnimatedScale(
        scale: unlocked ? 1.0 : 0.96,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked
                ? achievement.background
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unlocked
                  ? achievement.color.withValues(alpha: 0.5)
                  : AppColors.borderGrey,
              width: unlocked ? 1.4 : 1,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: achievement.color.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? achievement.color.withValues(alpha: 0.16)
                          : Colors.white,
                      border: Border.all(
                        color: unlocked
                            ? achievement.color.withValues(alpha: 0.5)
                            : AppColors.borderGrey,
                      ),
                    ),
                    child: Icon(
                      unlocked
                          ? achievement.icon
                          : Icons.lock_outline_rounded,
                      size: 19,
                      color: unlocked
                          ? achievement.color
                          : AppColors.textLight,
                    ),
                  ),
                  if (unlocked)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: achievement.color,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: unlocked
                            ? AppColors.textDark
                            : AppColors.textLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        height: 1.35,
                        color: unlocked
                            ? AppColors.textMedium
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Motivation + celebration widgets
// ---------------------------------------------------------------------------
class _MotivationCard extends StatefulWidget {
  const _MotivationCard();

  @override
  State<_MotivationCard> createState() => _MotivationCardState();
}

class _MotivationCardState extends State<_MotivationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final index =
            (_controller.value * exerciseMotivationMessages.length).floor();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0FDF4), Color(0xFFE5EBFF)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: exerciseBlueBorder.withValues(alpha: 0.6),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: Column(
              key: ValueKey(index),
              children: [
                const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 26,
                  color: Color(0xFF45B69C),
                ),
                const SizedBox(height: 8),
                Text(
                  exerciseMotivationMessages[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CelebrationBanner extends StatelessWidget {
  final ExerciseAchievement achievement;

  const _CelebrationBanner({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: achievement.color.withValues(alpha: 0.6),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: achievement.color.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: achievement.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 22,
                  color: achievement.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievement unlocked!',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Text(
                      achievement.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Log activity bottom sheet — real movement done outside guided workouts
// ---------------------------------------------------------------------------
class _LogActivitySheet extends ConsumerStatefulWidget {
  const _LogActivitySheet();

  @override
  ConsumerState<_LogActivitySheet> createState() =>
      _LogActivitySheetState();
}

class _LogActivitySheetState extends ConsumerState<_LogActivitySheet> {
  String _type = 'walk';
  int _minutes = 10;
  bool _saving = false;

  static const _types = [
    (
      id: 'walk',
      label: 'Walk',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFF45B69C),
    ),
    (
      id: 'strength',
      label: 'Strength',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF7B4397),
    ),
    (
      id: 'yoga',
      label: 'Yoga',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF9D76C1),
    ),
    (
      id: 'mobility',
      label: 'Mobility',
      icon: Icons.accessibility_new_rounded,
      color: Color(0xFF6495ED),
    ),
    (
      id: 'cardio',
      label: 'Cardio',
      icon: Icons.favorite_rounded,
      color: Color(0xFFC94A6E),
    ),
    (
      id: 'gentle',
      label: 'Gentle',
      icon: Icons.spa_outlined,
      color: Color(0xFFE8A33D),
    ),
  ];

  static const _minuteOptions = [5, 10, 15, 20, 30];

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ref
        .read(exerciseProgressProvider)
        .logSession(activityType: _type, durationMinutes: _minutes);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log a movement session',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Moved outside a guided workout? Log it here — it counts for '
              'your streak and achievements.',
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in _types)
                  GestureDetector(
                    onTap: () => setState(() => _type = type.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _type == type.id
                            ? type.color.withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _type == type.id
                              ? type.color
                              : AppColors.borderGrey,
                          width: _type == type.id ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                            color: _type == type.id
                                ? type.color
                                : AppColors.textLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _type == type.id
                                  ? type.color
                                  : AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'How long?',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in _minuteOptions)
                  GestureDetector(
                    onTap: () => setState(() => _minutes = minutes),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _minutes == minutes
                            ? exerciseBlueDeep.withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _minutes == minutes
                              ? exerciseBlueDeep
                              : AppColors.borderGrey,
                          width: _minutes == minutes ? 1.6 : 1,
                        ),
                      ),
                      child: Text(
                        '$minutes min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _minutes == minutes
                              ? exerciseBlueDeep
                              : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: exerciseBlueDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: Text(
                  _saving ? 'Saving…' : 'Log activity',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
