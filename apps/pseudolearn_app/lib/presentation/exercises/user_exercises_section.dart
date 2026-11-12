import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/exercises/user_exercise_library_cubit.dart';
import '../../application/exercises/user_exercise_library_state.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../components/button/app_button.dart';
import '../components/dialog/app_dialog.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/grid_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'user_exercise_menu.dart';
import 'user_exercise_tile.dart';

final class UserExercisesSection extends StatefulWidget {
  final VoidCallback onCreate;

  const UserExercisesSection({super.key, required this.onCreate});

  @override
  State<UserExercisesSection> createState() => _UserExercisesSectionState();
}

final class _UserExercisesSectionState extends State<UserExercisesSection> {
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

  void _openMenu(UserExercise exercise) {
    showUserExerciseMenu(
      context: context,
      onEdit: () => context.push('/biblioteca/ejercicio/${exercise.id}'),
      onDelete: () => _delete(exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserExerciseLibraryCubit, UserExerciseLibraryState>(
      builder: (context, state) => _SectionView(
        state: state,
        onCreate: widget.onCreate,
        onSolve: _solve,
        onMenu: _openMenu,
      ),
    );
  }
}

final class _SectionView extends StatelessWidget {
  final UserExerciseLibraryState state;
  final VoidCallback onCreate;
  final ValueChanged<UserExercise> onSolve;
  final ValueChanged<UserExercise> onMenu;

  const _SectionView({
    required this.state,
    required this.onCreate,
    required this.onSolve,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoading) {
      return const AppSkeletonList(itemExtent: GridMetricsTokens.cardExtentDocument);
    }
    if (state.exercises.isEmpty) {
      return AppEmptyState(
        icon: Icons.assignment_outlined,
        title: l10n.userExercisesEmptyTitle,
        description: l10n.userExercisesEmpty,
        actionLabel: l10n.userExercisesNew,
        onAction: onCreate,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space20),
      itemCount: state.exercises.length,
      itemBuilder: (context, index) => UserExerciseTile(
        key: ValueKey('user-exercise:${state.exercises[index].id}'),
        exercise: state.exercises[index],
        onSolve: () => onSolve(state.exercises[index]),
        onMenu: () => onMenu(state.exercises[index]),
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
