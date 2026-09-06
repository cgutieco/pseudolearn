import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../symbols/symbol.dart';
import 'class_hierarchy_provider.dart';
import 'semantic_type.dart';
import 'type_relations.dart';

final class VariableTypeState {
  SemanticType type;
  final bool isExplicitlyDeclared;
  bool isWidened;
  bool isInitialized;

  VariableTypeState({
    required this.type,
    required this.isExplicitlyDeclared,
    this.isWidened = false,
    this.isInitialized = false,
  });
}

final class TypeEnvironment {
  final Map<Symbol, VariableTypeState> _variables = {};
  final ClassHierarchyProvider? hierarchy;
  final List<Diagnostic> _diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;

  TypeEnvironment({
    this.hierarchy,
    List<Diagnostic>? diagnostics,
    required this.severityFor,
  }) : _diagnostics = diagnostics ?? [];

  List<Diagnostic> get diagnostics => _diagnostics;

  void declare(
    Symbol symbol,
    SemanticType type, {
    bool isExplicit = true,
    bool isInitialized = false,
  }) {
    _variables[symbol] = VariableTypeState(
      type: type,
      isExplicitlyDeclared: isExplicit,
      isInitialized: isInitialized,
    );
  }

  SemanticType? typeOf(Symbol symbol) {
    final state = _variables[symbol];
    if (state != null) return state.type;

    if (symbol is VariableSymbol && symbol.isDeclared) {
      final baseType = symbol.primitiveType != null
          ? PrimitiveSemanticType(symbol.primitiveType!)
          : (symbol.customTypeName != null
              ? ClassSemanticType(symbol.customTypeName!)
              : const IndeterminateSemanticType());
      if (symbol.dimensionCount > 0 && !baseType.isIndeterminate) {
        return ArraySemanticType(baseType, symbol.dimensionCount);
      }
      return baseType;
    }
    return null;
  }

  bool isInitialized(Symbol symbol) =>
      _variables[symbol]?.isInitialized ?? false;

  void markInitialized(Symbol symbol) {
    final state = _variables[symbol];
    if (state != null) {
      state.isInitialized = true;
    } else {
      final t = typeOf(symbol) ?? const IndeterminateSemanticType();
      _variables[symbol] = VariableTypeState(
        type: t,
        isExplicitlyDeclared: symbol is VariableSymbol && symbol.isDeclared,
        isInitialized: true,
      );
    }
  }

  void recordAssignment(
    Symbol symbol,
    SemanticType valueType,
    Span assignmentSpan,
  ) {
    final state = _variables[symbol];
    if (state == null) {
      if (symbol is VariableSymbol && symbol.isDeclared) {
        _handleDeclaredFirstAssignment(symbol, valueType, assignmentSpan);
        return;
      }
      _handleFirstAssignment(symbol, valueType, assignmentSpan);
      return;
    }

    state.isInitialized = true;

    if (state.isExplicitlyDeclared) {
      _checkExplicitAssignment(symbol, state.type, valueType, assignmentSpan);
      return;
    }

    _handleInferredAssignment(symbol, state, valueType, assignmentSpan);
  }

  void _handleDeclaredFirstAssignment(
    VariableSymbol symbol,
    SemanticType valueType,
    Span assignmentSpan,
  ) {
    final declaredType = symbol.primitiveType != null
        ? (symbol.dimensionCount > 0
            ? ArraySemanticType(
                PrimitiveSemanticType(symbol.primitiveType!),
                symbol.dimensionCount,
              )
            : PrimitiveSemanticType(symbol.primitiveType!))
        : (symbol.customTypeName != null
            ? ClassSemanticType(symbol.customTypeName!)
            : const IndeterminateSemanticType());

    _variables[symbol] = VariableTypeState(
      type: declaredType,
      isExplicitlyDeclared: true,
      isInitialized: true,
    );
    _checkExplicitAssignment(symbol, declaredType, valueType, assignmentSpan);
  }

  void _handleFirstAssignment(
    Symbol symbol,
    SemanticType valueType,
    Span span,
  ) {
    final inferredType =
        valueType.isError ? const IndeterminateSemanticType() : valueType;

    _variables[symbol] = VariableTypeState(
      type: inferredType,
      isExplicitlyDeclared: false,
      isInitialized: true,
    );

    if (!inferredType.isIndeterminate && !inferredType.isError) {
      _diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.inferredVariableType,
          severity: severityFor(DiagnosticCode.inferredVariableType),
          span: span,
          arguments: {
            'lexeme': LexemeDiagnosticArgument(symbol.name),
            'type': inferredType is PrimitiveSemanticType
                ? TypeDiagnosticArgument(inferredType.primitive)
                : LexemeDiagnosticArgument(inferredType.displayName),
          },
        ),
      );
    }
  }

  void _checkExplicitAssignment(
    Symbol symbol,
    SemanticType targetType,
    SemanticType valueType,
    Span span,
  ) {
    if (valueType.isError || valueType.isIndeterminate) return;
    if (!TypeRelations.isAssignable(valueType, targetType,
        hierarchy: hierarchy)) {
      _diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.incompatibleTypesInAssignment,
          severity: severityFor(DiagnosticCode.incompatibleTypesInAssignment),
          span: span,
          arguments: {
            'expected': targetType is PrimitiveSemanticType
                ? TypeDiagnosticArgument(targetType.primitive)
                : LexemeDiagnosticArgument(targetType.displayName),
            'found': valueType is PrimitiveSemanticType
                ? TypeDiagnosticArgument(valueType.primitive)
                : LexemeDiagnosticArgument(valueType.displayName),
          },
        ),
      );
    }
  }

  void _handleInferredAssignment(
    Symbol symbol,
    VariableTypeState state,
    SemanticType valueType,
    Span span,
  ) {
    if (valueType.isError || valueType.isIndeterminate) return;

    if (TypeRelations.isAssignable(valueType, state.type,
        hierarchy: hierarchy)) {
      return;
    }

    if (state.type.isInteger && valueType.isReal && !state.isWidened) {
      state.type = PrimitiveSemanticType(PrimitiveType.real);
      state.isWidened = true;
      _diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.widenedVariableType,
          severity: severityFor(DiagnosticCode.widenedVariableType),
          span: span,
          arguments: {
            'lexeme': LexemeDiagnosticArgument(symbol.name),
          },
        ),
      );
      return;
    }

    _diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.typeConflictOnInferredVariable,
        severity: severityFor(DiagnosticCode.typeConflictOnInferredVariable),
        span: span,
        arguments: {
          'lexeme': LexemeDiagnosticArgument(symbol.name),
        },
      ),
    );
  }
}
