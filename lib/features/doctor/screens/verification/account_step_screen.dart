import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/doctor_verification_provider.dart';
import 'verification_review_screen.dart';
import 'verification_step_scaffold.dart';

/// Step 7 - Create the doctor account password.
///
/// The account itself is only created when the doctor confirms the review
/// screen. The password is never stored - it is handed straight to Firebase
/// Authentication.
class AccountStepScreen extends ConsumerStatefulWidget {
  const AccountStepScreen({super.key});

  @override
  ConsumerState<AccountStepScreen> createState() => _AccountStepScreenState();
}

class _AccountStepScreenState extends ConsumerState<AccountStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(doctorVerificationProvider);
    _passwordController = TextEditingController(text: state.password);
    _confirmController = TextEditingController(text: state.confirmPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(doctorVerificationProvider.notifier);
    notifier
      ..setPassword(_passwordController.text)
      ..setConfirmPassword(_confirmController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerificationReviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VerificationStepScaffold(
      step: 7,
      title: 'Create Your Doctor Account',
      subtitle:
          'Set a password for your professional account. You will sign in '
          'with your professional email and this password.',
      continueLabel: 'Review Information',
      onContinue: _continue,
      child: Form(
        key: _formKey,
        child: VerificationCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerificationSectionHeader(
                title: 'Account Security',
                trailing: 'Step 7 of 7',
              ),
              const SizedBox(height: 16),
              VerificationTextField(
                label: 'Password',
                helperText: 'At least 6 characters.',
                controller: _passwordController,
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                validator: (value) {
                  final text = value ?? '';
                  if (text.isEmpty) {
                    return 'Password is required.';
                  }
                  if (text.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              VerificationTextField(
                label: 'Confirm Password',
                helperText: 'Re-enter the password to confirm it.',
                controller: _confirmController,
                icon: Icons.lock_reset_rounded,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password.';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.mintGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your password is protected by secure authentication '
                      'and is never stored in plain text.',
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