import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/execution_step.dart';
import 'step_pace.dart';

final class StepSettlement {
  static const int _anyDepth = 1 << 30;
  static const int _noDepth = -1;

  final int maxDepth;
  final ProgramNodeId? excludedNodeId;
  final int? _afterEventIndex;
  final int? _taskId;

  const StepSettlement({required this.maxDepth, this.excludedNodeId})
    : _afterEventIndex = null,
      _taskId = null;

  const StepSettlement.atAnyFocusChange()
    : maxDepth = _anyDepth,
      excludedNodeId = null,
      _afterEventIndex = null,
      _taskId = null;

  const StepSettlement.atExecutionEnd()
    : maxDepth = _noDepth,
      excludedNodeId = null,
      _afterEventIndex = null,
      _taskId = null;

  StepSettlement.afterEvent({required int eventIndex, int? taskId})
    : maxDepth = _noDepth,
      excludedNodeId = null,
      _afterEventIndex = eventIndex,
      _taskId = taskId;

  factory StepSettlement.forTask({
    required int taskId,
    required ExecutionStep from,
  }) => StepSettlement.afterEvent(eventIndex: from.eventIndex, taskId: taskId);

  factory StepSettlement.forPace(StepPace pace, ExecutionStep from) {
    return switch (pace) {
      StepPace.nextEvent => StepSettlement.afterEvent(
        eventIndex: from.eventIndex,
      ),
      StepPace.nextStatement => const StepSettlement.atAnyFocusChange(),
      StepPace.toEnd => const StepSettlement.atExecutionEnd(),
      StepPace.overBlock => StepSettlement(
        maxDepth: from.blockPosition.depth,
        excludedNodeId: from.focus?.nodeId,
      ),
      StepPace.outOfBlock => StepSettlement(
        maxDepth: from.blockPosition.depth - 1,
        excludedNodeId: from.blockPosition.enclosingNodeId,
      ),
    };
  }

  bool settlesOn(ExecutionStep step, int previousRevision) {
    if (step.isTerminal || step.isAwaitingInput || step.isAwaitingEffect) {
      return true;
    }
    final afterEventIndex = _afterEventIndex;
    if (afterEventIndex != null) {
      return step.eventIndex > afterEventIndex &&
          (_taskId == null || step.taskId == _taskId);
    }
    if (step.focusRevision == previousRevision) return false;
    if (step.blockPosition.depth > maxDepth) return false;
    return step.focus?.nodeId != excludedNodeId;
  }
}
