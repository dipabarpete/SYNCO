import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DashboardHeroHeader extends StatelessWidget {
  final String firstName;

  const DashboardHeroHeader({
    super.key,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;

    final sectionHeight = isCompact ? 112.0 : 118.0;
    final helloFontSize = isCompact ? 23.0 : 26.0;
    final nameFontSize = isCompact ? 24.0 : 27.0;
    final emojiFontSize = isCompact ? 19.0 : 21.0;
    final subtitleFontSize = isCompact ? 14.0 : 15.5;
    final imageWidth = (screenWidth * 0.38).clamp(135.0, 162.0);
    final textImageGap = isCompact ? 6.0 : 10.0;

    return SizedBox(
      height: sectionHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hello, ',
                        style: GoogleFonts.outfit(
                          fontSize: helloFontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.3,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: '$firstName! ',
                        style: GoogleFonts.outfit(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.3,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: '✨',
                        style: TextStyle(
                          fontSize: emojiFontSize,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isCompact ? 5 : 6),
                Text(
                  'Take charge of your health today',
                  style: GoogleFonts.inter(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    letterSpacing: 0.1,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: textImageGap),
          SizedBox(
            width: imageWidth,
            height: sectionHeight,
            child: Image.asset(
              'assets/images/dashboard_hero_girl.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
