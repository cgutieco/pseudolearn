import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/semantic/types/class_hierarchy_provider.dart';
import 'package:pseudolearn_core/src/semantic/types/semantic_type.dart';
import 'package:pseudolearn_core/src/semantic/types/type_relations.dart';
import 'package:test/test.dart';

final class MockHierarchyProvider implements ClassHierarchyProvider {
  final Map<String, String> superclasses;

  MockHierarchyProvider(this.superclasses);

  @override
  bool isSubclassOf(String subclass, String superclass) {
    String? current = superclasses[subclass];
    while (current != null) {
      if (current == superclass) return true;
      current = superclasses[current];
    }
    return false;
  }
}

void main() {
  group('TypeRelations.areIdentical', () {
    test('identical primitives are identical', () {
      expect(
        TypeRelations.areIdentical(
          const PrimitiveSemanticType(PrimitiveType.integer),
          const PrimitiveSemanticType(PrimitiveType.integer),
        ),
        isTrue,
      );
      expect(
        TypeRelations.areIdentical(
          const PrimitiveSemanticType(PrimitiveType.integer),
          const PrimitiveSemanticType(PrimitiveType.real),
        ),
        isFalse,
      );
    });

    test('identical classes are identical', () {
      expect(
        TypeRelations.areIdentical(
          const ClassSemanticType('Persona'),
          const ClassSemanticType('Persona'),
        ),
        isTrue,
      );
      expect(
        TypeRelations.areIdentical(
          const ClassSemanticType('Persona'),
          const ClassSemanticType('Animal'),
        ),
        isFalse,
      );
    });

    test('arrays are identical only if element and dimensions match', () {
      final arr1 = ArraySemanticType(
        const PrimitiveSemanticType(PrimitiveType.integer),
        2,
      );
      final arr2 = ArraySemanticType(
        const PrimitiveSemanticType(PrimitiveType.integer),
        2,
      );
      final arr3 = ArraySemanticType(
        const PrimitiveSemanticType(PrimitiveType.real),
        2,
      );
      final arr4 = ArraySemanticType(
        const PrimitiveSemanticType(PrimitiveType.integer),
        1,
      );

      expect(TypeRelations.areIdentical(arr1, arr2), isTrue);
      expect(TypeRelations.areIdentical(arr1, arr3), isFalse);
      expect(TypeRelations.areIdentical(arr1, arr4), isFalse);
    });
  });

  group('TypeRelations.isConvertibleTo', () {
    final hierarchy = MockHierarchyProvider({
      'Gato': 'Mascota',
      'Siames': 'Gato',
      'Perro': 'Mascota',
    });

    test('entero is convertible to real but not vice versa (12.1)', () {
      expect(
        TypeRelations.isConvertibleTo(
          const PrimitiveSemanticType(PrimitiveType.integer),
          const PrimitiveSemanticType(PrimitiveType.real),
        ),
        isTrue,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const PrimitiveSemanticType(PrimitiveType.real),
          const PrimitiveSemanticType(PrimitiveType.integer),
        ),
        isFalse,
      );
    });

    test('no other primitive implicit conversions exist', () {
      expect(
        TypeRelations.isConvertibleTo(
          const PrimitiveSemanticType(PrimitiveType.character),
          const PrimitiveSemanticType(PrimitiveType.string),
        ),
        isFalse,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const PrimitiveSemanticType(PrimitiveType.string),
          const PrimitiveSemanticType(PrimitiveType.character),
        ),
        isFalse,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const PrimitiveSemanticType(PrimitiveType.boolean),
          const PrimitiveSemanticType(PrimitiveType.integer),
        ),
        isFalse,
      );
    });

    test('subclass is convertible to superclass (polymorphism)', () {
      expect(
        TypeRelations.isConvertibleTo(
          const ClassSemanticType('Gato'),
          const ClassSemanticType('Mascota'),
          hierarchy: hierarchy,
        ),
        isTrue,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const ClassSemanticType('Siames'),
          const ClassSemanticType('Mascota'),
          hierarchy: hierarchy,
        ),
        isTrue,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const ClassSemanticType('Mascota'),
          const ClassSemanticType('Gato'),
          hierarchy: hierarchy,
        ),
        isFalse,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const ClassSemanticType('Gato'),
          const ClassSemanticType('Perro'),
          hierarchy: hierarchy,
        ),
        isFalse,
      );
    });

    test(
        'error and indeterminate types are always convertible to avoid cascades',
        () {
      expect(
        TypeRelations.isConvertibleTo(
          const ErrorSemanticType(),
          const PrimitiveSemanticType(PrimitiveType.integer),
        ),
        isTrue,
      );
      expect(
        TypeRelations.isConvertibleTo(
          const IndeterminateSemanticType(),
          const PrimitiveSemanticType(PrimitiveType.string),
        ),
        isTrue,
      );
    });
  });

  group('TypeRelations.areComparable', () {
    final hierarchy = MockHierarchyProvider({
      'Gato': 'Mascota',
      'Perro': 'Mascota',
    });

    test(
        'classes with inheritance relation are comparable for identity equality',
        () {
      expect(
        TypeRelations.areComparable(
          const ClassSemanticType('Gato'),
          const ClassSemanticType('Mascota'),
          hierarchy: hierarchy,
        ),
        isTrue,
      );
      expect(
        TypeRelations.areComparable(
          const ClassSemanticType('Gato'),
          const ClassSemanticType('Perro'),
          hierarchy: hierarchy,
        ),
        isFalse,
      );
    });

    test('entero and real are comparable', () {
      expect(
        TypeRelations.areComparable(
          const PrimitiveSemanticType(PrimitiveType.integer),
          const PrimitiveSemanticType(PrimitiveType.real),
        ),
        isTrue,
      );
    });
  });
}
