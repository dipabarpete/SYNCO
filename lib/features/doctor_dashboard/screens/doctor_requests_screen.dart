import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/backend.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_section_widgets.dart';

/// Reason for consultation of a real booking, read from the patient's AI
/// health summary (`users/{userId}/health_summaries/{appointmentId}`) that the
/// booking flow creates. Read-only; never writes to Firestore.
final requestIssueProvider = FutureProvider.family<
    String,
    ({String userId, String appointmentId})>((ref, args) async {
  if (args.userId.isEmpty ||
      args.appointmentId.isEmpty ||
      Backend.firestore == null) {
    return '';
  }
  try {
    final doc = await Backend.firestore!
        .collection('users')
        .doc(args.userId)
        .collection('health_summaries')
        .doc(args.appointmentId)
        .get();
    if (doc.exists) {
      final reason = doc.data()?['reasonForConsultation'];
      if (reason is String && reason.trim().isNotEmpty) return reason;
    }
  } catch (_) {
    // Fall back to the appointment's own issue field / generic label.
  }
  return '';
});

/// Requests tab of the Doctor Portal.
///
/// Shows the new appointment requests (status = requested) of the logged-in
/// doctor. Real requests come from the existing `bookings` data via
/// [pendingRequestsProvider]; Accept / Decline update the real booking via the
/// existing [DoctorDashboardController].
///
/// During development/testing, temporary dummy requests (ids starting with
/// "demo_req_") are shown on top so the screen stays populated. They are pure
/// UI-only demo data, never written to Firestore, and never appear in the
/// dashboard's pending count.
class DoctorRequestsScreen extends ConsumerStatefulWidget {
  const DoctorRequestsScreen({super.key});

  @override
  ConsumerState<DoctorRequestsScreen> createState() =>
      _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends ConsumerState<DoctorRequestsScreen> {
  /// Demo request ids the doctor has already resolved locally. Removing them
  /// from the list is purely visual - Firestore is never touched for them.
  final Set<String> _resolvedDemoIds = {};

  /// Booking ids currently being updated, so buttons show a spinner.
  final Set<String> _updatingIds = {};

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);
    final pending = ref.watch(pendingRequestsProvider);
    final doctor =
        ref.watch(currentDoctorProvider).value ?? _fallbackDemoDoctor();

    final shown = [
      ..._dummyPendingRequests(doctor).where(
        (a) => !_resolvedDemoIds.contains(a.id),
      ),
      ...pending,
    ]..sort((a, b) => a.date.compareTo(b.date));

