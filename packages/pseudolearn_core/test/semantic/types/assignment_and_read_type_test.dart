import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

TypeCheckResult analyzeProgram(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.strict(),
  bool? strictInitialization,
}) {
  final tokens = Lexer(profile).tokenize(source).tokens;
  final parseResult = Parser().parse(TokenStream(tokens));
  expect(parseResult.program, isNotNull);
  expect(
    parseResult.diagnostics,
    isEmpty,
    reason: 'a type-checking fixture must be syntactically valid',
  );

  final nameResolver = NameResolver(profile: profile);
  final resolution = nameResolver.resolve(parseResult.program!);

  final typeChecker = TypeChecker(
    resolution: resolution,
    profile: profile,
    strictInitialization: strictInitialization,
  );
  return typeChecker.check(parseResult.program!);
}

void main() {
  group('Assignment and Read Type Checking', () {
    test('compatible primitive assignments pass with zero type errors', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    Definir r Como Real
    Definir s Como Cadena
    x <- 10
    r <- 3.14
    r <- x
    s <- "Hola"
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics.where(
            (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment),
        isEmpty,
      );
    });

    test(
        'assigning real to integer produces incompatibleTypesInAssignment (no implicit truncation, 12.1)',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 3.14
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.incompatibleTypesInAssignment),
        isTrue,
      );
    });

    test('assigning string to boolean produces incompatibleTypesInAssignment',
        () {
      const src = '''
Proceso Principal
    Definir flag Como Logico
    flag <- "verdadero"
FinProceso
''';
      final result = analyzeProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.incompatibleTypesInAssignment),
        isTrue,
      );
    });

    test(
        'assigning compatible value to array element succeeds, incompatible fails',
        () {
      const src = '''
Proceso Principal
    Dimension a[5] Como Entero
    a[1] <- 42
    a[2] <- 3.14
FinProceso
''';
      final result = analyzeProgram(src);
      final assignmentErrors = result.diagnostics.where(
        (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
      );
      expect(assignmentErrors.length, equals(1));
    });

    test(
        'uninitialized variable in strict mode produces variableUsedUninitialized (12.7)',
        () {
      const src = '''
Proceso Principal
    Definir a Como Entero
    Definir b Como Entero
    b <- a + 1
FinProceso
''';
      final result = analyzeProgram(src, strictInitialization: true);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.variableUsedUninitialized),
        isTrue,
      );
    });

    test('reading variable initializes it for subsequent uses', () {
      const src = '''
Proceso Principal
    Definir a Como Entero
    Definir b Como Entero
    Leer a
    b <- a + 1
FinProceso
''';
      final result = analyzeProgram(src, strictInitialization: true);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.variableUsedUninitialized),
        isFalse,
      );
    });
  });
}
