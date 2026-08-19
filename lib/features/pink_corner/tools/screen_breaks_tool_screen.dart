import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Screen Breaks tool — a practical mini-reminder with gentle, optional
/// timers. Presented as helpful suggestions, never medical requirements.
class ScreenBreaksToolScreen extends StatefulWidget {
  const ScreenBreaksToolScreen({super.key});

  @override
  State<ScreenBreaksToolScreen> createState() => _ScreenBreaksToolScreenState();
}

const _peach = Color(0xFFFFB085);
const _peachLight = Color(0xFFFFF7ED);

class _ScreenBreaksToolScreenState extends State<ScreenBreaksToolScreen> {
  Timer? _timer;
  int _secondsLeft = 0;
  int _totalSeconds = 0;
  int _stage = 0;
  bool _isRunning = false;
  String _timerTitle = '';

  static const _stages = [
    'Roll your shoulders gently',
    'Look at something far away',
    'Breathe in slowly \u2014 out slowly',
    'Finish with a gentle stretch',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(String title, int totalSeconds) {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
      _timerTitle = title;
      _totalSeconds = totalSeconds;
      _secondsLeft = totalSeconds;
      _stage = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft -= 1;
        final elapsed = _totalSeconds - _secondsLeft;
        final stageLength = _totalSeconds / _stages.length;
        _stage = (elapsed / stageLength).floor().clamp(0, _stages.length - 1);
        if (_secondsLeft <= 0) {
          timer.cancel();
          _isRunning = false;
        }
      });
    });
  }

  void _cancel() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  String get _timeLabel {
    final minutes = _secondsLeft ~/ 60;
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
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
          'Screen Breaks',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sequence visual: Screen → Pause → Look away → Stretch → Return
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _peachLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _peach.withValues(alpha: 0.35)),
              ),
              child: Column(
                children: [
                  Text(
                    'A simple rhythm for your eyes and body',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _peach,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      _SequenceChip(icon: Icons.smartphone_rounded, label: 'Screen'),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textLight),
                      _SequenceChip(icon: Icons.pause_rounded, label: 'Pause'),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textLight),
                      _SequenceChip(icon: Icons.visibility_off_outlined, label: 'Look away'),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textLight),
                      _SequenceChip(icon: Icons.self_improvement_rounded, label: 'Stretch / breathe'),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textLight),
                      _SequenceChip(icon: Icons.restart_alt_rounded, label: 'Return'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Timer card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.borderGrey.withValues(alpha: 0.7),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _isRunning ? _timerTitle : 'Try a quick break',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isRunning) ...[
                    Text(
                      _timeLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: _peach,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _stages[_stage],
                        key: ValueKey(_stage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _cancel,
                      child: Text(
                        'End break early',
                        style: GoogleFonts.inter(color: AppColors.textMedium),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _TimerButton(
                            icon: Icons.remove_red_eye_outlined,
                            label: '20-second eye break',
                            onTap: () =>
                                _startTimer('Look at something about 20 feet away', 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TimerButton(
                            icon: Icons.accessibility_new_rounded,
                            label: '2-minute stretch break',
                            onTap: () => _startTimer('Stretch break', 120),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD8B4F8).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.softPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These are gentle suggestions, not rigid schedules. Take breaks in whatever '
                      'rhythm genuinely works for you.',
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
      ),
    );
  }
}

class _SequenceChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SequenceChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _peach.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _peach),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _peachLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _peach.withValues(alpha: 0.45)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: _peach),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}