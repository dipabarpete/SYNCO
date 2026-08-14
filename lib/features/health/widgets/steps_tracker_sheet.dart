import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Step count form. One entry per day; editing updates that day's entry. The
/// data layer keeps a `source` field (`manual` today, `device` ready for a
/// future wearable sync integration).
class StepsSheet extends ConsumerStatefulWidget {
  final StepEntry? entry;

  const StepsSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {StepEntry? entry}) {
    return showHealthSheet<bool>(context, StepsSheet(entry: entry));
  }

  @override
  ConsumerState<StepsSheet> createState() => _StepsSheetState();
}

class _StepsSheetState extends ConsumerState<StepsSheet> {
  final TextEditingController _countController = TextEditingController();

  late DateTime _date;
  bool _saving = false;
  String? _errorMessage;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _date = dateOnly(entry?.date ?? DateTime.now());
    if (entry != null) {
      _countController.text = entry.count.toString();
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final count = int.tryParse(_countController.text.trim());
    if (count == null || count <= 0) {
      setState(() => _errorMessage = 'Please enter how many steps you took.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await ref.read(healthDataProvider.notifier).saveSteps(
          existing: widget.entry,
          date: _date,
          count: count,
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
      _isEditing ? 'Steps updated.' : 'Steps saved - nice work!',
    );
  }

  Future<void> _delete() async {
    if (widget.entry == null) return;
    final ok = await confirmDeleteEntry(context, 'this steps entry');
    if (!ok || !mounted) return;
    final error =
        await ref.read(healthDataProvider.notifier).deleteSteps(widget.entry!.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }
    Navigator.pop(context, true);
    showSavedSnack(context, 'Steps entry deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return HealthSheetScaffold(
      title: _isEditing ? 'Edit Steps' : 'Step Count',
      icon: TrackerMeta.steps.icon,
      color: TrackerMeta.steps.strongColor,
      subtitle: 'How many steps did you take today?',
      saving: _saving,
      saveLabel: _isEditing ? 'Save Steps' : HealthTrackerType.steps.saveLabel,
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
            label: 'Steps date',
            onChanged: (d) => setState(() => _date = dateOnly(d)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            inputFormatters: [wholeNumberFormatter],
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '7,842',
              prefixText: 'steps ',
              prefixStyle: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TrackerMeta.steps.strongColor,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TrackerMeta.steps.strongColor.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TrackerMeta.steps.strongColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TrackerMeta.steps.strongColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manual entry for now - wearable syncing can be added later.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}