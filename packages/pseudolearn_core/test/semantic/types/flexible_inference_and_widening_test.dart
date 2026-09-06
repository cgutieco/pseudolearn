import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

TypeCheckResult analyzeFlexibleProgram(String source) {
  const profile = ClassicSpanishProfile.flexible();
  final tokens = Lexer(profile).tokenize(source).tokens;
  final parseResult = Parser().parse(TokenStream(tokens));
  expect(parseResult.program, isNotNull);

  final nameResolver = NameResolver(profile: profile);
  final resolution = nameResolver.resolve(parseResult.program!);

  final typeChecker = TypeChecker(
    resolution: resolution,
    profile: profile,
    strictInitialization: false,
  );
  return typeChecker.check(parseResult.program!);
}

void main() {
  group('Flexible Inference and Widening (12.5, 12.6)', () {
    test('first assignment infers type with informational diagnostic (12.5)',
        () {
      const src = '''
Proceso Principal
    x <- 42
FinProceso
''';
      final result = analyzeFlexibleProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.inferredVariableType),
        isTrue,
      );
    });

    test(
        'reassigning real to inferred integer widens type with diagnostic (12.6)',
        () {
      const src = '''
Proceso Principal
    x <- 10
    x <- 3.14
FinProceso
''';
      final result = analyzeFlexibleProgram(src);
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.widenedVariableType),
        isTrue,
      );
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.typeConflictOnInferredVariable,
        ),
        isFalse,
      );
    });

    test(
        'reassigning string to inferred integer produces typeConflictOnInferredVariable (12.6)',
        () {
      const src = '''
Proceso Principal
    x <- 10
    x <- "texto"
FinProceso
''';
      final result = analyzeFlexibleProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.typeConflictOnInferredVariable,
        ),
        isTrue,
      );
    });

    test(
        'no widening between sibling classes produces typeConflictOnInferredVariable (12.6)',
        () {
      const src = '''
Clase Mascota
FinClase

Clase Gato Hereda De Mascota
FinClase

Clase Perro Hereda De Mascota
FinClase

Proceso Principal
    m <- Nuevo Gato()
    m <- Nuevo Perro()
FinProceso
''';
      final result = analyzeFlexibleProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.typeConflictOnInferredVariable,
        ),
        isTrue,
      );
    });

    test(
        'explicitly declared variable does NOT widen; produces assignment error (12.6)',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 10
    x <- 3.14
FinProceso
''';
      final result = analyzeFlexibleProgram(src);
      expect(
        result.diagnostics.any(
          (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
        ),
        isTrue,
      );
      expect(
        result.diagnostics
            .any((d) => d.code == DiagnosticCode.widenedVariableType),
        isFalse,
      );
    });

    test('read statement gives indeterminate type and defers checks', () {
      const src = '''
Proceso Principal
    Leer val
    res <- val + 5
FinProceso
''';
      final result = analyzeFlexibleProgram(src);
      expect(
        result.diagnostics.where(
          (d) =>
              d.code == DiagnosticCode.incompatibleTypesInAssignment ||
              d.code == DiagnosticCode.incompatibleOperandTypes,
        ),
        isEmpty,
      );
    });
  });
}
