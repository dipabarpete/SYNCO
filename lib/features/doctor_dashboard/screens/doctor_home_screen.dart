import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';
import '../../doctor/screens/consultation_chat_screen.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_section_widgets.dart';
import 'patient_detail_screen.dart';

/// Home tab of the Doctor Portal.
///
/// Shows a personalized greeting, a "New Requests" notification card and the
/// doctor's appointments scheduled (and completed) today. All data comes from
/// the existing backend providers for the logged-in doctor.
class DoctorHomeScreen extends ConsumerWidget {
  /// Called when the doctor taps the "New Requests" card, so the portal shell
  /// can switch to the Appointments section.
  final VoidCallback onOpenRequests;

  const DoctorHomeScreen({super.key, required this.onOpenRequests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final doctorAsync = ref.watch(currentDoctorProvider);
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    final pendingRequests = ref.watch(pendingRequestsProvider);
    final todayAppointments = ref.watch(todayAppointmentsProvider);
    final completedToday = ref.watch(completedTodayAppointmentsProvider);

    // Temporary demo records (UI/testing only). They are always shown so the
    // dashboard looks populated, and real appointments are listed after them.
    // They are pure UI-only demo data and never touch the real booking system.
    final doctor = doctorAsync.value;
    final shownToday = [
      ..._dummyTodayAppointments(doctor ?? _fallbackDemoDoctor()),
      ...todayAppointments,
    ];
    final shownCompleted = [
      ..._dummyCompletedAppointments(doctor ?? _fallbackDemoDoctor()),
      ...completedToday,
    ];

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.softPurple,
        onRefresh: () async {
          ref.invalidate(doctorAppointmentsProvider);
          await ref.read(doctorAppointmentsProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildGreeting(doctorAsync.value, user?.displayName),
            const SizedBox(height: 18),
            _buildRequestsCard(context, ref, pendingRequests.length),
            const SizedBox(height: 26),
            if (appointmentsAsync.isLoading) ...[
              const _DashboardLoadingBox(),
            ] else if (appointmentsAsync.hasError) ...[
              _buildErrorState(ref),
            ] else ...[
              const DoctorSectionHeader(
                title: "Today's Appointments",
              ),
              const SizedBox(height: 12),
              if (shownToday.isEmpty)
                const DoctorEmptyState(
                  icon: Icons.calendar_today_rounded,
                  title: 'No appointments scheduled for today',
                  subtitle: 'Your confirmed consultations will appear here.',
                )
              else
                ...shownToday.map(
                  (a) => _TodayAppointmentTile(appointment: a),
                ),
              const SizedBox(height: 26),
              const DoctorSectionHeader(
                title: 'Completed Today',
              ),
              const SizedBox(height: 12),
              if (shownCompleted.isEmpty)
                const DoctorEmptyState(
                  icon: Icons.task_alt_rounded,
                  title: 'No completed appointments today',
                  subtitle: 'Consultations you complete today will appear here.',
                )
              else
                ...shownCompleted.map(
                  (a) => _CompletedAppointmentTile(appointment: a),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(Doctor? doctor, String? fallbackName) {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning,';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon,';
    } else {
      timeGreeting = 'Good evening,';
    }

    final rawName = doctor != null && doctor.name.isNotEmpty
        ? doctor.name
        : (fallbackName?.isNotEmpty == true ? fallbackName! : 'Doctor');
    final displayName = formatDoctorDisplayName(rawName);

    // Plain greeting text directly on the dashboard background - no card.
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeGreeting,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsCard(
    BuildContext context,
    WidgetRef ref,
    int pendingCount,
  ) {
    final hasRequests = pendingCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenRequests,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: hasRequests
                ? const Color(0xFFE3F6EE)
                : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasRequests
                  ? AppColors.mintGreen.withValues(alpha: 0.8)
                  : AppColors.borderGrey.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: hasRequests
                    ? AppColors.confirmedGreen.withValues(alpha: 0.10)
                    : AppColors.shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasRequests
                      ? AppColors.mintGreen.withValues(alpha: 0.5)
                      : AppColors.lightGrey,
                ),
                child: Icon(
                  hasRequests
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: hasRequests
                      ? AppColors.confirmedGreen
                      : AppColors.textLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Requests',
                      style: GoogleFonts.outfit(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasRequests
                          ? '$pendingCount new appointment '
                              'request${pendingCount == 1 ? '' : 's'}'
                          : 'No new appointment requests',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: hasRequests
                            ? AppColors.confirmedGreen
                            : AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasRequests) ...[
                const SizedBox(width: 10),
                // Noticeable green circular badge with the pending count.
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E8B76), Color(0xFF3FA98F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.confirmedGreen.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$pendingCount',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.confirmedGreen,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return DoctorErrorState(
      message: "Couldn't load your appointments. Check your connection "
          'and try again.',
      onRetry: () {
        ref.invalidate(doctorAppointmentsProvider);
      },
    );
  }
}

class _DashboardLoadingBox extends StatelessWidget {
  const _DashboardLoadingBox();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.softPurple),
      ),
    );
  }
}

class _TodayAppointmentTile extends ConsumerWidget {
  final Appointment appointment;

  const _TodayAppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = appointment;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(
                userId: a.userId,
                appointmentId: a.id,
                patientName: a.patientName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.babyPink,
                child: Text(
                  a.patientName.isNotEmpty
                      ? a.patientName.substring(0, 1).toUpperCase()
                      : 'P',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${a.slot} • ${a.modeName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              DoctorModePill(mode: a.mode),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Message Patient',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsultationChatScreen(
                        chatId: a.id,
                        patientName: a.patientName,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.softPurple,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stand-in doctor used when the logged-in doctor's profile is not available
/// yet, so demo records can still render. Never persisted anywhere.
Doctor _fallbackDemoDoctor() {
  return Doctor(
    id: 'demo_doctor',
    name: 'Consultant',
    specialization: '',
    experience: '',
    rating: 0,
    consultationFee: 0,
    availability: '',
    mode: ConsultationMode.online,
    about: '',
    availableDays: const [],
    timeSlots: const [],
  );
}

/// Temporary demo records (UI/testing only). Always displayed at the top of
/// the "Today's Appointments" section and never written to the real booking
/// system.
List<Appointment> _dummyTodayAppointments(Doctor doctor) {
  final now = DateTime.now();
  final createdAt = now.subtract(const Duration(hours: 2));
  return [
    Appointment(
      id: 'demo_today_1',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: now,
      slot: '09:30 AM',
      fee: doctor.consultationFee,
      patientName: 'Aisha Verma',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'demo_today_2',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: now,
      slot: '11:00 AM',
      fee: doctor.consultationFee,
      patientName: 'Meera Nair',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'demo_today_3',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: now,
      slot: '02:30 PM',
      fee: doctor.consultationFee,
      patientName: 'Riya Kapoor',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'demo_today_4',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: now,
      slot: '04:00 PM',
      fee: doctor.consultationFee,
      patientName: 'Ananya Iyer',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
  ];
}

/// Temporary demo records (UI/testing only), same rules as
/// [_dummyTodayAppointments]: always shown at the top of the
/// "Completed Today" section, never persisted.
List<Appointment> _dummyCompletedAppointments(Doctor doctor) {
  final now = DateTime.now();
  final createdAt = now.subtract(const Duration(hours: 4));
  return [
    Appointment(
      id: 'demo_completed_1',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: now,
      slot: '08:15 AM',
      fee: doctor.consultationFee,
      patientName: 'Kavya Rao',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.completed,
    ),
    Appointment(
      id: 'demo_completed_2',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: now,
      slot: '09:00 AM',
      fee: doctor.consultationFee,
      patientName: 'Sneha Pillai',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.completed,
    ),
    Appointment(
      id: 'demo_completed_3',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: now,
      slot: '10:30 AM',
      fee: doctor.consultationFee,
      patientName: 'Tanvi Desai',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.completed,
    ),
    Appointment(
      id: 'demo_completed_4',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: now,
      slot: '11:45 AM',
      fee: doctor.consultationFee,
      patientName: 'Divya Menon',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.completed,
    ),
  ];
}

class _CompletedAppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const _CompletedAppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final a = appointment;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(
                userId: a.userId,
                appointmentId: a.id,
                patientName: a.patientName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.mintGreen.withValues(alpha: 0.4),
                child: Text(
                  a.patientName.isNotEmpty
                      ? a.patientName.substring(0, 1).toUpperCase()
                      : 'P',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppColors.confirmedGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${a.formattedDateShort} • ${a.slot} • ${a.modeName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.confirmedGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.confirmedGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
