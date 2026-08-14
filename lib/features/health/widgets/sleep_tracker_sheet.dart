import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Sleep tracker form: start/wake times, auto-computed duration, quality and
/// sleep factors. Edits the existing entry for the day when one exists.
class SleepSheet extends ConsumerStatefulWidget {
  final SleepEntry? entry;

  const SleepSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {SleepEntry? entry}) {
    return showHealthSheet<bool>(context, SleepSheet(entry: entry));
  }

  @override
  ConsumerState<SleepSheet> createState() => _SleepSheetState();
}

class _SleepSheetState extends ConsumerState<SleepSheet> {
  late DateTime _date;
  late int _startMinutes;
  late int _endMinutes;
  String? _quality;
  Set<String> _factors = {};
  bool _saving = false;
  String? _errorMessage;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _date = dateOnly(entry?.date ?? DateTime.now());
    _startMinutes = entry?.startMinutes ?? 23 * 60;
    _endMinutes = entry?.endMinutes ?? 7 * 60;
    _quality = entry?.quality;
    _factors = {...?entry?.factors};
  }

  int get _duration =>
      SleepEntry.computeDurationMinutes(_startMinutes, _endMinutes);

  Future<void> _save() async {
    if (_saving) return;
    if (_quality == null) {
      setState(() => _errorMessage = 'Please select your sleep quality.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await ref.read(healthDataProvider.notifier).saveSleep(
          existing: widget.entry,
          date: _date,
          startMinutes: _startMinutes,
          endMinutes: _endMinutes,
          durationMinutes: _duration,
          quality: _quality!,
          factors: _factors.toList(),
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
      _isEditing ? 'Sleep entry updated.' : 'Sleep logged - rest well \u2764\uFE0F',
    );
  }

  Future<void> _delete() async {
    if (widget.entry == null) return;
    final ok = await confirmDeleteEntry(context, 'this sleep entry');
    if (!ok || !mounted) return;
    final error =
        await ref.read(healthDataProvider.notifier).deleteSleep(widget.entry!.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }
    Navigator.pop(context, true);
    showSavedSnack(context, 'Sleep entry deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return HealthSheetScaffold(
      title: _isEditing ? 'Edit Sleep' : 'Sleep',
      icon: TrackerMeta.sleep.icon,
      color: TrackerMeta.sleep.color,
      subtitle: 'When did you sleep?',
      saving: _saving,
      saveLabel: _isEditing ? 'Save Sleep' : HealthTrackerType.sleep.saveLabel,
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
            label: 'Sleep date',
            onChanged: (d) => setState(() => _date = dateOnly(d)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HealthTimeField(
                  minutesOfDay: _startMinutes,
                  label: 'Sleep start',
                  icon: Icons.bedtime_rounded,
                  onChanged: (m) => setState(() => _startMinutes = m),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HealthTimeField(
                  minutesOfDay: _endMinutes,
                  label: 'Wake up',
                  icon: Icons.wb_sunny_rounded,
                  onChanged: (m) => setState(() => _endMinutes = m),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: TrackerMeta.sleep.color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: TrackerMeta.sleep.color.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timelapse_rounded,
                  color: TrackerMeta.sleep.color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Sleep duration',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _duration > 0 ? formatDurationMinutes(_duration) : '--',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TrackerMeta.sleep.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SheetSectionTitle('Sleep Quality'),
          const SizedBox(height: 8),
          OptionChips(
            options: kHealthQualityOptions,
            selected: _quality,
            onChanged: (v) => setState(() => _quality = v),
            selectedColor: TrackerMeta.sleep.color,
          ),
          const SizedBox(height: 18),
          const SheetSectionTitle(
            'Sleep Factors',
            subtitle: 'Select anything that applied',
          ),
          const SizedBox(height: 8),
          MultiSelectChips(
            options: kSleepFactorOptions,
            selected: _factors,
            onChanged: (v) => setState(() => _factors = v),
            selectedColor: TrackerMeta.sleep.color,
          ),
        ],
      ),
    );
  }
}