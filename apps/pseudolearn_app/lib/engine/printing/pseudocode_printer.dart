import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'statement_printer.dart';
import 'structure_printer.dart';

final class PseudocodePrinter {
  final SyntaxLexicon _lexicon;
  late final StatementPrinter _statementPrinter;
  late final StructurePrinter _structurePrinter;

  PseudocodePrinter(SyntaxLexicon lexicon) : _lexicon = lexicon {
    _statementPrinter = StatementPrinter(printer: this, lexicon: lexicon);
    _structurePrinter = StructurePrinter(
      statementPrinter: _statementPrinter,
      lexicon: lexicon,
    );
  }

  String printUnit(SourceUnitNode unit) => _structurePrinter.printUnit(unit);

  String printStatement(StatementNode statement, {int indentLevel = 0}) =>
      _statementPrinter.printStatement(statement, indentLevel: indentLevel);

  String expressionText(ExpressionNode expression) {
    return switch (expression) {
      LiteralExpressionNode() => _literalText(expression),
      VariableExpressionNode(:final name) => name,
      ParenthesizedExpressionNode(:final expression) => '(${expressionText(expression)})',
      UnaryExpressionNode() => _unaryText(expression),
      BinaryExpressionNode() => _binaryText(expression),
      ArrayAccessExpressionNode() => _arrayAccessText(expression),
      FunctionCallExpressionNode(:final name, :final arguments) =>
        '$name(${argumentList(arguments)})',
      InstantiationExpressionNode(:final className, :final arguments) =>
        '${_lexeme(TokenType.newInstance)} $className(${argumentList(arguments)})',
      MemberAccessExpressionNode(:final target, :final memberName) =>
        '${expressionText(target)}.$memberName',
      MethodCallExpressionNode(:final target, :final methodName, :final arguments) =>
        '${expressionText(target)}.$methodName(${argumentList(arguments)})',
      ThisExpressionNode() => _lexeme(TokenType.thisObject),
      SuperExpressionNode() => _lexeme(TokenType.superClass),
    };
  }

  String argumentList(List<ExpressionNode> arguments) =>
      arguments.map(expressionText).join(', ');

  String _lexeme(TokenType tokenType) => _lexicon.formatTokenType(tokenType);

  String _literalText(LiteralExpressionNode literal) {
    return switch (literal.type) {
      PrimitiveType.string => '"${literal.value}"',
      PrimitiveType.character => "'${literal.value}'",
      PrimitiveType.boolean => _lexeme(
          literal.value == true ? TokenType.booleanTrue : TokenType.booleanFalse,
        ),
      PrimitiveType.integer || PrimitiveType.real => '${literal.value}',
    };
  }

  String _unaryText(UnaryExpressionNode unary) {
    final lexeme = _lexeme(_unaryTokenType(unary.operator));
    final operand = expressionText(unary.operand);
    return _isWord(lexeme) ? '$lexeme $operand' : '$lexeme$operand';
  }

  String _binaryText(BinaryExpressionNode binary) {
    final lexeme = _lexeme(_binaryTokenType(binary.operator));
    return '${expressionText(binary.left)} $lexeme ${expressionText(binary.right)}';
  }

  String _arrayAccessText(ArrayAccessExpressionNode access) {
    final indices = access.indices.map(expressionText).map((index) => '[$index]').join();
    return '${expressionText(access.target)}$indices';
  }

  bool _isWord(String lexeme) {
    if (lexeme.isEmpty) return false;
    final code = lexeme.codeUnitAt(0);
    const upperA = 65;
    const upperZ = 90;
    const lowerA = 97;
    const lowerZ = 122;
    const firstNonAscii = 128;
    if (code >= upperA && code <= upperZ) return true;
    if (code >= lowerA && code <= lowerZ) return true;
    return code >= firstNonAscii;
  }

  TokenType _unaryTokenType(UnaryOperator operator) {
    return switch (operator) {
      UnaryOperator.positive => TokenType.plus,
      UnaryOperator.negate => TokenType.minus,
      UnaryOperator.not => TokenType.not,
    };
  }

  TokenType _binaryTokenType(BinaryOperator operator) {
    return switch (operator) {
      BinaryOperator.add => TokenType.plus,
      BinaryOperator.subtract => TokenType.minus,
      BinaryOperator.multiply => TokenType.multiply,
      BinaryOperator.divide => TokenType.divide,
      BinaryOperator.integerDivide => TokenType.integerDivide,
      BinaryOperator.modulo => TokenType.modulo,
      BinaryOperator.power => TokenType.power,
      BinaryOperator.equal => TokenType.equal,
      BinaryOperator.notEqual => TokenType.notEqual,
      BinaryOperator.lessThan => TokenType.lessThan,
      BinaryOperator.lessThanOrEqual => TokenType.lessThanOrEqual,
      BinaryOperator.greaterThan => TokenType.greaterThan,
      BinaryOperator.greaterThanOrEqual => TokenType.greaterThanOrEqual,
      BinaryOperator.and => TokenType.and,
      BinaryOperator.or => TokenType.or,
    };
  }
}
