import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/agent/context/screen_snapshots.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/reference/reference_section_cubit.dart';
import '../../../application/reference/reference_section_state.dart';
import '../../../application/route/route_lesson_cubit.dart';
import '../../../application/route/route_lesson_state.dart';
import '../../../application/route/session/exercise_session_cubit.dart';
import '../../../application/route/session/exercise_session_state.dart';
import 'screen_context_publisher.dart';

final class EditorContextPublisher extends StatelessWidget {
  final Widget child;

  const EditorContextPublisher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, editor) => BlocBuilder<ExecutionCubit, ExecutionState>(
        builder: (context, execution) => BlocBuilder<ExerciseSessionCubit, ExerciseSessionState>(
          builder: (context, session) => ScreenContextPublisher(
            snapshot: editorSnapshot(editor, execution, session),
            fullText: () => editor.sourceCode,
            child: child,
          ),
        ),
      ),
    );
  }
}

final class LessonContextPublisher extends StatelessWidget {
  final Widget child;

  const LessonContextPublisher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteLessonCubit, RouteLessonState>(
      builder: (context, state) => ScreenContextPublisher(
        snapshot: lessonSnapshot(state),
        fullText: () => lessonText(state),
        child: child,
      ),
    );
  }
}

final class SpecificationContextPublisher extends StatelessWidget {
  final String sectionId;
  final Widget child;

  const SpecificationContextPublisher({super.key, required this.sectionId, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferenceSectionCubit, ReferenceSectionState>(
      builder: (context, state) => ScreenContextPublisher(
        snapshot: specificationSnapshot(sectionId, state),
        fullText: () => specificationText(sectionId, state),
        child: child,
      ),
    );
  }
}

final class StaticContextPublisher extends StatelessWidget {
  final String screen;
  final String route;
  final Widget child;

  const StaticContextPublisher({super.key, required this.screen, required this.route, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScreenContextPublisher(snapshot: staticSnapshot(screen, route), child: child);
  }
}
