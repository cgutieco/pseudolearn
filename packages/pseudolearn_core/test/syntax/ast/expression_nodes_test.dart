import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  Span makeSpan(int startOffset, int endOffset) {
    return Span(
      start: Position(line: 1, column: startOffset + 1, offset: startOffset),
      end: Position(line: 1, column: endOffset + 1, offset: endOffset),
    );
  }

  group('Expression Nodes', () {
    test('LiteralExpressionNode supports all primitive types', () {
      final intNode = LiteralExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 2),
        value: 42,
        type: PrimitiveType.integer,
      );
      final realNode = LiteralExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 4),
        value: 3.14,
        type: PrimitiveType.real,
      );
      final boolNode = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(0, 9),
        value: true,
        type: PrimitiveType.boolean,
      );
      final charNode = LiteralExpressionNode(
        id: const NodeId(4),
        span: makeSpan(0, 3),
        value: 'a',
        type: PrimitiveType.character,
      );
      final strNode = LiteralExpressionNode(
        id: const NodeId(5),
        span: makeSpan(0, 7),
        value: 'hello',
        type: PrimitiveType.string,
      );

      expect(intNode.value, 42);
      expect(intNode.type, PrimitiveType.integer);
      expect(realNode.value, 3.14);
      expect(realNode.type, PrimitiveType.real);
      expect(boolNode.value, true);
      expect(boolNode.type, PrimitiveType.boolean);
      expect(charNode.value, 'a');
      expect(charNode.type, PrimitiveType.character);
      expect(strNode.value, 'hello');
      expect(strNode.type, PrimitiveType.string);
    });

    test('VariableExpressionNode stores variable identifier name', () {
      final node = VariableExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 5),
        name: 'total',
      );

      expect(node.name, 'total');
    });

    test('UnaryExpressionNode stores operator, operand, and operator span', () {
      final operand = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(1, 2),
        name: 'x',
      );
      final node = UnaryExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 2),
        operator: UnaryOperator.negate,
        operand: operand,
        operatorSpan: makeSpan(0, 1),
      );

      expect(node.operator, UnaryOperator.negate);
      expect(node.operand, operand);
      expect(node.operatorSpan, makeSpan(0, 1));
    });

    test('BinaryExpressionNode stores left, operator, right, and operator span',
        () {
      final left = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 1),
        name: 'a',
      );
      final right = VariableExpressionNode(
        id: const NodeId(3),
        span: makeSpan(4, 5),
        name: 'b',
      );
      final node = BinaryExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 5),
        left: left,
        operator: BinaryOperator.add,
        right: right,
        operatorSpan: makeSpan(2, 3),
      );

      expect(node.left, left);
      expect(node.operator, BinaryOperator.add);
      expect(node.right, right);
      expect(node.operatorSpan, makeSpan(2, 3));
    });

    test('ParenthesizedExpressionNode wraps inner expression', () {
      final inner = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(1, 2),
        name: 'x',
      );
      final node = ParenthesizedExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 3),
        expression: inner,
      );

      expect(node.expression, inner);
    });

    test('ArrayAccessExpressionNode stores target and index expressions', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 5),
        name: 'notas',
      );
      final index1 = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(6, 7),
        value: 0,
        type: PrimitiveType.integer,
      );
      final index2 = LiteralExpressionNode(
        id: const NodeId(4),
        span: makeSpan(9, 10),
        value: 1,
        type: PrimitiveType.integer,
      );
      final node = ArrayAccessExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 11),
        target: target,
        indices: [index1, index2],
      );

      expect(node.target, target);
      expect(node.indices, [index1, index2]);
    });

    test('FunctionCallExpressionNode stores function name and arguments', () {
      final arg = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(3, 4),
        name: 'x',
      );
      final node = FunctionCallExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 5),
        name: 'rc',
        nameSpan: makeSpan(0, 2),
        arguments: [arg],
      );

      expect(node.name, 'rc');
      expect(node.nameSpan, makeSpan(0, 2));
      expect(node.arguments, [arg]);
    });
  });
}
