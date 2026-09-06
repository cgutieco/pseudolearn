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
  group('Control Flow and Array Type Checking', () {
    test(
        'non-boolean condition in If statement produces nonBooleanCondition (12.12)',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 10
    Si x Entonces
        Escribir "hola"
    FinSi
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.nonBooleanCondition),
        isTrue,
      );
    });

    test(
        'non-boolean condition in While statement produces nonBooleanCondition',
        () {
      const src = '''
Proceso Principal
    Definir s Como Cadena
    s <- "texto"
    Mientras s Hacer
        Escribir s
    FinMientras
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.nonBooleanCondition),
        isTrue,
      );
    });

    test('non-integer bounds in For loop produce nonIntegerForBound (8.5)', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 3.14 Con Paso 1 Hacer
        Escribir i
    FinPara
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.nonIntegerForBound),
        isTrue,
      );
    });

    test(
        'non-integer array index in access produces nonIntegerArrayIndex (12.9)',
        () {
      const src = '''
Proceso Principal
    Dimension a[10] Como Entero
    Definir val Como Entero
    val <- a[2.5]
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.nonIntegerArrayIndex),
        isTrue,
      );
    });

    test(
        'array access with incorrect number of dimensions produces arrayDimensionCountMismatch (12.9)',
        () {
      const src = '''
Proceso Principal
    Dimension matriz[3, 3] Como Entero
    Definir val Como Entero
    val <- matriz[1]
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.arrayDimensionCountMismatch),
        isTrue,
      );
    });

    test(
        'using complete array as scalar value in write or expression produces arrayCannotBeUsedAsValue (9.1, 11.8)',
        () {
      const src = '''
Proceso Principal
    Dimension a[5] Como Entero
    Escribir a
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.arrayCannotBeUsedAsValue),
        isTrue,
      );
    });

    test(
        'switch case label with real value produces incompatibleSwitchCaseType (8.2, 12.10)',
        () {
      const src = '''
Proceso Principal
    Definir n Como Entero
    n <- 5
    Segun n Hacer
        3.14:
            Escribir "pi"
    FinSegun
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.incompatibleSwitchCaseType,
        ),
        isTrue,
      );
    });
  });
}
