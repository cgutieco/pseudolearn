import '../../export/target_code_builder.dart';
import '../rust_program_view.dart';
import 'statement_shape.dart';
import 'rust_expression_writer.dart';

final class RustShapeStatements {
  final RustExpressionWriter _writer;

  /// Return type of the subroutine being emitted, so a returned integer is
  /// converted when the subroutine returns a real.
  String? returnPrimitive;

  RustShapeStatements(this._writer);

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
    final primitive = shape.primitive;
    final initializer = shape.initializer;
    final (type, empty) = switch (primitive) {
      'integer' => (': i64', '0'),
      'real' => (': f64', '0.0'),
      'boolean' => (': bool', 'false'),
      'string' => (': String', 'String::new()'),
      _ => ('', '0'),
    };
    final value = initializer == null
        ? empty
        : _writer.writeAs(initializer, primitive);
    for (final name in shape.names) {
      buffer.writeln('${indent}let mut $name$type = $value;');
    }
  }

  void _emit(StatementShape shape, TargetCodeBuilder buffer, String indent) {
    switch (shape) {
      case final AssignmentShape s:
        final target = _writer.write(s.target);
        final value = _writer.writeAs(s.value, _writer.types.of(s.target));
        buffer.writeln('$indent$target = $value;');
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
        final returned = s.value;
        final value = returned == null
            ? ''
            : ' ${_writer.writeAs(returned, returnPrimitive)}';
        buffer.writeln('${indent}return$value;');
      case final CallShape s:
        _call(s, buffer, indent);
      case final MethodCallShape s:
        _methodCall(s, buffer, indent);
    }
  }

  void _read(ReadShape s, TargetCodeBuilder buffer, String indent) {
    for (final target in s.targets) {
      final call = _writer.helpers.read(target.primitive);
      buffer.writeln('$indent${_writer.write(target.node)} = $call;');
    }
  }

  void _call(CallShape s, TargetCodeBuilder buffer, String indent) {
    final parameters = _writer.types.signatureOf(s.name)?.parameters;
    final args = [
      for (var index = 0; index < s.arguments.length; index++)
        _writer.writeAs(
          s.arguments[index],
          parameters != null && index < parameters.length
              ? parameters[index]
              : null,
        ),
    ].join(', ');
    buffer.writeln('$indent${s.name}($args);');
  }

  void _methodCall(MethodCallShape s, TargetCodeBuilder buffer, String indent) {
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
    final placeholders = List.filled(s.expressions.length, '{}').join();
    final args = s.expressions.map(_outputArgument).join(', ');
    final macro = s.withoutNewline ? 'print!' : 'println!';
    final full = args.isEmpty ? '""' : '"$placeholders", $args';
    buffer.writeln('$indent$macro($full);');
  }

  String _outputArgument(RustViewNode expression) {
    final text = _writer.write(expression);
    return _writer.types.of(expression) == 'real'
        ? _writer.helpers.realText(text)
        : text;
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
