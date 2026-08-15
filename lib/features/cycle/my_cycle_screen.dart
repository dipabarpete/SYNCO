import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cycle_data.dart';
import '../../models/period_day_log.dart';
import '../../models/period_record.dart';
import '../../providers/app_providers.dart';
import 'services/cycle_calculation_service.dart';
import 'widgets/period_form_sheet.dart';

const Color _kPeriodFill = Color(0xFFF9C9D4);
const Color _kFertileFill = Color(0xFFFFF4CE);
const Color _kFertileBorder = Color(0xFFF0DF9C);
const Color _kOvulationFill = Color(0xFFFFB085);
const Color _kOvulationBorder = Color(0xFFF59E6B);

class MyCycleScreen extends ConsumerStatefulWidget {
  const MyCycleScreen({super.key});

  @override
  ConsumerState<MyCycleScreen> createState() => _MyCycleScreenState();
}

class _MyCycleScreenState extends ConsumerState<MyCycleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Deferred so `state` is not modified while the widget tree is building.
    Future.microtask(() => ref.read(periodLogsProvider.notifier).loadPeriods());
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(cycleDataProvider);
    final insights = ref.watch(cycleInsightsProvider);
    final periodLogs = ref.watch(periodLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cycle & Fertility',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded, color: AppColors.softPurple),
            onPressed: () => _showCycleReportModal(context, insights),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarCard(insights, cycle),
            const SizedBox(height: 20),

            _buildHighlightsRow(insights),
            const SizedBox(height: 20),

            _buildSummaryCard(insights),
            const SizedBox(height: 20),

            _buildCycleInsightsCard(insights),
            const SizedBox(height: 20),

            // Period History Section
            Text(
              'Period History',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildPeriodHistorySection(periodLogs),
            const SizedBox(height: 20),

            // Add Period Button (saves to Firebase period_logs)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showAddPeriodSheet,
                icon: const Icon(Icons.event_note_rounded),
                label: const Text('Add Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(CycleInsights insights) {
    if (!insights.hasHistory) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 12,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start tracking your cycle',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log your first period to unlock estimated phases, '
                    'ovulation and fertility insights.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          insights.currentPhase.displayName,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Estimated',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day ${insights.currentDayOfCycle} of ~${insights.averageCycleLength}-day cycle',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nextPeriodLabel(insights),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _phaseDescription(insights.currentPhase),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  String _nextPeriodLabel(CycleInsights insights) {
    final next = insights.predictedNextPeriod;
    final days = insights.daysUntilNextPeriod;
    if (next == null) return 'Log your period to see predictions';
    if (days != null && days < 0) {
      return 'Next period predicted ${-days} day${-days == 1 ? '' : 's'} ago — log it if it started';
    }
    if (days == null) return 'Next period predicted on ${DateFormat('d MMM').format(next)}';
    return 'Next period predicted in $days day${days == 1 ? '' : 's'} '
        '(${DateFormat('d MMM').format(next)})';
  }

  // ── Calendar ──────────────────────────────────────────────────────────────

  Widget _buildCalendarCard(CycleInsights insights, CycleData cycle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _openDayDetail(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, focusedDay, insights),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: AppColors.softLavender,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.softPurple,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.babyPink,
                borderRadius: BorderRadius.circular(16),
              ),
              formatButtonTextStyle: GoogleFonts.inter(
                color: AppColors.softPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(AppColors.rosePink, 'Period'),
            const SizedBox(width: 14),
            _legendItem(_kOvulationFill, 'Ovulation (est.)'),
            const SizedBox(width: 14),
            _legendItem(_kFertileBorder, 'Fertility window (est.)'),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMedium),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime day, DateTime focusedDay, CycleInsights insights) {
    final isSelected = _selectedDay != null && isSameDay(_selectedDay, day);
    final isToday = isSameDay(DateTime.now(), day);
    final inMonth = day.year == focusedDay.year && day.month == focusedDay.month;
    final isPeriodDay = insights.periodDays.contains(day);
    final isFertileDay = insights.fertileDays.contains(day);
    final isOvulationDay = insights.ovulationDay != null &&
        isSameDay(insights.ovulationDay!, day);

    Color? bg;
    Color textColor = inMonth ? AppColors.textDark : AppColors.textLight;
    Color? border;
    bool boldText = false;

    if (isSelected) {
      bg = AppColors.softPurple;
      textColor = Colors.white;
      boldText = true;
    } else if (isToday) {
      bg = AppColors.softLavender;
      textColor = AppColors.softPurple;
      boldText = true;
    } else if (isPeriodDay) {
      bg = _kPeriodFill;
      textColor = AppColors.deepRose;
      border = AppColors.rosePink;
      boldText = true;
    } else if (isOvulationDay) {
      bg = _kOvulationFill;
      textColor = Colors.white;
      border = _kOvulationBorder;
      boldText = true;
    } else if (isFertileDay) {
      bg = _kFertileFill;
      textColor = AppColors.textDark;
      border = _kFertileBorder;
    }

    final showMarkerDots = isSelected || isToday;
    final dots = <Widget>[
      if (showMarkerDots && isPeriodDay)
        _dot(AppColors.rosePink),
      if (showMarkerDots && isFertileDay)
        _dot(_kFertileBorder),
      if (showMarkerDots && isOvulationDay)
        _dot(_kOvulationFill),
    ];

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border != null ? Border.all(color: border, width: 1.4) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            '${day.day}',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: boldText ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: dots.isEmpty ? const [SizedBox(height: 5)] : dots,
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 4.5,
      height: 4.5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ── Highlights ────────────────────────────────────────────────────────────

  Widget _buildHighlightsRow(CycleInsights insights) {
    if (!insights.hasHistory) {
      return const SizedBox.shrink();
    }
    final window = insights.fertileWindowStart != null
        ? '${CycleCalculationService.shortDate(insights.fertileWindowStart!)} – '
            '${CycleCalculationService.shortDate(insights.fertileWindowEnd!)}'
        : '—';
    final ovulation = insights.estimatedOvulation != null
        ? CycleCalculationService.shortDate(insights.estimatedOvulation!)
        : '—';
    return Row(
      children: [
        Expanded(
          child: _buildInfoPill(
            icon: Icons.favorite_rounded,
            title: 'Fertile Window',
            subtitle: window,
            color: AppColors.rosePink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoPill(
            icon: Icons.wb_sunny_rounded,
            title: 'Ovulation Day',
            subtitle: ovulation,
            color: AppColors.peachCoral,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Cycle Insights ────────────────────────────────────────────────────────

  Widget _buildCycleInsightsCard(CycleInsights insights) {
    if (!insights.hasHistory) return const SizedBox.shrink();
    final next = insights.predictedNextPeriod;
    final ovulation = insights.estimatedOvulation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cycleGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Cycle Insights (Estimated)',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _insightRow('📅', 'Next expected period', next != null ? DateFormat('d MMM yyyy').format(next) : '—'),
          _insightRow('🟣', 'Estimated fertile window',
              insights.fertileWindowStart != null
                  ? '${DateFormat('d MMM').format(insights.fertileWindowStart!)} – '
                      '${DateFormat('d MMM').format(insights.fertileWindowEnd!)}'
                  : '—'),
          _insightRow('🔵', 'Estimated ovulation day', ovulation != null ? DateFormat('d MMM yyyy').format(ovulation) : '—'),
          _insightRow('🩸', 'Average cycle length', '${insights.averageCycleLength} days'),
          _insightRow('⏳', 'Average period length', '${insights.averagePeriodDuration} days'),
          if (insights.cycleNumber > 0)
            _insightRow('♻️', 'Current cycle #', '${insights.cycleNumber}'),
          const SizedBox(height: 6),
          Text(
            'Predicted upcoming periods:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          for (final date in insights.predictedPeriodStarts)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text(
                '• ${DateFormat('d MMM yyyy').format(date)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'All dates shown here are estimates based on your logged cycle '
              'history. They are predictions, not exact biological dates or '
              'medical advice.',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Period History ────────────────────────────────────────────────────────

  List<Widget> _buildPeriodHistorySection(PeriodLogsState logs) {
    if (logs.isLoading && logs.records.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.softPurple),
          ),
        ),
      ];
    }

    final errorMessage = logs.errorMessage;
    if (errorMessage != null) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.babyPink.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.rosePink.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: AppColors.rosePink, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () =>
                    ref.read(periodLogsProvider.notifier).loadPeriods(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.softPurple,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    if (logs.records.isEmpty) {
      return [_buildEmptyPeriodState()];
    }

    final sorted = [...logs.records]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted.asMap().entries.map((entry) {
      final cycleNumber = sorted.length - entry.key;
      return _buildPeriodRecordCard(entry.value, cycleNumber: cycleNumber);
    }).toList();
  }

  Widget _buildEmptyPeriodState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.water_drop_outlined,
            color: AppColors.softPurple,
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            'Start tracking your period',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Add Period" to log and save your first period.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _showAddPeriodSheet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Period'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRecordCard(PeriodRecord record, {required int cycleNumber}) {
    final end = record.endDate;
    final dayCount = end == null
        ? 1
        : end.difference(record.startDate).inDays + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: () => _openPeriodDetail(record),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cycle #$cycleNumber',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _formatPeriodRange(record),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '$dayCount day${dayCount == 1 ? '' : 's'} • Tap for daily logs',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                if (record.flowLevelDisplay != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softLavender,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      record.flowLevelDisplay!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.softPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final mood in record.moods)
                  _miniChip('😊 $mood', AppColors.softLavender, AppColors.softPurple),
                for (final symptom in record.symptoms)
                  _miniChip('🩺 $symptom', AppColors.babyPink, AppColors.deepRose),
                if (record.discharge != null)
                  _miniChip('💧 ${record.discharge}', AppColors.skyBlue, AppColors.softPurple),
                for (final item in record.digestion)
                  _miniChip('🫄 $item', AppColors.mintGreen, AppColors.confirmedGreen),
                for (final item in record.otherFactors)
                  _miniChip('🌿 $item', AppColors.pendingAmberSoft, AppColors.pendingAmber),
              ],
            ),
            if (record.moods.isEmpty &&
                record.symptoms.isEmpty &&
                record.discharge == null &&
                record.digestion.isEmpty &&
                record.otherFactors.isEmpty)
              Text(
                'No additional health logs for this period.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            if (record.painLevel != null && record.painLevel! > 0)
              Text(
                'Pain: ${record.painLevel}/5',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
              ),
            if (record.notes != null && record.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                record.notes!,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMedium,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editPeriod(record),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.softPurple,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _confirmDeletePeriod(record),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.deepRose,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPeriodRange(PeriodRecord record) {
    final start = DateFormat('dd MMM yyyy').format(record.startDate);
    final end = record.endDate;
    if (end == null || isSameDay(record.startDate, end)) {
      return start;
    }
    return '$start – ${DateFormat('dd MMM yyyy').format(end)}';
  }

  Widget _miniChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 10.5, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Detail sheets ─────────────────────────────────────────────────────────

  void _openPeriodDetail(PeriodRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _PeriodDetailSheet(record: record),
    );
  }

  void _openDayDetail(DateTime day) {
    final records = ref.read(periodLogsProvider).records;
    PeriodRecord? owner;
    for (final record in records) {
      if (record.periodDates.any((d) => isSameDay(d, day))) {
        owner = record;
        break;
      }
    }
    if (owner == null) return;
    final selectedRecord = owner;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _DayDetailSheet(record: selectedRecord, day: day),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _showAddPeriodSheet() async {
    final saved = await PeriodFormSheet.show(context);
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Period saved successfully!')),
    );
  }

  Future<void> _editPeriod(PeriodRecord record) async {
    final saved = await PeriodFormSheet.show(context, record: record);
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Period updated — predictions recalculated!')),
    );
  }

  Future<void> _confirmDeletePeriod(PeriodRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete this period?'),
        content: Text(
          'This will permanently remove your period starting '
          '${DateFormat('dd MMM yyyy').format(record.startDate)} '
          'and its daily logs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error =
        await ref.read(periodLogsProvider.notifier).deletePeriod(record.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Period deleted successfully!',
        ),
      ),
    );
  }

  void _showCycleReportModal(BuildContext context, CycleInsights insights) {
    final next = insights.predictedNextPeriod;
    final ovulation = insights.estimatedOvulation;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.analytics_rounded, color: AppColors.softPurple),
            const SizedBox(width: 8),
            Text('Cycle Analytics Report', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!insights.hasHistory) ...[
              Text(
                'Log a period to unlock cycle analytics.',
                style: GoogleFonts.inter(color: AppColors.textMedium),
              ),
            ] else ...[
              Text('Average Cycle Length: ${insights.averageCycleLength} days (est.)', style: GoogleFonts.inter()),
              const SizedBox(height: 6),
              Text('Average Period Duration: ${insights.averagePeriodDuration} days (est.)', style: GoogleFonts.inter()),
              const SizedBox(height: 6),
              Text('Current Phase: ${insights.currentPhase.displayName} (estimated)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Next Period (est.): ${next != null ? DateFormat('dd MMM yyyy').format(next) : '—'}', style: GoogleFonts.inter()),
              const SizedBox(height: 6),
              Text('Ovulation (est.): ${ovulation != null ? DateFormat('dd MMM yyyy').format(ovulation) : '—'}', style: GoogleFonts.inter()),
              const SizedBox(height: 12),
              Text(
                'All values are estimates based on your logged cycle history, not medical advice.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  String _phaseDescription(CyclePhase phase) => phase.description;
}

// ── Period Detail Sheet ─────────────────────────────────────────────────────

class _PeriodDetailSheet extends StatelessWidget {
  final PeriodRecord record;

  const _PeriodDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final dayLogs = record.periodDates
        .map((date) => record.logForDate(date))
        .whereType<PeriodDayLog>()
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('🩸', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Period — ${DateFormat('dd MMM yyyy').format(record.startDate)}'
                    '${record.endDate != null ? ' – ${DateFormat('dd MMM yyyy').format(record.endDate!)}' : ''}',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (record.flowLevelDisplay != null) ...[
              _label('Flow', record.flowLevelDisplay!),
              const SizedBox(height: 6),
            ],
            if (record.painLevel != null && record.painLevel! > 0) ...[
              _label('Pain', '${record.painLevel}/5'),
              const SizedBox(height: 6),
            ],
            if (record.moods.isNotEmpty) ...[
              _label('Moods', record.moods.join(', ')),
              const SizedBox(height: 6),
            ],
            if (record.symptoms.isNotEmpty) ...[
              _label('Symptoms', record.symptoms.join(', ')),
              const SizedBox(height: 6),
            ],
            if (record.discharge != null) ...[
              _label('Discharge', record.discharge!),
              const SizedBox(height: 6),
            ],
            if (record.digestion.isNotEmpty) ...[
              _label('Digestion & Stool', record.digestion.join(', ')),
              const SizedBox(height: 6),
            ],
            if (record.otherFactors.isNotEmpty) ...[
              _label('Other', record.otherFactors.join(', ')),
              const SizedBox(height: 6),
            ],
            if (record.notes != null && record.notes!.trim().isNotEmpty) ...[
              _label('Notes', record.notes!),
              const SizedBox(height: 6),
            ],
            if (record.moods.isEmpty &&
                record.symptoms.isEmpty &&
                record.discharge == null &&
                record.digestion.isEmpty &&
                record.otherFactors.isEmpty)
              Text(
                'No additional health logs recorded for this period.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textLight,
                ),
              ),
            if (dayLogs.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Daily Logs',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              for (final dayLog in dayLogs) _buildDayLogTile(dayLog),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayLogTile(PeriodDayLog log) {
    final parts = <String>[
      if (log.flowLevel != null) log.flowLevel!,
      ...log.moods,
      ...log.symptoms,
      if (log.discharge != null) '💧 ${log.discharge}',
      ...log.digestion,
      ...log.otherFactors,
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.babyPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🩸 ${DateFormat('d MMM').format(log.date)}',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.deepRose,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              parts.isEmpty ? 'No extra logs' : parts.join(' • '),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Day Detail Sheet ────────────────────────────────────────────────────────

class _DayDetailSheet extends StatelessWidget {
  final PeriodRecord record;
  final DateTime day;

  const _DayDetailSheet({required this.record, required this.day});

  @override
  Widget build(BuildContext context) {
    final log = record.logForDate(day);
    final flow = log?.flowLevel ?? record.flowLevel;
    final pain = log?.painLevel ?? record.painLevel;
    final moods = log?.moods.isNotEmpty == true ? log!.moods : record.moods;
    final symptoms =
        log?.symptoms.isNotEmpty == true ? log!.symptoms : record.symptoms;
    final discharge = log?.discharge ?? record.discharge;
    final digestion =
        log?.digestion.isNotEmpty == true ? log!.digestion : record.digestion;
    final others =
        log?.otherFactors.isNotEmpty == true ? log!.otherFactors : record.otherFactors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩸', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, d MMM yyyy').format(day),
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Saved with the period entry starting '
            '${DateFormat('dd MMM yyyy').format(record.startDate)}',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMedium),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip('🩸 Period', AppColors.rosePink, Colors.white),
              if (flow != null)
                _chip('💧 Flow: $flow', AppColors.softLavender, AppColors.softPurple),
              if (pain != null && pain > 0)
                _chip('🤕 Pain: $pain/5', AppColors.babyPink, AppColors.deepRose),
              for (final mood in moods)
                _chip('😊 $mood', AppColors.softLavender, AppColors.softPurple),
              for (final symptom in symptoms)
                _chip('🩺 $symptom', AppColors.babyPink, AppColors.deepRose),
              if (discharge != null)
                _chip('💧 $discharge', AppColors.skyBlue, AppColors.softPurple),
              for (final item in digestion)
                _chip('🫄 $item', AppColors.mintGreen, AppColors.confirmedGreen),
              for (final item in others)
                _chip('🌿 $item', AppColors.pendingAmberSoft, AppColors.pendingAmber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
