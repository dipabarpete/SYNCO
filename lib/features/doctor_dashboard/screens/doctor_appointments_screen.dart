import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_appointment_card.dart';
import '../widgets/doctor_section_widgets.dart';

/// Appointments tab of the Doctor Portal.
///
/// Shows the full-width Upcoming Appointments section. Backend data comes from
/// the existing providers for the logged-in doctor; temporary demo records
/// mirror the Doctor Dashboard's demo data (see doctor_home_screen.dart) so
/// the screen stays populated for UI/testing. Demo records never touch
/// Firestore, and real records are always listed after them.
class DoctorAppointmentsScreen extends ConsumerWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return SafeArea(
      bottom: false,
      child: appointmentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (_, _) => DoctorErrorState(
          message:
              "Couldn't load your appointments. Check your connection "
              'and try again.',
          onRetry: () {
            ref.invalidate(doctorAppointmentsProvider);
          },
        ),
        data: (_) => _buildSections(ref),
      ),
    );
  }

  Widget _buildSections(WidgetRef ref) {
    final today = ref.watch(todayAppointmentsProvider);
    final upcoming = ref.watch(upcomingAppointmentsProvider);

    // Temporary demo records (UI/testing only), mirroring the Doctor
    // Dashboard's demo appointments exactly (same patient names, modes, slots
    // and status values as doctor_home_screen.dart). They are pure UI-only
    // demo data, never touch the real booking system, and real backend
    // records are always listed after them.
    final doctor =
        ref.watch(currentDoctorProvider).value ?? _fallbackDemoDoctor();
    final upcomingAll = [
      ..._dummyTodayAppointments(doctor),
      ..._dummyTomorrowAppointments(doctor),
      ...today,
      ...upcoming,
    ]..sort((a, b) => a.date.compareTo(b.date));

    // Split upcoming consultations into Today / Tomorrow / Later so the dates
    // are easy to tell apart at a glance.
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final upcomingToday = upcomingAll.where((a) => isSameDay(a.date, now));
    final upcomingTomorrow = upcomingAll.where(
      (a) => isSameDay(a.date, tomorrow),
    );
    final upcomingLater = upcomingAll.where(
      (a) => !isSameDay(a.date, now) && !isSameDay(a.date, tomorrow),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Today's and tomorrow's consultations are separated so the dates
        // are easy to tell apart at a glance.
        if (upcomingAll.isEmpty)
          const DoctorEmptyState(
            icon: Icons.calendar_today_rounded,
            title: 'No upcoming appointments',
            subtitle: 'Your confirmed consultations will appear here.',
          )
        else ...[
          if (upcomingToday.isNotEmpty) ...[
            const _DayGroupLabel('Today'),
            ...upcomingToday.map(_upcomingCard),
          ],
          if (upcomingTomorrow.isNotEmpty) ...[
            const _DayGroupLabel('Tomorrow'),
            ...upcomingTomorrow.map(_upcomingCard),
          ],
          if (upcomingLater.isNotEmpty) ...[
            const _DayGroupLabel('Later'),
            ...upcomingLater.map(_upcomingCard),
          ],
        ],
      ],
    );
  }

  /// Card for an upcoming appointment. Demo records (ids starting with
  /// "demo_") are UI-only and have no backend booking, so their backend
  /// actions (chat / mark complete / cancel) are hidden for them.
  Widget _upcomingCard(Appointment appointment) {
    final isDemo = appointment.id.startsWith('demo_');
    return DoctorAppointmentCard(
      appointment: appointment,
      showEnterChat: !isDemo,
      showComplete: !isDemo,
      showStatus: true,
      allowCancel: !isDemo,
    );
  }
}

/// Full-screen history of the doctor's completed appointments, most recent
/// first. Backed entirely by the real backend providers.
///
/// Opened from the History icon in the Appointments section app bar.
class DoctorAppointmentHistoryScreen extends ConsumerWidget {
  const DoctorAppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(completedAppointmentsProvider);
    // Temporary demo records (UI/testing only), mirroring the Doctor
    // Dashboard demo history. Real history always follows.
    final doctor =
        ref.watch(currentDoctorProvider).value ?? _fallbackDemoDoctor();
    final shown = [..._dummyCompletedAppointments(doctor), ...completed];

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Appointment History',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: shown.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: DoctorEmptyState(
                icon: Icons.task_alt_rounded,
                title: 'No completed appointments yet',
                subtitle: 'Completed consultations will appear here.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: _sortedHistory(shown)
                  .map(
                    (a) =>
                        DoctorAppointmentCard(appointment: a, showStatus: true),
                  )
                  .toList(),
            ),
    );
  }

  List<Appointment> _sortedHistory(List<Appointment> completed) {
    final sorted = [...completed];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
}

/// Small pill label used to separate Today / Tomorrow / Later groups inside
/// the Upcoming Appointments section.
class _DayGroupLabel extends StatelessWidget {
  final String label;

  const _DayGroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Temporary demo appointments (UI/testing only).
//
// These mirror the Doctor Dashboard's demo records exactly (same patient
// names, modes, slots and status values as doctor_home_screen.dart) so both
// screens show the same demo data. They are never written to Firestore and
// never touch the real booking system; real backend records are always listed
// after them.
// ---------------------------------------------------------------------------

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

/// Demo "today" appointments - the same records as the Doctor Dashboard's
/// "Today's Appointments" demo data. Always shown at the top of the Upcoming
/// Appointments section and never persisted.
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

/// Demo "tomorrow" appointments - same patients and style as the dashboard
/// demo records, but scheduled for tomorrow. Never persisted.
List<Appointment> _dummyTomorrowAppointments(Doctor doctor) {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final createdAt = DateTime.now().subtract(const Duration(hours: 3));
  return [
    Appointment(
      id: 'demo_tomorrow_1',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: tomorrow,
      slot: '10:00 AM',
      fee: doctor.consultationFee,
      patientName: 'Ananya Iyer',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'demo_tomorrow_2',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: tomorrow,
      slot: '12:15 PM',
      fee: doctor.consultationFee,
      patientName: 'Tanvi Desai',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'demo_tomorrow_3',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: tomorrow,
      slot: '03:00 PM',
      fee: doctor.consultationFee,
      patientName: 'Divya Menon',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: 'demo_tomorrow_4',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: tomorrow,
      slot: '05:30 PM',
      fee: doctor.consultationFee,
      patientName: 'Sneha Pillai',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.confirmed,
    ),
  ];
}

/// Demo completed appointments - the same records as the Doctor Dashboard's
/// "Completed Today" demo data. Always shown at the top of the History list
/// and never persisted.
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
