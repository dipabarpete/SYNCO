import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/diagnosis_option_card.dart';
import '../widgets/onboarding_screen_layout.dart';

/// Total steps of the Early Risk Assessment branch (Q1-Q10, Q11-Q17 and the
/// two reproductive-context screens that follow Q17 = No).
const int _earlyRiskTotalSteps = 22;

Route<void> _nextRoute(Widget page) => PageRouteBuilder<void>(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      ),
  transitionDuration: const Duration(milliseconds: 300),
);

Widget _continueButton({
  required bool enabled,
  required VoidCallback onPressed,
}) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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

Widget _sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.softPurple,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _EarlyRiskSingleChoiceScreen extends StatelessWidget {
  final int currentStep;
  final String section;
  final String question;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;
  final String? supportingText;
  final List<(String, Color, String)>? decoratedOptions;

  // Multi-select support (used for family/metabolic/reproductive questions).
  final List<String>? selectedValues;
  final ValueChanged<String>? onToggle;

  const _EarlyRiskSingleChoiceScreen({
    required this.currentStep,
    required this.section,
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.onContinue,
    this.supportingText,
    this.decoratedOptions,
    this.selectedValues,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isMulti = onToggle != null;
    final isSelected = isMulti
        ? (selectedValues?.isNotEmpty ?? false)
        : selectedValue != null;
    return OnboardingScreenLayout(
      currentStep: currentStep,
      totalSteps: _earlyRiskTotalSteps,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(enabled: isSelected, onPressed: onContinue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _sectionLabel(section),
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
          if (supportingText != null) ...[
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
                      supportingText!,
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
          ],
          const SizedBox(height: 28),
          if (decoratedOptions != null)
            for (final option in decoratedOptions!)
              DiagnosisOptionCard(
                label: option.$1,
                subtitle: option.$3.isNotEmpty ? option.$3 : null,
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: option.$2,
                  ),
                ),
                isSelected: selectedValue == option.$1,
                onTap: () => onSelected(option.$1),
              )
          else
            for (final option in options)
              DiagnosisOptionCard(
                label: option,
                isSelected: isMulti
                    ? (selectedValues?.contains(option) ?? false)
                    : selectedValue == option,
                onTap: () => isMulti ? onToggle!(option) : onSelected(option),
              ),
        ],
      ),
    );
  }
}

/// Q1 — Age
class EarlyRiskAgeScreen extends ConsumerWidget {
  const EarlyRiskAgeScreen({super.key});

  static const _options = ['Under 18', '18–24', '25–34', '35–44', '45+'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 4,
      section: 'BASIC INFORMATION',
      question: 'What is your age?',
      options: _options,
      selectedValue: state.ageRange,
      onSelected: ref.read(onboardingProvider.notifier).setAgeRange,
      onContinue: () =>
          Navigator.push(context, _nextRoute(const EarlyRiskHeightScreen())),
    );
  }
}

/// Q2 — Height
class EarlyRiskHeightScreen extends ConsumerStatefulWidget {
  const EarlyRiskHeightScreen({super.key});

  @override
  ConsumerState<EarlyRiskHeightScreen> createState() =>
      _EarlyRiskHeightScreenState();
}

