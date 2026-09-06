import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  Span makeSpan(int startOffset, int endOffset) {
    return Span(
      start: Position(line: 1, column: startOffset + 1, offset: startOffset),
      end: Position(line: 1, column: endOffset + 1, offset: endOffset),
    );
  }

  group('Structural Traversal - Children Source Order', () {
    test('AlgorithmNode returns body statements in order', () {
      final stmt1 = ErrorStatementNode(
        id: const NodeId(2),
        span: makeSpan(10, 15),
      );
      final stmt2 = ErrorStatementNode(
        id: const NodeId(3),
        span: makeSpan(16, 20),
      );
      final node = AlgorithmNode(
        id: const NodeId(1),
        span: makeSpan(0, 30),
        name: 'A',
        nameSpan: makeSpan(8, 9),
        body: [stmt1, stmt2],
      );

      expect(getChildNodes(node), [stmt1, stmt2]);
    });

    test('VariableDeclarationNode returns variable declarators in order', () {
      final v1 = VariableDeclaratorNode(
        id: const NodeId(2),
        span: makeSpan(8, 9),
        name: 'a',
      );
      final v2 = VariableDeclaratorNode(
        id: const NodeId(3),
        span: makeSpan(11, 12),
        name: 'b',
      );
      final node = VariableDeclarationNode(
        id: const NodeId(1),
        span: makeSpan(0, 25),
        variables: [v1, v2],
        type: PrimitiveType.integer,
        typeSpan: makeSpan(18, 25),
      );

      expect(getChildNodes(node), [v1, v2]);
    });

    test('DimensionStatementNode returns array declarators in order', () {
      final dim = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(16, 18),
        value: 10,
        type: PrimitiveType.integer,
      );
      final arr = ArrayDeclaratorNode(
        id: const NodeId(2),
        span: makeSpan(10, 19),
        name: 'arr',
        nameSpan: makeSpan(10, 13),
        dimensions: [dim],
      );
      final node = DimensionStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 30),
        arrays: [arr],
        elementType: PrimitiveType.integer,
        typeSpan: makeSpan(20, 27),
      );

      expect(getChildNodes(node), [arr]);
      expect(getChildNodes(arr), [dim]);
    });

    test('AssignmentStatementNode returns target then value', () {
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 1),
        name: 'x',
      );
      final value = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(5, 6),
        value: 1,
        type: PrimitiveType.integer,
      );
      final node = AssignmentStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 6),
        target: target,
        value: value,
        assignmentOperatorSpan: makeSpan(2, 4),
      );

      expect(getChildNodes(node), [target, value]);
    });

    test('WriteStatementNode returns expressions in order', () {
      final e1 = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(9, 10),
        name: 'a',
      );
      final e2 = VariableExpressionNode(
        id: const NodeId(3),
        span: makeSpan(12, 13),
        name: 'b',
      );
      final node = WriteStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 13),
        expressions: [e1, e2],
      );

      expect(getChildNodes(node), [e1, e2]);
    });

    test('ReadStatementNode returns targets in order', () {
      final t1 = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(5, 6),
        name: 'x',
      );
      final node = ReadStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 6),
        targets: [t1],
      );

      expect(getChildNodes(node), [t1]);
    });

    test('IfStatementNode returns condition, thenBody, and elseBody in order',
        () {
      final cond = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(3, 4),
        name: 'c',
      );
      final s1 = ErrorStatementNode(
        id: const NodeId(3),
        span: makeSpan(14, 18),
      );
      final s2 = ErrorStatementNode(
        id: const NodeId(4),
        span: makeSpan(25, 29),
      );
      final node = IfStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 35),
        condition: cond,
        thenBody: [s1],
        elseBody: [s2],
        elseKeywordSpan: makeSpan(19, 23),
      );

      expect(getChildNodes(node), [cond, s1, s2]);
    });

    test(
        'SwitchStatementNode returns selector, cases, and defaultCase in order',
        () {
      final sel = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(6, 7),
        name: 'x',
      );
      final lbl = LiteralExpressionNode(
        id: const NodeId(4),
        span: makeSpan(14, 15),
        value: 1,
        type: PrimitiveType.integer,
      );
      final bodyStmt = ErrorStatementNode(
        id: const NodeId(5),
        span: makeSpan(18, 22),
      );
      final case1 = SwitchCaseNode(
        id: const NodeId(3),
        span: makeSpan(14, 22),
        labels: [lbl],
        body: [bodyStmt],
      );
      final defStmt = ErrorStatementNode(
        id: const NodeId(7),
        span: makeSpan(35, 39),
      );
      final defaultCase = SwitchDefaultNode(
        id: const NodeId(6),
        span: makeSpan(23, 39),
        body: [defStmt],
      );
      final node = SwitchStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 50),
        selector: sel,
        cases: [case1],
        defaultCase: defaultCase,
      );

      expect(getChildNodes(node), [sel, case1, defaultCase]);
      expect(getChildNodes(case1), [lbl, bodyStmt]);
      expect(getChildNodes(defaultCase), [defStmt]);
    });

    test('WhileStatementNode returns condition then body', () {
      final cond = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(9, 10),
        name: 'c',
      );
      final stmt = ErrorStatementNode(
        id: const NodeId(3),
        span: makeSpan(17, 20),
      );
      final node = WhileStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 30),
        condition: cond,
        body: [stmt],
      );

      expect(getChildNodes(node), [cond, stmt]);
    });

    test('RepeatUntilStatementNode returns body THEN condition in source order',
        () {
      final stmt = ErrorStatementNode(
        id: const NodeId(2),
        span: makeSpan(8, 12),
      );
      final cond = VariableExpressionNode(
        id: const NodeId(3),
        span: makeSpan(23, 24),
        name: 'c',
      );
      final node = RepeatUntilStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 24),
        body: [stmt],
        condition: cond,
        untilKeywordSpan: makeSpan(13, 22),
      );

      expect(getChildNodes(node), [stmt, cond]);
    });

    test('ForStatementNode returns variable, from, to, step, body in order',
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
      final stmt = ErrorStatementNode(
        id: const NodeId(6),
        span: makeSpan(40, 45),
      );

      final node = ForStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 55),
        variable: variable,
        from: from,
        to: to,
        step: step,
        body: [stmt],
      );

      expect(getChildNodes(node), [variable, from, to, step, stmt]);
    });

    test('Operator and call expressions return children in order', () {
      final operand = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(1, 2),
        name: 'x',
      );
      final unary = UnaryExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 2),
        operator: UnaryOperator.negate,
        operand: operand,
        operatorSpan: makeSpan(0, 1),
      );
      expect(getChildNodes(unary), [operand]);

      final right = VariableExpressionNode(
        id: const NodeId(3),
        span: makeSpan(4, 5),
        name: 'y',
      );
      final binary = BinaryExpressionNode(
        id: const NodeId(4),
        span: makeSpan(0, 5),
        left: operand,
        operator: BinaryOperator.add,
        right: right,
        operatorSpan: makeSpan(2, 3),
      );
      expect(getChildNodes(binary), [operand, right]);

      final paren = ParenthesizedExpressionNode(
        id: const NodeId(5),
        span: makeSpan(0, 7),
        expression: binary,
      );
      expect(getChildNodes(paren), [binary]);

      final arrAccess = ArrayAccessExpressionNode(
        id: const NodeId(6),
        span: makeSpan(0, 8),
        target: operand,
        indices: [right],
      );
      expect(getChildNodes(arrAccess), [operand, right]);

      final call = FunctionCallExpressionNode(
        id: const NodeId(7),
        span: makeSpan(0, 6),
        name: 'rc',
        nameSpan: makeSpan(0, 2),
        arguments: [operand],
      );
      expect(getChildNodes(call), [operand]);
    });

    test('Leaf nodes return empty list, not null', () {
      final varDecl = VariableDeclaratorNode(
        id: const NodeId(1),
        span: makeSpan(0, 1),
        name: 'x',
      );
      final lit = LiteralExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 1),
        value: 1,
        type: PrimitiveType.integer,
      );
      final variable = VariableExpressionNode(
        id: const NodeId(3),
        span: makeSpan(0, 1),
        name: 'x',
      );
      final err = ErrorStatementNode(
        id: const NodeId(4),
        span: makeSpan(0, 1),
      );

      expect(getChildNodes(varDecl), isEmpty);
      expect(getChildNodes(lit), isEmpty);
      expect(getChildNodes(variable), isEmpty);
      expect(getChildNodes(err), isEmpty);
    });
  });

  group('Structural Traversal - Utilities and Edge Cases', () {
    test('findInnermostNodeAt finds deepest node containing position', () {
      final lit = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(5, 7),
        value: 42,
        type: PrimitiveType.integer,
      );
      final target = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 1),
        name: 'x',
      );
      final assignment = AssignmentStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 7),
        target: target,
        value: lit,
        assignmentOperatorSpan: makeSpan(2, 4),
      );

      expect(
        findInnermostNodeAt(
            assignment, const Position(line: 1, column: 1, offset: 0)),
        target,
      );
      expect(
        findInnermostNodeAt(
            assignment, const Position(line: 1, column: 6, offset: 5)),
        lit,
      );
      expect(
        findInnermostNodeAt(
            assignment, const Position(line: 1, column: 3, offset: 2)),
        assignment,
      );
      expect(
        findInnermostNodeAt(
            assignment, const Position(line: 1, column: 10, offset: 9)),
        isNull,
      );
    });

    test('collectNodeIds collects all unique IDs in subtree', () {
      final e1 = LiteralExpressionNode(
        id: const NodeId(3),
        span: makeSpan(0, 1),
        value: 1,
        type: PrimitiveType.integer,
      );
      final e2 = LiteralExpressionNode(
        id: const NodeId(4),
        span: makeSpan(2, 3),
        value: 2,
        type: PrimitiveType.integer,
      );
      final bin = BinaryExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 3),
        left: e1,
        operator: BinaryOperator.add,
        right: e2,
        operatorSpan: makeSpan(1, 2),
      );
      final stmt = WriteStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 10),
        expressions: [bin],
      );

      final ids = collectNodeIds(stmt);
      expect(ids,
          {const NodeId(1), const NodeId(2), const NodeId(3), const NodeId(4)});
    });

    test('calculateEnclosingSpan merges children spans and matches root', () {
      final lit = LiteralExpressionNode(
        id: const NodeId(2),
        span: makeSpan(10, 12),
        value: 99,
        type: PrimitiveType.integer,
      );
      final stmt = WriteStatementNode(
        id: const NodeId(1),
        span: makeSpan(0, 20),
        expressions: [lit],
      );

      final enclosing = calculateEnclosingSpan(stmt);
      expect(enclosing, makeSpan(0, 20));
    });

    test('collectNodesOfType collects instances of matching type', () {
      final v1 = VariableExpressionNode(
        id: const NodeId(2),
        span: makeSpan(0, 1),
        name: 'a',
      );
      final v2 = VariableExpressionNode(
        id: const NodeId(3),
        span: makeSpan(4, 5),
        name: 'b',
      );
      final bin = BinaryExpressionNode(
        id: const NodeId(1),
        span: makeSpan(0, 5),
        left: v1,
        operator: BinaryOperator.add,
        right: v2,
        operatorSpan: makeSpan(2, 3),
      );

      final vars = collectNodesOfType<VariableExpressionNode>(bin);
      expect(vars, [v1, v2]);
      final lits = collectNodesOfType<LiteralExpressionNode>(bin);
      expect(lits, isEmpty);
    });

    test('deeply nested tree traversal (10 levels of nesting)', () {
      ExpressionNode expr = LiteralExpressionNode(
        id: const NodeId(100),
        span: makeSpan(50, 51),
        value: 1,
        type: PrimitiveType.integer,
      );
      for (var i = 99; i >= 90; i--) {
        expr = ParenthesizedExpressionNode(
          id: NodeId(i),
          span: makeSpan(i - 90, (100 - i) + 50),
          expression: expr,
        );
      }

      final ids = collectNodeIds(expr);
      expect(ids, hasLength(11));
      expect(ids.contains(const NodeId(100)), isTrue);
      expect(ids.contains(const NodeId(90)), isTrue);
    });

    test(
        'Comprehensive synthetic program covering ALL structured AST node types',
        () {
      final varA = VariableDeclaratorNode(
        id: const NodeId(2),
        span: makeSpan(8, 9),
        name: 'a',
      );
      final varDecl = VariableDeclarationNode(
        id: const NodeId(1),
        span: makeSpan(0, 20),
        variables: [varA],
        type: PrimitiveType.integer,
        typeSpan: makeSpan(13, 20),
      );

      final dimExpr = LiteralExpressionNode(
        id: const NodeId(5),
        span: makeSpan(35, 37),
        value: 10,
        type: PrimitiveType.integer,
      );
      final arrDecl = ArrayDeclaratorNode(
        id: const NodeId(4),
        span: makeSpan(30, 38),
        name: 'arr',
        nameSpan: makeSpan(30, 33),
        dimensions: [dimExpr],
      );
      final dimStmt = DimensionStatementNode(
        id: const NodeId(3),
        span: makeSpan(21, 48),
        arrays: [arrDecl],
        elementType: PrimitiveType.real,
        typeSpan: makeSpan(44, 48),
      );

      final varTarget = VariableExpressionNode(
        id: const NodeId(7),
        span: makeSpan(50, 51),
        name: 'a',
      );
      final assignVal = LiteralExpressionNode(
        id: const NodeId(8),
        span: makeSpan(55, 56),
        value: 5,
        type: PrimitiveType.integer,
      );
      final assignStmt = AssignmentStatementNode(
        id: const NodeId(6),
        span: makeSpan(50, 56),
        target: varTarget,
        value: assignVal,
        assignmentOperatorSpan: makeSpan(52, 54),
      );

      final readTarget = ArrayAccessExpressionNode(
        id: const NodeId(10),
        span: makeSpan(63, 69),
        target: varTarget,
        indices: [assignVal],
      );
      final readStmt = ReadStatementNode(
        id: const NodeId(9),
        span: makeSpan(58, 69),
        targets: [readTarget],
      );

      final unaryExpr = UnaryExpressionNode(
        id: const NodeId(13),
        span: makeSpan(80, 82),
        operator: UnaryOperator.positive,
        operand: assignVal,
        operatorSpan: makeSpan(80, 81),
      );
      final callExpr = FunctionCallExpressionNode(
        id: const NodeId(14),
        span: makeSpan(85, 91),
        name: 'rc',
        nameSpan: makeSpan(85, 87),
        arguments: [assignVal],
      );
      final binExpr = BinaryExpressionNode(
        id: const NodeId(15),
        span: makeSpan(80, 91),
        left: unaryExpr,
        operator: BinaryOperator.multiply,
        right: callExpr,
        operatorSpan: makeSpan(83, 84),
      );
      final parenExpr = ParenthesizedExpressionNode(
        id: const NodeId(12),
        span: makeSpan(79, 92),
        expression: binExpr,
      );
      final writeStmt = WriteStatementNode(
        id: const NodeId(11),
        span: makeSpan(70, 103),
        expressions: [parenExpr],
        withoutNewline: true,
        withoutNewlineSpan: makeSpan(93, 103),
      );

      final ifStmt = IfStatementNode(
        id: const NodeId(16),
        span: makeSpan(105, 130),
        condition: varTarget,
        thenBody: [assignStmt],
        elseBody: [writeStmt],
        elseKeywordSpan: makeSpan(118, 122),
      );

      final switchCase = SwitchCaseNode(
        id: const NodeId(19),
        span: makeSpan(145, 160),
        labels: [assignVal],
        body: [assignStmt],
      );
      final switchDef = SwitchDefaultNode(
        id: const NodeId(20),
        span: makeSpan(161, 175),
        body: [writeStmt],
      );
      final switchStmt = SwitchStatementNode(
        id: const NodeId(17),
        span: makeSpan(132, 185),
        selector: varTarget,
        cases: [switchCase],
        defaultCase: switchDef,
      );

      final whileStmt = WhileStatementNode(
        id: const NodeId(21),
        span: makeSpan(187, 210),
        condition: varTarget,
        body: [assignStmt],
      );

      final repeatStmt = RepeatUntilStatementNode(
        id: const NodeId(22),
        span: makeSpan(212, 235),
        body: [assignStmt],
        condition: varTarget,
        untilKeywordSpan: makeSpan(225, 233),
      );

      final forStmt = ForStatementNode(
        id: const NodeId(23),
        span: makeSpan(237, 270),
        variable: varTarget,
        from: assignVal,
        to: assignVal,
        step: assignVal,
        body: [assignStmt],
      );

      final errStmt = ErrorStatementNode(
        id: const NodeId(24),
        span: makeSpan(272, 280),
      );

      final program = AlgorithmNode(
        id: const NodeId(0),
        span: makeSpan(0, 300),
        name: 'Todo',
        nameSpan: makeSpan(8, 12),
        body: [
          varDecl,
          dimStmt,
          assignStmt,
          readStmt,
          writeStmt,
          ifStmt,
          switchStmt,
          whileStmt,
          repeatStmt,
          forStmt,
          errStmt,
        ],
      );

      final allIds = collectNodeIds(program);
      expect(allIds.contains(const NodeId(0)), isTrue);
      expect(allIds.contains(const NodeId(24)), isTrue);
      expect(allIds.length, greaterThanOrEqualTo(24));
    });
  });
}
