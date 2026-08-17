import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/consultation_session.dart';
import '../../doctor/screens/consultation_chat_screen.dart';
import '../providers/consultation_providers.dart';
import '../providers/doctor_provider.dart';

/// Live consultation surface shared by the doctor and the patient.
///
/// This is the actual room both participants enter after joining. The
/// communication medium reuses the existing SYNCO consultation chat; the
/// video / call interface renders the real session state (who joined, when
/// the consultation started, elapsed time) for that medium.
///
/// Only the assigned doctor sees the "End Consultation" action; ending marks
/// the booking as completed through the existing booking flow so it moves
/// into appointment history and unlocks the existing review system.
class ConsultationSessionScreen extends ConsumerStatefulWidget {
  final Appointment appointment;
  final ConsultationKind kind;
  final bool isDoctor;

  const ConsultationSessionScreen({
    super.key,
    required this.appointment,
    required this.kind,
    required this.isDoctor,
  });

  @override
  ConsumerState<ConsultationSessionScreen> createState() =>
      _ConsultationSessionScreenState();
}

class _ConsultationSessionScreenState
    extends ConsumerState<ConsultationSessionScreen> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  bool get _isCall => widget.kind == ConsultationKind.call;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = ref.read(consultationSessionProvider(
        widget.appointment.id,
      )).value;
      final started = session?.startedAt;
      if (started != null) {
        setState(() {
          _elapsed = DateTime.now().difference(started);
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _endConsultation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'End Consultation?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Ending the consultation will mark this appointment as '
          'completed and close the consultation room.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: AppColors.textMedium,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'End Consultation',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppColors.deepRose,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final doctorId = ref.read(currentDoctorIdProvider);
    if (doctorId == null) return;
    try {
      await ref
          .read(consultationServiceProvider)
          .markCompleted(widget.appointment.id, doctorId);
      // The existing booking flow moves the appointment into history and
      // notifies the patient (see DoctorService.updateAppointmentStatus).
      await ref
          .read(doctorServiceProvider)
          .updateAppointmentStatus(widget.appointment.id, 'completed');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not end the consultation: $e'),
            backgroundColor: AppColors.deepRose,
          ),
        );
      }
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationChatScreen(
          chatId: widget.appointment.id,
          patientName: widget.isDoctor
              ? widget.appointment.patientName
              : widget.appointment.doctor.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      consultationSessionProvider(widget.appointment.id),
    );

    return Scaffold(
      backgroundColor: AppColors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isCall ? 'Call Consultation' : 'Video Consultation',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: sessionAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Could not load the consultation.',
                    style: GoogleFonts.inter(color: Colors.white70),
                  ),
                ),
                data: (session) =>
                    _buildRoomBody(context, session),
              ),
            ),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomBody(BuildContext context, ConsultationSession? session) {
    final joined = session?.doctorJoined == true &&
        session?.patientJoined == true;
    final patientName = widget.appointment.patientName;
    final doctorName = widget.appointment.doctor.name;

    final myName = widget.isDoctor ? doctorName : patientName;
    final otherName = widget.isDoctor ? patientName : doctorName;
    final otherJoined = widget.isDoctor
        ? (session?.patientJoined ?? false)
        : (session?.doctorJoined ?? false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_isCall)
            _buildCallSurface(
              avatar: _Avatar(letter: myName.isNotEmpty ? myName[0] : '?'),
              name: myName,
              joined: true,
              big: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildVideoTile(
                    label: 'You',
                    name: myName,
                    joined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVideoTile(
                    label: 'Patient',
                    name: otherName,
                    joined: otherJoined,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          _StatusBanner(
            joined: joined,
            waitingText: _isCall
                ? 'Waiting for ${_firstName(otherName)} to join the call…'
                : 'Waiting for ${_firstName(otherName)} to join the video…',
            doctorName: doctorName,
          ),
          const SizedBox(height: 12),
          if (joined && _elapsed != Duration.zero) ...[
            Text(
              _formatElapsed(_elapsed),
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isCall ? 'Call in progress' : 'Video consultation in progress',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.white70,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your camera and microphone are shared securely with '
                    '${_firstName(doctorName)} through this consultation '
                    'session. Text chat is available at any time.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallSurface({
    required _Avatar avatar,
    required String name,
    required bool joined,
    bool big = false,
  }) {
    return Column(
      children: [
        avatar.withSize(big ? 96 : 64),
        const SizedBox(height: 12),
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: big ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: joined
                ? AppColors.mintGreen.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                joined
                    ? Icons.circle_rounded
                    : Icons.hourglass_top_rounded,
                size: 10,
                color: joined ? AppColors.mintGreen : Colors.white54,
              ),
              const SizedBox(width: 5),
              Text(
                joined ? 'Connected' : 'Connecting…',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: joined ? AppColors.mintGreen : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTile({
    required String label,
    required String name,
    required bool joined,
  }) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceAccent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: joined
              ? AppColors.mintGreen.withValues(alpha: 0.5)
              : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Avatar(letter: name.isNotEmpty ? name[0] : '?').withSize(52),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            joined ? 'Joined' : label == 'Patient' ? 'Waiting…' : 'Joining…',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: joined ? AppColors.mintGreen : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (widget.isDoctor)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _endConsultation,
                icon: const Icon(Icons.call_end_rounded, size: 18),
                label: const Text('End Consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Leave'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool joined;
  final String waitingText;
  final String doctorName;

  const _StatusBanner({
    required this.joined,
    required this.waitingText,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: joined
            ? AppColors.mintGreen.withValues(alpha: 0.25)
            : AppColors.pendingAmberSoft.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (joined)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.mintGreen,
              size: 16,
            )
          else
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.pendingAmber,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              joined ? 'Consultation ready' : waitingText,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: joined ? AppColors.mintGreen : AppColors.pendingAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;

  const _Avatar({required this.letter});

  Widget withSize(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppColors.deepPurple,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => withSize(56);
}

String _firstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'the patient';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _formatElapsed(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0
      ? '${two(h)}:${two(m)}:${two(s)}'
      : '${two(m)}:${two(s)}';
}