class _EarlyRiskHeightScreenState extends ConsumerState<EarlyRiskHeightScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingProvider).heightCm;
    _controller = TextEditingController(
      text: initial != null ? initial.toString() : '',
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);

    final raw = _controller.text.trim();
    final value = double.tryParse(raw);
    final isValid =
        raw.isNotEmpty && value != null && value >= 100 && value <= 250;

    return OnboardingScreenLayout(
      currentStep: 5,
      totalSteps: _earlyRiskTotalSteps,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: isValid,
        onPressed: () {
          notifier.setHeightCm(_controller.text);
          Navigator.push(context, _nextRoute(const EarlyRiskWeightScreen()));
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _sectionLabel('BASIC INFORMATION'),
          Text(
            'How tall are you?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Height',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
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
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => notifier.setHeightCm(_controller.text),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your height',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.height_rounded,
                    color: AppColors.softPurple,
                  ),
                ),
                suffixText: 'cm',
                suffixStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Q3 — Current Weight
class EarlyRiskWeightScreen extends ConsumerStatefulWidget {
  const EarlyRiskWeightScreen({super.key});

  @override
  ConsumerState<EarlyRiskWeightScreen> createState() =>
      _EarlyRiskWeightScreenState();
}

class _EarlyRiskWeightScreenState extends ConsumerState<EarlyRiskWeightScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingProvider).weightKg;
    _controller = TextEditingController(
      text: initial != null ? initial.toString() : '',
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);

    final raw = _controller.text.trim();
    final value = double.tryParse(raw);
    final isValid =
        raw.isNotEmpty && value != null && value >= 30 && value <= 300;

    return OnboardingScreenLayout(
      currentStep: 6,
      totalSteps: _earlyRiskTotalSteps,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: isValid,
        onPressed: () {
          notifier.setWeightKg(_controller.text);
          Navigator.push(
            context,
            _nextRoute(const EarlyRiskPeriodRegularityScreen()),
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _sectionLabel('BASIC INFORMATION'),
          Text(
            'What is your current weight?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Weight',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
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
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => notifier.setWeightKg(_controller.text),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your weight',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.monitor_weight_outlined,
                    color: AppColors.softPurple,
                  ),
                ),
                suffixText: 'kg',
                suffixStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.softPurple.withValues(alpha: 0.15),
              ),
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
                    'Your height and weight help us understand context only. They are not used to diagnose PCOS.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMedium,
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

/// Q4 — Period Regularity
class EarlyRiskPeriodRegularityScreen extends ConsumerWidget {
  const EarlyRiskPeriodRegularityScreen({super.key});

  static const _options = [
    ('Regular', Color(0xFF66BB6A), 'Usually comes around the same time.'),
    ('Sometimes irregular', Color(0xFFFFCA28), 'Sometimes early or late.'),
    ('Often irregular', Color(0xFFFFA726), 'Frequently unpredictable.'),
    ('Very irregular / periods frequently absent', Color(0xFFEF5350), ''),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 7,
      section: 'MENSTRUAL CYCLE',
      question: 'How regular are your periods?',
      options: const [],
      decoratedOptions: _options,
      selectedValue: state.periodRegularityRisk,
      onSelected: ref.read(onboardingProvider.notifier).setPeriodRegularityRisk,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskCycleLengthScreen()),
      ),
    );
  }
}

/// Q5 — Typical Cycle Length
class EarlyRiskCycleLengthScreen extends ConsumerWidget {
  const EarlyRiskCycleLengthScreen({super.key});

  static const _options = [
    'Less than 21 days',
    '21–35 days',
    '36–45 days',
    'More than 45 days',
    "I don't know",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 8,
      section: 'MENSTRUAL CYCLE',
      question: 'Approximately how long is your typical cycle?',
      supportingText:
          'Your cycle is counted from the first day of one period to the first day of the next.',
      options: _options,
      selectedValue: state.typicalCycleLength,
      onSelected: ref.read(onboardingProvider.notifier).setTypicalCycleLength,
      onContinue: () =>
          Navigator.push(context, _nextRoute(const EarlyRiskGap90DaysScreen())),
    );
  }
}

/// Q6 — 90+ days without a period
class EarlyRiskGap90DaysScreen extends ConsumerWidget {
  const EarlyRiskGap90DaysScreen({super.key});

  static const _options = ['Yes', 'No', "I'm not sure"];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 9,
      section: 'MENSTRUAL CYCLE',
      question: 'Have you ever gone 90 days or more without a period?',
      options: _options,
      selectedValue: state.periodGap90Days,
      onSelected: ref.read(onboardingProvider.notifier).setPeriodGap90Days,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskPeriodChangeScreen()),
      ),
    );
  }
}

/// Q7 — Period changes
class EarlyRiskPeriodChangeScreen extends ConsumerWidget {
  const EarlyRiskPeriodChangeScreen({super.key});

