import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Progressive Muscle Relaxation tool — a gentle, educational version.
///
/// For each body part: notice tension → gently tense → release → notice the
/// difference. Tension is always gentle (~50% effort) and can be skipped
/// entirely; nothing here should ever hurt.
class PmrToolScreen extends StatefulWidget {
  const PmrToolScreen({super.key});

  @override
  State<PmrToolScreen> createState() => _PmrToolScreenState();
}

const _mintDeep = Color(0xFF45B69C);
const _mintLight = Color(0xFFE2F5EE);

class _BodyPart {
  final String name;
  final String description;
  final IconData icon;

  const _BodyPart({
    required this.name,
    required this.description,
    required this.icon,
  });
}

const _bodyParts = [
  _BodyPart(
    name: 'Hands and arms',
    description: 'Make gentle fists, soften, let go',
    icon: Icons.back_hand_rounded,
  ),
  _BodyPart(
    name: 'Shoulders',
    description: 'Lift them a little, then let them drop',
    icon: Icons.accessibility_new_rounded,
  ),
  _BodyPart(
    name: 'Jaw and face',
    description: 'Soften your jaw, relax your forehead',
    icon: Icons.face_outlined,
  ),
  _BodyPart(
    name: 'Feet and legs',
    description: 'Press gently, release, and notice',
    icon: Icons.airline_seat_legroom_normal_rounded,
  ),
];

const _phases = [
  (label: 'Notice', seconds: 4, message: 'Bring your attention lightly to this part of your body.'),
  (label: 'Gently tense', seconds: 6, message: 'Tense it softly — about half effort — and hold.'),
  (label: 'Release', seconds: 10, message: 'Let go completely. Breathe out as you soften.'),
  (label: 'Notice the difference', seconds: 4, message: 'Feel the calm contrast where you just let go.'),
];

class _PmrToolScreenState extends State<PmrToolScreen> {
  Timer? _timer;
  int _part = 0;
  int _phase = 0;
  int _secondsLeft = 0;
  bool _isRunning = false;
  bool _isDone = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _isDone = false;
      _part = 0;
      _phase = 0;
      _secondsLeft = _phases[0].seconds;
    });
    _tick();
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _advance();
        }
      });
    });
  }

  void _advance() {
    if (_phase < _phases.length - 1) {
      _phase += 1;
      _secondsLeft = _phases[_phase].seconds;
    } else if (_part < _bodyParts.length - 1) {
      _part += 1;
      _phase = 0;
      _secondsLeft = _phases[0].seconds;
    } else {
      _timer?.cancel();
      _isRunning = false;
      _isDone = true;
    }
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _part = 0;
      _phase = 0;
    });
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
          'Muscle Relaxation',
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
            if (_isDone)
              _buildDoneCard()
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _mintLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _mintDeep.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _isRunning
                          ? 'Step ${_part + 1} of ${_bodyParts.length}'
                          : 'Tense and release, gently',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _mintDeep,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_isRunning) ...[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Column(
                          key: ValueKey('$_part-$_phase'),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _bodyParts[_part].icon,
                                  size: 26,
                                  color: _mintDeep,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    _bodyParts[_part].name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _bodyParts[_part].description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _phases[_phase].label,
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: _mintDeep,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _phases[_phase].message,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      height: 1.45,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$_secondsLeft s',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: _mintDeep,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: _secondsLeft /
                                    _phases[_phase].seconds,
                                minHeight: 5,
                                backgroundColor:
                                    _mintDeep.withValues(alpha: 0.12),
                                valueColor:
                                    const AlwaysStoppedAnimation(_mintDeep),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _stop,
                        child: Text(
                          'Stop',
                          style: GoogleFonts.inter(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.spa_rounded,
                        size: 42,
                        color: _mintDeep.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Slowly move through four gentle steps for each part of the body:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < _phases.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _mintDeep,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${_phases[i].label} — ${_phases[i].message}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _start,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mintDeep,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Start — about 2 minutes',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8A33D).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFE8A33D),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tense only gently — about half of your full effort. If any part of this '
                      'ever feels painful or uncomfortable, stop right away or skip it entirely.',
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

  Widget _buildDoneCard() {
    return Container(
      padding: const EdgeInsets.all(28),
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
            child: const Icon(Icons.check_rounded, size: 30, color: _mintDeep),
          ),
          const SizedBox(height: 14),
          Text(
            'Whole body, gently released',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _mintDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a moment to notice how your body feels now. If you\u2019d like to go '
            'again, plenty of people repeat the loop twice.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 20),
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
              'Do it again',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}