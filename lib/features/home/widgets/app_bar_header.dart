import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AppBarHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final bool isPartnerLinked;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onPartnerTap;
  final VoidCallback? onNotificationTap;

  const AppBarHeader({
    super.key,
    this.userName = 'Ananya',
    this.avatarUrl = '',
    this.isPartnerLinked = false,
    this.onAvatarTap,
    this.onPartnerTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Circular Profile Avatar with Pastel Ring
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blushPink.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.babyPink,
              child: avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => _buildFallbackAvatar(),
                      ),
                    )
                  : _buildFallbackAvatar(),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // SYNCO Brand Name
        Text(
          'SYNCO',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            letterSpacing: 1.5,
          ),
        ),

        const Spacer(),

        // Right Side: Notification Icon with Badge
        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.softPurpleLight.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.softPurple,
                  size: 24,
                ),
              ),
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.rosePink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 46,
      height: 46,
      color: AppColors.babyPink,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.softPurple,
        size: 24,
      ),
    );
  }
}
