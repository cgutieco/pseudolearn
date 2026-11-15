import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/route/route_lesson_cubit.dart';
import '../../application/route/route_lesson_state.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../l10n/generated/app_localizations.dart';
import '../reference/reference_edition_resolver.dart';
import '../theme/app_theme.dart';
import 'lesson_scope.dart';
import 'route_lesson_reader.dart';
import 'route_navigation.dart';

final class RouteLessonPage extends StatefulWidget {
  final String lessonId;

  const RouteLessonPage({super.key, required this.lessonId});

  @override
  State<RouteLessonPage> createState() => _RouteLessonPageState();
}

final class _RouteLessonPageState extends State<RouteLessonPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RouteLessonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId) _load();
  }

  void _load() => context.read<RouteLessonCubit>().load(
    currentReferenceEdition(context),
    widget.lessonId,
  );

  void _openExercise(String exerciseId) {
    openRouteExercise(context, widget.lessonId, exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      appBar: AppBar(backgroundColor: theme.colors.surfaces.canvas),
      body: BlocBuilder<RouteLessonCubit, RouteLessonState>(
        builder: (context, state) => RouteLessonBody(
          state: state,
          scope: LessonScope(
            edition: currentReferenceEdition(context),
            onOpenLink: (target) => openRouteTarget(context, target),
            onOpenExercise: _openExercise,
            exercises: state.exercises,
            completedExerciseIds: state.completedExerciseIds,
          ),
        ),
      ),
    );
  }
}

final class RouteLessonBody extends StatelessWidget {
  final RouteLessonState state;
  final LessonScope scope;

  const RouteLessonBody({super.key, required this.state, required this.scope});

  @override
  Widget build(BuildContext context) {
    final lesson = state.lesson;
    if (lesson != null) return RouteLessonReader(lesson: lesson, scope: scope);
    if (state.status == RouteLessonStatus.notFound) {
      final l10n = AppLocalizations.of(context)!;
      return AppEmptyState(
        icon: Icons.route_outlined,
        title: l10n.routeLessonNotFoundTitle,
        description: l10n.knowledgeErrorDescription,
      );
    }
    return const AppSkeletonList(itemExtent: 96);
  }
}
