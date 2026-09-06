import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'expression_parser.dart';
import 'statement_synchronizer.dart';
import 'switch_case_label_validator.dart';
import 'token_stream.dart';

typedef BodyParser = List<StatementNode> Function(
  TokenStream stream,
  List<Diagnostic> diagnostics,
  Set<TokenType> stopTokens, {
  bool Function(TokenStream stream)? isStopPredicate,
});

final class SwitchStatementParser {
  final NodeIdGenerator _nodeIdGenerator;

  SwitchStatementParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  SwitchStatementNode parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody,
  ) {
    final switchToken = stream.advance();
    final selector = _parseCondition(stream, diagnostics, expressionParser);

    if (!stream.match(TokenType.doKeyword)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedDoKeyword,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }

    final (cases, defaultCase) = _parseSwitchBranches(
      stream,
      diagnostics,
      expressionParser,
      parseBody,
    );

    _validateClosure(stream, diagnostics, switchToken.span);

    return SwitchStatementNode(
      id: _nextId(),
      span: stream.spanFrom(switchToken.span),
      selector: selector,
      cases: cases,
      defaultCase: defaultCase,
    );
  }

  (List<SwitchCaseNode>, SwitchDefaultNode?) _parseSwitchBranches(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody,
  ) {
    final cases = <SwitchCaseNode>[];
    SwitchDefaultNode? defaultCase;
    final seenLabels = <String, Span>{};

    StatementSynchronizer.skipIgnoredDelimiters(stream);
    while (!_isSwitchEnd(stream.peek().type)) {
      if (stream.match(TokenType.defaultCase)) {
        defaultCase = _handleDefaultBranch(
          stream,
          diagnostics,
          parseBody,
          existingDefault: defaultCase,
        );
      } else {
        final singleCase = _parseCaseBranch(
          stream,
          diagnostics,
          expressionParser,
          parseBody,
          seenLabels: seenLabels,
        );
        if (singleCase != null) {
          cases.add(singleCase);
        } else {
          break;
        }
      }
      StatementSynchronizer.skipIgnoredDelimiters(stream);
    }
    return (cases, defaultCase);
  }

  SwitchDefaultNode _handleDefaultBranch(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    BodyParser parseBody, {
    required SwitchDefaultNode? existingDefault,
  }) {
    if (existingDefault != null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.duplicateDefaultCase,
          severity: Severity.error,
          span: stream.previousToken.span,
        ),
      );
    }
    final defaultNode = _parseDefaultBranch(stream, diagnostics, parseBody);
    StatementSynchronizer.skipIgnoredDelimiters(stream);
    if (!_isSwitchEnd(stream.peek().type)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.invalidDefaultCasePosition,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }
    return defaultNode;
  }

  SwitchCaseNode? _parseCaseBranch(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody, {
    required Map<String, Span> seenLabels,
  }) {
    final labels = _parseCaseLabels(
      stream,
      diagnostics,
      expressionParser,
      seenLabels,
    );
    if (labels.isEmpty) return null;
    _matchBranchSeparator(stream, diagnostics);
    final body = parseBody(
      stream,
      diagnostics,
      _caseBranchStopTokens,
      isStopPredicate: SwitchCaseLabelValidator.isCaseLabelStart,
    );
    return SwitchCaseNode(
      id: _nextId(),
      span: stream.spanFrom(labels.first.span),
      labels: labels,
      body: body,
    );
  }

  List<ExpressionNode> _parseCaseLabels(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    Map<String, Span> seenLabels,
  ) {
    final labels = <ExpressionNode>[];
    final first = _parseSingleCaseLabel(
      stream,
      diagnostics,
      expressionParser,
      seenLabels,
    );
    if (first != null) labels.add(first);

    while (stream.match(TokenType.comma)) {
      final next = _parseSingleCaseLabel(
        stream,
        diagnostics,
        expressionParser,
        seenLabels,
      );
      if (next != null) labels.add(next);
    }
    return labels;
  }

  ExpressionNode? _parseSingleCaseLabel(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    Map<String, Span> seenLabels,
  ) {
    final expr = expressionParser.parseExpression(stream, diagnostics);
    if (expr == null) return null;

    if (!SwitchCaseLabelValidator.isLiteral(expr)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.nonLiteralSwitchCaseLabel,
          severity: Severity.error,
          span: expr.span,
        ),
      );
      return expr;
    }

    SwitchCaseLabelValidator.validateDuplicate(expr, diagnostics, seenLabels);
    return expr;
  }

  SwitchDefaultNode _parseDefaultBranch(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    BodyParser parseBody,
  ) {
    final startSpan = stream.previousToken.span;
    _matchBranchSeparator(stream, diagnostics);
    final body = parseBody(
      stream,
      diagnostics,
      {TokenType.endSwitch, TokenType.endAlgorithm, TokenType.endOfFile},
      isStopPredicate: SwitchCaseLabelValidator.isCaseLabelStart,
    );
    return SwitchDefaultNode(
      id: _nextId(),
      span: stream.spanFrom(startSpan),
      body: body,
    );
  }

  bool _isSwitchEnd(TokenType type) => switch (type) {
        TokenType.endSwitch ||
        TokenType.endAlgorithm ||
        TokenType.endOfFile =>
          true,
        _ => false,
      };

  ExpressionNode _parseCondition(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final expr = expressionParser.parseExpression(stream, diagnostics);
    if (expr != null) return expr;
    return LiteralExpressionNode(
      id: _nextId(),
      span: stream.peek().span,
      value: false,
      type: PrimitiveType.boolean,
    );
  }

  void _validateClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span openSpan,
  ) {
    StatementSynchronizer.skipIgnoredDelimiters(stream);
    if (!stream.match(TokenType.endSwitch)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedSwitchStatement,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [openSpan],
        ),
      );
    }
  }

  void _matchBranchSeparator(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.match(TokenType.branchSeparator)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedBranchSeparator,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }
  }
}

const _caseBranchStopTokens = {
  TokenType.defaultCase,
  TokenType.endSwitch,
  TokenType.endAlgorithm,
  TokenType.endOfFile,
};
