import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('isSuperConstructorCall', () {
    final span = Span.zero;
    const id = NodeId(1);

    test('returns true for Super.Constructor(...) with arguments', () {
      final stmt = MethodCallStatementNode(
        id: id,
        span: span,
        target: SuperExpressionNode(id: const NodeId(2), span: span),
        methodName: 'Constructor',
        methodSpan: span,
        arguments: [
          LiteralExpressionNode(
            id: const NodeId(3),
            span: span,
            value: 42,
            type: PrimitiveType.integer,
          ),
        ],
      );

      expect(isSuperConstructorCall(stmt), isTrue);
    });

    test('returns true for Super.constructor case-insensitively', () {
      final stmt = MethodCallStatementNode(
        id: id,
        span: span,
        target: SuperExpressionNode(id: const NodeId(2), span: span),
        methodName: 'constructor',
        methodSpan: span,
        arguments: const [],
      );

      expect(isSuperConstructorCall(stmt), isTrue);
    });

    test('returns false for Super.Describir()', () {
      final stmt = MethodCallStatementNode(
        id: id,
        span: span,
        target: SuperExpressionNode(id: const NodeId(2), span: span),
        methodName: 'Describir',
        methodSpan: span,
        arguments: const [],
      );

      expect(isSuperConstructorCall(stmt), isFalse);
    });

    test('returns false for Este.Constructor()', () {
      final stmt = MethodCallStatementNode(
        id: id,
        span: span,
        target: ThisExpressionNode(id: const NodeId(2), span: span),
        methodName: 'Constructor',
        methodSpan: span,
        arguments: const [],
      );

      expect(isSuperConstructorCall(stmt), isFalse);
    });

    test('returns false for regular variable target x.Constructor()', () {
      final stmt = MethodCallStatementNode(
        id: id,
        span: span,
        target: VariableExpressionNode(id: const NodeId(2), span: span, name: 'x'),
        methodName: 'Constructor',
        methodSpan: span,
        arguments: const [],
      );

      expect(isSuperConstructorCall(stmt), isFalse);
    });

    test('returns false for other statement types', () {
      final stmt = ReturnStatementNode(
        id: id,
        span: span,
        value: null,
      );

      expect(isSuperConstructorCall(stmt), isFalse);
    });
  });
}
