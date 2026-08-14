import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Mental wellness form: stress/anxiety/energy 1-5 scales, sleep quality and
/// mood. One daily entry; a supportive, non-judgmental tone.
class WellnessSheet extends ConsumerStatefulWidget {
  final MentalWellnessEntry? entry;

  const WellnessSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {MentalWellnessEntry? entry}) {
    return showHealthSheet<bool>(context, WellnessSheet(entry: entry));
  }

  @override
  ConsumerState<WellnessSheet> createState() => _WellnessSheetState();
}

class _WellnessSheetState extends ConsumerState<WellnessSheet> {
  late DateTime _date;
  late int _stress;
  late int _anxiety;
  late int _energy;
  late int _timeMinutes;
  String? _sleepQuality;
  String? _mood;
  bool _saving = false;
  String? _errorMessage;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _date = dateOnly(entry?.date ?? DateTime.now());
    final now = DateTime.now();
    _timeMinutes = entry?.timeMinutes ?? now.hour * 60 + now.minute;
    _stress = entry?.stressLevel ?? 3;
    _anxiety = entry?.anxietyLevel ?? 3;
    _energy = entry?.energyLevel ?? 3;
    _sleepQuality = entry?.sleepQuality;
    _mood = entry?.mood;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_mood == null) {
      setState(() => _errorMessage = 'Please pick a mood for today.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await ref.read(healthDataProvider.notifier).saveWellness(
          existing: widget.entry,
          date: _date,
          stressLevel: _stress,
          anxietyLevel: _anxiety,
          energyLevel: _energy,
          sleepQuality: _sleepQuality ?? '',
          mood: _mood!,
          timeMinutes: _timeMinutes,
        );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _errorMessage = error;
      });
      return;
    }

    Navigator.pop(context, true);
    showSavedSnack(
      context,
      'Wellness saved - thanks for checking in with yourself.',
    );
  }

  Future<void> _delete() async {
    if (widget.entry == null) return;
    final ok = await confirmDeleteEntry(context, 'this wellness entry');
    if (!ok || !mounted) return;
    final error = await ref
        .read(healthDataProvider.notifier)
        .deleteWellness(widget.entry!.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }
    Navigator.pop(context, true);
    showSavedSnack(context, 'Wellness entry deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return HealthSheetScaffold(
      title: _isEditing ? 'Edit Wellness' : 'Mental Wellness',
      icon: TrackerMeta.wellness.icon,
      color: TrackerMeta.wellness.color,
      subtitle: 'A gentle check-in with yourself. No judgement here.',
      saving: _saving,
      saveLabel: _isEditing ? 'Save Wellness' : HealthTrackerType.mentalWellness.saveLabel,
      errorMessage: _errorMessage,
      headerAction: _isEditing
          ? IconButton(
              onPressed: _delete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textLight,
              ),
              tooltip: 'Delete',
            )
          : null,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthDateField(
            date: _date,
            label: 'Check-in date',
            onChanged: (d) => setState(() => _date = dateOnly(d)),
          ),
          const SizedBox(height: 12),
          HealthTimeField(
            minutesOfDay: _timeMinutes,
            label: 'Check-in time',
            onChanged: (v) => setState(() => _timeMinutes = v),
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 18),
          _buildScale(
            title: 'Stress Level',
            value: _stress,
            color: AppColors.stressColor,
            labels: const ['Low', 'High'],
            onChanged: (v) => setState(() => _stress = v),
          ),
          const SizedBox(height: 16),
          _buildScale(
            title: 'Anxiety Level',
            value: _anxiety,
            color: TrackerMeta.wellness.color,
            labels: const ['Low', 'High'],
            onChanged: (v) => setState(() => _anxiety = v),
          ),
          const SizedBox(height: 16),
          _buildScale(
            title: 'Energy Level',
            value: _energy,
            color: TrackerMeta.steps.strongColor,
            labels: const ['Low', 'High'],
            onChanged: (v) => setState(() => _energy = v),
          ),
          const SizedBox(height: 18),
          const SheetSectionTitle('Sleep Quality'),
          const SizedBox(height: 8),
          OptionChips(
            options: kHealthQualityOptions,
            selected: kHealthQualityOptions.contains(_sleepQuality)
                ? _sleepQuality
                : null,
            onChanged: (v) => setState(() => _sleepQuality = v),
            selectedColor: TrackerMeta.wellness.color,
          ),
          const SizedBox(height: 18),
          const SheetSectionTitle('Mood'),
          const SizedBox(height: 8),
          OptionChips(
            options: kMoodOptions,
            selected: _mood,
            onChanged: (v) => setState(() => _mood = v),
            selectedColor: TrackerMeta.wellness.color,
          ),
        ],
      ),
    );
  }

  Widget _buildScale({
    required String title,
    required int value,
    required Color color,
    required List<String> labels,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SheetSectionTitle(title),
            const Spacer(),
            Text(
              '$value/5',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) {
            final level = i + 1;
            final selected = value == level;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 46,
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.22)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: selected
                          ? color
                          : AppColors.borderGrey.withValues(alpha: 0.6),
                      width: selected ? 1.6 : 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      selected
                          ? Icons.favorite_rounded
                          : Icons.circle_outlined,
                      size: selected ? 20 : 15,
                      color: selected ? color : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              labels.first,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: AppColors.textLight,
              ),
            ),
            const Spacer(),
            Text(
              labels.last,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}