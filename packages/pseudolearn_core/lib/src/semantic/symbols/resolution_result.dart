import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import 'scope.dart';
import 'symbol.dart';

final class ResolutionResult {
  final Map<NodeId, Symbol> resolvedSymbols;
  final Map<NodeId, ClassSymbol> resolvedClasses;
  final List<Diagnostic> diagnostics;
  final SourceUnitScope rootScope;

  const ResolutionResult({
    required this.resolvedSymbols,
    required this.resolvedClasses,
    required this.diagnostics,
    required this.rootScope,
  });

  bool get hasErrors => diagnostics.any((d) => d.severity == Severity.error);

  Symbol? symbolFor(NodeId id) => resolvedSymbols[id];

  ClassSymbol? classFor(NodeId id) => resolvedClasses[id];
}
