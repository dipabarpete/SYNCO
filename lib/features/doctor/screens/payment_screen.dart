import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../models/appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const PaymentScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  Appointment? _appointment;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAppointment();
  }

  Future<void> _fetchAppointment() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('bookings').doc(widget.appointmentId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final doctorId = data['doctorId'];
        final doctorDoc = await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
        if (doctorDoc.exists) {
          final doctor = Doctor.fromFirestore(doctorDoc);
          setState(() {
            _appointment = Appointment.fromMap(doc.id, data, doctor);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = "Doctor not found.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = "Appointment not found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load appointment: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUPIPayment() async {
    if (_appointment == null) return;
    
    final doctorName = Uri.encodeComponent(_appointment!.doctor.name);
    final uri = Uri.parse('upi://pay?pa=doctor@upi&pn=$doctorName&am=${_appointment!.fee}&cu=INR');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No UPI app found. Please install a digital payment app like GPay or PhonePe.'),
        ),
      );
    }
  }

  Future<void> _confirmPayment() async {
    if (_appointment == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.appointmentId).update({
        'paymentStatus': 'paid',
        'status': 'confirmed' // Assuming it might need to be explicitly set or already is
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Confirmed Successfully!')),
      );
      Navigator.pop(context); // Go back after payment
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm payment: $e')),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Complete Payment',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            style: GoogleFonts.inter(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_appointment == null) return const SizedBox.shrink();

    final a = _appointment!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.softLavender,
                  child: Text(
                    a.doctor.initials,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.softPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  a.doctor.name,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${a.modeName} Consultation',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${a.formattedDateShort} \u2022 ${a.slot}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Consultation Fee',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Text(
                      '₹${a.fee}',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _launchUPIPayment,
            icon: const Icon(Icons.payment_rounded, color: Colors.white),
            label: Text(
              'Pay Now via UPI',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _isProcessing ? null : _confirmPayment,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.softPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'I have completed the payment',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.softPurple,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
