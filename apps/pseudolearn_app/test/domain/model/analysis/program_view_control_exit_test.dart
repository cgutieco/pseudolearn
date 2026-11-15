import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_view_control_exit.dart';

void main() {
  test('a control exit keeps an unmodifiable cleanup order', () {
    final cleanups = [const ProgramNodeId(4), const ProgramNodeId(2)];
    final exit = ProgramViewControlExit(
      exitNodeId: const ProgramNodeId(7),
      kind: ProgramViewExitKind.returnUnit,
      targetNodeId: null,
      cleanupNodeIds: cleanups,
    );
    cleanups.clear();

    expect(exit.cleanupNodeIds, [const ProgramNodeId(4), const ProgramNodeId(2)]);
    expect(() => exit.cleanupNodeIds.add(const ProgramNodeId(1)), throwsUnsupportedError);
  });

  test('a cleanup scope may list no cleanups', () {
    final scope = ProgramViewCleanupScope(
      bodyNodeId: const ProgramNodeId(0),
      cleanupNodeIds: const [],
    );

    expect(scope.cleanupNodeIds, isEmpty);
  });
}
