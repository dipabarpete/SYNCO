import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/exercise_provider.dart';
import '../services/exercise_local_store.dart';

const Color exerciseBlueDeep = Color(0xFF5B7FFF);

/// Reusable "Your Movement" card widget.
///
/// Displays real-time movement progress (Streak, Sessions, Minutes) and weekly
/// timeline powered by [exerciseProgressProvider]. Shared between the main
/// Learn screen and the Exercise & Movement screen.
class YourMovementCard extends ConsumerWidget {
  final VoidCallback? onLogActivity;

  const YourMovementCard({super.key, this.onLogActivity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(exerciseProgressProvider);
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
              if (onLogActivity != null)
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

class _WeeklyTimeline extends StatelessWidget {
  final List<ExerciseSession> sessions;

  const _WeeklyTimeline({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final byDay = <DateTime, int>{};
    for (final session in sessions) {
      final day = _dayOnly(session.date);
      byDay[day] = (byDay[day] ?? 0) + session.durationMinutes;
    }

    final today = _dayOnly(DateTime.now());
    final maxMinutes = byDay.values.fold<int>(0, (a, b) => math.max(a, b));

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

  static DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
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
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isToday = today == day;
    final height = minutes == 0
        ? 6.0
        : 8.0 + (46.0 * (minutes / (maxMinutes == 0 ? 1 : maxMinutes)));

    return Column(
      children: [
        if (minutes > 0)
          const Icon(
            Icons.local_fire_department_rounded,
            size: 13,
            color: Color(0xFFFF7A59),
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
