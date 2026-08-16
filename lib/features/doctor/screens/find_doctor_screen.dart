import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../models/doctor.dart';
import 'all_doctors_screen.dart';
import 'booking_screen.dart';
import 'doctor_profile_screen.dart';
import 'my_appointments_screen.dart';
import '../widgets/consultation_mode_card.dart';
import '../widgets/doctor_card.dart';
import '../widgets/doctor_search_bar.dart';
import '../widgets/section_header.dart';

class FindDoctorScreen extends ConsumerStatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  ConsumerState<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends ConsumerState<FindDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  ConsultationMode? _selectedMode;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filter(List<Doctor> doctors) {
    return doctors.where((doctor) {
      final matchesMode =
          _selectedMode == null || doctor.mode == _selectedMode;
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          doctor.name.toLowerCase().contains(q) ||
          doctor.specialization.toLowerCase().contains(q);
      return matchesMode && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Find a Doctor',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _openAppointments,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.softPurpleLight.withValues(
                      alpha: 0.25,
                    ),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.softPurple,
                  size: 23,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showNotifications,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softLavender.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.softPurpleLight.withValues(
                          alpha: 0.25,
                        ),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.softPurple,
                      size: 23,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.rosePink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorSearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 16),

              // -------------------------------------------------------------
              // CONSULTATION MODE SELECTION
              // -------------------------------------------------------------
              Row(
                children: [
                  ConsultationModeCard(
                    mode: ConsultationMode.online,
                    isSelected: _selectedMode == ConsultationMode.online,
                    onTap: () => setState(() {
                      _selectedMode = _selectedMode == ConsultationMode.online
                          ? null
                          : ConsultationMode.online;
                    }),
                  ),
                  const SizedBox(width: 12),
                  ConsultationModeCard(
                    mode: ConsultationMode.offline,
                    isSelected: _selectedMode == ConsultationMode.offline,
                    onTap: () => setState(() {
                      _selectedMode = _selectedMode == ConsultationMode.offline
                          ? null
                          : ConsultationMode.offline;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              doctorsAsync.when(
                data: (allDoctors) {
                  final filteredDoctors = _filter(allDoctors);
                  final suggested = filteredDoctors.where((d) => d.rating >= 4.8).toList();
                  final nearby = filteredDoctors.where((d) => d.mode == ConsultationMode.offline).toList();

                  return Column(
                    children: [
                      // -------------------------------------------------------------
                      // SUGGESTED DOCTORS
                      // -------------------------------------------------------------
                      SectionHeader(
                        title: 'Suggested Doctors',
                        actionLabel: 'View All',
                        onActionTap: () => _openAllDoctors(suggested),
                      ),
                      const SizedBox(height: 14),
                      if (suggested.isEmpty)
                        _buildEmptyState()
                      else
                        ...suggested.map(
                          (doctor) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () => _openProfile(doctor),
                              onBookNow: () => _openBooking(doctor),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // -------------------------------------------------------------
                      // NEARBY DOCTORS
                      // -------------------------------------------------------------
                      SectionHeader(
                        title: 'Nearby Doctors',
                        actionLabel: 'View All',
                        onActionTap: () => _openAllDoctors(nearby),
                      ),
                      const SizedBox(height: 14),
                      if (nearby.isEmpty)
                        _buildEmptyState()
                      else
                        ...nearby.map(
                          (doctor) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () => _openProfile(doctor),
                              onBookNow: () => _openBooking(doctor),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // -------------------------------------------------------------
                      // ALL AVAILABLE DOCTORS (Includes newly registered)
                      // -------------------------------------------------------------
                      SectionHeader(
                        title: 'All Available Doctors',
                        actionLabel: 'View All',
                        onActionTap: () => _openAllDoctors(filteredDoctors),
                      ),
                      const SizedBox(height: 14),
                      if (filteredDoctors.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredDoctors.map(
                          (doctor) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () => _openProfile(doctor),
                              onBookNow: () => _openBooking(doctor),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.softPurple)),
                ),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 34,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 8),
          Text(
            'No doctors found',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Try a different search or consultation mode.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: AppColors.creamWhite,
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have 1 new update: Your consultation reminders and doctor '
          'appointment updates will appear here.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.softPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorProfileScreen(doctor: doctor),
      ),
    );
  }

  void _openAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyAppointmentsScreen(),
      ),
    );
  }

  void _openBooking(Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(doctor: doctor),
      ),
    );
  }

  void _openAllDoctors(List<Doctor> doctors) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllDoctorsScreen(doctors: doctors),
      ),
    );
  }
}
