import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_cubit.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_state.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_reference.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../../fakes/fake_exercise_checker.dart';
import '../../../fakes/fake_route_repository.dart';
import '../../../fakes/in_memory_local_progress_store.dart';
import '../../../fakes/in_memory_user_exercise_repository.dart';
import '../../../fakes/user_exercise_fixtures.dart';

void main() {
  const edition = ReferenceEdition(
    language: UiLanguageId.spanish,
    profile: SyntaxProfileId.classicSpanish,
  );
  late InMemoryUserExerciseRepository userExercises;
  late InMemoryLocalProgressStore progress;
  late FakeExerciseChecker checker;
  late ExerciseSessionCubit cubit;

  setUp(() {
    userExercises = InMemoryUserExerciseRepository()..exercises['ux-1'] = sumExercise();
    progress = InMemoryLocalProgressStore();
    checker = FakeExerciseChecker();
    cubit = ExerciseSessionCubit(
      repository: FakeRouteRepository(),
      checker: checker,
      progressStore: progress,
      userExercises: userExercises,
    );
  });

  tearDown(() => cubit.close());

  test('a user reference loads the user exercise', () async {
    await cubit.loadExercise(exerciseId: 'user:ux-1', edition: edition);
    expect(cubit.state.status, ExerciseSessionStatus.ready);
    expect(cubit.state.exercise!.origin, ExerciseOrigin.user);
  });

  test('a missing user exercise is not found', () async {
    await cubit.loadExercise(exerciseId: 'user:nope', edition: edition);
    expect(cubit.state.status, ExerciseSessionStatus.exerciseNotFound);
  });

  test('solving a user exercise records user progress', () async {
    checker.nextResult = const ExerciseCheckResult(
      outcome: ExerciseCheckOutcome.allCasesPassed,
      passedCases: 2,
      totalCases: 2,
    );
    await cubit.loadExercise(exerciseId: 'user:ux-1', edition: edition);
    await cubit.checkSolution(
      sourceCode: sumSolution,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    expect(await progress.isExerciseCompleted(userExerciseProgressId('ux-1')), isTrue);
  });
}
