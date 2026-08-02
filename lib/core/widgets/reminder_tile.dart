import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../models/reminder_item.dart';

class ReminderTile extends StatelessWidget {
  final ReminderItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  const ReminderTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.cardBackgroundColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: item.borderColor,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Left Side: Circular White Icon Container
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    size: 19,
                    color: item.iconColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Center: Title & Subtitle/Time Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.timeDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Side: Functional ON/OFF Switch
                GestureDetector(
                  onTap: () {}, // Prevents parent InkWell from triggering edit when clicking switch
                  child: Switch(
                    value: item.isEnabled,
                    onChanged: onToggle,
                    activeThumbColor: Colors.white,
                    activeTrackColor: item.iconColor,
                    inactiveThumbColor: AppColors.textLight,
                    inactiveTrackColor: AppColors.lightGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
