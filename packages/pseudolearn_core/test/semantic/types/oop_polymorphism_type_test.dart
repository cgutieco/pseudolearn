import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

TypeCheckResult analyzeProgram(String source) {
  const profile = ClassicSpanishProfile.strict();
  final tokens = Lexer(profile).tokenize(source).tokens;
  final parseResult = Parser().parse(TokenStream(tokens));
  expect(parseResult.program, isNotNull);

  final nameResolver = NameResolver(profile: profile);
  final resolution = nameResolver.resolve(parseResult.program!);

  final typeChecker = TypeChecker(
    resolution: resolution,
    profile: profile,
    strictInitialization: true,
  );
  return typeChecker.check(parseResult.program!);
}

void main() {
  group('OOP Polymorphism and Object Types (11, 12.9)', () {
    test(
        'subclass instance assigned to superclass variable is valid (polymorphism)',
        () {
      const src = '''
Clase Animal
    Publico Definir nombre Como Cadena
FinClase

Clase Perro Hereda De Animal
FinClase

Proceso Principal
    Definir a Como Animal
    Definir p Como Perro
    p <- Nuevo Perro()
    a <- p
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.where(
          (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
        ),
        isEmpty,
      );
    });

    test(
        'superclass instance assigned to subclass variable produces error (12.1, 12.9)',
        () {
      const src = '''
Clase Animal
FinClase

Clase Perro Hereda De Animal
FinClase

Proceso Principal
    Definir a Como Animal
    Definir p Como Perro
    a <- Nuevo Animal()
    p <- a
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
        ),
        isTrue,
      );
    });

    test('instantiation arguments must match constructor parameters', () {
      const src = '''
Clase Persona
    Privado Definir edad Como Entero

    Metodo Constructor(e Como Entero)
        Este.edad <- e
    FinMetodo
FinClase

Proceso Principal
    Definir p Como Persona
    p <- Nuevo Persona("no es entero")
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.incompatibleArgumentType,
        ),
        isTrue,
      );
    });

    test(
        'writing an object instance directly produces objectCannotBeWritten (11.8)',
        () {
      const src = '''
Clase Persona
FinClase

Proceso Principal
    Definir p Como Persona
    p <- Nuevo Persona()
    Escribir p
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.objectCannotBeWritten),
        isTrue,
      );
    });
  });
}
