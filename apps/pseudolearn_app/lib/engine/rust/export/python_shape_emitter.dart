import '../../../domain/model/export/exported_program.dart';
import '../../../domain/model/export/target_language_id.dart';
import '../../export/target_code_builder.dart';
import '../../export/target_code_header.dart';
import 'python_expression_rules.dart';
import 'python_shape_statements.dart';
import 'statement_shape.dart';
import 'unit_shape.dart';
import 'view_expression_writer.dart';

final class PythonShapeEmitter {
  const PythonShapeEmitter();

  ExportedProgram emit(ProgramShape program, ViewExpressionWriter writer) {
    final statements = PythonShapeStatements(writer);
    final buffer = TargetCodeBuilder();
    buffer.writeln(targetCodeHeader(TargetLanguageId.python));
    _imports(program.builtins, buffer);
    buffer.writeln();
    for (final shape in program.classes) {
      _class(shape, buffer, statements);
      buffer.writeln();
    }
    for (final shape in program.subroutines) {
      final params = shape.parameters.map((p) => p.name).join(', ');
      buffer.writeln('def ${shape.name}($params):');
      statements.emitBlock(shape.body, buffer, '    ');
      buffer.writeln();
    }
    final algorithm = program.algorithm;
    if (algorithm != null) _algorithm(algorithm, buffer, statements);
    return buffer.build(TargetLanguageId.python);
  }

  void _imports(Set<String> builtins, TargetCodeBuilder buffer) {
    if (builtins.any(mathBuiltins.contains)) buffer.writeln('import math');
    if (builtins.contains('random')) buffer.writeln('import random');
  }

  void _class(
    ClassShape shape,
    TargetCodeBuilder buffer,
    PythonShapeStatements statements,
  ) {
    final base = shape.superclass == null ? '' : '(${shape.superclass})';
    buffer.writeln('class ${shape.name}$base:');
    for (final member in shape.members) {
      final (name, params) = switch (member) {
        ConstructorShape() => ('__init__', member.parameters),
        final MethodShape method => (method.name, method.parameters),
      };
      final names = ['self', ...params.map((p) => p.name)].join(', ');
      buffer.writeln('    def $name($names):');
      statements.emitBlock(member.body, buffer, '        ');
    }
    if (shape.members.isEmpty) buffer.writeln('    pass');
  }

  void _algorithm(
    List<StatementShape> body,
    TargetCodeBuilder buffer,
    PythonShapeStatements statements,
  ) {
    buffer.writeln('def main():');
    statements.emitBlock(body, buffer, '    ');
    buffer.writeln();
    buffer.writeln('if __name__ == "__main__":');
    buffer.writeln('    main()');
  }
}
