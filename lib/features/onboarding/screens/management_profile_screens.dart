import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/diagnosis_option_card.dart';
import '../widgets/onboarding_screen_layout.dart';

Route<void> _nextRoute(Widget page) => PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );

Widget _continueButton({required bool enabled, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: enabled ? AppColors.primaryGradient : null,
        color: enabled ? null : AppColors.lightGrey,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.blushPink.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: AppColors.lightGrey,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : AppColors.textLight,
          ),
        ),
      ),
    ),
  );
}

class DiagnosedByScreen extends ConsumerWidget {
  const DiagnosedByScreen({super.key});

  static const _options = [
    'Gynecologist',
    'Endocrinologist',
    'General physician',
    'Other healthcare professional',
    "I'm not sure",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _SingleChoiceScreen(
      currentStep: 4,
      totalSteps: 12,
      question: 'Who diagnosed you?',
      options: _options,
      selectedValue: state.diagnosedBy,
      onSelected: ref.read(onboardingProvider.notifier).setDiagnosedBy,
      onContinue: () => Navigator.push(context, _nextRoute(const DiagnosisTimeframeScreen())),
    );
  }
}

class DiagnosisTimeframeScreen extends ConsumerWidget {
  const DiagnosisTimeframeScreen({super.key});

  static const _options = [
    'Less than 6 months ago',
    '6 months - 1 year ago',
    '1- 3 years ago',
    'More than 3 years ago',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _SingleChoiceScreen(
      currentStep: 5,
      totalSteps: 12,
      question: 'When were you diagnosed?',
      options: _options,
      selectedValue: state.diagnosisTimeframe,
      onSelected: ref.read(onboardingProvider.notifier).setDiagnosisTimeframe,
      onContinue: () => Navigator.push(context, _nextRoute(const MedicationsScreen())),
    );
  }
}

