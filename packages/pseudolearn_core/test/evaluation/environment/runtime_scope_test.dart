import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/evaluation/environment/runtime_scope.dart';
import 'package:pseudolearn_core/src/evaluation/environment/variable_cell.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/semantic/symbols/symbol.dart';
import 'package:test/test.dart';

void main() {
  final span = Span(
    start: const Position(line: 1, column: 1, offset: 0),
    end: const Position(line: 1, column: 2, offset: 1),
  );

  VariableSymbol makeSymbol(String name) => VariableSymbol(
        name: name,
        span: span,
        primitiveType: PrimitiveType.integer,
      );

  group('RuntimeScope', () {
    test('declares and retrieves variables by Symbol identity', () {
      final scope = RuntimeScope();
      final a = makeSymbol('x');
      final b = makeSymbol('x');

      scope.cellFor(a).assign(const RealValue(1.0));
      scope.cellFor(b).assign(const StringValue('otro'));

      expect(scope.cellFor(a).value, equals(const RealValue(1.0)));
      expect(scope.cellFor(b).value, equals(const StringValue('otro')));
    });

    test('bind aliases an existing cell instead of creating a fresh one', () {
      final scope = RuntimeScope();
      final a = makeSymbol('param');
      final externalCell = VariableCell();
      externalCell.assign(const StringValue('original'));

      scope.bind(a, externalCell);

      expect(scope.cellFor(a).value, equals(const StringValue('original')));
      scope.cellFor(a).assign(const StringValue('modificado'));
      expect(externalCell.value, equals(const StringValue('modificado')));
    });
  });
}
