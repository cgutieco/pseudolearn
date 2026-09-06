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
  group('Subroutine Arguments and Return Types', () {
    test('argument count mismatch is detected on call', () {
      const src = '''
SubProceso Sumar(a Como Entero, b Como Entero) Como Entero
    Retornar a + b
FinSubProceso

Proceso Principal
    Definir res Como Entero
    res <- Sumar(1)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.argumentCountMismatch,
        ),
        isTrue,
      );
    });

    test('incompatible argument type for by-value parameter is detected', () {
      const src = '''
SubProceso ImprimirCadena(s Como Cadena)
    Escribir s
FinSubProceso

Proceso Principal
    ImprimirCadena(123)
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

    test('by-reference parameter requires designator (10.4)', () {
      const src = '''
SubProceso Incrementar(n Como Entero Por Referencia)
    n <- n + 1
FinSubProceso

Proceso Principal
    Incrementar(10 + 5)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.byReferenceArgumentRequiresDesignator,
        ),
        isTrue,
      );
    });

    test('by-reference parameter rejects integer to real conversion (10.4)',
        () {
      const src = '''
SubProceso Modificar(r Como Real Por Referencia)
    r <- 3.14
FinSubProceso

Proceso Principal
    Definir x Como Entero
    x <- 10
    Modificar(x)
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.byReferenceArgumentTypeMismatch,
        ),
        isTrue,
      );
    });

    test('passing array element as by-reference argument is valid (10.4)', () {
      const src = '''
SubProceso Intercambiar(a Como Entero Por Referencia, b Como Entero Por Referencia)
    Definir aux Como Entero
    aux <- a
    a <- b
    b <- aux
FinSubProceso

Proceso Principal
    Dimension v[2] Como Entero
    v[1] <- 10
    v[2] <- 20
    Intercambiar(v[1], v[2])
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.where(
          (d) =>
              d.code == DiagnosticCode.byReferenceArgumentRequiresDesignator ||
              d.code == DiagnosticCode.byReferenceArgumentTypeMismatch,
        ),
        isEmpty,
      );
    });

    test(
        'subroutine without return statement when return type is declared (10.5)',
        () {
      const src = '''
SubProceso Calcular(a Como Entero) Como Entero
    Definir x Como Entero
    x <- a * 2
FinSubProceso

Proceso Principal
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.subroutineWithoutReturn),
        isTrue,
      );
    });

    test(
        'returning expression in void subroutine produces returnExpressionInVoidSubroutine (10.5)',
        () {
      const src = '''
SubProceso Saludar()
    Retornar "hola"
FinSubProceso

Proceso Principal
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.returnExpressionInVoidSubroutine,
        ),
        isTrue,
      );
    });

    test('incompatible return type is detected', () {
      const src = '''
SubProceso ObtenerNumero() Como Entero
    Retornar "no es numero"
FinSubProceso

Proceso Principal
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.incompatibleReturnType),
        isTrue,
      );
    });

    test(
        'calling void subroutine inside expression produces callAsExpressionWithoutReturnType (10.6)',
        () {
      const src = '''
SubProceso HacerAlgo()
FinSubProceso

Proceso Principal
    Definir x Como Entero
    x <- HacerAlgo() + 1
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.callAsExpressionWithoutReturnType,
        ),
        isTrue,
      );
    });

    test(
        'calling function as statement produces discardedReturnValue warning (10.6)',
        () {
      const src = '''
SubProceso ObtenerValor() Como Entero
    Retornar 42
FinSubProceso

Proceso Principal
    ObtenerValor()
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.discardedReturnValue),
        isTrue,
      );
    });
  });
}
