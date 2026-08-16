import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/screens/all_doctors_screen.dart';
import 'package:hersync/features/onboarding/widgets/diagnosis_option_card.dart';
import 'package:hersync/features/symptoms_assessment/data/pcos_questions_data.dart';
import 'package:hersync/features/symptoms_assessment/models/endometriosis_assessment_result.dart';
import 'package:hersync/features/symptoms_assessment/models/endometriosis_result_level.dart';
import 'package:hersync/features/symptoms_assessment/models/fibroids_assessment_result.dart';
import 'package:hersync/features/symptoms_assessment/models/fibroids_result_level.dart';
import 'package:hersync/features/symptoms_assessment/models/pcos_assessment_result.dart';
import 'package:hersync/features/symptoms_assessment/models/pcos_result_level.dart';
import 'package:hersync/features/symptoms_assessment/models/saved_screening_result.dart';
import 'package:hersync/features/symptoms_assessment/providers/endometriosis_assessment_provider.dart';
import 'package:hersync/features/symptoms_assessment/providers/fibroids_assessment_provider.dart';
import 'package:hersync/features/symptoms_assessment/providers/pcos_assessment_provider.dart';
import 'package:hersync/features/symptoms_assessment/providers/screening_results_provider.dart';
import 'package:hersync/features/symptoms_assessment/screens/endometriosis_assessment_result_screen.dart';
import 'package:hersync/features/symptoms_assessment/screens/fibroids_assessment_result_screen.dart';
import 'package:hersync/features/symptoms_assessment/screens/pcos_assessment_result_screen.dart';
import 'package:hersync/features/symptoms_assessment/screens/pcos_assessment_screen.dart';
import 'package:hersync/providers/app_providers.dart';
import 'package:hersync/features/doctor/models/doctor.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Highest-scoring option index for each PCOS question (23 questions).
List<int> _maxScoreOptions() {
  return [
    for (final q in pcosQuestions)
      q.scores.indexWhere((s) => s == q.scores.reduce((a, b) => a > b ? a : b)),
  ];
}

PcosAssessmentResult _pcosResult(PcosResultLevel level, {int score = 20}) {
  return PcosAssessmentResult(
    rawScore: score,
    resultLevel: level,
    categoryTitle: 'Higher indication of PCOS-associated features',
    categoryDescription:
        'Your responses include multiple features that can be associated with PCOS. This does not mean that you have PCOS. Similar symptoms can occur with other hormonal or medical conditions.',
    categoryRecommendation:
        'This screening cannot diagnose PCOS. We recommend discussing your results with a qualified healthcare professional.',
    categoryCta: 'Discuss With a Doctor',
    menstrualCluster: true,
    androgenCluster: true,
    metabolicCluster: true,
    clinicalEvidenceCluster: true,
    menstrualStatus: 'Several associated features',
    androgenStatus: 'Several associated features',
    metabolicStatus: 'Several associated features',
    clinicalEvidenceStatus: 'Previous clinical findings reported',
    explanationBullets: const [
      'Your responses indicate some menstrual-cycle features that can be associated with PCOS, such as irregular or widely spaced periods.',
      'You also reported symptoms such as increased facial/body hair, persistent acne, or scalp-hair changes.',
      'You reported some metabolic health factors that can sometimes occur alongside PCOS.',
      'You reported prior clinical findings or medical evaluation history relevant to PCOS.',
    ],
    highSignalSymptoms: const [
      'Your periods are very irregular or widely spaced.',
      'You reported going 90 days or more without a period when not pregnant.',
      'You reported increased facial or body hair.',
      'You reported noticeable scalp-hair thinning or hair loss.',
    ],
    lowerSpecificitySymptoms: const [
      'Difficulty losing weight despite diet or physical activity changes',
      'Acne or recurring breakouts',
    ],
    contributingCategories: const [
      'Irregular or widely spaced menstrual cycles',
      'Increased facial or body hair',
      'Persistent acne',
      'Scalp-hair thinning',
      'Insulin resistance or blood sugar history',
      'Darkened skin folds',
    ],
    nextStepText:
        'Consider discussing your results and symptoms with a qualified healthcare professional. They can determine whether further evaluation is appropriate.',
    primaryCta: 'Discuss With a Doctor',
    secondaryCta: null,
    hasSpecialCaseNotice: true,
    specialCaseNoticeText:
        'Please consider speaking with a healthcare professional regarding persistent 90+ day absence of periods, very heavy bleeding, or marked recent symptom changes.',
    answers: const {},
    completedAt: DateTime(2026, 8, 12, 10, 30),
  );
}

