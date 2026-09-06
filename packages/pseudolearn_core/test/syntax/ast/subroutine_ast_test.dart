import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Subroutine AST Nodes and Structural Traversal', () {
    final generator = NodeIdGenerator();
    final span = Span(
      start: const Position(offset: 0, line: 1, column: 1),
      end: const Position(offset: 20, line: 1, column: 21),
    );

    test('constructs ParameterNode with properties', () {
      final param = ParameterNode(
        id: generator.next(),
        span: span,
        name: 'notas',
        nameSpan: span,
        dimensionCount: 1,
        type: PrimitiveType.integer,
        typeSpan: span,
        passingMode: ParameterPassingMode.byReference,
        passingModeSpan: span,
      );

      expect(param.name, equals('notas'));
      expect(param.dimensionCount, equals(1));
      expect(param.type, equals(PrimitiveType.integer));
      expect(param.passingMode, equals(ParameterPassingMode.byReference));
      expect(getChildNodes(param), isEmpty);
    });

    test('constructs ReturnStatementNode with optional value', () {
      final literal = LiteralExpressionNode(
        id: generator.next(),
        span: span,
        type: PrimitiveType.integer,
        value: 42,
      );
      final returnStmt = ReturnStatementNode(
        id: generator.next(),
        span: span,
        value: literal,
      );

      expect(returnStmt.value, equals(literal));
      expect(getChildNodes(returnStmt), equals([literal]));

      final emptyReturn = ReturnStatementNode(
        id: generator.next(),
        span: span,
      );
      expect(getChildNodes(emptyReturn), isEmpty);
    });

    test('constructs CallStatementNode with arguments', () {
      final arg1 = LiteralExpressionNode(
        id: generator.next(),
        span: span,
        type: PrimitiveType.integer,
        value: 1,
      );
      final arg2 = LiteralExpressionNode(
        id: generator.next(),
        span: span,
        type: PrimitiveType.integer,
        value: 2,
      );
      final callStmt = CallStatementNode(
        id: generator.next(),
        span: span,
        name: 'Sumar',
        nameSpan: span,
        arguments: [arg1, arg2],
      );

      expect(callStmt.name, equals('Sumar'));
      expect(callStmt.arguments, equals([arg1, arg2]));
      expect(getChildNodes(callStmt), equals([arg1, arg2]));
    });

    test(
        'constructs SubroutineDeclarationNode and returns children in textual order',
        () {
      final param = ParameterNode(
        id: generator.next(),
        span: span,
        name: 'x',
        nameSpan: span,
        type: PrimitiveType.integer,
      );
      final returnStmt = ReturnStatementNode(
        id: generator.next(),
        span: span,
      );
      final sub = SubroutineDeclarationNode(
        id: generator.next(),
        span: span,
        name: 'Procesar',
        nameSpan: span,
        parameters: [param],
        returnType: null,
        body: [returnStmt],
      );

      expect(sub.name, equals('Procesar'));
      expect(sub.parameters, equals([param]));
      expect(getChildNodes(sub), equals([param, returnStmt]));
    });

    test('SourceUnitNode returns top level declarations in textual order', () {
      final sub = SubroutineDeclarationNode(
        id: generator.next(),
        span: Span(
          start: const Position(offset: 0, line: 1, column: 1),
          end: const Position(offset: 30, line: 2, column: 15),
        ),
        name: 'Saludar',
        nameSpan: span,
        parameters: const [],
        body: const [],
      );
      final alg = AlgorithmNode(
        id: generator.next(),
        span: Span(
          start: const Position(offset: 35, line: 4, column: 1),
          end: const Position(offset: 60, line: 5, column: 12),
        ),
        name: 'Principal',
        nameSpan: span,
        body: const [],
      );
      final unit = SourceUnitNode(
        id: generator.next(),
        span: Span(
          start: const Position(offset: 0, line: 1, column: 1),
          end: const Position(offset: 60, line: 5, column: 12),
        ),
        algorithm: alg,
        subroutines: [sub],
        declarations: [sub, alg],
      );

      expect(getChildNodes(unit), equals([sub, alg]));
    });

    test('collectNodeIds collects all ids across source unit with subroutines',
        () {
      final param = ParameterNode(
        id: generator.next(),
        span: span,
        name: 'n',
        nameSpan: span,
      );
      final returnStmt = ReturnStatementNode(
        id: generator.next(),
        span: span,
      );
      final sub = SubroutineDeclarationNode(
        id: generator.next(),
        span: span,
        name: 'Sub',
        nameSpan: span,
        parameters: [param],
        body: [returnStmt],
      );
      final alg = AlgorithmNode(
        id: generator.next(),
        span: span,
        name: 'Alg',
        nameSpan: span,
        body: const [],
      );
      final unit = SourceUnitNode(
        id: generator.next(),
        span: span,
        algorithm: alg,
        subroutines: [sub],
        declarations: [sub, alg],
      );

      final collected = collectNodeIds(unit);
      expect(
        collected,
        containsAll([unit.id, sub.id, param.id, returnStmt.id, alg.id]),
      );
      expect(collected.length, equals(5));
    });
  });
}
