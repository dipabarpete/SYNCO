import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../kyra/kyra_ai_screen.dart';
import '../../kyra/food_scanner_screen.dart';
import '../../kyra/lab_report_screen.dart';

class DashboardFeatureRow extends StatelessWidget {
  final VoidCallback? onFoodScannerTap;
  final VoidCallback? onKyraAiTap;
  final VoidCallback? onLabReportTap;

  const DashboardFeatureRow({
    super.key,
    this.onFoodScannerTap,
    this.onKyraAiTap,
    this.onLabReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Food Scanner Card (Left - Reference Card Style)
        Expanded(
          child: _buildStandaloneCard(
            context: context,
            title: 'Food\nScanner',
            icon: Icons.photo_camera_rounded,
            iconColor: AppColors.softPurple,
            badgeBgColor: AppColors.softLavender.withValues(alpha: 0.5),
            onTap: onFoodScannerTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const FoodScannerScreen(),
                    ),
                  );
                },
          ),
        ),

        const SizedBox(width: 10),

        // 2. Kyra AI Button (Center - Distinctive Purple Circular Button)
        GestureDetector(
          onTap: onKyraAiTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const KyraAiScreen(),
                  ),
                );
              },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softPurple.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kyra AI',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // 3. Lab Report Interpreter Card (Right - Reference Card Style)
        Expanded(
          child: _buildStandaloneCard(
            context: context,
            title: 'Lab Report\nInterpreter',
            icon: Icons.description_rounded,
            iconColor: AppColors.deepRose,
            badgeBgColor: AppColors.babyPink,
            onTap: onLabReportTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const LabReportScreen(),
                    ),
                  );
                },
          ),
        ),
      ],
    );
  }

  Widget _buildStandaloneCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color badgeBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 114,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.softPurple.withValues(alpha: 0.12),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Icon inside soft rounded squircle badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 8),
              // Bottom Title Text
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
