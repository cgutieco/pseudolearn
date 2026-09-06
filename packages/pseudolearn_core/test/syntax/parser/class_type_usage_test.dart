import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Class as Type in Declarations (Happy path)', () {
    test('parses variable declaration with custom class type', () {
      const source = '''
Algoritmo Test
  Definir p Como Persona
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final decl =
          result.program!.algorithm!.body.first as VariableDeclarationNode;
      expect(decl.type, isNull);
      expect(decl.customTypeName, equals('Persona'));
    });

    test('parses dimension statement with custom class type', () {
      const source = '''
Algoritmo Test
  Dimension lista[50] Como Alumno
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final dim =
          result.program!.algorithm!.body.first as DimensionStatementNode;
      expect(dim.elementType, isNull);
      expect(dim.customElementTypeName, equals('Alumno'));
    });

    test('parses subroutine parameters and return type with custom class type',
        () {
      const source = '''
SubProceso Clonar(origen Como Persona) Como Persona
FinSubProceso

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final sub = result.program!.subroutines.first;
      expect(sub.customReturnType, equals('Persona'));
      expect(sub.parameters.first.customTypeName, equals('Persona'));
    });

    test('parses method parameters and return type with custom class type', () {
      const source = '''
Clase Fabrica
  Metodo Fabricar(p Como Molde) Como Producto
  FinMetodo
FinClase

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final m = result.program!.classes.first.members
          .whereType<MethodDeclarationNode>()
          .first;
      expect(m.customReturnType, equals('Producto'));
      expect(m.parameters.first.customTypeName, equals('Molde'));
    });
  });

  group('Class as Type in Declarations (Unhappy path)', () {
    test(
        'reports invalidArrayReturnType when custom type is followed by brackets in return',
        () {
      const source = '''
SubProceso ObtenerTodos() Como Persona[]
FinSubProceso

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.invalidArrayReturnType),
      );
    });

    test(
        'reports unsupportedGenericsConstruct when generic brackets are used in type',
        () {
      const source = '''
Algoritmo Test
  Definir lista Como Lista<Persona>
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedGenericsConstruct),
      );
    });
  });
}
