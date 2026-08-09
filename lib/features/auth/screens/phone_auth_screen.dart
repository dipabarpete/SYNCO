import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  String _selectedCountryCode = '+1';
  String? _inlineError;
  bool _isLoading = false;

  final List<Map<String, String>> _countryCodes = const [
    {'code': '+1', 'country': 'United States / Canada', 'flag': '🇺🇸'},
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+44', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺'},
    {'code': '+81', 'country': 'Japan', 'flag': '🇯🇵'},
    {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷'},
    {'code': '+971', 'country': 'UAE', 'flag': '🇦🇪'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    final rawNumber = _phoneController.text.trim();

    setState(() {
      _inlineError = null;
    });

    if (rawNumber.isEmpty) {
      setState(() {
        _inlineError = 'Please enter your phone number.';
      });
      return;
    }

    if (rawNumber.length < 7 || rawNumber.length > 15) {
      setState(() {
        _inlineError = 'Please enter a valid phone number (7-15 digits).';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final result = await authNotifier.sendPhoneOtp(
      countryCode: _selectedCountryCode,
      phoneNumber: rawNumber,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final fullNumber = '$_selectedCountryCode $rawNumber';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneNumber: fullNumber,
          ),
        ),
      );
    } else {
      setState(() {
        _inlineError = result.errorMessage ?? 'Failed to send OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Phone Verification',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Header Icon Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.babyPink,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blushPink.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.softPurple,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Enter your Phone Number',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We will send a 6-digit verification code to verify your device.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Country Code & Phone Input Field Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _inlineError != null
                        ? AppColors.deepRose
                        : (_phoneFocusNode.hasFocus
                            ? AppColors.softPurple
                            : AppColors.borderGrey),
                    width: _phoneFocusNode.hasFocus || _inlineError != null ? 1.8 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softPurple.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Country Code Dropdown Button
                    Container(
                      padding: const EdgeInsets.only(left: 14, right: 6),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMedium,
                            size: 20,
                          ),
                          items: _countryCodes.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['code'],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['flag']!,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['code']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCountryCode = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    // Divider line
                    Container(
                      height: 28,
                      width: 1,
                      color: AppColors.borderGrey,
                    ),

                    // Phone Number TextField
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          letterSpacing: 0.8,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textLight,
                            letterSpacing: 0.2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        onChanged: (_) {
                          if (_inlineError != null) {
                            setState(() {
                              _inlineError = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Inline Validation Error Message
              if (_inlineError != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.deepRose,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _inlineError!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.deepRose,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blushPink.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Send OTP',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
