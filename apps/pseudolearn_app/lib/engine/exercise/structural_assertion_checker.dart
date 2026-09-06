import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/knowledge/structural_assertion.dart';
import '../../domain/model/knowledge/structural_assertion_kind.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../analysis/analysis_cache.dart';
import 'program_structure.dart';
import 'structural_assertions.dart';

final class StructuralAssertionChecker {
  final AnalysisCache _analyses;
  final Map<StructuralAssertionKind, StructuralAssertionEvaluator>
      _catalog;

  StructuralAssertionChecker({
    AnalysisCache? analyses,
    Map<StructuralAssertionKind, StructuralAssertionEvaluator>?
        catalog,
  })  : _analyses = analyses ?? AnalysisCache(),
        _catalog = catalog ?? structuralAssertionCatalog;

  SourceUnitNode? sourceUnitOf(String sourceCode, SyntaxProfileId profileId) =>
      _analyses.of(sourceCode, profileId).sourceUnit;

  List<StructuralAssertion> unmetAssertions({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required List<StructuralAssertion> assertions,
  }) {
    if (assertions.isEmpty) return const [];
    final unit = _analyses.of(sourceCode, profileId).sourceUnit;
    if (unit == null) return List.unmodifiable(assertions);
    final structure = ProgramStructure.of(unit);
    final unmet = <StructuralAssertion>[];
    for (final assertion in assertions) {
      final evaluate = _catalog[assertion.kind];
      if (evaluate == null || !evaluate(assertion, structure)) {
        unmet.add(assertion);
      }
    }
    return unmet;
  }
}
