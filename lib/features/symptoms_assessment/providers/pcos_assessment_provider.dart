import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pcos_questions_data.dart';
import '../models/pcos_assessment_result.dart';
import '../models/pcos_question.dart';
import '../models/saved_screening_result.dart';
import '../services/pcos_assessment_calculator.dart';
import 'screening_results_provider.dart';

class PcosAssessmentState {
  final int currentQuestionIndex;
  final Map<int, int> answers; // questionIndex -> optionIndex
  final PcosAssessmentResult? result;
  final bool isCompleted;

  const PcosAssessmentState({
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.result,
    this.isCompleted = false,
  });

  PcosQuestion get currentQuestion => pcosQuestions[currentQuestionIndex];
  bool get hasSelectedCurrent => answers.containsKey(currentQuestionIndex);
  int? get currentSelectedOption => answers[currentQuestionIndex];

  PcosAssessmentState copyWith({
    int? currentQuestionIndex,
    Map<int, int>? answers,
    PcosAssessmentResult? result,
    bool? isCompleted,
  }) {
    return PcosAssessmentState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

final pcosAssessmentProvider =
    StateNotifierProvider<PcosAssessmentNotifier, PcosAssessmentState>((ref) {
  return PcosAssessmentNotifier(ref.read(screeningResultsProvider.notifier));
});

class PcosAssessmentNotifier extends StateNotifier<PcosAssessmentState> {
  PcosAssessmentNotifier(this._screeningResultsNotifier)
      : super(const PcosAssessmentState());

  final ScreeningResultsNotifier _screeningResultsNotifier;

  void selectOption(int optionIndex) {
    final updatedAnswers = Map<int, int>.from(state.answers);
    updatedAnswers[state.currentQuestionIndex] = optionIndex;
    state = state.copyWith(answers: updatedAnswers);
  }

  bool nextQuestion() {
    if (!state.hasSelectedCurrent) return false;

    if (state.currentQuestionIndex < pcosQuestions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      return true;
    } else {
      // Reached end of Q23 -> Calculate Result
      final calculatedResult = PcosAssessmentCalculator.calculateResult(state.answers);
      state = state.copyWith(
        result: calculatedResult,
        isCompleted: true,
      );
      _screeningResultsNotifier.save(
        SavedScreeningResult.fromPcos(calculatedResult),
      );
      return true;
    }
  }

  bool previousQuestion() {
    if (state.isCompleted) {
      state = state.copyWith(isCompleted: false);
      return true;
    }
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
      return true;
    }
    return false;
  }

  void reset() {
    state = const PcosAssessmentState();
  }
}
