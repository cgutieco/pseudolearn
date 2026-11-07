import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/execution_observation_policy.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'task_labels.dart';
import 'task_timeline_metrics.dart';

final class TaskTimelineHeader extends StatelessWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;
  final double columnWidth;

  const TaskTimelineHeader({
    super.key,
    required this.state,
    required this.flow,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TaskLegend(flow: flow),
          _ColumnLabels(flow: flow, columnWidth: columnWidth),
          if (flow.rangeStart > state.horizonFirst)
            _EarlierEvents(state: state),
        ],
      ),
    );
  }
}

final class _TaskLegend extends StatelessWidget {
  final TaskFlowScene flow;

  const _TaskLegend({required this.flow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final legend = flow.columns
        .map((column) => taskNamedLabel(l10n, column.taskId, column.name))
        .join('   ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.space4,
        SpacingTokens.space2,
        SpacingTokens.space4,
        SpacingTokens.space1,
      ),
      child: AppText(
        legend,
        variant: AppTextVariant.caption,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

final class _ColumnLabels extends StatelessWidget {
  final TaskFlowScene flow;
  final double columnWidth;

  const _ColumnLabels({required this.flow, required this.columnWidth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(
        left: TaskTimelineMetrics.indexWidth,
        bottom: SpacingTokens.space1,
      ),
      child: Row(
        children: [
          for (final column in flow.columns)
            SizedBox(
              width: columnWidth,
              child: AppText(
                taskShortLabel(l10n, column.taskId),
                variant: AppTextVariant.codeCaption,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }
}

final class _EarlierEvents extends StatelessWidget {
  final ExecutionHistoryState state;

  const _EarlierEvents({required this.state});

  @override
  Widget build(BuildContext context) {
    final start = state.rangeStart - ExecutionObservationPolicy.eventWindowSize;
    final first = start < state.horizonFirst ? state.horizonFirst : start;
    return TextButton.icon(
      onPressed: () => context.read<ExecutionHistoryCubit>().dispatch(
        SelectHistoryRange(first, state.rangeEnd - first + 1),
      ),
      icon: const Icon(Icons.expand_less),
      label: Text(AppLocalizations.of(context)!.executionEarlierEvents),
    );
  }
}
