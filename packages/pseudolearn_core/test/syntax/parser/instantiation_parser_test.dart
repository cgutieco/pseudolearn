import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Instantiation Parser (Happy path)', () {
    test('parses new instance without arguments in Spanish', () {
      const source = '''
Algoritmo Test
  Definir p Como Persona
  p <- Nuevo Persona()
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final alg = result.program!.algorithm!;
      final assign = alg.body.whereType<AssignmentStatementNode>().first;
      expect(assign.value, isA<InstantiationExpressionNode>());
      final inst = assign.value as InstantiationExpressionNode;
      expect(inst.className, equals('Persona'));
      expect(inst.arguments, isEmpty);
    });

    test('parses new instance with arguments in Spanish', () {
      const source = '''
Algoritmo Test
  p <- Nuevo Persona(25, "Carlos")
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final alg = result.program!.algorithm!;
      final assign = alg.body.whereType<AssignmentStatementNode>().first;
      final inst = assign.value as InstantiationExpressionNode;
      expect(inst.className, equals('Persona'));
      expect(inst.arguments, hasLength(2));
    });

    test('parses new instance in English profile', () {
      const source = '''
algorithm Test
  p <- new Person(42);
endAlgorithm
''';
      final profile = const EnglishProfile.flexible();
      final tokens = Lexer(profile).tokenize(source).tokens;
      final result = Parser(profile: profile).parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final alg = result.program!.algorithm!;
      final assign = alg.body.whereType<AssignmentStatementNode>().first;
      final inst = assign.value as InstantiationExpressionNode;
      expect(inst.className, equals('Person'));
      expect(inst.arguments, hasLength(1));
    });
  });

  group('Instantiation Parser (Unhappy path)', () {
    test('reports expectedClassNameInInstantiation when identifier is missing',
        () {
      const source = '''
Algoritmo Test
  p <- Nuevo 123()
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedClassNameInInstantiation),
      );
    });

    test('reports missingInstantiationParentheses when parentheses are omitted',
        () {
      const source = '''
Algoritmo Test
  p <- Nuevo Persona
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.missingInstantiationParentheses),
      );
    });

    test('reports unclosedParenthesis when closing paren is missing', () {
      const source = '''
Algoritmo Test
  p <- Nuevo Persona(1, 2
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedParenthesis),
      );
    });
  });
}
