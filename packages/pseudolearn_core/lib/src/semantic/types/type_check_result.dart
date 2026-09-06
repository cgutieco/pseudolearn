import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import 'semantic_type.dart';

final class TypeCheckResult {
  final Map<NodeId, SemanticType> nodeTypes;
  final List<Diagnostic> diagnostics;

  const TypeCheckResult({
    required this.nodeTypes,
    required this.diagnostics,
  });

  bool get hasErrors => diagnostics.any((d) => d.severity == Severity.error);

  SemanticType? typeFor(NodeId id) => nodeTypes[id];
}
