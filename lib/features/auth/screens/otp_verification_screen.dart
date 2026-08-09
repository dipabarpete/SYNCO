import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _countdown = 30;
  bool _isResendActive = false;
  bool _isLoading = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _isResendActive = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _countdown = 0;
          _isResendActive = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _handleVerify() async {
    final code = _otpCode;
    setState(() {
      _inlineError = null;
    });

    if (code.length < 6) {
      setState(() {
        _inlineError = 'Please enter all 6 digits of the OTP code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.verifyPhoneOtp(
      phoneNumber: widget.phoneNumber,
      otpCode: code,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Pop all auth screens back to main navigator scope
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _inlineError = 'Invalid code. Please check and try again.';
      });
    }
  }

  void _handleResendOtp() async {
    if (!_isResendActive) return;

    setState(() {
      _inlineError = null;
    });

    final parts = widget.phoneNumber.split(' ');
    final countryCode = parts.isNotEmpty ? parts[0] : '+1';
    final numberOnly = parts.length > 1 ? parts.sublist(1).join('') : widget.phoneNumber;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.sendPhoneOtp(
      countryCode: countryCode,
      phoneNumber: numberOnly,
    );

    _startCountdown();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A new 6-digit OTP code has been sent to ${widget.phoneNumber}',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.softPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
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
          'Verification Code',
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
              
              // Header Badge Icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lavenderAccent.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  color: AppColors.softPurple,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Enter 6-digit Code',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Code sent to ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6 OTP Input Boxes Grid Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 58,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace) {
                          if (_controllers[index].text.isEmpty && index > 0) {
                            _controllers[index - 1].clear();
                            _focusNodes[index - 1].requestFocus();
                          }
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _inlineError != null
                                  ? AppColors.deepRose
                                  : AppColors.borderGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.softPurple,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (_inlineError != null) {
                            setState(() {
                              _inlineError = null;
                            });
                          }
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (_otpCode.length == 6) {
                            _handleVerify();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),

              // Inline Error Message
              if (_inlineError != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.deepRose,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _inlineError!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.deepRose,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Resend OTP Countdown Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Didn\'t receive the code?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _isResendActive ? _handleResendOtp : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        _isResendActive
                            ? 'Resend OTP'
                            : 'Resend OTP in ${_countdown}s',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isResendActive
                              ? AppColors.softPurple
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Verify & Continue Button
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
                    onPressed: _isLoading ? null : _handleVerify,
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
                            'Verify & Continue',
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
