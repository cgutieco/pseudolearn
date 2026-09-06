import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/specification_coverage_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectSpecificationCoverage (PANT-06-F5)', () {
    final sections = [
      specificationEntry('esp-i-lexico', order: 1),
      specificationEntry('esp-i-control', order: 2),
      specificationEntry('esp-i-arreglos', order: 3),
      specificationEntry('esp-i-subprogramas', order: 4),
      specificationEntry('esp-o-clases', order: 5),
    ];

    test('marks as exercised the section of every construct written', () {
      final coverage = projectSpecificationCoverage(
        sections: sections,
        exercisedConstructs: {AstConstruct.countedLoop},
      );
      final control = coverage.sections.first;

      expect(control.sectionId, 'esp-i-control');
      expect(control.isExercised, isTrue);
      expect(coverage.count.done, 1);
    });

    test('sections without a measurable construct stay out of the count', () {
      final coverage = projectSpecificationCoverage(
        sections: sections,
        exercisedConstructs: const {},
      );

      expect(
        coverage.sections.map((section) => section.sectionId),
        isNot(contains('esp-i-lexico')),
      );
      expect(coverage.count.total, 4);
    });

    test('nothing written leaves every measurable section pending', () {
      final coverage = projectSpecificationCoverage(
        sections: sections,
        exercisedConstructs: const {},
      );

      expect(coverage.count.done, 0);
      for (final section in coverage.sections) {
        expect(section.isExercised, isFalse);
      }
    });

    test('a catalogue without specification sections reports nothing', () {
      final coverage = projectSpecificationCoverage(
        sections: const [],
        exercisedConstructs: {AstConstruct.conditional},
      );

      expect(coverage.sections, isEmpty);
      expect(coverage.count.total, 0);
    });
  });
}
