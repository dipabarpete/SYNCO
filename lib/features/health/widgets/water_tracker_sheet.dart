import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Water intake form. Multiple entries can be logged per day; the sheet shows
/// today's entries and their running total while the form adds a new one.
class WaterSheet extends ConsumerStatefulWidget {
  final WaterEntry? entry;

  const WaterSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {WaterEntry? entry}) {
    return showHealthSheet<bool>(context, WaterSheet(entry: entry));
  }

  @override
  ConsumerState<WaterSheet> createState() => _WaterSheetState();
}

class _WaterSheetState extends ConsumerState<WaterSheet> {
  final TextEditingController _quantityController = TextEditingController();

  late DateTime _date;
  late int _timeMinutes;
  String _unit = 'cups';
  String? _hydrationLevel;
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
      _unit = entry.unit;
      _hydrationLevel = entry.hydrationLevel;
      _quantityController.text =
          (entry.quantity % 1 == 0)
              ? entry.quantity.toInt().toString()
              : entry.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  List<WaterEntry> get _today => ref
      .watch(healthDataProvider)
      .water
      .where((e) => HealthDataState.sameDay(e.date, _date))
      .toList();

  void _resetForm() {
    final now = DateTime.now();
    setState(() {
      _editingId = null;
      _unit = 'cups';
      _hydrationLevel = null;
      _timeMinutes = now.hour * 60 + now.minute;
      _quantityController.clear();
    });
  }

  void _startEdit(WaterEntry entry) {
    setState(() {
      _editingId = entry.id;
      _unit = entry.unit;
      _hydrationLevel = entry.hydrationLevel;
      _timeMinutes = entry.timeMinutes ?? _timeMinutes;
      _quantityController.text =
          (entry.quantity % 1 == 0)
              ? entry.quantity.toInt().toString()
              : entry.quantity.toString();
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _errorMessage = 'Please enter how much you drank.');
      return;
    }
    if (_hydrationLevel == null) {
      setState(() => _errorMessage = 'Please select your hydration level.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final existing = _editingId == null
        ? null
        : _today.where((e) => e.id == _editingId).firstOrNull;

    final error = await ref.read(healthDataProvider.notifier).saveWater(
          existing: widget.entry ?? existing,
          date: _date,
          quantity: quantity,
          unit: _unit,
          hydrationLevel: _hydrationLevel!,
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
    showSavedSnack(
      context,
      _editingId == null ? 'Water intake logged.' : 'Water entry updated.',
    );
    setState(() => _saving = false);
  }

  Future<void> _delete(WaterEntry entry) async {
    final ok = await confirmDeleteEntry(context, 'this water entry');
    if (!ok || !mounted) return;
    final error =
        await ref.read(healthDataProvider.notifier).deleteWater(entry.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      showSavedSnack(context, 'Water entry deleted.');
    }
  }

  double get _todayTotalFlOz => _today.fold(0.0, (s, e) => s + e.quantityFlOz);
  double get _todayTotalCups => _todayTotalFlOz / 8;

  @override
  Widget build(BuildContext context) {
    final today = _today;
    return HealthSheetScaffold(
      title: 'Water Intake',
      icon: TrackerMeta.water.icon,
      color: TrackerMeta.water.color,
      subtitle: 'How much water did you drink today?',
      saving: _saving,
      saveLabel: _editingId == null
          ? HealthTrackerType.water.saveLabel
          : 'Update Intake',
      errorMessage: _errorMessage,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (today.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: TrackerMeta.water.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TrackerMeta.water.color.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_drink_rounded,
                    color: TrackerMeta.water.color,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Today's total",
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_todayTotalCups.toStringAsFixed(_todayTotalCups % 1 == 0 ? 0 : 1)} cups',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TrackerMeta.water.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SheetSectionTitle('Logged today'),
            const SizedBox(height: 8),
            ...today.map(
              (entry) => LoggedEntryRow(
                icon: Icons.water_drop_rounded,
                color: TrackerMeta.water.color,
                title: '${entry.quantity % 1 == 0 ? entry.quantity.toInt() : entry.quantity} ${entry.unit}',
                subtitle: entry.timeMinutes == null
                    ? entry.hydrationLevel
                    : '${entry.hydrationLevel} \u00B7 ${formatClock(entry.timeMinutes!)}',
                onTap: () => _startEdit(entry),
                onDelete: () => _delete(entry),
              ),
            ),
            const SizedBox(height: 4),
          ],
          HealthDateField(
            date: _date,
            label: 'Water date',
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
          Row(
            children: [
              Expanded(
                child: HealthTextField(
                  controller: _quantityController,
                  labelText: 'Quantity',
                  hintText: 'e.g. 2',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [decimalFormatter],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OptionChips(
                  options: const ['cups', 'fl oz'],
                  selected: _unit,
                  onChanged: (v) => setState(() => _unit = v),
                  selectedColor: TrackerMeta.water.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SheetSectionTitle('Hydration Level'),
          const SizedBox(height: 8),
          OptionChips(
            options: kHealthQualityOptions,
            selected: _hydrationLevel,
            onChanged: (v) => setState(() => _hydrationLevel = v),
            selectedColor: TrackerMeta.water.color,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}