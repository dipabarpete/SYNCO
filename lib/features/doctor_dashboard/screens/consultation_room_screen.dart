import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/consultation_session.dart';
import '../../doctor/screens/consultation_chat_screen.dart';
import '../providers/consultation_providers.dart';
import '../providers/doctor_provider.dart';
import 'consultation_session_screen.dart';

/// Consultation Room of the Doctor Portal.
///
/// Shows the room for a real appointment of the logged-in doctor: patient
/// details, consultation mode selected by the patient, the waiting room with
/// live join status, and the entry point into the actual consultation medium.
///
/// Used both as the center tab of the portal shell ([embedded]) and as a
/// standalone route opened from a consultation notification
/// ([appointmentId] given). Room access is limited to the doctor assigned to
/// the appointment.
class DoctorConsultationRoomScreen extends ConsumerStatefulWidget {
  /// When provided (deep link from a notification), the room is pinned to
  /// this appointment instead of auto-selecting.
  final String? appointmentId;

  /// When true the screen renders inside the portal shell (no Scaffold).
  final bool embedded;

  const DoctorConsultationRoomScreen({
    super.key,
    this.appointmentId,
    this.embedded = false,
  });

  @override
  ConsumerState<DoctorConsultationRoomScreen> createState() =>
      _DoctorConsultationRoomScreenState();
}

class _DoctorConsultationRoomScreenState
    extends ConsumerState<DoctorConsultationRoomScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (widget.appointmentId != null) {
      content = _PinnedRoomBody(appointmentId: widget.appointmentId!);
    } else {
      content = _RoomTabBody(
        selectedId: _selectedId,
        onSelect: (id) => setState(() => _selectedId = id),
      );
    }

    if (widget.embedded) return content;

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
      body: content,
    );
  }
}

/// Tab content: auto-selects the most relevant upcoming consultation and
/// lets the doctor switch between today's/upcoming appointments.
class _RoomTabBody extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _RoomTabBody({required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeConsultationsProvider);
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return SafeArea(
      bottom: false,
      child: appointmentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (_, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Couldn't load your consultations. Check your connection "
              'and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMedium),
            ),
          ),
        ),
        data: (_) {
          if (active.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: const [
                DoctorRoomEmptyState(),
              ],
            );
          }

          final selectedId = this.selectedId ?? active.first.id;
          final selected = active.firstWhere(
            (a) => a.id == selectedId,
            orElse: () => active.first,
          );

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (active.length > 1) ...[
                _AppointmentSelector(
                  appointments: active,
                  selectedId: selected.id,
                  onSelect: onSelect,
                ),
                const SizedBox(height: 14),
              ],
              _ConsultationRoomCard(
                appointment: selected,
                autoJoin: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Deep-linked content: loads a single appointment and enforces that it
/// belongs to the logged-in doctor.
class _PinnedRoomBody extends ConsumerWidget {
  final String appointmentId;

  const _PinnedRoomBody({required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync = ref.watch(appointmentByIdProvider(appointmentId));
    final accessAsync =
        ref.watch(doctorConsultationAccessProvider(appointmentId));

    return SafeArea(
      bottom: false,
      child: appointmentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (_, _) => const _RoomErrorState(),
        data: (appointment) {
          if (appointment == null) return const _RoomErrorState();
          return accessAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.softPurple),
            ),
            data: (allowed) => allowed
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _ConsultationRoomCard(
                        appointment: appointment,
                        autoJoin: true,
                      ),
                    ],
                  )
                : const _AccessDeniedState(),
            error: (_, _) => const _RoomErrorState(),
          );
        },
      ),
    );
  }
}

