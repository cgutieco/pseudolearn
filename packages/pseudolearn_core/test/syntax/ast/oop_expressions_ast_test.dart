import 'package:pseudolearn_core/src/domain/node_id.dart';
import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/ast/structural_traversal.dart';
import 'package:test/test.dart';

void main() {
  final span = Span(
    start: const Position(line: 1, column: 1, offset: 0),
    end: const Position(line: 1, column: 10, offset: 9),
  );

  group('OOP Expression AST Nodes', () {
    test('InstantiationExpressionNode properties and traversal', () {
      final arg = LiteralExpressionNode(
        id: const NodeId(2),
        span: span,
        value: 42,
        type: PrimitiveType.integer,
      );
      final node = InstantiationExpressionNode(
        id: const NodeId(1),
        span: span,
        className: 'Persona',
        classNameSpan: span,
        arguments: [arg],
      );

      expect(node.className, equals('Persona'));
      expect(node.arguments, hasLength(1));
      expect(getChildNodes(node), equals([arg]));
    });

    test('MemberAccessExpressionNode properties and traversal', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: span,
        name: 'p',
      );
      final node = MemberAccessExpressionNode(
        id: const NodeId(1),
        span: span,
        target: target,
        memberName: 'nombre',
        memberSpan: span,
      );

      expect(node.memberName, equals('nombre'));
      expect(getChildNodes(node), equals([target]));
    });

    test('MethodCallExpressionNode properties and traversal', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: span,
        name: 'p',
      );
      final arg = LiteralExpressionNode(
        id: const NodeId(3),
        span: span,
        value: 'Hola',
        type: PrimitiveType.string,
      );
      final node = MethodCallExpressionNode(
        id: const NodeId(1),
        span: span,
        target: target,
        methodName: 'saludar',
        methodSpan: span,
        arguments: [arg],
      );

      expect(node.methodName, equals('saludar'));
      expect(getChildNodes(node), equals([target, arg]));
    });

    test('ThisExpressionNode and SuperExpressionNode properties and traversal',
        () {
      final thisNode = ThisExpressionNode(
        id: const NodeId(1),
        span: span,
      );
      final superNode = SuperExpressionNode(
        id: const NodeId(2),
        span: span,
      );

      expect(getChildNodes(thisNode), isEmpty);
      expect(getChildNodes(superNode), isEmpty);
    });

    test('MethodCallStatementNode properties and traversal', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: span,
        name: 'p',
      );
      final arg = LiteralExpressionNode(
        id: const NodeId(3),
        span: span,
        value: 1,
        type: PrimitiveType.integer,
      );
      final stmt = MethodCallStatementNode(
        id: const NodeId(1),
        span: span,
        target: target,
        methodName: 'imprimir',
        methodSpan: span,
        arguments: [arg],
      );

      expect(stmt.methodName, equals('imprimir'));
      expect(getChildNodes(stmt), equals([target, arg]));
    });
  });
}
