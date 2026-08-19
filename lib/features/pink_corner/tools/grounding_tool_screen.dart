import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Grounding exercise tool — the 5-4-3-2-1 senses sequence.
///
/// Presented as an interactive step-by-step walk-through: the user taps
/// "Next" after each step.
class GroundingToolScreen extends StatefulWidget {
  const GroundingToolScreen({super.key});

  @override
  State<GroundingToolScreen> createState() => _GroundingToolScreenState();
}

const _blue = Color(0xFF5B7FFF);
const _blueLight = Color(0xFFF0F4FF);

class _GroundingStep {
  final int count;
  final String sense;
  final String hint;
  final IconData icon;

  const _GroundingStep({
    required this.count,
    required this.sense,
    required this.hint,
    required this.icon,
  });
}

const _steps = [
  _GroundingStep(
    count: 5,
    sense: 'things you can see',
    hint: 'Look slowly around your space — colours, shapes, light, even small details.',
    icon: Icons.visibility_outlined,
  ),
  _GroundingStep(
    count: 4,
    sense: 'things you can feel',
    hint: 'The clothes on your skin, the chair under you, the warmth or coolness of the air.',
    icon: Icons.touch_app_rounded,
  ),
  _GroundingStep(
    count: 3,
    sense: 'things you can hear',
    hint: 'Sounds near and far — a fan, traffic, birds, your own breathing.',
    icon: Icons.hearing_rounded,
  ),
  _GroundingStep(
    count: 2,
    sense: 'things you can smell',
    hint: 'Breathe in gently. Plain air counts — so does a familiar scent nearby.',
    icon: Icons.local_florist_outlined,
  ),
  _GroundingStep(
    count: 1,
    sense: 'thing you can taste',
    hint: 'A sip of water, the taste in your mouth, or a tiny piece of something you enjoy.',
    icon: Icons.restaurant_outlined,
  ),
];

class _GroundingToolScreenState extends State<GroundingToolScreen> {
  int _step = 0;
  bool _done = false;

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step += 1);
    } else {
      setState(() => _done = true);
    }
  }

  void _restart() {
    setState(() {
      _step = 0;
      _done = false;
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
          'Grounding',
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
            if (!_done) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'The 5-4-3-2-1 senses walk',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A gentle way to land back in the present moment — '
                      'step by step, sense by sense.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        height: 1.5,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _steps.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: i == _step ? 22 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: i <= _step
                                    ? _blue
                                    : _blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Column(
                        key: ValueKey(_step),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _blue.withValues(alpha: 0.18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _steps[_step].icon,
                              size: 34,
                              color: _blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${_steps[_step].count}',
                            style: GoogleFonts.outfit(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: _blue,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _steps[_step].sense,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _steps[_step].hint,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _step < _steps.length - 1 ? 'Next step' : 'Finish',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _restart,
                      child: Text(
                        'Start over',
                        style: GoogleFonts.inter(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.self_improvement_rounded,
                        size: 34,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You made it back — here, now',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Notice the room around you once more. You can repeat this '
                      'anytime — a single step is enough on rougher days.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _restart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
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
                        'Go again',
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
            ],
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
                      'No need to "do it perfectly" — naming even one thing you can '
                      'see is a grounding win.',
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