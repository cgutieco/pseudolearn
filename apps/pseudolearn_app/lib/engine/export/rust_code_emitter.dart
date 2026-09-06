import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/export/exported_program.dart';
import '../../domain/model/export/target_language_id.dart';
import 'rust_expression_emitter.dart';
import 'rust_statement_emitter.dart';
import 'target_code_builder.dart';
import 'target_code_header.dart';

final class RustCodeEmitter {
  const RustCodeEmitter();

  ExportedProgram emit(
    SourceUnitNode unit,
    TargetLanguageId targetLanguage, {
    ResolutionResult? resolution,
  }) {
    final expressions = RustExpressionEmitter(resolution);
    final statements = RustStatementEmitter(expressions);
    final buffer = TargetCodeBuilder();

    buffer.writeln(targetCodeHeader(targetLanguage));
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

  void _emitClass(
    ClassNode cls,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements,
  ) {
    _emitStruct(cls, buffer);
    buffer.writeln();
    _emitImpl(cls, buffer, statements);
  }

  void _emitStruct(ClassNode cls, TargetCodeBuilder buffer) {
    buffer.writeln('#[derive(Default, Clone)]');
    buffer.writeln('struct ${cls.name} {');
    if (cls.superclassName != null) {
      buffer.writeln('    pub base: ${cls.superclassName},');
    }
    for (final member in cls.members) {
      if (member is! ClassFieldNode) continue;
      if (member.declaration is! VariableDeclarationNode) continue;
      final decl = member.declaration as VariableDeclarationNode;
      final typeStr = decl.customTypeName ?? _rustType(decl.type);
      for (final v in decl.variables) {
        buffer.writeln('    pub ${v.name}: $typeStr,');
      }
    }
    buffer.writeln('}');
  }

  void _emitImpl(
    ClassNode cls,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements,
  ) {
    buffer.writeln('impl ${cls.name} {');
    var hasMethod = false;
    for (final member in cls.members) {
      final emitted = _emitClassMember(
        member,
        buffer,
        statements,
        hasPreviousMethod: hasMethod,
      );
      hasMethod = hasMethod || emitted;
    }
    if (!hasMethod) {
      buffer.writeln('    pub fn new() -> Self {');
      buffer.writeln('        Self::default()');
      buffer.writeln('    }');
    }
    buffer.writeln('}');
  }

  bool _emitClassMember(
    ClassMemberNode member,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements, {
    required bool hasPreviousMethod,
  }) {
    if (member is ConstructorDeclarationNode) {
      _emitConstructor(member, buffer, statements);
      return true;
    }
    if (member is MethodDeclarationNode) {
      if (hasPreviousMethod) buffer.writeln();
      _emitMethod(member, buffer, statements);
      return true;
    }
    return false;
  }

  void _emitConstructor(
    ConstructorDeclarationNode ctor,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements,
  ) {
    final params = ctor.parameters.map(_formatParam).join(', ');
    buffer.writeln('    pub fn new($params) -> Self {');
    buffer.writeln('        let mut this = Self::default();');
    statements.emitBlock(ctor.body, buffer, '        ');
    buffer.writeln('        this');
    buffer.writeln('    }');
  }

  void _emitMethod(
    MethodDeclarationNode method,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements,
  ) {
    final params =
        ['&mut self', ...method.parameters.map(_formatParam)].join(', ');
    final ret = method.returnType != null || method.customReturnType != null
        ? ' -> ${_rustReturnType(method)}'
        : '';
    buffer.writeln('    pub fn ${method.name}($params)$ret {');
    statements.emitBlock(method.body, buffer, '        ');
    buffer.writeln('    }');
  }

  void _emitSubroutine(
    SubroutineDeclarationNode sub,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements,
  ) {
    final params = sub.parameters.map(_formatParam).join(', ');
    buffer.writeln('fn ${sub.name}($params) {');
    statements.emitBlock(sub.body, buffer, '    ');
    buffer.writeln('}');
  }

  void _emitAlgorithm(
    AlgorithmNode algo,
    TargetCodeBuilder buffer,
    RustStatementEmitter statements,
  ) {
    buffer.writeln('fn main() {');
    statements.emitBlock(algo.body, buffer, '    ');
    buffer.writeln('}');
  }

  static String _formatParam(ParameterNode param) {
    final typeStr = param.customTypeName ?? _rustType(param.type);
    return '${param.name}: $typeStr';
  }

  static String _rustType(PrimitiveType? type) {
    return switch (type) {
      PrimitiveType.integer => 'i64',
      PrimitiveType.real => 'f64',
      PrimitiveType.boolean => 'bool',
      PrimitiveType.character || PrimitiveType.string => 'String',
      null => 'i64',
    };
  }

  static String _rustReturnType(MethodDeclarationNode method) {
    if (method.customReturnType != null) return method.customReturnType!;
    return _rustType(method.returnType);
  }
}
