import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../../doctor_dashboard/screens/doctor_dashboard_screen.dart';

class DoctorAuthScreen extends ConsumerStatefulWidget {
  const DoctorAuthScreen({super.key});

  @override
  ConsumerState<DoctorAuthScreen> createState() => _DoctorAuthScreenState();
}

class _DoctorAuthScreenState extends ConsumerState<DoctorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.deepRose,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    ref.read(authNotifierProvider.notifier).clearMessages();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        final success = await ref.read(authNotifierProvider.notifier).loginWithEmail(
          email: email,
          password: password,
        );

        if (success && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDashboardScreen()),
            (route) => false,
          );
        } else {
          final error = ref.read(authNotifierProvider).errorMessage ?? 'Login failed';
          _showError(error);
        }
      } else {
        // Sign Up
        final success = await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: email,
          password: password,
        );

        if (success) {
          final user = ref.read(authNotifierProvider).user;
          if (user != null) {
            final newDoctor = Doctor(
              id: user.id,
              name: _nameController.text.trim(),
              specialization: 'General Physician', // Default for now
              experience: '0 Years',
              consultationFee: 50,
              rating: 0.0,
              availability: 'Available Today',
              mode: ConsultationMode.online,
              about: 'Newly registered practitioner on SYNCO.',
              availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
              timeSlots: ['10:00 AM', '12:00 PM', '02:00 PM', '04:00 PM'],
              licenseId: _licenseController.text.trim(),
            );
            
            await DoctorService().createDoctorProfile(newDoctor);

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DoctorDashboardScreen()),
                (route) => false,
              );
            }
          }
        } else {
          final error = ref.read(authNotifierProvider).errorMessage ?? 'Sign up failed';
          _showError(error);
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.creamWhite,
              Color(0xFFF3EFE0),
              Color(0xFFFAF8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Branding Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pureWhite,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.softPurple.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 48,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      _isLogin ? 'SYNCO Doctor Login' : 'Register as Doctor',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Consultant & Healthcare Practitioner Access',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  if (!_isLogin) ...[
                    // Full Name Field
                    _buildLabel('Full Name (with Title)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'e.g. Dr. John Smith, MD',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Medical License Field
                    _buildLabel('Medical License Number'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _licenseController,
                      hintText: 'MCI-84920-IND',
                      icon: Icons.badge_outlined,
                      validator: (v) => v!.isEmpty ? 'License is required' : null,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email Field
                  _buildLabel('Work Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'dr.smith@hospital.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Password must be 6+ characters' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isLogin ? 'Access Doctor Dashboard' : 'Create Doctor Account',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Toggle Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isLogin 
                            ? 'New practitioner? Apply for access here.'
                            : 'Already registered? Sign in here.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.softPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.softPurple),
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepRose, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepRose, width: 2),
        ),
      ),
    );
  }
}
