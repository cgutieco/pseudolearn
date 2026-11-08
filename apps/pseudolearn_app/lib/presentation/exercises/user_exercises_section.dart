import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/exercises/user_exercise_library_cubit.dart';
import '../../application/exercises/user_exercise_library_state.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../components/button/app_button.dart';
import '../components/card/app_card.dart';
import '../components/dialog/app_dialog.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'user_exercise_editor_page.dart';

final class UserExercisesSection extends StatefulWidget {
  const UserExercisesSection({super.key});

  @override
  State<UserExercisesSection> createState() => _UserExercisesSectionState();
}

final class _UserExercisesSectionState extends State<UserExercisesSection> {
  @override
  void initState() {
    super.initState();
    context.read<UserExerciseLibraryCubit>().load();
  }

  void _solve(UserExercise exercise) {
    context.read<UserExerciseLibraryCubit>().openAttempt(exercise).then((documentId) {
      if (documentId != null && mounted) context.push('/biblioteca/documento/$documentId');
    });
  }

  void _delete(UserExercise exercise) {
    final cubit = context.read<UserExerciseLibraryCubit>();
    showAppDialog<void>(
      context,
      builder: (dialogContext) => _DeleteDialog(
        title: exercise.title,
        onConfirm: () => cubit.delete(exercise.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserExerciseLibraryCubit, UserExerciseLibraryState>(
      builder: (context, state) => _SectionView(
        state: state,
        onCreate: () => context.push('/biblioteca/ejercicio/$newUserExerciseSegment'),
        onSolve: _solve,
        onEdit: (exercise) => context.push('/biblioteca/ejercicio/${exercise.id}'),
        onDelete: _delete,
      ),
    );
  }
}

final class _SectionView extends StatelessWidget {
  final UserExerciseLibraryState state;
  final VoidCallback onCreate;
  final ValueChanged<UserExercise> onSolve;
  final ValueChanged<UserExercise> onEdit;
  final ValueChanged<UserExercise> onDelete;

  const _SectionView({
    required this.state,
    required this.onCreate,
    required this.onSolve,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      key: const ValueKey('feature:user-exercises'),
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(onCreate: onCreate),
          if (state.isEmpty) AppText(l10n.userExercisesEmpty, variant: AppTextVariant.bodySmall),
          for (final exercise in state.exercises)
            _ExerciseTile(
              exercise: exercise,
              onSolve: () => onSolve(exercise),
              onEdit: () => onEdit(exercise),
              onDelete: () => onDelete(exercise),
            ),
        ],
      ),
    );
  }
}

final class _SectionHeading extends StatelessWidget {
  final VoidCallback onCreate;

  const _SectionHeading({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Row(
        children: [
          Expanded(child: AppText(l10n.userExercisesTitle, variant: AppTextVariant.heading4)),
          AppButton(
            key: const ValueKey('feature:user-exercise-create'),
            label: l10n.userExercisesNew,
            icon: Icons.add,
            variant: AppButtonVariant.secondary,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

final class _ExerciseTile extends StatelessWidget {
  final UserExercise exercise;
  final VoidCallback onSolve;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseTile({
    required this.exercise,
    required this.onSolve,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: AppCard(
        onTap: onSolve,
        child: Wrap(
          spacing: SpacingTokens.space2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppText(exercise.title, variant: AppTextVariant.label),
            AppButton(key: ValueKey('user-exercise-solve:${exercise.id}'), label: l10n.userExercisesSolve, variant: AppButtonVariant.primary, onPressed: onSolve),
            AppButton(label: l10n.userExercisesEdit, variant: AppButtonVariant.tertiary, onPressed: onEdit),
            AppButton(label: l10n.userExercisesDelete, variant: AppButtonVariant.tertiary, onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

final class _DeleteDialog extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;

  const _DeleteDialog({required this.title, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppDialog(
      title: l10n.userExercisesDeleteTitle,
      body: l10n.userExercisesDeleteMessage(title),
      actions: [
        AppButton(label: l10n.actionCancel, variant: AppButtonVariant.tertiary, onPressed: () => Navigator.of(context).pop()),
        AppButton(
          label: l10n.actionDelete,
          variant: AppButtonVariant.primary,
          destructive: true,
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
