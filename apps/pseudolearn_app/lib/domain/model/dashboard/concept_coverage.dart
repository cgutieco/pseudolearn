import '../knowledge/ast_construct.dart';
import 'coverage_count.dart';

final class ConceptUsage {
  final AstConstruct construct;
  final int documentCount;

  const ConceptUsage({required this.construct, required this.documentCount});

  bool get isExercised => documentCount > 0;
}

final class ConceptCoverage {
  final List<ConceptUsage> concepts;
  final CoverageCount count;

  const ConceptCoverage({required this.concepts, required this.count});

  const ConceptCoverage.empty()
      : concepts = const [],
        count = const CoverageCount.empty();

  factory ConceptCoverage.of(List<ConceptUsage> concepts) {
    final exercised = concepts.where((concept) => concept.isExercised).length;
    return ConceptCoverage(
      concepts: concepts,
      count: CoverageCount(done: exercised, total: concepts.length),
    );
  }
}
