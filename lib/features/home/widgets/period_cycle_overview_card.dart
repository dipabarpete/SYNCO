import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PeriodCycleOverviewCard extends StatelessWidget {
  final String currentPhase;
  final int currentDay;
  final int totalDays;
  final int daysUntilNextPeriod;
  final VoidCallback? onTap;

  const PeriodCycleOverviewCard({
    super.key,
    this.currentPhase = 'Follicular Phase',
    this.currentDay = 8,
    this.totalDays = 28,
    this.daysUntilNextPeriod = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.cycleGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: AppColors.softPurple.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER ROW: Phase, Day & Mini Calendar Icon + Chevron Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.softPurple,
                              AppColors.softPurpleLight,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPhase,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Day $currentDay of $totalDays • Cycle Overview',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.softPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Clickable Chevron Indicator
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.softPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. MINI MONTHLY CALENDAR PREVIEW
            _buildMiniCalendar(),

            const SizedBox(height: 12),
            Divider(
              color: AppColors.softPurple.withValues(alpha: 0.15),
              thickness: 0.8,
              height: 1,
            ),
            const SizedBox(height: 12),

            // 3. SUMMARY CARDS ROW (Next Period | Fertile Window | Ovulation)
            Row(
              children: [
                Expanded(
                  child: _buildCyclePill(
                    label: 'Next Period',
                    value: 'In $daysUntilNextPeriod Days',
                    bgColor: AppColors.babyPink,
                    textColor: AppColors.deepRose,
                    icon: Icons.water_drop_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCyclePill(
                    label: 'Fertile Window',
                    value: 'Days 11-16',
                    bgColor: AppColors.softLavender,
                    textColor: AppColors.softPurple,
                    icon: Icons.wb_sunny_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCyclePill(
                    label: 'Ovulation',
                    value: 'In 6 Days',
                    bgColor: AppColors.peachCoral.withValues(alpha: 0.25),
                    textColor: AppColors.textDark,
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final now = DateTime.now();
    final monthName = _getMonthName(now.month);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday % 7; // Sun=0, Mon=1...

    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Period days for demo: 1 to 5
    const periodDays = {1, 2, 3, 4, 5};
    // Fertile days: 11 to 16
    const fertileDays = {11, 12, 13, 15, 16};
    // Ovulation day: 14
    const ovulationDay = 14;
    // Today's day
    final todayDay = currentDay > 0 && currentDay <= daysInMonth ? currentDay : now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Title Row & Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$monthName ${now.year}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildLegendDot(AppColors.rosePink, 'Period'),
                    const SizedBox(width: 8),
                    _buildLegendDot(AppColors.softPurpleLight, 'Fertile'),
                    const SizedBox(width: 8),
                    _buildLegendDot(AppColors.peachCoral, 'Ovulation'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Day of Week Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek.map((day) {
            return SizedBox(
              width: 24,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMedium,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: firstDayOfWeek + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (ctx, index) {
            if (index < firstDayOfWeek) {
              return const SizedBox();
            }
            final dayNumber = index - firstDayOfWeek + 1;
            final isPeriod = periodDays.contains(dayNumber);
            final isFertile = fertileDays.contains(dayNumber);
            final isOvulation = dayNumber == ovulationDay;
            final isToday = dayNumber == todayDay;

            BoxDecoration decoration;
            Color textColor = AppColors.textDark;

            if (isToday) {
              decoration = BoxDecoration(
                color: AppColors.softPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softPurple.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              );
              textColor = Colors.white;
            } else if (isPeriod) {
              decoration = BoxDecoration(
                color: AppColors.rosePink.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.rosePink, width: 1),
              );
              textColor = AppColors.deepRose;
            } else if (isOvulation) {
              decoration = BoxDecoration(
                color: AppColors.peachCoral.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.peachCoral, width: 1.2),
              );
              textColor = AppColors.textDark;
            } else if (isFertile) {
              decoration = BoxDecoration(
                color: AppColors.softLavender,
                shape: BoxShape.circle,
              );
              textColor = AppColors.softPurple;
            } else {
              decoration = const BoxDecoration(
                shape: BoxShape.circle,
              );
            }

            return Container(
              alignment: Alignment.center,
              decoration: decoration,
              child: Text(
                '$dayNumber',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isToday || isPeriod || isOvulation
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: textColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  Widget _buildCyclePill({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
