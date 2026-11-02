import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/execution/block_position.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_stack_frame.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';

ExecutionTaskContext context(int taskId) => ExecutionTaskContext(
  taskId: taskId,
  status: ExecutionTaskStatus.running,
  completionOutcome: null,
  lastEventIndex: 4,
  focus: null,
  focusRevision: 2,
  blockPosition: const BlockPosition(depth: 1),
  frames: [
    ExecutionStackFrame(statementNodes: [const ProgramNodeId(5)]),
  ],
  scopeName: 'Worker',
  scopeDepth: 1,
  variables: const [
    WatchRow(name: 'value', formattedValue: '7', scopeName: 'Worker'),
  ],
);

void main() {
  test('task context equality includes task identity and nested state', () {
    final first = context(1);
    final equal = context(1);
    final sibling = context(2);

    expect(first, equal);
    expect(first.hashCode, equal.hashCode);
    expect(first, isNot(sibling));
    expect(first.frames.single.statementNodes, [const ProgramNodeId(5)]);
  });

  test('task context snapshots own immutable collections', () {
    final frameNodes = [const ProgramNodeId(5)];
    final frames = [ExecutionStackFrame(statementNodes: frameNodes)];
    final variables = <WatchRow>[
      const WatchRow(name: 'value', formattedValue: '7', scopeName: 'Worker'),
    ];
    final snapshot = ExecutionTaskContext(
      taskId: 1,
      status: ExecutionTaskStatus.suspended,
      completionOutcome: null,
      lastEventIndex: 4,
      focus: null,
      focusRevision: 2,
      blockPosition: const BlockPosition(depth: 1),
      frames: frames,
      scopeName: 'Worker',
      scopeDepth: 1,
      variables: variables,
    );
    frameNodes.add(const ProgramNodeId(8));
    frames.clear();
    variables.clear();

    expect(snapshot.frames.single.statementNodes, [const ProgramNodeId(5)]);
    expect(snapshot.variables, hasLength(1));
  });
}
