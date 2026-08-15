import 'package:flutter/material.dart';
import '../../doctor_dashboard/screens/doctor_dashboard_screen.dart' as new_dashboard;

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We are routing the old dashboard directly to the new one so hot reload instantly picks it up!
    return const new_dashboard.DoctorDashboardScreen();
  }
}
