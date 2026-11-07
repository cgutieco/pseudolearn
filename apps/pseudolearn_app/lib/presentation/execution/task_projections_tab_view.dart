import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import 'task_event_narration_bar.dart';
import 'task_projections_messages.dart';
import 'task_state_cards_view.dart';
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TaskEventNarrationBar(
        state: state,
        flow: flow,
        onSourceSelected: onSourceSelected,
      ),
      if (state.error != null) TaskHistoryError(state: state),
      Expanded(
        child: switch (state.surface) {
          ExecutionHistorySurface.flow => TaskTimelineView(
            state: state,
            flow: flow,
            onSourceSelected: onSourceSelected,
          ),
          ExecutionHistorySurface.structure => TaskStateCardsView(state: state),
          ExecutionHistorySurface.events => TaskVariablesView(
            state: state,
            flow: flow,
          ),
        },
      ),
    ],
  );
}
