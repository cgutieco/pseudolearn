import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_exercise_cubit.dart';
import 'package:pseudolearn_app/application/route/route_exercise_state.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_program.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/route_exercise/prediction_evaluator.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';
import '../../fakes/route_fixtures.dart';

const ReferenceEdition _edition = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

RouteExercise _predict() {
  final base = sampleExercise('p', const PredictEvaluation('5'), kind: RouteExerciseKind.predict);
  return RouteExercise(
    id: base.id,
    lessonId: base.lessonId,
    kind: base.kind,
    level: base.level,
    required: base.required,
    title: base.title,
    statement: base.statement,
    restriction: base.restriction,
    hints: base.hints,
    variant: base.variant,
    explanation: base.explanation,
    program: const ReferenceProgram(
      id: 'p',
      title: '',
      source: 'Escribir 5;',
      lines: [],
      executed: true,
      output: '5\n',
      termination: 'completed',
    ),
    starterCode: null,
    evaluation: base.evaluation,
  );
}

RouteExerciseCubit _cubit(InMemoryLocalProgressStore store) => RouteExerciseCubit(
  repository: FakeRouteRepository(exercises: {'p': _predict()}),
  progressStore: store,
  evaluators: {RouteExerciseKind.predict: const PredictionEvaluator()},
);

void main() {
  test('loads the exercise and hides the output of a prediction', () async {
    final cubit = _cubit(InMemoryLocalProgressStore());
    await cubit.load(_edition, 'p');

    expect(cubit.state.status, RouteExerciseStatus.ready);
    expect(cubit.state.shownProgram?.executed, isFalse);
    expect(cubit.state.shownProgram?.output, isEmpty);
  });

  test('a correct answer is solved, recorded and opens the program run', () async {
    final store = InMemoryLocalProgressStore();
    final cubit = _cubit(store);
    await cubit.load(_edition, 'p');

    await cubit.submit(
      answer: const TextRouteAnswer('5'),
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

    expect(cubit.state.verdict?.solved, isTrue);
    expect(cubit.state.completed, isTrue);
    expect(cubit.state.shownProgram?.output, '5\n');
    expect(await store.isExerciseCompleted(routeExerciseProgressId('p')), isTrue);
  });

  test('a wrong answer keeps the exercise open and unrecorded', () async {
    final store = InMemoryLocalProgressStore();
    final cubit = _cubit(store);
    await cubit.load(_edition, 'p');

    await cubit.submit(
      answer: const TextRouteAnswer('6'),
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

    expect(cubit.state.verdict?.solved, isFalse);
    expect(cubit.state.completed, isFalse);
    cubit.clearVerdict();
    expect(cubit.state.verdict, isNull);
  });

  test('hints are revealed one by one and the answer on request', () async {
    final cubit = _cubit(InMemoryLocalProgressStore());
    await cubit.load(_edition, 'p');

    cubit.showNextHint();
    cubit.showNextHint();
    cubit.showNextHint();
    expect(cubit.state.hintsShown, 2);
    expect(cubit.state.canShowHint, isFalse);

    cubit.revealAnswer();
    expect(cubit.state.isOpen, isTrue);
  });

  test('an unknown exercise or kind without evaluator does nothing harmful', () async {
    final cubit = RouteExerciseCubit(
      repository: FakeRouteRepository(exercises: {'p': _predict()}),
      progressStore: InMemoryLocalProgressStore(),
      evaluators: const {},
    );
    await cubit.load(_edition, 'nada');
    expect(cubit.state.status, RouteExerciseStatus.notFound);

    await cubit.load(_edition, 'p');
    await cubit.submit(
      answer: const TextRouteAnswer('5'),
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    expect(cubit.state.verdict, isNull);
  });
}
