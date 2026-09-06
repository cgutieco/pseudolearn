import '../../domain/model/dashboard/specification_coverage.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/construct_specification_sections.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';

SpecificationCoverage projectSpecificationCoverage({
  required List<KnowledgeEntry> sections,
  required Set<AstConstruct> exercisedConstructs,
}) {
  final measurable = measurableSpecificationSectionIds();
  final covered = _coveredSectionIds(exercisedConstructs);
  final ordered = List<KnowledgeEntry>.from(sections)
    ..sort((a, b) => a.order.compareTo(b.order));

  return SpecificationCoverage.of([
    for (final section in ordered)
      if (measurable.contains(section.id))
        SpecificationSectionCoverage(
          sectionId: section.id,
          title: section.title,
          isExercised: covered.contains(section.id),
        ),
  ]);
}

Set<String> _coveredSectionIds(Set<AstConstruct> exercisedConstructs) {
  final covered = <String>{};
  for (final construct in exercisedConstructs) {
    final sectionId = constructSpecificationSections[construct];
    if (sectionId != null) covered.add(sectionId);
  }
  return covered;
}
