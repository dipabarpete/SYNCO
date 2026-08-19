import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/meditation_provider.dart';

/// Short guided meditation tool: Pause → Notice your breathing → Relax your
/// body → Return attention gently. Optional session logging uses the app's
/// existing meditation log (kept local to the session, like the rest of the app).
class MeditationToolScreen extends ConsumerStatefulWidget {
  const MeditationToolScreen({super.key});

  @override
  ConsumerState<MeditationToolScreen> createState() =>
      _MeditationToolScreenState();
}

const _mintDeep = Color(0xFF2E8B76);
const _mintLight = Color(0xFFE9F7F1);

const _meditationSteps = [
  'Pause, and settle in',
  'Notice your breathing',
  'Relax your body gently',
  'Return your attention softly',
  'Well done \u2014 you paused',
];

class _MeditationToolScreenState extends ConsumerState<MeditationToolScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulse;
  int _durationMinutes = 3;
  int _activeStep = 0;
  bool _isRunning = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(minutes: 3));
    _controller.addListener(() {
      final next = (_controller.value * _meditationSteps.length).floor();
      if (next != _activeStep && next < _meditationSteps.length) {
        setState(() => _activeStep = next);
      }
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRunning = false;
          _isDone = true;
          _activeStep = _meditationSteps.length - 1;
        });
      }
    });
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _isDone = false;
      _activeStep = 0;
    });
    _controller.duration = Duration(minutes: _durationMinutes);
    _controller.forward(from: 0);
  }

  void _stop() {
    setState(() {
      _isRunning = false;
    });
    _controller.stop();
    _controller.reset();
    _activeStep = 0;
  }

  void _logSession() {
    ref.read(meditationProvider.notifier).addSession(_durationMinutes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $_durationMinutes minute meditation'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _mintDeep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes =
        ref.watch(meditationProvider.notifier).totalMeditationMinutes;

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
          'Meditation',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isRunning && !_isDone) ...[
              _buildIdleCard(totalMinutes),
            ] else if (_isDone) ...[
              _buildDoneCard(),
            ] else ...[
              _buildSessionCard(),
            ],
            const SizedBox(height: 14),
            Text(
              'Keep it short and kind. There is no \u201cperfect\u201d meditation — '
              'showing up for one gentle minute counts.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleCard(int totalMinutes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _mintLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _mintDeep.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.self_improvement_rounded,
                size: 40,
                color: _mintDeep.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 12),
              Text(
                'You only need a minute',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _mintDeep,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pause \u2192 notice your breathing \u2192 relax your body \u2192 return attention gently.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Choose a length',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final minutes in [1, 3, 5]) ...[
                    if (minutes != 1) const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _durationMinutes = minutes),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _durationMinutes == minutes
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _durationMinutes == minutes
                                  ? _mintDeep
                                  : AppColors.borderGrey,
                              width: _durationMinutes == minutes ? 1.6 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$minutes min',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _durationMinutes == minutes
                                    ? _mintDeep
                                    : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mintDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start meditating',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Total mindful minutes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _mintLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.self_improvement_rounded, color: _mintDeep),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total mindful minutes',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Text(
                    '$totalMinutes mins',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _mintLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mintDeep.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + _pulse.value * 0.14,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _mintDeep.withValues(alpha: 0.16),
                    border: Border.all(
                      color: _mintDeep.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _mintDeep.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _meditationSteps[_activeStep],
              key: ValueKey(_activeStep),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: _mintDeep,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: _controller.value,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            backgroundColor: _mintDeep.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(_mintDeep),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: _stop,
            child: Text(
              'End session',
              style: GoogleFonts.inter(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _mintLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mintDeep.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 30, color: _mintDeep),
          ),
          const SizedBox(height: 14),
          Text(
            'Well done \u2014 you paused',
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _mintDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You meditated for $_durationMinutes minute${_durationMinutes == 1 ? '' : 's'}. '
            'Whenever you\u2019re ready, ease back into your day — gently.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _logSession,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _mintDeep,
                  side: BorderSide(color: _mintDeep.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Log this session'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isDone = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mintDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text('Meditate again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}