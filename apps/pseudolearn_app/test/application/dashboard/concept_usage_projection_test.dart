import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/concept_usage_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';

void main() {
  group('projectConceptUsage (PANT-06-F5)', () {
    test('counts how many documents use each construct', () {
      final coverage = projectConceptUsage({
        'a': {AstConstruct.conditional, AstConstruct.countedLoop},
        'b': {AstConstruct.conditional},
      });
      final conditional = coverage.concepts.firstWhere(
        (concept) => concept.construct == AstConstruct.conditional,
      );

      expect(conditional.documentCount, 2);
      expect(coverage.count.done, 2);
      expect(coverage.count.total, AstConstruct.values.length);
    });

    test('the whole catalogue is reported, unused constructs included', () {
      final coverage = projectConceptUsage(const {});

      expect(coverage.concepts.length, AstConstruct.values.length);
      expect(coverage.count.done, 0);
      for (final concept in coverage.concepts) {
        expect(concept.isExercised, isFalse);
      }
    });

    test('a document with no recognised construct adds nothing', () {
      final coverage = projectConceptUsage({'a': const <AstConstruct>{}});

      expect(coverage.count.done, 0);
    });

    test('the exercised set is the union across documents', () {
      final exercised = exercisedConstructsOf({
        'a': {AstConstruct.subprogram},
        'b': {AstConstruct.subprogram, AstConstruct.classDeclaration},
      });

      expect(exercised, {AstConstruct.subprogram, AstConstruct.classDeclaration});
    });
  });
}