  static const _options = ['Yes', 'No', 'Not sure'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 10,
      section: 'MENSTRUAL CYCLE',
      question:
          'Have your periods changed significantly compared with the past?',
      options: _options,
      selectedValue: state.periodChangeHistory,
      onSelected: ref.read(onboardingProvider.notifier).setPeriodChangeHistory,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskFacialHairScreen()),
      ),
    );
  }
}

/// Q8 — Facial/body hair
class EarlyRiskFacialHairScreen extends ConsumerWidget {
  const EarlyRiskFacialHairScreen({super.key});

  static const _options = ['No', 'Mild', 'Moderate', 'Significant', 'Not sure'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 11,
      section: 'A FEW QUESTIONS ABOUT OTHER SYMPTOMS',
      question:
          'Do you experience unusual or increased facial/body hair growth?',
      options: _options,
      selectedValue: state.facialBodyHairGrowth,
      onSelected: ref.read(onboardingProvider.notifier).setFacialBodyHairGrowth,
      onContinue: () =>
          Navigator.push(context, _nextRoute(const EarlyRiskAcneScreen())),
    );
  }
}

/// Q9 — Acne
class EarlyRiskAcneScreen extends ConsumerWidget {
  const EarlyRiskAcneScreen({super.key});

  static const _options = ['No', 'Occasionally', 'Frequently', 'Severe'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 12,
      section: 'A FEW QUESTIONS ABOUT OTHER SYMPTOMS',
      question: 'Do you experience persistent or severe acne?',
      options: _options,
      selectedValue: state.acneSeverity,
      onSelected: ref.read(onboardingProvider.notifier).setAcneSeverity,
      onContinue: () =>
          Navigator.push(context, _nextRoute(const EarlyRiskScalpHairScreen())),
    );
  }
}

/// Q10 — Scalp hair thinning
class EarlyRiskScalpHairScreen extends ConsumerWidget {
  const EarlyRiskScalpHairScreen({super.key});

  static const _options = ['No', 'Yes', 'Not sure'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 13,
      section: 'A FEW QUESTIONS ABOUT OTHER SYMPTOMS',
      question: 'Have you noticed thinning of hair on your scalp?',
      options: _options,
      selectedValue: state.scalpHairThinning,
      onSelected: ref.read(onboardingProvider.notifier).setScalpHairThinning,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskWeightChangeScreen()),
      ),
    );
  }
}

/// Q11 — Recent weight change
class EarlyRiskWeightChangeScreen extends ConsumerWidget {
  const EarlyRiskWeightChangeScreen({super.key});

  static const _options = [
    'No significant change',
    'Weight gain',
    'Weight loss',
    'Not sure',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 14,
      section: 'METABOLIC & FAMILY HISTORY',
      question: 'Has your weight changed significantly recently?',
      supportingText:
          'Some metabolic and family factors can be relevant when looking at patterns associated with PCOS.',
      options: _options,
      selectedValue: state.recentWeightChange,
      onSelected: ref.read(onboardingProvider.notifier).setRecentWeightChange,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskFamilyHistoryScreen()),
      ),
    );
  }
}

/// Q12 — Family history (multi-select)
class EarlyRiskFamilyHistoryScreen extends ConsumerWidget {
  const EarlyRiskFamilyHistoryScreen({super.key});

  static const _options = [
    'PCOS',
    'Type 2 diabetes',
    'Insulin resistance',
    'None',
    "Don't know",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 15,
      section: 'METABOLIC & FAMILY HISTORY',
      question: 'Does anyone in your immediate family have:',
      options: _options,
      selectedValue: null,
      onSelected: (_) {},
      selectedValues: state.familyConditions,
      onToggle: ref.read(onboardingProvider.notifier).toggleFamilyCondition,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskMetabolicConditionsScreen()),
      ),
    );
  }
}

/// Q13 — Diagnosed metabolic conditions (multi-select)
class EarlyRiskMetabolicConditionsScreen extends ConsumerWidget {
  const EarlyRiskMetabolicConditionsScreen({super.key});

