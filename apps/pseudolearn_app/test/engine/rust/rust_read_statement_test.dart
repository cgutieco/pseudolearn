import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_read_statement.dart';

void main() {
  group('RustReadStatement', () {
    test('a single designator is the text after the keyword', () {
      final statement = RustReadStatement.parse('Leer numero;');
      expect(statement.text, 'Leer numero;');
      expect(statement.designators, ['numero']);
      expect(statement.designatorAt(0), 'numero');
    });

    test('top-level commas separate designators', () {
      final statement = RustReadStatement.parse('Read first, second;');
      expect(statement.designators, ['first', 'second']);
      expect(statement.designatorAt(1), 'second');
    });

    test('commas inside indices, calls and text stay in one designator', () {
      final statement = RustReadStatement.parse(
        'Leer m[i, j], v[f(a, b)], d["x,y"], c;',
      );
      expect(statement.designators, ['m[i, j]', 'v[f(a, b)]', 'd["x,y"]', 'c']);
    });

    test('line breaks and tabs collapse into single spaces', () {
      final statement = RustReadStatement.parse('Leer\ta,\n   b ;');
      expect(statement.text, 'Leer a, b ;');
      expect(statement.designators, ['a', 'b']);
    });

    test('a position past the designators names them all', () {
      final statement = RustReadStatement.parse('Leer persona;');
      expect(statement.designatorAt(3), 'persona');
      expect(RustReadStatement.parse('Leer a, b;').designatorAt(-1), 'a, b');
    });

    test('a statement without designators names nothing', () {
      expect(RustReadStatement.parse('Leer;').designators, isEmpty);
      expect(RustReadStatement.parse('').designatorAt(0), '');
      expect(RustReadStatement.parse('Escr').designatorAt(0), '');
    });

    test('a one character designator is kept', () {
      expect(RustReadStatement.parse('Leer x').designators, ['x']);
    });
  });
}
