import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/parser_profile.dart';
import '../../domain/severity.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'assignment_and_call_parser.dart';
import 'dimension_declaration_parser.dart';
import 'expression_parser.dart';
import 'for_statement_parser.dart';
import 'if_statement_parser.dart';
import 'io_statement_parser.dart';
import 'loop_statement_parser.dart';
import 'return_statement_parser.dart';
import 'statement_synchronizer.dart';
import 'switch_statement_parser.dart';
import 'token_stream.dart';
import 'variable_declaration_parser.dart';

final class StatementParser {
  final NodeIdGenerator _nodeIdGenerator;
  final ParserProfile _profile;
  final ExpressionParser _expressionParser;
  final VariableDeclarationParser _variableDeclarationParser;
  final DimensionDeclarationParser _dimensionDeclarationParser;
  final IoStatementParser _ioParser;
  final IfStatementParser _ifParser;
  final SwitchStatementParser _switchParser;
  final LoopStatementParser _loopParser;
  final ForStatementParser _forParser;
  final ReturnStatementParser _returnParser;
  final AssignmentAndCallParser _assignmentAndCallParser;

  StatementParser(
    this._nodeIdGenerator,
    this._profile,
    this._expressionParser,
  )   : _variableDeclarationParser =
            VariableDeclarationParser(_nodeIdGenerator),
        _dimensionDeclarationParser =
            DimensionDeclarationParser(_nodeIdGenerator),
        _ioParser = IoStatementParser(_nodeIdGenerator),
        _ifParser = IfStatementParser(_nodeIdGenerator),
        _switchParser = SwitchStatementParser(_nodeIdGenerator),
        _loopParser = LoopStatementParser(_nodeIdGenerator),
        _forParser = ForStatementParser(_nodeIdGenerator, _profile),
        _returnParser = ReturnStatementParser(_nodeIdGenerator),
        _assignmentAndCallParser =
            AssignmentAndCallParser(_nodeIdGenerator, _profile);

  NodeId _nextId() => _nodeIdGenerator.next();

  List<StatementNode> parseStatementList(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Set<TokenType> stopTokens, {
    bool Function(TokenStream stream)? isStopPredicate,
    bool inSubroutine = false,
  }) {
    final statements = <StatementNode>[];
    StatementSynchronizer.skipIgnoredDelimiters(stream);

    while (!stream.isAtEnd &&
        !stopTokens.contains(stream.peek().type) &&
        !(isStopPredicate != null && isStopPredicate(stream))) {
      final initialDiagnosticCount = diagnostics.length;
      final statement = _parseSingleStatement(
        stream,
        diagnostics,
        inSubroutine: inSubroutine,
      );

      if (statement != null) {
        statements.add(statement);
      } else {
        final errorSpan = stream.previousToken.span;
        statements.add(ErrorStatementNode(id: _nextId(), span: errorSpan));
      }

      final errorOccurred = diagnostics.length > initialDiagnosticCount;
      if (errorOccurred && !_isCompoundStatement(statement)) {
        StatementSynchronizer.synchronize(stream, stopTokens);
      }

      StatementSynchronizer.skipIgnoredDelimiters(stream);
    }
    return statements;
  }

  bool _isCompoundStatement(StatementNode? node) => switch (node) {
        IfStatementNode() ||
        WhileStatementNode() ||
        ForStatementNode() ||
        SwitchStatementNode() ||
        RepeatUntilStatementNode() =>
          true,
        _ => false,
      };

  StatementNode? _parseSingleStatement(
    TokenStream stream,
    List<Diagnostic> diagnostics, {
    required bool inSubroutine,
  }) {
    final statement = _dispatchStatement(
      stream,
      diagnostics,
      inSubroutine: inSubroutine,
    );

    if (statement != null && _isSimpleStatement(statement)) {
      _checkStatementTerminator(stream, diagnostics);
    }
    return statement;
  }

  StatementNode? _dispatchStatement(
    TokenStream stream,
    List<Diagnostic> diagnostics, {
    required bool inSubroutine,
  }) =>
      switch (stream.peek().type) {
        TokenType.declare ||
        TokenType.dimension ||
        TokenType.write ||
        TokenType.read =>
          _dispatchDeclarationOrIo(stream, diagnostics),
        TokenType.returnKeyword => _returnParser.parse(
            stream,
            diagnostics,
            _expressionParser,
            inSubroutine: inSubroutine,
          ),
        TokenType.subroutine ||
        TokenType.classKeyword ||
        TokenType.method ||
        TokenType.constructor =>
          _dispatchForbiddenKeyword(stream, diagnostics, inSubroutine),
        _ => _dispatchControlOrAssignment(
            stream,
            diagnostics,
            inSubroutine: inSubroutine,
          ),
      };

