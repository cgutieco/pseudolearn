import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/program_node_id.dart';
import 'rust_expression_emitter.dart';
import 'target_code_builder.dart';

final class RustStatementEmitter {
  final RustExpressionEmitter _expressions;

  const RustStatementEmitter([
    RustExpressionEmitter expressions = const RustExpressionEmitter(),
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
        final target = _expressions.emit(s.target);
        final val = _expressions.emit(s.value);
        buffer.writeln('$indent$target = $val;');
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
        _emitCall(s, buffer, indent);
      case final MethodCallStatementNode s:
        _emitMethodCall(s, buffer, indent);
      default:
        buffer.writeln('$indent// unsupported statement');
    }
  }

  void _emitCall(CallStatementNode s, TargetCodeBuilder buffer, String indent) {
    final args = s.arguments.map(_expressions.emit).join(', ');
    buffer.writeln('$indent${s.name}($args);');
  }

  void _emitMethodCall(
    MethodCallStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final args = s.arguments.map(_expressions.emit).join(', ');
    if (isSuperConstructorCall(s)) {
      buffer.writeln('$indent// Super.Constructor($args);');
      return;
    }
    final target = _expressions.emit(s.target);
    buffer.writeln('$indent$target.${s.methodName}($args);');
  }

  void _emitVarDecl(
    VariableDeclarationNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    for (final decl in s.variables) {
      buffer.writeln('$indent' 'let mut ${decl.name} = 0;');
    }
  }

  void _emitWrite(
    WriteStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final placeholders = List.filled(s.expressions.length, '{}').join(' ');
    final args = s.expressions.map(_expressions.emit).join(', ');
    final macroName = s.withoutNewline ? 'print!' : 'println!';
    final fullArgs = args.isEmpty ? '""' : '"$placeholders", $args';
    buffer.writeln('$indent$macroName($fullArgs);');
  }

  void _emitRead(ReadStatementNode s, TargetCodeBuilder buffer, String indent) {
    for (final target in s.targets) {
      buffer.writeln('$indent// read input into ${_expressions.emit(target)}');
    }
  }

  void _emitReturn(
    ReturnStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final val = s.value != null ? ' ${_expressions.emit(s.value!)}' : '';
    buffer.writeln('$indent' 'return$val;');
  }

  void _emitDimension(
    DimensionStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    for (final array in s.arrays) {
      if (array.dimensions.length == 1) {
        final size = _expressions.emit(array.dimensions.first);
        buffer.writeln(
          '$indent' 'let mut ${array.name} = vec![0; ($size) as usize];',
        );
      } else if (array.dimensions.length == 2) {
        final rows = _expressions.emit(array.dimensions[0]);
        final cols = _expressions.emit(array.dimensions[1]);
        buffer.writeln(
          '$indent'
          'let mut ${array.name} = vec![vec![0; ($cols) as usize]; ($rows) as usize];',
        );
      } else {
        buffer.writeln('$indent' 'let mut ${array.name} = Vec::new();');
      }
    }
  }

  void _emitIf(IfStatementNode s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('$indent' 'if ${_expressions.emit(s.condition)} {');
    emitBlock(s.thenBody, buffer, '$indent    ');
    if (s.elseBody != null && s.elseBody!.isNotEmpty) {
      buffer.writeln('$indent} else {');
      emitBlock(s.elseBody!, buffer, '$indent    ');
    }
    buffer.writeln('$indent}');
  }

  void _emitWhile(WhileStatementNode s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('$indent' 'while ${_expressions.emit(s.condition)} {');
    emitBlock(s.body, buffer, '$indent    ');
    buffer.writeln('$indent}');
  }

  void _emitRepeatUntil(
    RepeatUntilStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    buffer.writeln('$indent' 'loop {');
    for (final stmt in s.body) {
      emitStatement(stmt, buffer, indent: '$indent    ');
    }
    buffer.writeln('$indent    if ${_expressions.emit(s.condition)} {');
    buffer.writeln('$indent        break;');
    buffer.writeln('$indent    }');
    buffer.writeln('$indent}');
  }

  void _emitFor(ForStatementNode s, TargetCodeBuilder buffer, String indent) {
    final from = _expressions.emit(s.from);
    final to = _expressions.emit(s.to);
    if (s.step == null) {
      buffer.writeln('$indent' 'for ${s.variable.name} in $from..=$to {');
    } else {
      _emitCustomStepFor(s, buffer, indent);
    }
    emitBlock(s.body, buffer, '$indent    ');
    buffer.writeln('$indent}');
  }

  void _emitCustomStepFor(
    ForStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final from = _expressions.emit(s.from);
    final to = _expressions.emit(s.to);
    final isNeg = s.step is UnaryExpressionNode &&
        (s.step as UnaryExpressionNode).operator == UnaryOperator.negate;
    if (isNeg) {
      buffer.writeln('$indent' 'for ${s.variable.name} in ($to..=$from).rev() {');
    } else {
      final stepExpr = _expressions.emit(s.step!);
      buffer.writeln(
        '$indent'
        'for ${s.variable.name} in ($from..=$to).step_by(($stepExpr) as usize) {',
      );
    }
  }

  void _emitSwitch(
    SwitchStatementNode s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    buffer.writeln('$indent' 'match ${_expressions.emit(s.selector)} {');
    for (final c in s.cases) {
      final labels = c.labels.map(_expressions.emit).join(' | ');
      buffer.writeln('$indent    $labels => {');
      emitBlock(c.body, buffer, '$indent        ');
      buffer.writeln('$indent    }');
    }
    if (s.defaultCase != null) {
      buffer.writeln('$indent    _ => {');
      emitBlock(s.defaultCase!.body, buffer, '$indent        ');
      buffer.writeln('$indent    }');
    }
    buffer.writeln('$indent}');
  }
}
