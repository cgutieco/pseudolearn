import 'package:flutter/material.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../shell/design_canvas.dart';
import '../theme/tokens/motion.dart';
import 'task_event_selection.dart';
import 'task_timeline_header.dart';
import 'task_timeline_metrics.dart';
import 'task_timeline_row.dart';

final class TaskTimelineView extends StatefulWidget {
  final ExecutionHistoryState state;
  final TaskFlowScene flow;
  final ValueChanged<SourceRange>? onSourceSelected;

  const TaskTimelineView({
    super.key,
    required this.state,
    required this.flow,
    required this.onSourceSelected,
  });

  @override
  State<TaskTimelineView> createState() => _TaskTimelineViewState();
}

final class _TaskTimelineViewState extends State<TaskTimelineView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _scheduleReveal(animate: false);
  }

  @override
  void didUpdateWidget(covariant TaskTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedEvent != widget.state.selectedEvent ||
        oldWidget.flow.rows.length != widget.flow.rows.length) {
      _scheduleReveal(animate: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleReveal({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(animate));
  }

  void _reveal(bool animate) {
    final rowIndex = widget.flow.rowIndexOf(widget.state.selectedEvent);
    if (!mounted || !_controller.hasClients || rowIndex == null) return;
    final position = _controller.position;
    final offset = TaskTimelineMetrics.centeredOffset(
      rowIndex: rowIndex,
      viewport: position.viewportDimension,
      maximum: position.maxScrollExtent,
    );
    final duration = _motion(context);
    if (!animate || duration == Duration.zero) {
      _controller.jumpTo(offset);
      return;
    }
    _controller.animateTo(
      offset,
      duration: duration,
      curve: MotionTokens.easeStandard,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columnWidth = TaskTimelineMetrics.columnWidth(
        width: constraints.maxWidth,
        columns: widget.flow.columns.length,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TaskTimelineHeader(
            state: widget.state,
            flow: widget.flow,
            columnWidth: columnWidth,
          ),
          Expanded(
            child: _TimelineRows(
              controller: _controller,
              view: widget,
              columnWidth: columnWidth,
            ),
          ),
        ],
      );
    },
  );
}

final class _TimelineRows extends StatelessWidget {
  final ScrollController controller;
  final TaskTimelineView view;
  final double columnWidth;

  const _TimelineRows({
    required this.controller,
    required this.view,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller: controller,
    itemExtent: TaskTimelineMetrics.rowHeight,
    itemCount: view.flow.rows.length,
    itemBuilder: (context, index) {
      final row = view.flow.rows[index];
      return TaskTimelineRow(
        row: row,
        columnCount: view.flow.columns.length,
        columnWidth: columnWidth,
        isSelected: row.event.index == view.state.selectedEvent,
        onTap: () => selectTaskEvent(
          context: context,
          flow: view.flow,
          eventIndex: row.event.index,
          onSourceSelected: view.onSourceSelected,
        ),
      );
    },
  );
}

Duration _motion(BuildContext context) =>
    context
        .dependOnInheritedWidgetOfExactType<DesignCanvasScope>()
        ?.data
        .motion(MotionSpeed.standard) ??
    MotionTokens.motionDefault;
