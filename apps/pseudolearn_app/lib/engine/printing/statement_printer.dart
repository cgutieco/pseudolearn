import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'pseudocode_printer.dart';

final class StatementPrinter {
  final PseudocodePrinter _printer;
  final SyntaxLexicon _lexicon;

  const StatementPrinter({
    required PseudocodePrinter printer,
    required SyntaxLexicon lexicon,
  })  : _printer = printer,
        _lexicon = lexicon;

  bool get _needsTerminator =>
      _lexicon is ParserProfile && (_lexicon as ParserProfile).mandatoryStatementTerminator;

  String get _terminator => _needsTerminator ? ';' : '';

  String printStatement(StatementNode statement, {int indentLevel = 0}) {
    final indent = '  ' * indentLevel;
    return switch (statement) {
      VariableDeclarationNode() => '$indent${_variableDeclaration(statement)}$_terminator',
      DimensionStatementNode() => '$indent${_dimensionStatement(statement)}$_terminator',
      AssignmentStatementNode() => '$indent${_assignment(statement)}$_terminator',
      ReadStatementNode() => '$indent${_read(statement)}$_terminator',
      WriteStatementNode() => '$indent${_write(statement)}$_terminator',
      IfStatementNode() => _ifStatement(statement, indentLevel),
      SwitchStatementNode() => _switchStatement(statement, indentLevel),
      WhileStatementNode() => _whileStatement(statement, indentLevel),
      RepeatUntilStatementNode() => _repeatUntil(statement, indentLevel),
      ForStatementNode() => _forStatement(statement, indentLevel),
      ReturnStatementNode() => '$indent${_return(statement)}$_terminator',
      CallStatementNode() => '$indent${_call(statement)}$_terminator',
      MethodCallStatementNode() => '$indent${_methodCall(statement)}$_terminator',
      ErrorStatementNode() => '$indent// error',
    };
  }

  String printBlock(List<StatementNode> statements, {int indentLevel = 0}) {
    return statements.map((s) => printStatement(s, indentLevel: indentLevel)).join('\n');
  }

  String _lexeme(TokenType type) => _lexicon.formatTokenType(type);

  String _formatType(PrimitiveType? type, String? customTypeName) {
    if (type != null) return _formatPrimitiveType(type);
    return customTypeName ?? '';
  }

  String _formatPrimitiveType(PrimitiveType type) {
    final token = switch (type) {
      PrimitiveType.integer => TokenType.integerType,
      PrimitiveType.real => TokenType.realType,
      PrimitiveType.boolean => TokenType.booleanType,
      PrimitiveType.character => TokenType.characterType,
      PrimitiveType.string => TokenType.stringType,
    };
    return _lexeme(token);
  }

  String _variableDeclaration(VariableDeclarationNode decl) {
    final vars = decl.variables.map((v) => v.name).join(', ');
    final type = _formatType(decl.type, decl.customTypeName);
    return '${_lexeme(TokenType.declare)} $vars ${_lexeme(TokenType.typeConnector)} $type';
  }

  String _dimensionStatement(DimensionStatementNode dim) {
    final arrays = dim.arrays.map((a) {
      final dims = a.dimensions.map(_printer.expressionText).join(', ');
      return '${a.name}[$dims]';
    }).join(', ');
    final type = _formatType(dim.elementType, dim.customElementTypeName);
    return '${_lexeme(TokenType.dimension)} $arrays ${_lexeme(TokenType.typeConnector)} $type';
  }

  String _assignment(AssignmentStatementNode a) =>
      '${_printer.expressionText(a.target)} ${_lexeme(TokenType.assignment)} ${_printer.expressionText(a.value)}';

  String _read(ReadStatementNode r) =>
      '${_lexeme(TokenType.read)} ${r.targets.map(_printer.expressionText).join(', ')}';

  String _write(WriteStatementNode w) {
    final exprs = w.expressions.map(_printer.expressionText).join(', ');
    final without = w.withoutNewline ? ' ${_lexeme(TokenType.withoutNewline)}' : '';
    return '${_lexeme(TokenType.write)} $exprs$without';
  }

