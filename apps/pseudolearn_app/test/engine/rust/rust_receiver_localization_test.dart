import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import '../../fakes/native_test_engine.dart';

const _english = '''
class Counter
constructor()
endConstructor
method Show()
write 1;
endMethod
endClass
algorithm Main
define value as Counter <- new Counter();
value.Show();
endAlgorithm
''';
const _spanish = '''
Clase Counter
Constructor()
FinConstructor
Metodo Show()
Escribir 1;
FinMetodo
FinClase
Algoritmo Main
Definir value Como Counter <- Nuevo Counter();
value.Show();
FinAlgoritmo
''';

void main() {
  for (final (source, profile, expected) in [
    (_english, SyntaxProfileId.english, 'this'),
    (_spanish, SyntaxProfileId.classicSpanish, 'Este'),
  ]) {
    test('receiver rows use the vocabulary of $profile', () {
      final execution =
          nativeTestEngine.createProgramExecution() as RustProgramExecution;
      var step = execution.startExecution(
        sourceCode: source,
        profileId: profile,
        languageId: UiLanguageId.english,
      );
      final names = <String>{};
      for (var count = 0; count < 100 && !step.isTerminal; count++) {
        step = execution.step();
        names.addAll(
          step.variables
              .where((row) => row.identityBadge != null)
              .map((row) => row.name),
        );
      }
      expect(names, contains(expected));
      expect(names, isNot(contains(expected == 'this' ? 'Este' : 'this')));
      execution.stop();
    });
  }
}
