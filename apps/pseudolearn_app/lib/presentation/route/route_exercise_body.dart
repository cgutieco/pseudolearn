import 'package:material_ui/material_ui.dart';
import '../../application/route/route_exercise_state.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_exercise.dart';
import '../components/button/app_button.dart';
import '../components/layout/app_content_column.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../reference/blocks/reference_program_view.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'answers/answer_panel.dart';
import 'exercise_parts.dart';
import 'lesson_block_view.dart';
import 'lesson_scope.dart';
import 'route_labels.dart';

final class RouteExerciseActions {
  final ValueChanged<RouteAnswer> onSubmit;
  final VoidCallback onOpenEditor;
  final VoidCallback onHint;
  final VoidCallback onReveal;

  const RouteExerciseActions({
    required this.onSubmit,
    required this.onOpenEditor,
    required this.onHint,
    required this.onReveal,
  });
}

final class RouteExerciseBody extends StatelessWidget {
  final RouteExerciseState state;
  final RouteExercise exercise;
  final LessonScope scope;
  final RouteExerciseActions actions;

  const RouteExerciseBody({
    super.key,
    required this.state,
    required this.exercise,
    required this.scope,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final program = state.shownProgram;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.space4),
      child: AppContentColumn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExerciseHeading(exercise: exercise, scope: scope, completed: state.completed),
            LessonBlockColumn(blocks: exercise.statement, scope: scope),
            if (exercise.restriction.isNotEmpty)
              LessonBlockColumn(blocks: exercise.restriction, scope: scope),
            if (program != null) ReferenceProgramView(program: program, edition: scope.edition),
            const SizedBox(height: SpacingTokens.space3),
            ExerciseAnswerArea(state: state, exercise: exercise, scope: scope, actions: actions),
            ExerciseHints(exercise: exercise, shown: state.hintsShown, canShowMore: state.canShowHint, scope: scope, onHint: actions.onHint),
            ExerciseReveal(exercise: exercise, open: state.isOpen, scope: scope, onReveal: actions.onReveal),
          ],
        ),
      ),
    );
  }
}

final class ExerciseHeading extends StatelessWidget {
  final RouteExercise exercise;
  final LessonScope scope;
  final bool completed;

  const ExerciseHeading({
    super.key,
    required this.exercise,
    required this.scope,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final badges = [
      routeKindLabel(exercise.kind, l10n),
      routeLevelLabel(exercise.level, l10n),
      if (exercise.required) l10n.routePracticeRequired,
      if (completed) l10n.routePracticeDone,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(badges, variant: AppTextVariant.caption, color: completed ? theme.colors.severities.success.fg : theme.colors.text.tertiary),
          LessonRunsText(runs: exercise.title, scope: scope, variant: AppTextVariant.heading2),
        ],
      ),
    );
  }
}

final class ExerciseAnswerArea extends StatelessWidget {
  final RouteExerciseState state;
  final RouteExercise exercise;
  final LessonScope scope;
  final RouteExerciseActions actions;

  const ExerciseAnswerArea({
    super.key,
    required this.state,
    required this.exercise,
    required this.scope,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (exercise.kind.isAnsweredInEditor) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AppButton(
          label: l10n.routeExerciseOpenEditor,
          variant: AppButtonVariant.primary,
          icon: Icons.edit_note_rounded,
          onPressed: actions.onOpenEditor,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnswerPanel(exercise: exercise, verdict: state.verdict, scope: scope, onSubmit: actions.onSubmit),
        ExerciseFeedback(verdict: state.verdict),
      ],
    );
  }
}
