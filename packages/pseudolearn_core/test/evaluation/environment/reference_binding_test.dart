import 'package:pseudolearn_core/src/evaluation/environment/array_storage.dart';
import 'package:pseudolearn_core/src/evaluation/environment/reference_binding.dart';
import 'package:pseudolearn_core/src/evaluation/environment/variable_cell.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:test/test.dart';

void main() {
  group('ReferenceBinding over a plain VariableCell', () {
    test('reads and writes through to the target cell', () {
      final cell = VariableCell();
      final binding = ReferenceBinding(cell);

      expect(binding.hasValue, isFalse);
      binding.write(const StringValue('hola'));
      expect(cell.hasValue, isTrue);
      expect(cell.value, equals(const StringValue('hola')));
      expect(binding.value, equals(const StringValue('hola')));

      cell.assign(const RealValue(1.5));
      expect(binding.value, equals(const RealValue(1.5)));
    });
  });

  group('ReferenceBinding over an array element', () {
    test(
        'binds the cell at invocation time; mutating the index later does not change the cell',
        () {
      final storage = ArrayStorage([5]);
      var index = 2;
      final binding = ReferenceBinding(storage.cellAt([index])!);

      index = 4;
      binding.write(const StringValue('elemento'));

      expect(storage.cellAt([2])!.value, equals(const StringValue('elemento')));
      expect(storage.cellAt([4])!.hasValue, isFalse);
    });
  });
}
