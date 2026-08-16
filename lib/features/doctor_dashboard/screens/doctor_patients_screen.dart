import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_section_widgets.dart';
import 'patient_detail_screen.dart';

/// Patients tab of the Doctor Portal.
///
/// Shows the unique patients of the logged-in doctor, derived purely from the
/// existing `bookings` data (no duplicate patient storage is created).
class DoctorPatientsScreen extends ConsumerWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);
    final patients = ref.watch(doctorPatientsProvider);

    return SafeArea(
      bottom: false,
      child: appointmentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (_, _) => DoctorErrorState(
          message: "Couldn't load your patients. Check your connection "
              'and try again.',
          onRetry: () {
            ref.invalidate(doctorAppointmentsProvider);
          },
        ),
        data: (_) {
          if (patients.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                DoctorEmptyState(
                  icon: Icons.group_off_rounded,
                  title: 'No patients yet',
                  subtitle: 'Patients who book a consultation with you will '
                      'appear here.',
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              DoctorSectionHeader(
                title: 'My Patients',
                subtitle: '${patients.length} patient'
                    '${patients.length == 1 ? '' : 's'} from your bookings',
              ),
              const SizedBox(height: 14),
              ...patients.map((p) => _PatientCard(patient: p)),
            ],
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final DoctorPatient patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final last = p.lastAppointment;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                userId: p.userId,
                appointmentId: last.id,
                patientName: p.patientName,
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
                radius: 22,
                backgroundColor: AppColors.softLavender,
                child: Text(
                  p.patientName.isNotEmpty
                      ? p.patientName.substring(0, 1).toUpperCase()
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
                      p.patientName,
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
                      '${p.appointmentCount} appointment'
                      '${p.appointmentCount == 1 ? '' : 's'} • Last: '
                      '${last.formattedDateShort} • ${last.slot}',
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
              DoctorStatusPill(status: last.status),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}