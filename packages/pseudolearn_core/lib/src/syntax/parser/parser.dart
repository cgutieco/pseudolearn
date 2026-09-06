import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/parser_profile.dart';
import '../../domain/profile/profiles/classic_spanish_profile.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'class_parser.dart';
import 'expression_parser.dart';
import 'parse_result.dart';
import 'statement_parser.dart';
import 'statement_synchronizer.dart';
import 'subroutine_parser.dart';
import 'token_stream.dart';
import 'top_level_collector.dart';

final class Parser {
  static const int maxSyntacticDiagnostics = 100;

  final NodeIdGenerator _nodeIdGenerator;
  final ParserProfile _profile;
  final StatementParser _statementParser;
  final SubroutineParser _subroutineParser;
  final ClassParser _classParser;

  factory Parser({
    NodeIdGenerator? nodeIdGenerator,
    ParserProfile? profile,
  }) {
    final generator = nodeIdGenerator ?? NodeIdGenerator();
    final prof = profile ?? const ClassicSpanishProfile.flexible();
    final exprParser = ExpressionParser(generator);
    return Parser._(
      nodeIdGenerator: generator,
      profile: prof,
      statementParser: StatementParser(generator, prof, exprParser),
      subroutineParser: SubroutineParser(generator),
      classParser: ClassParser(generator, prof),
    );
  }

  const Parser._({
    required NodeIdGenerator nodeIdGenerator,
    required ParserProfile profile,
    required StatementParser statementParser,
    required SubroutineParser subroutineParser,
    required ClassParser classParser,
  })  : _nodeIdGenerator = nodeIdGenerator,
        _profile = profile,
        _statementParser = statementParser,
        _subroutineParser = subroutineParser,
        _classParser = classParser;

  NodeId _nextId() => _nodeIdGenerator.next();

  ParseResult parse(TokenStream stream) {
    final rawDiagnostics = <Diagnostic>[];
    _skipIgnoredDelimiters(stream);

    if (stream.isAtEnd) {
      _reportMissingAlgorithm(stream, rawDiagnostics);
      return ParseResult(program: null, diagnostics: rawDiagnostics);
    }

    final collector = _parseTopLevel(stream, rawDiagnostics);

    if (collector.algorithm == null) {
      _reportMissingAlgorithm(stream, rawDiagnostics);
    }

    final unitNode = _buildSourceUnitNode(stream, collector);

    return ParseResult(
      program: unitNode,
      diagnostics: _applyDiagnosticLimit(rawDiagnostics),
    );
  }

  TopLevelCollector _parseTopLevel(
    TokenStream stream,
    List<Diagnostic> rawDiagnostics,
  ) {
    final collector = TopLevelCollector();

    while (!stream.isAtEnd) {
      _skipIgnoredDelimiters(stream);
      if (stream.isAtEnd) break;

      _dispatchTopLevelItem(stream, rawDiagnostics, collector);
      _skipIgnoredDelimiters(stream);
    }
    return collector;
  }

  void _dispatchTopLevelItem(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    TopLevelCollector collector,
  ) {
    if (stream.check(TokenType.classKeyword)) {
      final cls = _classParser.parse(
        stream,
        diagnostics,
        _statementParser,
      );
      collector.classes.add(cls);
      collector.declarations.add(cls);
      return;
    }

    if (stream.check(TokenType.subroutine)) {
      final sub = _subroutineParser.parse(
        stream,
        diagnostics,
        _statementParser,
      );
      collector.subroutines.add(sub);
      collector.declarations.add(sub);
      return;
    }

    if (stream.check(TokenType.algorithm)) {
      if (collector.algorithm != null) {
        _handleDuplicateAlgorithm(stream, diagnostics);
        return;
      }
      final alg = _parseAlgorithm(stream, diagnostics);
      collector.algorithm = alg;
      collector.declarations.add(alg);
      return;
    }

    _handleExtraneousTopLevelToken(stream, diagnostics);
  }

  SourceUnitNode _buildSourceUnitNode(
    TokenStream stream,
    TopLevelCollector collector,
  ) {
    final declarations = collector.declarations;
    final span = declarations.isNotEmpty
        ? stream.spanFrom(
            declarations.first.span,
            declarations.last.span,
          )
        : stream.peek().span;

    return SourceUnitNode(
      id: _nextId(),
      span: span,
      algorithm: collector.algorithm,
      subroutines: collector.subroutines,
      classes: collector.classes,
      declarations: declarations,
    );
  }

  AlgorithmNode _parseAlgorithm(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final algorithmToken = stream.advance();
    final (name, nameSpan) = _parseAlgorithmName(stream, diagnostics);

    final body = _statementParser.parseStatementList(
      stream,
      diagnostics,
      {TokenType.endAlgorithm, TokenType.endOfFile},
      inSubroutine: false,
    );

    _validateAlgorithmClosure(stream, diagnostics, algorithmToken.span);

    return AlgorithmNode(
      id: _nextId(),
      span: stream.spanFrom(algorithmToken.span),
      name: name,
      nameSpan: nameSpan,
      body: body,
    );
  }

  void _handleDuplicateAlgorithm(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final token = stream.peek();
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.multipleAlgorithms,
        severity: Severity.error,
        span: token.span,
      ),
    );
    _parseAlgorithm(stream, diagnostics);
  }

  void _handleExtraneousTopLevelToken(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final extraToken = stream.advance();
    final unsupported =
        _profile.unsupportedConstructs[extraToken.lexeme.toLowerCase()];
    if (unsupported != null) {
      diagnostics.add(
        Diagnostic(
          code: diagnosticForUnsupportedConstruct(unsupported),
          severity: Severity.error,
          span: extraToken.span,
        ),
      );
      return;
    }
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.unexpectedTokenOutsideProgramUnit,
        severity: Severity.error,
        span: extraToken.span,
        arguments: {'lexeme': LexemeDiagnosticArgument(extraToken.lexeme)},
      ),
    );
  }

  void _reportMissingAlgorithm(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.expectedAlgorithmStart,
        severity: Severity.error,
        span: stream.peek().span,
      ),
    );
  }

  (String, Span) _parseAlgorithmName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.check(TokenType.identifier)) {
      final span = stream.peek().span;
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedAlgorithmName,
          severity: Severity.error,
          span: span,
        ),
      );
      return ('', span);
    }
    final nameToken = stream.advance();
    return (nameToken.lexeme, nameToken.span);
  }

  void _validateAlgorithmClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span algorithmStartSpan,
  ) {
    if (!stream.match(TokenType.endAlgorithm)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedAlgorithm,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [algorithmStartSpan],
        ),
      );
    }
  }

  List<Diagnostic> _applyDiagnosticLimit(List<Diagnostic> diagnostics) {
    if (diagnostics.length <= maxSyntacticDiagnostics) {
      return diagnostics;
    }
    final limited = diagnostics.sublist(0, maxSyntacticDiagnostics);
    limited.add(
      Diagnostic(
        code: DiagnosticCode.maxDiagnosticsExceeded,
        severity: Severity.error,
        span: diagnostics[maxSyntacticDiagnostics - 1].span,
      ),
    );
    return limited;
  }

  void _skipIgnoredDelimiters(TokenStream stream) =>
      StatementSynchronizer.skipIgnoredDelimiters(stream);
}