    return SafeArea(
      bottom: false,
      child: shown.isEmpty
          ? (appointmentsAsync.hasError
              ? DoctorErrorState(
                  message: "Couldn't load your requests. Check your "
                      'connection and try again.',
                  onRetry: () {
                    ref.invalidate(doctorAppointmentsProvider);
                  },
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    DoctorEmptyState(
                      icon: Icons.inbox_rounded,
                      title: 'No new requests',
                      subtitle: 'Appointment requests from patients will '
                          'appear here.',
                    ),
                  ],
                ))
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ...shown.map(
                  (a) => _RequestCard(
                    appointment: a,
                    updating: _updatingIds.contains(a.id),
                    onAccept: () => _resolve(context, a, accepted: true),
                    onDecline: () => _resolve(context, a, accepted: false),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    Appointment appointment, {
    required bool accepted,
  }) async {
    final status = accepted ? 'confirmed' : 'declined';

    // Demo requests are UI-only: resolve them locally without any backend
    // write so Firestore data is never touched by demo data.
    if (appointment.id.startsWith('demo_')) {
      setState(() => _resolvedDemoIds.add(appointment.id));
      _showSnack(
        context,
        accepted
            ? 'Request accepted (demo)'
            : 'Request declined (demo)',
        error: false,
      );
      return;
    }

    setState(() => _updatingIds.add(appointment.id));
    try {
      await ref
          .read(doctorDashboardControllerProvider)
          .updateStatus(appointment.id, status);
      if (mounted) {
        _showSnack(
          this.context,
          accepted ? 'Request accepted' : 'Request declined',
          error: false,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnack(
          this.context,
          "Couldn't update the request. Check your connection and try again.",
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(appointment.id));
      }
    }
  }

  void _showSnack(BuildContext context, String message,
      {required bool error}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.deepRose : AppColors.confirmedGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
  }
}

/// Card for a single new appointment request.
///
/// Layout: Patient info (name, age) -> Appointment date/time -> Issue ->
/// Online/Offline type -> Accept / Decline actions.
class _RequestCard extends ConsumerWidget {
  final Appointment appointment;
  final bool updating;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.appointment,
    required this.updating,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = appointment;

    // Real requests also read the consultation issue from the patient's
    // health summary in the backend when available.
    final backendIssue = ref
        .watch(requestIssueProvider((userId: a.userId, appointmentId: a.id)));
    final backendIssueText = backendIssue.value ?? '';
    final issue = a.issue.isNotEmpty
        ? a.issue
        : (backendIssueText.isNotEmpty
            ? backendIssueText
            : 'General consultation');

    final nameWithAge =
        a.age != null ? '${a.patientName}, ${a.age}' : a.patientName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient information + Online/Offline type.
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.softLavender,
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
                child: Text(
                  nameWithAge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DoctorModePill(mode: a.mode),
            ],
          ),
          const SizedBox(height: 12),
          // Appointment date and time.
          _infoLine(
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.softPurple,
            text: 'Appointment: ${_formatDateTime(a)}',
          ),
          const SizedBox(height: 8),
          // Health issue / reason for consultation.
          _infoLine(
            icon: Icons.medical_information_rounded,
            iconColor: AppColors.deepRose,
            text: 'Issue: $issue',
          ),
          const SizedBox(height: 12),
          // Request status + Accept / Decline actions.
          Row(
            children: [
              DoctorStatusPill(status: a.status),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: updating ? null : onAccept,
                  icon: updating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    'Accept',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.confirmedGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.confirmedGreen.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: updating ? null : onDecline,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(
                    'Decline',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepRose,
                    side: const BorderSide(
                      color: AppColors.deepRose,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textMedium,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  /// e.g. "18 Aug 2026 · 10:30 AM"
  String _formatDateTime(Appointment a) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = a.date;
    return '${d.day} ${months[d.month - 1]} ${d.year} · ${a.slot}';
  }
}

/// Stand-in doctor used when the logged-in doctor's profile is not available
/// yet, so dummy requests can still render. Never persisted anywhere.
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

/// Temporary dummy appointment requests (UI/testing only).
///
/// Realistic Indian patient names, ages, dates, times, issues and Online /
/// Offline modes. They are pure UI-only demo data: Accept / Decline only
/// removes them from the local list and they never touch Firestore or the real
/// booking system. Real backend requests are always listed after them.
List<Appointment> _dummyPendingRequests(Doctor doctor) {
  final createdAt = DateTime.now().subtract(const Duration(hours: 2));
  return [
    Appointment(
      id: 'demo_req_1',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: DateTime.now().add(const Duration(days: 1)),
      slot: '10:30 AM',
      fee: doctor.consultationFee,
      patientName: 'Priya Sharma',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.requested,
      age: 29,
      issue: 'Irregular periods',
    ),
    Appointment(
      id: 'demo_req_2',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: DateTime.now().add(const Duration(days: 1)),
      slot: '11:45 AM',
      fee: doctor.consultationFee,
      patientName: 'Anjali Mehta',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.requested,
      age: 34,
      issue: 'Heavy bleeding during periods',
    ),
    Appointment(
      id: 'demo_req_3',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: DateTime.now().add(const Duration(days: 2)),
      slot: '09:30 AM',
      fee: doctor.consultationFee,
      patientName: 'Isha Patel',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.requested,
      age: 25,
      issue: 'Severe period cramps',
    ),
    Appointment(
      id: 'demo_req_4',
      doctor: doctor,
      mode: ConsultationMode.offline,
      date: DateTime.now().add(const Duration(days: 2)),
      slot: '02:00 PM',
      fee: doctor.consultationFee,
      patientName: 'Neha Gupta',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.requested,
      age: 32,
      issue: 'PCOS follow-up consultation',
    ),
    Appointment(
      id: 'demo_req_5',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: DateTime.now().add(const Duration(days: 3)),
      slot: '04:30 PM',
      fee: doctor.consultationFee,
      patientName: 'Ritu Deshmukh',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.requested,
      age: 28,
      issue: 'Delayed periods (40 days)',
    ),
    Appointment(
      id: 'demo_req_6',
      doctor: doctor,
      mode: ConsultationMode.online,
      date: DateTime.now().add(const Duration(days: 3)),
      slot: '12:15 PM',
      fee: doctor.consultationFee,
      patientName: 'Kavya Krishnan',
      userId: '',
      createdAt: createdAt,
      status: AppointmentStatus.requested,
      age: 31,
      issue: 'Painful periods',
    ),
  ];
}