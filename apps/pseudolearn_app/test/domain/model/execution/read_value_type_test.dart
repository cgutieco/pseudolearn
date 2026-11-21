import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/read_value_type.dart';

void main() {
  group('ReadValueType.fromWireName', () {
    test('maps every wire name of the engine', () {
      expect(ReadValueType.fromWireName('entero'), ReadValueType.integer);
      expect(ReadValueType.fromWireName('real'), ReadValueType.real);
      expect(ReadValueType.fromWireName('logico'), ReadValueType.boolean);
      expect(ReadValueType.fromWireName('caracter'), ReadValueType.character);
      expect(ReadValueType.fromWireName('cadena'), ReadValueType.text);
    });

    test('an unknown, empty or missing name has no type', () {
      expect(ReadValueType.fromWireName('Entero'), isNull);
      expect(ReadValueType.fromWireName(''), isNull);
      expect(ReadValueType.fromWireName(null), isNull);
      expect(ReadValueType.fromWireName(3), isNull);
    });
  });
}
