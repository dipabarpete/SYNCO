import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/period_record.dart';
import '../../../providers/app_providers.dart';

/// Bottom sheet used to add a new period or edit an existing one.
/// Saves through [periodLogsProvider] so data lands in Firebase `period_logs`.
class PeriodFormSheet extends ConsumerStatefulWidget {
  /// When provided, the sheet edits that period; otherwise it adds a new one.
  final PeriodRecord? record;

  const PeriodFormSheet({super.key, this.record});

  static Future<bool?> show(BuildContext context, {PeriodRecord? record}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PeriodFormSheet(record: record),
    );
  }

  @override
  ConsumerState<PeriodFormSheet> createState() => _PeriodFormSheetState();
}

class _PeriodFormSheetState extends ConsumerState<PeriodFormSheet> {
  static const List<String> _flowOptions = [
    'Spotting',
    'Light',
    'Medium',
    'Heavy',
  ];
  static const List<String> _moodOptions = [
    'Happy',
    'Calm',
    'Anxious',
    'Moody',
    'Tired',
  ];
  static const List<String> _symptomOptions = [
    'Cramps',
    'Bloating',
    'Acne',
    'Fatigue',
    'Headache',
    'Nausea',
    'Mood Swings',
    'Back Pain',
  ];

  final TextEditingController _notesController = TextEditingController();

  late DateTime _startDate;
  DateTime? _endDate;
  String? _flowLevel;
  int _painLevel = 0;
  String? _mood;
  List<String> _symptoms = [];
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _startDate = record?.startDate ?? DateTime.now();
    _endDate = record?.endDate;
    _flowLevel = record?.flowLevel;
    _painLevel = record?.painLevel ?? 0;
    _mood = record?.mood;
    _symptoms = [...?record?.symptoms];
    _notesController.text = record?.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Edit Period' : 'Log Period';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildDateTile(
              icon: Icons.event_available_rounded,
              label: 'Start Date',
              value: DateFormat('dd MMM yyyy').format(_startDate),
              onTap: () => _pickDate(
                current: _startDate,
                onPicked: (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(height: 12),
            _buildDateTile(
              icon: Icons.event_note_rounded,
              label: 'End Date (optional)',
              value: _endDate != null
                  ? DateFormat('dd MMM yyyy').format(_endDate!)
                  : 'Not set',
              onTap: () => _pickDate(
                current: _endDate ?? _startDate,
                onPicked: (date) => setState(() => _endDate = date),
              ),
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.textMedium,
                      onPressed: () => setState(() => _endDate = null),
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            Text('Flow Level:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _flowOptions.map((flow) {
                return ChoiceChip(
                  label: Text(flow),
                  selected: _flowLevel == flow.toLowerCase(),
                  selectedColor: AppColors.rosePink,
                  labelStyle: GoogleFonts.inter(
                    color: _flowLevel == flow.toLowerCase()
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                  onSelected: (_) => setState(() => _flowLevel = flow.toLowerCase()),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text(
              'Pain Level ($_painLevel/5):',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _painLevel.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              activeColor: AppColors.rosePink,
              label: '$_painLevel/5',
              onChanged: (val) => setState(() => _painLevel = val.toInt()),
            ),
            const SizedBox(height: 8),

            Text('Mood:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moodOptions.map((mood) {
                return ChoiceChip(
                  label: Text(mood),
                  selected: _mood == mood,
                  selectedColor: AppColors.softLavender,
                  labelStyle: GoogleFonts.inter(
                    color: _mood == mood ? AppColors.softPurple : AppColors.textDark,
                  ),
                  onSelected: (_) => setState(() => _mood = mood),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text('Symptoms:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptomOptions.map((symptom) {
                return FilterChip(
                  label: Text(symptom),
                  selected: _symptoms.contains(symptom),
                  selectedColor: AppColors.babyPink,
                  labelStyle: GoogleFonts.inter(
                    color: _symptoms.contains(symptom)
                        ? AppColors.deepRose
                        : AppColors.textDark,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _symptoms = [..._symptoms, symptom];
                      } else {
                        _symptoms = _symptoms.where((s) => s != symptom).toList();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.borderGrey.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.borderGrey.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : _isEditing
                          ? 'Save Changes'
                          : 'Save Period',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.softPurple, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required DateTime current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(now.year + 10, 12, 31),
      helpText: 'Select a date',
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final endDate = _endDate;
    if (endDate != null && endDate.isBefore(_startDate)) {
      setState(() {
        _errorMessage = 'End date must be on or after the start date.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final notifier = ref.read(periodLogsProvider.notifier);
    final trimmedNotes = _notesController.text.trim();
    final String? error;
    if (_isEditing) {
      error = await notifier.updatePeriod(
        widget.record!.id,
        startDate: _startDate,
        endDate: endDate,
        flowLevel: _flowLevel,
        painLevel: _painLevel,
        mood: _mood,
        symptoms: _symptoms,
        notes: trimmedNotes.isEmpty ? null : trimmedNotes,
      );
    } else {
      error = await notifier.addPeriod(
        startDate: _startDate,
        endDate: endDate,
        flowLevel: _flowLevel,
        painLevel: _painLevel,
        mood: _mood,
        symptoms: _symptoms,
        notes: trimmedNotes.isEmpty ? null : trimmedNotes,
      );
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
        _errorMessage = error;
      });
      return;
    }

    Navigator.pop(context, true);
  }
}