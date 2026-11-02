import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class TaskSurfaceSelector extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskSurfaceSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      child: _TaskSurfaceSegments(state: state),
    );
  }
}

final class _TaskSurfaceSegments extends StatelessWidget {
  final ExecutionHistoryState state;

  const _TaskSurfaceSegments({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<ExecutionHistorySurface>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ExecutionHistorySurface.flow,
          label: Text(l10n.executionProjectionFlow),
        ),
        ButtonSegment(
          value: ExecutionHistorySurface.structure,
          label: Text(l10n.executionProjectionStructure),
        ),
        ButtonSegment(
          value: ExecutionHistorySurface.events,
          label: Text(l10n.executionProjectionEvents),
        ),
      ],
      selected: {state.surface},
      onSelectionChanged: (selection) => context
          .read<ExecutionHistoryCubit>()
          .dispatch(SelectHistorySurface(selection.first)),
    );
  }
}
