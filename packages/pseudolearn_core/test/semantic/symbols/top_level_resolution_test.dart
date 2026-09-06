import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/semantic/symbols/name_resolver.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  const profile = ClassicSpanishProfile.strict();

  SourceUnitNode parseSource(String source) {
    final tokens = Lexer(profile).tokenize(source).tokens;
    final parseResult = Parser().parse(TokenStream(tokens));
    return parseResult.program!;
  }

  group('Top-level declaration order independence', () {
    test('resolves subroutine called before its declaration', () {
      const source = '''
Algoritmo Principal
  Saludar()
FinAlgoritmo

SubProceso Saludar()
  Escribir "Hola"
FinSubProceso
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.undeclaredSubroutine),
        isEmpty,
      );
    });

    test('resolves classes instantiated before their declaration', () {
      const source = '''
Algoritmo Principal
  Definir p Como Persona
  p <- Nuevo Persona()
FinAlgoritmo

Clase Persona
FinClase
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.undeclaredClass),
        isEmpty,
      );
    });
  });

  group('Top-level duplicates and conflicts', () {
    test('reports duplicateSubroutine when two subroutines share the same name',
        () {
      const source = '''
SubProceso Calcular()
FinSubProceso

SubProceso Calcular()
FinSubProceso

Algoritmo Principal
  Calcular()
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateSubroutine),
      );
    });

    test('reports duplicateClass when two classes share the same name', () {
      const source = '''
Clase Modelo
FinClase

Clase Modelo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateClass),
      );
    });

    test('reports classAndSubroutineSameName on collision', () {
      const source = '''
Clase Elemento
FinClase

SubProceso Elemento()
FinSubProceso

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.classAndSubroutineSameName),
      );
    });

    test('reports duplicateParameterName in subroutine signature', () {
      const source = '''
SubProceso Sumar(a Como Entero, a Como Entero)
FinSubProceso

Algoritmo Principal
  Sumar(1, 2)
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateParameterName),
      );
    });
  });

  group('Builtin functions resolution and shadowing', () {
    test('resolves profile builtin functions', () {
      const source = '''
Algoritmo Principal
  Definir x Como Real
  x <- rc(16)
  Escribir x
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.undeclaredSubroutine),
        isEmpty,
      );
    });

    test(
        'allows user subroutine to shadow builtin function without collision error',
        () {
      const source = '''
SubProceso rc(n Como Real) Como Real
  Retornar n
FinSubProceso

Algoritmo Principal
  Definir x Como Real
  x <- rc(9)
  Escribir x
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.duplicateSubroutine),
        isEmpty,
      );
    });
  });
}
