import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/fibroids_questions_data.dart';
import '../models/fibroids_assessment_result.dart';
import '../models/fibroids_question.dart';
import '../models/saved_screening_result.dart';
import '../services/fibroids_assessment_scoring_service.dart';
import 'screening_results_provider.dart';

class FibroidsAssessmentState {
  final int currentQuestionIndex;
  final Map<int, int> answers; // questionIndex -> optionIndex
  final UterineFibroidAssessmentResult? result;
  final bool isCompleted;

  const FibroidsAssessmentState({
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.result,
    this.isCompleted = false,
  });

  UterineFibroidQuestion get currentQuestion => fibroidsQuestions[currentQuestionIndex];
  bool get hasSelectedCurrent => answers.containsKey(currentQuestionIndex);
  int? get currentSelectedOption => answers[currentQuestionIndex];

  FibroidsAssessmentState copyWith({
    int? currentQuestionIndex,
    Map<int, int>? answers,
    UterineFibroidAssessmentResult? result,
    bool? isCompleted,
  }) {
    return FibroidsAssessmentState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

final fibroidsAssessmentProvider =
    StateNotifierProvider<FibroidsAssessmentNotifier, FibroidsAssessmentState>((ref) {
  return FibroidsAssessmentNotifier(ref);
});

class FibroidsAssessmentNotifier extends StateNotifier<FibroidsAssessmentState> {
  FibroidsAssessmentNotifier(this._ref) : super(const FibroidsAssessmentState());

  final Ref _ref;

  void selectOption(int optionIndex) {
    final updatedAnswers = Map<int, int>.from(state.answers);
    updatedAnswers[state.currentQuestionIndex] = optionIndex;
    state = state.copyWith(answers: updatedAnswers);
  }

  bool nextQuestion() {
    if (!state.hasSelectedCurrent) return false;

    if (state.currentQuestionIndex < fibroidsQuestions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      return true;
    } else {
      // Reached end of Q24 -> Calculate Result
      final calculatedResult =
          UterineFibroidAssessmentScoringService.calculateResult(state.answers);
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
  void _persistResult(UterineFibroidAssessmentResult result) {
    unawaited(
      _ref
          .read(screeningResultsProvider.notifier)
          .save(SavedScreeningResult.fromFibroids(result)),
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
    state = const FibroidsAssessmentState();
  }
}