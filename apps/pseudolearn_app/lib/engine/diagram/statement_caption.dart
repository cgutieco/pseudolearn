import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../printing/pseudocode_printer.dart';
import 'diagram_vocabulary.dart';
import 'type_lexeme.dart';

final class StatementCaption {
  final PseudocodePrinter _printer;
  final SyntaxLexicon _lexicon;
  final TypeLexeme _types;
  final DiagramVocabulary _vocabulary;

  StatementCaption({
    required PseudocodePrinter printer,
    required SyntaxLexicon lexicon,
    required DiagramVocabulary vocabulary,
  })  : _printer = printer,
        _lexicon = lexicon,
        _types = TypeLexeme(lexicon),
        _vocabulary = vocabulary;

  String forStatement(StatementNode statement) {
    return switch (statement) {
      AssignmentStatementNode(:final target, :final value) =>
        '${_printer.expressionText(target)} ${_lexeme(TokenType.assignment)} '
            '${_printer.expressionText(value)}',
      VariableDeclarationNode() => _declarationText(statement),
      DimensionStatementNode() => _dimensionText(statement),
      ReadStatementNode(:final targets) =>
        '${_lexeme(TokenType.read)} ${_printer.argumentList(targets)}',
      WriteStatementNode() => _writeText(statement),
      ReturnStatementNode(:final value) => value == null
          ? _lexeme(TokenType.returnKeyword)
          : '${_lexeme(TokenType.returnKeyword)} ${_printer.expressionText(value)}',
      CallStatementNode(:final name, :final arguments) =>
        '$name(${_printer.argumentList(arguments)})',
      MethodCallStatementNode(:final target, :final methodName, :final arguments) =>
        '${_printer.expressionText(target)}.$methodName(${_printer.argumentList(arguments)})',
      _ => '',
    };
  }

  String forCondition(ExpressionNode condition) =>
      _vocabulary.asQuestion(_printer.expressionText(condition));

  String forLoopHeader(ForStatementNode loop) {
    final buffer = StringBuffer()
      ..write(_printer.expressionText(loop.variable))
      ..write(' ${_lexeme(TokenType.assignment)} ')
      ..write(_printer.expressionText(loop.from))
      ..write(' ${_lexeme(TokenType.to)} ')
      ..write(_printer.expressionText(loop.to));
    if (loop.step != null) {
      buffer.write(' ${_lexeme(TokenType.step)} ${_printer.expressionText(loop.step!)}');
    }
    return buffer.toString();
  }

  String forSelector(ExpressionNode selector) =>
      '${_lexeme(TokenType.switchKeyword)} ${_printer.expressionText(selector)}';

  String forCaseLabels(List<ExpressionNode>? labels) => labels == null
      ? _lexeme(TokenType.defaultCase)
      : labels.map(_printer.expressionText).join(', ');

  String _lexeme(TokenType tokenType) => _lexicon.formatTokenType(tokenType);

  String _declarationText(VariableDeclarationNode declaration) {
    final names = declaration.variables.map((variable) => variable.name).join(', ');
    final typeName = _types.of(declaration.type, declaration.customTypeName);
    return '${_lexeme(TokenType.declare)} $names '
        '${_lexeme(TokenType.typeConnector)} $typeName';
  }

  String _dimensionText(DimensionStatementNode dimension) {
    final arrays = dimension.arrays.map(_arrayDeclaratorText).join(', ');
    return '${_lexeme(TokenType.dimension)} $arrays';
  }

  String _arrayDeclaratorText(ArrayDeclaratorNode array) {
    final sizes = array.dimensions.map(_printer.expressionText).join(', ');
    return '${array.name}[$sizes]';
  }

  String _writeText(WriteStatementNode write) {
    final values = _printer.argumentList(write.expressions);
    if (!write.withoutNewline) return '${_lexeme(TokenType.write)} $values';
    return '${_lexeme(TokenType.write)} $values ${_lexeme(TokenType.withoutNewline)}';
  }
}
