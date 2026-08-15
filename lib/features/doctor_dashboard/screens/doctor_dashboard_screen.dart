import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';
import '../../doctor/screens/consultation_chat_screen.dart';
import '../providers/doctor_provider.dart';
import 'patient_detail_screen.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final doctorName = user?.displayName ?? 'Doctor';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.softLavender,
                child: Icon(Icons.medical_services_rounded, color: AppColors.softPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. $doctorName',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Consultant Portal',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HerSyncAuthGateway(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.deepRose),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.softPurple,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.softPurple,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Requests'),
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(ref, pendingRequestsProvider, showActions: true),
            _buildTabContent(ref, todayAppointmentsProvider, showEnterChat: true),
            _buildTabContent(ref, upcomingAppointmentsProvider, showActions: false, showEnterChat: true),
            _buildTabContent(ref, completedAppointmentsProvider, showActions: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(WidgetRef ref, Provider<List<Appointment>> provider, {bool showActions = false, bool showEnterChat = false}) {
    final appointments = ref.watch(provider);
    
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: AppColors.borderGrey),
            const SizedBox(height: 16),
            Text(
              'No appointments found.',
              style: GoogleFonts.inter(color: AppColors.textMedium),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(context, ref, appointments[index], showActions, showEnterChat);
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, WidgetRef ref, Appointment a, bool showActions, bool showEnterChat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.babyPink,
                child: Text(
                  a.patientName.isNotEmpty ? a.patientName.substring(0, 1).toUpperCase() : 'P',
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
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${a.formattedDateShort} • ${a.slot}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  a.modeName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
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
                  icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                  label: const Text('View AI Summary'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.softPurple,
                    side: const BorderSide(color: AppColors.softPurple),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(doctorDashboardControllerProvider).updateStatus(a.id, 'declined');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.babyPink,
                      foregroundColor: AppColors.deepRose,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(doctorDashboardControllerProvider).updateStatus(a.id, 'confirmed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B76),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          if (showEnterChat) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Message Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
