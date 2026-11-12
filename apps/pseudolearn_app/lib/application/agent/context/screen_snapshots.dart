import '../../../domain/model/agent/screen_context_snapshot.dart';
import '../../../domain/model/analysis/app_diagnostic.dart';
import '../../../domain/model/execution/output_line.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../../domain/model/route/route_exercise_projection.dart';
import '../../editor/editor_state.dart';
import '../../execution/execution_state.dart';
import '../../reference/reference_section_state.dart';
import '../../route/route_lesson_state.dart';
import '../../route/session/exercise_session_state.dart';

const int _outputLimit = 600;

ScreenContextSnapshot editorSnapshot(
  EditorState editor,
  ExecutionState execution,
  ExerciseSessionState exercise,
) {
  final document = editor.document;
  final diagnostics = [
    for (final diagnostic in editor.report.diagnostics)
      if (diagnostic.severity == AppSeverity.error || diagnostic.severity == AppSeverity.warning)
        'L${diagnostic.primaryRange.startLine}: ${diagnostic.message}',
  ];
  return ScreenContextSnapshot(
    screen: 'editor',
    route: '/biblioteca/documento/${document?.id ?? ''}',
    fields: {
      'document_id': document?.id ?? '',
      'title': document?.title ?? '',
      'profile': document?.profileId.name ?? '',
      'unsaved_changes': '${editor.isDirty}',
      'diagnostics': diagnostics.take(8).join('\n'),
      'arguments': (document?.executionArguments ?? const []).join(' '),
      'last_run_status': execution.status.name,
      'last_output': _truncated(_output(execution)),
      'last_error': execution.haltMessage ?? '',
      ..._exerciseFields(document?.exerciseId, exercise),
    },
  );
}

ScreenContextSnapshot lessonSnapshot(RouteLessonState state) {
  final lesson = state.lesson;
  return ScreenContextSnapshot(
    screen: 'lesson',
    route: '/conocimiento/ruta/${lesson?.id ?? ''}',
    fields: {'lesson_id': lesson?.id ?? '', 'title': lesson == null ? '' : plainTextOf(lesson.title)},
  );
}

String lessonText(RouteLessonState state) {
  final lesson = state.lesson;
  return lesson == null ? '' : plainTextOfBlocks(lesson.blocks);
}

ScreenContextSnapshot specificationSnapshot(String sectionId, ReferenceSectionState state) {
  final section = state.sections[sectionId];
  return ScreenContextSnapshot(
    screen: 'specification',
    route: '/conocimiento/especificacion/$sectionId',
    fields: {
      'section_id': sectionId,
      'title': section == null ? '' : plainTextOf(section.title),
      'summary': section == null ? '' : plainTextOf(section.phrase),
    },
  );
}

String specificationText(String sectionId, ReferenceSectionState state) {
  final section = state.sections[sectionId];
  if (section == null) return '';
  return '${plainTextOf(section.title)}\n\n${plainTextOf(section.phrase)}';
}

ScreenContextSnapshot staticSnapshot(String screen, String route) =>
    ScreenContextSnapshot(screen: screen, route: route);

Map<String, String> _exerciseFields(String? exerciseId, ExerciseSessionState session) {
  final exercise = session.exercise;
  if (exerciseId == null || exercise == null) return const {};
  return {
    'exercise': exercise.reference.encoded,
    'exercise_title': exercise.title,
    'exercise_statement': _truncated(exercise.statement),
    'exercise_failed_attempts': '${session.failedAttempts}',
    'exercise_solved': '${session.isCompleted}',
    'exercise_last_verdict': session.lastResult?.outcome.name ?? '',
    'exercise_hints_available': '${exercise.hints.length}',
  };
}

String _output(ExecutionState execution) => [
  for (final line in execution.outputLines)
    if (line.kind != OutputLineKind.userInputEcho) line.text,
].join('\n');

String _truncated(String text) =>
    text.length > _outputLimit ? '${text.substring(0, _outputLimit)}…' : text;
