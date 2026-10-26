import '../../export/target_code_builder.dart';
import 'statement_shape.dart';
import 'view_expression_writer.dart';

final class RustShapeStatements {
  final ViewExpressionWriter _writer;

  const RustShapeStatements(this._writer);

  void emitBlock(
    List<StatementShape> body,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    for (final shape in body) {
      buffer.attributedTo(shape.origin, () => _emit(shape, buffer, indent));
    }
  }

  void _declaration(
    DeclarationShape shape,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final value = shape.initializer == null
        ? '0'
        : _writer.write(shape.initializer!);
    for (final name in shape.names) {
      buffer.writeln('${indent}let mut $name = $value;');
    }
  }

  void _emit(StatementShape shape, TargetCodeBuilder buffer, String indent) {
    switch (shape) {
      case final AssignmentShape s:
        final target = _writer.write(s.target);
        buffer.writeln('$indent$target = ${_writer.write(s.value)};');
      case final DeclarationShape s:
        _declaration(s, buffer, indent);
      case final DimensionShape s:
        _dimension(s, buffer, indent);
      case final WriteShape s:
        _write(s, buffer, indent);
      case final ReadShape s:
        _read(s, buffer, indent);
      case final IfShape s:
        _if(s, buffer, indent);
      case final WhileShape s:
        buffer.writeln('${indent}while ${_writer.write(s.condition)} {');
        emitBlock(s.body, buffer, '$indent    ');
        buffer.writeln('$indent}');
      case final RepeatShape s:
        _repeat(s, buffer, indent);
      case final ForShape s:
        _for(s, buffer, indent);
      case final SwitchShape s:
        _switch(s, buffer, indent);
      case final ReturnShape s:
        final value = s.value == null ? '' : ' ${_writer.write(s.value!)}';
        buffer.writeln('${indent}return$value;');
      case final CallShape s:
        _call(s, buffer, indent);
      case final MethodCallShape s:
        _methodCall(s, buffer, indent);
      case UnsupportedShape():
        buffer.writeln('$indent// unsupported statement');
    }
  }

  void _read(ReadShape s, TargetCodeBuilder buffer, String indent) {
    for (final target in s.targets) {
      buffer.writeln('$indent// read input into ${_writer.write(target)}');
    }
  }

  void _call(CallShape s, TargetCodeBuilder buffer, String indent) {
    final args = s.arguments.map(_writer.write).join(', ');
    buffer.writeln('$indent${s.name}($args);');
  }

  void _methodCall(
    MethodCallShape s,
    TargetCodeBuilder buffer,
    String indent,
  ) {
    final args = s.arguments.map(_writer.write).join(', ');
    if (s.isSuperConstructor) {
      buffer.writeln('$indent// Super.Constructor($args);');
      return;
    }
    final target = _writer.writeChain(s.target, s.call);
    buffer.writeln('$indent$target.${s.methodName}($args);');
  }

  void _dimension(DimensionShape s, TargetCodeBuilder buffer, String indent) {
    for (final array in s.arrays) {
      final sizes = array.dimensions.map(_writer.write).toList();
      final text = switch (sizes.length) {
        1 => 'let mut ${array.name} = vec![0; (${sizes.first}) as usize];',
        2 =>
          'let mut ${array.name} = vec![vec![0; (${sizes[1]}) as usize]; (${sizes[0]}) as usize];',
        _ => 'let mut ${array.name} = Vec::new();',
      };
      buffer.writeln('$indent$text');
    }
  }

  void _write(WriteShape s, TargetCodeBuilder buffer, String indent) {
    final placeholders = List.filled(s.expressions.length, '{}').join(' ');
    final args = s.expressions.map(_writer.write).join(', ');
    final macro = s.withoutNewline ? 'print!' : 'println!';
    final full = args.isEmpty ? '""' : '"$placeholders", $args';
    buffer.writeln('$indent$macro($full);');
  }

  void _if(IfShape s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('${indent}if ${_writer.write(s.condition)} {');
    emitBlock(s.thenBody, buffer, '$indent    ');
    if (s.elseBody.isNotEmpty) {
      buffer.writeln('$indent} else {');
      emitBlock(s.elseBody, buffer, '$indent    ');
    }
    buffer.writeln('$indent}');
  }

  void _repeat(RepeatShape s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('${indent}loop {');
    emitBlock(s.body, buffer, '$indent    ');
    buffer.writeln('$indent    if ${_writer.write(s.condition)} {');
    buffer.writeln('$indent        break;');
    buffer.writeln('$indent    }');
    buffer.writeln('$indent}');
  }

  void _for(ForShape s, TargetCodeBuilder buffer, String indent) {
    final from = _writer.write(s.from);
    final to = _writer.write(s.to);
    final step = s.step;
    final header = switch (step) {
      null => '${s.variable} in $from..=$to',
      _ when _writer.isNegation(step) => '${s.variable} in ($to..=$from).rev()',
      _ =>
        '${s.variable} in ($from..=$to).step_by((${_writer.write(step)}) as usize)',
    };
    buffer.writeln('${indent}for $header {');
    emitBlock(s.body, buffer, '$indent    ');
    buffer.writeln('$indent}');
  }

  void _switch(SwitchShape s, TargetCodeBuilder buffer, String indent) {
    buffer.writeln('${indent}match ${_writer.write(s.selector)} {');
    for (final branch in s.cases) {
      final labels = branch.labels.map(_writer.write).join(' | ');
      buffer.writeln('$indent    $labels => {');
      emitBlock(branch.body, buffer, '$indent        ');
      buffer.writeln('$indent    }');
    }
    final defaultBody = s.defaultBody;
    if (defaultBody != null) {
      buffer.writeln('$indent    _ => {');
      emitBlock(defaultBody, buffer, '$indent        ');
      buffer.writeln('$indent    }');
    }
    buffer.writeln('$indent}');
  }
}
