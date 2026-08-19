import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';
import 'document_upload_field.dart';
import 'verification_step_scaffold.dart';
import 'identity_step_screen.dart';

/// Step 2 - Credential documents.
class CredentialsStepScreen extends ConsumerStatefulWidget {
  const CredentialsStepScreen({super.key});

  @override
  ConsumerState<CredentialsStepScreen> createState() =>
      _CredentialsStepScreenState();
}

class _CredentialsStepScreenState extends ConsumerState<CredentialsStepScreen> {
  String? _fileError;

  bool _requiredDocumentsUploaded() {
    final state = ref.read(doctorVerificationProvider);
    final hasQualification = state.pendingFiles[
              VerificationDocKind.qualificationCertificate] !=
          null ||
        state.data.qualificationCertificate != null;
    final hasRegistration = state.pendingFiles[
              VerificationDocKind.registrationCertificate] !=
          null ||
        state.data.registrationCertificate != null;
    return hasQualification && hasRegistration;
  }

  void _continue() {
    if (!_requiredDocumentsUploaded()) {
      setState(() {
        _fileError =
            'Qualification certificate and registration certificate are '
            'required before continuing.';
      });
      return;
    }
    setState(() => _fileError = null);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IdentityStepScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VerificationStepScaffold(
      step: 2,
      title: 'Professional Credentials',
      subtitle:
          'Upload your credential documents so our team can verify your '
          'professional history. These documents stay private.',
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificationCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationSectionHeader(
                  title: 'Credential Documents',
                  trailing: 'Step 2 of 7',
                ),
                const SizedBox(height: 16),
                DocumentUploadField(
                  kind: VerificationDocKind.qualificationCertificate,
                  label: 'Qualification Certificate',
                  helperText:
                      'Upload the relevant qualification certificate '
                      '(PDF, JPG, JPEG or PNG).',
                ),
                const SizedBox(height: 20),
                DocumentUploadField(
                  kind: VerificationDocKind.registrationCertificate,
                  label: 'Medical Registration Certificate / Card',
                  helperText:
                      'Upload your registration certificate or card issued by '
                      'your registering authority.',
                ),
                const SizedBox(height: 20),
                DocumentUploadField(
                  kind: VerificationDocKind.specializationCertificate,
                  label: 'Specialization Certificate',
                  helperText:
                      'Optional: add your specialization certificate if you '
                      'have one. You can also add it in the Specialty step.',
                  optional: true,
                ),
                if (_fileError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _fileError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.softPurple,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your credential documents are PRIVATE. They are stored '
                    'securely, are never shown on your public profile, and can '
                    'only be accessed by you.',
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      height: 1.4,
                    ),
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