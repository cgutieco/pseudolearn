import '../../domain/diagnostic.dart';
import '../../domain/severity.dart';
import '../ast/ast_node.dart';

final class ParseResult {
  final SourceUnitNode? program;
  final List<Diagnostic> diagnostics;

  const ParseResult({
    required this.program,
    required this.diagnostics,
  });

  bool get hasErrors => diagnostics.any((d) => d.severity == Severity.error);

  bool get isSuccessful => program != null && !hasErrors;
}
