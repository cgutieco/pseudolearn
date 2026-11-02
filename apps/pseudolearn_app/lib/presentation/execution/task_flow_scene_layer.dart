import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'task_flow_painter.dart';

final class TaskFlowSceneLayer extends StatelessWidget {
  final TaskFlowScene scene;
  final int selectedEvent;

  const TaskFlowSceneLayer({
    super.key,
    required this.scene,
    required this.selectedEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Stack(
      children: [
        CustomPaint(
          size: Size(scene.width, scene.height),
          painter: TaskFlowPainter(scene: scene, colors: colors),
        ),
        for (final lane in scene.lanes) TaskFlowLaneLabel(lane: lane),
        for (final marker in scene.markers)
          TaskFlowEventMarker(
            marker: marker,
            isSelected: marker.event.index == selectedEvent,
          ),
        for (final connector in scene.connectors)
          TaskFlowConnectorSemantics(connector: connector),
      ],
    );
  }
}

final class TaskFlowLaneLabel extends StatelessWidget {
  final TaskFlowLane lane;

  const TaskFlowLaneLabel({super.key, required this.lane});

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.executionTaskLane(lane.taskId);
    return Positioned(
      left: 4,
      top: lane.y - 14,
      width: 88,
      child: Semantics(
        label: label,
        child: AppText(
          label,
          variant: AppTextVariant.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

final class TaskFlowEventMarker extends StatelessWidget {
  final TaskFlowMarker marker;
  final bool isSelected;

  const TaskFlowEventMarker({
    super.key,
    required this.marker,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final event = marker.event;
    final label = AppLocalizations.of(context)!.executionEventSemantics(
      event.index,
      event.taskId,
      event.eventClass,
      event.line,
    );
    return Positioned(
      left: marker.x - 22,
      top: marker.y - 22,
      width: 44,
      height: 44,
      child: TaskFlowMarkerButton(
        event: event,
        label: label,
        isSelected: isSelected,
      ),
    );
  }
}

final class TaskFlowMarkerButton extends StatelessWidget {
  final ExecutionHistoryEvent event;
  final String label;
  final bool isSelected;

  const TaskFlowMarkerButton({
    super.key,
    required this.event,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: IconButton(
      tooltip: label,
      padding: EdgeInsets.zero,
      onPressed: () => context.read<ExecutionHistoryCubit>().dispatch(
        SelectHistoryEvent(event.index),
      ),
      icon: TaskFlowEventMarkerIcon(
        eventIndex: event.index,
        isSelected: isSelected,
      ),
    ),
  );
}

final class TaskFlowEventMarkerIcon extends StatelessWidget {
  final int eventIndex;
  final bool isSelected;

  const TaskFlowEventMarkerIcon({
    super.key,
    required this.eventIndex,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? colors.surfaces.brandSubtle
            : colors.surfaces.defaultSurface,
        border: Border.all(
          color: isSelected ? colors.text.link : colors.borders.strong,
        ),
        shape: BoxShape.circle,
      ),
      child: AppText(
        eventIndex.toString(),
        variant: AppTextVariant.codeCaption,
        maxLines: 1,
      ),
    );
  }
}

final class TaskFlowConnectorSemantics extends StatelessWidget {
  final TaskFlowConnector connector;

  const TaskFlowConnectorSemantics({super.key, required this.connector});

  @override
  Widget build(BuildContext context) => connector.targetKind == 'creation'
      ? const SizedBox.shrink()
      : _TaskFlowConnectorLabel(connector: connector);
}

final class _TaskFlowConnectorLabel extends StatelessWidget {
  final TaskFlowConnector connector;

  const _TaskFlowConnectorLabel({required this.connector});

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.executionFlowConnector(
      connector.sourceEvent,
      connector.sourceTaskId,
      connector.cause,
      connector.targetId,
    );
    return Positioned(
      left: connector.startX,
      top: connector.endY,
      width: SpacingTokens.spaceHalf,
      height: SpacingTokens.spaceHalf,
      child: Semantics(
        container: true,
        label: label,
        child: const SizedBox(
          width: SpacingTokens.spaceHalf,
          height: SpacingTokens.spaceHalf,
        ),
      ),
    );
  }
}
