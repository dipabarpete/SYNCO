import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'data/exercise_achievements.dart';
import 'data/exercise_workout.dart';
import 'providers/exercise_provider.dart';
import 'widgets/article_widgets.dart';
import 'widgets/exercise_visuals.dart';

/// Guided workout player for a single [ExerciseWorkout].
///
/// Walks the user through timed steps (with pause/skip), and only records a
/// completed movement session when the workout is genuinely finished — or
/// when the user ends early, in which case the real elapsed minutes are
/// recorded. Achievements unlock strictly from these real records.
class ExerciseWorkoutScreen extends ConsumerStatefulWidget {
  final ExerciseWorkout workout;

  const ExerciseWorkoutScreen({super.key, required this.workout});

  @override
  ConsumerState<ExerciseWorkoutScreen> createState() =>
      _ExerciseWorkoutScreenState();
}

class _ExerciseWorkoutScreenState extends ConsumerState<ExerciseWorkoutScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _started = false;
  bool _paused = false;
  bool _saved = false;
  int _energyLevel = 0;

  int get _totalSeconds =>
      widget.workout.steps.fold(0, (sum, step) => sum + step.seconds);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _started = true;
      _paused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused) return;
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _totalSeconds) {
          _timer?.cancel();
        }
      });
    });
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
  }

  void _skipToEndOfCurrentStep() {
    final elapsedInStep = _currentStepElapsed();
    setState(() {
      _elapsedSeconds = math.min(
        _elapsedSeconds + (currentStep.seconds - elapsedInStep),
        _totalSeconds,
      );
    });
    if (_elapsedSeconds >= _totalSeconds) _timer?.cancel();
  }

  int _currentStepIndex() {
    var remaining = _elapsedSeconds;
    for (var i = 0; i < widget.workout.steps.length; i++) {
      if (remaining < widget.workout.steps[i].seconds) return i;
      remaining -= widget.workout.steps[i].seconds;
    }
    return widget.workout.steps.length - 1;
  }

  int _currentStepElapsed() {
    var remaining = _elapsedSeconds;
    for (var i = 0; i < widget.workout.steps.length; i++) {
      if (remaining < widget.workout.steps[i].seconds) return remaining;
      remaining -= widget.workout.steps[i].seconds;
    }
    return widget.workout.steps.last.seconds;
  }

  ExerciseStep get currentStep =>
      widget.workout.steps[_currentStepIndex()];

  bool get _completed => _elapsedSeconds >= _totalSeconds;

  String get _timeLabel {
    final total = _elapsedSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _saveSession({required bool completed}) async {
    if (_saved) return;
    setState(() => _saved = true);
    _timer?.cancel();

    final durationMinutes = completed
        ? widget.workout.durationMinutes
        : (_elapsedSeconds / 60).ceil().clamp(1, widget.workout.durationMinutes);

    final controller = ref.read(exerciseProgressProvider);
    final unlocked = await controller.logSession(
      activityType: widget.workout.activityType,
      durationMinutes: durationMinutes,
      workoutId: widget.workout.id,
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _SessionSavedDialog(
        workout: widget.workout,
        completed: completed,
        durationMinutes: durationMinutes,
        unlocked: unlocked,
      ),
    );
  }

  void _confirmFinishEarly() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Finish early?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'That is completely okay — some days are shorter. '
          'Your movement so far will be saved.',
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep moving'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.workout.accentColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _saveSession(completed: false);
            },
            child: const Text('Save & finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
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
          'Beginner Workouts',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(workout),
            if (!_started) ...[
              if (workout.id == 'low-energy') ...[
                const SizedBox(height: 16),
                _EnergyAdaptCard(
                  level: _energyLevel,
                  onChanged: (v) => setState(() => _energyLevel = v),
                ),
              ] else if (workout.id == 'low-impact') ...[
                const SizedBox(height: 16),
                const LowImpactMarchVisual(),
              ] else if (workout.id == 'yoga-relaxation') ...[
                const SizedBox(height: 16),
                const BreathRingVisual(),
              ],
              const SizedBox(height: 20),
              const ArticleSectionHeading(
                title: 'Your steps',
                icon: Icons.list_alt_rounded,
              ),
              for (var i = 0; i < workout.steps.length; i++)
                _StepListTile(
                  step: workout.steps[i],
                  index: i + 1,
                  accent: workout.accentColor,
                ),
              const SizedBox(height: 16),
              _buildSafetyNote(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: workout.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _start,
                  child: Text(
                    'Start workout',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else if (_completed) ...[
              const SizedBox(height: 16),
              _CompletionCard(workout: workout),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: workout.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _saved ? null : () => _saveSession(completed: true),
                  child: Text(
                    _saved ? 'Saved — well done!' : 'Finish & save session',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              _buildPlayer(workout),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ExerciseWorkout workout) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            workout.backgroundColor,
            Color.lerp(workout.backgroundColor, workout.accentColor, 0.1)!,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: workout.accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  workout.icon,
                  size: 26,
                  color: workout.accentColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeaderChip(
                icon: Icons.schedule_rounded,
                label: '${workout.durationMinutes} min',
                color: workout.accentColor,
              ),
              const SizedBox(width: 8),
              _HeaderChip(
                icon: Icons.signal_cellular_alt_rounded,
                label: workout.difficulty,
                color: workout.accentColor,
              ),
              const SizedBox(width: 8),
              _HeaderChip(
                icon: Icons.self_improvement_rounded,
                label: workout.equipment,
                color: workout.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: workout.accentColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.volunteer_activism_outlined,
                  size: 17,
                  color: AppColors.softPurple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    workout.gentleNote,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8A33D).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.healing_rounded,
            size: 18,
            color: Color(0xFFE8A33D),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Stop if an exercise causes pain. Choose a lower-intensity option if you are '
              'tired or uncomfortable — and talk to a qualified healthcare professional if '
              'you have a health condition, injury, or are unsure whether this is right for you.',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(ExerciseWorkout workout) {
    final step = currentStep;
    final stepIndex = _currentStepIndex();
    final elapsedInStep = _currentStepElapsed();
    final remaining = step.seconds - elapsedInStep;
    final progress =
        (_elapsedSeconds / _totalSeconds).clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: workout.accentColor.withValues(alpha: 0.35),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: workout.accentColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(workout.accentColor),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: workout.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: workout.accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      step.icon,
                      size: 26,
                      color: workout.accentColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${stepIndex + 1} of ${workout.steps.length}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.detail,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: remaining / step.seconds,
                      strokeWidth: 8,
                      backgroundColor:
                          workout.accentColor.withValues(alpha: 0.12),
                      valueColor:
                          AlwaysStoppedAnimation(workout.accentColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _formatSeconds(remaining),
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'remaining',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: $_timeLabel',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _togglePause,
                      icon: Icon(
                        _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        size: 18,
                      ),
                      label: Text(_paused ? 'Resume' : 'Pause'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: workout.accentColor,
                        side: BorderSide(
                          color: workout.accentColor.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _skipToEndOfCurrentStep,
                      icon: const Icon(Icons.skip_next_rounded, size: 18),
                      label: const Text('Skip'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMedium,
                        side: BorderSide(
                          color: AppColors.borderGrey.withValues(alpha: 0.9),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: _confirmFinishEarly,
          icon: const Icon(Icons.flag_outlined, size: 17),
          label: const Text('Finish early — that\u2019s okay'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMedium),
        ),
      ],
    );
  }

  String _formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepListTile extends StatelessWidget {
  final ExerciseStep step;
  final int index;
  final Color accent;

  const _StepListTile({
    required this.step,
    required this.index,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Icon(step.icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$index. ${step.name}',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.detail,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${step.seconds}s',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final ExerciseWorkout workout;

  const _CompletionCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [workout.backgroundColor, const Color(0xFFE5EBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: workout.accentColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 34,
            color: exerciseBlueDeep,
          ),
          const SizedBox(height: 8),
          Text(
            'Nice work!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You showed up today. Consistency matters more than perfection.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Save your session to grow your streak and unlock achievements.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSavedDialog extends StatelessWidget {
  final ExerciseWorkout workout;
  final bool completed;
  final int durationMinutes;
  final List<ExerciseAchievement> unlocked;

  const _SessionSavedDialog({
    required this.workout,
    required this.completed,
    required this.durationMinutes,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final message = exerciseMotivationMessages[
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) %
            exerciseMotivationMessages.length];
    return AlertDialog(
      backgroundColor: AppColors.creamWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Icon(
            completed
                ? Icons.celebration_rounded
                : Icons.flag_rounded,
            color: exerciseBlueDeep,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              completed ? 'Workout saved' : 'Saved',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your $durationMinutes-minute movement session was recorded. $message',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
          if (unlocked.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final achievement in unlocked)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: achievement.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: achievement.color.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      achievement.icon,
                      size: 20,
                      color: achievement.color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Achievement unlocked: ${achievement.title}',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              completed
                  ? 'Rest is part of taking care of yourself — enjoy the calm after movement.'
                  : 'Some days need a lighter version of movement. You listened to your body — that matters.',
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ],
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: workout.accentColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// Interactive "energy slider" used by the low-energy workout.
///
/// As the slider moves toward "Low", the suggested intensity adapts downward —
/// communicating that lighter versions of movement are always acceptable.
class _EnergyAdaptCard extends StatelessWidget {
  final int level;
  final ValueChanged<int> onChanged;

  const _EnergyAdaptCard({required this.level, required this.onChanged});

  static const _content = [
    (
      title: 'Low energy',
      icon: Icons.battery_alert_rounded,
      color: Color(0xFFE8A33D),
      options: [
        'A slow stroll around the room, or in place',
        'Soft seated stretching within comfort',
        'A short breathing break',
      ],
    ),
    (
      title: 'Some energy',
      icon: Icons.battery_3_bar_rounded,
      color: Color(0xFF5B7FFF),
      options: [
        'A little walking at an easy pace',
        'Standing mobility — gentle arm and leg moves',
        'A few slow shoulder rolls',
      ],
    ),
    (
      title: 'Brighter',
      icon: Icons.battery_full_rounded,
      color: Color(0xFF45B69C),
      options: [
        'A slightly longer stroll if it feels right',
        'Easy strength — a few chair squats',
        'Yoga or mobility, your way',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final item = _content[level];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8A33D).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 18,
                color: Color(0xFFE8A33D),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'How\u2019s your energy today?',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Some days need a lighter version of movement — not "you must exercise every day".',
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.45,
              color: AppColors.textMedium,
            ),
          ),
          Slider(
            value: level.toDouble(),
            min: 0,
            max: 2,
            divisions: 2,
            activeColor: item.color,
            inactiveColor: item.color.withValues(alpha: 0.25),
            onChanged: (v) => onChanged(v.round()),
          ),
          Row(
            children: [
              Text(
                'Low energy',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMedium,
                ),
              ),
              const Spacer(),
              Text(
                'Brighter',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(level),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.icon, size: 16, color: item.color),
                      const SizedBox(width: 6),
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final option in item.options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: AppColors.textMedium,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                height: 1.4,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you feel significantly unwell or dangerously fatigued, rest is the right choice.',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}