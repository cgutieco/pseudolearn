import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/construct_specification_sections.dart';

Set<String> _sectionIdsOf(String manifestPath) {
  final manifest = jsonDecode(File(manifestPath).readAsStringSync());
  final sections = (manifest as Map<String, dynamic>)['specification'] as List;
  return sections.map((raw) => (raw as Map<String, dynamic>)['id'] as String).toSet();
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

    test('every named section exists in the published Spanish manifest', () {
      final declared = _sectionIdsOf('assets/knowledge/manifest_es.json');
      expect(measurableSpecificationSectionIds().difference(declared), isEmpty);
    });

    test('every named section exists in the published English manifest', () {
      final declared = _sectionIdsOf('assets/knowledge/manifest_en.json');
      expect(measurableSpecificationSectionIds().difference(declared), isEmpty);
    });

    test('the measurable set is smaller than the published catalogue', () {
      final declared = _sectionIdsOf('assets/knowledge/manifest_es.json');
      expect(measurableSpecificationSectionIds().length, lessThan(declared.length));
    });
  });
}
