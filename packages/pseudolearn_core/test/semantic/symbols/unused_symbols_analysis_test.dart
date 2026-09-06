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

  group('Unused variable analysis (12.8)', () {
    test(
        'reports variableDeclaredNeverUsed when declared without read or write',
        () {
      const source = '''
Algoritmo Principal
  Definir x Como Entero
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.variableDeclaredNeverUsed),
      );
    });

    test('reports variableAssignedNeverRead when assigned but never read', () {
      const source = '''
Algoritmo Principal
  Definir total Como Entero
  total <- 100
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.variableAssignedNeverRead),
      );
    });

    test('no hygiene warning when variable is assigned and read', () {
      const source = '''
Algoritmo Principal
  Definir resultado Como Entero
  resultado <- 50
  Escribir resultado
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.where(
          (d) =>
              d.code == DiagnosticCode.variableDeclaredNeverUsed ||
              d.code == DiagnosticCode.variableAssignedNeverRead,
        ),
        isEmpty,
      );
    });
  });

  group('Unused subroutines and parameters', () {
    test(
        'reports unusedSubroutine when subroutine is declared but never called',
        () {
      const source = '''
SubProceso NuncaUsado()
FinSubProceso

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unusedSubroutine),
      );
    });

    test(
        'reports unusedParameter when parameter is not read in subroutine body',
        () {
      const source = '''
SubProceso Saludar(nombre Como Cadena)
  Escribir "Hola"
FinSubProceso

Algoritmo Principal
  Saludar("Mundo")
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unusedParameter),
      );
    });
  });

  group('Special usage rules (12.8)', () {
    test('for loop control variable is treated as assigned and read', () {
      const source = '''
Algoritmo Principal
  Definir i Como Entero
  Para i <- 1 Hasta 10 Con Paso 1 Hacer
    Escribir "Paso"
  FinPara
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.where(
          (d) =>
              d.code == DiagnosticCode.variableDeclaredNeverUsed ||
              d.code == DiagnosticCode.variableAssignedNeverRead,
        ),
        isEmpty,
      );
    });

    test(
        'variable passed by reference to subroutine is treated as read and assigned',
        () {
      const source = '''
SubProceso ModificarPorReferencia(PorReferencia n Como Entero)
  n <- n + 1
FinSubProceso

Algoritmo Principal
  Definir val Como Entero
  val <- 10
  ModificarPorReferencia(val)
  Escribir val
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.where(
          (d) =>
              d.code == DiagnosticCode.variableDeclaredNeverUsed ||
              d.code == DiagnosticCode.variableAssignedNeverRead,
        ),
        isEmpty,
      );
    });
  });
}