EndometriosisAssessmentResult _endoResult(EndometriosisResultLevel level,
    {int score = 24}) {
  return EndometriosisAssessmentResult(
    rawScore: score,
    resultLevel: level,
    resultTitle: 'Higher indication of endometriosis-associated features',
    description:
        'Your responses include several symptoms or symptom patterns that can be associated with endometriosis.',
    additionalText:
        'This does not mean that you have endometriosis. Similar symptoms can have other causes, and a qualified healthcare professional is needed to evaluate them.',
    nextStepText:
        'Consider discussing these symptoms with a gynecologist or another qualified healthcare professional.',
    painCluster: true,
    deepPelvicPainCluster: true,
    bowelCluster: true,
    urinaryCluster: true,
    fertilityClinicalCluster: true,
    contributingSymptoms: const [
      'Severe menstrual pain',
      'Period pain affecting daily activities',
      'Pelvic pain outside your period',
      'Deep pelvic pain during or after sex',
      'Pain with bowel movements',
      'Difficulty becoming pregnant',
    ],
    highSignalSymptoms: const [
      'Severe or disabling period pain',
      'Pain that interferes with daily activities',
      'Pelvic pain outside periods',
      'Deep pelvic pain during sex',
      'Blood in stool around periods',
      'Blood in urine around periods',
      'Difficulty becoming pregnant',
    ],
    hasMedicalAttentionFlags: true,
    medicalAttentionNotice:
        'Some of the symptoms you reported may need medical evaluation. Consider contacting a healthcare professional, particularly if symptoms are severe, new, or worsening.',
    primaryCta: 'Discuss With a Doctor',
    secondaryCta: 'Track My Symptoms',
    answers: const {},
    completedAt: DateTime(2026, 8, 12, 10, 30),
  );
}

UterineFibroidAssessmentResult _fibroidsResult(
    UterineFibroidResultLevel level,
    {int score = 24}) {
  return UterineFibroidAssessmentResult(
    rawScore: score,
    resultLevel: level,
    resultTitle: 'Higher indication of uterine-fibroid-associated features',
    description:
        'Your responses include several symptoms or symptom patterns that can be associated with uterine fibroids.',
    additionalText:
        'This does not mean that you have uterine fibroids. Similar symptoms can have other causes, and a qualified healthcare professional is needed to evaluate them.',
    nextStepText:
        'Consider discussing these symptoms with a gynecologist or another qualified healthcare professional.',
    heavyBleedingCluster: true,
    pelvicPressureCluster: true,
    bladderBowelCluster: true,
    anemiaAssociatedCluster: true,
    fertilityClinicalCluster: true,
    contributingSymptoms: const [
      'Heavy or very heavy menstrual bleeding',
      'Pelvic pressure, heaviness, or fullness',
      'Frequent urination',
      'Frequent fatigue or low energy',
      'Difficulty becoming pregnant',
    ],
    highSignalSymptoms: const [
      'Heavy or very heavy menstrual bleeding',
      'Bleeding that soaks through products or clothes',
      'Pelvic pressure or fullness',
    ],
    medicalAttentionFlags: const [
      UterineFibroidAttentionFlag(
        id: 'heavyBleeding',
        message: 'Heavy bleeding reported.',
      ),
      UterineFibroidAttentionFlag(
        id: 'anemia',
        message: 'Anemia-related symptoms reported.',
      ),
    ],
    primaryCta: 'Discuss With a Doctor',
    secondaryCta: 'Track My Symptoms',
    answers: const {},
    completedAt: DateTime(2026, 8, 12, 10, 30),
  );
}

