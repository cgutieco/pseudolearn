import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_cubit.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../../fakes/fake_exercise_checker.dart';
import '../../../fakes/fake_route_repository.dart';
import '../../../fakes/in_memory_local_progress_store.dart';
import '../../../fakes/route_fixtures.dart';
import '../../../fakes/in_memory_user_exercise_repository.dart';

void main() {
  group('ExerciseSessionCubit', () {
    late FakeRouteRepository repository;
    late FakeExerciseChecker checker;
    late InMemoryLocalProgressStore progressStore;
    late ExerciseSessionCubit cubit;

    const exercise1 = Exercise(
      id: 'con-b1-ej1',
      title: 'Ejercicio con-b1-ej1',
      statement: 'Enunciado',
      level: RouteLevel.seed,
      kind: RouteExerciseKind.solve,
      lessonId: 'inicio.primero',
      starterCode: 'Algoritmo X\nFinAlgoritmo\n',
      visibleCases: [
        ExerciseCase(
          inputs: ['2', '3'],
          expectedOutputs: ['5'],
          expectedValueKind: ExpectedValueKind.numeric,
        ),
      ],
      hiddenCases: [
        ExerciseCase(
          inputs: ['10', '20'],
          expectedOutputs: ['30'],
          expectedValueKind: ExpectedValueKind.numeric,
        ),
      ],
    );

    setUp(() {
      repository = FakeRouteRepository(
        exercises: {
          'con-b1-ej1': sampleExercise(
            'con-b1-ej1',
            CasesEvaluation(
              visibleCases: exercise1.visibleCases,
              hiddenCases: exercise1.hiddenCases,
              assertions: const [],
              reference: '',
            ),
          ),
        },
      );
      checker = FakeExerciseChecker();
      progressStore = InMemoryLocalProgressStore();
      cubit = ExerciseSessionCubit(
        repository: repository,
        checker: checker,
        progressStore: progressStore,
        userExercises: InMemoryUserExerciseRepository(),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status and null exercise', () {
      expect(cubit.state.status, ExerciseSessionStatus.initial);
      expect(cubit.state.exercise, isNull);
      expect(cubit.state.lastResult, isNull);
    });

    test('loadExercise by id sets ready status and loads exercise', () async {
      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      expect(cubit.state.status, ExerciseSessionStatus.ready);
      expect(cubit.state.exercise, exercise1);
      expect(cubit.state.isCompleted, isFalse);
    });

    test('checkSolution passing all cases marks completed in progressStore', () async {
      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      checker.nextResult = const ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.allCasesPassed,
        passedCases: 2,
        totalCases: 2,
      );

      await cubit.checkSolution(
        sourceCode: 'algoritmo Suma escribir 5 fin',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.status, ExerciseSessionStatus.success);
      expect(cubit.state.isSolved, isTrue);
      expect(cubit.state.isCompleted, isTrue);
      expect(await progressStore.isExerciseCompleted(routeExerciseProgressId('con-b1-ej1')), isTrue);
      expect(cubit.state.revealedHiddenFailure, isNull);
    });

    test('checkSolution failing hidden case reveals only the first hidden failure', () async {
      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      const hiddenFailure = ExerciseCaseFailure(
        caseIndex: 1,
        isHidden: true,
        inputs: ['10', '20'],
        expectedOutputs: ['30'],
        actualOutputs: ['0'],
      );

      checker.nextResult = const ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.caseFailed,
        passedCases: 1,
        totalCases: 2,
        firstFailure: hiddenFailure,
      );

      await cubit.checkSolution(
        sourceCode: 'algoritmo Falso fin',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.status, ExerciseSessionStatus.success);
      expect(cubit.state.isSolved, isFalse);
      expect(cubit.state.revealedHiddenFailure, hiddenFailure);
      expect(cubit.state.revealedHiddenFailure?.inputs, ['10', '20']);
      expect(cubit.state.revealedHiddenFailure?.expectedOutputs, ['30']);
    });

    test('checkSolution with parse failure and resetResult', () async {
      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      checker.nextResult = const ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.programDidNotParse,
        passedCases: 0,
        totalCases: 2,
      );

      await cubit.checkSolution(
        sourceCode: 'invalido % syntax',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.status, ExerciseSessionStatus.success);
      expect(cubit.state.lastResult?.outcome, ExerciseCheckOutcome.programDidNotParse);
      expect(cubit.state.isSolved, isFalse);

      cubit.resetResult();
      expect(cubit.state.lastResult, isNull);
      expect(cubit.state.revealedHiddenFailure, isNull);
    });

    test('loading the exercise already held leaves a finished check untouched', () async {
      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );
      checker.nextResult = const ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.allCasesPassed,
        passedCases: 2,
        totalCases: 2,
      );
      await cubit.checkSolution(
        sourceCode: 'algoritmo Suma escribir 5 fin',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      expect(cubit.state.status, ExerciseSessionStatus.success);
      expect(cubit.state.isSolved, isTrue);
    });

    test('loading the same exercise in another language does reload it', () async {
      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );
      final statuses = <ExerciseSessionStatus>[];
      final subscription = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.loadExercise(
        exerciseId: 'con-b1-ej1',
        edition: const ReferenceEdition(language: UiLanguageId.english, profile: SyntaxProfileId.classicSpanish),
      );
      await subscription.cancel();

      expect(statuses, contains(ExerciseSessionStatus.loading));
    });

    test('a failed load does not block retrying the same identifier', () async {
      await cubit.loadExercise(
        exerciseId: 'unknown-ex',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );
      expect(cubit.state.status, ExerciseSessionStatus.exerciseNotFound);

      await cubit.loadExercise(
        exerciseId: 'unknown-ex',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      expect(cubit.state.status, ExerciseSessionStatus.exerciseNotFound);
    });

    test('loadExercise with non-existent id emits exerciseNotFound', () async {
      await cubit.loadExercise(
        exerciseId: 'unknown-ex',
        edition: const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
      );

      expect(cubit.state.status, ExerciseSessionStatus.exerciseNotFound);
      expect(cubit.state.exercise, isNull);
    });
  });
}
