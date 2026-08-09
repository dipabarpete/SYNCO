import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isSignUpMode = false;
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (_emailError != null || _passwordError != null || _generalError != null) {
      setState(() {
        _emailError = null;
        _passwordError = null;
        _generalError = null;
      });
    }
  }

  bool _validateInputs() {
    _clearErrors();
    bool isValid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email address is required.';
      });
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _emailError = 'Please enter a valid email address.';
        });
        isValid = false;
      }
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty.';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters long.';
      });
      isValid = false;
    }

    return isValid;
  }

  void _handleFormSubmit() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    bool success;

    if (_isSignUpMode) {
      success = await authNotifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authNotifier.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final authState = ref.read(authNotifierProvider);
      setState(() {
        _generalError = authState.errorMessage ?? 'Authentication failed. Please try again.';
      });
    }
  }

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    String? resetError;
    bool isResetSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.creamWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Reset Password',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email address to receive password reset instructions.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reset Email Field
                    TextField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.softPurple),
                        filled: true,
                        fillColor: AppColors.pureWhite,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: resetError != null ? AppColors.deepRose : AppColors.borderGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.softPurple, width: 1.8),
                        ),
                      ),
                    ),

                    if (resetError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        resetError!,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.deepRose),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isResetSending
                            ? null
                            : () async {
                                final email = resetEmailController.text.trim();
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(email)) {
                                  setSheetState(() {
                                    resetError = 'Please enter a valid email address.';
                                  });
                                  return;
                                }

                                setSheetState(() {
                                  isResetSending = true;
                                  resetError = null;
                                });

                                final authNotifier = ref.read(authNotifierProvider.notifier);
                                final result = await authNotifier.sendPasswordReset(email);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.isSuccess
                                            ? 'Password reset instructions sent to $email'
                                            : (result.errorMessage ?? 'Failed to send reset email.'),
                                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                                      ),
                                      backgroundColor: result.isSuccess ? AppColors.softPurple : AppColors.deepRose,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isResetSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Send Reset Link',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          _isSignUpMode ? 'Create Account' : 'Email Login',
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
              const SizedBox(height: 6),

              // Segmented Tab Switcher: Log In vs Sign Up
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lavenderAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isSignUpMode) {
                            setState(() {
                              _isSignUpMode = false;
                              _clearErrors();
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isSignUpMode ? AppColors.pureWhite : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isSignUpMode
                                ? [
                                    BoxShadow(
                                      color: AppColors.softPurple.withValues(alpha: 0.1),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Log In',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: !_isSignUpMode ? FontWeight.bold : FontWeight.w500,
                                color: !_isSignUpMode ? AppColors.softPurple : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isSignUpMode) {
                            setState(() {
                              _isSignUpMode = true;
                              _clearErrors();
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isSignUpMode ? AppColors.pureWhite : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isSignUpMode
                                ? [
                                    BoxShadow(
                                      color: AppColors.softPurple.withValues(alpha: 0.1),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Create Account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: _isSignUpMode ? FontWeight.bold : FontWeight.w500,
                                color: _isSignUpMode ? AppColors.softPurple : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Header Badge Icon & Title
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.babyPink,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.blushPink.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isSignUpMode ? Icons.person_add_outlined : Icons.mark_email_read_rounded,
                      color: AppColors.softPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignUpMode ? 'Join HerSync Today' : 'Welcome Back',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          _isSignUpMode
                              ? 'Create your personalized health profile.'
                              : 'Sign in to access your health dashboard.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // General Top Error Alert
              if (_generalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.deepRose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.deepRose.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.deepRose, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _generalError!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.deepRose,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 1. Email Address Field
              Text(
                'Email Address',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.softPurple),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _emailError != null ? AppColors.deepRose : AppColors.borderGrey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _emailError != null ? AppColors.deepRose : AppColors.softPurple,
                      width: 1.8,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (_) => _clearErrors(),
              ),

              if (_emailError != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    _emailError!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.deepRose,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 2. Password Field
              Text(
                'Password',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _isPasswordObscured,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: _isSignUpMode ? 'At least 6 characters' : 'Enter your password',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.softPurple),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMedium,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _passwordError != null ? AppColors.deepRose : AppColors.borderGrey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _passwordError != null ? AppColors.deepRose : AppColors.softPurple,
                      width: 1.8,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (_) => _clearErrors(),
              ),

              if (_passwordError != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    _passwordError!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.deepRose,
                    ),
                  ),
                ),
              ],

              if (!_isSignUpMode) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordSheet,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button
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
                    onPressed: _isLoading ? null : _handleFormSubmit,
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
                            _isSignUpMode ? 'Create Account' : 'Continue',
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

              const SizedBox(height: 24),

              // Switch Option Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Prefer phone or Google? ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Switch option',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
