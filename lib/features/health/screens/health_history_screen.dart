import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import '../services/health_analytics.dart';
import '../widgets/food_tracker_sheet.dart';
import '../widgets/health_form_helpers.dart';
import '../widgets/sleep_tracker_sheet.dart';
import '../widgets/steps_tracker_sheet.dart';
import '../widgets/sugar_tracker_sheet.dart';
import '../widgets/supplement_tracker_sheet.dart';
import '../widgets/tracker_meta.dart';
import '../widgets/water_tracker_sheet.dart';
import '../widgets/weight_tracker_sheet.dart';
import '../widgets/wellness_tracker_sheet.dart';

enum HistoryPeriod { today, week, month }

/// Browsable history of all logged health entries. Entries can be opened to
/// edit and deleted from here; the period can be switched between
/// Today / This Week / This Month.
class HealthHistoryScreen extends ConsumerStatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  ConsumerState<HealthHistoryScreen> createState() =>
      _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends ConsumerState<HealthHistoryScreen> {
  HistoryPeriod _period = HistoryPeriod.today;

  (DateTime, DateTime) get _range {
    final now = DateTime.now();
    switch (_period) {
      case HistoryPeriod.today:
        return (now, now);
      case HistoryPeriod.week:
        return (HealthAnalytics.addDays(now, -6), now);
      case HistoryPeriod.month:
        return (HealthAnalytics.firstOfMonth(now), now);
    }
  }

  Future<void> _openEntry(HealthEntry entry) async {
    switch (entry) {
      case SleepEntry e:
        await SleepSheet.show(context, entry: e);
      case WaterEntry e:
        await WaterSheet.show(context, entry: e);
      case StepEntry e:
        await StepsSheet.show(context, entry: e);
      case SugarCravingEntry e:
        await SugarCravingSheet.show(context, entry: e);
      case SupplementEntry e:
        await SupplementSheet.show(context, entry: e);
      case MentalWellnessEntry e:
        await WellnessSheet.show(context, entry: e);
      case FoodEntry e:
        await FoodSheet.show(context, entry: e);
      case WeightEntry e:
        await WeightSheet.show(context, entry: e);
      default:
        break;
    }
  }

  Future<void> _deleteEntry(HealthEntry entry) async {
    final confirmed =
        await confirmDeleteEntry(context, 'this entry');
    if (!confirmed || !mounted) return;

    final notifier = ref.read(healthDataProvider.notifier);
    final String? error;
    switch (entry) {
      case SleepEntry e:
        error = await notifier.deleteSleep(e.id);
      case WaterEntry e:
        error = await notifier.deleteWater(e.id);
      case StepEntry e:
        error = await notifier.deleteSteps(e.id);
      case SugarCravingEntry e:
        error = await notifier.deleteSugarCraving(e.id);
      case SupplementEntry e:
        error = await notifier.deleteSupplement(e.id);
      case MentalWellnessEntry e:
        error = await notifier.deleteWellness(e.id);
      case FoodEntry e:
        error = await notifier.deleteFood(e.id);
      case WeightEntry e:
        error = await notifier.deleteWeight(e.id);
      default:
        error = null;
    }

    if (!mounted) return;
    if (error != null) {
      showSavedSnack(context, error);
    } else {
      showSavedSnack(context, 'Entry deleted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(healthDataProvider);
    final (start, end) = _range;

    final inRange = data.allEntries
        .where((e) =>
            !e.date.isBefore(HealthAnalytics.startOfDay(start)) &&
            !e.date.isAfter(HealthAnalytics.startOfDay(end)))
        .toList();
    inRange.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.createdAt.compareTo(a.createdAt);
    });

    // Group by day, newest days first.
    final days = <DateTime, List<HealthEntry>>{};
    for (final entry in inRange) {
      final key = dateOnly(entry.date);
      (days[key] ??= []).add(entry);
    }
    final orderedDays = days.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SegmentedButton<HistoryPeriod>(
              segments: const [
                ButtonSegment(
                  value: HistoryPeriod.today,
                  label: Text('Today'),
                  icon: Icon(Icons.today_rounded, size: 16),
                ),
                ButtonSegment(
                  value: HistoryPeriod.week,
                  label: Text('This Week'),
                  icon: Icon(Icons.calendar_view_week_rounded, size: 16),
                ),
                ButtonSegment(
                  value: HistoryPeriod.month,
                  label: Text('This Month'),
                  icon: Icon(Icons.calendar_month_rounded, size: 16),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (selection) {
                setState(() => _period = selection.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.softPurple.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.softPurple
                      : AppColors.textMedium,
                ),
                side: WidgetStateProperty.resolveWith(
                  (states) => BorderSide(
                    color: states.contains(WidgetState.selected)
                        ? AppColors.softPurple.withValues(alpha: 0.5)
                        : AppColors.borderGrey,
                  ),
                ),
                textStyle: WidgetStatePropertyAll(
                  GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: orderedDays.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: orderedDays.length,
                    itemBuilder: (_, i) {
                      final day = orderedDays[i];
                      return _buildDaySection(day, days[day]!);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(DateTime day, List<HealthEntry> entries) {
    final isToday = HealthDataState.sameDay(day, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          child: Row(
            children: [
              Text(
                isToday ? 'Today' : DateFormat('EEEE, dd MMM yyyy').format(day),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softPurple,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${entries.length}',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...entries.map(
          (e) => _EntryCard(
            entry: e,
            onTap: () => _openEntry(e),
            onDelete: () => _deleteEntry(e),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildEmptyState() {
    final label = switch (_period) {
      HistoryPeriod.today => 'today',
      HistoryPeriod.week => 'this week',
      HistoryPeriod.month => 'this month',
    };
    final showHint = _period == HistoryPeriod.month;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.babyPink.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_rounded,
                size: 28,
                color: AppColors.rosePink,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Nothing logged $label',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showHint
                  ? 'Entries from this month will show up here.'
                  : 'Add your first entry from the Health page.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final HealthEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LoggedEntryRow(
      icon: _icon,
      color: _color,
      title: _title,
      subtitle: _subtitle,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  IconData get _icon {
    return switch (entry) {
      SleepEntry() => TrackerMeta.sleep.icon,
      WaterEntry() => TrackerMeta.water.icon,
      StepEntry() => TrackerMeta.steps.icon,
      SugarCravingEntry() => TrackerMeta.sugar.icon,
      SupplementEntry() => TrackerMeta.supplements.icon,
      MentalWellnessEntry() => TrackerMeta.wellness.icon,
      FoodEntry() => TrackerMeta.food.icon,
      WeightEntry() => TrackerMeta.weight.icon,
      _ => Icons.favorite_rounded,
    };
  }

  Color get _color {
    return switch (entry) {
      SleepEntry() => TrackerMeta.sleep.color,
      WaterEntry() => TrackerMeta.water.color,
      StepEntry() => TrackerMeta.steps.strongColor,
      SugarCravingEntry() => TrackerMeta.sugar.strongColor,
      SupplementEntry() => TrackerMeta.supplements.color,
      MentalWellnessEntry() => TrackerMeta.wellness.color,
      FoodEntry() => TrackerMeta.food.strongColor,
      WeightEntry() => TrackerMeta.weight.color,
      _ => AppColors.softPurple,
    };
  }

  String get _title {
    return switch (entry) {
      SleepEntry e =>
        '${formatDurationMinutes(e.durationMinutes)} \u00B7 ${e.quality}',
      WaterEntry e =>
        '${e.quantity % 1 == 0 ? e.quantity.toInt() : e.quantity} ${e.unit} \u00B7 ${e.hydrationLevel}',
      StepEntry e => '${e.count} steps',
      SugarCravingEntry e => e.craving,
      SupplementEntry e => e.name,
      MentalWellnessEntry e => 'Stress ${e.stressLevel}/5 \u00B7 Anxiety ${e.anxietyLevel}/5',
      FoodEntry e => e.description,
      WeightEntry e =>
        '${e.weight % 1 == 0 ? e.weight.toInt() : e.weight} ${e.unit}',
      _ => 'Entry',
    };
  }

  String? get _subtitle {
    return switch (entry) {
      SleepEntry e => e.factors.isEmpty
          ? null
          : '${e.factors.take(3).join(', ')}${e.factors.length > 3 ? '...' : ''}',
      WaterEntry e => e.timeMinutes == null
          ? null
          : formatClock(e.timeMinutes!),
      StepEntry() => null,
      SugarCravingEntry e => e.timeMinutes == null
          ? 'Level: ${e.level}'
          : 'Level: ${e.level} \u00B7 ${formatClock(e.timeMinutes!)}',
      SupplementEntry e => e.timeMinutes == null
          ? null
          : formatClock(e.timeMinutes!),
      MentalWellnessEntry e => [
          if (e.timeMinutes != null) formatClock(e.timeMinutes!),
          'Energy ${e.energyLevel}/5',
          'Mood: ${e.mood}',
        ].join(' \u00B7 '),
      FoodEntry e => [
          e.mealType,
          if (e.timeMinutes != null) formatClock(e.timeMinutes!),
          if (e.tags.isNotEmpty) e.tags.take(4).join(', '),
          if (e.isFavorite) 'Favorite',
        ].join(' \u00B7 '),
      WeightEntry() => null,
      _ => null,
    };
  }
}