Future<void> _pumpResultScreen(
  WidgetTester tester,
  Widget screen, {
  double width = 360,
  double height = 640,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final errors = <FlutterErrorDetails>[];
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    errors.add(details);
    oldOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = oldOnError);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();

  expect(errors, isEmpty, reason: 'Screen must not overflow at ${width}x$height');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Saving screening results', () {
    test('PCOS completion saves a completed result with outcome details',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pcosAssessmentProvider.notifier);
      for (int i = 0; i < 23; i++) {
        notifier.selectOption(0);
        notifier.nextQuestion();
      }

      final repo = container.read(screeningResultsRepositoryProvider);
      final saved = repo.latestResult(ScreeningAssessmentType.pcos);

      expect(saved, isNotNull);
      expect(saved!.assessmentType, ScreeningAssessmentType.pcos);
      expect(saved.isCompleted, isTrue);
      expect(saved.categoryTitle, isNotEmpty);
      expect(saved.levelLabel, isNotEmpty);
      expect(saved.rawScore, 0);
      expect(saved.completedAt.isAfter(DateTime(2026)), isTrue);
    });

    test('Endometriosis completion saves a completed result', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(endometriosisAssessmentProvider.notifier);
      for (int i = 0; i < 24; i++) {
        notifier.selectOption(0);
        notifier.nextQuestion();
      }

      final repo = container.read(screeningResultsRepositoryProvider);
      final saved =
          repo.latestResult(ScreeningAssessmentType.endometriosis);

      expect(saved, isNotNull);
      expect(saved!.assessmentType, ScreeningAssessmentType.endometriosis);
      expect(saved.isCompleted, isTrue);
      expect(saved.completedAt.isAfter(DateTime(2026)), isTrue);
    });

    test('Uterine Fibroids completion saves a completed result', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(fibroidsAssessmentProvider.notifier);
      for (int i = 0; i < 24; i++) {
        notifier.selectOption(0);
        notifier.nextQuestion();
      }

      final repo = container.read(screeningResultsRepositoryProvider);
      final saved =
          repo.latestResult(ScreeningAssessmentType.uterineFibroids);

      expect(saved, isNotNull);
      expect(saved!.assessmentType, ScreeningAssessmentType.uterineFibroids);
      expect(saved.isCompleted, isTrue);
      expect(saved.completedAt.isAfter(DateTime(2026)), isTrue);
    });
  });

  group('Updating saved results on retake', () {
    test('Retaking PCOS replaces the previous result (single entry)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pcosAssessmentProvider.notifier);

      // Run 1: option 0 for every question -> Low indication, score 0
      for (int i = 0; i < 23; i++) {
        notifier.selectOption(0);
        notifier.nextQuestion();
      }
      final repo = container.read(screeningResultsRepositoryProvider);
      final first = repo.latestResult(ScreeningAssessmentType.pcos)!;
      expect(first.levelLabel, 'Low indication');
      expect(first.rawScore, 0);

      // Run 2 (retake): highest-scoring option per question
      notifier.reset();
      final highOptions = _maxScoreOptions();
      for (int i = 0; i < 23; i++) {
        notifier.selectOption(highOptions[i]);
        notifier.nextQuestion();
      }

      expect(repo.allResults.length, 1,
          reason: 'Only one latest result per assessment type');
      final latest = repo.latestResult(ScreeningAssessmentType.pcos)!;
      expect(latest.isCompleted, isTrue);
      expect(latest.levelLabel, 'Higher indication');
      expect(latest.rawScore, greaterThan(12));
      expect(latest.completedAt.isAfter(first.completedAt), isTrue,
          reason: 'Latest completed result is treated as current');
    });
  });

  group('Separate results per assessment type', () {
    test('Three assessments keep independent latest results', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pcos = container.read(pcosAssessmentProvider.notifier);
      for (int i = 0; i < 23; i++) {
        pcos.selectOption(0);
        pcos.nextQuestion();
      }

      final endo =
          container.read(endometriosisAssessmentProvider.notifier);
      for (int i = 0; i < 24; i++) {
        endo.selectOption(0);
        endo.nextQuestion();
      }

      final fibroids = container.read(fibroidsAssessmentProvider.notifier);
      for (int i = 0; i < 24; i++) {
        fibroids.selectOption(0);
        fibroids.nextQuestion();
      }

      final repo = container.read(screeningResultsRepositoryProvider);
      final all = repo.allResults;
      expect(all.length, 3);
      expect(all[ScreeningAssessmentType.pcos], isNotNull);
      expect(all[ScreeningAssessmentType.endometriosis], isNotNull);
      expect(all[ScreeningAssessmentType.uterineFibroids], isNotNull);
    });

    test('Retaking only Endometriosis does not touch the other results', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pcos = container.read(pcosAssessmentProvider.notifier);
      for (int i = 0; i < 23; i++) {
        pcos.selectOption(0);
        pcos.nextQuestion();
      }

      final endo =
          container.read(endometriosisAssessmentProvider.notifier);
      for (int i = 0; i < 24; i++) {
        endo.selectOption(0);
        endo.nextQuestion();
      }

      final repo = container.read(screeningResultsRepositoryProvider);
      final pcosFirst = repo.latestResult(ScreeningAssessmentType.pcos);
      final endoFirst =
          repo.latestResult(ScreeningAssessmentType.endometriosis);

      // Retake only endometriosis
      endo.reset();
      for (int i = 0; i < 24; i++) {
        endo.selectOption(0);
        endo.nextQuestion();
      }

      expect(repo.allResults.length, 2);
      expect(repo.latestResult(ScreeningAssessmentType.pcos), pcosFirst,
          reason: 'PCOS result must stay untouched');
      expect(repo.latestResult(ScreeningAssessmentType.endometriosis),
          isNot(same(endoFirst)),
          reason: 'Endometriosis result should be replaced');
    });
  });

  group('Result screen layout', () {
    const sizes = <(double, double)>[(360, 640), (320, 568)];

    for (final (width, height) in sizes) {
      testWidgets('PCOS result screen has no overflow at ${width}x$height',
          (tester) async {
        for (final level in PcosResultLevel.values) {
          await _pumpResultScreen(
            tester,
            PcosAssessmentResultScreen(result: _pcosResult(level)),
            width: width,
            height: height,
          );
        }
      });

      testWidgets(
          'Endometriosis result screen has no overflow at ${width}x$height',
          (tester) async {
        for (final level in EndometriosisResultLevel.values) {
          await _pumpResultScreen(
            tester,
            EndometriosisAssessmentResultScreen(result: _endoResult(level)),
            width: width,
            height: height,
          );
        }
      });

      testWidgets(
          'Uterine Fibroids result screen has no overflow at ${width}x$height',
          (tester) async {
        for (final level in UterineFibroidResultLevel.values) {
          await _pumpResultScreen(
            tester,
            FibroidsAssessmentResultScreen(result: _fibroidsResult(level)),
            width: width,
            height: height,
          );
        }
      });
    }
  });

  group('Discuss With a Doctor navigation', () {
    testWidgets('PCOS result opens the existing All Doctors screen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorsProvider.overrideWith((ref) => Stream.value(<Doctor>[])),
          ],
          child: MaterialApp(
            home: PcosAssessmentResultScreen(
              result: _dummyPcosForNav(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Discuss With a Doctor'));
      await tester.tap(find.text('Discuss With a Doctor'));
      await tester.pumpAndSettle();

      expect(find.byType(AllDoctorsScreen), findsOneWidget);
      expect(find.text('All Doctors'), findsOneWidget);
    });

    testWidgets('Endometriosis result opens the existing All Doctors screen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorsProvider.overrideWith((ref) => Stream.value(<Doctor>[])),
          ],
          child: MaterialApp(
            home: EndometriosisAssessmentResultScreen(
              result: _dummyEndoForNav(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Discuss With a Doctor'));
      await tester.tap(find.text('Discuss With a Doctor'));
      await tester.pumpAndSettle();

      expect(find.byType(AllDoctorsScreen), findsOneWidget);
      expect(find.text('All Doctors'), findsOneWidget);
    });

    testWidgets('Fibroids result opens the existing All Doctors screen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorsProvider.overrideWith((ref) => Stream.value(<Doctor>[])),
          ],
          child: MaterialApp(
            home: FibroidsAssessmentResultScreen(
              result: _dummyFibroidsForNav(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Discuss With a Doctor'));
      await tester.tap(find.text('Discuss With a Doctor'));
      await tester.pumpAndSettle();

      expect(find.byType(AllDoctorsScreen), findsOneWidget);
      expect(find.text('All Doctors'), findsOneWidget);
    });
  });

  group('End-to-end quiz flow', () {
    testWidgets('Completing the PCOS quiz shows result and saves it',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PcosAssessmentScreen()),
        ),
      );

      for (int q = 0; q < 22; q++) {
        await tester.tap(find.byType(DiagnosisOptionCard).first);
        await tester.pump();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(DiagnosisOptionCard).first);
      await tester.pump();
      await tester.tap(find.text('View Screening Summary'));
      await tester.pumpAndSettle();

      expect(find.byType(PcosAssessmentResultScreen), findsOneWidget);

      final repo = container.read(screeningResultsRepositoryProvider);
      final saved = repo.latestResult(ScreeningAssessmentType.pcos);
      expect(saved, isNotNull);
      expect(saved!.isCompleted, isTrue);
      expect(saved.rawScore, 0);
      expect(saved.levelLabel, 'Low indication');
    });
  });
}

PcosAssessmentResult _dummyPcosForNav() => _pcosResult(PcosResultLevel.higher);
EndometriosisAssessmentResult _dummyEndoForNav() =>
    _endoResult(EndometriosisResultLevel.higher);
UterineFibroidAssessmentResult _dummyFibroidsForNav() =>
    _fibroidsResult(UterineFibroidResultLevel.higher);


