import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import '../../domain/model/execution/execution_observation_state.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../components/chip/app_chip_filter.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'task_labels.dart';

final class TaskSelectorChips extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;
  final TaskFlowScene flow;

  const TaskSelectorChips({
    super.key,
    required this.state,
    required this.inspection,
    required this.flow,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ExecutionHistoryCubit>();
    return _LabeledStrip(
      label: l10n.executionTaskPickerLabel,
      children: [
        AppChipFilter(
          label: l10n.executionFollowEventTask,
          isSelected: !state.taskPinned,
          onTap: () => cubit.dispatch(const SelectHistoryTask(null)),
        ),
        for (final task in inspection.tasks)
          AppChipFilter(
            label: taskNamedLabel(l10n, task.taskId, flow.nameOf(task.taskId)),
            isSelected: state.taskPinned && task.taskId == state.selectedTaskId,
            onTap: () => cubit.dispatch(SelectHistoryTask(task.taskId)),
          ),
      ],
    );
  }
}

final class TaskFrameBreadcrumb extends StatelessWidget {
  final ExecutionHistoryState state;
  final ExecutionObservationState inspection;

  const TaskFrameBreadcrumb({
    super.key,
    required this.state,
    required this.inspection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ExecutionHistoryCubit>();
    const page = ExecutionObservationPolicy.frameWindowSize;
    final shown = state.frameStart + inspection.frames.length;
    return _LabeledStrip(
      label: l10n.executionCallStackLabel,
      children: [
        if (state.frameStart > 0)
          _FramePageButton(
            tooltip: l10n.executionPreviousFrames,
            icon: Icons.chevron_left,
            frameStart: state.frameStart - page,
          ),
        for (final frame in inspection.frames)
          AppChipFilter(
            label: frame.name,
            isSelected: frame.id == state.selectedFrame,
            onTap: () => cubit.dispatch(SelectHistoryFrame(frame.id)),
          ),
        if (shown < inspection.totalFrames)
          _FramePageButton(
            tooltip: l10n.executionNextFrames,
            icon: Icons.chevron_right,
            frameStart: state.frameStart + page,
          ),
      ],
    );
  }
}

final class _FramePageButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final int frameStart;

  const _FramePageButton({
    required this.tooltip,
    required this.icon,
    required this.frameStart,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    icon: Icon(icon),
    onPressed: () => context.read<ExecutionHistoryCubit>().dispatch(
      SelectHistoryFramePage(frameStart),
    ),
  );
}

final class _LabeledStrip extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _LabeledStrip({required this.label, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.space3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, variant: AppTextVariant.overline),
        const SizedBox(height: SpacingTokens.space1),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final child in children)
                Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.space2),
                  child: child,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
