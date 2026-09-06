import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/random_identifier_generator.dart';

void main() {
  group('RandomIdentifierGenerator Tests (CIM-F4)', () {
    test('generate produces unique valid UUID format strings', () {
      final generator = RandomIdentifierGenerator();
      final id1 = generator.generate();
      final id2 = generator.generate();

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidRegex.hasMatch(id1), isTrue);
      expect(uuidRegex.hasMatch(id2), isTrue);
    });
  });
}
