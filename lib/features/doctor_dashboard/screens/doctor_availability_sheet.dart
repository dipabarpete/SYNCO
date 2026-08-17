import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/services/doctor_service.dart';

/// Bottom sheet that lets the doctor add a weekly availability slot:
/// available day, start/end time and consultation mode (online / offline /
/// both).
///
/// Saving writes into the existing availability fields of the doctor
/// document (`availableDays`, `timeSlots`, `availabilitySlots`) which the
/// patient-side booking flow already reads, so no duplicate backend system
/// is created. Pops with `true` when a slot was saved.
class DoctorAvailabilitySheet extends ConsumerStatefulWidget {
  final String doctorId;

  const DoctorAvailabilitySheet({super.key, required this.doctorId});

  @override
  ConsumerState<DoctorAvailabilitySheet> createState() =>
      _DoctorAvailabilitySheetState();
}

class _DoctorAvailabilitySheetState
    extends ConsumerState<DoctorAvailabilitySheet> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _selectedDay = 'Mon';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  String _mode = 'both';
  bool _isSaving = false;
  String? _error;

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.softPurple),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _startTime = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.softPurple),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    final start = _formatTime(_startTime);
    final end = _formatTime(_endTime);

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });
      await DoctorService().addAvailability(
        doctorId: widget.doctorId,
        day: _selectedDay,
        start: start,
        end: end,
        mode: _mode,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'Could not save availability. Please try again.';
        });
      }
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final meridian = t.hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')} $meridian';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add Availability',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Patients can book these slots through the app.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 22),

              _buildLabel('Available Day'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _days.map((day) {
                  final selected = day == _selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.softPurple
                            : AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.softPurple
                              : AppColors.borderGrey.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        day,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              _buildLabel('Time'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeTile(
                      icon: Icons.access_time_rounded,
                      label: 'Start',
                      value: _formatTime(_startTime),
                      onTap: _pickStart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeTile(
                      icon: Icons.access_time_filled_rounded,
                      label: 'End',
                      value: _formatTime(_endTime),
                      onTap: _pickEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              _buildLabel('Consultation Mode'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildModeChip(
                    label: 'Online',
                    icon: Icons.videocam_rounded,
                    mode: 'online',
                  ),
                  const SizedBox(width: 8),
                  _buildModeChip(
                    label: 'Offline',
                    icon: Icons.local_hospital_rounded,
                    mode: 'offline',
                  ),
                  const SizedBox(width: 8),
                  _buildModeChip(
                    label: 'Both',
                    icon: Icons.sync_alt_rounded,
                    mode: 'both',
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.deepRose,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Availability',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderGrey.withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.softPurple),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required String mode,
  }) {
    final selected = mode == _mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.softPurple.withValues(alpha: 0.12)
                : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.softPurple
                  : AppColors.borderGrey.withValues(alpha: 0.8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.softPurple : AppColors.textLight,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.softPurple : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
