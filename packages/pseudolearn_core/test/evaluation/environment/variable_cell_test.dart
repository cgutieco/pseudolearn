import 'package:pseudolearn_core/src/evaluation/environment/variable_cell.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:test/test.dart';

void main() {
  group('VariableCell', () {
    test('starts unassigned', () {
      final cell = VariableCell();
      expect(cell.hasValue, isFalse);
    });

    test('value getter throws StateError when unassigned (internal invariant)',
        () {
      final cell = VariableCell();
      expect(() => cell.value, throwsStateError);
    });

    test('assign sets the value and updates hasValue', () {
      final cell = VariableCell();
      cell.assign(const RealValue(1.0));
      expect(cell.hasValue, isTrue);
      expect(cell.value, equals(const RealValue(1.0)));
      cell.assign(const RealValue(2.0));
      expect(cell.value, equals(const RealValue(2.0)));
    });
  });
}
