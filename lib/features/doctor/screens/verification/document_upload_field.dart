import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';

/// Accepted document types for credential and identity uploads.
const List<String> supportedDocumentExtensions = [
  'pdf',
  'jpg',
  'jpeg',
  'png',
];

/// Upload control for one verification document.
///
/// Shows the four required actions:
///  - Upload
///  - Selected filename
///  - Replace
///  - Remove
///
/// Only supported file/image types are accepted. Files are NOT uploaded
/// anywhere here - they are only picked locally and uploaded when the doctor
/// confirms the submission.
class DocumentUploadField extends ConsumerStatefulWidget {
  final VerificationDocKind kind;
  final String label;
  final String helperText;
  final bool optional;

  /// When true the picker offers camera + gallery (profile photo / selfie).
  final bool isPhoto;

  const DocumentUploadField({
    super.key,
    required this.kind,
    required this.label,
    required this.helperText,
    this.optional = false,
    this.isPhoto = false,
  });

  @override
  ConsumerState<DocumentUploadField> createState() =>
      _DocumentUploadFieldState();
}

class _DocumentUploadFieldState extends ConsumerState<DocumentUploadField> {
  bool _isPicking = false;
  String? _error;

  static const int _maxFileSizeBytes = 15 * 1024 * 1024;

  Future<void> _pick() async {
    final notifier = ref.read(doctorVerificationProvider.notifier);
    setState(() {
      _isPicking = true;
      _error = null;
    });
    try {
      UploadFile? picked;
      if (widget.isPhoto) {
        picked = await _pickPhoto();
      } else {
        picked = await _pickDocument();
      }
      if (picked != null) {
        notifier.pickFile(widget.kind, picked);
      }
    } catch (e) {
      _showError('Could not open the file picker: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<UploadFile?> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedDocumentExtensions,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.size > _maxFileSizeBytes) {
      _showError('This file is too large. Please choose a file under 15 MB.');
      return null;
    }
    final extension = (file.extension ?? '').toLowerCase();
    if (!supportedDocumentExtensions.contains(extension) && file.size > 0) {
      _showError('Only PDF, JPG, JPEG or PNG files are supported.');
      return null;
    }
    return UploadFile(
      name: file.name,
      extension: extension,
      path: file.path,
      bytes: file.bytes,
    );
  }

  Future<UploadFile?> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Profile Photo',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return null;

    final xfile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (xfile == null) return null;

    final bytes = await xfile.readAsBytes();
    if (bytes.length > _maxFileSizeBytes) {
      _showError('This image is too large. Please choose one under 15 MB.');
      return null;
    }
    final name = xfile.path.split('/').last;
    final dot = name.lastIndexOf('.');
    final extension =
        dot >= 0 ? name.substring(dot + 1).toLowerCase() : 'jpg';
    return UploadFile(
      name: name,
      extension: extension,
      path: xfile.path,
      bytes: bytes as Uint8List?,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.deepRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorVerificationProvider);
    final pending = state.pendingFiles[widget.kind];
    final stored = state.data.storedFor(widget.kind);

    final hasFile = pending != null || stored != null;
    final fileName = pending?.name ?? stored?.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (widget.optional)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softLavender,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Optional',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!hasFile)
          _UploadBox(
            label: widget.label,
            isPicking: _isPicking,
            onTap: _pick,
          )
        else
          _SelectedFileTile(
            fileName: fileName ?? '',
            isPicking: _isPicking,
            onReplace: _pick,
            onRemove: () {
              setState(() => _error = null);
              ref.read(doctorVerificationProvider.notifier).removeFile(
                    widget.kind,
                  );
            },
          ),
        const SizedBox(height: 6),
        Text(
          widget.helperText,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textLight,
            height: 1.35,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.deepRose,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final bool isPicking;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.isPicking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPicking ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.babyPink.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lavenderAccent.withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                isPicking ? Icons.hourglass_top_rounded : Icons.cloud_upload_outlined,
                color: AppColors.softPurple,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                isPicking ? 'Opening picker...' : 'Upload',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, JPG, JPEG or PNG',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedFileTile extends StatelessWidget {
  final String fileName;
  final bool isPicking;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  const _SelectedFileTile({
    required this.fileName,
    required this.isPicking,
    required this.onReplace,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.softLavender,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.softLavender,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.softPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (isPicking)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.softPurple,
              ),
            )
          else ...[
            TextButton(
              onPressed: onReplace,
              child: Text(
                'Replace',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softPurple,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.deepRose,
                size: 20,
              ),
              tooltip: 'Remove',
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.softPurple, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}