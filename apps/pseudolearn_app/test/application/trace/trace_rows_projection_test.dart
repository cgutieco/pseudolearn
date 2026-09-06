import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/trace/trace_rows_projection.dart';
import 'package:pseudolearn_app/application/trace/trace_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';

const _projection = TraceRowsProjection();

ExecutionFocus _focusAtLine(int line) {
  return ExecutionFocus(
    nodeId: ProgramNodeId(line),
    range: SourceRange(
      startOffset: line,
      endOffset: line + 1,
      startLine: line,
      startColumn: 1,
      endLine: line,
      endColumn: 2,
    ),
    kind: ExecutionFocusKind.statement,
  );
}

ExecutionStep _stepWith({
  required int line,
  required Map<String, String> variables,
  bool isFinished = false,
}) {
  final rows = <WatchRow>[];
  for (final entry in variables.entries) {
    rows.add(WatchRow(
      name: entry.key,
      formattedValue: entry.value,
      scopeName: 'global',
    ));
  }
  return ExecutionStep(
    stepNumber: line,
    scopeName: 'global',
    scopeDepth: 1,
    focus: _focusAtLine(line),
    focusRevision: line,
    variables: rows,
    isFinished: isFinished,
  );
}

void main() {
  group('TraceRowsProjection.opened', () {
    test('opens the first row with the focused line', () {
      final state = _projection.opened(
        const TraceState.initial(),
        _stepWith(line: 3, variables: const {'x': '1'}),
        _focusAtLine(3),
      );

      expect(state.rows.length, 1);
      expect(state.rows.first.lineNumber, 3);
      expect(state.rows.first.isOpen, isTrue);
      expect(state.variableNames, ['x']);
      expect(state.hasExecution, isTrue);
    });

    test('closes the previous row when the next one opens', () {
      final first = _projection.opened(
        const TraceState.initial(),
        _stepWith(line: 3, variables: const {'x': '1'}),
        _focusAtLine(3),
      );
      final second = _projection.opened(
        first,
        _stepWith(line: 4, variables: const {'x': '2'}),
        _focusAtLine(4),
      );

      expect(second.rows.length, 2);
      expect(second.rows.first.isOpen, isFalse);
      expect(second.rows.first.cells['x']?.formattedValue, '2');
      expect(second.rows.last.isOpen, isTrue);
    });

    test('marks a variable whose value changed', () {
      var state = _projection.opened(
        const TraceState.initial(),
        _stepWith(line: 1, variables: const {'x': '1'}),
        _focusAtLine(1),
      );
      state = _projection.opened(
        state,
        _stepWith(line: 2, variables: const {'x': '2'}),
        _focusAtLine(2),
      );
      state = _projection.opened(
        state,
        _stepWith(line: 3, variables: const {'x': '9'}),
        _focusAtLine(3),
      );

      expect(state.changedNames, ['x']);
      expect(state.changedValues, ['9']);
    });

    test('leaves a variable unmarked when its value held', () {
      var state = _projection.opened(
        const TraceState.initial(),
        _stepWith(line: 1, variables: const {'x': '7'}),
        _focusAtLine(1),
      );
      state = _projection.opened(
        state,
        _stepWith(line: 2, variables: const {'x': '7'}),
        _focusAtLine(2),
      );
      state = _projection.opened(
        state,
        _stepWith(line: 3, variables: const {'x': '7'}),
        _focusAtLine(3),
      );

      expect(state.changedNames, isEmpty);
    });

    test('records a variable that left scope as an empty cell', () {
      var state = _projection.opened(
        const TraceState.initial(),
        _stepWith(line: 1, variables: const {'x': '1', 'y': '2'}),
        _focusAtLine(1),
      );
      state = _projection.opened(
        state,
        _stepWith(line: 2, variables: const {'x': '1'}),
        _focusAtLine(2),
      );

      expect(state.variableNames, containsAll(<String>['x', 'y']));
      expect(state.rows.last.cells['y']?.isOutOfScope, isTrue);
    });
  });

  group('TraceRowsProjection.closed', () {
    test('settles the open row with the terminal values', () {
      final open = _projection.opened(
        const TraceState.initial(),
        _stepWith(line: 1, variables: const {'x': '1'}),
        _focusAtLine(1),
      );

      final closed = _projection.closed(
        open,
        _stepWith(line: 2, variables: const {'x': '5'}, isFinished: true),
      );

      expect(closed.rows.length, 1);
      expect(closed.rows.single.isOpen, isFalse);
      expect(closed.rows.single.cells['x']?.formattedValue, '5');
    });

    test('returns the state untouched when no row is open', () {
      const state = TraceState.initial();

      final closed = _projection.closed(
        state,
        _stepWith(line: 1, variables: const {}, isFinished: true),
      );

      expect(identical(closed, state), isTrue);
    });
  });
}
