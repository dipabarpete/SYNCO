import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_bottom_nav_bar.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_home_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_settings_screen.dart';
import '../../../core/services/notification_controller.dart';

/// Doctor Portal shell.
///
/// Hosts the four primary doctor sections in a bottom navigation:
/// Dashboard / Appointments / Patients / Profile. All sections are powered by
/// the existing doctor providers and services for the logged-in doctor.
class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Initialize notifications listener for the doctor
    ref.read(notificationControllerProvider);

    final user = ref.watch(authNotifierProvider).user;
    final doctorAsync = ref.watch(currentDoctorProvider);
    final doctorName = formatDoctorDisplayName(
      doctorAsync.value != null && doctorAsync.value!.name.isNotEmpty
          ? doctorAsync.value!.name
          : (user?.displayName ?? 'Doctor'),
    );

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.softLavender,
              child: Icon(
                Icons.medical_services_rounded,
                color: AppColors.softPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Consultant Portal',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HerSyncAuthGateway(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.deepRose),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DoctorHomeScreen(
            onOpenRequests: () => setState(() => _currentIndex = 1),
          ),
          const DoctorAppointmentsScreen(),
          const DoctorPatientsScreen(),
          const DoctorSettingsScreen(),
        ],
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}