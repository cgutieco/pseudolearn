import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'task_view_help_sheet.dart';

final class TaskViewHeader extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskViewHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.space3,
      SpacingTokens.space2,
      SpacingTokens.space1,
      SpacingTokens.space1,
    ),
    child: Row(
      children: [
        Expanded(child: _TaskSurfaceSegments(state: state)),
        TaskViewHelpButton(surface: state.surface),
      ],
    ),
  );
}

final class _TaskSurfaceSegments extends StatelessWidget {
  final ExecutionHistoryState state;

  const _TaskSurfaceSegments({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<ExecutionHistorySurface>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      segments: [
        _segment(ExecutionHistorySurface.flow, l10n.executionProjectionFlow),
        _segment(
          ExecutionHistorySurface.structure,
          l10n.executionProjectionStructure,
        ),
        _segment(
          ExecutionHistorySurface.events,
          l10n.executionProjectionEvents,
        ),
      ],
      selected: {state.surface},
      onSelectionChanged: (selection) => context
          .read<ExecutionHistoryCubit>()
          .dispatch(SelectHistorySurface(selection.first)),
    );
  }
}

ButtonSegment<ExecutionHistorySurface> _segment(
  ExecutionHistorySurface surface,
  String label,
) => ButtonSegment(
  value: surface,
  label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
);
