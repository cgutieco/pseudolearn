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
  group('Builtin function calls: arity', () {
    test('too few arguments to a math builtin is a diagnostic', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    x <- rc()
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.argumentCountMismatch),
        isTrue,
      );
    });

    test('too many arguments to a math builtin is a diagnostic', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    x <- rc(4, 1, 2)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.argumentCountMismatch),
        isTrue,
      );
    });

    test('correct arity for a math builtin has no arity diagnostic', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    x <- rc(4)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.argumentCountMismatch),
        isFalse,
      );
    });

    test('random takes no arguments', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    x <- azar()
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.argumentCountMismatch),
        isFalse,
      );
    });
  });

  group('Builtin function calls: argument types', () {
    test('non-numeric argument to a math builtin is a diagnostic', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    x <- rc("hola")
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.incompatibleArgumentType),
        isTrue,
      );
    });

    test('truncate and round return integer, not real', () {
      const src = '''
Proceso Principal
    Definir a Como Entero
    Definir b Como Entero
    a <- trunc(3.5)
    b <- redon(3.5)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
          result.diagnostics.any((d) => d.severity == Severity.error), isFalse);
    });

    test('length requires a string argument', () {
      const src = '''
Proceso Principal
    Definir n Como Entero
    n <- Longitud(42)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.incompatibleArgumentType),
        isTrue,
      );
    });

    test('length of a string is well typed', () {
      const src = '''
Proceso Principal
    Definir n Como Entero
    n <- Longitud("hola")
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
          result.diagnostics.any((d) => d.severity == Severity.error), isFalse);
    });

    test('characterAt requires string and integer, returns character', () {
      const src = '''
Proceso Principal
    Definir c Como Caracter
    c <- CaracterEn("hola", 0)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
          result.diagnostics.any((d) => d.severity == Severity.error), isFalse);
    });

    test('toText accepts any primitive and returns string', () {
      const src = '''
Proceso Principal
    Definir s Como Cadena
    s <- ATexto(42)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
          result.diagnostics.any((d) => d.severity == Severity.error), isFalse);
    });

    test('shallowCopy on a non-class argument is a diagnostic', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- Copiar(4)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.incompatibleArgumentType),
        isTrue,
      );
    });
  });
}
