import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/period_day_log.dart';
import '../../../models/period_record.dart';
import '../../../providers/app_providers.dart';

/// Bottom sheet used to add a new period or edit an existing one.
/// Saves through [periodLogsProvider] so every field lands in Firebase
/// `users/{userId}/period_logs` together with per-day logs.
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
    'Sad',
    'Irritable',
    'Energetic',
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
    'Abdominal Pain',
    'Cravings',
    'Brain Fog',
  ];
  static const List<String> _dischargeOptions = [
    'None',
    'Spotting',
    'Sticky',
    'Creamy',
    'Watery',
    'Egg White',
  ];
  static const List<String> _digestionOptions = [
    'Normal',
    'Constipation',
    'Diarrhoea',
    'Gas & Bloating',
    'Cravings',
    'Nausea',
    'Appetite Change',
  ];
  static const List<String> _otherOptions = [
    'Tender Breasts',
    'Insomnia',
    'Dizziness',
    'Hot Flashes',
    'Energy Dip',
    'Skin Changes',
    'Swelling',
  ];

  final TextEditingController _notesController = TextEditingController();

  late DateTime _startDate;
  DateTime? _endDate;
  String? _flowLevel;
  int _painLevel = 0;
  List<String> _moods = [];
  List<String> _symptoms = [];
  String? _discharge;
  List<String> _digestion = [];
  List<String> _otherFactors = [];

  /// Per-day overrides keyed by `yyyy-MM-dd`. Dates without an override
  /// inherit the period-level selections when the entry is saved.
  final Map<String, PeriodDayLog> _dailyLogs = {};

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
    _moods = [...record?.moods ?? []];
    if (record?.moods.isEmpty == true && record?.mood != null) {
      _moods = [record!.mood!];
    }
    _symptoms = [...?record?.symptoms];
    _discharge = record?.discharge;
    _digestion = [...record?.digestion ?? []];
    _otherFactors = [...record?.otherFactors ?? []];
    if (record != null) {
      _dailyLogs.addAll(record.dailyLogs);
    }
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
            Row(
              children: [
                const Text('🩸', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── 🩸 Period Details ──────────────────────────────────────────
            _sectionHeader('🩸', 'Period Details'),
            const SizedBox(height: 10),
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
            const SizedBox(height: 14),
            _sectionHeader('🌡️', 'Flow & Pain'),
            const SizedBox(height: 8),
            _choiceChips(
              options: _flowOptions,
              selected: _flowLevel,
              onSelected: (value) =>
                  setState(() => _flowLevel = value.toLowerCase()),
              selectedColor: AppColors.rosePink,
              selectedTextColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Pain Level',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_painLevel/5',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.deepRose,
                  ),
                ),
              ],
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
            const SizedBox(height: 6),

            // ── 😊 Moods ──────────────────────────────────────────────────
            _sectionHeader('😊', 'Moods'),
            const SizedBox(height: 4),
            Text(
              'Select all that apply',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
            ),
            const SizedBox(height: 8),
            _multiChips(
              options: _moodOptions,
              selected: _moods,
              onChanged: (value) => setState(() => _moods = value),
              selectedColor: AppColors.softLavender,
              selectedTextColor: AppColors.softPurple,
            ),
            const SizedBox(height: 16),

            // ── 🩺 Symptoms ───────────────────────────────────────────────
            _sectionHeader('🩺', 'Symptoms'),
            const SizedBox(height: 4),
            Text(
              'Select all that apply',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
            ),
            const SizedBox(height: 8),
            _multiChips(
              options: _symptomOptions,
              selected: _symptoms,
              onChanged: (value) => setState(() => _symptoms = value),
              selectedColor: AppColors.babyPink,
              selectedTextColor: AppColors.deepRose,
            ),
            const SizedBox(height: 16),

            // ── 💧 Vaginal Discharge ──────────────────────────────────────
            _sectionHeader('💧', 'Vaginal Discharge'),
            const SizedBox(height: 8),
            _choiceChips(
              options: _dischargeOptions,
              selected: _discharge,
              onSelected: (value) => setState(() => _discharge = value),
              selectedColor: AppColors.skyBlue,
              selectedTextColor: AppColors.softPurple,
            ),
            const SizedBox(height: 16),

            // ── 🫄 Digestion & Stool ──────────────────────────────────────
            _sectionHeader('🫄', 'Digestion & Stool'),
            const SizedBox(height: 4),
            Text(
              'Select all that apply',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
            ),
            const SizedBox(height: 8),
            _multiChips(
              options: _digestionOptions,
              selected: _digestion,
              onChanged: (value) => setState(() => _digestion = value),
              selectedColor: AppColors.mintGreen,
              selectedTextColor: AppColors.confirmedGreen,
            ),
            const SizedBox(height: 16),

            // ── 🌿 Others ─────────────────────────────────────────────────
            _sectionHeader('🌿', 'Others'),
            const SizedBox(height: 4),
            Text(
              'Select all that apply',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
            ),
            const SizedBox(height: 8),
            _multiChips(
              options: _otherOptions,
              selected: _otherFactors,
              onChanged: (value) => setState(() => _otherFactors = value),
              selectedColor: AppColors.pendingAmberSoft,
              selectedTextColor: AppColors.pendingAmber,
            ),
            const SizedBox(height: 16),

            // ── 📝 Notes ──────────────────────────────────────────────────
            _sectionHeader('📝', 'Notes'),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),

            // ── 📅 Daily Logs (date-linked) ──────────────────────────────
            _sectionHeader('📅', 'Daily Logs'),
            const SizedBox(height: 4),
            Text(
              'Tap a day to log its own details. Days you do not customise '
              'inherit the selections above.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
            ),
            const SizedBox(height: 8),
            ..._buildDailyLogRows(),

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

  Widget _sectionHeader(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _choiceChips({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
    required Color selectedColor,
    required Color selectedTextColor,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: selectedColor,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? selectedTextColor : AppColors.textDark,
          ),
          onSelected: (_) => onSelected(option),
        );
      }).toList(),
    );
  }

  Widget _multiChips({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    required Color selectedColor,
    required Color selectedTextColor,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: selectedColor,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? selectedTextColor : AppColors.textDark,
          ),
          onSelected: (picked) {
            onChanged(
              picked
                  ? [...selected, option]
                  : selected.where((s) => s != option).toList(),
            );
          },
        );
      }).toList(),
    );
  }

  List<Widget> _buildDailyLogRows() {
    final endDate = _endDate;
    if (endDate == null) return const [];

    final days = <DateTime>[];
    var day = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final last = DateTime(endDate.year, endDate.month, endDate.day);
    while (!day.isAfter(last)) {
      days.add(day);
      day = day.add(const Duration(days: 1));
    }

    return days.map((date) {
      final key = PeriodDayLog.formatDateKey(date);
      final override = _dailyLogs[key];
      final isCustom = override != null;

      final preview = <String>[
        if (override?.flowLevel != null) override!.flowLevel!,
        ...?override?.moods,
        if (override?.discharge != null) '💧 ${override!.discharge}',
        ...?override?.symptoms,
      ].take(3).join(' • ');

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: themeCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCustom
                ? AppColors.softPurple.withValues(alpha: 0.5)
                : AppColors.borderGrey.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMM').format(date),
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.softLavender,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Custom',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.softPurple,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (preview.isNotEmpty)
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    )
                  else
                    Text(
                      'Uses period details above',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isCustom ? Icons.tune_rounded : Icons.edit_outlined,
                size: 18,
                color: AppColors.softPurple,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () => _editDayLog(date),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color get themeCardColor => Theme.of(context).cardColor;

  Future<void> _editDayLog(DateTime date) async {
    final key = PeriodDayLog.formatDateKey(date);
    final defaults = PeriodDayLog(
      date: date,
      flowLevel: _flowLevel,
      painLevel: _painLevel,
      moods: [..._moods],
      symptoms: [..._symptoms],
      discharge: _discharge,
      digestion: [..._digestion],
      otherFactors: [..._otherFactors],
    );
    final updated = await DayLogEditorSheet.show(
      context,
      initial: _dailyLogs[key] ?? defaults,
      isCustomized: _dailyLogs.containsKey(key),
    );
    if (updated == null || !mounted) return;
    setState(() {
      // A day that matches the period-level selections inherits them instead
      // of keeping a stale custom override.
      final matchesDefaults =
          updated.flowLevel == defaults.flowLevel &&
          updated.painLevel == defaults.painLevel &&
          _sameList(updated.moods, defaults.moods) &&
          _sameList(updated.symptoms, defaults.symptoms) &&
          updated.discharge == defaults.discharge &&
          _sameList(updated.digestion, defaults.digestion) &&
          _sameList(updated.otherFactors, defaults.otherFactors);
      if (matchesDefaults) {
        _dailyLogs.remove(key);
      } else {
        _dailyLogs[key] = updated;
      }
    });
  }

  bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

    final effectiveDailyLogs = _buildEffectiveDailyLogs(endDate);

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
        moods: _moods,
        symptoms: _symptoms,
        discharge: _discharge,
        digestion: _digestion,
        otherFactors: _otherFactors,
        dailyLogs: effectiveDailyLogs,
        notes: trimmedNotes.isEmpty ? null : trimmedNotes,
      );
    } else {
      error = await notifier.addPeriod(
        startDate: _startDate,
        endDate: endDate,
        flowLevel: _flowLevel,
        painLevel: _painLevel,
        moods: _moods,
        symptoms: _symptoms,
        discharge: _discharge,
        digestion: _digestion,
        otherFactors: _otherFactors,
        dailyLogs: effectiveDailyLogs,
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

  /// Builds the persisted per-day logs: customized days are kept, all other
  /// days in the range inherit the period-level selections.
  Map<String, PeriodDayLog> _buildEffectiveDailyLogs(DateTime? endDate) {
    final logs = <String, PeriodDayLog>{};
    final last = endDate ?? _startDate;
    var day = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    while (!day.isAfter(lastDay)) {
      final key = PeriodDayLog.formatDateKey(day);
      final existing = _dailyLogs[key];
      logs[key] = existing ??
          PeriodDayLog(
            date: day,
            flowLevel: _flowLevel,
            painLevel: _painLevel,
            moods: [..._moods],
            symptoms: [..._symptoms],
            discharge: _discharge,
            digestion: [..._digestion],
            otherFactors: [..._otherFactors],
          );
      day = day.add(const Duration(days: 1));
    }
    return logs;
  }
}

/// Small editor for a single day's log inside the Add Period flow.
class DayLogEditorSheet extends StatefulWidget {
  final PeriodDayLog initial;
  final bool isCustomized;

  const DayLogEditorSheet({
    super.key,
    required this.initial,
    required this.isCustomized,
  });

  static Future<PeriodDayLog?> show(
    BuildContext context, {
    required PeriodDayLog initial,
    required bool isCustomized,
  }) {
    return showModalBottomSheet<PeriodDayLog>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DayLogEditorSheet(
        initial: initial,
        isCustomized: isCustomized,
      ),
    );
  }

  @override
  State<DayLogEditorSheet> createState() => _DayLogEditorSheetState();
}

class _DayLogEditorSheetState extends State<DayLogEditorSheet> {
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
    'Sad',
    'Irritable',
    'Energetic',
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
    'Abdominal Pain',
    'Cravings',
    'Brain Fog',
  ];
  static const List<String> _dischargeOptions = [
    'None',
    'Spotting',
    'Sticky',
    'Creamy',
    'Watery',
    'Egg White',
  ];
  static const List<String> _digestionOptions = [
    'Normal',
    'Constipation',
    'Diarrhoea',
    'Gas & Bloating',
    'Cravings',
    'Nausea',
    'Appetite Change',
  ];
  static const List<String> _otherOptions = [
    'Tender Breasts',
    'Insomnia',
    'Dizziness',
    'Hot Flashes',
    'Energy Dip',
    'Skin Changes',
    'Swelling',
  ];

  late String? _flowLevel;
  late int _painLevel;
  late List<String> _moods;
  late List<String> _symptoms;
  late String? _discharge;
  late List<String> _digestion;
  late List<String> _otherFactors;

  @override
  void initState() {
    super.initState();
    _flowLevel = widget.initial.flowLevel;
    _painLevel = widget.initial.painLevel ?? 0;
    _moods = [...widget.initial.moods];
    _symptoms = [...widget.initial.symptoms];
    _discharge = widget.initial.discharge;
    _digestion = [...widget.initial.digestion];
    _otherFactors = [...widget.initial.otherFactors];
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Daily Log — ${DateFormat('dd MMM yyyy').format(widget.initial.date)}',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _sectionHeader('🌡️', 'Flow & Pain'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _flowOptions.map((flow) {
                final isSelected = _flowLevel == flow.toLowerCase();
                return ChoiceChip(
                  label: Text(flow),
                  selected: isSelected,
                  selectedColor: AppColors.rosePink,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                  onSelected: (_) =>
                      setState(() => _flowLevel = flow.toLowerCase()),
                );
              }).toList(),
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
            const SizedBox(height: 6),

            _sectionHeader('😊', 'Moods'),
            const SizedBox(height: 8),
            _multiChips(
              options: _moodOptions,
              selected: _moods,
              onChanged: (v) => setState(() => _moods = v),
              selectedColor: AppColors.softLavender,
              selectedTextColor: AppColors.softPurple,
            ),
            const SizedBox(height: 12),

            _sectionHeader('🩺', 'Symptoms'),
            const SizedBox(height: 8),
            _multiChips(
              options: _symptomOptions,
              selected: _symptoms,
              onChanged: (v) => setState(() => _symptoms = v),
              selectedColor: AppColors.babyPink,
              selectedTextColor: AppColors.deepRose,
            ),
            const SizedBox(height: 12),

            _sectionHeader('💧', 'Vaginal Discharge'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dischargeOptions.map((option) {
                final isSelected = _discharge == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: AppColors.skyBlue,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.softPurple
                        : AppColors.textDark,
                  ),
                  onSelected: (_) => setState(() => _discharge = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            _sectionHeader('🫄', 'Digestion & Stool'),
            const SizedBox(height: 8),
            _multiChips(
              options: _digestionOptions,
              selected: _digestion,
              onChanged: (v) => setState(() => _digestion = v),
              selectedColor: AppColors.mintGreen,
              selectedTextColor: AppColors.confirmedGreen,
            ),
            const SizedBox(height: 12),

            _sectionHeader('🌿', 'Others'),
            const SizedBox(height: 8),
            _multiChips(
              options: _otherOptions,
              selected: _otherFactors,
              onChanged: (v) => setState(() => _otherFactors = v),
              selectedColor: AppColors.pendingAmberSoft,
              selectedTextColor: AppColors.pendingAmber,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, _buildLog()),
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Save Day Log',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
            if (widget.isCustomized) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context, widget.initial),
                child: Text(
                  'Reset to period details',
                  style: GoogleFonts.inter(
                    color: AppColors.textMedium,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PeriodDayLog _buildLog() {
    return widget.initial.copyWith(
      flowLevel: _flowLevel,
      painLevel: _painLevel,
      moods: _moods,
      symptoms: _symptoms,
      discharge: _discharge,
      digestion: _digestion,
      otherFactors: _otherFactors,
    );
  }

  Widget _sectionHeader(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _multiChips({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    required Color selectedColor,
    required Color selectedTextColor,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: selectedColor,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? selectedTextColor : AppColors.textDark,
          ),
          onSelected: (picked) {
            onChanged(
              picked
                  ? [...selected, option]
                  : selected.where((s) => s != option).toList(),
            );
          },
        );
      }).toList(),
    );
  }
}
