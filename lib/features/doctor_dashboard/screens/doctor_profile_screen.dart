import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/doctor.dart';
import '../providers/doctor_provider.dart';
import 'doctor_availability_sheet.dart';
import 'doctor_settings_screen.dart';

/// Profile tab of the Doctor Portal.
///
/// Shows the complete, professional profile of the logged-in doctor: photo,
/// credentials, verification badge, gender (only when publicly enabled),
/// specializations, experience, consultations, hospital/clinic, bio, patient
/// rating and languages. Everything is driven by the doctor's actual profile
/// data from `doctors/{doctorId}`; nothing is hardcoded or assumed.
///
/// Also lets the doctor add weekly availability which is written into the
/// existing availability fields consumed by the patient booking flow.
class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    final completedCount = ref.watch(completedAppointmentsProvider).length;

    return SafeArea(
      bottom: false,
      child: doctorAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (error, _) => _ProfileErrorState(
          onRetry: () => ref.invalidate(currentDoctorProvider),
        ),
        data: (doctor) {
          if (doctor == null) {
            return const _ProfileMissingState();
          }
          return _buildContent(context, ref, doctor, completedCount);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Doctor doctor,
    int completedCount,
  ) {
    final consultations = completedCount > 0
        ? completedCount
        : doctor.consultationsCount;
    final specializations = doctor.specializationList;

    Future<void> openAddAvailability() async {
      final doctorId = ref.read(currentDoctorIdProvider);
      if (doctorId == null) return;
      final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.creamWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => DoctorAvailabilitySheet(doctorId: doctorId),
      );
      if (saved == true && context.mounted) {
        ref.invalidate(currentDoctorProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability added successfully!'),
            backgroundColor: AppColors.softPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    Future<void> openEditProfile() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorSettingsScreen()),
      );
      if (context.mounted) ref.invalidate(currentDoctorProvider);
    }

    return RefreshIndicator(
      color: AppColors.softPurple,
      onRefresh: () async {
        ref.invalidate(currentDoctorProvider);
        ref.invalidate(doctorAppointmentsProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildHeaderCard(context, doctor, onEdit: openEditProfile),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timeline_rounded,
                  value: doctor.experience.isEmpty
                      ? '—'
                      : doctor.experience,
                  label: 'Experience',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_available_rounded,
                  value: '${_formatCount(consultations)} Consultations',
                  label: 'Provided',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (doctor.visibleGender != null) ...[
            _SectionCard(
              title: 'Gender',
              child: _InfoTile(
                icon: Icons.wc_rounded,
                text: doctor.visibleGender!,
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (specializations.isNotEmpty) ...[
            _SectionCard(
              title: 'Specializations',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: specializations
                    .map((s) => _TagChip(label: s))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (doctor.isOfflineConsultant) ...[
            _HospitalCard(doctor: doctor),
            const SizedBox(height: 14),
          ],

          if (doctor.about.trim().isNotEmpty) ...[
            _SectionCard(
              title: 'About the Doctor',
              child: Text(
                doctor.about.trim(),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.55,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          _RatingCard(doctor: doctor),
          const SizedBox(height: 14),

          if (doctor.languages.isNotEmpty) ...[
            _SectionCard(
              title: 'Languages',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: doctor.languages
                    .map((l) => _TagChip(label: l, variant: _ChipVariant.pink))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          _AvailabilityCard(
            slots: doctor.availabilitySlots,
            onAdd: openAddAvailability,
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: openAddAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.add_rounded, size: 22),
              label: Text(
                'Add Availability',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: openEditProfile,
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
                color: AppColors.softPurple,
              ),
              label: Text(
                'Edit Profile Details',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero card: photo, name, qualifications, license ID and verified badge.
  /// The badge is only shown when the profile explicitly marks the doctor as
  /// verified - it is never claimed for unverified profiles.
  Widget _buildHeaderCard(
    BuildContext context,
    Doctor doctor, {
    required VoidCallback onEdit,
  }) {
    final qualifications = doctor.qualifications.join(', ');
    final licenseId = doctor.licenseId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.softPurple, AppColors.softPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.softPurple.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Photo (initials-based fallback when no photo URL is stored, or
          // when the photo fails to load).
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: SizedBox(
                width: 76,
                height: 76,
                child: (doctor.photoUrl != null &&
                        doctor.photoUrl!.isNotEmpty)
                    ? Image.network(
                        doctor.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _InitialsAvatar(doctor: doctor),
                      )
                    : _InitialsAvatar(doctor: doctor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (qualifications.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              qualifications,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.94),
              ),
            ),
          ],
          if (licenseId != null && licenseId.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              'License: $licenseId',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (doctor.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 17,
                    color: Color(0xFF7BE0BE),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Verified Doctor',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Profile Pending Verification',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 17,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats large counts with thousands separators, e.g. 1240 -> "1,240".
  String _formatCount(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

/// Initials avatar used when the doctor has no photo (or it fails to load).
class _InitialsAvatar extends StatelessWidget {
  final Doctor doctor;

  const _InitialsAvatar({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: doctor.avatarBackground,
      child: Center(
        child: Text(
          doctor.initials,
          style: GoogleFonts.outfit(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.softPurple,
          ),
        ),
      ),
    );
  }
}

/// A single labelled stat, e.g. "8+ Years" / "1,240 Consultations".
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.softPurple),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded white card with a section title.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Icon + text row used for simple facts (e.g. Gender).
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softLavender.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.softPurple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

enum _ChipVariant { purple, pink }

/// Small clean chip/tag used for specializations and languages.
class _TagChip extends StatelessWidget {
  final String label;
  final _ChipVariant variant;

  const _TagChip({required this.label, this.variant = _ChipVariant.purple});

  @override
  Widget build(BuildContext context) {
    final isPurple = variant == _ChipVariant.purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: isPurple
            ? AppColors.softLavender.withValues(alpha: 0.55)
            : AppColors.babyPink,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPurple
              ? AppColors.softPurpleLight.withValues(alpha: 0.35)
              : AppColors.blushPinkLight.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: isPurple ? AppColors.softPurple : AppColors.deepRose,
        ),
      ),
    );
  }
}

/// Hospital / Clinic section for offline consultations. Only rendered when the
/// doctor actually offers offline visits, so a misleading location is never
/// shown.
class _HospitalCard extends StatelessWidget {
  final Doctor doctor;

  const _HospitalCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final name = doctor.clinicName;
    final location = doctor.clinicLocation;

    return _SectionCard(
      title: 'Hospital / Clinic',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.babyPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.deepRose,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null && name.isNotEmpty)
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    if (location != null && location.isNotEmpty) ...[
                      if (name != null && name.isNotEmpty)
                        const SizedBox(height: 3),
                      Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                    if (doctor.mode == ConsultationMode.offline) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.confirmedGreen,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Visit the clinic for offline consultations',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.confirmedGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Patient rating: average, star rating and number of ratings. Computed from
/// the doctor's actual rating data (kept in sync with real patient reviews).
class _RatingCard extends StatelessWidget {
  final Doctor doctor;

  const _RatingCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final count = doctor.reviewCount;
    final hasRatings = count > 0 && doctor.rating > 0;

    return _SectionCard(
      title: 'Patient Rating',
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                hasRatings ? doctor.rating.toStringAsFixed(1) : '—',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final filled = hasRatings
                        ? (doctor.rating - index).clamp(0.0, 1.0)
                        : 0.0;
                    return Icon(
                      filled >= 0.75
                          ? Icons.star_rounded
                          : filled >= 0.25
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded,
                      size: 19,
                      color: hasRatings
                          ? const Color(0xFFFFC107)
                          : AppColors.borderGrey,
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  hasRatings
                      ? '$count patient '
                          'rating${count == 1 ? '' : 's'}'
                      : 'No ratings yet',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: hasRatings
                        ? AppColors.textDark
                        : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Saved weekly availability entries plus the empty state before any slot is
/// added. Populated from the doctor's real `availabilitySlots` data.
class _AvailabilityCard extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final VoidCallback onAdd;

  const _AvailabilityCard({required this.slots, required this.onAdd});

  static const _dayOrder = {
    'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4,
    'Fri': 5, 'Sat': 6, 'Sun': 7,
  };

  String _modeLabel(String mode) {
    switch (mode) {
      case 'online':
        return 'Online';
      case 'offline':
        return 'Offline';
      case 'both':
        return 'Online & Offline';
      default:
        return mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...slots]..sort((a, b) {
        final da = _dayOrder[(a['day'] ?? '').toString()] ?? 0;
        final db = _dayOrder[(b['day'] ?? '').toString()] ?? 0;
        return da.compareTo(db);
      });

    return _SectionCard(
      title: 'Availability',
      child: sorted.isEmpty
          ? Column(
              children: [
                const Icon(
                  Icons.event_available_outlined,
                  size: 30,
                  color: AppColors.softPurpleLight,
                ),
                const SizedBox(height: 8),
                Text(
                  'No availability added yet',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Add slots so patients can book consultations with you.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                for (final slot in sorted) ...[
                  _AvailabilityTile(
                    day: (slot['day'] ?? '').toString(),
                    range:
                        '${slot['start'] ?? '—'} – ${slot['end'] ?? '—'}',
                    modeLabel: _modeLabel((slot['mode'] ?? '').toString()),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  final String day;
  final String range;
  final String modeLabel;

  const _AvailabilityTile({
    required this.day,
    required this.range,
    required this.modeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.softPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.softPurple,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                range,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                modeLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown when the doctor profile document could not be loaded.
class _ProfileErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 12),
            Text(
              "Couldn't load your profile.",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Shown when the logged-in user has no doctor profile yet.
class _ProfileMissingState extends StatelessWidget {
  const _ProfileMissingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.medical_information_outlined,
              size: 40,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 12),
            Text(
              'No doctor profile found.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your registration to see your profile here.',
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