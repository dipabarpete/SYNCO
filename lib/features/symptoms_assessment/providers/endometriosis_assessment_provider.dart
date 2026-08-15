import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/endometriosis_questions_data.dart';
import '../models/endometriosis_assessment_result.dart';
import '../models/endometriosis_question.dart';
import '../models/saved_screening_result.dart';
import '../services/endometriosis_assessment_scoring_service.dart';
import 'screening_results_provider.dart';

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
  return EndometriosisAssessmentNotifier(ref);
});

class EndometriosisAssessmentNotifier extends StateNotifier<EndometriosisAssessmentState> {
  EndometriosisAssessmentNotifier(this._ref)
      : super(const EndometriosisAssessmentState());

  final Ref _ref;

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
      _persistResult(calculatedResult);
      return true;
    }
  }

  /// Saves the completed result so the user's latest attempt survives
  /// restarts and re-logins.
  void _persistResult(EndometriosisAssessmentResult result) {
    unawaited(
      _ref
          .read(screeningResultsProvider.notifier)
          .save(SavedScreeningResult.fromEndometriosis(result)),
    );
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
