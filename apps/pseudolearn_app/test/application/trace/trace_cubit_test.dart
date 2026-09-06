import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';

SourceRange _rangeOn(int line) => SourceRange(
      startOffset: line * 10,
      endOffset: line * 10 + 5,
      startLine: line,
      startColumn: 1,
      endLine: line,
      endColumn: 6,
    );

ExecutionState _stateWith({
  required int revision,
  required int line,
  required List<WatchRow> variables,
  int runId = 1,
  String scopeName = 'Principal',
  ExecutionFocusKind kind = ExecutionFocusKind.statement,
  bool isFinished = false,
}) {
  return ExecutionState(
    status: ExecutionStatus.pausedAtStatement,
    currentStep: ExecutionStep(
      stepNumber: revision,
      focus: ExecutionFocus(
        nodeId: ProgramNodeId(revision),
        range: _rangeOn(line),
        kind: kind,
      ),
      focusRevision: revision,
      scopeName: scopeName,
      scopeDepth: 1,
      variables: variables,
      isFinished: isFinished,
    ),
    outputLines: const [],
    runId: runId,
    statementNumber: revision,
  );
}

const _x1 = WatchRow(name: 'x', formattedValue: '1', scopeName: 'Principal');
const _x10 = WatchRow(name: 'x', formattedValue: '10', scopeName: 'Principal');
const _y0 = WatchRow(name: 'y', formattedValue: '0', scopeName: 'Principal');
const _y7 = WatchRow(name: 'y', formattedValue: '7', scopeName: 'Principal');

void main() {
  group('TraceCubit', () {
    late StreamController<ExecutionState> executions;
    late TraceCubit cubit;

    setUp(() {
      executions = StreamController<ExecutionState>.broadcast();
      cubit = TraceCubit(executionStates: executions.stream);
    });

    tearDown(() async {
      await cubit.close();
      await executions.close();
    });

    Future<void> push(ExecutionState state) async {
      executions.add(state);
      await Future<void>.delayed(Duration.zero);
    }

    test('the focused statement opens its own row right away', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x10]));

      expect(cubit.state.hasExecution, isTrue);
      expect(cubit.state.rows, hasLength(1));
      expect(cubit.state.rows.single.lineNumber, 2);
      expect(cubit.state.rows.single.isOpen, isTrue);
      expect(cubit.state.openRow, isNotNull);
    });

    test('the last row always names the line the editor is standing on', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x1]));
      await push(_stateWith(revision: 2, line: 3, variables: const [_x1]));
      await push(_stateWith(revision: 3, line: 4, variables: const [_x10]));

      expect(cubit.state.rows.last.lineNumber, 4);
      expect(cubit.state.currentRowIndex, 2);
    });

    test('a row closes with the values that its statement left behind', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x1]));
      await push(_stateWith(revision: 2, line: 3, variables: const [_x10]));

      final closed = cubit.state.rows.first;
      expect(closed.isOpen, isFalse);
      expect(closed.cells['x']?.formattedValue, '10');
    });

    test('the cell that changed is the only one marked', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x10, _y0]));
      await push(_stateWith(revision: 2, line: 3, variables: const [_x10, _y0]));
      await push(_stateWith(revision: 3, line: 4, variables: const [_x10, _y7]));

      final second = cubit.state.rows[1];
      expect(second.cells['y']?.hasJustChanged, isTrue);
      expect(second.cells['x']?.hasJustChanged, isFalse);
      expect(cubit.state.changedNames, ['y']);
      expect(cubit.state.changedValues, ['7']);
    });

    test('a variable outside the active scope leaves an empty cell, not a dash', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x10]));
      await push(_stateWith(
        revision: 2,
        line: 3,
        scopeName: 'Sub',
        variables: const [WatchRow(name: 'y', formattedValue: '20', scopeName: 'Sub')],
      ));

      final cell = cubit.state.rows.first.cells['x'];
      expect(cell?.isOutOfScope, isTrue);
      expect(cell?.formattedValue, '');
      expect(cell?.hasJustChanged, isFalse);
    });

    test('a new run clears the table instead of appending to the old one', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x1]));
      await push(_stateWith(runId: 2, revision: 1, line: 2, variables: const [_x1]));

      expect(cubit.state.rows, hasLength(1));
    });

    test('the same statement re-emitted does not duplicate its row', () async {
      final state = _stateWith(revision: 1, line: 2, variables: const [_x1]);
      await push(state);
      await push(state);

      expect(cubit.state.rows, hasLength(1));
    });

    test('a statement that changes nothing still leaves its row', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x1]));
      await push(_stateWith(revision: 2, line: 3, variables: const [_x1]));
      await push(_stateWith(revision: 3, line: 4, variables: const [_x1]));

      expect(cubit.state.rows, hasLength(3));
      expect(cubit.state.rows.map((row) => row.lineNumber), [2, 3, 4]);
    });

    test('one row per didactic step, numbered as the footer counts them', () async {
      for (var revision = 1; revision <= 5; revision++) {
        await push(_stateWith(revision: revision, line: revision + 1, variables: const [_x1]));
      }

      expect(cubit.state.rows, hasLength(5));
      expect(cubit.state.rows.last.stepNumber, 5);
    });

    test('a subroutine boundary leaves its own row', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x1]));
      await push(_stateWith(
        revision: 2,
        line: 8,
        kind: ExecutionFocusKind.subroutineEntered,
        variables: const [_x1],
      ));

      expect(cubit.state.rows, hasLength(2));
    });

    test('the end of the execution closes the last row', () async {
      await push(_stateWith(revision: 1, line: 2, variables: const [_x1]));
      await push(_stateWith(revision: 2, line: 3, variables: const [_x10], isFinished: true));

      expect(cubit.state.openRow, isNull);
      expect(cubit.state.rows.single.cells['x']?.formattedValue, '10');
    });

    test('a step where nothing is focused yet writes no row', () async {
      executions.add(const ExecutionState(
        status: ExecutionStatus.pausedAtStatement,
        currentStep: ExecutionStep(stepNumber: 0, scopeName: 'global', scopeDepth: 1),
        outputLines: [],
        runId: 1,
      ));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.rows, isEmpty);
      expect(cubit.state.hasExecution, isFalse);
    });
  });
}
