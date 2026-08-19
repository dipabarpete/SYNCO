import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/doctor_verification_provider.dart';
import 'verification_step_scaffold.dart';
import 'account_step_screen.dart';

/// Step 6 - Professional contact.
class ContactStepScreen extends ConsumerStatefulWidget {
  const ContactStepScreen({super.key});

  @override
  ConsumerState<ContactStepScreen> createState() => _ContactStepScreenState();
}

class _ContactStepScreenState extends ConsumerState<ContactStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final data = ref.read(doctorVerificationProvider).data;
    _emailController = TextEditingController(text: data.professionalEmail);
    _phoneController = TextEditingController(text: data.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  static final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(doctorVerificationProvider.notifier);
    notifier
      ..setProfessionalEmail(_emailController.text)
      ..setPhone(_phoneController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountStepScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VerificationStepScaffold(
      step: 6,
      title: 'Professional Contact',
      subtitle:
          'This professional email will be your login identifier. Use an '
          'email address you regularly access for your professional account.',
      onContinue: _continue,
      child: Form(
        key: _formKey,
        child: VerificationCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerificationSectionHeader(
                title: 'Contact Details',
                trailing: 'Step 6 of 7',
              ),
              const SizedBox(height: 16),
              VerificationTextField(
                label: 'Professional / Work Email',
                helperText:
                    'This email will be your login identifier. Use an email '
                    'address you regularly access.',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Professional email is required.';
                  }
                  if (!_emailRegex.hasMatch(text)) {
                    return 'Please enter a valid professional email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              VerificationTextField(
                label: 'Phone Number',
                helperText:
                    'A number where we can reach you professionally '
                    '(e.g. +91 98765 43210).',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Phone number is required.';
                  }
                  final digits = text.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 7 || digits.length > 15) {
                    return 'Please enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.softPurple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your professional email is securely associated with '
                      'your doctor account.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}