import 'coverage_count.dart';

final class SpecificationSectionCoverage {
  final String sectionId;
  final String title;
  final bool isExercised;

  const SpecificationSectionCoverage({
    required this.sectionId,
    required this.title,
    required this.isExercised,
  });
}

final class SpecificationCoverage {
  final List<SpecificationSectionCoverage> sections;
  final CoverageCount count;

  const SpecificationCoverage({required this.sections, required this.count});

  const SpecificationCoverage.empty()
      : sections = const [],
        count = const CoverageCount.empty();

  factory SpecificationCoverage.of(
    List<SpecificationSectionCoverage> sections,
  ) {
    final exercised = sections.where((section) => section.isExercised).length;
    return SpecificationCoverage(
      sections: sections,
      count: CoverageCount(done: exercised, total: sections.length),
    );
  }
}
