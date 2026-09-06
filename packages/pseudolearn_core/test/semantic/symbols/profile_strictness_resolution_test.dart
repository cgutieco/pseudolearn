import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/severity.dart';
import 'package:pseudolearn_core/src/semantic/symbols/name_resolver.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Strict vs Flexible severity policy in NameResolver', () {
    const source = '''
Algoritmo Principal
  x <- 10
  Escribir x
FinAlgoritmo
''';

    test('strict profile reports undeclaredVariable with Severity.error', () {
      const strictProfile = ClassicSpanishProfile.strict();
      final tokens = Lexer(strictProfile).tokenize(source).tokens;
      final ast = Parser().parse(TokenStream(tokens)).program!;
      final result = const NameResolver(profile: strictProfile).resolve(ast);

      final diag = result.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );
      expect(diag.severity, equals(Severity.error));
      expect(result.hasErrors, isTrue);
    });

    test('flexible profile reports undeclaredVariable with Severity.warning',
        () {
      const flexibleProfile = ClassicSpanishProfile.flexible();
      final tokens = Lexer(flexibleProfile).tokenize(source).tokens;
      final ast = Parser().parse(TokenStream(tokens)).program!;
      final result = const NameResolver(profile: flexibleProfile).resolve(ast);

      final diag = result.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );
      expect(diag.severity, equals(Severity.warning));
      expect(result.hasErrors, isFalse);
    });
  });
}
