import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Pedagogical Diagnostics for OOP Foreign Constructs', () {
    test('reports unsupportedInterfaceConstruct on interface/interfaz', () {
      const spanishSource = '''
Interfaz IPersona
FinInterfaz

Algoritmo Main
FinAlgoritmo
''';
      final tokensEs = Lexer(const ClassicSpanishProfile.flexible())
          .tokenize(spanishSource)
          .tokens;
      final resultEs = Parser().parse(TokenStream(tokensEs));
      expect(
        resultEs.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedInterfaceConstruct),
      );

      const englishSource = '''
interface IPerson
endInterface

algorithm Main
endAlgorithm
''';
      final profileEn = const EnglishProfile.flexible();
      final tokensEn = Lexer(profileEn).tokenize(englishSource).tokens;
      final resultEn = Parser(profile: profileEn).parse(TokenStream(tokensEn));
      expect(
        resultEn.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedInterfaceConstruct),
      );
    });

    test(
        'reports unsupportedAbstractConstruct on abstract keyword in class member',
        () {
      const source = '''
Clase Base
  abstract Metodo M()
  FinMetodo
FinClase

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedAbstractConstruct),
      );
    });

    test('reports unsupportedStaticConstruct on static/estatico member', () {
      const source = '''
Clase Base
  estatico Definir contador Como Entero
FinClase

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedStaticConstruct),
      );
    });

    test(
        'reports unsupportedProtectedConstruct on protected/protegido visibility',
        () {
      const source = '''
Clase Base
  protegido Definir clave Como Cadena
FinClase

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedProtectedConstruct),
      );
    });

    test(
        'reports unsupportedExceptionConstruct on try/catch/throw / intentar/capturar/lanzar',
        () {
      const source = '''
Algoritmo Test
  intentar
    x <- 10 / 0
  capturar
    Escribir "Error"
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedExceptionConstruct),
      );
    });
  });
}
