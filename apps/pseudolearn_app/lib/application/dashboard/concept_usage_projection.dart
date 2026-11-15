import '../../domain/model/dashboard/concept_coverage.dart';
import '../../domain/model/knowledge/ast_construct.dart';

ConceptCoverage projectConceptUsage(
  Map<String, Set<AstConstruct>> constructsByDocument,
) {
  final counts = <AstConstruct, int>{};
  for (final constructs in constructsByDocument.values) {
    for (final construct in constructs) {
      counts[construct] = (counts[construct] ?? 0) + 1;
    }
  }
  return ConceptCoverage.of([
    for (final construct in AstConstruct.values)
      ConceptUsage(
        construct: construct,
        documentCount: counts[construct] ?? 0,
      ),
  ]);
}

Set<AstConstruct> exercisedConstructsOf(
  Map<String, Set<AstConstruct>> constructsByDocument,
) {
  final used = <AstConstruct>{};
  for (final constructs in constructsByDocument.values) {
    used.addAll(constructs);
  }
  return used;
}
