import '../../export/target_code_builder.dart';
import 'statement_shape.dart';
import 'view_expression_writer.dart';

final class PythonShapeStatements {
  final ViewExpressionWriter _writer;

  const PythonShapeStatements(this._writer);

  void emitBlock(
    List<StatementShape> body,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    if (body.isEmpty) {
      buffer.writeln('${indent}pass');
      return;
    }
    for (final shape in body) {
      buffer.attributedTo(shape.origin, () => _emit(shape, buffer, indent));
    }
  }

  void _emit(StatementShape shape, TargetCodeBuilder buffer, String indent) {
    switch (shape) {
      case final AssignmentShape s:
        final target = _writer.write(s.target);
        buffer.writeln('$indent$target = ${_writer.write(s.value)}');
      case final DeclarationShape s:
        for (final name in s.names) {
          buffer.writeln('$indent$name = None');
        }
      case final DimensionShape s:
        _dimension(s, buffer, indent);
      case final WriteShape s:
        _write(s, buffer, indent);
      case final ReadShape s:
        for (final target in s.targets) {
          buffer.writeln('$indent${_writer.write(target)} = input()');
        }
      case final IfShape s:
        _if(s, buffer, indent);
      case final WhileShape s:
        buffer.writeln('${indent}while ${_writer.write(s.condition)}:');
        emitBlock(s.body, buffer, '$indent    ');
      case final RepeatShape s:
        _repeat(s, buffer, indent);
      case final ForShape s:
        _for(s, buffer, indent);
      case final SwitchShape s:
        _switch(s, buffer, indent);
      case final ReturnShape s:
        final value = s.value == null ? '' : ' ${_writer.write(s.value!)}';
        buffer.writeln('${indent}return$value');
      case final CallShape s:
        final args = s.arguments.map(_writer.write).join(', ');
        buffer.writeln('$indent${s.name}($args)');
      case final MethodCallShape s:
        _methodCall(s, buffer, indent);
      case UnsupportedShape():
        buffer.writeln('$indent# Unsupported statement');
    }
  }

  void _methodCall(
    MethodCallShape s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final args = s.arguments.map(_writer.write).join(', ');
    if (s.isSuperConstructor) {
      buffer.writeln('${indent}super().__init__($args)');
      return;
    }
    final target = _writer.writeChain(s.target, s.call);
    buffer.writeln('$indent$target.${s.methodName}($args)');
  }

  void _dimension(DimensionShape s, TargetCodeBuilder buffer, String indent) {
    for (final array in s.arrays) {
      final sizes = array.dimensions.map(_writer.write).toList();
      final text = switch (sizes.length) {
        1 => '${array.name} = [0] * (${sizes.first})',
        2 =>
          '${array.name} = [[0] * (${sizes[1]}) for _ in range(${sizes[0]})]',
        _ => '${array.name} = []',
      };
      buffer.writeln('$indent$text');
    }
  }

  void _write(WriteShape s, TargetCodeBuilder buffer, String indent) {
    final args = s.expressions.map(_writer.write).join(', ');
    final end = s.withoutNewline ? ', end=""' : '';
    buffer.writeln('${indent}print($args$end)');
  }

  void _if(IfShape s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('${indent}if ${_writer.write(s.condition)}:');
    emitBlock(s.thenBody, buffer, '$indent    ');
    if (s.elseBody.isEmpty) return;
    buffer.writeln('${indent}else:');
    emitBlock(s.elseBody, buffer, '$indent    ');
  }

  void _repeat(RepeatShape s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('${indent}while True:');
    for (final shape in s.body) {
      buffer.attributedTo(shape.origin, () => _emit(shape, buffer, '$indent    '));
    }
    buffer.writeln('$indent    if ${_writer.write(s.condition)}:');
    buffer.writeln('$indent        break');
  }

  void _for(ForShape s, TargetCodeBuilder buffer, String indent) {
    final from = _writer.write(s.from);
    final to = _writer.write(s.to);
    final step = s.step;
    final adjusted = step != null && _writer.isNegation(step)
        ? '$to - 1'
        : '$to + 1';
    final stepText = step == null ? '' : ', ${_writer.write(step)}';
    buffer.writeln('${indent}for ${s.variable} in range($from, $adjusted$stepText):');
    emitBlock(s.body, buffer, '$indent    ');
  }

  void _switch(SwitchShape s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('${indent}match ${_writer.write(s.selector)}:');
    for (final branch in s.cases) {
      final labels = branch.labels.map(_writer.write).join(' | ');
      buffer.writeln('$indent    case $labels:');
      emitBlock(branch.body, buffer, '$indent        ');
    }
    final defaultBody = s.defaultBody;
    if (defaultBody == null) return;
    buffer.writeln('$indent    case _:');
    emitBlock(defaultBody, buffer, '$indent        ');
  }
}
