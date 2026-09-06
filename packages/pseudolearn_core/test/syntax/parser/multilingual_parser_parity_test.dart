import 'package:pseudolearn_core/src/domain/profile/language_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parse_result.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

ParseResult _parse(String source, LanguageProfile profile) {
  final lexer = Lexer(profile);
  final result = lexer.tokenize(source);
  final stream = TokenStream(result.tokens);
  return Parser(profile: profile).parse(stream);
}

void main() {
  group('Multilingual Parser Parity', () {
    test('variable declaration produces equivalent AST in Spanish and English',
        () {
      final spanish = _parse('''
Proceso Test
  Definir total Como Entero
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
algorithm Test
  define total as integer;
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.diagnostics, isEmpty);
      expect(english.diagnostics, isEmpty);

      final spBody = spanish.program!.algorithm!.body;
      final enBody = english.program!.algorithm!.body;
      expect(spBody.length, equals(enBody.length));

      final spDecl = spBody.first as VariableDeclarationNode;
      final enDecl = enBody.first as VariableDeclarationNode;
      expect(spDecl.variables.map((v) => v.name),
          equals(enDecl.variables.map((v) => v.name)));
      expect(spDecl.type, equals(enDecl.type));
    });

    test('if-else statement produces equivalent AST structure in both profiles',
        () {
      final spanish = _parse('''
Proceso Test
  Definir total Como Entero
  Si total > 0 Entonces
    Escribir total
  Sino
    Escribir 0
  FinSi
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
algorithm Test
  define total as integer;
  if total > 0 then
    write total;
  else
    write 0;
  endIf
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.diagnostics, isEmpty);
      expect(english.diagnostics, isEmpty);

      final spBody = spanish.program!.algorithm!.body;
      final enBody = english.program!.algorithm!.body;
      expect(spBody.length, equals(enBody.length));

      final spIf = spBody[1] as IfStatementNode;
      final enIf = enBody[1] as IfStatementNode;
      expect(spIf.thenBody.length, equals(enIf.thenBody.length));
      expect(spIf.elseBody?.length, equals(enIf.elseBody?.length));
    });

    test('for loop produces equivalent AST structure in both profiles', () {
      final spanish = _parse('''
Proceso Test
  Definir i Como Entero
  Para i <- 1 Hasta 10 Con Paso 1 Hacer
    Escribir i
  FinPara
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
algorithm Test
  define i as integer;
  for i <- 1 to 10 step 1 do
    write i;
  endFor
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.diagnostics, isEmpty);
      expect(english.diagnostics, isEmpty);

      final spFor = spanish.program!.algorithm!.body[1] as ForStatementNode;
      final enFor = english.program!.algorithm!.body[1] as ForStatementNode;
      expect(spFor.body.length, equals(enFor.body.length));
      expect(spFor.step, isNotNull);
      expect(enFor.step, isNotNull);
    });

    test('switch statement produces equivalent case count in both profiles',
        () {
      final spanish = _parse('''
Proceso Test
  Definir opct Como Entero
  Segun opct Hacer
    1:
      Escribir "uno"
    2:
      Escribir "dos"
    De Otro Modo:
      Escribir "otro"
  FinSegun
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
algorithm Test
  define opct as integer;
  switch opct do
    1:
      write "one";
    2:
      write "two";
    otherwise:
      write "other";
  endSwitch
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.diagnostics, isEmpty);
      expect(english.diagnostics, isEmpty);

      final spSwitch =
          spanish.program!.algorithm!.body[1] as SwitchStatementNode;
      final enSwitch =
          english.program!.algorithm!.body[1] as SwitchStatementNode;
      expect(spSwitch.cases.length, equals(enSwitch.cases.length));
      expect(spSwitch.defaultCase, isNotNull);
      expect(enSwitch.defaultCase, isNotNull);
    });

    test('program name is preserved identically in both profiles', () {
      final spanish = _parse('''
Proceso MiAlgoritmo
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
algorithm MiAlgoritmo
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.program!.algorithm!.name,
          equals(english.program!.algorithm!.name));
    });
  });
}
