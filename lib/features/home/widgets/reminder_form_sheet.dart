import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/reminder_item.dart';

class ReminderFormSheet extends StatefulWidget {
  final ReminderItem? initialItem;
  final Function(ReminderItem item) onSave;
  final Function(String id)? onDelete;

  const ReminderFormSheet({
    super.key,
    this.initialItem,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _selectedCategory;
  late String _selectedRepeat;
  late List<String> _selectedCustomDays;
  late List<DateTime> _selectedDates;
  late List<TimeOfDay> _selectedTimes;
  late String _selectedColorKey;

  final List<Map<String, String>> _categories = [
    {'name': 'Water', 'icon': '💧'},
    {'name': 'Period', 'icon': '🌸'},
    {'name': 'Medicine', 'icon': '💊'},
    {'name': 'Nutrition', 'icon': '🥗'},
    {'name': 'Exercise', 'icon': '🏃'},
    {'name': 'Sleep', 'icon': '💤'},
    {'name': 'Custom', 'icon': '❤️'},
  ];

  final List<String> _repeatOptions = [
    'Never',
    'Daily',
    'Weekly',
    'Monthly',
    'Every Weekday',
    'Weekends',
    'Custom Days',
  ];

  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<Map<String, dynamic>> _colorPalette = [
    {'name': 'Pink', 'color': const Color(0xFFFFF0F5), 'accent': const Color(0xFFEC4899)},
    {'name': 'Blue', 'color': const Color(0xFFEFF7FF), 'accent': const Color(0xFF3B82F6)},
    {'name': 'Purple', 'color': const Color(0xFFF3EFFF), 'accent': const Color(0xFF8B5CF6)},
    {'name': 'Green', 'color': const Color(0xFFEAF9F2), 'accent': const Color(0xFF10B981)},
    {'name': 'Peach', 'color': const Color(0xFFFFF4E8), 'accent': const Color(0xFFF97316)},
    {'name': 'Yellow', 'color': const Color(0xFFFFFBE8), 'accent': const Color(0xFFEAB308)},
    {'name': 'Mint', 'color': const Color(0xFFEBF8F2), 'accent': const Color(0xFF059669)},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _selectedCategory = item?.category ?? 'Water';
    _selectedRepeat = item?.repeatSchedule ?? 'Daily';
    _selectedCustomDays = List.from(item?.customDays ?? []);
    _selectedDates = List.from(item?.selectedDates ?? [DateTime.now()]);
    _selectedTimes = List.from(
      item?.reminderTimes ?? [const TimeOfDay(hour: 9, minute: 0)],
    );
    _selectedColorKey = item?.colorKey ?? 'Pink';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.softPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (!_selectedDates.any((d) =>
            d.year == picked.year &&
            d.month == picked.month &&
            d.day == picked.day)) {
          _selectedDates.add(picked);
        }
      });
    }
  }

  void _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.softPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTimes.add(picked);
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder title')),
      );
      return;
    }

    final id = widget.initialItem?.id ??
        'rem_${DateTime.now().millisecondsSinceEpoch}';

    final newItem = ReminderItem(
      id: id,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      subtitle: _notesController.text.isNotEmpty
          ? _notesController.text.trim()
          : 'Scheduled Reminder',
      selectedDates: _selectedDates,
      repeatSchedule: _selectedRepeat,
      customDays: _selectedCustomDays,
      reminderTimes: _selectedTimes,
      colorKey: _selectedColorKey,
      notes: _notesController.text.trim(),
      isEnabled: widget.initialItem?.isEnabled ?? true,
    );

    widget.onSave(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Reminder' : 'Create New Reminder',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Reminder Title
            Text(
              'Reminder Title',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Drink Water, Take Supplements',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                filled: true,
                fillColor: const Color(0xFFFAF8F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Category Selection
            Text(
              'Category',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['name'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text('${cat['icon']} ${cat['name']}'),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.softPurple
                            : AppColors.textMedium,
                      ),
                      selectedColor: AppColors.softPurple.withValues(alpha: 0.15),
                      backgroundColor: const Color(0xFFFAF8F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.softPurple
                              : AppColors.borderGrey.withValues(alpha: 0.6),
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = cat['name']!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Date Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date Selection',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text('Add Date'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.softPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _selectedDates.map((date) {
                final formatted = DateFormat('MMM d, yyyy').format(date);
                return Chip(
                  label: Text(formatted),
                  labelStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.textDark),
                  backgroundColor: AppColors.babyPink,
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: _selectedDates.length > 1
                      ? () {
                          setState(() {
                            _selectedDates.remove(date);
                          });
                        }
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 4. Repeat Schedule
            Text(
              'Repeat Schedule',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedRepeat,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFAF8F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.6)),
                ),
              ),
              items: _repeatOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRepeat = val;
                  });
                }
              },
            ),
            if (_selectedRepeat == 'Custom Days') ...[
              const SizedBox(height: 10),
              Text(
                'Select Custom Days:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekdays.map((day) {
                  final isSelected = _selectedCustomDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCustomDays.remove(day);
                        } else {
                          _selectedCustomDays.add(day);
                        }
                      });
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.softPurple
                            : const Color(0xFFFAF8F5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.softPurple
                              : AppColors.borderGrey,
                        ),
                      ),
                      child: Text(
                        day.substring(0, 2),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // 5. Reminder Times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reminder Times',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.access_time_rounded, size: 16),
                  label: const Text('+ Add Time'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.softPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _selectedTimes.map((time) {
                final hour =
                    time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                final minute = time.minute.toString().padLeft(2, '0');
                final formatted = '$hour:$minute $period';

                return Chip(
                  label: Text(formatted),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                  backgroundColor: AppColors.softLavender.withValues(alpha: 0.5),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: _selectedTimes.length > 1
                      ? () {
                          setState(() {
                            _selectedTimes.remove(time);
                          });
                        }
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 6. Reminder Color Theme
            Text(
              'Card Pastel Color',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _colorPalette.map((cp) {
                final isSelected = _selectedColorKey == cp['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorKey = cp['name'] as String;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cp['color'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (cp['accent'] as Color)
                            : AppColors.borderGrey,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (cp['accent'] as Color).withValues(alpha: 0.3),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: cp['accent'] as Color,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 7. Notes (Optional)
            Text(
              'Notes (Optional)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Drink at least 300 ml of water.',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                filled: true,
                fillColor: const Color(0xFFFAF8F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.6)),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 8. Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.softPurple.withValues(alpha: 0.3),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      isEdit ? 'Update Reminder' : 'Save Reminder',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 9. Delete Button (Edit Mode)
            if (isEdit && widget.onDelete != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.onDelete!(widget.initialItem!.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  label: Text(
                    'Delete Reminder',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
