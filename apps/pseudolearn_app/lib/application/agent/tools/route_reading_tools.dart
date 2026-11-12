import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/exercises/exercise_reference.dart';
import '../../../domain/model/exercises/user_exercise_projection.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/reference/reference_edition.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../../domain/model/route/route_exercise.dart';
import '../../../domain/model/route/route_exercise_projection.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../../domain/model/route/route_lesson.dart';
import '../../../domain/model/route/route_toc.dart';
import '../../../domain/ports/local_progress_store.dart';
import '../../../domain/ports/route_repository.dart';
import '../../../domain/ports/user_exercise_repository.dart';
import 'agent_tool.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class RouteProgressTool extends DirectTool {
  final RouteRepository _route;
  final LocalProgressStore _progress;
  final ReferenceEdition Function() _edition;

  const RouteProgressTool(this._route, this._progress, this._edition);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'get_route_progress',
    description: 'Summarises the learning route: lessons, whether each was visited and how many exercises are solved.',
    parameters: objectSchema(const {}),
    risk: ToolRisk.read,
    stepLabel: 'agentStepProgress',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final toc = await _route.loadToc(_edition());
    if (toc is! ContentLoaded<RouteToc>) return ToolExecution.failed('route_unavailable');
    final progress = await _progress.readProgress();
    return ToolExecution.done({
      'lessons': [
        for (final part in toc.value.parts)
          for (final lesson in part.lessons)
            {
              'id': lesson.id,
              'title': plainTextOf(lesson.title),
              'visited': progress.visitedModuleIds.contains(routeLessonProgressId(lesson.id)),
              'exercises': lesson.exercises.length,
              'solved': [
                for (final exercise in lesson.exercises)
                  if (progress.isExerciseCompleted(routeExerciseProgressId(exercise.id))) exercise.id,
              ],
            },
      ],
    });
  }
}

final class GetLessonTool extends DirectTool {
  final RouteRepository _route;
  final ReferenceEdition Function() _edition;

  const GetLessonTool(this._route, this._edition);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'get_lesson',
    description: 'Returns the text of a route lesson.',
    parameters: objectSchema({'lesson_id': stringProperty('Lesson id.')}, required: const ['lesson_id']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepLesson',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('lesson_id');
    if (id == null) return ToolExecution.failed('invalid_arguments');
    final lesson = await _route.loadLesson(_edition(), id);
    if (lesson is! ContentLoaded<RouteLesson>) return ToolExecution.failed('not_found');
    return ToolExecution.done({
      'id': lesson.value.id,
      'title': plainTextOf(lesson.value.title),
      'text': plainTextOfBlocks(lesson.value.blocks),
    });
  }
}

final class GetExerciseTool extends DirectTool {
  final RouteRepository _route;
  final UserExerciseRepository _userExercises;
  final ReferenceEdition Function() _edition;

  const GetExerciseTool(this._route, this._userExercises, this._edition);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'get_exercise',
    description:
        'Returns an exercise statement and its visible cases. Ids are route:<id> or user:<id>. '
        'Hidden cases and the reference solution are never returned.',
    parameters: objectSchema({'exercise_id': stringProperty('Exercise reference.')}, required: const ['exercise_id']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepExercise',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('exercise_id');
    if (id == null) return ToolExecution.failed('invalid_arguments');
    final exercise = await _resolve(ExerciseReference.parse(id));
    if (exercise == null) return ToolExecution.failed('not_found');
    return ToolExecution.done({
      'id': exercise.reference.encoded,
      'title': exercise.title,
      'kind': exercise.kind.name,
      'statement': exercise.statement,
      'hint_count': exercise.hints.length,
      'visible_cases': [
        for (final item in exercise.visibleCases)
          {'inputs': item.inputs, 'expected': item.expectedOutputs},
      ],
      'hidden_case_count': exercise.hiddenCases.length,
    });
  }

  Future<Exercise?> _resolve(ExerciseReference reference) async {
    if (reference.origin == ExerciseOrigin.user) {
      final exercise = await _userExercises.loadExercise(reference.id);
      return exercise == null ? null : exerciseOfUser(exercise);
    }
    final loaded = await _route.loadExercise(_edition(), reference.id);
    return loaded is ContentLoaded<RouteExercise> ? editorExerciseOf(loaded.value) : null;
  }
}
