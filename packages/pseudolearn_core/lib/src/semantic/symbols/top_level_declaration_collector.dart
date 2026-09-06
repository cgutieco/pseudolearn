import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'scope.dart';
import 'symbol.dart';

final class TopLevelDeclarationCollector {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;

  TopLevelDeclarationCollector({
    required this.profile,
    required this.diagnostics,
  });

  void collect({
    required SourceUnitNode sourceUnit,
    required SourceUnitScope rootScope,
    required Map<String, SubroutineSymbol> subroutines,
    required Map<String, ClassSymbol> classes,
  }) {
    for (final declaration in sourceUnit.declarations) {
      switch (declaration) {
        case SubroutineDeclarationNode():
          _collectSubroutine(declaration, rootScope, subroutines);
        case ClassNode():
          _collectClass(declaration, rootScope, classes);
        default:
          break;
      }
    }
  }

  void _collectSubroutine(
    SubroutineDeclarationNode node,
    SourceUnitScope rootScope,
    Map<String, SubroutineSymbol> subroutines,
  ) {
    final existing = rootScope.lookupLocal(node.name);
    if (existing != null) {
      _reportDuplicateTopLevel(
        name: node.name,
        span: node.nameSpan,
        existing: existing,
        isNewSubroutine: true,
      );
      return;
    }

    final parameterSymbols = _buildParameters(node);
    final symbol = SubroutineSymbol(
      name: node.name,
      span: node.nameSpan,
      parameters: parameterSymbols,
      returnType: node.returnType,
      customReturnType: node.customReturnType,
      returnTypeSpan: node.returnTypeSpan,
      declarationNode: node,
    );

    rootScope.define(symbol);
    subroutines[node.name] = symbol;
  }

  void _collectClass(
    ClassNode node,
    SourceUnitScope rootScope,
    Map<String, ClassSymbol> classes,
  ) {
    final existing = rootScope.lookupLocal(node.name);
    if (existing != null) {
      _reportDuplicateTopLevel(
        name: node.name,
        span: node.nameSpan,
        existing: existing,
        isNewSubroutine: false,
      );
      return;
    }

    final symbol = ClassSymbol(
      name: node.name,
      span: node.nameSpan,
      superclassName: node.superclassName,
      superclassSpan: node.superclassSpan,
      declarationNode: node,
    );

    rootScope.define(symbol);
    classes[node.name] = symbol;
  }

  List<ParameterSymbol> _buildParameters(SubroutineDeclarationNode node) {
    final result = <ParameterSymbol>[];
    final seen = <String, Span>{};

    for (final param in node.parameters) {
      if (seen.containsKey(param.name)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.duplicateParameterName,
            severity:
                profile.severityPolicy[DiagnosticCode.duplicateParameterName] ??
                    profile.severityPolicy.values.first,
            span: param.span,
            relatedSpans: [seen[param.name]!],
            arguments: {'lexeme': LexemeDiagnosticArgument(param.name)},
          ),
        );
      } else {
        seen[param.name] = param.span;
        result.add(
          ParameterSymbol(
            name: param.name,
            span: param.span,
            primitiveType: param.type,
            customTypeName: param.customTypeName,
            dimensionCount: param.dimensionCount,
            passingMode: param.passingMode,
          ),
        );
      }
    }
    return result;
  }

  void _reportDuplicateTopLevel({
    required String name,
    required Span span,
    required Symbol existing,
    required bool isNewSubroutine,
  }) {
    final isBothSubroutine = isNewSubroutine && existing is SubroutineSymbol;
    final isBothClass = !isNewSubroutine && existing is ClassSymbol;

    final code = isBothSubroutine
        ? DiagnosticCode.duplicateSubroutine
        : (isBothClass
            ? DiagnosticCode.duplicateClass
            : DiagnosticCode.classAndSubroutineSameName);

    diagnostics.add(
      Diagnostic(
        code: code,
        severity:
            profile.severityPolicy[code] ?? profile.severityPolicy.values.first,
        span: span,
        relatedSpans: [existing.span],
        arguments: {'lexeme': LexemeDiagnosticArgument(name)},
      ),
    );
  }
}
