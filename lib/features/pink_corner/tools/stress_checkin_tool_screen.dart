import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../services/stress_wellbeing_local_store.dart';
import '../services/stress_wellbeing_repository.dart';

/// Stress Check-in tool — a simple, private check-in that helps the user
/// notice patterns. It is explicitly not a diagnosis or a clinical score.
class StressCheckInToolScreen extends StatefulWidget {
  const StressCheckInToolScreen({super.key});

  @override
  State<StressCheckInToolScreen> createState() => _StressCheckInToolScreenState();
}

const _blue = Color(0xFF5B7FFF);
const _blueLight = Color(0xFFF0F4FF);

class _Level {
  final String label;
  final String note;
  final IconData icon;
  final Color color;
  final Color bg;

  const _Level({
    required this.label,
    required this.note,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

const _levels = [
  _Level(
    label: 'Low',
    note: 'Feeling calm, steady or manageable',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFF2E8B76),
    bg: Color(0xFFE3F6EE),
  ),
  _Level(
    label: 'Moderate',
    note: 'Noticeable pressure, but handling it',
    icon: Icons.filter_drama_rounded,
    color: Color(0xFFE8A33D),
    bg: Color(0xFFFBF0DF),
  ),
  _Level(
    label: 'High',
    note: 'Quite a lot of pressure right now',
    icon: Icons.thunderstorm_outlined,
    color: Color(0xFFC94A6E),
    bg: Color(0xFFFFF0F3),
  ),
  _Level(
    label: 'Overwhelmed',
    note: 'Feeling like too much is happening at once',
    icon: Icons.waves_rounded,
    color: Color(0xFF7B4397),
    bg: Color(0xFFF4EFFB),
  ),
];

const _factors = [
  'Sleep',
  'Work / studies',
  'Relationships',
  'Health',
  'Other',
];

class _StressCheckInToolScreenState extends State<StressCheckInToolScreen> {
  final StressWellbeingRepository _repository = StressWellbeingRepository();
  StreamSubscription? _subscription;

  int? _selectedLevel;
  final Set<String> _selectedFactors = {};
  List<StressCheckInRecord> _history = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.streamCheckIns().listen((records) {
      if (!mounted) return;
      setState(() {
        _history = records;
        _loaded = true;
      });
    }, onError: (e) {
      debugPrint('[stress_checkin] stream error: $e');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap a level first \u2014 then save.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final record = StressCheckInRecord(
      id: 'st_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      level: _levels[_selectedLevel!].label,
      factors: _selectedFactors.toList(),
    );
    await _repository.saveCheckIn(record);
    setState(() {
      _selectedLevel = null;
      _selectedFactors.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanks for checking in with yourself. Saved to health log.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _blue,
      ),
    );
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
          'Stress Check-in',
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
            Text(
              'How are you feeling right now?',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'There\u2019s no right answer — just an honest one. This is a personal check-in '
              'to help you notice patterns over time.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Level cards
            for (var i = 0; i < _levels.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLevel = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _selectedLevel == i
                          ? _levels[i].bg
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedLevel == i
                            ? _levels[i].color
                            : AppColors.borderGrey,
                        width: _selectedLevel == i ? 1.6 : 1,
                      ),
                      boxShadow: _selectedLevel == i
                          ? [
                              BoxShadow(
                                color: _levels[i].color.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _levels[i].icon,
                            size: 20,
                            color: _levels[i].color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _levels[i].label,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _levels[i].note,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _selectedLevel == i
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 20,
                          color: _selectedLevel == i
                              ? _levels[i].color
                              : AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Optional factor question
            Text(
              'What seems to be affecting you most? (optional)',
              style: GoogleFonts.outfit(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final factor in _factors)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!_selectedFactors.remove(factor)) {
                          _selectedFactors.add(factor);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedFactors.contains(factor)
                            ? _blueLight
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedFactors.contains(factor)
                              ? _blue
                              : AppColors.borderGrey,
                          width: _selectedFactors.contains(factor) ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        factor,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedFactors.contains(factor)
                              ? _blue
                              : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save check-in',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Recent check-ins
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 20, color: _blue),
                const SizedBox(width: 8),
                Text(
                  'Your recent check-ins',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_loaded)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _blue,
                    ),
                  ),
                ),
              )
            else if (_history.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.7),
                  ),
                ),
                child: Text(
                  'No check-ins yet. Doing your first one today is a kind start.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textMedium,
                  ),
                ),
              )
            else
              for (final record in _history)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderGrey.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _levelColor(record.level),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.level}'
                              '${record.factors.isEmpty ? '' : ' \u00b7 ${record.factors.join(', ')}'}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              StressWellbeingLocalStore.friendlyDate(record.date),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      'This check-in is for noticing patterns only — it is not a mental-health '
                      'diagnosis or a clinical score. If you\u2019re worried about how you\u2019re '
                      'feeling, talking to a healthcare professional is the best step.',
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

  Color _levelColor(String label) {
    for (final level in _levels) {
      if (level.label == label) return level.color;
    }
    return AppColors.textLight;
  }
}