import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/engine/classdiagram/inheritance_levels.dart';

ClassBox _box(String name, {String? superclassName}) => ClassBox(
      name: name,
      superclassName: superclassName,
      attributes: const [],
      methods: const [],
      nodeId: ProgramNodeId(name.hashCode),
      sourceLine: 1,
    );

List<List<String>> _namesOf(List<ClassBox> classes) => [
      for (final level in InheritanceLevels.of(classes))
        [for (final box in level) box.name],
    ];

void main() {
  group('InheritanceLevels', () {
    test('an empty list produces no levels', () {
      expect(InheritanceLevels.of(const []), isEmpty);
    });

    test('classes without a superclass share the root level', () {
      final levels = _namesOf([_box('A'), _box('B')]);

      expect(levels, [
        ['A', 'B'],
      ]);
    });

    test('a chain of three produces three levels', () {
      final levels = _namesOf([
        _box('A'),
        _box('B', superclassName: 'A'),
        _box('C', superclassName: 'B'),
      ]);

      expect(levels, [
        ['A'],
        ['B'],
        ['C'],
      ]);
    });

    test('two siblings share the level below their superclass', () {
      final levels = _namesOf([
        _box('A'),
        _box('B', superclassName: 'A'),
        _box('C', superclassName: 'A'),
      ]);

      expect(levels, [
        ['A'],
        ['B', 'C'],
      ]);
    });

    test('order inside a level follows the order of declaration', () {
      final levels = _namesOf([
        _box('Z', superclassName: 'A'),
        _box('A'),
        _box('M', superclassName: 'A'),
      ]);

      expect(levels, [
        ['A'],
        ['Z', 'M'],
      ]);
    });

    test('a superclass that is not declared leaves the class at the root', () {
      final levels = _namesOf([_box('Sola', superclassName: 'Ausente')]);

      expect(levels, [
        ['Sola'],
      ]);
    });

    test('cyclic inheritance terminates and keeps both at the same level', () {
      final levels = _namesOf([
        _box('Uno', superclassName: 'Dos'),
        _box('Dos', superclassName: 'Uno'),
      ]);

      expect(levels, [
        ['Uno', 'Dos'],
      ]);
    });

    test('a class that inherits from itself terminates at the root', () {
      final levels = _namesOf([_box('Sola', superclassName: 'Sola')]);

      expect(levels, [
        ['Sola'],
      ]);
    });

    test('a cycle of three terminates', () {
      final levels = _namesOf([
        _box('A', superclassName: 'C'),
        _box('B', superclassName: 'A'),
        _box('C', superclassName: 'B'),
      ]);

      expect(levels.length, 1);
      expect(levels.first.length, 3);
    });
  });
}