  StatementNode? _dispatchForbiddenKeyword(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    bool inSubroutine,
  ) {
    final type = stream.peek().type;
    final code = switch (type) {
      TokenType.subroutine => inSubroutine
          ? DiagnosticCode.subroutineInsideSubroutine
          : DiagnosticCode.subroutineInsideAlgorithm,
      TokenType.classKeyword => inSubroutine
          ? DiagnosticCode.classInsideSubroutine
          : DiagnosticCode.classInsideAlgorithm,
      TokenType.method => DiagnosticCode.methodOutsideClass,
      _ => DiagnosticCode.constructorOutsideClass,
    };
    return _handleForbiddenKeyword(stream, diagnostics, code);
  }

  StatementNode? _dispatchDeclarationOrIo(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) =>
      switch (stream.peek().type) {
        TokenType.declare =>
          _variableDeclarationParser.parse(stream, diagnostics),
        TokenType.dimension => _dimensionDeclarationParser.parse(
            stream,
            diagnostics,
            _expressionParser,
          ),
        TokenType.write =>
          _ioParser.parseWrite(stream, diagnostics, _expressionParser),
        TokenType.read =>
          _ioParser.parseRead(stream, diagnostics, _expressionParser),
        _ => null,
      };

  StatementNode? _handleForbiddenKeyword(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    DiagnosticCode code,
  ) {
    final token = stream.advance();
    diagnostics.add(
      Diagnostic(code: code, severity: Severity.error, span: token.span),
    );
    return null;
  }

  StatementNode? _dispatchControlOrAssignment(
    TokenStream stream,
    List<Diagnostic> diagnostics, {
    required bool inSubroutine,
  }) =>
      switch (stream.peek().type) {
        TokenType.ifKeyword ||
        TokenType.switchKeyword ||
        TokenType.whileKeyword ||
        TokenType.repeat ||
        TokenType.forKeyword =>
          _dispatchControlStatement(
            stream,
            diagnostics,
            inSubroutine: inSubroutine,
          ),
        _ => _assignmentAndCallParser.parse(
            stream,
            diagnostics,
            _expressionParser,
          ),
      };

  StatementNode? _dispatchControlStatement(
    TokenStream stream,
    List<Diagnostic> diagnostics, {
    required bool inSubroutine,
  }) {
    final subParser = _createSubListParser(inSubroutine);
    return switch (stream.peek().type) {
      TokenType.ifKeyword =>
        _ifParser.parse(stream, diagnostics, _expressionParser, subParser),
      TokenType.switchKeyword =>
        _switchParser.parse(stream, diagnostics, _expressionParser, subParser),
      TokenType.whileKeyword => _loopParser.parseWhile(
          stream, diagnostics, _expressionParser, subParser),
      TokenType.repeat => _loopParser.parseRepeatUntil(
          stream, diagnostics, _expressionParser, subParser),
      TokenType.forKeyword =>
        _forParser.parse(stream, diagnostics, _expressionParser, subParser),
      _ => null,
    };
  }

  List<StatementNode> Function(
    TokenStream,
    List<Diagnostic>,
    Set<TokenType>, {
    bool Function(TokenStream)? isStopPredicate,
  }) _createSubListParser(bool inSubroutine) =>
      (s, d, st, {isStopPredicate}) => parseStatementList(
            s,
            d,
            st,
            isStopPredicate: isStopPredicate,
            inSubroutine: inSubroutine,
          );

  bool _isSimpleStatement(StatementNode node) => switch (node) {
        VariableDeclarationNode() ||
        DimensionStatementNode() ||
        AssignmentStatementNode() ||
        WriteStatementNode() ||
        ReadStatementNode() ||
        ReturnStatementNode() ||
        CallStatementNode() =>
          true,
        _ => false,
      };

  void _checkStatementTerminator(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.match(TokenType.semicolon)) {
      return;
    }
    if (_profile.mandatoryStatementTerminator) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.missingStatementTerminator,
          severity: Severity.error,
          span: stream.previousToken.span,
        ),
      );
    }
  }
}
