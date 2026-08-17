import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/notification_providers.dart';
import '../../whisper_room/notifications_screen.dart';
import '../widgets/doctor_bottom_nav_bar.dart';
import 'consultation_room_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_home_screen.dart';
import 'doctor_requests_screen.dart';
import 'doctor_profile_screen.dart';
import '../../../core/services/notification_controller.dart';

/// Doctor Portal shell.
///
/// Hosts the five primary doctor sections in a bottom navigation:
/// Dashboard / Appointments / Consultation Room / Requests / Profile. All
/// sections are powered by the existing doctor providers and services for the
/// logged-in doctor.
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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/doctor_dashboard_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          scrolledUnderElevation: 0,
          // The Appointments section has its own app bar: no profile icon and
          // a History action instead of Notifications. The Requests section
          // only shows the New Requests title: no profile or notification
          // icon. The Consultation Room section keeps its own title without
          // the profile shortcut.
          leading: _currentIndex == 1 || _currentIndex == 2 ||
                  _currentIndex == 3
              ? null
              : IconButton(
                  tooltip: 'Profile',
                  // Profile navigation already exists as the Profile tab of this
                  // portal shell, so reuse it instead of creating a new route.
                  onPressed: () => setState(() => _currentIndex = 4),
                  icon: const Icon(
                    Icons.person_rounded,
                    color: AppColors.softPurple,
                    size: 24,
                  ),
                ),
          title: Text(
            _currentIndex == 1
                ? 'Appointments'
                : (_currentIndex == 2
                    ? 'Consultation Room'
                    : (_currentIndex == 3 ? 'New Requests' : 'SYNCO')),
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: 1.5,
            ),
          ),
          actions: _currentIndex == 1
              ? [
                  IconButton(
                    tooltip: 'History',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoctorAppointmentHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.history_rounded,
                      color: AppColors.softPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                ]
              : _currentIndex == 2 || _currentIndex == 3
                  ? const []
                  : [
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadCount =
                          ref.watch(unreadNotificationsCountProvider);
                      return IconButton(
                        tooltip: 'Notifications',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.softPurple,
                              size: 24,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: AppColors.rosePink,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            DoctorHomeScreen(
              onOpenRequests: () => setState(() => _currentIndex = 3),
            ),
            const DoctorAppointmentsScreen(),
            const DoctorConsultationRoomScreen(embedded: true),
            const DoctorRequestsScreen(),
            const DoctorProfileScreen(),
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
      ),
    );
  }
}