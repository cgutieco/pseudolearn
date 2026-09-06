import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/profile/language_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/ast/operators.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/expression_parse_result.dart';
import 'package:pseudolearn_core/src/syntax/parser/expression_parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

ExpressionParseResult parseExpressionSource(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.strict(),
}) {
  final lexer = Lexer(profile);
  final lexerResult = lexer.tokenize(source);
  final stream = TokenStream(lexerResult.tokens);
  final parser = ExpressionParser();
  return parser.parse(stream);
}

ExpressionNode parseValid(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.strict(),
}) {
  final result = parseExpressionSource(source, profile: profile);
  expect(result.diagnostics, isEmpty,
      reason: 'Expected no diagnostics for: $source');
  expect(result.expression, isNotNull,
      reason: 'Expected valid expression node for: $source');
  return result.expression!;
}

void main() {
  group('ExpressionParser precedence tests', () {
    test('Level 1 vs Level 2: unary binds tighter than power (-a ^ b)', () {
      final expr = parseValid('-a ^ b') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.power));
      expect(expr.left, isA<UnaryExpressionNode>());
      final leftUnary = expr.left as UnaryExpressionNode;
      expect(leftUnary.operator, equals(UnaryOperator.negate));
      expect((leftUnary.operand as VariableExpressionNode).name, equals('a'));
      expect((expr.right as VariableExpressionNode).name, equals('b'));
    });

    test('Level 2 vs Level 3: power binds tighter than multiply (a * b ^ c)',
        () {
      final expr = parseValid('a * b ^ c') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.multiply));
      expect((expr.left as VariableExpressionNode).name, equals('a'));
      expect(expr.right, isA<BinaryExpressionNode>());
      final rightPower = expr.right as BinaryExpressionNode;
      expect(rightPower.operator, equals(BinaryOperator.power));
    });

    test('Level 3 vs Level 4: multiply binds tighter than add (a + b * c)', () {
      final expr = parseValid('a + b * c') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.add));
      expect((expr.left as VariableExpressionNode).name, equals('a'));
      expect(expr.right, isA<BinaryExpressionNode>());
      final rightMult = expr.right as BinaryExpressionNode;
      expect(rightMult.operator, equals(BinaryOperator.multiply));
    });

    test('Level 4 vs Level 5: add binds tighter than lessThan (a < b + c)', () {
      final expr = parseValid('a < b + c') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.lessThan));
      expect((expr.left as VariableExpressionNode).name, equals('a'));
      expect(expr.right, isA<BinaryExpressionNode>());
      final rightAdd = expr.right as BinaryExpressionNode;
      expect(rightAdd.operator, equals(BinaryOperator.add));
    });

    test(
        'Level 5 vs Level 6: relational order binds tighter than equal (a < b = c > d)',
        () {
      final expr = parseValid('a < b = c > d') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.equal));
      expect(expr.left, isA<BinaryExpressionNode>());
      expect((expr.left as BinaryExpressionNode).operator,
          equals(BinaryOperator.lessThan));
      expect(expr.right, isA<BinaryExpressionNode>());
      expect((expr.right as BinaryExpressionNode).operator,
          equals(BinaryOperator.greaterThan));
    });

    test(
        'Level 6 vs Level 7: equal binds tighter than logical AND (a = b Y c <> d)',
        () {
      final expr = parseValid('a = b Y c <> d') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.and));
      expect(expr.left, isA<BinaryExpressionNode>());
      expect((expr.left as BinaryExpressionNode).operator,
          equals(BinaryOperator.equal));
      expect(expr.right, isA<BinaryExpressionNode>());
      expect((expr.right as BinaryExpressionNode).operator,
          equals(BinaryOperator.notEqual));
    });

    test('Level 7 vs Level 8: AND binds tighter than OR (a Y b O c Y d)', () {
      final expr = parseValid('a Y b O c Y d') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.or));
      expect(expr.left, isA<BinaryExpressionNode>());
      expect((expr.left as BinaryExpressionNode).operator,
          equals(BinaryOperator.and));
      expect(expr.right, isA<BinaryExpressionNode>());
      expect((expr.right as BinaryExpressionNode).operator,
          equals(BinaryOperator.and));
    });
  });

  group('ExpressionParser associativity tests', () {
    test('Left associativity in binary subtraction (a - b - c)', () {
      final expr = parseValid('a - b - c') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.subtract));
      expect(expr.left, isA<BinaryExpressionNode>());
      final leftSub = expr.left as BinaryExpressionNode;
      expect(leftSub.operator, equals(BinaryOperator.subtract));
      expect((leftSub.left as VariableExpressionNode).name, equals('a'));
      expect((leftSub.right as VariableExpressionNode).name, equals('b'));
      expect((expr.right as VariableExpressionNode).name, equals('c'));
    });

    test('Left associativity in division and modulo (a / b / c)', () {
      final expr = parseValid('a / b / c') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.divide));
      expect(expr.left, isA<BinaryExpressionNode>());
    });

    test('Right associativity in power (a ^ b ^ c -> a ^ (b ^ c))', () {
      final expr = parseValid('a ^ b ^ c') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.power));
      expect((expr.left as VariableExpressionNode).name, equals('a'));
      expect(expr.right, isA<BinaryExpressionNode>());
      final rightPower = expr.right as BinaryExpressionNode;
      expect(rightPower.operator, equals(BinaryOperator.power));
      expect((rightPower.left as VariableExpressionNode).name, equals('b'));
      expect((rightPower.right as VariableExpressionNode).name, equals('c'));
    });

    test('Right associativity in chained unaries (- - x)', () {
      final expr = parseValid('- - x') as UnaryExpressionNode;
      expect(expr.operator, equals(UnaryOperator.negate));
      expect(expr.operand, isA<UnaryExpressionNode>());
      final inner = expr.operand as UnaryExpressionNode;
      expect(inner.operator, equals(UnaryOperator.negate));
      expect((inner.operand as VariableExpressionNode).name, equals('x'));
    });

    test('Right associativity in chained logical NOT (NO NO flag)', () {
      final expr = parseValid('NO NO flag') as UnaryExpressionNode;
      expect(expr.operator, equals(UnaryOperator.not));
      expect(expr.operand, isA<UnaryExpressionNode>());
      final inner = expr.operand as UnaryExpressionNode;
      expect(inner.operator, equals(UnaryOperator.not));
    });
  });

  group('ExpressionParser unary and grouping tests', () {
    test('Unary applied to literal, variable and parenthesized expression', () {
      final literalExpr = parseValid('-42') as UnaryExpressionNode;
      expect(literalExpr.operator, equals(UnaryOperator.negate));
      expect((literalExpr.operand as LiteralExpressionNode).value,
          equals(PseudoInteger.fromInt(42)));

      final varExpr = parseValid('+total') as UnaryExpressionNode;
      expect(varExpr.operator, equals(UnaryOperator.positive));

      final parenExpr = parseValid('-(a + b)') as UnaryExpressionNode;
      expect(parenExpr.operator, equals(UnaryOperator.negate));
      expect(parenExpr.operand, isA<ParenthesizedExpressionNode>());
    });

    test('Logical NOT vs relational equality (NO a = b -> (NO a) = b)', () {
      final expr = parseValid('NO a = b') as BinaryExpressionNode;
      expect(expr.operator, equals(BinaryOperator.equal));
      expect(expr.left, isA<UnaryExpressionNode>());
      final leftNot = expr.left as UnaryExpressionNode;
      expect(leftNot.operator, equals(UnaryOperator.not));
      expect((leftNot.operand as VariableExpressionNode).name, equals('a'));
      expect((expr.right as VariableExpressionNode).name, equals('b'));
    });

    test('Parenthesized expression explicit precedence NO (a = b)', () {
      final expr = parseValid('NO (a = b)') as UnaryExpressionNode;
      expect(expr.operator, equals(UnaryOperator.not));
      expect(expr.operand, isA<ParenthesizedExpressionNode>());
    });

    test('Deeply nested and redundant parentheses', () {
      final expr = parseValid('((((x))))') as ParenthesizedExpressionNode;
      expect(expr.expression, isA<ParenthesizedExpressionNode>());
    });
  });

  group('ExpressionParser array access and function calls', () {
    test('1D and 2D array access with complex index expressions', () {
      final expr1D = parseValid('notas[i]') as ArrayAccessExpressionNode;
      expect((expr1D.target as VariableExpressionNode).name, equals('notas'));
      expect(expr1D.indices.length, equals(1));

      final expr2D =
          parseValid('matriz[i + 1, j * 2]') as ArrayAccessExpressionNode;
      expect((expr2D.target as VariableExpressionNode).name, equals('matriz'));
      expect(expr2D.indices.length, equals(2));
      expect(expr2D.indices[0], isA<BinaryExpressionNode>());
      expect(expr2D.indices[1], isA<BinaryExpressionNode>());
    });

    test('Nested array access (arr[otro[i]])', () {
      final expr = parseValid('arr[otro[i]]') as ArrayAccessExpressionNode;
      expect(expr.indices.first, isA<ArrayAccessExpressionNode>());
    });

    test('Function calls with 0, 1 and multiple arguments', () {
      final callZero = parseValid('azar()') as FunctionCallExpressionNode;
      expect(callZero.name, equals('azar'));
      expect(callZero.arguments, isEmpty);

      final callOne = parseValid('rc(x + 1)') as FunctionCallExpressionNode;
      expect(callOne.name, equals('rc'));
      expect(callOne.arguments.length, equals(1));

      final callMulti =
          parseValid('calculo(a, b + 1, c ^ 2)') as FunctionCallExpressionNode;
      expect(callMulti.name, equals('calculo'));
      expect(callMulti.arguments.length, equals(3));
    });

    test('Addition vs concatenation produces same BinaryOperator.add', () {
      final numAdd = parseValid('a + b') as BinaryExpressionNode;
      expect(numAdd.operator, equals(BinaryOperator.add));

      final strConcat = parseValid('"hola" + " mundo"') as BinaryExpressionNode;
      expect(strConcat.operator, equals(BinaryOperator.add));
    });
  });

  group('ExpressionParser error and unhappy path diagnostics', () {
    test('Binary operator without right operand (5 +)', () {
      final result = parseExpressionSource('5 +');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.expectedExpression),
          isTrue);
    });

    test('Binary operator without left operand (* 5)', () {
      final result = parseExpressionSource('* 5');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.unexpectedTokenInExpression),
          isTrue);
    });

    test('Two consecutive binary operators (5 + * 3)', () {
      final result = parseExpressionSource('5 + * 3');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.unexpectedTokenInExpression),
          isTrue);
    });

    test('Unclosed opening parenthesis ((5 + 3)', () {
      final result = parseExpressionSource('(5 + 3');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.unclosedParenthesis),
          isTrue);
    });

    test('Unexpected closing parenthesis (5 + 3))', () {
      final result = parseExpressionSource(') 5 + 3');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics.any(
              (d) => d.code == DiagnosticCode.unexpectedClosingParenthesis),
          isTrue);
    });

    test('Empty parentheses ()', () {
      final result = parseExpressionSource('()');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.emptyParentheses),
          isTrue);
    });

    test('Empty array index list (arr[])', () {
      final result = parseExpressionSource('arr[]');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.emptyIndexList),
          isTrue);
    });

    test('Trailing comma in function call arguments (f(a,))', () {
      final result = parseExpressionSource('f(a,)');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics.any((d) => d.code == DiagnosticCode.trailingComma),
          isTrue);
    });

    test('Trailing comma in array indices (arr[1,])', () {
      final result = parseExpressionSource('arr[1,]');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics.any((d) => d.code == DiagnosticCode.trailingComma),
          isTrue);
    });

    test('Chained array access pedagogical diagnostic (arr[i][j])', () {
      final result = parseExpressionSource('arr[i][j]');
      expect(result.hasErrors, isTrue);
      expect(
          result.diagnostics
              .any((d) => d.code == DiagnosticCode.chainedArrayAccess),
          isTrue);
    });
  });

  group('ExpressionParser boundary cases and multilingual parity', () {
    test('Boundary literals and single character identifiers', () {
      final singleChar = parseValid('x') as VariableExpressionNode;
      expect(singleChar.name, equals('x'));

      final intLiteral =
          parseValid('9223372036854775807') as LiteralExpressionNode;
      expect(intLiteral.value, equals(PseudoInteger.maxValue));
      expect(intLiteral.type, equals(PrimitiveType.integer));

      final boolTrue = parseValid('Verdadero') as LiteralExpressionNode;
      expect(boolTrue.value, equals(true));
      expect(boolTrue.type, equals(PrimitiveType.boolean));
    });

    test('Multilingual parity between Spanish and English profiles', () {
      final spanishExpr = parseValid(
        'NO a Y b O c = d',
        profile: const ClassicSpanishProfile.strict(),
      ) as BinaryExpressionNode;

      final englishExpr = parseValid(
        'NOT a AND b OR c = d',
        profile: const EnglishProfile.strict(),
      ) as BinaryExpressionNode;

      expect(spanishExpr.operator, equals(englishExpr.operator));
      expect(
        (spanishExpr.left as BinaryExpressionNode).operator,
        equals((englishExpr.left as BinaryExpressionNode).operator),
      );
      expect(
        (spanishExpr.right as BinaryExpressionNode).operator,
        equals((englishExpr.right as BinaryExpressionNode).operator),
      );
    });
  });

  group('ExpressionParser exact span verification', () {
    test('Exact spans on binary, unary and parenthesized expressions', () {
      final expr = parseValid('-(a + b)') as UnaryExpressionNode;
      expect(expr.span.start.offset, equals(0));
      expect(expr.span.end.offset, equals(8));
      expect(expr.operatorSpan.start.offset, equals(0));
      expect(expr.operatorSpan.end.offset, equals(1));

      final paren = expr.operand as ParenthesizedExpressionNode;
      expect(paren.span.start.offset, equals(1));
      expect(paren.span.end.offset, equals(8));

      final bin = paren.expression as BinaryExpressionNode;
      expect(bin.span.start.offset, equals(2));
      expect(bin.span.end.offset, equals(7));
      expect(bin.operatorSpan.start.offset, equals(4));
      expect(bin.operatorSpan.end.offset, equals(5));
    });

    test('Exact spans on array access and function calls', () {
      final call =
          parseValid('mi_funcion(10, 20)') as FunctionCallExpressionNode;
      expect(call.nameSpan.start.offset, equals(0));
      expect(call.nameSpan.end.offset, equals(10));
      expect(call.span.start.offset, equals(0));
      expect(call.span.end.offset, equals(18));

      final access = parseValid('matriz[i, j]') as ArrayAccessExpressionNode;
      expect(access.span.start.offset, equals(0));
      expect(access.span.end.offset, equals(12));
    });

    test('Exact diagnostic span on chained array access', () {
      final result = parseExpressionSource('arr[i][j]');
      final chainedDiag = result.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.chainedArrayAccess,
      );
      expect(chainedDiag.span.start.offset, equals(6));
      expect(chainedDiag.span.end.offset, equals(7));
    });
  });
}
