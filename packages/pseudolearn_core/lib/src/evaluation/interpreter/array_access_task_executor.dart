import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/pseudo_integer.dart';
import '../../syntax/ast/ast_node.dart';
import '../environment/reference_binding.dart';
import '../environment/variable_cell.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class ArrayAccessTaskExecutor {
  final Interpreter engine;

  ArrayAccessTaskExecutor(this.engine);

  Diagnostic? finishArrayAccess(
      FinishArrayAccessTask task, InterpreterFrame frame) {
    final resolved = _resolveArrayCell(task.node, frame);
    if (resolved.diagnostic != null) return resolved.diagnostic;
    final symbolName = _designatorName(task.node.target);
    return engine.expressions
        .pushCellValue(frame, resolved.cell!, symbolName, task.node.span);
  }

  Diagnostic? finishArrayReference(
      FinishArrayReferenceTask task, InterpreterFrame frame) {
    final resolved = _resolveArrayCell(task.node, frame);
    if (resolved.diagnostic != null) return resolved.diagnostic;
    frame.pushOperand(ReferenceBinding(resolved.cell!));
    return null;
  }

  ({VariableCell? cell, Diagnostic? diagnostic}) _resolveArrayCell(
    ArrayAccessExpressionNode node,
    InterpreterFrame frame,
  ) {
    final indexValues =
        List.generate(node.indices.length, (_) => frame.popValue())
            .reversed
            .toList();
    final symbol = engine.program.resolution
        .symbolFor((node.target as VariableExpressionNode).id);
    final storage = frame.environment.scope.arrayFor(symbol!)!;
    final indices = [
      for (final v in indexValues) (v as IntegerValue).value.toHostInt()
    ];

    for (var dimension = 0; dimension < indices.length; dimension++) {
      final index = indices[dimension];
      final size = storage.dimensionSizes[dimension];
      if (index < 0 || index >= size) {
        return (
          cell: null,
          diagnostic: engine.diagnostic(
            DiagnosticCode.arrayIndexOutOfRange,
            node.indices[dimension].span,
            arguments: {
              'index': IntegerValueDiagnosticArgument(
                (indexValues[dimension] as IntegerValue).value,
              ),
              'size':
                  IntegerValueDiagnosticArgument(PseudoInteger.fromInt(size)),
            },
          ),
        );
      }
    }
    return (cell: storage.cellAt(indices), diagnostic: null);
  }

  String _designatorName(ExpressionNode designator) =>
      designator is VariableExpressionNode ? designator.name : '';
}
