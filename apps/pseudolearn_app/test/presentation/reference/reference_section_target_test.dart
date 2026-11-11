import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/reference/reference_section_target.dart';

void main() {
  group('sectionTarget', () {
    test('returns the bare section when there is no anchor', () {
      expect(sectionTarget('lexico.numeros', null), 'lexico.numeros');
    });

    test('returns the bare section when the anchor is empty', () {
      expect(sectionTarget('lexico.numeros', ''), 'lexico.numeros');
    });

    test('joins section and anchor', () {
      expect(sectionTarget('lexico.numeros', 'reales'), 'lexico.numeros#reales');
    });
  });

  group('specificationLocation', () {
    test('points at the section without a query when there is no anchor', () {
      expect(
        specificationLocation('lexico.numeros'),
        '/conocimiento/especificacion/lexico.numeros',
      );
    });

    test('moves the anchor into the query string', () {
      expect(
        specificationLocation('lexico.numeros#reales'),
        '/conocimiento/especificacion/lexico.numeros?anchor=reales',
      );
    });

    test('encodes anchors with reserved characters', () {
      expect(
        specificationLocation('lexico.numeros#a b&c'),
        '/conocimiento/especificacion/lexico.numeros?anchor=a+b%26c',
      );
    });

    test('drops a trailing separator with no anchor', () {
      expect(
        specificationLocation('lexico.numeros#'),
        '/conocimiento/especificacion/lexico.numeros',
      );
    });
  });
}
