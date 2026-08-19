import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/doctor_verification_provider.dart';
import 'verification_step_scaffold.dart';
import 'credentials_step_screen.dart';

/// Step 1 - Basic professional information.
class ProfessionalStepScreen extends ConsumerStatefulWidget {
  const ProfessionalStepScreen({super.key});

  @override
  ConsumerState<ProfessionalStepScreen> createState() =>
      _ProfessionalStepScreenState();
}

class _ProfessionalStepScreenState
    extends ConsumerState<ProfessionalStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _regNumberController;
  late final TextEditingController _authorityController;
  late final TextEditingController _qualificationController;

  @override
  void initState() {
    super.initState();
    final data = ref.read(doctorVerificationProvider).data;
    _nameController = TextEditingController(text: data.fullName);
    _regNumberController = TextEditingController(text: data.registrationNumber);
    _authorityController =
        TextEditingController(text: data.registeringAuthority);
    _qualificationController = TextEditingController(text: data.qualification);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNumberController.dispose();
    _authorityController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(doctorVerificationProvider.notifier);
    notifier
      ..setFullName(_nameController.text)
      ..setRegistrationNumber(_regNumberController.text)
      ..setRegisteringAuthority(_authorityController.text)
      ..setQualification(_qualificationController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CredentialsStepScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VerificationStepScaffold(
      step: 1,
      title: 'Doctor Verification',
      subtitle: 'Tell us about your professional credentials.',
      onContinue: _continue,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerificationCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerificationSectionHeader(
                    title: 'Professional Information',
                    trailing: 'Step 1 of 7',
                  ),
                  const SizedBox(height: 16),
                  VerificationTextField(
                    label: 'Full Legal Name',
                    helperText:
                        'Enter your name exactly as it appears on your '
                        'professional records.',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full legal name is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  VerificationTextField(
                    label: 'Medical Registration Number',
                    helperText: 'As printed on your medical registration.',
                    controller: _regNumberController,
                    icon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Medical registration number is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  VerificationTextField(
                    label: 'Medical Council / Registering Authority',
                    helperText:
                        'The council or authority that registers your practice.',
                    controller: _authorityController,
                    icon: Icons.account_balance_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Registering authority is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  VerificationTextField(
                    label: 'Primary Medical Qualification',
                    helperText: 'e.g. MBBS, MBBS MD, MBBS MS',
                    controller: _qualificationController,
                    icon: Icons.school_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Primary medical qualification is required.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}