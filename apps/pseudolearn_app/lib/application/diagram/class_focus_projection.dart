import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_unit.dart';
import '../../domain/model/execution/execution_focus.dart';

final class ClassFocusProjection {
  const ClassFocusProjection._();

  static ProgramNodeId? memberOf({
    required List<DiagramUnit> units,
    required ExecutionFocus? focus,
  }) {
    final unitId = focus?.unitId;
    if (unitId == null) return null;
    for (final unit in units) {
      if (unit.id != unitId) continue;
      return unit.className == null ? null : unit.nodeId;
    }
    return null;
  }
}
