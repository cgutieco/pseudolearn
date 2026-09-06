import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/program_node_id.dart';
import 'python_expression_emitter.dart';
import 'target_code_builder.dart';

final class PythonStatementEmitter {
  final PythonExpressionEmitter _expressions;

  const PythonStatementEmitter([
    PythonExpressionEmitter expressions = const PythonExpressionEmitter(),
  ]) : _expressions = expressions;

  void emitStatement(
    StatementNode stmt,
    TargetCodeBuilder buffer, {
    required String indent,
  }) {
    buffer.attributedTo(
      ProgramNodeId(stmt.id.value),
      () => _emitStatementBody(stmt, buffer, indent),
    );
  }

  void emitBlock(
    List<StatementNode> body,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    if (body.isEmpty) {
      buffer.writeln('$indent' 'pass');
      return;
    }
    for (final stmt in body) {
      emitStatement(stmt, buffer, indent: indent);
    }
  }

  void _emitStatementBody(
    StatementNode stmt,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    switch (stmt) {
      case final AssignmentStatementNode s:
        buffer.writeln(
          '$indent${_expressions.emit(s.target)} = ${_expressions.emit(s.value)}',
        );
      case final VariableDeclarationNode s:
        _emitVarDecl(s, buffer, indent);
      case final DimensionStatementNode s:
        _emitDimension(s, buffer, indent);
      case final WriteStatementNode s:
        _emitWrite(s, buffer, indent);
      case final ReadStatementNode s:
        _emitRead(s, buffer, indent);
      case final IfStatementNode s:
        _emitIf(s, buffer, indent);
      case final WhileStatementNode s:
        _emitWhile(s, buffer, indent);
      case final RepeatUntilStatementNode s:
        _emitRepeatUntil(s, buffer, indent);
      case final ForStatementNode s:
        _emitFor(s, buffer, indent);
      case final SwitchStatementNode s:
        _emitSwitch(s, buffer, indent);
      case final ReturnStatementNode s:
        _emitReturn(s, buffer, indent);
      case final CallStatementNode s:
        buffer.writeln(
          '$indent${s.name}(${s.arguments.map(_expressions.emit).join(', ')})',
        );
      case final MethodCallStatementNode s:
        _emitMethodCall(s, buffer, indent);
      default:
        buffer.writeln('$indent# Unsupported statement');
    }
  }

  void _emitMethodCall(
    MethodCallStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    if (isSuperConstructorCall(s)) {
      final args = s.arguments.map(_expressions.emit).join(', ');
      buffer.writeln('$indent' 'super().__init__($args)');
      return;
    }
    final target = _expressions.emit(s.target);
    final args = s.arguments.map(_expressions.emit).join(', ');
    buffer.writeln('$indent$target.${s.methodName}($args)');
  }

  void _emitVarDecl(
    VariableDeclarationNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    for (final decl in s.variables) {
      buffer.writeln('$indent${decl.name} = None');
    }
  }

  void _emitWrite(
    WriteStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final args = s.expressions.map(_expressions.emit).join(', ');
    final end = s.withoutNewline ? ', end=""' : '';
    buffer.writeln('$indent' 'print($args$end)');
  }

  void _emitRead(
    ReadStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    for (final target in s.targets) {
      buffer.writeln('$indent${_expressions.emit(target)} = input()');
    }
  }

  void _emitReturn(
    ReturnStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final val = s.value != null ? ' ${_expressions.emit(s.value!)}' : '';
    buffer.writeln('$indent' 'return$val');
  }

  void _emitDimension(
    DimensionStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    for (final array in s.arrays) {
      if (array.dimensions.length == 1) {
        final size = _expressions.emit(array.dimensions.first);
        buffer.writeln('$indent${array.name} = [0] * ($size)');
      } else if (array.dimensions.length == 2) {
        final cols = _expressions.emit(array.dimensions[1]);
        final rows = _expressions.emit(array.dimensions[0]);
        buffer.writeln(
          '$indent${array.name} = [[0] * ($cols) for _ in range($rows)]',
        );
      } else {
        buffer.writeln('$indent${array.name} = []');
      }
    }
  }

  void _emitIf(
    IfStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    buffer.writeln('$indent' 'if ${_expressions.emit(s.condition)}:');
    emitBlock(s.thenBody, buffer, '$indent    ');
    if (s.elseBody != null && s.elseBody!.isNotEmpty) {
      buffer.writeln('$indent' 'else:');
      emitBlock(s.elseBody!, buffer, '$indent    ');
    }
  }

  void _emitWhile(
    WhileStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    buffer.writeln('$indent' 'while ${_expressions.emit(s.condition)}:');
    emitBlock(s.body, buffer, '$indent    ');
  }

  void _emitRepeatUntil(
    RepeatUntilStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    buffer.writeln('$indent' 'while True:');
    for (final stmt in s.body) {
      emitStatement(stmt, buffer, indent: '$indent    ');
    }
    buffer.writeln('$indent    if ${_expressions.emit(s.condition)}:');
    buffer.writeln('$indent        break');
  }

  void _emitFor(
    ForStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final from = _expressions.emit(s.from);
    final to = _expressions.emit(s.to);
    final isNeg = s.step is UnaryExpressionNode &&
        (s.step as UnaryExpressionNode).operator == UnaryOperator.negate;
    final endAdj = isNeg ? '$to - 1' : '$to + 1';
    final stepExpr = s.step != null ? ', ${_expressions.emit(s.step!)}' : '';
    final rangeArgs = '$from, $endAdj$stepExpr';
    buffer.writeln('$indent' 'for ${s.variable.name} in range($rangeArgs):');
    emitBlock(s.body, buffer, '$indent    ');
  }

  void _emitSwitch(
    SwitchStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    buffer.writeln('$indent' 'match ${_expressions.emit(s.selector)}:');
    for (final c in s.cases) {
      final labels = c.labels.map(_expressions.emit).join(' | ');
      buffer.writeln('$indent    case $labels:');
      emitBlock(c.body, buffer, '$indent        ');
    }
    if (s.defaultCase != null) {
      buffer.writeln('$indent    case _:');
      emitBlock(s.defaultCase!.body, buffer, '$indent        ');
    }
  }
}
