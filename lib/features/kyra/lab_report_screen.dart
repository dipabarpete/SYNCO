import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'services/ai_analysis_service.dart';

enum ReportType { pdf, photo }

class LabReportScreen extends StatefulWidget {
  const LabReportScreen({super.key});

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen> {
  String? _fileBase64;
  String? _fileName;
  ReportType? _reportType;
  bool _isLoading = false;
  String? _analysisResult;
  String? _errorMessage;
  final AiAnalysisService _apiService = AiAnalysisService();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null || file.bytes!.isEmpty) {
          _showError('The selected PDF file is empty or unreadable.');
          return;
        }

        if (file.size > 10 * 1024 * 1024) {
          _showError('File size exceeds the 10MB limit. Please select a smaller PDF.');
          return;
        }

        final extension = file.extension?.toLowerCase();
        if (extension != 'pdf') {
          _showError('Invalid file format. Please select a PDF file.');
          return;
        }

        setState(() {
          _fileBase64 = base64Encode(file.bytes!);
          _fileName = file.name;
          _reportType = ReportType.pdf;
          _analysisResult = null;
          _errorMessage = null;
        });

        _analyzeLabReport();
      }
    } catch (e) {
      _showError('Failed to pick PDF file. Please try again.');
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        if (bytes.isEmpty) {
          _showError('The selected image is empty or invalid.');
          return;
        }

        if (bytes.length > 10 * 1024 * 1024) {
          _showError('Image size exceeds the 10MB limit. Please upload a smaller image.');
          return;
        }

        final extension = image.name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(extension)) {
          _showError('Unsupported image format. Please select a JPG or PNG photo.');
          return;
        }

        setState(() {
          _fileBase64 = base64Encode(bytes);
          _fileName = image.name;
          _reportType = ReportType.photo;
          _analysisResult = null;
          _errorMessage = null;
        });

        _analyzeLabReport();
      }
    } catch (e) {
      _showError('Failed to pick photo. Please try again.');
    }
  }

  void _showPhotoSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Photo Source',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
              icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
              label: Text('Photo Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt_rounded, color: AppColors.softPurple),
              label: Text('Take a Photo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.softPurple, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportTypeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Report Format',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _pickPdf();
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: Text('📄 Upload PDF', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showPhotoSourceSelector();
              },
              icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
              label: Text('🖼 Upload Photo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeLabReport() async {
    if (_fileBase64 == null || _fileName == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    const medicalPrompt = 
      "Interpret this lab report for female health. Frame your response clearly as follows:\n"
      "1. Simplified Explanation of overall findings.\n"
      "2. What reported values generally mean.\n"
      "3. Key biomarkers or sections to discuss with a doctor.\n"
      "4. Questions to ask your doctor during your next visit.\n\n"
      "Important Safety Instruction: Do NOT present this response as a medical diagnosis. Keep language clear, supportive, and informative.";

    try {
      final String result;
      if (_reportType == ReportType.photo) {
        result = await _apiService.analyzeLabReportImage(
          _fileBase64!, 
          _fileName!,
          medicalPrompt,
        );
      } else {
        result = await _apiService.analyzeLabReport(
          _fileBase64!, 
          _fileName!,
          medicalPrompt,
        );
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _analysisResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to analyze the report right now. Please try again.';
        });
      }
    }
  }

  void _showPrivacyDisclaimerDialog({ReportType? targetType}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softLavender.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.softPurple,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Before you upload your report',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please remove or hide your personal information from the report before uploading.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepRose,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Before uploading a medical report, please hide, crop, or remove personal details such as:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              _buildBulletItem('Full name'),
              _buildBulletItem('Phone number'),
              _buildBulletItem('Email address'),
              _buildBulletItem('Home/address details'),
              _buildBulletItem('Patient ID or other identifying information'),
              _buildBulletItem('Any other information that can directly identify you'),
              const SizedBox(height: 10),
              Text(
                'Only upload the medical information needed for interpretation.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kyra AI helps simplify health reports and does not replace professional medical advice.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textMedium,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (targetType == ReportType.pdf) {
                  _pickPdf();
                } else if (targetType == ReportType.photo) {
                  _showPhotoSourceSelector();
                } else {
                  _showReportTypeSelector();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'OK, Continue',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.deepRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _clearSelectedFile() {
    setState(() {
      _fileBase64 = null;
      _fileName = null;
      _reportType = null;
      _analysisResult = null;
      _errorMessage = null;
    });
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textMedium),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Lab Report Interpreter',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Attached Report Preview Card
            if (_fileBase64 != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    if (_reportType == ReportType.photo)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(_fileBase64!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 56,
                            height: 56,
                            color: AppColors.softLavender,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.softPurple),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.deepRose.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.deepRose, size: 36),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName ?? (_reportType == ReportType.photo ? 'Photo_Report.png' : 'Document.pdf'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _reportType == ReportType.photo ? 'Photo Attached' : 'PDF Attached',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
                      tooltip: 'Remove File',
                      onPressed: _isLoading ? null : _clearSelectedFile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Main Prompt Banner Container (when no file attached)
            if (_fileBase64 == null) ...[
              GestureDetector(
                onTap: _isLoading ? null : () => _showPrivacyDisclaimerDialog(),
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.softLavender.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.picture_as_pdf_rounded, size: 48, color: AppColors.softPurple),
                          SizedBox(width: 16),
                          Icon(Icons.photo_library_rounded, size: 48, color: AppColors.softPurple),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Simplify your health reports with Kyra AI',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Upload a PDF or Photo of your medical report',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dual Action Buttons: PDF and Photo Upload
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _showPrivacyDisclaimerDialog(targetType: ReportType.pdf),
                      icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
                      label: Text('Upload PDF', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _showPrivacyDisclaimerDialog(targetType: ReportType.photo),
                      icon: const Icon(Icons.photo_camera_rounded, color: Colors.white),
                      label: Text('Upload Photo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Loading State
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.softPurple),
                      const SizedBox(height: 16),
                      Text(
                        _reportType == ReportType.photo ? 'Reading photo lab report...' : 'Reading lab results...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Error Message
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepRose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.deepRose.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.deepRose),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              )
            // Analysis Result Area
            else if (_analysisResult != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_information_rounded, color: AppColors.softPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Medical Insight',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      _analysisResult!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
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
