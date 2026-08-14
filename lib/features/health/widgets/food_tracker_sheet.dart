import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Food & nutrition form. Multiple meals can be logged per day and are shown
/// in chronological order. Meals can be saved as favourites for faster
/// future logging, and custom tags can be created.
class FoodSheet extends ConsumerStatefulWidget {
  final FoodEntry? entry;

  const FoodSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {FoodEntry? entry}) {
    return showHealthSheet<bool>(context, FoodSheet(entry: entry));
  }

  @override
  ConsumerState<FoodSheet> createState() => _FoodSheetState();
}

class _FoodSheetState extends ConsumerState<FoodSheet> {
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _date;
  late int _timeMinutes;
  String? _mealType;
  Set<String> _tags = {};
  bool _isFavorite = false;
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
      _descriptionController.text = entry.description;
      _mealType = entry.mealType;
      _tags = {...entry.tags};
      _isFavorite = entry.isFavorite;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<FoodEntry> get _today {
    final meals = ref
        .watch(healthDataProvider)
        .food
        .where((e) => HealthDataState.sameDay(e.date, _date))
        .toList();
    meals.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return meals;
  }

  List<FoodEntry> get _favorites {
    final seen = <String>{};
    final favorites = <FoodEntry>[];
    for (final meal in ref.watch(healthDataProvider).food) {
      if (meal.isFavorite && seen.add(meal.description)) {
        favorites.add(meal);
      }
    }
    return favorites.take(6).toList();
  }

  void _startEdit(FoodEntry entry) {
    setState(() {
      _editingId = entry.id;
      _descriptionController.text = entry.description;
      _mealType = entry.mealType;
      _tags = {...entry.tags};
      _isFavorite = entry.isFavorite;
      _timeMinutes = entry.timeMinutes ?? _timeMinutes;
    });
  }

  void _resetForm() {
    final now = DateTime.now();
    setState(() {
      _editingId = null;
      _descriptionController.clear();
      _mealType = null;
      _tags = {};
      _isFavorite = false;
      _timeMinutes = now.hour * 60 + now.minute;
    });
  }

  Future<void> _addCustomTag() async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Custom Tag',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Homemade',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(ctx, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (tag != null && mounted) {
      setState(() => _tags = {..._tags, tag});
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() => _errorMessage = 'Please tell us what you ate.');
      return;
    }
    if (_mealType == null) {
      setState(() => _errorMessage = 'Please select a meal type.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final existing = _editingId == null
        ? null
        : ref
            .read(healthDataProvider)
            .food
            .where((e) => e.id == _editingId)
            .firstOrNull;

    final error = await ref.read(healthDataProvider.notifier).saveFood(
          existing: widget.entry ?? existing,
          date: _date,
          description: description,
          mealType: _mealType!,
          tags: _tags.toList(),
          isFavorite: _isFavorite,
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
      _editingId == null ? 'Meal saved.' : 'Meal updated.',
    );
  }

  Future<void> _delete(FoodEntry entry) async {
    final ok = await confirmDeleteEntry(context, 'this meal');
    if (!ok || !mounted) return;
    final error =
        await ref.read(healthDataProvider.notifier).deleteFood(entry.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      showSavedSnack(context, 'Meal deleted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    final favorites = _favorites;
    return HealthSheetScaffold(
      title: 'Food & Nutrition',
      icon: TrackerMeta.food.icon,
      color: TrackerMeta.food.strongColor,
      subtitle: 'What did you eat?',
      saving: _saving,
      saveLabel: _editingId == null
          ? HealthTrackerType.food.saveLabel
          : 'Update Meal',
      errorMessage: _errorMessage,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (favorites.isNotEmpty) ...[
            const SheetSectionTitle('Favourites', subtitle: 'Tap to fill a meal quickly'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites.map((meal) {
                return ActionChip(
                  avatar: const Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: AppColors.rosePink,
                  ),
                  label: Text(
                    meal.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.rosePink.withValues(alpha: 0.35),
                    ),
                  ),
                  backgroundColor: AppColors.babyPink.withValues(alpha: 0.4),
                  onPressed: () => _startEdit(meal.copyForFill()),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],
          if (today.isNotEmpty) ...[
            const SheetSectionTitle(
              "Today's meals",
              subtitle: 'In the order you logged them',
            ),
            const SizedBox(height: 8),
            ...today.map(
              (meal) => LoggedEntryRow(
                icon: TrackerMeta.food.icon,
                color: TrackerMeta.food.strongColor,
                title: meal.description,
                subtitle: meal.mealType +
                    (meal.timeMinutes == null
                        ? ''
                        : ' \u00B7 ${formatClock(meal.timeMinutes!)}') +
                    (meal.tags.isEmpty ? '' : ' · ${meal.tags.take(3).join(', ')}') +
                    (meal.isFavorite ? '  \u2764\uFE0F' : ''),
                onTap: () => _startEdit(meal),
                onDelete: () => _delete(meal),
              ),
            ),
            const SizedBox(height: 8),
          ],
          HealthDateField(
            date: _date,
            label: 'Meal date',
            onChanged: (d) => setState(() => _date = dateOnly(d)),
          ),
          const SizedBox(height: 12),
          HealthTimeField(
            minutesOfDay: _timeMinutes,
            label: 'Meal time',
            onChanged: (v) => setState(() => _timeMinutes = v),
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 12),
          HealthTextField(
            controller: _descriptionController,
            labelText: 'Meal',
            hintText: 'e.g. Paneer roti and salad',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const SheetSectionTitle('Meal Type'),
          const SizedBox(height: 8),
          OptionChips(
            options: kMealTypeOptions,
            selected: _mealType,
            onChanged: (v) => setState(() => _mealType = v),
            selectedColor: TrackerMeta.food.strongColor,
          ),
          const SizedBox(height: 18),
          const SheetSectionTitle(
            'Quick Tags',
            subtitle: 'Add food tags to your meals to help Kyra find patterns.',
          ),
          const SizedBox(height: 8),
          MultiSelectChips(
            options: kFoodTagOptions,
            selected: _tags,
            onChanged: (v) => setState(() => _tags = v),
            selectedColor: TrackerMeta.food.strongColor,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(
                Icons.add_rounded,
                size: 16,
                color: AppColors.softPurple,
              ),
              label: const Text('+ Custom Tag'),
              labelStyle: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.softPurple,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.softPurple.withValues(alpha: 0.4),
                ),
              ),
              onPressed: _addCustomTag,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _isFavorite,
            onChanged: (v) => setState(() => _isFavorite = v),
            title: Text(
              'Save as Favorite',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Text(
              'Faster logging next time',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: AppColors.textMedium,
              ),
            ),
            activeTrackColor: AppColors.rosePink,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}