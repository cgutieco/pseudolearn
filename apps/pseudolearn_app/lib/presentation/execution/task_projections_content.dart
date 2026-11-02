import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import 'execution_history_navigation.dart';
import 'task_event_state_view.dart';
import 'task_flow_canvas.dart';
import 'task_structure_view.dart';
import 'task_projections_messages.dart';

final class TaskProjectionsContent extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskProjectionsContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ExecutionHistoryNavigation(
        state: state,
        cubit: context.read<ExecutionHistoryCubit>(),
      ),
      if (state.error != null) TaskHistoryError(state: state),
      Expanded(child: _TaskProjectionSurface(state: state)),
    ],
  );
}

final class _TaskProjectionSurface extends StatelessWidget {
  final ExecutionHistoryState state;

  const _TaskProjectionSurface({required this.state});

  @override
  Widget build(BuildContext context) => switch (state.surface) {
    ExecutionHistorySurface.flow => TaskFlowCanvas(state: state),
    ExecutionHistorySurface.structure => TaskStructureView(state: state),
    ExecutionHistorySurface.events => TaskEventStateView(state: state),
  };
}
