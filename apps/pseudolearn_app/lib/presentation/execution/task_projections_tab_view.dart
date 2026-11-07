import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import 'task_event_narration_bar.dart';
import 'task_projections_messages.dart';
import 'task_state_cards_view.dart';
import 'task_timeline_metrics.dart';
import 'task_timeline_view.dart';
import 'task_variables_view.dart';
import 'task_view_header.dart';

final class TaskProjectionsTabView extends StatelessWidget {
  final ExecutionHistoryState state;
  final ValueChanged<SourceRange>? onSourceSelected;

  const TaskProjectionsTabView({
    super.key,
    required this.state,
    this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TaskViewHeader(state: state),
      Expanded(
        child: !state.hasExecution || state.selectedEvent < 0
            ? TaskHistoryEmptyMessage(state: state)
            : _TaskProjectionBody(
                state: state,
                flow: context.read<ExecutionHistoryCubit>().projectFlow(),
                onSourceSelected: onSourceSelected,
              ),
      ),
    ],
  );
}

final class _TaskProjectionBody extends StatelessWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;
  final ValueChanged<SourceRange>? onSourceSelected;

  const _TaskProjectionBody({
    required this.state,
    required this.flow,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => _TaskProjectionPanes(
      body: this,
      isCompact: constraints.maxHeight < TaskTimelineMetrics.compactPaneHeight,
    ),
  );
}

final class _TaskProjectionPanes extends StatelessWidget {
  final _TaskProjectionBody body;
  final bool isCompact;

  const _TaskProjectionPanes({required this.body, required this.isCompact});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TaskEventNarrationBar(
        state: body.state,
        flow: body.flow,
        onSourceSelected: body.onSourceSelected,
        isCompact: isCompact,
      ),
      if (body.state.error != null) TaskHistoryError(state: body.state),
      Expanded(
        child: switch (body.state.surface) {
          ExecutionHistorySurface.flow => TaskTimelineView(
            state: body.state,
            flow: body.flow,
            onSourceSelected: body.onSourceSelected,
            showsLegend: !isCompact,
          ),
          ExecutionHistorySurface.structure => TaskStateCardsView(
            state: body.state,
          ),
          ExecutionHistorySurface.events => TaskVariablesView(
            state: body.state,
            flow: body.flow,
          ),
        },
      ),
    ],
  );
}
