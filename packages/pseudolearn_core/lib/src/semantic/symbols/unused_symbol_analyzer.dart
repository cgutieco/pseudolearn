import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import 'scope.dart';
import 'symbol.dart';

final class UnusedSymbolAnalyzer {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;

  UnusedSymbolAnalyzer({
    required this.profile,
    required this.diagnostics,
  });

  void analyze({
    required SourceUnitScope rootScope,
    required Map<String, SubroutineSymbol> subroutines,
    required Map<String, ClassSymbol> classes,
  }) {
    _analyzeSubroutines(subroutines.values);
    _analyzeClasses(classes.values);
  }

  void _analyzeSubroutines(Iterable<SubroutineSymbol> subroutines) {
    for (final subroutine in subroutines) {
      if (!subroutine.isCalled) {
        _report(
          DiagnosticCode.unusedSubroutine,
          subroutine.span,
          {'lexeme': LexemeDiagnosticArgument(subroutine.name)},
        );
      }
      _checkUnusedParameters(subroutine.parameters);
    }
  }

  void _analyzeClasses(Iterable<ClassSymbol> classes) {
    for (final classSymbol in classes) {
      for (final method in classSymbol.methods.values) {
        _checkUnusedParameters(method.parameters);
      }
      final constructor = classSymbol.constructor;
      if (constructor != null) {
        _checkUnusedParameters(constructor.parameters);
      }
    }
  }

  void _checkUnusedParameters(List<ParameterSymbol> parameters) {
    for (final param in parameters) {
      if (!param.isRead && !param.isAssigned) {
        _report(
          DiagnosticCode.unusedParameter,
          param.span,
          {'lexeme': LexemeDiagnosticArgument(param.name)},
        );
      }
    }
  }

  void analyzeVariablesInScope(Scope scope) {
    for (final symbol in scope.symbols.values) {
      if (symbol is VariableSymbol) {
        _checkVariableUsage(symbol);
      }
    }
  }

  void _checkVariableUsage(VariableSymbol symbol) {
    if (symbol.isDeclared && !symbol.isAssigned && !symbol.isRead) {
      _report(
        DiagnosticCode.variableDeclaredNeverUsed,
        symbol.span,
        {'lexeme': LexemeDiagnosticArgument(symbol.name)},
      );
    } else if (symbol.isAssigned && !symbol.isRead) {
      _report(
        DiagnosticCode.variableAssignedNeverRead,
        symbol.span,
        {'lexeme': LexemeDiagnosticArgument(symbol.name)},
      );
    }
  }

  void _report(
    DiagnosticCode code,
    Span span,
    Map<String, DiagnosticArgument> arguments,
  ) {
    diagnostics.add(
      Diagnostic(
        code: code,
        severity:
            profile.severityPolicy[code] ?? profile.severityPolicy.values.first,
        span: span,
        arguments: arguments,
      ),
    );
  }
}
