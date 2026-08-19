import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/doctor_verification_provider.dart';
import 'verification_step_scaffold.dart';
import 'contact_step_screen.dart';

/// Step 5 - Clinic / hospital practice information.
class PracticeStepScreen extends ConsumerStatefulWidget {
  const PracticeStepScreen({super.key});

  @override
  ConsumerState<PracticeStepScreen> createState() => _PracticeStepScreenState();
}

class _PracticeStepScreenState extends ConsumerState<PracticeStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final data = ref.read(doctorVerificationProvider).data;
    _nameController = TextEditingController(text: data.clinicName);
    _locationController = TextEditingController(text: data.clinicLocation);
    _addressController = TextEditingController(text: data.clinicAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(doctorVerificationProvider.notifier);
    notifier
      ..setClinicName(_nameController.text)
      ..setClinicLocation(_locationController.text)
      ..setClinicAddress(_addressController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactStepScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VerificationStepScaffold(
      step: 5,
      title: 'Practice Information',
      subtitle:
          'Tell us where you practice. These details will be used on your '
          'doctor profile, for offline consultations and for patient '
          'appointment information.',
      onContinue: _continue,
      child: Form(
        key: _formKey,
        child: VerificationCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerificationSectionHeader(
                title: 'Hospital / Clinic',
                trailing: 'Step 5 of 7',
              ),
              const SizedBox(height: 16),
              VerificationTextField(
                label: 'Hospital / Clinic Name',
                helperText: 'e.g. St. Mary\'s Women\'s Clinic',
                controller: _nameController,
                icon: Icons.local_hospital_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Hospital or clinic name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              VerificationTextField(
                label: 'Hospital / Clinic Location',
                helperText: 'City or area, e.g. Mumbai',
                controller: _locationController,
                icon: Icons.place_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              VerificationTextField(
                label: 'Address',
                helperText: 'Street address, building, landmark (optional)',
                controller: _addressController,
                icon: Icons.home_outlined,
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 14),
              Text(
                'You can edit these details later from your Doctor Profile.',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}