  String _ifStatement(IfStatementNode node, int indentLevel) {
    final indent = '  ' * indentLevel;
    final cond = _printer.expressionText(node.condition);
    final buf = StringBuffer('$indent${_lexeme(TokenType.ifKeyword)} $cond ${_lexeme(TokenType.then)}\n');
    buf.writeln(printBlock(node.thenBody, indentLevel: indentLevel + 1));
    if (node.elseBody != null && node.elseBody!.isNotEmpty) {
      buf.writeln('$indent${_lexeme(TokenType.elseKeyword)}');
      buf.writeln(printBlock(node.elseBody!, indentLevel: indentLevel + 1));
    }
    buf.write('$indent${_lexeme(TokenType.endIf)}');
    return buf.toString();
  }

  String _switchStatement(SwitchStatementNode node, int indentLevel) {
    final indent = '  ' * indentLevel;
    final selector = _printer.expressionText(node.selector);
    final buf = StringBuffer('$indent${_lexeme(TokenType.switchKeyword)} $selector ${_lexeme(TokenType.doKeyword)}\n');
    for (final c in node.cases) {
      final labels = c.labels.map(_printer.expressionText).join(', ');
      buf.writeln('$indent  $labels:');
      buf.writeln(printBlock(c.body, indentLevel: indentLevel + 2));
    }
    if (node.defaultCase != null) {
      buf.writeln('$indent  ${_lexeme(TokenType.defaultCase)}:');
      buf.writeln(printBlock(node.defaultCase!.body, indentLevel: indentLevel + 2));
    }
    buf.write('$indent${_lexeme(TokenType.endSwitch)}');
    return buf.toString();
  }

  String _whileStatement(WhileStatementNode node, int indentLevel) {
    final indent = '  ' * indentLevel;
    final cond = _printer.expressionText(node.condition);
    final buf = StringBuffer('$indent${_lexeme(TokenType.whileKeyword)} $cond ${_lexeme(TokenType.doKeyword)}\n');
    buf.writeln(printBlock(node.body, indentLevel: indentLevel + 1));
    buf.write('$indent${_lexeme(TokenType.endWhile)}');
    return buf.toString();
  }

  String _repeatUntil(RepeatUntilStatementNode node, int indentLevel) {
    final indent = '  ' * indentLevel;
    final cond = _printer.expressionText(node.condition);
    final buf = StringBuffer('$indent${_lexeme(TokenType.repeat)}\n');
    buf.writeln(printBlock(node.body, indentLevel: indentLevel + 1));
    buf.write('$indent${_lexeme(TokenType.until)} $cond');
    return buf.toString();
  }

  String _forStatement(ForStatementNode node, int indentLevel) {
    final indent = '  ' * indentLevel;
    final variable = _printer.expressionText(node.variable);
    final from = _printer.expressionText(node.from);
    final to = _printer.expressionText(node.to);
    final step = node.step != null ? ' ${_lexeme(TokenType.step)} ${_printer.expressionText(node.step!)}' : '';
    final buf = StringBuffer(
      '$indent${_lexeme(TokenType.forKeyword)} $variable ${_lexeme(TokenType.assignment)} $from '
      '${_lexeme(TokenType.to)} $to$step ${_lexeme(TokenType.doKeyword)}\n',
    );
    buf.writeln(printBlock(node.body, indentLevel: indentLevel + 1));
    buf.write('$indent${_lexeme(TokenType.endFor)}');
    return buf.toString();
  }

  String _return(ReturnStatementNode r) {
    final ret = _lexeme(TokenType.returnKeyword);
    return r.value != null ? '$ret ${_printer.expressionText(r.value!)}' : ret;
  }

  String _call(CallStatementNode c) => '${c.name}(${_printer.argumentList(c.arguments)})';

  String _methodCall(MethodCallStatementNode m) =>
      '${_printer.expressionText(m.target)}.${m.methodName}(${_printer.argumentList(m.arguments)})';
}
