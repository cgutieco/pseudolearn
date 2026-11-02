import 'package:flutter/material.dart';
import '../../application/execution/execution_history_state.dart';
import 'task_projections_content.dart';
import 'task_projections_messages.dart';
import 'task_surface_selector.dart';

final class TaskProjectionsTabView extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskProjectionsTabView({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TaskSurfaceSelector(state: state),
      Expanded(
        child: !state.hasExecution || state.selectedEvent < 0
            ? TaskHistoryEmptyMessage(state: state)
            : TaskProjectionsContent(state: state),
      ),
    ],
  );
}
