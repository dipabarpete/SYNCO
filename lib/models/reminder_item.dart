import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ReminderItem {
  final String id;
  final String title;
  final String category;
  final String subtitle;
  final List<DateTime> selectedDates;
  final String repeatSchedule;
  final List<String> customDays;
  final List<TimeOfDay> reminderTimes;
  final String colorKey;
  final String notes;
  final bool isEnabled;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.category,
    this.subtitle = '',
    this.selectedDates = const [],
    this.repeatSchedule = 'Daily',
    this.customDays = const [],
    this.reminderTimes = const [],
    this.colorKey = 'Pink',
    this.notes = '',
    this.isEnabled = true,
  });

  ReminderItem copyWith({
    String? id,
    String? title,
    String? category,
    String? subtitle,
    List<DateTime>? selectedDates,
    String? repeatSchedule,
    List<String>? customDays,
    List<TimeOfDay>? reminderTimes,
    String? colorKey,
    String? notes,
    bool? isEnabled,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      subtitle: subtitle ?? this.subtitle,
      selectedDates: selectedDates ?? this.selectedDates,
      repeatSchedule: repeatSchedule ?? this.repeatSchedule,
      customDays: customDays ?? this.customDays,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      colorKey: colorKey ?? this.colorKey,
      notes: notes ?? this.notes,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'water':
        return Icons.water_drop_outlined;
      case 'period':
        return Icons.calendar_month_outlined;
      case 'medicine':
        return Icons.medication_outlined;
      case 'nutrition':
        return Icons.apple_outlined;
      case 'exercise':
        return Icons.directions_walk_rounded;
      case 'sleep':
        return Icons.nightlight_round;
      case 'custom':
      default:
        return Icons.favorite_border_rounded;
    }
  }

  Color get cardBackgroundColor {
    switch (colorKey.toLowerCase()) {
      case 'pink':
        return const Color(0xFFFFF0F5);
      case 'blue':
        return const Color(0xFFEFF7FF);
      case 'purple':
        return const Color(0xFFF3EFFF);
      case 'green':
      case 'mint':
        return const Color(0xFFEAF9F2);
      case 'peach':
        return const Color(0xFFFFF4E8);
      case 'yellow':
        return const Color(0xFFFFFBE8);
      default:
        return const Color(0xFFFFF0F5);
    }
  }

  Color get iconColor {
    switch (colorKey.toLowerCase()) {
      case 'pink':
        return const Color(0xFFEC4899);
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'green':
      case 'mint':
        return const Color(0xFF10B981);
      case 'peach':
        return const Color(0xFFF97316);
      case 'yellow':
        return const Color(0xFFEAB308);
      default:
        return AppColors.softPurple;
    }
  }

  Color get borderColor {
    switch (colorKey.toLowerCase()) {
      case 'pink':
        return const Color(0xFFFFD6E4);
      case 'blue':
        return const Color(0xFFD6EBFF);
      case 'purple':
        return const Color(0xFFE5DAFA);
      case 'green':
      case 'mint':
        return const Color(0xFFD3F4E5);
      case 'peach':
        return const Color(0xFFFFE4CA);
      case 'yellow':
        return const Color(0xFFFFF1B8);
      default:
        return AppColors.softLavender;
    }
  }

  String get timeDisplay {
    if (reminderTimes.isEmpty) {
      return subtitle.isNotEmpty ? subtitle : 'Scheduled';
    }
    final formatted = reminderTimes.map((t) {
      final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }).join(', ');
    return subtitle.isNotEmpty ? '$subtitle • $formatted' : formatted;
  }
}
