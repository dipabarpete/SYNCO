import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Guided breathing tool with selectable gentle patterns.
///
/// A soft circle expands during the inhale, holds briefly when the pattern
/// includes a pause, and shrinks during the exhale. Patterns are gentle
/// suggestions — there is no single "right" way to breathe.
class BreathingToolScreen extends StatefulWidget {
  const BreathingToolScreen({super.key});

  @override
  State<BreathingToolScreen> createState() => _BreathingToolScreenState();
}

class _BreathingPattern {
  final String name;
  final String label;
  final Duration inhale;
  final Duration hold;
  final Duration exhale;

  const _BreathingPattern({
    required this.name,
    required this.label,
    required this.inhale,
    required this.hold,
    required this.exhale,
  });
}

const _mintDeep = Color(0xFF45B69C);
const _mintLight = Color(0xFFE2F5EE);

const _patterns = [
  _BreathingPattern(
    name: 'Balanced',
    label: '4 \u00b7 4 \u00b7 4',
    inhale: Duration(seconds: 4),
    hold: Duration(seconds: 4),
    exhale: Duration(seconds: 4),
  ),
  _BreathingPattern(
    name: 'Gentle unwind',
    label: '4 \u00b7 2 \u00b7 6',
    inhale: Duration(seconds: 4),
    hold: Duration(seconds: 2),
    exhale: Duration(seconds: 6),
  ),
  _BreathingPattern(
    name: 'Slow calming',
    label: '4 \u00b7 7 \u00b7 8',
    inhale: Duration(seconds: 4),
    hold: Duration(seconds: 7),
    exhale: Duration(seconds: 8),
  ),
];

class _BreathingToolScreenState extends State<BreathingToolScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _patternIndex = 0;
  bool _isRunning = false;
  int _rounds = 0;

  _BreathingPattern get _pattern => _patterns[_patternIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isRunning) {
        setState(() => _rounds += 1);
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPattern(int index) {
    if (_isRunning) return;
    setState(() {
      _patternIndex = index;
      _rounds = 0;
      _controller.duration = _patterns[index].inhale +
          _patterns[index].hold +
          _patterns[index].exhale;
      _controller.reset();
    });
  }

  void _toggle() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _controller.duration =
          _pattern.inhale + _pattern.hold + _pattern.exhale;
      _rounds = 0;
      _controller.forward(from: 0);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  (double scale, String label, String hint) _metricsAt(double t) {
    final pattern = _pattern;
    final totalMillis = pattern.inhale.inMilliseconds +
        pattern.hold.inMilliseconds +
        pattern.exhale.inMilliseconds;
    final inhaleF = pattern.inhale.inMilliseconds / totalMillis;
    final holdF = (pattern.inhale.inMilliseconds + pattern.hold.inMilliseconds) / totalMillis;

    double scale;
    String label;
    String hint;
    if (t < inhaleF) {
      scale = 1.0 + 0.65 * Curves.easeInOut.transform(t / inhaleF);
      label = 'Inhale';
      hint = 'Breathe in slowly and gently';
    } else if (t < holdF) {
      scale = 1.65;
      label = 'Pause';
      hint = 'Hold softly — no straining';
    } else {
      final exhaleProgress = (t - holdF) / (1 - holdF);
      scale = 1.65 - 0.65 * Curves.easeInOut.transform(exhaleProgress);
      label = 'Exhale';
      hint = 'Let the breath go out unhurried';
    }
    return (scale, label, hint);
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
          'Breathing',
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
                    'Guided slow breathing',
                    style: GoogleFonts.outfit(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: _mintDeep,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Follow the circle — it grows as you breathe in, holds, and gently shrinks as you breathe out.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Breathing circle
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final (scale, label, hint) =
                          _isRunning ? _metricsAt(_controller.value) : (1.0, 'Ready?', 'Tap start when you feel ready');
                      return Column(
                        children: [
                          SizedBox(
                            height: 170,
                            child: Center(
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _mintDeep.withValues(alpha: 0.18),
                                    border: Border.all(
                                      color: _mintDeep.withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _mintDeep.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Column(
                              key: ValueKey(label),
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _mintDeep,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hint,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _rounds == 0
                                ? 'A few slow rounds is a great start'
                                : 'Completed $_rounds round${_rounds == 1 ? '' : 's'} \u00b7 keep going at your own pace',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _toggle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRunning ? AppColors.textMedium : _mintDeep,
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isRunning ? 'Stop' : 'Start breathing',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Pattern selector
            Text(
              'Choose a pattern',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < _patterns.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectPattern(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _patternIndex == i
                              ? _mintLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _patternIndex == i
                                ? _mintDeep
                                : AppColors.borderGrey,
                            width: _patternIndex == i ? 1.6 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _patterns[i].name,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _patternIndex == i
                                    ? _mintDeep
                                    : AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _patterns[i].label,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 14),

            // Gentle reassurance
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
                      'These are gentle suggestions, not medical instructions. If a pattern feels '
                      'uncomfortable, skip the pause or breathe at a pace that feels natural to you.',
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