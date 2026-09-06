import 'package:pseudolearn_core/src/domain/diagnostic.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_argument.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/node_id.dart';
import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/severity.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('NodeId', () {
    test('constructs nodeId and checks equality', () {
      const id1 = NodeId(42);
      const id2 = NodeId(42);
      const id3 = NodeId(43);

      expect(id1.value, equals(42));
      expect(id1, equals(id2));
      expect(id1.hashCode, equals(id2.hashCode));
      expect(id1, isNot(equals(id3)));
      expect(id1.toString(), equals('#42'));
    });

    test('generates monotonic node identifiers', () {
      final generator = NodeIdGenerator();
      final first = generator.next();
      final second = generator.next();
      final third = generator.next();

      expect(first.value, equals(1));
      expect(second.value, equals(2));
      expect(third.value, equals(3));
    });
  });

  group('DiagnosticArgument', () {
    test('constructs all 5 typed diagnostic argument variants', () {
      const tokenArg = TokenDiagnosticArgument(TokenType.algorithm);
      const typeArg = TypeDiagnosticArgument(PrimitiveType.integer);
      const termArg = TermDiagnosticArgument(DiagnosticTerm.variable);
      const lexemeArg = LexemeDiagnosticArgument('miVariable');
      const numberArg = NumberDiagnosticArgument(10);

      expect(tokenArg.tokenType, equals(TokenType.algorithm));
      expect(typeArg.type, equals(PrimitiveType.integer));
      expect(termArg.term, equals(DiagnosticTerm.variable));
      expect(lexemeArg.lexeme, equals('miVariable'));
      expect(numberArg.value, equals(10));

      expect(
          tokenArg, equals(const TokenDiagnosticArgument(TokenType.algorithm)));
      expect(
          typeArg, equals(const TypeDiagnosticArgument(PrimitiveType.integer)));
      expect(termArg,
          equals(const TermDiagnosticArgument(DiagnosticTerm.variable)));
      expect(lexemeArg, equals(const LexemeDiagnosticArgument('miVariable')));
      expect(numberArg, equals(const NumberDiagnosticArgument(10)));
    });
  });

  group('Diagnostic', () {
    final span = Span(
      start: const Position(line: 1, column: 1, offset: 0),
      end: const Position(line: 1, column: 5, offset: 4),
    );
    final relatedSpan = Span(
      start: const Position(line: 2, column: 1, offset: 10),
      end: const Position(line: 2, column: 8, offset: 17),
    );

    test('constructs diagnostic with all argument types and related spans', () {
      final diagnostic = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: span,
        relatedSpans: [relatedSpan],
        arguments: const {
          'token': TokenDiagnosticArgument(TokenType.identifier),
          'type': TypeDiagnosticArgument(PrimitiveType.real),
          'term': TermDiagnosticArgument(DiagnosticTerm.function),
          'lexeme': LexemeDiagnosticArgument('calc'),
          'number': NumberDiagnosticArgument(3),
        },
      );

      expect(diagnostic.code, equals(DiagnosticCode.unrecognizedCharacter));
      expect(diagnostic.severity, equals(Severity.error));
      expect(diagnostic.span, equals(span));
      expect(diagnostic.relatedSpans, hasLength(1));
      expect(diagnostic.relatedSpans.first, equals(relatedSpan));
      expect(diagnostic.arguments, hasLength(5));
      expect(
        diagnostic.arguments['lexeme'],
        equals(const LexemeDiagnosticArgument('calc')),
      );
    });

    test('implements value equality across fields and collections', () {
      final diag1 = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.warning,
        span: span,
        relatedSpans: [relatedSpan],
        arguments: const {'name': LexemeDiagnosticArgument('x')},
      );
      final diag2 = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.warning,
        span: span,
        relatedSpans: [relatedSpan],
        arguments: const {'name': LexemeDiagnosticArgument('x')},
      );
      final diag3 = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: span,
      );

      expect(diag1, equals(diag2));
      expect(diag1.hashCode, equals(diag2.hashCode));
      expect(diag1, isNot(equals(diag3)));
    });
  });
}
