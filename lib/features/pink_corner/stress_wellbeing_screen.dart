import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/meditation_provider.dart';

class StressWellbeingScreen extends ConsumerStatefulWidget {
  const StressWellbeingScreen({super.key});

  @override
  ConsumerState<StressWellbeingScreen> createState() => _StressWellbeingScreenState();
}

class _StressWellbeingScreenState extends ConsumerState<StressWellbeingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  bool _isBreathing = false;
  String _breathingText = "Ready to relax?";
  final Color _mintGreen = const Color(0xFF45B69C);
  final Color _lightMint = const Color(0xFFE2F5EE);

  @override
  void initState() {
    super.initState();
    // A 4-second inhale, 4-second exhale cycle
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathingText = "Breathe Out...";
        });
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed && _isBreathing) {
        setState(() {
          _breathingText = "Breathe In...";
        });
        _breathingController.forward();
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathingText = "Breathe In...";
        _breathingController.forward();
      } else {
        _breathingText = "Ready to relax?";
        _breathingController.stop();
        _breathingController.reverse();
      }
    });
  }

  void _showLogMeditationDialog() {
    final TextEditingController minutesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Log Meditation',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          content: TextField(
            controller: minutesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Duration (minutes)',
              hintStyle: GoogleFonts.inter(color: AppColors.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.softPurple),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.softPurple, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMedium)),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(minutesController.text.trim());
                if (minutes != null && minutes > 0) {
                  ref.read(meditationProvider.notifier).addSession(minutes);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _mintGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Log', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meditationLogs = ref.watch(meditationProvider);
    final totalMinutes = ref.watch(meditationProvider.notifier).totalMeditationMinutes;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Stress & Wellbeing',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Breathing Exercise Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: _lightMint,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _mintGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Guided Breathing',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _mintGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a moment to center yourself',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Animated Breathing Circle
                  SizedBox(
                    height: 180,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _mintGreen.withValues(alpha: 0.2),
                                border: Border.all(color: _mintGreen, width: 2),
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _mintGreen.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  Text(
                    _breathingText,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _mintGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _toggleBreathing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBreathing ? AppColors.textMedium : _mintGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isBreathing ? 'Stop' : 'Start Breathing',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Meditation Log Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meditation Log',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showLogMeditationDialog,
                  icon: Icon(Icons.add_rounded, color: _mintGreen),
                  label: Text('Log Time', style: TextStyle(color: _mintGreen)),
                )
              ],
            ),
            const SizedBox(height: 8),
            
            // Total Time Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lightMint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.self_improvement_rounded, color: _mintGreen),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Mindful Minutes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                      Text(
                        '$totalMinutes mins',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Recent Sessions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            
            if (meditationLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No sessions logged yet. Take a deep breath and start today!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textLight),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meditationLogs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = meditationLogs[index];
                  // Simple date formatting
                  final dateStr = "${log.date.month}/${log.date.day}/${log.date.year}";
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.softLavender),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: _mintGreen, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              dateStr,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${log.durationMinutes} min',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _mintGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
