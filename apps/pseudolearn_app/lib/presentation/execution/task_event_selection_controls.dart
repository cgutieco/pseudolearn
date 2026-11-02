import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class TaskEventSelectionControls extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;

  const TaskEventSelectionControls({
    super.key,
    required this.state,
    required this.inspection,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _TaskSelector(state: state, inspection: inspection),
      _FramePageControls(state: state, inspection: inspection),
    ],
  );
}

final class _TaskSelector extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;

  const _TaskSelector({required this.state, required this.inspection});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.space4,
      vertical: SpacingTokens.space1,
    ),
    child: DropdownButtonFormField<int>(
      initialValue: state.hasSelectedTask ? state.selectedTaskId : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.executionTaskSelector,
      ),
      items: [
        for (final task in inspection.tasks)
          DropdownMenuItem(
            value: task.taskId,
            child: Text(
              AppLocalizations.of(context)!.executionTaskLane(task.taskId),
            ),
          ),
      ],
      onChanged: (task) {
        if (task != null) {
          context.read<ExecutionHistoryCubit>().dispatch(
            SelectHistoryTask(task),
          );
        }
      },
    ),
  );
}

final class _FramePageControls extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;

  const _FramePageControls({required this.state, required this.inspection});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.space4,
      vertical: SpacingTokens.space1,
    ),
    child: Row(
      children: [
        _PreviousFramePage(state: state),
        Expanded(
          child: _FrameSelector(state: state, inspection: inspection),
        ),
        _NextFramePage(state: state, inspection: inspection),
      ],
    ),
  );
}

final class _PreviousFramePage extends StatelessWidget {
  final ExecutionHistoryState state;

  const _PreviousFramePage({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.executionPreviousFrames,
      onPressed: state.frameStart == 0
          ? null
          : () => context.read<ExecutionHistoryCubit>().dispatch(
              SelectHistoryFramePage(
                state.frameStart - ExecutionObservationPolicy.frameWindowSize,
              ),
            ),
      icon: const Icon(Icons.chevron_left),
    );
  }
}

final class _NextFramePage extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;

  const _NextFramePage({required this.state, required this.inspection});

  @override
  Widget build(BuildContext context) {
    final atEnd =
        state.frameStart + inspection.frames.length >= inspection.totalFrames;
    return IconButton(
      tooltip: AppLocalizations.of(context)!.executionNextFrames,
      onPressed: atEnd
          ? null
          : () => context.read<ExecutionHistoryCubit>().dispatch(
              SelectHistoryFramePage(
                state.frameStart + ExecutionObservationPolicy.frameWindowSize,
              ),
            ),
      icon: const Icon(Icons.chevron_right),
    );
  }
}

final class _FrameSelector extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;

  const _FrameSelector({required this.state, required this.inspection});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: state.hasSelectedFrame ? state.selectedFrame : null,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.executionFrameSelector,
    ),
    items: [
      for (final frame in inspection.frames)
        DropdownMenuItem(
          value: frame.id,
          child: Text(
            AppLocalizations.of(
              context,
            )!.executionFrameLabel(frame.id, frame.name),
          ),
        ),
    ],
    onChanged: (frame) {
      if (frame != null) {
        context.read<ExecutionHistoryCubit>().dispatch(
          SelectHistoryFrame(frame),
        );
      }
    },
  );
}
