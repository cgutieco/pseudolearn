import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/execution_step.dart';
import 'step_pace.dart';

final class StepSettlement {
  static const int _anyDepth = 1 << 30;
  static const int _noDepth = -1;

  final int maxDepth;
  final ProgramNodeId? excludedNodeId;

  const StepSettlement({required this.maxDepth, this.excludedNodeId});

  const StepSettlement.atAnyFocusChange()
      : maxDepth = _anyDepth,
        excludedNodeId = null;

  const StepSettlement.atExecutionEnd()
      : maxDepth = _noDepth,
        excludedNodeId = null;

  factory StepSettlement.forPace(StepPace pace, ExecutionStep from) {
    return switch (pace) {
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
    if (step.isTerminal || step.isAwaitingInput) return true;
    if (step.focusRevision == previousRevision) return false;
    if (step.blockPosition.depth > maxDepth) return false;
    return step.focus?.nodeId != excludedNodeId;
  }
}
