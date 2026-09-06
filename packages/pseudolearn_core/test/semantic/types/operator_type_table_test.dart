import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/semantic/types/operator_type_table.dart';
import 'package:pseudolearn_core/src/semantic/types/semantic_type.dart';
import 'package:pseudolearn_core/src/syntax/ast/operators.dart';
import 'package:test/test.dart';

void main() {
  const table = OperatorTypeTable();
  const entero = PrimitiveSemanticType(PrimitiveType.integer);
  const real = PrimitiveSemanticType(PrimitiveType.real);
  const logico = PrimitiveSemanticType(PrimitiveType.boolean);
  const caracter = PrimitiveSemanticType(PrimitiveType.character);
  const cadena = PrimitiveSemanticType(PrimitiveType.string);

  group('OperatorTypeTable Unary Operators', () {
    test('unary + and - keep numeric types', () {
      expect(table.computeUnary(UnaryOperator.positive, entero).resultType,
          entero);
      expect(table.computeUnary(UnaryOperator.negate, real).resultType, real);
      expect(
        table.computeUnary(UnaryOperator.positive, logico).diagnosticCode,
        DiagnosticCode.incompatibleOperandTypes,
      );
    });

    test('unary NO requires boolean', () {
      expect(table.computeUnary(UnaryOperator.not, logico).resultType, logico);
      expect(
        table.computeUnary(UnaryOperator.not, entero).diagnosticCode,
        DiagnosticCode.incompatibleOperandTypes,
      );
    });
  });

  group('OperatorTypeTable Binary Arithmetic Operators (12.3)', () {
    test('addition of integers gives integer, mixed gives real', () {
      expect(table.computeBinary(BinaryOperator.add, entero, entero).resultType,
          entero);
      expect(table.computeBinary(BinaryOperator.add, entero, real).resultType,
          real);
      expect(table.computeBinary(BinaryOperator.add, real, entero).resultType,
          real);
      expect(
          table.computeBinary(BinaryOperator.add, real, real).resultType, real);
    });

    test('addition as concatenation requires strings/chars or gives error', () {
      expect(table.computeBinary(BinaryOperator.add, cadena, cadena).resultType,
          cadena);
      expect(
          table.computeBinary(BinaryOperator.add, cadena, caracter).resultType,
          cadena);
      expect(
          table
              .computeBinary(BinaryOperator.add, caracter, caracter)
              .resultType,
          cadena);

      expect(
        table.computeBinary(BinaryOperator.add, entero, cadena).diagnosticCode,
        DiagnosticCode.cannotConcatenateNumberWithText,
      );
      expect(
        table.computeBinary(BinaryOperator.add, cadena, real).diagnosticCode,
        DiagnosticCode.cannotConcatenateNumberWithText,
      );
    });

    test('division gives REAL ALWAYS, even for two integers (12.3)', () {
      expect(
          table.computeBinary(BinaryOperator.divide, entero, entero).resultType,
          real);
      expect(table.computeBinary(BinaryOperator.divide, real, real).resultType,
          real);
    });

    test(
        'div and mod accept ONLY integers, reject real operands with specific diagnostic (12.3)',
        () {
      expect(
          table
              .computeBinary(BinaryOperator.integerDivide, entero, entero)
              .resultType,
          entero);
      expect(
          table.computeBinary(BinaryOperator.modulo, entero, entero).resultType,
          entero);

      expect(
        table
            .computeBinary(BinaryOperator.integerDivide, real, entero)
            .diagnosticCode,
        DiagnosticCode.divOrModWithRealOperand,
      );
      expect(
        table.computeBinary(BinaryOperator.modulo, entero, real).diagnosticCode,
        DiagnosticCode.divOrModWithRealOperand,
      );
    });

    test('power operator preserves integer for (entero, entero)', () {
      expect(
          table.computeBinary(BinaryOperator.power, entero, entero).resultType,
          entero);
      expect(table.computeBinary(BinaryOperator.power, entero, real).resultType,
          real);
    });
  });

  group('OperatorTypeTable Relational & Equality Operators', () {
    test(
        'relational order operators reject booleans with noOrderBetweenBooleans (12.3)',
        () {
      expect(
        table
            .computeBinary(BinaryOperator.lessThan, logico, logico)
            .diagnosticCode,
        DiagnosticCode.noOrderBetweenBooleans,
      );
      expect(
        table
            .computeBinary(BinaryOperator.greaterThanOrEqual, logico, logico)
            .diagnosticCode,
        DiagnosticCode.noOrderBetweenBooleans,
      );
    });

    test('relational order operators accept numbers, chars, strings', () {
      expect(
          table.computeBinary(BinaryOperator.lessThan, entero, real).resultType,
          logico);
      expect(
          table
              .computeBinary(BinaryOperator.greaterThan, caracter, caracter)
              .resultType,
          logico);
      expect(
          table
              .computeBinary(BinaryOperator.lessThanOrEqual, cadena, cadena)
              .resultType,
          logico);
    });

    test(
        'equality on two reals produces realEqualityComparison warning (12.3, 12.12)',
        () {
      final res = table.computeBinary(BinaryOperator.equal, real, real);
      expect(res.resultType, logico);
      expect(res.warningCode, DiagnosticCode.realEqualityComparison);
    });

    test('equality on integers or strings has no warning', () {
      final res = table.computeBinary(BinaryOperator.equal, entero, entero);
      expect(res.resultType, logico);
      expect(res.warningCode, isNull);
    });
  });

  group('OperatorTypeTable Logical Operators', () {
    test('AND and OR accept only booleans', () {
      expect(table.computeBinary(BinaryOperator.and, logico, logico).resultType,
          logico);
      expect(table.computeBinary(BinaryOperator.or, logico, logico).resultType,
          logico);
      expect(
        table.computeBinary(BinaryOperator.and, entero, logico).diagnosticCode,
        DiagnosticCode.incompatibleOperandTypes,
      );
    });
  });

  group('Mathematical Identity for div and mod with negative operands', () {
    test(
        'truncation towards zero and remainder identity (a div b) * b + (a mod b) = a',
        () {
      int pseudoDiv(int a, int b) => a ~/ b;
      int pseudoMod(int a, int b) => a.remainder(b);

      const cases = [
        (7, 2),
        (-7, 2),
        (7, -2),
        (-7, -2),
        (-10, 3),
        (10, -3),
      ];

      for (final (a, b) in cases) {
        final q = pseudoDiv(a, b);
        final r = pseudoMod(a, b);
        expect(q * b + r, equals(a));
      }

      expect(pseudoDiv(-7, 2), equals(-3));
      expect(pseudoMod(-7, 2), equals(-1));
    });
  });
}
