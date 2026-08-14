import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Supplement logging form. Multiple supplements can be logged per day and
/// each row can be edited or removed. SYNCO never suggests supplements or
/// dosages - it only records what the user already takes.
class SupplementSheet extends ConsumerStatefulWidget {
  final SupplementEntry? entry;

  const SupplementSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {SupplementEntry? entry}) {
    return showHealthSheet<bool>(context, SupplementSheet(entry: entry));
  }

  @override
  ConsumerState<SupplementSheet> createState() => _SupplementSheetState();
}

class _SupplementSheetState extends ConsumerState<SupplementSheet> {
  final TextEditingController _nameController = TextEditingController();

  late DateTime _date;
  late int _timeMinutes;
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
      _nameController.text = entry.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<SupplementEntry> get _today => ref
      .watch(healthDataProvider)
      .supplements
      .where((e) => HealthDataState.sameDay(e.date, _date))
      .toList();

  void _startEdit(SupplementEntry entry) {
    setState(() {
      _editingId = entry.id;
      _nameController.text = entry.name;
      _timeMinutes = entry.timeMinutes ?? _timeMinutes;
    });
  }

  void _resetForm() {
    final now = DateTime.now();
    setState(() {
      _editingId = null;
      _nameController.clear();
      _timeMinutes = now.hour * 60 + now.minute;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter the supplement name.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final existing = _editingId == null
        ? null
        : _today.where((e) => e.id == _editingId).firstOrNull;

    final error = await ref.read(healthDataProvider.notifier).saveSupplement(
          existing: widget.entry ?? existing,
          date: _date,
          name: name,
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
      _editingId == null ? 'Supplement added.' : 'Supplement updated.',
    );
  }

  Future<void> _delete(SupplementEntry entry) async {
    final ok = await confirmDeleteEntry(context, 'this supplement');
    if (!ok || !mounted) return;
    final error =
        await ref.read(healthDataProvider.notifier).deleteSupplement(entry.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      showSavedSnack(context, 'Supplement removed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    return HealthSheetScaffold(
      title: 'Supplements',
      icon: TrackerMeta.supplements.icon,
      color: TrackerMeta.supplements.color,
      subtitle: 'What supplement are you taking?',
      saving: _saving,
      saveLabel: _editingId == null
          ? HealthTrackerType.supplements.saveLabel
          : 'Update Supplement',
      errorMessage: _errorMessage,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (today.isNotEmpty) ...[
            SheetSectionTitle(
              'Logged today',
              subtitle: '${today.length} ${today.length == 1 ? 'supplement' : 'supplements'}',
            ),
            const SizedBox(height: 8),
            ...today.map(
              (entry) => LoggedEntryRow(
                icon: TrackerMeta.supplements.icon,
                color: TrackerMeta.supplements.color,
                title: entry.name,
                subtitle: entry.timeMinutes == null
                    ? '${entry.date.day} ${_monthName(entry.date)} ${entry.date.year}'
                    : '${formatClock(entry.timeMinutes!)} \u00B7 ${entry.date.day} ${_monthName(entry.date)}',
                onTap: () => _startEdit(entry),
                onDelete: () => _delete(entry),
              ),
            ),
            const SizedBox(height: 8),
          ],
          HealthDateField(
            date: _date,
            label: 'Supplement date',
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
            controller: _nameController,
            labelText: 'Supplement / vitamin',
            hintText: 'e.g. Vitamin D, Iron, Omega-3',
          ),
          const SizedBox(height: 10),
          Text(
            'SYNCO only records what you already take - it never recommends '
            'supplements or dosages.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  static String _monthName(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}