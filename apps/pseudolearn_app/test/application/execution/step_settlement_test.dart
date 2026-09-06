import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/execution/step_settlement.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/block_position.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';

const _range = SourceRange(
  startOffset: 0,
  endOffset: 4,
  startLine: 1,
  startColumn: 1,
  endLine: 1,
  endColumn: 5,
);

ExecutionStep _step({
  required int revision,
  required int depth,
  required int nodeId,
  int? enclosingNodeId,
  ExecutionFocusKind kind = ExecutionFocusKind.statement,
  bool isFinished = false,
  bool isAwaitingInput = false,
}) {
  return ExecutionStep(
    stepNumber: revision,
    scopeName: 'main',
    scopeDepth: 1,
    focus: ExecutionFocus(
      nodeId: ProgramNodeId(nodeId),
      range: _range,
      kind: kind,
    ),
    focusRevision: revision,
    blockPosition: BlockPosition(
      depth: depth,
      enclosingNodeId: enclosingNodeId == null ? null : ProgramNodeId(enclosingNodeId),
    ),
    isFinished: isFinished,
    isAwaitingInput: isAwaitingInput,
  );
}

void main() {
  group('nextStatement', () {
    final settlement = StepSettlement.forPace(
      StepPace.nextStatement,
      _step(revision: 1, depth: 1, nodeId: 10),
    );

    test('settles on the first focus change, however deep', () {
      expect(settlement.settlesOn(_step(revision: 2, depth: 5, nodeId: 20), 1), isTrue);
    });

    test('does not settle while the focus has not moved', () {
      expect(settlement.settlesOn(_step(revision: 1, depth: 1, nodeId: 10), 1), isFalse);
    });
  });

  group('overBlock', () {
    final fromLoopHeader = StepSettlement.forPace(
      StepPace.overBlock,
      _step(revision: 4, depth: 1, nodeId: 10, kind: ExecutionFocusKind.decision),
    );

    test('skips everything inside the block', () {
      expect(fromLoopHeader.settlesOn(_step(revision: 5, depth: 2, nodeId: 11), 4), isFalse);
    });

    test('skips the loop condition of the very block being run', () {
      expect(
        fromLoopHeader.settlesOn(
          _step(revision: 6, depth: 1, nodeId: 10, kind: ExecutionFocusKind.decision),
          4,
        ),
        isFalse,
      );
    });

    test('settles on the first statement after the block', () {
      expect(fromLoopHeader.settlesOn(_step(revision: 9, depth: 1, nodeId: 12), 4), isTrue);
    });

    test('over a simple statement behaves like a single step', () {
      final settlement = StepSettlement.forPace(
        StepPace.overBlock,
        _step(revision: 2, depth: 1, nodeId: 30),
      );
      expect(settlement.settlesOn(_step(revision: 3, depth: 1, nodeId: 31), 2), isTrue);
    });
  });

  group('outOfBlock', () {
    final fromLoopBody = StepSettlement.forPace(
      StepPace.outOfBlock,
      _step(revision: 7, depth: 2, nodeId: 11, enclosingNodeId: 10),
    );

    test('skips the remaining turns of the enclosing loop', () {
      expect(
        fromLoopBody.settlesOn(
          _step(revision: 8, depth: 1, nodeId: 10, kind: ExecutionFocusKind.decision),
          7,
        ),
        isFalse,
      );
    });

    test('skips sibling statements of the same body', () {
      expect(fromLoopBody.settlesOn(_step(revision: 8, depth: 2, nodeId: 13), 7), isFalse);
    });

    test('settles once execution leaves the enclosing block', () {
      expect(fromLoopBody.settlesOn(_step(revision: 12, depth: 1, nodeId: 14), 7), isTrue);
    });

    test('without an enclosing block nothing but the end settles it', () {
      final settlement = StepSettlement.forPace(
        StepPace.outOfBlock,
        _step(revision: 1, depth: 1, nodeId: 10),
      );
      expect(settlement.settlesOn(_step(revision: 2, depth: 1, nodeId: 11), 1), isFalse);
    });
  });

  group('toEnd', () {
    final settlement = StepSettlement.forPace(
      StepPace.toEnd,
      _step(revision: 1, depth: 1, nodeId: 10),
    );

    test('ignores every focus change', () {
      expect(settlement.settlesOn(_step(revision: 2, depth: 1, nodeId: 11), 1), isFalse);
    });

    test('settles when the program finishes', () {
      expect(
        settlement.settlesOn(_step(revision: 2, depth: 1, nodeId: 11, isFinished: true), 1),
        isTrue,
      );
    });

    test('settles when the program asks for input', () {
      expect(
        settlement.settlesOn(
          _step(revision: 2, depth: 1, nodeId: 11, isAwaitingInput: true),
          1,
        ),
        isTrue,
      );
    });
  });
}
