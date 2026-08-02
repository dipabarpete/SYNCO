import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/reminder_tile.dart';
import '../../../models/reminder_item.dart';
import '../../../providers/app_providers.dart';
import 'reminder_form_sheet.dart';

class UpcomingRemindersCard extends ConsumerWidget {
  const UpcomingRemindersCard({super.key});

  void _openReminderForm(
    BuildContext context,
    WidgetRef ref, {
    ReminderItem? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReminderFormSheet(
        initialItem: item,
        onSave: (savedItem) {
          if (item == null) {
            ref.read(remindersProvider.notifier).addReminder(savedItem);
          } else {
            ref.read(remindersProvider.notifier).updateReminder(savedItem);
          }
        },
        onDelete: (id) {
          ref.read(remindersProvider.notifier).deleteReminder(id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.softLavender,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.softPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  size: 16,
                  color: AppColors.softPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upcoming Reminders',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. List of Pastel Reminder Cards
          if (reminders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No reminders scheduled yet.\nTap below to add your first reminder! 🌸',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              itemBuilder: (ctx, index) {
                final item = reminders[index];
                return ReminderTile(
                  item: item,
                  onToggle: (val) {
                    ref.read(remindersProvider.notifier).toggleReminder(item.id);
                  },
                  onTap: () => _openReminderForm(context, ref, item: item),
                );
              },
            ),
          const SizedBox(height: 8),

          // 3. Full-Width Add Reminder Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openReminderForm(context, ref),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFFFD1DC),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: AppColors.softPurple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add Reminder',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
