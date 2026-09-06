import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/profile/builtin_parameter_kind.dart';
import '../../domain/profile/builtin_signature.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/symbol.dart';
import 'class_hierarchy_provider.dart';
import 'semantic_type.dart';
import 'type_relations.dart';

final class BuiltinCallTypeChecker {
  final ClassHierarchyProvider hierarchy;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;

  const BuiltinCallTypeChecker({
    required this.hierarchy,
    required this.diagnostics,
    required this.severityFor,
  });

  SemanticType check(
    BuiltinFunctionSymbol symbol,
    FunctionCallExpressionNode node,
    SemanticType Function(ExpressionNode) evaluate,
  ) {
    final signature = symbol.signature;
    final argumentTypes = [for (final arg in node.arguments) evaluate(arg)];

    if (argumentTypes.length != signature.parameters.length) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.argumentCountMismatch,
          severity: severityFor(DiagnosticCode.argumentCountMismatch),
          span: node.span,
          arguments: {
            'expected': NumberDiagnosticArgument(signature.parameters.length),
            'found': NumberDiagnosticArgument(argumentTypes.length),
          },
        ),
      );
      return _returnType(signature, argumentTypes);
    }

    for (var i = 0; i < signature.parameters.length; i++) {
      _checkParameter(
        symbol.name,
        signature.parameters[i],
        argumentTypes[i],
        node.arguments[i].span,
      );
    }

    return _returnType(signature, argumentTypes);
  }

  void _checkParameter(
    String functionName,
    BuiltinParameterKind kind,
    SemanticType argumentType,
    Span argumentSpan,
  ) {
    if (argumentType.isError || argumentType.isIndeterminate) return;
    if (_matches(kind, argumentType)) return;
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.incompatibleArgumentType,
        severity: severityFor(DiagnosticCode.incompatibleArgumentType),
        span: argumentSpan,
        arguments: {'lexeme': LexemeDiagnosticArgument(functionName)},
      ),
    );
  }

  bool _matches(BuiltinParameterKind kind, SemanticType type) => switch (kind) {
        BuiltinParameterKind.integer => type.isInteger,
        BuiltinParameterKind.real => TypeRelations.isConvertibleTo(
            type,
            const PrimitiveSemanticType(PrimitiveType.real),
            hierarchy: hierarchy,
          ),
        BuiltinParameterKind.string => type.isString,
        BuiltinParameterKind.character => type.isCharacter,
        BuiltinParameterKind.numeric => type.isNumeric,
        BuiltinParameterKind.anyPrimitive =>
          type.isNumeric || type.isBoolean || type.isCharacter || type.isString,
        BuiltinParameterKind.anyClass => type.isClass,
      };

  SemanticType _returnType(
    BuiltinSignature signature,
    List<SemanticType> argumentTypes,
  ) =>
      switch (signature.returnKind) {
        BuiltinReturnKind.integer =>
          const PrimitiveSemanticType(PrimitiveType.integer),
        BuiltinReturnKind.real =>
          const PrimitiveSemanticType(PrimitiveType.real),
        BuiltinReturnKind.string =>
          const PrimitiveSemanticType(PrimitiveType.string),
        BuiltinReturnKind.character =>
          const PrimitiveSemanticType(PrimitiveType.character),
        BuiltinReturnKind.sameAsFirstArgument => argumentTypes.isNotEmpty
            ? argumentTypes.first
            : const ErrorSemanticType(),
      };
}