  static const _options = [
    'High blood sugar',
    'Prediabetes/diabetes',
    'High cholesterol',
    'High blood pressure',
    'None',
    "Don't know",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 16,
      section: 'METABOLIC & FAMILY HISTORY',
      question: 'Have you ever been told by a doctor that you have:',
      options: _options,
      selectedValue: null,
      onSelected: (_) {},
      selectedValues: state.diagnosedMetabolicConditions,
      onToggle: ref.read(onboardingProvider.notifier).toggleMetabolicCondition,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskPhysicalActivityScreen()),
      ),
    );
  }
}

/// Q14 — Physical activity
class EarlyRiskPhysicalActivityScreen extends ConsumerWidget {
  const EarlyRiskPhysicalActivityScreen({super.key});

  static const _options = [
    'Mostly sedentary',
    'Light activity',
    'Moderate activity',
    'Very active',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 17,
      section: 'LIFESTYLE',
      question: 'How physically active are you?',
      supportingText:
          'Lifestyle factors can provide additional context, but they are less important than menstrual and clinical features in this assessment.',
      options: _options,
      selectedValue: state.physicalActivity,
      onSelected: ref.read(onboardingProvider.notifier).setPhysicalActivity,
      onContinue: () =>
          Navigator.push(context, _nextRoute(const EarlyRiskSleepScreen())),
    );
  }
}

/// Q15 — Sleep duration
class EarlyRiskSleepScreen extends ConsumerWidget {
  const EarlyRiskSleepScreen({super.key});

  static const _options = ['Less than 5', '5–6', '6–7', '7–9', 'More than 9'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 18,
      section: 'LIFESTYLE',
      question: 'How many hours do you usually sleep?',
      options: _options,
      selectedValue: state.sleepDuration,
      onSelected: ref.read(onboardingProvider.notifier).setSleepDuration,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskStressScaleScreen()),
      ),
    );
  }
}

/// Q16 — Stress level (1-5 scale)
class EarlyRiskStressScaleScreen extends ConsumerWidget {
  const EarlyRiskStressScaleScreen({super.key});

