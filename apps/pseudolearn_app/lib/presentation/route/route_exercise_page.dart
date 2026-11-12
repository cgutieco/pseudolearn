import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/route/route_exercise_cubit.dart';
import '../../application/route/route_exercise_state.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_exercise_projection.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../l10n/generated/app_localizations.dart';
import '../reference/reference_edition_resolver.dart';
import '../theme/app_theme.dart';
import 'exercise_creation_launcher.dart';
import 'lesson_scope.dart';
import 'route_exercise_body.dart';
import 'route_navigation.dart';

final class RouteExercisePage extends StatefulWidget {
  final String lessonId;
  final String exerciseId;

  const RouteExercisePage({
    super.key,
    required this.lessonId,
    required this.exerciseId,
  });

  @override
  State<RouteExercisePage> createState() => _RouteExercisePageState();
}

final class _RouteExercisePageState extends State<RouteExercisePage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => context.read<RouteExerciseCubit>().load(
    currentReferenceEdition(context),
    widget.exerciseId,
  );

  void _submit(RouteAnswer answer) {
    final edition = currentReferenceEdition(context);
    context.read<RouteExerciseCubit>().submit(
      answer: answer,
      profileId: edition.profile,
      languageId: edition.language,
    );
  }

  void _openEditor() {
    final exercise = context.read<RouteExerciseCubit>().state.exercise;
    if (exercise == null) return;
    launchExerciseCreationDialog(
      context: context,
      exercise: editorExerciseOf(exercise),
      onClosed: _load,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      appBar: AppBar(backgroundColor: theme.colors.surfaces.canvas),
      body: BlocBuilder<RouteExerciseCubit, RouteExerciseState>(
        builder: (context, state) => RouteExerciseContent(
          state: state,
          scope: LessonScope(
            edition: currentReferenceEdition(context),
            onOpenLink: (target) => openRouteTarget(context, target),
            onOpenExercise: (id) => openRouteExercise(context, widget.lessonId, id),
          ),
          actions: RouteExerciseActions(
            onSubmit: _submit,
            onOpenEditor: _openEditor,
            onHint: context.read<RouteExerciseCubit>().showNextHint,
            onReveal: context.read<RouteExerciseCubit>().revealAnswer,
          ),
        ),
      ),
    );
  }
}

final class RouteExerciseContent extends StatelessWidget {
  final RouteExerciseState state;
  final LessonScope scope;
  final RouteExerciseActions actions;

  const RouteExerciseContent({
    super.key,
    required this.state,
    required this.scope,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = state.exercise;
    if (exercise != null) {
      return RouteExerciseBody(state: state, exercise: exercise, scope: scope, actions: actions);
    }
    if (state.status == RouteExerciseStatus.notFound) {
      final l10n = AppLocalizations.of(context)!;
      return AppEmptyState(
        icon: Icons.quiz_outlined,
        title: l10n.routeExerciseNotFoundTitle,
        description: l10n.knowledgeErrorDescription,
      );
    }
    return const AppSkeletonList(itemExtent: 96);
  }
}
