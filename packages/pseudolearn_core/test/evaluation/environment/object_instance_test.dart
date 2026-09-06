import 'package:pseudolearn_core/src/domain/node_id.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/domain/visibility.dart';
import 'package:pseudolearn_core/src/evaluation/environment/object_instance.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/semantic/symbols/symbol.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:test/test.dart';

void main() {
  ClassSymbol createClass({
    required String name,
    ClassSymbol? superclass,
    List<FieldSymbol>? fields,
  }) {
    final fieldMap = <String, FieldSymbol>{};
    if (fields != null) {
      for (final f in fields) {
        fieldMap[f.name] = f;
      }
    }
    return ClassSymbol(
      name: name,
      span: Span.zero,
      superclass: superclass,
      fields: fieldMap,
      declarationNode: ClassNode(
        id: const NodeId(1),
        span: Span.zero,
        name: name,
        nameSpan: Span.zero,
        members: const [],
      ),
    );
  }

  FieldSymbol createField(String name, {PrimitiveType type = PrimitiveType.integer}) =>
      FieldSymbol(
        name: name,
        span: Span.zero,
        visibility: Visibility.public,
        primitiveType: type,
      );

  group('ObjectInstance tests', () {
    test('initializes uninitialized field cells for own and superclass fields', () {
      final baseClass = createClass(
        name: 'Mascota',
        fields: [createField('nombre', type: PrimitiveType.string)],
      );
      final derivedClass = createClass(
        name: 'Gato',
        superclass: baseClass,
        fields: [createField('raza', type: PrimitiveType.string)],
      );

      final instance = ObjectInstance(id: 10, classSymbol: derivedClass);

      expect(instance.id, equals(10));
      expect(instance.classSymbol, equals(derivedClass));
      expect(instance.hasField('nombre'), isTrue);
      expect(instance.hasField('raza'), isTrue);
      expect(instance.hasField('edad'), isFalse);

      final nombreCell = instance.fieldCell('nombre');
      final razaCell = instance.fieldCell('raza');

      expect(nombreCell, isNotNull);
      expect(razaCell, isNotNull);
      expect(nombreCell!.hasValue, isFalse);
      expect(razaCell!.hasValue, isFalse);
    });

    test('field mutation modifies the cell within the instance', () {
      final cls = createClass(
        name: 'Persona',
        fields: [createField('edad', type: PrimitiveType.integer)],
      );
      final instance = ObjectInstance(id: 1, classSymbol: cls);

      final cell = instance.fieldCell('edad')!;
      cell.assign(IntegerValue(PseudoInteger.fromInt(30)));

      expect(cell.hasValue, isTrue);
      expect(cell.value, equals(IntegerValue(PseudoInteger.fromInt(30))));
    });

    test('shallowCopy clones cells with independent primitive cell storage', () {
      final cls = createClass(
        name: 'Persona',
        fields: [createField('edad', type: PrimitiveType.integer)],
      );
      final original = ObjectInstance(id: 1, classSymbol: cls);
      original.fieldCell('edad')!.assign(IntegerValue(PseudoInteger.fromInt(25)));

      final copy = original.shallowCopy(2);

      expect(copy.id, equals(2));
      expect(copy.classSymbol, equals(cls));
      expect(copy.fieldCell('edad')!.hasValue, isTrue);
      expect(copy.fieldCell('edad')!.value, equals(IntegerValue(PseudoInteger.fromInt(25))));

      copy.fieldCell('edad')!.assign(IntegerValue(PseudoInteger.fromInt(40)));

      expect(original.fieldCell('edad')!.value, equals(IntegerValue(PseudoInteger.fromInt(25))));
      expect(copy.fieldCell('edad')!.value, equals(IntegerValue(PseudoInteger.fromInt(40))));
    });

    test('shallowCopy with uninitialized field preserves uninitialized state', () {
      final cls = createClass(
        name: 'Persona',
        fields: [createField('nombre', type: PrimitiveType.string)],
      );
      final original = ObjectInstance(id: 1, classSymbol: cls);
      final copy = original.shallowCopy(2);

      expect(copy.fieldCell('nombre')!.hasValue, isFalse);
    });
  });
}
