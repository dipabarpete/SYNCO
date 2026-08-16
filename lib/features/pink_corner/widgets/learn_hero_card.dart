import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Hero banner for the Learn section.
///
/// Reuses the exact same hero girl illustration as the SYNCO dashboard
/// (assets/images/dashboard_hero_girl.png) on the left, paired with a soft
/// editorial tagline on the right. The card fades/slides in gently when the
/// Learn screen opens, and the illustration slowly floats so it feels alive
/// without bouncing the rest of the card.
class LearnHeroCard extends StatefulWidget {
  const LearnHeroCard({super.key});

  @override
  State<LearnHeroCard> createState() => _LearnHeroCardState();
}

class _LearnHeroCardState extends State<LearnHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 370;

    final imageSize = (screenWidth * 0.30).clamp(100.0, 132.0);

    final headlineFontSize = isCompact ? 21.0 : 24.0;
    final sublineFontSize = isCompact ? 13.5 : 15.0;
    final textGap = isCompact ? 4.0 : 8.0;
    final textImageGap = isCompact ? 10.0 : 14.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
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
                  vertical: isCompact ? 12 : 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LEFT: exact same dashboard hero girl, gently floating.
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: Image.asset(
                          'assets/images/dashboard_hero_girl.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.self_improvement_rounded,
                              size: imageSize * 0.55,
                              color: AppColors.softPurple,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: textImageGap),
                    // RIGHT: editorial tagline.
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
                              letterSpacing: -0.4,
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
                              height: 1.25,
                              letterSpacing: 0.1,
                              color: AppColors.softPurple,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: textGap * 0.75),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [Color(0xFFC94A6E), Color(0xFF7B4397)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              'Live healthier.',
                              style: GoogleFonts.outfit(
                                fontSize: sublineFontSize,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: 0.1,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}