import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/export/exported_program.dart';
import '../../domain/model/export/target_language_id.dart';
import 'python_expression_emitter.dart';
import 'python_statement_emitter.dart';
import 'target_code_builder.dart';
import 'target_code_header.dart';

final class PythonCodeEmitter {
  const PythonCodeEmitter();

  ExportedProgram emit(
    SourceUnitNode unit,
    TargetLanguageId targetLanguage, {
    ResolutionResult? resolution,
  }) {
    final expressions = PythonExpressionEmitter(resolution);
    final statements = PythonStatementEmitter(expressions);
    final buffer = TargetCodeBuilder();

    buffer.writeln(targetCodeHeader(targetLanguage));
    _emitImports(buffer, resolution);
    buffer.writeln();

    for (final cls in unit.classes) {
      _emitClass(cls, buffer, statements);
      buffer.writeln();
    }

    for (final subroutine in unit.subroutines) {
      _emitSubroutine(subroutine, buffer, statements);
      buffer.writeln();
    }

    if (unit.algorithm != null) {
      _emitAlgorithm(unit.algorithm!, buffer, statements);
    }

    return buffer.build(targetLanguage);
  }

  void _emitImports(TargetCodeBuilder buffer, ResolutionResult? resolution) {
    if (resolution == null) return;
    var hasMath = false;
    var hasRandom = false;

    for (final symbol in resolution.resolvedSymbols.values) {
      if (symbol is! BuiltinFunctionSymbol) continue;
      if (symbol.function == BuiltinFunction.random) {
        hasRandom = true;
      } else if (_isMathFunction(symbol.function)) {
        hasMath = true;
      }
    }

    if (hasMath) buffer.writeln('import math');
    if (hasRandom) buffer.writeln('import random');
  }

  bool _isMathFunction(BuiltinFunction fn) => switch (fn) {
        BuiltinFunction.squareRoot ||
        BuiltinFunction.naturalLogarithm ||
        BuiltinFunction.exponential ||
        BuiltinFunction.sine ||
        BuiltinFunction.cosine ||
        BuiltinFunction.arcTangent ||
        BuiltinFunction.truncate =>
          true,
        _ => false,
      };

  void _emitClass(
    ClassNode cls,
    TargetCodeBuilder buffer,
    PythonStatementEmitter statements,
  ) {
    final header = cls.superclassName != null
        ? 'class ${cls.name}(${cls.superclassName}):'
        : 'class ${cls.name}:';
    buffer.writeln(header);

    var hasMember = false;
    for (final member in cls.members) {
      if (member is ConstructorDeclarationNode) {
        _emitConstructor(member, buffer, statements);
        hasMember = true;
      } else if (member is MethodDeclarationNode) {
        _emitMethod(member, buffer, statements);
        hasMember = true;
      }
    }

    if (!hasMember) {
      buffer.writeln('    pass');
    }
  }

  void _emitConstructor(
    ConstructorDeclarationNode ctor,
    TargetCodeBuilder buffer,
    PythonStatementEmitter statements,
  ) {
    final params = ['self', ...ctor.parameters.map((p) => p.name)].join(', ');
    buffer.writeln('    def __init__($params):');
    statements.emitBlock(ctor.body, buffer, '        ');
  }

  void _emitMethod(
    MethodDeclarationNode method,
    TargetCodeBuilder buffer,
    PythonStatementEmitter statements,
  ) {
    final params =
        ['self', ...method.parameters.map((p) => p.name)].join(', ');
    buffer.writeln('    def ${method.name}($params):');
    statements.emitBlock(method.body, buffer, '        ');
  }

  void _emitSubroutine(
    SubroutineDeclarationNode sub,
    TargetCodeBuilder buffer,
    PythonStatementEmitter statements,
  ) {
    final params = sub.parameters.map((p) => p.name).join(', ');
    buffer.writeln('def ${sub.name}($params):');
    statements.emitBlock(sub.body, buffer, '    ');
  }

  void _emitAlgorithm(
    AlgorithmNode algo,
    TargetCodeBuilder buffer,
    PythonStatementEmitter statements,
  ) {
    buffer.writeln('def main():');
    statements.emitBlock(algo.body, buffer, '    ');
    buffer.writeln();
    buffer.writeln('if __name__ == "__main__":');
    buffer.writeln('    main()');
  }
}
