import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

TypeCheckResult runPipeline(
  String source, {
  required LanguageProfile profile,
}) {
  final tokens = Lexer(profile).tokenize(source).tokens;
  final parseResult = Parser().parse(TokenStream(tokens));
  expect(parseResult.program, isNotNull);

  final nameResolver = NameResolver(profile: profile);
  final resolution = nameResolver.resolve(parseResult.program!);

  final typeChecker = TypeChecker(
    resolution: resolution,
    profile: profile,
    strictInitialization: profile.mandatoryInitialization,
  );
  return typeChecker.check(parseResult.program!);
}

void main() {
  group('Strict vs Flexible Severity Parity (12.10)', () {
    test(
        'undeclared variable is Error in strict profile and Warning in flexible profile',
        () {
      const src = '''
Proceso Principal
    x <- 10
FinProceso
''';

      const strictProfile = ClassicSpanishProfile.strict();
      const flexibleProfile = ClassicSpanishProfile.flexible();

      final strictResult = runPipeline(src, profile: strictProfile);
      final flexibleResult = runPipeline(src, profile: flexibleProfile);

      final strictDiag = strictResult.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );
      final flexibleDiag = flexibleResult.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );

      expect(strictDiag.severity, equals(Severity.error));
      expect(flexibleDiag.severity, equals(Severity.warning));
    });

    test('structural type error is Error in BOTH profiles (Class A invariant)',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- "texto"
FinProceso
''';

      const strictProfile = ClassicSpanishProfile.strict();
      const flexibleProfile = ClassicSpanishProfile.flexible();

      final strictResult = runPipeline(src, profile: strictProfile);
      final flexibleResult = runPipeline(src, profile: flexibleProfile);

      final strictDiag = strictResult.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
      );
      final flexibleDiag = flexibleResult.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
      );

      expect(strictDiag.severity, equals(Severity.error));
      expect(flexibleDiag.severity, equals(Severity.error));
    });
  });
}
