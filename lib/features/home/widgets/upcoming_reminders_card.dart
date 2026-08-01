import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/reminder_tile.dart';

class UpcomingRemindersCard extends StatefulWidget {
  const UpcomingRemindersCard({super.key});

  @override
  State<UpcomingRemindersCard> createState() => _UpcomingRemindersCardState();
}

class _UpcomingRemindersCardState extends State<UpcomingRemindersCard> {
  // Local dummy state for the required 4 reminders
  final Map<String, bool> _reminderStates = {
    'Water Intake': true,
    'Supplements': true,
    'Exercise': true,
    'Sleep': false,
  };

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> remindersList = [
      {
        'title': 'Water Intake',
        'subtitle': 'Drink 250ml fresh water',
        'time': '10:30 AM',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.waterColor,
      },
      {
        'title': 'Supplements',
        'subtitle': 'Multivitamin & Spearmint Tea',
        'time': '1:00 PM',
        'icon': Icons.medication_rounded,
        'color': AppColors.softPurple,
      },
      {
        'title': 'Exercise',
        'subtitle': '20 Min Power Walk / Light Yoga',
        'time': '5:30 PM',
        'icon': Icons.fitness_center_rounded,
        'color': AppColors.stepsColor,
      },
      {
        'title': 'Sleep',
        'subtitle': 'Wind down & phone off',
        'time': '10:30 PM',
        'icon': Icons.bedtime_rounded,
        'color': AppColors.sleepColor,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softLavender,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm_rounded,
                        size: 16,
                        color: AppColors.softPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Upcoming Reminders',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.babyPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '4 Scheduled',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of 4 Reminders
          ...remindersList.map((r) {
            final title = r['title'] as String;
            final subtitle = r['subtitle'] as String;
            final time = r['time'] as String;
            final icon = r['icon'] as IconData;
            final color = r['color'] as Color;
            final isEnabled = _reminderStates[title] ?? true;

            return ReminderTile(
              title: title,
              time: '$subtitle • $time',
              icon: icon,
              iconBgColor: color,
              isEnabled: isEnabled,
              onToggle: (val) {
                setState(() {
                  _reminderStates[title] = val;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
