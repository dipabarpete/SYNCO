import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cycle_data.dart';
import '../../providers/app_providers.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(cycleDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cycle & Fertility',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded, color: AppColors.softPurple),
            onPressed: () => _showCycleReportModal(context, cycle),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            Container(
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
                          cycle.currentPhase.displayName,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Day ${cycle.currentDayOfCycle} of ${cycle.cycleLengthDays}-Day Cycle',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Next Period predicted in ${cycle.daysUntilNextPeriod} days',
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
            ),
            const SizedBox(height: 20),

            // Calendar View Card
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
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: AppColors.softLavender,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.softPurple,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.rosePink,
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
            const SizedBox(height: 20),

            // Key Highlights Bar
            Row(
              children: [
                Expanded(
                  child: _buildInfoPill(
                    icon: Icons.favorite_rounded,
                    title: 'Fertility Window',
                    subtitle: 'Days 11 - 16',
                    color: AppColors.rosePink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoPill(
                    icon: Icons.wb_sunny_rounded,
                    title: 'Ovulation Day',
                    subtitle: 'Day 14 (in 2 days)',
                    color: AppColors.peachCoral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Log Daily Symptoms Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showLogSymptomsSheet(context),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Log Today\'s Symptoms & Flow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Symptoms History Section
            Text(
              'Logged Symptom History',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ...cycle.symptomLogs.map((log) => _buildSymptomLogCard(log)),
          ],
        ),
      ),
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

  Widget _buildSymptomLogCard(DailySymptomLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${log.date.day}/${log.date.month}/${log.date.year}',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softLavender,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Mood: ${log.mood}',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.softPurple, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: log.symptoms
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.babyPink,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          Text(
            'Flow: ${log.flowLevel} • Pain Scale: ${log.painScale}/5',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  void _showLogSymptomsSheet(BuildContext context) {
    String selectedFlow = 'Medium';
    int painLevel = 2;
    String selectedMood = 'Calm';
    final List<String> selectedSymptoms = ['Mild Cramps'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
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
                  Text(
                    'Log Period & Symptoms',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Flow Level:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Spotting', 'Light', 'Medium', 'Heavy'].map((flow) {
                      final isSel = selectedFlow == flow;
                      return ChoiceChip(
                        label: Text(flow),
                        selected: isSel,
                        selectedColor: AppColors.rosePink,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedFlow = flow);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Pain Level ($painLevel/5):', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  Slider(
                    value: painLevel.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: AppColors.rosePink,
                    onChanged: (val) => setModalState(() => painLevel = val.toInt()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cycleDataProvider.notifier).logSymptomToday(
                            selectedSymptoms.first,
                            selectedFlow,
                            painLevel,
                            selectedMood,
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cycle logs updated successfully! 🌸')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Log Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCycleReportModal(BuildContext context, CycleData cycle) {
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
            Text('Average Cycle Length: ${cycle.cycleLengthDays} days', style: GoogleFonts.inter()),
            const SizedBox(height: 6),
            Text('Average Period Duration: ${cycle.periodDurationDays} days', style: GoogleFonts.inter()),
            const SizedBox(height: 6),
            Text('Current Phase: ${cycle.currentPhase.displayName}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('AI Regularity Status: 98% Regular & Healthy', style: GoogleFonts.inter(color: AppColors.softPurple, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
