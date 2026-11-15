import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/exercises/active_exercise.dart';
import '../../../domain/model/exercises/exercise_reference.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../../domain/ports/active_exercise_source.dart';
import '../../../domain/ports/assisted_progress_store.dart';
import 'agent_tool.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

const int attemptsBeforeSolution = 3;

String tutorProgressId(ActiveExercise exercise) =>
    exercise.reference.origin == ExerciseOrigin.user
    ? userExerciseProgressId(exercise.reference.id)
    : routeExerciseProgressId(exercise.reference.id);

final class GiveHintTool extends DirectTool {
  final ActiveExerciseSource _exercise;
  final AssistedProgressStore _assisted;

  const GiveHintTool(this._exercise, this._assisted);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'give_hint',
    description:
        'Tutor mode: returns the hint of the given level (1 is the vaguest) for the exercise open '
        'on screen. Give one level at a time and never more than asked.',
    parameters: objectSchema({'level': integerProperty('Hint level, starting at 1.')}, required: const ['level']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepHint',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final exercise = _exercise.activeExercise;
    if (exercise == null) return ToolExecution.failed('no_exercise_open');
    if (exercise.hints.isEmpty) return ToolExecution.failed('no_hints');
    final level = (arguments.integer('level') ?? 1).clamp(1, exercise.hints.length);
    await _assisted.markAssisted(tutorProgressId(exercise));
    return ToolExecution.done({
      'level': level,
      'levels': exercise.hints.length,
      'hint': exercise.hints[level - 1],
    }, summary: '$level/${exercise.hints.length}');
  }
}

final class RevealSolutionTool extends ConfirmedTool {
  final ActiveExerciseSource _exercise;
  final AssistedProgressStore _assisted;

  const RevealSolutionTool(this._exercise, this._assisted);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'reveal_solution',
    description:
        'Tutor mode: reveals the reference solution of the exercise on screen. Only after three '
        'failed attempts and when the person explicitly asks for the solution.',
    parameters: objectSchema({
      'explicit_request': {'type': 'boolean', 'description': 'True only if the person asked for the solution.'},
    }, required: const ['explicit_request']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepRevealSolution',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final exercise = _exercise.activeExercise;
    if (exercise == null) return ToolExecution.failed('no_exercise_open');
    if (arguments.flag('explicit_request') != true) return ToolExecution.failed('not_requested');
    if (exercise.failedAttempts < attemptsBeforeSolution && !exercise.solved) {
      return ToolExecution.failed('too_early', detail: '${exercise.failedAttempts}/$attemptsBeforeSolution');
    }
    final solution = exercise.solution;
    if (solution == null || solution.isEmpty) return ToolExecution.failed('no_solution');
    await _assisted.markAssisted(tutorProgressId(exercise));
    return ToolExecution.done({'solution': solution});
  }
}
