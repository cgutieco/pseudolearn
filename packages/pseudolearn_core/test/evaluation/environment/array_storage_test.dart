import 'package:pseudolearn_core/src/evaluation/environment/array_storage.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:test/test.dart';

void main() {
  group('ArrayStorage, flat 1D indexing', () {
    test('allocates cells matching dimension sizes and initializes unassigned',
        () {
      final storage = ArrayStorage([5]);
      expect(storage.dimensionSizes, equals([5]));
      expect(storage.elementCount, equals(5));
      for (var i = 0; i < 5; i++) {
        expect(storage.cellAt([i])!.hasValue, isFalse);
      }
    });

    test('assigns and reads values at boundary indices', () {
      final storage = ArrayStorage([5]);
      storage.cellAt([0])!.assign(const RealValue(10.0));
      storage.cellAt([4])!.assign(const RealValue(20.0));

      expect(storage.cellAt([0])!.value, equals(const RealValue(10.0)));
      expect(storage.cellAt([4])!.value, equals(const RealValue(20.0)));
      expect(storage.cellAt([2])!.hasValue, isFalse);
    });

    test('out-of-bounds index returns null', () {
      final storage = ArrayStorage([5]);
      expect(storage.cellAt([-1]), isNull);
      expect(storage.cellAt([5]), isNull);
      expect(storage.cellAt([6]), isNull);
      expect(storage.cellAt([]), isNull);
      expect(storage.cellAt([0, 0]), isNull);
    });
  });

  group('ArrayStorage, 2D row-major layout', () {
    test('indexes [row, col] correctly across boundaries', () {
      final storage = ArrayStorage([2, 3]);
      expect(storage.dimensionSizes, equals([2, 3]));
      expect(storage.elementCount, equals(6));

      storage.cellAt([0, 0])!.assign(const RealValue(1.0));
      storage.cellAt([0, 2])!.assign(const RealValue(2.0));
      storage.cellAt([1, 0])!.assign(const RealValue(3.0));
      storage.cellAt([1, 2])!.assign(const RealValue(4.0));

      expect(storage.cellAt([0, 0])!.value, equals(const RealValue(1.0)));
      expect(storage.cellAt([0, 2])!.value, equals(const RealValue(2.0)));
      expect(storage.cellAt([1, 0])!.value, equals(const RealValue(3.0)));
      expect(storage.cellAt([1, 2])!.value, equals(const RealValue(4.0)));
      expect(storage.cellAt([0, 1])!.hasValue, isFalse);
    });

    test('out-of-bounds and mismatched dimension indices return null', () {
      final storage = ArrayStorage([2, 3]);
      expect(storage.cellAt([-1, 0]), isNull);
      expect(storage.cellAt([0, -1]), isNull);
      expect(storage.cellAt([2, 0]), isNull);
      expect(storage.cellAt([0, 3]), isNull);
      expect(storage.cellAt([2, 3]), isNull);
      expect(storage.cellAt([]), isNull);
      expect(storage.cellAt([0]), isNull);
      expect(storage.cellAt([0, 0, 0]), isNull);
    });
  });

  group('ArrayStorage, 3D layout and edge dimensions', () {
    test('indexes 3D dimensions correctly with row-major layout', () {
      final storage = ArrayStorage([2, 3, 4]);
      expect(storage.elementCount, equals(24));

      storage.cellAt([0, 0, 0])!.assign(const RealValue(100.0));
      storage.cellAt([1, 2, 3])!.assign(const RealValue(200.0));

      expect(storage.cellAt([0, 0, 0])!.value, equals(const RealValue(100.0)));
      expect(storage.cellAt([1, 2, 3])!.value, equals(const RealValue(200.0)));
      expect(storage.cellAt([0, 0, 1])!.hasValue, isFalse);
      expect(storage.cellAt([2, 0, 0]), isNull);
      expect(storage.cellAt([0, 3, 0]), isNull);
      expect(storage.cellAt([0, 0, 4]), isNull);
    });

    test('allocates single element array for dimension [1]', () {
      final storage = ArrayStorage([1]);
      expect(storage.elementCount, equals(1));
      expect(storage.cellAt([0])!.hasValue, isFalse);
      storage.cellAt([0])!.assign(const RealValue(42.0));
      expect(storage.cellAt([0])!.value, equals(const RealValue(42.0)));
      expect(storage.cellAt([1]), isNull);
    });
  });
}
