import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Hero banner for the Learn section.
///
/// Reuses the same animated visual treatment used on the SYNCO dashboard
/// (assets/images/dashboard_hero_girl.png) and wraps it in a slow, calm
/// floating motion so it matches the dashboard's soft animated style.
class LearnHeroCard extends StatefulWidget {
  const LearnHeroCard({super.key});

  @override
  State<LearnHeroCard> createState() => _LearnHeroCardState();
}

class _LearnHeroCardState extends State<LearnHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 370;
    final imageWidth = (screenWidth * 0.33).clamp(100.0, 128.0);

    final headlineFontSize = isCompact ? 21.0 : 24.0;
    final sublineFontSize = isCompact ? 13.5 : 15.0;
    final textGap = isCompact ? 4.0 : 8.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F5), Color(0xFFF4EFFB)],
        ),
        border: Border.all(
          color: AppColors.blushPinkLight.withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -26,
              top: -38,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.lavenderAccent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.blushPinkLight.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 14 : 18,
                vertical: isCompact ? 10 : 14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Know more.',
                          style: GoogleFonts.outfit(
                            fontSize: headlineFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -0.3,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: textGap),
                        Text(
                          'Understand better.',
                          style: GoogleFonts.outfit(
                            fontSize: sublineFontSize,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: AppColors.softPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Live healthier.',
                          style: GoogleFonts.outfit(
                            fontSize: sublineFontSize,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: AppColors.softPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isCompact ? 4 : 8),
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: imageWidth,
                      height: imageWidth * 1.15,
                      child: Image.asset(
                        'assets/images/dashboard_hero_girl.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.self_improvement_rounded,
                            size: imageWidth * 0.55,
                            color: AppColors.softPurple,
                          );
                        },
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