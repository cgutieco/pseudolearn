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

  group('Algorithm and Subroutine Scope Isolation (10.7)', () {
    test('algorithm variables are NOT visible inside subroutines', () {
      const source = '''
Algoritmo Principal
  Definir variableGlobal Como Entero
  variableGlobal <- 10
  Modificar()
FinAlgoritmo

SubProceso Modificar()
  variableGlobal <- 20
FinSubProceso
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.undeclaredVariable),
      );
    });
  });

  group('Absence of block scopes and interleaved declarations (6.1)', () {
    test('variable declared inside if block is visible after if statement', () {
      const source = '''
Algoritmo Principal
  Definir condicion Como Logico
  condicion <- Verdadero
  Si condicion Entonces
    Definir resultado Como Entero
    resultado <- 42
  FinSi
  Escribir resultado
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.undeclaredVariable),
        isEmpty,
      );
    });

    test('variable declared inside loop block is visible after loop', () {
      const source = '''
Algoritmo Principal
  Definir i Como Entero
  Para i <- 1 Hasta 5 Con Paso 1 Hacer
    Definir ultimoValor Como Entero
    ultimoValor <- i * 2
  FinPara
  Escribir ultimoValor
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.undeclaredVariable),
        isEmpty,
      );
    });
  });

  group('Sequential declaration order diagnostics', () {
    test(
        'reports variableUsedBeforeDeclaration when read before declaration line',
        () {
      const source = '''
Algoritmo Principal
  Escribir x
  Definir x Como Entero
  x <- 5
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.variableUsedBeforeDeclaration),
      );
    });

    test(
        'reports variableUsedBeforeDeclaration when written before declaration line',
        () {
      const source = '''
Algoritmo Principal
  x <- 10
  Definir x Como Entero
  Escribir x
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.variableUsedBeforeDeclaration),
      );
    });
  });

  group('Duplicate declarations and name collisions', () {
    test(
        'reports duplicateVariableDeclaration when declared twice in same scope',
        () {
      const source = '''
Algoritmo Principal
  Definir edad Como Entero
  Definir edad Como Real
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateVariableDeclaration),
      );
    });

    test(
        'reports subroutineAndVariableSameName when variable has same name as subroutine',
        () {
      const source = '''
SubProceso Procesar()
FinSubProceso

Algoritmo Principal
  Definir Procesar Como Entero
  Procesar <- 5
  Escribir Procesar
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.subroutineAndVariableSameName),
      );
    });
  });
}
