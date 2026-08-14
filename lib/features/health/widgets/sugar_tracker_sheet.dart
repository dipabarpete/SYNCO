import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Sugar craving form. Multiple cravings can be logged on the same day.
class SugarCravingSheet extends ConsumerStatefulWidget {
  final SugarCravingEntry? entry;

  const SugarCravingSheet({super.key, this.entry});

  static Future<bool?> show(
    BuildContext context, {
    SugarCravingEntry? entry,
  }) {
    return showHealthSheet<bool>(context, SugarCravingSheet(entry: entry));
  }

  @override
  ConsumerState<SugarCravingSheet> createState() => _SugarCravingSheetState();
}

class _SugarCravingSheetState extends ConsumerState<SugarCravingSheet> {
  final TextEditingController _cravingController = TextEditingController();

  late DateTime _date;
  late int _timeMinutes;
  String? _level;
  String? _editingId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _date = dateOnly(entry?.date ?? DateTime.now());
    final now = DateTime.now();
    _timeMinutes = entry?.timeMinutes ?? now.hour * 60 + now.minute;
    if (entry != null) {
      _editingId = entry.id;
      _cravingController.text = entry.craving;
      _level = entry.level;
    }
  }

  @override
  void dispose() {
    _cravingController.dispose();
    super.dispose();
  }

  List<SugarCravingEntry> get _today => ref
      .watch(healthDataProvider)
      .sugarCravings
      .where((e) => HealthDataState.sameDay(e.date, _date))
      .toList();

  void _startEdit(SugarCravingEntry entry) {
    setState(() {
      _editingId = entry.id;
      _cravingController.text = entry.craving;
      _level = entry.level;
      _timeMinutes = entry.timeMinutes ?? _timeMinutes;
    });
  }

  void _resetForm() {
    final now = DateTime.now();
    setState(() {
      _editingId = null;
      _cravingController.clear();
      _level = null;
      _timeMinutes = now.hour * 60 + now.minute;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final craving = _cravingController.text.trim();
    if (craving.isEmpty) {
      setState(() => _errorMessage = 'Tell us what you are craving.');
      return;
    }
    if (_level == null) {
      setState(() => _errorMessage = 'Please select a craving level.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final existing = _editingId == null
        ? null
        : _today.where((e) => e.id == _editingId).firstOrNull;

    final error = await ref.read(healthDataProvider.notifier).saveSugarCraving(
          existing: widget.entry ?? existing,
          date: _date,
          craving: craving,
          level: _level!,
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

    _resetForm();
    setState(() => _saving = false);
    showSavedSnack(
      context,
      _editingId == null ? 'Craving logged.' : 'Craving updated.',
    );
  }

  Future<void> _delete(SugarCravingEntry entry) async {
    final ok = await confirmDeleteEntry(context, 'this craving');
    if (!ok || !mounted) return;
    final error = await ref
        .read(healthDataProvider.notifier)
        .deleteSugarCraving(entry.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      showSavedSnack(context, 'Craving deleted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    return HealthSheetScaffold(
      title: 'Sugar Cravings',
      icon: TrackerMeta.sugar.icon,
      color: TrackerMeta.sugar.strongColor,
      subtitle: 'What are you craving?',
      saving: _saving,
      saveLabel: _editingId == null
          ? HealthTrackerType.sugarCravings.saveLabel
          : 'Update Craving',
      errorMessage: _errorMessage,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (today.isNotEmpty) ...[
            SheetSectionTitle('Logged today', subtitle: '${today.length} ${today.length == 1 ? 'craving' : 'cravings'}'),
            const SizedBox(height: 8),
            ...today.map(
              (entry) => LoggedEntryRow(
                icon: TrackerMeta.sugar.icon,
                color: TrackerMeta.sugar.strongColor,
                title: entry.craving,
                subtitle: entry.timeMinutes == null
                    ? entry.level
                    : '${entry.level} \u00B7 ${formatClock(entry.timeMinutes!)}',
                onTap: () => _startEdit(entry),
                onDelete: () => _delete(entry),
              ),
            ),
            const SizedBox(height: 8),
          ],
          HealthDateField(
            date: _date,
            label: 'Craving date',
            onChanged: (d) => setState(() => _date = dateOnly(d)),
          ),
          const SizedBox(height: 12),
          HealthTimeField(
            minutesOfDay: _timeMinutes,
            label: 'Time',
            onChanged: (v) => setState(() => _timeMinutes = v),
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 12),
          HealthTextField(
            controller: _cravingController,
            labelText: 'Craving',
            hintText: 'e.g. Chocolate',
          ),
          const SizedBox(height: 16),
          const SheetSectionTitle('Craving Level'),
          const SizedBox(height: 8),
          OptionChips(
            options: kCravingLevelOptions,
            selected: _level,
            onChanged: (v) => setState(() => _level = v),
            selectedColor: TrackerMeta.sugar.strongColor,
          ),
        ],
      ),
    );
  }
}