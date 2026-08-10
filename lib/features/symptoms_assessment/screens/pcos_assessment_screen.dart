import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/widgets/diagnosis_option_card.dart';
import '../data/pcos_questions_data.dart';
import '../providers/pcos_assessment_provider.dart';
import 'pcos_assessment_result_screen.dart';

class PcosAssessmentScreen extends ConsumerWidget {
  const PcosAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pcosAssessmentProvider);
    final notifier = ref.read(pcosAssessmentProvider.notifier);

    // If screening is completed, navigate directly to Result Screen
    if (state.isCompleted && state.result != null) {
      return PcosAssessmentResultScreen(result: state.result!);
    }

    final currentQuestion = state.currentQuestion;
    final totalQuestions = pcosQuestions.length;
    final progress = (state.currentQuestionIndex + 1) / totalQuestions;
    final isLastQuestion = state.currentQuestionIndex == totalQuestions - 1;
    final canContinue = state.hasSelectedCurrent;

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
              // Top Bar: Back Button, Brand Title & Question Counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (state.currentQuestionIndex > 0) {
                          notifier.previousQuestion();
                        } else {
                          Navigator.pop(context);
                        }
                      },
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.lavenderAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'Question ${state.currentQuestionIndex + 1} of $totalQuestions',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar Line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.softLavender.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.softPurple),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Section Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.babyPink,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.softPurple.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            currentQuestion.section,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question Text
                        Text(
                          currentQuestion.question,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Options Cards
                        for (int i = 0; i < currentQuestion.options.length; i++)
                          DiagnosisOptionCard(
                            label: currentQuestion.options[i],
                            isSelected: state.currentSelectedOption == i,
                            onTap: () => notifier.selectOption(i),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Button Container
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: canContinue ? AppColors.primaryGradient : null,
                      color: canContinue ? null : AppColors.lightGrey,
                      boxShadow: canContinue
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
                      onPressed: canContinue ? () => notifier.nextQuestion() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: AppColors.lightGrey,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isLastQuestion ? 'View Screening Summary' : 'Next',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canContinue ? Colors.white : AppColors.textLight,
                        ),
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
