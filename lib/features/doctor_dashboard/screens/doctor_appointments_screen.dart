import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_appointment_card.dart';
import '../widgets/doctor_section_widgets.dart';

/// Appointments tab of the Doctor Portal.
///
/// Groups the doctor's appointment requests and existing appointments into
/// Requests / Today / Upcoming / Completed sections. Accept, decline, chat,
/// complete and AI-summary actions reuse the existing appointment
/// functionality.
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
          message: "Couldn't load your appointments. Check your connection "
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
    final requests = ref.watch(pendingRequestsProvider);
    final today = ref.watch(todayAppointmentsProvider);
    final upcoming = ref.watch(upcomingAppointmentsProvider);
    final completed = ref.watch(completedAppointmentsProvider);

    final hasAny =
        requests.isNotEmpty || today.isNotEmpty || upcoming.isNotEmpty || completed.isNotEmpty;

    if (!hasAny) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          DoctorEmptyState(
            icon: Icons.event_available_rounded,
            title: 'No appointments yet',
            subtitle: 'Appointment requests and consultations will appear here.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (requests.isNotEmpty) ...[
          _buildSectionTitle('Requests', requests.length),
          const SizedBox(height: 12),
          ...requests.map((a) => DoctorAppointmentCard(
                appointment: a,
                showActions: true,
              )),
          const SizedBox(height: 24),
        ],
        if (today.isNotEmpty) ...[
          _buildSectionTitle("Today's Appointments", today.length),
          const SizedBox(height: 12),
          ...today.map((a) => DoctorAppointmentCard(
                appointment: a,
                showEnterChat: true,
                showComplete: true,
              )),
          const SizedBox(height: 24),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildSectionTitle('Upcoming', upcoming.length),
          const SizedBox(height: 12),
          ...upcoming.map((a) => DoctorAppointmentCard(
                appointment: a,
                showEnterChat: true,
                showComplete: true,
              )),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty) ...[
          _buildSectionTitle('Completed', completed.length),
          const SizedBox(height: 12),
          ...completed.map((a) => DoctorAppointmentCard(appointment: a)),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DoctorSectionHeader(title: title),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.softLavender.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.softPurple,
            ),
          ),
        ),
      ],
    );
  }
}