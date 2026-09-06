import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/parser_profile.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import '../../domain/visibility.dart';
import '../ast/ast_node.dart';
import 'dimension_declaration_parser.dart';
import 'expression_parser.dart';
import 'method_and_constructor_parser.dart';
import 'statement_parser.dart';
import 'token_stream.dart';
import 'top_level_collector.dart';
import 'variable_declaration_parser.dart';

final class MemberParser {
  final NodeIdGenerator _nodeIdGenerator;
  final ParserProfile _profile;
  final VariableDeclarationParser _varDeclParser;
  final DimensionDeclarationParser _dimDeclParser;
  final MethodAndConstructorParser _methodParser;
  final ExpressionParser _expressionParser;

  MemberParser(this._nodeIdGenerator, this._profile)
      : _varDeclParser = VariableDeclarationParser(_nodeIdGenerator),
        _dimDeclParser = DimensionDeclarationParser(_nodeIdGenerator),
        _methodParser = MethodAndConstructorParser(_nodeIdGenerator),
        _expressionParser = ExpressionParser(_nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  List<ClassMemberNode> parseMembers(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser,
    String className,
  ) {
    final members = <ClassMemberNode>[];
    var hasConstructor = false;

    while (!stream.isAtEnd && !stream.check(TokenType.endClass)) {
      _skipDelimiters(stream);
      if (stream.isAtEnd || stream.check(TokenType.endClass)) break;

      final member = _parseSingleMember(
        stream,
        diagnostics,
        statementParser,
        className: className,
        hasConstructor: hasConstructor,
      );
      if (member != null) {
        if (member is ConstructorDeclarationNode) {
          hasConstructor = true;
        }
        members.add(member);
      }
      _skipDelimiters(stream);
    }
    return members;
  }

  ClassMemberNode? _parseSingleMember(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser, {
    required String className,
    required bool hasConstructor,
  }) {
    final (visibility, visSpan) = _parseVisibility(stream, diagnostics);

    if (stream.check(TokenType.declare)) {
      return _parseFieldFromVar(stream, diagnostics, visibility, visSpan);
    }
    if (stream.check(TokenType.dimension)) {
      return _parseFieldFromDim(stream, diagnostics, visibility, visSpan);
    }
    if (stream.check(TokenType.method)) {
      return _parseMethodOrConstructor(
        stream,
        diagnostics,
        statementParser,
        className: className,
        visibility: visibility,
        visSpan: visSpan,
        hasConstructor: hasConstructor,
      );
    }
    _handleUnexpectedMemberToken(stream, diagnostics);
    return null;
  }

  (Visibility, Span?) _parseVisibility(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    Visibility? visibility;
    Span? visSpan;

    while (stream.check(TokenType.publicVisibility) ||
        stream.check(TokenType.privateVisibility)) {
      final token = stream.advance();
      if (visibility != null) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.duplicateVisibilityModifier,
            severity: Severity.error,
            span: token.span,
          ),
        );
      } else {
        visibility = token.type == TokenType.publicVisibility
            ? Visibility.public
            : Visibility.private;
        visSpan = token.span;
      }
    }
    return (visibility ?? Visibility.public, visSpan);
  }

  ClassFieldNode? _parseFieldFromVar(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Visibility visibility,
    Span? visSpan,
  ) {
    final decl = _varDeclParser.parse(stream, diagnostics);
    if (decl == null) return null;
    final span =
        visSpan != null ? stream.spanFrom(visSpan, decl.span) : decl.span;
    return ClassFieldNode(
      id: _nextId(),
      span: span,
      visibility: visibility,
      declaration: decl,
    );
  }

  ClassFieldNode? _parseFieldFromDim(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Visibility visibility,
    Span? visSpan,
  ) {
    final decl = _dimDeclParser.parse(stream, diagnostics, _expressionParser);
    if (decl == null) return null;
    final span =
        visSpan != null ? stream.spanFrom(visSpan, decl.span) : decl.span;
    return ClassFieldNode(
      id: _nextId(),
      span: span,
      visibility: visibility,
      declaration: decl,
    );
  }

  ClassMemberNode _parseMethodOrConstructor(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser, {
    required String className,
    required Visibility visibility,
    required Span? visSpan,
    required bool hasConstructor,
  }) {
    final methodToken = stream.advance();
    final startSpan = visSpan ?? methodToken.span;

    if (stream.check(TokenType.constructor)) {
      return _methodParser.parseConstructor(
        stream,
        diagnostics,
        statementParser,
        startSpan: startSpan,
        visibilitySpan: visSpan,
        hasExistingConstructor: hasConstructor,
      );
    }
    return _methodParser.parseMethod(
      stream,
      diagnostics,
      statementParser,
      startSpan: startSpan,
      visibility: visibility,
      className: className,
    );
  }

  void _handleUnexpectedMemberToken(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final token = stream.advance();
    final unsupported =
        _profile.unsupportedConstructs[token.lexeme.toLowerCase()];
    if (unsupported != null) {
      diagnostics.add(
        Diagnostic(
          code: diagnosticForUnsupportedConstruct(unsupported),
          severity: Severity.error,
          span: token.span,
        ),
      );
      return;
    }
    _reportKnownOrUnexpectedMember(diagnostics, token);
  }

  void _reportKnownOrUnexpectedMember(
    List<Diagnostic> diagnostics,
    Token token,
  ) {
    final code = switch (token.type) {
      TokenType.subroutine => DiagnosticCode.subroutineInsideClass,
      TokenType.classKeyword => DiagnosticCode.nestedClassNotSupported,
      _ => DiagnosticCode.unexpectedStatement,
    };
    diagnostics.add(
      Diagnostic(
        code: code,
        severity: Severity.error,
        span: token.span,
      ),
    );
  }

  void _skipDelimiters(TokenStream stream) {
    while (!stream.isAtEnd &&
        (stream.check(TokenType.endOfLine) ||
            stream.check(TokenType.semicolon))) {
      stream.advance();
    }
  }
}