  static const _levels = [
    (1, 'Very low'),
    (2, 'Low'),
    (3, 'Moderate'),
    (4, 'High'),
    (5, 'Very high'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final selected = state.stressLevel;

    return OnboardingScreenLayout(
      currentStep: 19,
      totalSteps: _earlyRiskTotalSteps,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: selected != null,
        onPressed: () => Navigator.push(
          context,
          _nextRoute(const EarlyRiskPregnancyScreen()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _sectionLabel('LIFESTYLE'),
          Text(
            'How would you describe your stress level?',
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
                    'Rate your stress from 1 — Very low to 5 — Very high.',
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
          Row(
            children: [
              for (final level in _levels)
                Expanded(
                  child: _StressScaleItem(
                    value: level.$1,
                    label: level.$2,
                    isSelected: selected == level.$1,
                    onTap: () => notifier.setStressLevel(level.$1),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StressScaleItem extends StatelessWidget {
  final int value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StressScaleItem({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.pureWhite,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.softPurple
                        : AppColors.borderGrey.withValues(alpha: 0.8),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.softPurple.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.softPurple
                            : AppColors.textLight,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: AppColors.softPurple,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Q17 — Pregnancy status (safety gate)
class EarlyRiskPregnancyScreen extends ConsumerWidget {
  const EarlyRiskPregnancyScreen({super.key});

  static const _options = ['Yes', 'No', 'Not sure'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 20,
      section: 'IMPORTANT SAFETY QUESTIONS',
      question: 'Are you currently pregnant or could you be pregnant?',
      supportingText:
          'These questions help us make sure the assessment is interpreted appropriately for your current situation.',
      options: _options,
      selectedValue: state.pregnancyStatus,
      onSelected: ref.read(onboardingProvider.notifier).setPregnancyStatus,
      onContinue: () {
        if (state.pregnancyStatus == 'No') {
          Navigator.push(
            context,
            _nextRoute(const EarlyRiskReproductiveContextScreen()),
          );
        } else {
          // Yes or Not sure: pregnancy-aware, non-standard interpretation.
          Navigator.push(
            context,
            _nextRoute(const PregnancyAwareResultScreen()),
          );
        }
      },
    );
  }
}

/// Follow-up (Q17 = No) — reproductive context (multi-select)
class EarlyRiskReproductiveContextScreen extends ConsumerWidget {
  const EarlyRiskReproductiveContextScreen({super.key});

  static const _options = [
    'Recently stopped hormonal contraception',
    'Currently breastfeeding',
    'Recently gave birth / postpartum',
    'None of these',
    'Not sure',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    return _EarlyRiskSingleChoiceScreen(
      currentStep: 21,
      section: 'IMPORTANT SAFETY QUESTIONS',
      question: 'Have any of these situations applied to you recently?',
      options: _options,
      selectedValue: null,
      onSelected: (_) {},
      selectedValues: state.reproductiveContext,
      onToggle: ref.read(onboardingProvider.notifier).toggleReproductiveContext,
      onContinue: () => Navigator.push(
        context,
        _nextRoute(const EarlyRiskMenstrualConditionScreen()),
      ),
    );
  }
}

/// Final question (Q17 = No) — known medical condition affecting the cycle
class EarlyRiskMenstrualConditionScreen extends ConsumerStatefulWidget {
  const EarlyRiskMenstrualConditionScreen({super.key});

  @override
  ConsumerState<EarlyRiskMenstrualConditionScreen> createState() =>
      _EarlyRiskMenstrualConditionScreenState();
}

class _EarlyRiskMenstrualConditionScreenState
    extends ConsumerState<EarlyRiskMenstrualConditionScreen> {
  late final TextEditingController _conditionController;

  static const _options = ['Yes', 'No', 'Not sure'];

  @override
  void initState() {
    super.initState();
    _conditionController = TextEditingController(
      text:
          ref.read(onboardingProvider).menstrualAffectingConditionDetails ?? '',
    );
  }

  @override
  void dispose() {
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final hasSelection = state.menstrualAffectingCondition != null;
    final showsInput = state.menstrualAffectingCondition == 'Yes';

    return OnboardingScreenLayout(
      currentStep: 22,
      totalSteps: _earlyRiskTotalSteps,
      onBackTap: () => Navigator.pop(context),
      bottomButton: _continueButton(
        enabled: hasSelection,
        onPressed: () {
          notifier.setMenstrualAffectingConditionDetails(
            _conditionController.text,
          );
          Navigator.push(context, _nextRoute(const EarlyRiskResultScreen()));
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _sectionLabel('IMPORTANT SAFETY QUESTIONS'),
          Text(
            'Do you have any known medical condition that affects your menstrual cycle?',
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
              isSelected: state.menstrualAffectingCondition == option,
              onTap: () {
                if (option != 'Yes') _conditionController.clear();
                notifier.setMenstrualAffectingCondition(option);
              },
            ),
          if (showsInput) ...[
            const SizedBox(height: 8),
            Text(
              "If you'd like, tell us what condition:",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conditionController,
              minLines: 2,
              maxLines: 4,
              onChanged: notifier.setMenstrualAffectingConditionDetails,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter condition (optional)',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.pureWhite,
                contentPadding: const EdgeInsets.all(18),
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
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info banner used on the outcome screens.
class _OutcomeBanner extends StatelessWidget {
  final String text;
  final IconData icon;

  const _OutcomeBanner({
    required this.text,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.softPurple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.softPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.softPurple,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared layout for the questionnaires completion / outcome stages.
class _EarlyRiskOutcomeScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<(String, String, String)> features;
  final List<Widget> banners;
  final bool isSubmitting;
  final VoidCallback onGoToApp;

  const _EarlyRiskOutcomeScreen({
    required this.title,
    required this.subtitle,
    required this.features,
    required this.banners,
    required this.isSubmitting,
    required this.onGoToApp,
  });

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMedium,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),

                      for (final item in features)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.borderGrey.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor.withValues(
                                  alpha: 0.04,
                                ),
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
                                  color: AppColors.babyPink.withValues(
                                    alpha: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.softPurple.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item.$1,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.$2,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.$3,
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
                      ...banners,
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
                      onPressed: isSubmitting ? null : onGoToApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
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

/// Completion / hand-off stage for users who completed the questionnaire on
/// the standard (non-pregnancy) interpretation path.
class EarlyRiskResultScreen extends ConsumerWidget {
  const EarlyRiskResultScreen({super.key});

  static const _features = [
    (
      '🌸',
      'Track your cycle & wellness',
      'Keep track of periods, symptoms, mood, and daily wellness.',
    ),
    (
      '📚',
      'Learn at your own pace',
      'Explore the Learn Corner for symptom-friendly guidance.',
    ),
    (
      '👩‍⚕️',
      'Talk to a professional',
      'Discuss any patterns with a doctor whenever you feel ready.',
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
        : (authState.userProfile?.username.isNotEmpty == true &&
                  authState.userProfile?.username != 'User'
              ? authState.userProfile!.username
              : 'there');

    final displayName = rawName.trim().isNotEmpty ? rawName.trim() : 'there';

    final hasReproductiveContext =
        onboardingState.reproductiveContext.isNotEmpty ||
        onboardingState.menstrualAffectingCondition == 'Yes';

    return _EarlyRiskOutcomeScreen(
      title: 'Thank you, $displayName.',
      subtitle:
          'You’ve completed the early check-in. Here’s how Synco can support you next.',
      features: _features,
      banners: [
        if (hasReproductiveContext)
          const _OutcomeBanner(
            text:
                'Some of the situations you shared (such as stopping contraception, breastfeeding, recent birth, or a known condition) can affect menstrual patterns on their own. Keep that in mind when discussing these patterns with a healthcare professional.',
          ),
        const _OutcomeBanner(
          text:
              'Some of the patterns you shared can be associated with PCOS, but these answers cannot diagnose PCOS. These symptoms can also have other causes. If you’re concerned, consider discussing your symptoms with a healthcare professional.',
        ),
      ],
      isSubmitting: onboardingState.isSubmitting,
      onGoToApp: () => _onGoToApp(context, ref),
    );
  }
}

/// Completion / hand-off stage for users who answered Yes or Not sure to the
/// pregnancy question. A standard PCOS screening interpretation is not
/// appropriate in this situation, so none is generated.
class PregnancyAwareResultScreen extends ConsumerWidget {
  const PregnancyAwareResultScreen({super.key});

  static const _features = [
    (
      '🌸',
      'Track your cycle & wellness',
      'Keep track of periods, symptoms, mood, and daily wellness.',
    ),
    (
      '👩‍⚕️',
      'Talk to a professional',
      'Discuss anything that feels unusual with a doctor whenever you’re ready.',
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
        : (authState.userProfile?.username.isNotEmpty == true &&
                  authState.userProfile?.username != 'User'
              ? authState.userProfile!.username
              : 'there');

    final displayName = rawName.trim().isNotEmpty ? rawName.trim() : 'there';

    return _EarlyRiskOutcomeScreen(
      title: 'Thank you, $displayName.',
      subtitle:
          'You’ve completed the early check-in. Here’s how Synco can support you next.',
      features: _features,
      banners: const [
        _OutcomeBanner(
          icon: Icons.favorite_rounded,
          text:
              'Because you’re pregnant or may be pregnant, changes in your cycle and other symptoms can be related to the pregnancy itself. A standard PCOS screening interpretation is not appropriate right now, so we haven’t generated one.',
        ),
        _OutcomeBanner(
          text:
              'These answers are not a diagnosis. If anything feels unusual, consider discussing it with a healthcare professional.',
        ),
      ],
      isSubmitting: onboardingState.isSubmitting,
      onGoToApp: () => _onGoToApp(context, ref),
    );
  }
}