class _SingleChoiceScreen extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String question;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;

  const _SingleChoiceScreen({
    required this.currentStep,
    this.totalSteps = 12,
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue != null;
    return OnboardingScreenLayout(
      currentStep: currentStep,
      totalSteps: totalSteps,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(enabled: isSelected, onPressed: onContinue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            question,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          for (final option in options)
            DiagnosisOptionCard(
              label: option,
              isSelected: selectedValue == option,
              onTap: () => onSelected(option),
            ),
        ],
      ),
    );
  }
}

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  late final TextEditingController _medicationController;

  @override
  void initState() {
    super.initState();
    _medicationController = TextEditingController(
      text: ref.read(onboardingProvider).medicationDetails ?? '',
    );
  }

  @override
  void dispose() {
    _medicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final hasSelectedStatus = state.medicationStatus != null;
    final showsMedicationInput = state.medicationStatus == 'yes';

    return OnboardingScreenLayout(
      currentStep: 6,
      totalSteps: 12,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: hasSelectedStatus,
        onPressed: () {
          notifier.setMedicationDetails(_medicationController.text);
          Navigator.push(context, _nextRoute(const CurrentConcernsScreen()));
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Are you currently taking any medicines or supplements prescribed by your doctor?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          for (final option in const [('Yes', 'yes'), ('No', 'no'), ("I'm not sure", 'not_sure')])
            DiagnosisOptionCard(
              label: option.$1,
              isSelected: state.medicationStatus == option.$2,
              onTap: () {
                if (option.$2 != 'yes') _medicationController.clear();
                notifier.setMedicationStatus(option.$2);
              },
            ),
          if (showsMedicationInput) ...[
            const SizedBox(height: 8),
            Text(
              'If yes, please enter the medicine/supplement name.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _medicationController,
              minLines: 2,
              maxLines: 4,
              onChanged: notifier.setMedicationDetails,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter medicine or supplement name',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.pureWhite,
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.softPurple, width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CurrentConcernsScreen extends ConsumerStatefulWidget {
  const CurrentConcernsScreen({super.key});

  @override
  ConsumerState<CurrentConcernsScreen> createState() => _CurrentConcernsScreenState();
}

class _CurrentConcernsScreenState extends ConsumerState<CurrentConcernsScreen> {
  late final TextEditingController _otherConcernController;

  static const _options = [
    'Irregular periods',
    'Acne',
    'Excess facial/body hair',
    'Hair thinning / hair fall',
    'Weight management',
    'Difficulty losing weight',
    'Darkened skin patches',
    'Mood swings / stress',
    'Fertility concerns',
    'None',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _otherConcernController = TextEditingController(
      text: ref.read(onboardingProvider).otherConcern ?? '',
    );
  }

  @override
  void dispose() {
    _otherConcernController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final hasConcerns = state.currentConcerns.isNotEmpty;
    final showsOtherInput = state.currentConcerns.contains('Other');

    return OnboardingScreenLayout(
      currentStep: 7,
      totalSteps: 12,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: hasConcerns && !state.isSubmitting,
        onPressed: () {
          notifier.setOtherConcern(_otherConcernController.text);
          Navigator.push(context, _nextRoute(const PeriodRegularityScreen()));
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'What are your current main concerns?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          for (final option in _options)
            DiagnosisOptionCard(
              label: option,
              isSelected: state.currentConcerns.contains(option),
              onTap: () {
                final clearsOther =
                    (option == 'Other' && state.currentConcerns.contains('Other')) ||
                        (option == 'None' && !state.currentConcerns.contains('None'));
                if (clearsOther) _otherConcernController.clear();
                notifier.toggleConcern(option);
              },
            ),
          if (showsOtherInput) ...[
            const SizedBox(height: 8),
            Text(
              'Please tell us about your concern',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otherConcernController,
              minLines: 2,
              maxLines: 4,
              onChanged: notifier.setOtherConcern,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter your concern',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.pureWhite,
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.softPurple, width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PeriodRegularityScreen extends ConsumerWidget {
  const PeriodRegularityScreen({super.key});

  static const _options = [
    'Very regular',
    'Mostly regular',
    'Sometimes irregular',
    'Often irregular',
    "I don't get periods currently",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _SingleChoiceScreen(
      currentStep: 8,
      totalSteps: 12,
      question: 'How regular are your periods currently?',
      options: _options,
      selectedValue: state.periodRegularity,
      onSelected: ref.read(onboardingProvider.notifier).setPeriodRegularity,
      onContinue: () => Navigator.push(context, _nextRoute(const PeriodLengthScreen())),
    );
  }
}

class PeriodLengthScreen extends ConsumerStatefulWidget {
  const PeriodLengthScreen({super.key});

  @override
  ConsumerState<PeriodLengthScreen> createState() => _PeriodLengthScreenState();
}

class _PeriodLengthScreenState extends ConsumerState<PeriodLengthScreen> {
  late final TextEditingController _cycleLengthController;

  @override
  void initState() {
    super.initState();
    final initialDays = ref.read(onboardingProvider).averageCycleLengthDays;
    _cycleLengthController = TextEditingController(
      text: initialDays != null ? initialDays.toString() : '',
    );
    _cycleLengthController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cycleLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final isNoPeriodsCurrently =
        state.periodRegularity == "I don't get periods currently" ||
        state.periodRegularity == 'no_periods_currently';

    final text = _cycleLengthController.text.trim();
    final isInputValid = text.isNotEmpty && int.tryParse(text) != null;
    final canContinue = isNoPeriodsCurrently || isInputValid;

    return OnboardingScreenLayout(
      currentStep: 9,
      totalSteps: 12,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: canContinue,
        onPressed: () {
          notifier.setAverageCycleLengthDays(_cycleLengthController.text);
          Navigator.push(context, _nextRoute(const RecentSymptomChangesScreen()));
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Approximately how many days are there between your periods?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.softPurple.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.softPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For example: 28 days means approximately 28 days from the first day of one period to the first day of the next.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMedium,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _cycleLengthController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              onChanged: notifier.setAverageCycleLengthDays,
              decoration: InputDecoration(
                hintText: 'Enter number of days',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.softPurple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.borderGrey.withValues(alpha: 0.8),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.borderGrey.withValues(alpha: 0.8),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.softPurple,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentSymptomChangesScreen extends ConsumerWidget {
  const RecentSymptomChangesScreen({super.key});

  static const _options = [
    'Improved',
    'Stayed about the same',
    'Become worse',
    'Not sure',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _SingleChoiceScreen(
      currentStep: 10,
      totalSteps: 12,
      question: 'Have your symptoms changed recently?',
      options: _options,
      selectedValue: state.recentSymptomChange,
      onSelected: ref.read(onboardingProvider.notifier).setRecentSymptomChange,
      onContinue: () => Navigator.push(context, _nextRoute(const LabReportsScreen())),
    );
  }
}

class LabReportsScreen extends ConsumerWidget {
  const LabReportsScreen({super.key});

  Future<void> _pickReport(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setLabReportUploading(true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        notifier.addLabReport({
          'name': file.name,
          'path': file.path ?? file.name,
          'size': file.size,
          'extension': file.extension ?? '',
          'uploaded_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      notifier.setLabReportUploading(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final hasSelectedOption = state.labReportAvailability != null;
    final isYes = state.labReportAvailability == 'yes';

    return OnboardingScreenLayout(
      currentStep: 11,
      totalSteps: 12,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: hasSelectedOption,
        onPressed: () => Navigator.push(context, _nextRoute(const MainGoalScreen())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Do you have recent laboratory reports?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          for (final option in const [('Yes', 'yes'), ('No', 'no')])
            DiagnosisOptionCard(
              label: option.$1,
              isSelected: state.labReportAvailability == option.$2,
              onTap: () {
                notifier.setLabReportAvailability(option.$2);
              },
            ),
          if (isYes) ...[
            const SizedBox(height: 16),
            Text(
              'Upload Report',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your recent blood work, ultrasound, or hormone lab report.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: state.isUploadingLabReport ? null : () => _pickReport(context, ref),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.softPurple.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.softPurple.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.isUploadingLabReport)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.softPurple),
                          ),
                        )
                      else ...[
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.softPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Select Laboratory Report File',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.softPurple,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (state.labReports.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final report in state.labReports)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.babyPink.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.softPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppColors.softPurple,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          report['name'] ?? 'Lab Report',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => notifier.removeLabReport(report['path'] ?? ''),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        tooltip: 'Remove report',
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class MainGoalScreen extends ConsumerWidget {
  const MainGoalScreen({super.key});

  static const _options = [
    'Better understand my PCOS',
    'Manage my menstrual cycle',
    'Improve nutrition',
    'Manage weight',
    'Improve fitness',
    'Understand my lab reports',
    'Prepare for a doctor consultation',
    'Fertility-related support',
    'General wellness',
  ];

  void _onContinue(BuildContext context, OnboardingNotifier notifier, String? goal) {
    if (goal != null) {
      notifier.setPrimaryGoal(goal);
      Navigator.push(
        context,
        _nextRoute(const PersonalizedNextStepsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final isSelected = state.primaryGoal != null;

    return OnboardingScreenLayout(
      currentStep: 12,
      totalSteps: 12,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: isSelected && !state.isSubmitting,
        onPressed: () => _onContinue(context, notifier, state.primaryGoal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'What is your main goal?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          for (final option in _options)
            DiagnosisOptionCard(
              label: option,
              isSelected: state.primaryGoal == option,
              onTap: () => notifier.setPrimaryGoal(option),
            ),
        ],
      ),
    );
  }
}

class PersonalizedNextStepsScreen extends ConsumerWidget {
  const PersonalizedNextStepsScreen({super.key});

  static const _features = [
    (
      icon: '🌸',
      title: 'Track your cycle & wellness',
      description: 'Keep track of periods, symptoms, mood, and daily wellness.',
    ),
    (
      icon: '🔔',
      title: 'Get period reminders',
      description: 'Stay prepared with timely cycle reminders.',
    ),
    (
      icon: '📚',
      title: 'Learn & move',
      description: 'Explore the Learn Corner, yoga, and guided wellness activities.',
    ),
    (
      icon: '😴',
      title: 'Relax & sleep better',
      description: 'Listen to calming sleep meditations and sounds.',
    ),
    (
      icon: '🥗',
      title: 'Understand your food',
      description: 'Use Synco’s AI to identify foods and get personalized nutrition insights.',
    ),
    (
      icon: '🧪',
      title: 'Understand your lab reports',
      description: 'Upload reports and let Synco help explain the results in simple language.',
    ),
    (
      icon: '📊',
      title: 'See your health trends',
      description: 'Get personalized health insights and reports based on the information you track.',
    ),
    (
      icon: '👩‍⚕️',
      title: 'Talk to a professional',
      description: 'Consult a doctor or healthcare professional whenever you need support.',
    ),
  ];

  Future<void> _onGoToApp(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(onboardingProvider.notifier);
    await notifier.completeOnboarding();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HerSyncMainLayout()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final authState = ref.watch(authNotifierProvider);

    final rawName = onboardingState.userName.isNotEmpty
        ? onboardingState.userName
        : (authState.userProfile?.username.isNotEmpty == true && authState.userProfile?.username != 'User'
            ? authState.userProfile!.username
            : 'there');

    final displayName = rawName.trim().isNotEmpty ? rawName.trim() : 'there';

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.creamWhite,
              Color(0xFFFFF0F5),
              Color(0xFFFAF8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                      tooltip: 'Back',
                    ),
                    const Spacer(),
                    Text(
                      'SYNCO',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading
                      Text(
                        'You’re all set, $displayName.',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Supporting text
                      Text(
                        'Based on what you shared, here’s how Synco can support you in your everyday wellness journey.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMedium,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Feature Cards List
                      for (final item in _features)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.borderGrey.withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.babyPink.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.softPurple.withValues(alpha: 0.15),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textMedium,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Closing message banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.softPurple.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.softPurple.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 22,
                              color: AppColors.softPurple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your journey starts here. Let’s take it one day at a time.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.softPurple,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Primary CTA Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushPink.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onboardingState.isSubmitting
                          ? null
                          : () => _onGoToApp(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: onboardingState.isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Go to My Synco',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
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