/// Horizontal selector of the doctor's upcoming consultations.
class _AppointmentSelector extends StatelessWidget {
  final List<Appointment> appointments;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _AppointmentSelector({
    required this.appointments,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming consultations',
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final a = appointments[index];
              final selected = a.id == selectedId;
              final active = isConsultationWindowActive(a);
              return GestureDetector(
                onTap: () => onSelect(a.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.softPurple
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.softPurple
                          : AppColors.borderGrey.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.formattedDateShort,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active
                                ? Icons.video_call_rounded
                                : Icons.schedule_rounded,
                            size: 12,
                            color: selected
                                ? Colors.white70
                                : active
                                    ? AppColors.confirmedGreen
                                    : AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            a.slot,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The core Consultation Room card: patient details, consultation mode,
/// waiting room with live status, and the primary join/start action.
class _ConsultationRoomCard extends ConsumerStatefulWidget {
  final Appointment appointment;
  final bool autoJoin;

  const _ConsultationRoomCard({
    required this.appointment,
    this.autoJoin = false,
  });

  @override
  ConsumerState<_ConsultationRoomCard> createState() =>
      _ConsultationRoomCardState();
}

class _ConsultationRoomCardState extends ConsumerState<_ConsultationRoomCard> {
  Timer? _refreshTimer;
  bool _joining = false;

  Appointment get _a => widget.appointment;

  @override
  void initState() {
    super.initState();
    // Re-evaluate the consultation window periodically so the room moves to
    // the active state when the scheduled time arrives.
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _joinAsDoctor() async {
    final doctorId = ref.read(currentDoctorIdProvider);
    if (doctorId == null) return;
    setState(() => _joining = true);
    try {
      await ref
          .read(consultationServiceProvider)
          .join(appointmentId: _a.id, userId: doctorId, role: 'doctor');
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

  void _startConsultation(ConsultationKind kind) {
    final Widget target = switch (kind) {
      ConsultationKind.video || ConsultationKind.call =>
        ConsultationSessionScreen(
          appointment: _a,
          kind: kind,
          isDoctor: true,
        ),
      ConsultationKind.chat || ConsultationKind.clinic =>
        ConsultationChatScreen(chatId: _a.id, patientName: _a.patientName),
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _a;
    final kind = resolveConsultationKind(a);
    final sessionAsync = ref.watch(consultationSessionProvider(a.id));
    final session = sessionAsync.value;

    // The appointment itself was completed through the existing booking flow.
    if (a.status == AppointmentStatus.completed) {
      return _buildCompletedCard(kind);
    }

    final windowActive = isConsultationWindowActive(a);
    final doctorJoined = session?.doctorJoined ?? false;
    final patientJoined = session?.patientJoined ?? false;
    final inProgress = session?.status == ConsultationStatus.inProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PatientInfoCard(appointment: a, kind: kind),
        const SizedBox(height: 14),
        if (!windowActive)
          _buildNotStartedCard(kind)
        else if (inProgress)
          _buildInProgressCard(kind, doctorJoined, patientJoined)
        else if (session == null || !doctorJoined)
          _buildWaitingCard(
            kind,
            joined: doctorJoined,
            patientJoined: false,
          )
        else if (!patientJoined)
          _buildWaitingCard(
            kind,
            joined: true,
            patientJoined: false,
          )
        else
          _buildReadyCard(kind),
      ],
    );
  }

  Widget _buildNotStartedCard(ConsultationKind kind) {
    final a = _a;
    final start = a.startDateTime;
    final timeLabel = start != null
        ? '${a.formattedDateShort} · ${a.slot}'
        : a.slot;

    return _RoomStatusCard(
      icon: Icons.schedule_rounded,
      iconBg: AppColors.pendingAmberSoft,
      iconColor: AppColors.pendingAmber,
      title: 'Consultation has not started yet',
      subtitle:
          'Scheduled for $timeLabel · ${kind.label}. The room becomes '
          'available at the scheduled time.',
    );
  }

  Widget _buildWaitingCard(
    ConsultationKind kind, {
    required bool joined,
    required bool patientJoined,
  }) {
    final a = _a;
    final firstName = a.patientName.trim().split(RegExp(r'\s+')).first;

    return Column(
      children: [
        _RoomStatusCard(
          icon: Icons.hourglass_top_rounded,
          iconBg: AppColors.softLavender.withValues(alpha: 0.5),
          iconColor: AppColors.softPurple,
          title: 'Waiting Room',
          subtitle: joined
              ? 'Waiting for $firstName to join…\nYour patient will join '
                  'when the consultation starts.'
              : 'Your patient will join when the consultation starts.',
          children: [
            const SizedBox(height: 6),
            _ParticipantStatusRow(
              doctorJoined: true,
              patientJoined: patientJoined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!joined)
          _buildPrimaryButton(
            label: 'Join Consultation',
            icon: Icons.login_rounded,
            onTap: _joinAsDoctor,
            loading: _joining,
          )
        else
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
                  'Waiting for the patient to join…',
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

  Widget _buildReadyCard(ConsultationKind kind) {
    final a = _a;
    final firstName = a.patientName.trim().split(RegExp(r'\s+')).first;

    return Column(
      children: [
        _RoomStatusCard(
          icon: Icons.check_circle_rounded,
          iconBg: AppColors.mintGreen.withValues(alpha: 0.35),
          iconColor: AppColors.confirmedGreen,
          title: '$firstName has joined',
          subtitle: 'The consultation is ready. Start the '
              '${kind.label.toLowerCase()} when you are ready.',
          children: [
            const SizedBox(height: 6),
            const _ParticipantStatusRow(
              doctorJoined: true,
              patientJoined: true,
            ),
          ],
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
          onTap: () => _startConsultation(kind),
        ),
      ],
    );
  }

  Widget _buildInProgressCard(
    ConsultationKind kind,
    bool doctorJoined,
    bool patientJoined,
  ) {
    return Column(
      children: [
        _RoomStatusCard(
          icon: Icons.video_call_rounded,
          iconBg: AppColors.mintGreen.withValues(alpha: 0.35),
          iconColor: AppColors.confirmedGreen,
          title: 'Consultation in progress',
          subtitle: 'You and the patient are in the room. Tap below to '
              're-enter the consultation.',
          children: [
            const SizedBox(height: 6),
            _ParticipantStatusRow(
              doctorJoined: doctorJoined,
              patientJoined: patientJoined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildPrimaryButton(
          label: kind == ConsultationKind.video
              ? 'Rejoin Video Consultation'
              : kind == ConsultationKind.call
                  ? 'Rejoin Call'
                  : 'Open Chat',
          icon: switch (kind) {
            ConsultationKind.video => Icons.videocam_rounded,
            ConsultationKind.call => Icons.call_rounded,
            ConsultationKind.chat => Icons.chat_bubble_rounded,
            ConsultationKind.clinic => Icons.chat_bubble_rounded,
          },
          onTap: () => _startConsultation(kind),
        ),
      ],
    );
  }

  Widget _buildCompletedCard(ConsultationKind kind) {
    return _RoomStatusCard(
      icon: Icons.task_alt_rounded,
      iconBg: AppColors.mintGreen.withValues(alpha: 0.35),
      iconColor: AppColors.confirmedGreen,
      title: 'Consultation completed',
      subtitle: 'This appointment has been moved to your appointment '
          'history. The consultation room is now closed.',
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool loading = false,
    bool enabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !loading ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: enabled
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [AppColors.borderGrey, AppColors.lightGrey],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.softPurple.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
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
}

/// Patient summary card at the top of the room.
class _PatientInfoCard extends StatelessWidget {
  final Appointment appointment;
  final ConsultationKind kind;

  const _PatientInfoCard({required this.appointment, required this.kind});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final initial = a.patientName.isNotEmpty
        ? a.patientName.substring(0, 1).toUpperCase()
        : 'P';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.babyPink,
                  child: Text(
                    initial,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
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
                      a.patientName,
                      style: GoogleFonts.outfit(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (a.age != null) 'Age: ${a.age}',
                        a.formattedDateShort,
                        a.slot,
                      ].join(' · '),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                switch (kind) {
                  ConsultationKind.video => Icons.videocam_rounded,
                  ConsultationKind.call => Icons.call_rounded,
                  ConsultationKind.chat => Icons.chat_bubble_rounded,
                  ConsultationKind.clinic => Icons.local_hospital_rounded,
                },
                size: 16,
                color: AppColors.softPurple,
              ),
              const SizedBox(width: 7),
              Text(
                kind.label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softPurple,
                ),
              ),
              const Spacer(),
              _RoomStatusPill(
                windowActive: isConsultationWindowActive(a),
                completed: a.status == AppointmentStatus.completed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomStatusPill extends StatelessWidget {
  final bool windowActive;
  final bool completed;

  const _RoomStatusPill({required this.windowActive, required this.completed});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = completed
        ? (AppColors.mintGreen.withValues(alpha: 0.4),
            AppColors.confirmedGreen, 'Completed')
        : windowActive
            ? (AppColors.softLavender.withValues(alpha: 0.6),
                AppColors.softPurple, 'Waiting for consultation')
            : (AppColors.pendingAmberSoft, AppColors.pendingAmber,
                'Scheduled');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live participant status shown inside the waiting room.
class _ParticipantStatusRow extends StatelessWidget {
  final bool doctorJoined;
  final bool patientJoined;

  const _ParticipantStatusRow({
    required this.doctorJoined,
    required this.patientJoined,
  });

  @override
  Widget build(BuildContext context) {
    Widget status({required String label, required bool joined}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            joined ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 14,
            color: joined
                ? AppColors.confirmedGreen
                : AppColors.textLight,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: joined
                  ? AppColors.confirmedGreen
                  : AppColors.textLight,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        status(label: 'Doctor joined', joined: doctorJoined),
        const SizedBox(width: 18),
        status(label: 'Patient joined', joined: patientJoined),
      ],
    );
  }
}

/// Neutral card used for room states (not started, waiting, ready, done).
class _RoomStatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget>? children;

  const _RoomStatusCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
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
}

class DoctorRoomEmptyState extends StatelessWidget {
  const DoctorRoomEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softLavender,
            ),
            child: const Icon(
              Icons.video_call_rounded,
              size: 34,
              color: AppColors.softPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming consultations',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your confirmed appointments will appear here. When a '
            'consultation time arrives you will get a reminder and can '
            'join the room.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessDeniedState extends StatelessWidget {
  const _AccessDeniedState();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _RoomErrorState extends StatelessWidget {
  const _RoomErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'This appointment could not be found.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMedium),
        ),
      ),
    );
  }
}