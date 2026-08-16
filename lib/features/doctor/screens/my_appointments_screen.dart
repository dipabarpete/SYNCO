import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../models/appointment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'find_doctor_screen.dart';
import 'consultation_chat_screen.dart';
import 'review_doctor_screen.dart';

/// User-facing list of appointment requests.
///
/// Pending requests are shown separately from confirmed appointments so the
/// state of every appointment is immediately understandable.
class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: appointmentsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.softPurple),
          ),
          error: (err, stack) => Center(
            child: Text('Error loading appointments.', style: GoogleFonts.inter(color: AppColors.deepRose)),
          ),
          data: (appointments) {
            final requested = appointments.where((a) => a.status == AppointmentStatus.requested).toList();
            final confirmed = appointments.where((a) => a.status == AppointmentStatus.confirmed).toList();
            final declined = appointments.where((a) => a.status == AppointmentStatus.declined).toList();
            final cancelled = appointments.where((a) => a.status == AppointmentStatus.cancelled).toList();
            final completed = appointments.where((a) => a.status == AppointmentStatus.completed).toList();

            final latestConfirmed = confirmed.isEmpty ? null : confirmed.first;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: appointments.isEmpty
                  ? _buildEmptyState(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (latestConfirmed != null) ...[
                          _buildConfirmedBanner(context, latestConfirmed),
                          const SizedBox(height: 22),
                        ],
                        if (requested.isNotEmpty) ...[
                          _buildSectionTitle('UPCOMING'),
                          const SizedBox(height: 12),
                          ...requested.map((a) => _buildAppointmentCard(context, ref, a)),
                          const SizedBox(height: 20),
                        ],
                        if (confirmed.isNotEmpty) ...[
                          _buildSectionTitle('CONFIRMED'),
                          const SizedBox(height: 12),
                          ...confirmed.map((a) => _buildAppointmentCard(context, ref, a)),
                          const SizedBox(height: 20),
                        ],
                        if (completed.isNotEmpty) ...[
                          _buildSectionTitle('COMPLETED'),
                          const SizedBox(height: 12),
                          ...completed.map((a) => _buildCompletedCard(context, ref, a)),
                          const SizedBox(height: 20),
                        ],
                        if (declined.isNotEmpty) ...[
                          _buildSectionTitle('DECLINED'),
                          const SizedBox(height: 12),
                          ...declined.map((a) => _buildAppointmentCard(context, ref, a)),
                          const SizedBox(height: 20),
                        ],
                        if (cancelled.isNotEmpty) ...[
                          _buildSectionTitle('CANCELLED'),
                          const SizedBox(height: 12),
                          ...cancelled.map((a) => _buildAppointmentCard(context, ref, a)),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
        letterSpacing: 0.8,
      ),
    );
  }

  Future<void> _launchUPIPayment(BuildContext context, Appointment a) async {
    final doctorName = Uri.encodeComponent(a.doctor.name);
    final uri = Uri.parse('upi://pay?pa=doctor@upi&pn=$doctorName&am=${a.fee}&cu=INR');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No UPI app found. Please install a digital payment app like GPay or PhonePe.'),
        ),
      );
    }
  }

  Widget _buildConfirmedBanner(BuildContext context, Appointment a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F6EE), Color(0xFFF0FBF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.mintGreen.withValues(alpha: 0.8),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E8B76),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Appointment Confirmed',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E8B76),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${a.doctor.name} has accepted your consultation request.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.35,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${a.formattedDate} \u2022 ${a.slot} \u2022 ${a.modeName}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAppointmentDetails(context, a),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2E8B76)),
                    ),
                    child: Text(
                      'Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E8B76),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _enterChat(context, a),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B76),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chat with Doctor',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildAppointmentCard(
    BuildContext context,
    WidgetRef ref,
    Appointment a,
  ) {
    final doctor = a.doctor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.6),
          width: 1,
        ),
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
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 20,
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${a.modeName} \u2022 ${a.formattedDateShort} \u2022 ${a.slot}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(a.status),
            ],
          ),
          if (a.status == AppointmentStatus.requested) ...[
            const SizedBox(height: 12),
            Text(
              'Your appointment will be confirmed once the doctor accepts '
              'your request.',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _cancelRequest(context, ref, a),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    'Cancel Request',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepRose,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Payment option will appear once the doctor accepts your request.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (a.status == AppointmentStatus.declined) ...[
            const SizedBox(height: 12),
            Text(
              'Your appointment request was declined by the doctor.',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _findAnotherDoctor(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Find Another Doctor',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          if (a.status == AppointmentStatus.confirmed) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchUPIPayment(context, a),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pay ₹${a.fee}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAppointmentDetails(context, a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.softPurpleLight.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Details',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _enterChat(context, a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Chat',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (a.status == AppointmentStatus.completed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAppointmentDetails(context, a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.softPurpleLight.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Details',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Consultation Closed',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Card shown for a completed consultation in the COMPLETED section.
  ///
  /// Lets the user rate & review the doctor — unless a review for this
  /// consultation was already submitted ("Review submitted").
  Widget _buildCompletedCard(
    BuildContext context,
    WidgetRef ref,
    Appointment a,
  ) {
    final doctor = a.doctor;
    final reviewAsync = ref.watch(
      doctorReviewForConsultationProvider((
        doctorId: doctor.id,
        consultationId: a.id,
      )),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.6),
          width: 1,
        ),
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
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 20,
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${a.modeName} \u2022 ${a.formattedDateShort} \u2022 ${a.slot}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(a.status),
            ],
          ),
          const SizedBox(height: 12),
          reviewAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.softPurple,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
            error: (_, _) => _buildReviewButton(context, ref, a),
            data: (review) => review != null
                ? _buildReviewSubmittedCard()
                : _buildReviewButton(context, ref, a),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(
    BuildContext context,
    WidgetRef ref,
    Appointment a,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewDoctorScreen(appointment: a),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.softPurple.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Rate & Review Doctor',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSubmittedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.mintGreen.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mintGreen.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.confirmedGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Review submitted',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.confirmedGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(AppointmentStatus status) {
    final (Color bg, Color fg, String label) = switch (status) {
      AppointmentStatus.requested => (
          AppColors.pendingAmberSoft,
          AppColors.pendingAmber,
          'Awaiting Doctor Confirmation',
        ),
      AppointmentStatus.confirmed => (
          AppColors.mintGreen.withValues(alpha: 0.4),
          AppColors.confirmedGreen,
          'Confirmed',
        ),
      AppointmentStatus.declined => (
          AppColors.babyPink,
          AppColors.deepRose,
          'Request Declined',
        ),
      AppointmentStatus.cancelled => (
          AppColors.lightGrey,
          AppColors.textLight,
          'Cancelled',
        ),
      AppointmentStatus.completed => (
          AppColors.mintGreen.withValues(alpha: 0.4),
          AppColors.confirmedGreen,
          'Completed',
        ),
    };

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

  void _cancelRequest(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) {
    ref.read(doctorServiceProvider).updateAppointmentStatus(appointment.id, 'cancelled');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.softPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          'Appointment request cancelled.',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _enterChat(BuildContext context, Appointment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationChatScreen(
          chatId: a.id,
          patientName: a.doctor.name, // The user is chatting with the doctor
        ),
      ),
    );
  }

  void _findAnotherDoctor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FindDoctorScreen(),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment a) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        final doctor = a.doctor;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: doctor.avatarBackground,
                        child: Text(
                          doctor.initials,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            doctor.specialization,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(a.status),
                  ],
                ),
                const SizedBox(height: 18),
                _buildDetailRow(
                  icon: Icons.videocam_rounded,
                  label: 'Consultation Type',
                  value: a.modeName,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: a.formattedDate,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                  value: a.slot,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Consultation Fee',
                  value: '\u20B9${a.fee}',
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.confirmation_number_rounded,
                  label: 'Request ID',
                  value: a.id,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.babyPink,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: AppColors.deepRose),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textMedium,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softLavender,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 34,
              color: AppColors.softPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Book a consultation and track your request status here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _findAnotherDoctor(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Browse Doctors',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentBottomSheet(BuildContext context, Appointment a) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Complete Payment',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Consultation Fee: ₹${a.fee}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.softPurple,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment processed successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Pay Now ₹${a.fee}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
