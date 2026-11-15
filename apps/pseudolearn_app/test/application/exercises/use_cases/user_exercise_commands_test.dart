import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/create_user_exercise.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/delete_user_exercise.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/update_user_exercise.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/validate_user_exercise.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_publication.dart';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise_command_result.dart';
import '../../../fakes/fake_clock.dart';
import '../../../fakes/fake_identifier_generator.dart';
import '../../../fakes/in_memory_user_exercise_repository.dart';
import '../../../fakes/native_test_engine.dart';
import '../../../fakes/user_exercise_fixtures.dart';

void main() {
  final validate = ValidateUserExercise(
    analyzer: nativeTestEngine.analyzer,
    checker: nativeTestEngine.exerciseChecker,
  );
  final clock = FakeClock(DateTime.utc(2026, 11, 8, 12));
  late InMemoryUserExerciseRepository repository;

  setUp(() => repository = InMemoryUserExerciseRepository());

  CreateUserExercise create() => CreateUserExercise(
    repository: repository,
    validate: validate,
    identifiers: FakeIdentifierGenerator(['ux-new']),
    clock: clock,
  );

  test('create stores a valid exercise at revision one', () async {
    final result = await create()(sumDraft());
    expect((result as UserExerciseSaved).exercise.id, 'ux-new');
    expect(repository.exercises['ux-new']!.revision, 1);
  });

  test('create refuses an invalid draft without storing it', () async {
    final result = await create()(sumDraft(visible: const [], hidden: const []));
    expect(
      (result as UserExerciseInvalid).publication.problem,
      ExercisePublicationProblem.noVisibleCase,
    );
    expect(repository.exercises, isEmpty);
  });

  test('create reports storage failures as a value', () async {
    repository.failing = true;
    expect(await create()(sumDraft()), isA<UserExerciseStorageFailed>());
  });

  test('update revises an existing exercise and keeps its creation date', () async {
    repository.exercises['ux-1'] = sumExercise();
    final update = UpdateUserExercise(repository: repository, validate: validate, clock: clock);
    final result = await update(exerciseId: 'ux-1', draft: sumDraft(title: 'Suma'));
    final saved = (result as UserExerciseSaved).exercise;
    expect(saved.revision, 2);
    expect(saved.title, 'Suma');
    expect(saved.createdAt, sumExercise().createdAt);
    expect(saved.updatedAt, clock.now());
  });

  test('update of a missing exercise is reported', () async {
    final update = UpdateUserExercise(repository: repository, validate: validate, clock: clock);
    expect(await update(exerciseId: 'none', draft: sumDraft()), isA<UserExerciseMissing>());
  });

  test('delete removes and reports failures', () async {
    repository.exercises['ux-1'] = sumExercise();
    final delete = DeleteUserExercise(repository: repository);
    expect(await delete('ux-1'), isTrue);
    expect(repository.exercises, isEmpty);
    repository.failing = true;
    expect(await delete('ux-1'), isFalse);
  });
}
