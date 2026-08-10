import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/endometriosis_questions_data.dart';
import '../models/endometriosis_assessment_result.dart';
import '../models/endometriosis_question.dart';
import '../services/endometriosis_assessment_scoring_service.dart';

class EndometriosisAssessmentState {
  final int currentQuestionIndex;
  final Map<int, int> answers; // questionIndex -> optionIndex
  final EndometriosisAssessmentResult? result;
  final bool isCompleted;

  const EndometriosisAssessmentState({
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.result,
    this.isCompleted = false,
  });

  EndometriosisQuestion get currentQuestion => endometriosisQuestions[currentQuestionIndex];
  bool get hasSelectedCurrent => answers.containsKey(currentQuestionIndex);
  int? get currentSelectedOption => answers[currentQuestionIndex];

  EndometriosisAssessmentState copyWith({
    int? currentQuestionIndex,
    Map<int, int>? answers,
    EndometriosisAssessmentResult? result,
    bool? isCompleted,
  }) {
    return EndometriosisAssessmentState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

final endometriosisAssessmentProvider =
    StateNotifierProvider<EndometriosisAssessmentNotifier, EndometriosisAssessmentState>((ref) {
  return EndometriosisAssessmentNotifier();
});

class EndometriosisAssessmentNotifier extends StateNotifier<EndometriosisAssessmentState> {
  EndometriosisAssessmentNotifier() : super(const EndometriosisAssessmentState());

  void selectOption(int optionIndex) {
    final updatedAnswers = Map<int, int>.from(state.answers);
    updatedAnswers[state.currentQuestionIndex] = optionIndex;
    state = state.copyWith(answers: updatedAnswers);
  }

  bool nextQuestion() {
    if (!state.hasSelectedCurrent) return false;

    if (state.currentQuestionIndex < endometriosisQuestions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      return true;
    } else {
      // Reached end of Q24 -> Calculate Result
      final calculatedResult = EndometriosisAssessmentScoringService.calculateResult(state.answers);
      state = state.copyWith(
        result: calculatedResult,
        isCompleted: true,
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
    state = const EndometriosisAssessmentState();
  }
}
