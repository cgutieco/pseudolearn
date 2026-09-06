import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'symbol.dart';

final class ClassMemberValidator {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;

  ClassMemberValidator({
    required this.profile,
    required this.diagnostics,
  });

  void collectAndValidateMembers(ClassSymbol classSymbol) {
    for (final member in classSymbol.declarationNode.members) {
      switch (member) {
        case ClassFieldNode():
          _collectFieldMember(classSymbol, member);
        case MethodDeclarationNode():
          _collectMethodMember(classSymbol, member);
        case ConstructorDeclarationNode():
          _collectConstructorMember(classSymbol, member);
      }
    }
  }

  void _collectFieldMember(ClassSymbol classSymbol, ClassFieldNode fieldNode) {
    final decl = fieldNode.declaration;
    if (decl is VariableDeclarationNode) {
      for (final variable in decl.variables) {
        _registerField(
          classSymbol: classSymbol,
          name: variable.name,
          span: variable.span,
          fieldNode: fieldNode,
          type: decl.type,
          customTypeName: decl.customTypeName,
          dimensions: 0,
        );
      }
    } else if (decl is DimensionStatementNode) {
      for (final array in decl.arrays) {
        _registerField(
          classSymbol: classSymbol,
          name: array.name,
          span: array.span,
          fieldNode: fieldNode,
          type: decl.elementType,
          customTypeName: decl.customElementTypeName,
          dimensions: array.dimensions.length,
        );
      }
    }
  }

  void _registerField({
    required ClassSymbol classSymbol,
    required String name,
    required Span span,
    required ClassFieldNode fieldNode,
    required PrimitiveType? type,
    required String? customTypeName,
    required int dimensions,
  }) {
    if (classSymbol.fields.containsKey(name) ||
        classSymbol.methods.containsKey(name)) {
      _report(
        DiagnosticCode.duplicateMember,
        span,
        {'lexeme': LexemeDiagnosticArgument(name)},
      );
      return;
    }

    final inheritedField = classSymbol.superclass?.findField(name);
    if (inheritedField != null) {
      _report(
        DiagnosticCode.inheritedAttributeShadowed,
        span,
        {'lexeme': LexemeDiagnosticArgument(name)},
        relatedSpans: [inheritedField.span],
      );
    }

    classSymbol.fields[name] = FieldSymbol(
      name: name,
      span: span,
      visibility: fieldNode.visibility,
      primitiveType: type,
      customTypeName: customTypeName,
      dimensionCount: dimensions,
    );
  }

  void _collectMethodMember(
    ClassSymbol classSymbol,
    MethodDeclarationNode node,
  ) {
    if (classSymbol.fields.containsKey(node.name) ||
        classSymbol.methods.containsKey(node.name)) {
      _report(
        DiagnosticCode.duplicateMember,
        node.nameSpan,
        {'lexeme': LexemeDiagnosticArgument(node.name)},
      );
      return;
    }

    final params = _buildParameters(node.parameters);
    final methodSymbol = MethodSymbol(
      name: node.name,
      span: node.nameSpan,
      visibility: node.visibility,
      parameters: params,
      returnType: node.returnType,
      customReturnType: node.customReturnType,
      returnTypeSpan: node.returnTypeSpan,
      declarationNode: node,
    );

    final inheritedMethod = classSymbol.superclass?.findMethod(node.name);
    if (inheritedMethod != null &&
        !_isMatchingSignature(methodSymbol, inheritedMethod)) {
      _report(
        DiagnosticCode.incompatibleMethodOverride,
        node.nameSpan,
        {'lexeme': LexemeDiagnosticArgument(node.name)},
        relatedSpans: [inheritedMethod.span],
      );
    }

    classSymbol.methods[node.name] = methodSymbol;
  }

  List<ParameterSymbol> _buildParameters(List<ParameterNode> parameters) {
    final result = <ParameterSymbol>[];
    final seen = <String, Span>{};
    for (final p in parameters) {
      if (seen.containsKey(p.name)) {
        _report(
          DiagnosticCode.duplicateParameterName,
          p.span,
          {'lexeme': LexemeDiagnosticArgument(p.name)},
          relatedSpans: [seen[p.name]!],
        );
      } else {
        seen[p.name] = p.span;
        result.add(
          ParameterSymbol(
            name: p.name,
            span: p.span,
            primitiveType: p.type,
            customTypeName: p.customTypeName,
            dimensionCount: p.dimensionCount,
            passingMode: p.passingMode,
          ),
        );
      }
    }
    return result;
  }

  bool _isMatchingSignature(MethodSymbol child, MethodSymbol parent) {
    if (child.parameters.length != parent.parameters.length) return false;
    if (child.returnType != parent.returnType) return false;
    if (child.customReturnType != parent.customReturnType) return false;

    for (var i = 0; i < child.parameters.length; i++) {
      final cp = child.parameters[i];
      final pp = parent.parameters[i];
      if (cp.primitiveType != pp.primitiveType) return false;
      if (cp.customTypeName != pp.customTypeName) return false;
      if (cp.dimensionCount != pp.dimensionCount) return false;
      if (cp.passingMode != pp.passingMode) return false;
    }
    return true;
  }

  void _collectConstructorMember(
    ClassSymbol classSymbol,
    ConstructorDeclarationNode node,
  ) {
    if (classSymbol.constructor != null) {
      _report(DiagnosticCode.duplicateConstructor, node.span, const {});
      return;
    }

    final params = _buildParameters(node.parameters);
    classSymbol.constructor = ConstructorSymbol(
      span: node.span,
      parameters: params,
      declarationNode: node,
    );
  }

  void _report(
    DiagnosticCode code,
    Span span,
    Map<String, DiagnosticArgument> arguments, {
    List<Span>? relatedSpans,
  }) {
    diagnostics.add(
      Diagnostic(
        code: code,
        severity:
            profile.severityPolicy[code] ?? profile.severityPolicy.values.first,
        span: span,
        relatedSpans: relatedSpans ?? const [],
        arguments: arguments,
      ),
    );
  }
}
