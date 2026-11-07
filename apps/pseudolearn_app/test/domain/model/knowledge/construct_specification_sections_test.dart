import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/construct_specification_sections.dart';

Set<String> _sectionIdsOf(String tocPath) {
  final parts = jsonDecode(File(tocPath).readAsStringSync()) as List;
  return {
    for (final part in parts)
      for (final section in (part as Map<String, dynamic>)['sections'] as List)
        (section as Map<String, dynamic>)['id'] as String,
  };
}

void main() {
  group('constructSpecificationSections (PANT-06-F5)', () {
    test('every construct of the closed catalogue names a section', () {
      for (final construct in AstConstruct.values) {
        expect(
          constructSpecificationSections[construct],
          isNotNull,
          reason: 'construct ${construct.slug} has no specification section',
        );
      }
    });

    test('every named section exists in the published Spanish specification', () {
      final declared = _sectionIdsOf('assets/reference/es/es/toc.json');
      expect(measurableSpecificationSectionIds().difference(declared), isEmpty);
    });

    test('every named section exists in the published English specification', () {
      final declared = _sectionIdsOf('assets/reference/en/en/toc.json');
      expect(measurableSpecificationSectionIds().difference(declared), isEmpty);
    });

    test('the measurable set is smaller than the published catalogue', () {
      final declared = _sectionIdsOf('assets/reference/es/es/toc.json');
      expect(measurableSpecificationSectionIds().length, lessThan(declared.length));
    });
  });
}
