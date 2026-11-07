import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/route_exercise/trace_evaluator.dart';
import 'evaluator_support.dart';

void main() {
  const evaluator = TraceEvaluator();
  const evaluation = TraceEvaluation(
    columns: ['n', 'total'],
    rows: [
      TraceRow(label: 'antes', cells: [
        TraceCell(value: '0', editable: false),
        TraceCell(value: '0', editable: false),
      ]),
      TraceRow(label: '1', cells: [
        TraceCell(value: '1', editable: true),
        TraceCell(value: '1.0', editable: true),
      ]),
    ],
  );

  test('accepts every editable cell, numbers compared by value', () {
    final verdict = verdictOf(evaluator, evaluation, const CellsRouteAnswer({(1, 0): '1', (1, 1): '1'}));
    expect(verdict.solved, isTrue);
  });

  test('marks the wrong and the empty cells', () {
    final verdict = verdictOf(evaluator, evaluation, const CellsRouteAnswer({(1, 0): '2'}));
    expect(verdict.solved, isFalse);
    expect((verdict.feedback as WrongCellsFeedback).cells, {(1, 0), (1, 1)});
  });

  test('fixed cells are never required', () {
    final verdict = verdictOf(evaluator, evaluation, const CellsRouteAnswer({(0, 0): 'x', (1, 0): '1', (1, 1): '1'}));
    expect(verdict.solved, isTrue);
  });
}
