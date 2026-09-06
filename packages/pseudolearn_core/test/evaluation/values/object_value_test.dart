import 'package:pseudolearn_core/src/domain/node_id.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/evaluation/environment/object_instance.dart';
import 'package:pseudolearn_core/src/evaluation/values/comparison_evaluator.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/semantic/symbols/symbol.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:test/test.dart';

void main() {
  ClassSymbol dummyClass(String name) => ClassSymbol(
        name: name,
        span: Span.zero,
        declarationNode: ClassNode(
          id: const NodeId(1),
          span: Span.zero,
          name: name,
          nameSpan: Span.zero,
          members: const [],
        ),
      );

  group('ObjectValue tests', () {
    test('creates ObjectValue wrapping ObjectInstance', () {
      final cls = dummyClass('Persona');
      final instance = ObjectInstance(id: 1, classSymbol: cls);
      final value = ObjectValue(instance);

      expect(value.instance, equals(instance));
      expect(value.toString(), equals('ObjectValue(Persona#1)'));
    });

    test('equality is based on instance id', () {
      final cls = dummyClass('Persona');
      final instance1 = ObjectInstance(id: 1, classSymbol: cls);
      final instance2 = ObjectInstance(id: 2, classSymbol: cls);

      final val1a = ObjectValue(instance1);
      final val1b = ObjectValue(instance1);
      final val2 = ObjectValue(instance2);

      expect(val1a, equals(val1b));
      expect(val1a == val2, isFalse);
      expect(val1a.hashCode, equals(val1b.hashCode));
    });

    test('ComparisonEvaluator equalValues compares object identity', () {
      final cls = dummyClass('Persona');
      final instance1 = ObjectInstance(id: 1, classSymbol: cls);
      final instance2 = ObjectInstance(id: 2, classSymbol: cls);

      final val1a = ObjectValue(instance1);
      final val1b = ObjectValue(instance1);
      final val2 = ObjectValue(instance2);

      const evaluator = ComparisonEvaluator();

      expect(evaluator.equalValues(val1a, val1b), isTrue);
      expect(evaluator.equalValues(val1a, val2), isFalse);
    });
  });
}
