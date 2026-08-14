import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import 'services/ai_analysis_service.dart';

class LabReportScreen extends StatefulWidget {
  const LabReportScreen({super.key});

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen> {
  String? _fileBase64;
  String? _fileName;
  bool _isLoading = false;
  String? _analysisResult;
  final AiAnalysisService _apiService = AiAnalysisService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _fileBase64 = base64Encode(file.bytes!);
          _fileName = file.name;
          _analysisResult = null;
        });
        _analyzeLabReport();
      }
    }
  }

  Future<void> _analyzeLabReport() async {
    if (_fileBase64 == null || _fileName == null) return;
    
    setState(() => _isLoading = true);
    
    final result = await _apiService.analyzeLabReport(
      _fileBase64!, 
      _fileName!,
      "Interpret this lab report and highlight key biomarkers relevant to female health.",
    );
    
    setState(() {
      _isLoading = false;
      _analysisResult = result;
    });
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
            if (_fileBase64 != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: AppColors.deepRose, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName ?? 'Document.pdf',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDF Attached',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (_fileBase64 == null) ...[
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 64, color: AppColors.softPurple),
                    const SizedBox(height: 16),
                    Text(
                      'Upload a blood panel or hormone test (PDF)\nfor instant AI interpretation.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
              label: const Text('Upload PDF File', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            
            const SizedBox(height: 32),

            // Analysis Result Area
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.softPurple),
                    SizedBox(height: 16),
                    Text('Reading lab results...'),
                  ],
                ),
              )
            else if (_analysisResult != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
