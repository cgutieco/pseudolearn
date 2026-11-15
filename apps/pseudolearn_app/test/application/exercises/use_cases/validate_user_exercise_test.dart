import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/validate_user_exercise.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_publication.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import '../../../fakes/native_test_engine.dart';
import '../../../fakes/user_exercise_fixtures.dart';

void main() {
  final validate = ValidateUserExercise(
    analyzer: nativeTestEngine.analyzer,
    checker: nativeTestEngine.exerciseChecker,
  );

  test('a correct reference solution publishes', () {
    expect(validate(sumDraft()).isPublishable, isTrue);
  });

  test('an empty narrative is allowed', () {
    expect(validate(sumDraft(narrative: '')).isPublishable, isTrue);
  });

  test('empty title, statement, cases and solution are rejected in that order', () {
    expect(validate(sumDraft(title: ' ')).problem, ExercisePublicationProblem.emptyTitle);
    expect(validate(sumDraft(statement: '')).problem, ExercisePublicationProblem.emptyStatement);
    expect(
      validate(sumDraft(visible: const [], hidden: const [])).problem,
      ExercisePublicationProblem.noVisibleCase,
    );
    expect(validate(sumDraft(solution: '  ')).problem, ExercisePublicationProblem.emptyReferenceSolution);
  });

  test('a solution that does not parse is rejected before running', () {
    final publication = validate(sumDraft(solution: 'Algoritmo X\n  Si x >\nFinAlgoritmo\n'));
    expect(publication.problem, ExercisePublicationProblem.referenceDoesNotParse);
  });

  test('a failing hidden case names the case', () {
    const wrong = ExerciseCase(
      inputs: ['1', '1'],
      expectedOutputs: ['3'],
      expectedValueKind: ExpectedValueKind.numeric,
    );
    final publication = validate(sumDraft(hidden: const [wrong]));
    expect(publication.problem, ExercisePublicationProblem.referenceFailsCase);
    expect(publication.failingCaseIsHidden, isTrue);
    expect(publication.failingCaseIndex, isNotNull);
  });

  test('a case that needs more inputs than given fails', () {
    const short = ExerciseCase(
      inputs: ['1'],
      expectedOutputs: ['1'],
      expectedValueKind: ExpectedValueKind.numeric,
    );
    expect(
      validate(sumDraft(visible: const [short])).problem,
      ExercisePublicationProblem.referenceFailsCase,
    );
  });

  test('a satisfied omission passes and an unmet construct is reported', () {
    expect(validate(sumDraft(assertions: const [loopForbidden])).isPublishable, isTrue);
    final missing = validate(sumDraft(assertions: const [loopRequired]));
    expect(missing.problem, ExercisePublicationProblem.referenceMissesAssertion);
    expect(missing.unmetAssertions, const [loopRequired]);
  });
}
