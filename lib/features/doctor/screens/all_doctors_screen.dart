import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/doctor.dart';
import '../widgets/doctor_card.dart';
import 'booking_screen.dart';
import 'doctor_profile_screen.dart';

class AllDoctorsScreen extends StatelessWidget {
  final List<Doctor> doctors;
  final String? title;

  const AllDoctorsScreen({
    super.key,
    required this.doctors,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          title ?? 'All Doctors',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DoctorCard(
                doctor: doctor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorProfileScreen(doctor: doctor),
                    ),
                  );
                },
                onBookNow: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(doctor: doctor),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
