import '../../../domain/model/export/exported_program.dart';
import '../../../domain/model/export/target_language_id.dart';
import '../../export/target_code_builder.dart';
import '../../export/target_code_header.dart';
import 'rust_shape_statements.dart';
import 'statement_shape.dart';
import 'unit_shape.dart';
import 'view_expression_writer.dart';

final class RustShapeEmitter {
  const RustShapeEmitter();

  ExportedProgram emit(ProgramShape program, ViewExpressionWriter writer) {
    final statements = RustShapeStatements(writer);
    final buffer = TargetCodeBuilder();
    buffer.writeln(targetCodeHeader(TargetLanguageId.rust));
    buffer.writeln();
    for (final shape in program.classes) {
      _struct(shape, buffer);
      buffer.writeln();
      _implementation(shape, buffer, statements);
      buffer.writeln();
    }
    for (final shape in program.subroutines) {
      buffer.writeln('fn ${shape.name}(${_parameters(shape.parameters)}) {');
      statements.emitBlock(shape.body, buffer, '    ');
      buffer.writeln('}');
      buffer.writeln();
    }
    _algorithm(program.algorithm, buffer, statements);
    return buffer.build(TargetLanguageId.rust);
  }

  void _struct(ClassShape shape, TargetCodeBuilder buffer) {
    buffer.writeln('#[derive(Default, Clone)]');
    buffer.writeln('struct ${shape.name} {');
    if (shape.superclass != null) {
      buffer.writeln('    pub base: ${shape.superclass},');
    }
    for (final field in shape.fields) {
      for (final name in field.names) {
        buffer.writeln('    pub $name: ${_type(field.type)},');
      }
    }
    buffer.writeln('}');
  }

  void _implementation(
    ClassShape shape,
    TargetCodeBuilder buffer,
    RustShapeStatements statements,
  ) {
    buffer.writeln('impl ${shape.name} {');
    var previousMember = false;
    for (final member in shape.members) {
      switch (member) {
        case ConstructorShape():
          _constructor(member, buffer, statements);
        case final MethodShape method:
          if (previousMember) buffer.writeln();
          _method(method, buffer, statements);
      }
      previousMember = true;
    }
    if (shape.members.isEmpty) {
      buffer.writeln('    pub fn new() -> Self {');
      buffer.writeln('        Self::default()');
      buffer.writeln('    }');
    }
    buffer.writeln('}');
  }

  void _constructor(
    ConstructorShape shape,
    TargetCodeBuilder buffer,
    RustShapeStatements statements,
  ) {
    buffer.writeln('    pub fn new(${_parameters(shape.parameters)}) -> Self {');
    buffer.writeln('        let mut this = Self::default();');
    statements.emitBlock(shape.body, buffer, '        ');
    buffer.writeln('        this');
    buffer.writeln('    }');
  }

  void _method(
    MethodShape shape,
    TargetCodeBuilder buffer,
    RustShapeStatements statements,
  ) {
    final params = ['&mut self', ...shape.parameters.map(_parameter)].join(', ');
    final returns = shape.returnType;
    final suffix = returns == null ? '' : ' -> ${_type(returns)}';
    buffer.writeln('    pub fn ${shape.name}($params)$suffix {');
    statements.emitBlock(shape.body, buffer, '        ');
    buffer.writeln('    }');
  }

  void _algorithm(
    List<StatementShape>? body,
    TargetCodeBuilder buffer,
    RustShapeStatements statements,
  ) {
    if (body == null) return;
    buffer.writeln('fn main() {');
    statements.emitBlock(body, buffer, '    ');
    buffer.writeln('}');
  }

  String _parameters(List<ParameterShape> parameters) =>
      parameters.map(_parameter).join(', ');

  String _parameter(ParameterShape parameter) =>
      '${parameter.name}: ${_type(parameter.type)}';

  String _type(TypeShape type) => switch (type.primitive) {
    'integer' => 'i64',
    'real' => 'f64',
    'boolean' => 'bool',
    'character' || 'string' => 'String',
    _ => type.text,
  };
}
