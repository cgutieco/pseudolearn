import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/node_id.dart';
import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/profile/builtin_function.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/domain/severity.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/evaluation/builtins/builtin_invoker.dart';
import 'package:pseudolearn_core/src/evaluation/environment/object_instance.dart';
import 'package:pseudolearn_core/src/evaluation/values/random_source.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/evaluation/values/value_formatter.dart';
import 'package:pseudolearn_core/src/semantic/symbols/symbol.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:test/test.dart';

void main() {
  final span = Span(
    start: const Position(line: 1, column: 1, offset: 0),
    end: const Position(line: 1, column: 2, offset: 1),
  );

  BuiltinInvoker makeInvoker() => BuiltinInvoker(
        random: SeededRandomSource(1),
        formatter: const ValueFormatter(ClassicSpanishProfile.strict()),
        severityFor: (code) => Severity.error,
      );

  group('BuiltinInvoker: happy path', () {
    test('squareRoot of a perfect square', () {
      final result = makeInvoker().invoke(
        BuiltinFunction.squareRoot,
        [IntegerValue(PseudoInteger.fromInt(9))],
        span,
      );
      expect(result.diagnostic, isNull);
      expect(result.value, equals(const RealValue(3.0)));
    });

    test('length of a string', () {
      final result = makeInvoker().invoke(
        BuiltinFunction.length,
        [const StringValue('hola')],
        span,
      );
      expect(result.value, equals(IntegerValue(PseudoInteger.fromInt(4))));
    });

    test('random takes no arguments and stays in range', () {
      final result =
          makeInvoker().invoke(BuiltinFunction.random, const [], span);
      final value = (result.value as RealValue).value;
      expect(value, greaterThanOrEqualTo(0.0));
      expect(value, lessThan(1.0));
    });
  });

  group('BuiltinInvoker: failure path, with span and diagnostic code', () {
    test(
        'naturalLogarithm of zero fails with nonFiniteRealResult at the call span',
        () {
      final result = makeInvoker().invoke(
        BuiltinFunction.naturalLogarithm,
        [IntegerValue(PseudoInteger.zero)],
        span,
      );
      expect(result.value, isNull);
      expect(
          result.diagnostic!.code, equals(DiagnosticCode.nonFiniteRealResult));
      expect(result.diagnostic!.span, equals(span));
    });

    test(
        'textToInteger of non-numeric text fails with stringToNumberConversionFailed',
        () {
      final result = makeInvoker().invoke(
        BuiltinFunction.textToInteger,
        [const StringValue('hola')],
        span,
      );
      expect(result.diagnostic!.code,
          equals(DiagnosticCode.stringToNumberConversionFailed));
    });

    test('characterAt out of range fails with stringPositionOutOfRange', () {
      final result = makeInvoker().invoke(
        BuiltinFunction.characterAt,
        [const StringValue('hola'), IntegerValue(PseudoInteger.fromInt(10))],
        span,
      );
      expect(result.diagnostic!.code,
          equals(DiagnosticCode.stringPositionOutOfRange));
    });

    test(
        'characterFromCode with an invalid code fails with invalidCharacterCode',
        () {
      final result = makeInvoker().invoke(
        BuiltinFunction.characterFromCode,
        [IntegerValue(PseudoInteger.fromInt(-1))],
        span,
      );
      expect(
          result.diagnostic!.code, equals(DiagnosticCode.invalidCharacterCode));
    });

    test(
        'truncate of a value beyond the 64-bit range fails with integerOverflow',
        () {
      final result = makeInvoker().invoke(
        BuiltinFunction.truncate,
        [const RealValue(1e30)],
        span,
      );
      expect(result.diagnostic!.code, equals(DiagnosticCode.integerOverflow));
    });
  });

  test('shallowCopy clones ObjectInstance with new instance id', () {
    var idCounter = 1;
    final invoker = BuiltinInvoker(
      random: SeededRandomSource(1),
      formatter: const ValueFormatter(ClassicSpanishProfile.strict()),
      severityFor: (code) => Severity.error,
      nextInstanceId: () => ++idCounter,
    );
    final classNode = ClassNode(
      id: const NodeId(1),
      span: span,
      name: 'TestClass',
      nameSpan: span,
      members: const <ClassMemberNode>[],
    );
    final instance = ObjectInstance(
      id: 1,
      classSymbol: ClassSymbol(
        name: 'TestClass',
        span: span,
        declarationNode: classNode,
      ),
    );
    final original = ObjectValue(instance);
    final result = invoker.invoke(BuiltinFunction.shallowCopy, [original], span);

    expect(result.diagnostic, isNull);
    expect(result.value, isA<ObjectValue>());
    final clone = result.value as ObjectValue;
    expect(clone.instance.id, equals(2));
    expect(clone.instance.classSymbol.name, equals('TestClass'));
  });
}
