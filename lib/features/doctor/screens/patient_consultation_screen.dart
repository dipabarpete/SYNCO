import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/consultation_session.dart';
import '../../doctor_dashboard/providers/consultation_providers.dart';
import '../../doctor_dashboard/screens/consultation_session_screen.dart';
import '../../doctor/screens/consultation_chat_screen.dart';

/// Patient-side Consultation Room.
///
/// Opens the SAME session as the doctor: both sides connect to the
/// `consultations/{appointmentId}` document and the `chats/{appointmentId}`
/// messages, so the patient and the assigned doctor always meet in one room.
///
/// Access is limited to the patient of the appointment (see
/// [patientConsultationAccessProvider] and the Firestore rules).
class PatientConsultationScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const PatientConsultationScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<PatientConsultationScreen> createState() =>
      _PatientConsultationScreenState();
}

class _PatientConsultationScreenState
    extends ConsumerState<PatientConsultationScreen> {
  Timer? _refreshTimer;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _joinAsPatient() async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId == null) return;
    setState(() => _joining = true);
    try {
      await ref.read(consultationServiceProvider).join(
            appointmentId: widget.appointmentId,
            userId: userId,
            role: 'patient',
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not join the consultation: $e'),
            backgroundColor: AppColors.deepRose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  void _startConsultation(Appointment a, ConsultationKind kind) {
    final Widget target = switch (kind) {
      ConsultationKind.video || ConsultationKind.call =>
        ConsultationSessionScreen(
          appointment: a,
          kind: kind,
          isDoctor: false,
        ),
      ConsultationKind.chat || ConsultationKind.clinic =>
        ConsultationChatScreen(chatId: a.id, patientName: a.doctor.name),
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentAsync =
        ref.watch(appointmentByIdProvider(widget.appointmentId));
    final accessAsync =
        ref.watch(patientConsultationAccessProvider(widget.appointmentId));

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Consultation Room',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: appointmentAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.softPurple),
          ),
          error: (_, _) => const Center(
            child: Text(
              'This consultation could not be loaded.',
              style: TextStyle(color: AppColors.textMedium),
            ),
          ),
          data: (appointment) {
            if (appointment == null) {
              return const Center(
                child: Text(
                  'This consultation could not be found.',
                  style: TextStyle(color: AppColors.textMedium),
                ),
              );
            }
            return accessAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.softPurple),
              ),
              data: (allowed) => allowed
                  ? _buildRoom(appointment)
                  : _buildAccessDenied(),
              error: (_, _) => const Center(
                child: Text(
                  'This consultation could not be loaded.',
                  style: TextStyle(color: AppColors.textMedium),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoom(Appointment a) {
    final kind = resolveConsultationKind(a);
    final sessionAsync = ref.watch(consultationSessionProvider(a.id));
    final session = sessionAsync.value;

    if (a.status == AppointmentStatus.completed) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(
            icon: Icons.task_alt_rounded,
            iconBg: AppColors.mintGreen.withValues(alpha: 0.35),
            iconColor: AppColors.confirmedGreen,
            title: 'Consultation completed',
            subtitle: 'Your consultation with ${a.doctor.name} has been '
                'completed. You can rate and review the doctor from your '
                'appointments list.',
          ),
        ],
      );
    }

    final windowActive = isConsultationWindowActive(a);
    final patientJoined = session?.patientJoined ?? false;
    final doctorJoined = session?.doctorJoined ?? false;
    final inProgress = session?.status == ConsultationStatus.inProgress;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildDoctorCard(a, kind),
        const SizedBox(height: 14),
        if (!windowActive)
          _buildStatusCard(
            icon: Icons.schedule_rounded,
            iconBg: AppColors.pendingAmberSoft,
            iconColor: AppColors.pendingAmber,
            title: 'Consultation has not started yet',
            subtitle: 'Scheduled for ${a.formattedDateShort} · ${a.slot} · '
                '${kind.label}. Your doctor will join when the consultation '
                'starts.',
          )
        else if (inProgress || (patientJoined && doctorJoined))
          _buildReadyCard(a, kind)
        else if (patientJoined)
          _buildWaitingCard(a, doctorJoined: doctorJoined, kind: kind)
        else
          _buildJoinCard(a, kind),
      ],
    );
  }

  Widget _buildDoctorCard(Appointment a, ConsultationKind kind) {
    final doctor = a.doctor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: doctor.avatarBackground,
              child: Text(
                doctor.initials,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.outfit(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${a.formattedDateShort} · ${a.slot} · ${kind.label}',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            switch (kind) {
              ConsultationKind.video => Icons.videocam_rounded,
              ConsultationKind.call => Icons.call_rounded,
              ConsultationKind.chat => Icons.chat_bubble_rounded,
              ConsultationKind.clinic => Icons.local_hospital_rounded,
            },
            size: 18,
            color: AppColors.softPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCard(Appointment a, ConsultationKind kind) {
    return Column(
      children: [
        _buildStatusCard(
          icon: Icons.hourglass_top_rounded,
          iconBg: AppColors.softLavender.withValues(alpha: 0.5),
          iconColor: AppColors.softPurple,
          title: 'Waiting Room',
          subtitle: 'Your consultation with ${a.doctor.name} is ready. '
              'Join the room and the doctor will meet you here.',
        ),
        const SizedBox(height: 14),
        _buildPrimaryButton(
          label: kind.actionLabel,
          icon: switch (kind) {
            ConsultationKind.video => Icons.videocam_rounded,
            ConsultationKind.call => Icons.call_rounded,
            ConsultationKind.chat => Icons.chat_bubble_rounded,
            ConsultationKind.clinic => Icons.chat_bubble_rounded,
          },
          onTap: _joinAsPatient,
          loading: _joining,
        ),
      ],
    );
  }

  Widget _buildWaitingCard(
    Appointment a, {
    required bool doctorJoined,
    required ConsultationKind kind,
  }) {
    final doctorName = a.doctor.name.trim().split(RegExp(r'\s+')).first;

    return Column(
      children: [
        _buildStatusCard(
          icon: Icons.hourglass_top_rounded,
          iconBg: AppColors.softLavender.withValues(alpha: 0.5),
          iconColor: AppColors.softPurple,
          title: 'Waiting Room',
          subtitle: doctorJoined
              ? 'Dr. $doctorName has joined the room. The consultation will '
                  'begin shortly.'
              : 'Waiting for Dr. $doctorName to join…',
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _joinDot('Doctor joined', doctorJoined),
                const SizedBox(width: 18),
                _joinDot('You joined', true),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.softLavender.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.softPurple,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                doctorJoined
                    ? 'Starting the consultation…'
                    : 'Waiting for the doctor to join…',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softPurple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadyCard(Appointment a, ConsultationKind kind) {
    final doctorName = a.doctor.name.trim().split(RegExp(r'\s+')).first;

    return Column(
      children: [
        _buildStatusCard(
          icon: Icons.check_circle_rounded,
          iconBg: AppColors.mintGreen.withValues(alpha: 0.35),
          iconColor: AppColors.confirmedGreen,
          title: 'Consultation ready',
          subtitle: 'Dr. $doctorName has joined. Tap below to start your '
              '${kind.label.toLowerCase()}.',
        ),
        const SizedBox(height: 14),
        _buildPrimaryButton(
          label: kind.actionLabel,
          icon: switch (kind) {
            ConsultationKind.video => Icons.videocam_rounded,
            ConsultationKind.call => Icons.call_rounded,
            ConsultationKind.chat => Icons.chat_bubble_rounded,
            ConsultationKind.clinic => Icons.chat_bubble_rounded,
          },
          onTap: () => _startConsultation(a, kind),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    List<Widget>? children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textMedium,
              height: 1.45,
            ),
          ),
          ...?children,
        ],
      ),
    );
  }

  Widget _joinDot(String label, bool joined) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          joined ? Icons.check_circle_rounded : Icons.schedule_rounded,
          size: 14,
          color: joined ? AppColors.confirmedGreen : AppColors.textLight,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: joined ? AppColors.confirmedGreen : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softPurple.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.babyPink,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 30,
                color: AppColors.deepRose,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Access denied',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This consultation does not belong to you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}