import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/exercises/exercise_text_format.dart';
import '../../../domain/model/exercises/user_exercise_command_result.dart';
import '../../../domain/model/exercises/user_exercise_draft.dart';
import '../../../domain/model/knowledge/exercise_case.dart';
import '../../../domain/model/knowledge/expected_value_kind.dart';
import '../../exercises/use_cases/create_user_exercise.dart';
import '../../exercises/use_cases/delete_user_exercise.dart';
import '../../exercises/use_cases/update_user_exercise.dart';
import 'agent_tool.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final Map<String, Object?> _caseSchema = objectSchema({
  'inputs': stringListProperty('Values read in order.'),
  'expected': stringListProperty('Expected output lines.'),
}, required: const ['inputs', 'expected']);

Map<String, Object?> exerciseDraftSchema({bool withId = false}) => objectSchema({
  if (withId) 'exercise_id': stringProperty('Id of the user exercise, without the user: prefix.'),
  'title': stringProperty('Title.'),
  'narrative': stringProperty('Optional story in plain text.'),
  'statement': stringProperty('What the program must do.'),
  'restrictions': stringListProperty('Restrictions, one per entry.'),
  'hints': stringListProperty('Graded hints from vague to precise; never the solution.'),
  'visible_cases': objectListProperty('Cases shown to the person.', _caseSchema),
  'hidden_cases': objectListProperty('Cases kept hidden.', _caseSchema),
  'assertions': stringListProperty('Structural assertions such as "contiene: bucle-contado".'),
  'reference_solution': stringProperty('Program that passes every case.'),
  'starter_code': stringProperty('Optional starting code.'),
  'profile': stringProperty('Syntax profile.', values: profileNames),
}, required: [if (withId) 'exercise_id', 'title', 'statement', 'visible_cases', 'reference_solution', 'profile']);

UserExerciseDraft? exerciseDraftOf(ToolArguments arguments) {
  final title = arguments.text('title');
  final statement = arguments.text('statement');
  final solution = arguments.text('reference_solution');
  final profile = arguments.profile('profile');
  final assertions = parseAssertions((arguments.texts('assertions') ?? const []).join('\n'));
  if (title == null || statement == null || solution == null || profile == null || assertions == null) {
    return null;
  }
  return UserExerciseDraft(
    title: title,
    narrative: arguments.text('narrative') ?? '',
    statement: statement,
    restrictions: arguments.texts('restrictions') ?? const [],
    hints: arguments.texts('hints') ?? const [],
    visibleCases: _cases(arguments.values['visible_cases']),
    hiddenCases: _cases(arguments.values['hidden_cases']),
    assertions: assertions,
    referenceSolution: solution,
    starterCode: arguments.text('starter_code') ?? '',
    profileId: profile,
  );
}

List<ExerciseCase> _cases(Object? raw) {
  final cases = <ExerciseCase>[];
  for (final entry in raw is List<Object?> ? raw : const <Object?>[]) {
    if (entry is! Map<String, Object?>) continue;
    final values = ToolArguments(entry);
    final expected = values.texts('expected') ?? const [];
    cases.add(ExerciseCase(
      inputs: values.texts('inputs') ?? const [],
      expectedOutputs: expected,
      expectedValueKind: expected.every((value) => num.tryParse(value) != null)
          ? ExpectedValueKind.numeric
          : ExpectedValueKind.text,
    ));
  }
  return cases;
}

ToolExecution exerciseResult(UserExerciseCommandResult result) => switch (result) {
  UserExerciseSaved(:final exercise) => ToolExecution.done(
    {'exercise_id': exercise.reference.encoded, 'revision': exercise.revision},
    summary: exercise.title,
  ),
  UserExerciseInvalid(:final publication) => ToolExecution.failed(
    'not_publishable',
    detail: [
      publication.problem?.name ?? '',
      if (publication.failingCaseIndex != null)
        'case ${publication.failingCaseIndex! + 1}${publication.failingCaseIsHidden ? ' (hidden)' : ''}',
      for (final assertion in publication.unmetAssertions) assertion.requirement,
    ].join(' · '),
  ),
  UserExerciseMissing() => ToolExecution.failed('not_found'),
  UserExerciseStorageFailed() => ToolExecution.failed('storage_failed'),
};

final class CreateUserExerciseTool extends ConfirmedTool {
  final CreateUserExercise _create;

  const CreateUserExerciseTool(this._create);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'create_user_exercise',
    description:
        'Creates an exercise in "My exercises". It is published only if the reference solution '
        'passes every case; the person reviews a preview and confirms.',
    parameters: exerciseDraftSchema(),
    risk: ToolRisk.write,
    stepLabel: 'agentStepCreateExercise',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final draft = exerciseDraftOf(arguments);
    if (draft == null) return ToolExecution.failed('invalid_arguments');
    return exerciseResult(await _create(draft));
  }
}

final class UpdateUserExerciseTool extends ConfirmedTool {
  final UpdateUserExercise _update;

  const UpdateUserExerciseTool(this._update);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'update_user_exercise',
    description: 'Replaces a user exercise with a new validated version; the person confirms.',
    parameters: exerciseDraftSchema(withId: true),
    risk: ToolRisk.write,
    stepLabel: 'agentStepUpdateExercise',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('exercise_id');
    final draft = exerciseDraftOf(arguments);
    if (id == null || draft == null) return ToolExecution.failed('invalid_arguments');
    return exerciseResult(await _update(exerciseId: id.replaceFirst('user:', ''), draft: draft));
  }
}

final class DeleteUserExerciseTool extends ConfirmedTool {
  final DeleteUserExercise _delete;

  const DeleteUserExerciseTool(this._delete);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'delete_user_exercise',
    description: 'Deletes a user exercise; attempts are kept. The person always confirms first.',
    parameters: objectSchema({'exercise_id': stringProperty('User exercise id.')}, required: const ['exercise_id']),
    risk: ToolRisk.destructive,
    stepLabel: 'agentStepDeleteExercise',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('exercise_id');
    if (id == null) return ToolExecution.failed('invalid_arguments');
    final ok = await _delete(id.replaceFirst('user:', ''));
    return ok ? ToolExecution.done({'deleted': id}) : ToolExecution.failed('storage_failed');
  }
}
