import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  Span makeSpan(int startOffset, int endOffset) {
    return Span(
      start: Position(line: 1, column: startOffset + 1, offset: startOffset),
      end: Position(line: 1, column: endOffset + 1, offset: endOffset),
    );
  }

  group('Statement Nodes', () {
    test('VariableDeclarationNode stores variables, type, and spans', () {
      final declarator1 = VariableDeclaratorNode(
        id: const NodeId(2),
        span: makeSpan(8, 9),
        name: 'a',
      );
      final declarator2 = VariableDeclaratorNode(
        id: const NodeId(3),
        span: makeSpan(11, 12),
        name: 'b',
      );
      final node = VariableDeclarationNode(
        id: const NodeId(1),
        span: makeSpan(0, 25),
        variables: [declarator1, declarator2],
        type: PrimitiveType.integer,
        typeSpan: makeSpan(18, 25),
      );

      expect(node.variables, [declarator1, declarator2]);
      expect(node.type, PrimitiveType.integer);
      expect(node.typeSpan, makeSpan(18, 25));
    });

    test('DimensionStatementNode stores array declarators and dimensions', () {
      final sizeExpr = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(16, 18),
        value: 10,
        type: PrimitiveType.integer,
      );
      final array1 = ArrayDeclaratorNode(
        id: const NodeId(2),
        span: makeSpan(10, 19),
        name: 'notas',
        nameSpan: makeSpan(10, 15),
        dimensions: [sizeExpr],
      );
      final node = DimensionStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 30),
        arrays: [array1],
        elementType: PrimitiveType.real,
        typeSpan: makeSpan(25, 29),
      );

      expect(node.arrays, [array1]);
      expect(node.elementType, PrimitiveType.real);
      expect(array1.name, 'notas');
      expect(array1.dimensions, [sizeExpr]);
    });

    test('AssignmentStatementNode stores target, value, and operator span', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 1),
        name: 'x',
      );
      final value = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(5, 7),
        value: 42,
        type: PrimitiveType.integer,
      );
      final node = AssignmentStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 7),
        target: target,
        value: value,
        assignmentOperatorSpan: makeSpan(2, 4),
      );

      expect(node.target, target);
      expect(node.value, value);
      expect(node.assignmentOperatorSpan, makeSpan(2, 4));
    });

    test('WriteStatementNode supports expressions and withoutNewline flag', () {
      final expr = LiteralExpressionNode(
        id: const NodeId(2),
        span: makeSpan(9, 16),
        value: 'Hola',
        type: PrimitiveType.string,
      );
      final node = WriteStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 28),
        expressions: [expr],
        withoutNewline: true,
        withoutNewlineSpan: makeSpan(17, 28),
      );

      expect(node.expressions, [expr]);
      expect(node.withoutNewline, isTrue);
      expect(node.withoutNewlineSpan, makeSpan(17, 28));
    });

    test('ReadStatementNode stores designator targets', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(5, 6),
        name: 'x',
      );
      final node = ReadStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 6),
        targets: [target],
      );

      expect(node.targets, [target]);
    });

    test('IfStatementNode stores condition, thenBody, and optional elseBody',
        () {
      final condition = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(3, 8),
        name: 'flag',
      );
      final nodeWithoutElse = IfStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 25),
        condition: condition,
        thenBody: const [],
      );

      expect(nodeWithoutElse.condition, condition);
      expect(nodeWithoutElse.thenBody, isEmpty);
      expect(nodeWithoutElse.elseBody, isNull);

      final nodeWithElse = IfStatementNode(
        id: const NodeId(3),
        span: makeSpan(0, 40),
        condition: condition,
        thenBody: const [],
        elseBody: const [],
        elseKeywordSpan: makeSpan(20, 24),
      );

      expect(nodeWithElse.elseBody, isNotNull);
      expect(nodeWithElse.elseKeywordSpan, makeSpan(20, 24));
    });

    test('SwitchStatementNode stores selector, cases, and defaultCase', () {
      final selector = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(6, 9),
        name: 'opc',
      );
      final label = LiteralExpressionNode(
        id: const NodeId(4),
        span: makeSpan(16, 17),
        value: 1,
        type: PrimitiveType.integer,
      );
      final case1 = SwitchCaseNode(
        id: const NodeId(3),
        span: makeSpan(16, 30),
        labels: [label],
        body: const [],
      );
      final defaultCase = SwitchDefaultNode(
        id: const NodeId(5),
        span: makeSpan(31, 45),
        body: const [],
      );

      final node = SwitchStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 55),
        selector: selector,
        cases: [case1],
        defaultCase: defaultCase,
      );

      expect(node.selector, selector);
      expect(node.cases, [case1]);
      expect(node.defaultCase, defaultCase);
      expect(case1.labels, [label]);
    });

    test('WhileStatementNode stores condition and body', () {
      final condition = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(9, 13),
        name: 'cond',
      );
      final node = WhileStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 30),
        condition: condition,
        body: const [],
      );

      expect(node.condition, condition);
      expect(node.body, isEmpty);
    });

    test('RepeatUntilStatementNode stores body, condition, and keyword span',
        () {
      final condition = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(17, 21),
        name: 'done',
      );
      final node = RepeatUntilStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 21),
        body: const [],
        condition: condition,
        untilKeywordSpan: makeSpan(7, 16),
      );

      expect(node.body, isEmpty);
      expect(node.condition, condition);
      expect(node.untilKeywordSpan, makeSpan(7, 16));
    });

    test('ForStatementNode stores control variable, bounds, step, and body',
        () {
      final variable = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(5, 6),
        name: 'i',
      );
      final from = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(10, 11),
        value: 1,
        type: PrimitiveType.integer,
      );
      final to = LiteralExpressionNode(
        id: const NodeId(4),
        span: makeSpan(18, 20),
        value: 10,
        type: PrimitiveType.integer,
      );
      final step = LiteralExpressionNode(
        id: const NodeId(5),
        span: makeSpan(30, 31),
        value: 2,
        type: PrimitiveType.integer,
      );

      final node = ForStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 50),
        variable: variable,
        from: from,
        to: to,
        step: step,
        body: const [],
      );

      expect(node.variable, variable);
      expect(node.from, from);
      expect(node.to, to);
      expect(node.step, step);
      expect(node.body, isEmpty);
    });

    test('ErrorStatementNode stores id and span', () {
      final node = ErrorStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 10),
      );

      expect(node.id, const NodeId(1));
      expect(node.span, makeSpan(0, 10));
    });
  });
}
