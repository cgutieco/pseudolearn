import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_construct_reader.dart';

const _withLoopAndConditional = '''
Algoritmo Conteo
  Definir i Como Entero
  Para i <- 1 Hasta 3 Con Paso 1 Hacer
    Si i > 1 Entonces
      Escribir i
    FinSi
  FinPara
FinAlgoritmo
''';

const _withoutConstructs = '''
Algoritmo Saludo
  Escribir "hola"
FinAlgoritmo
''';

const _brokenSource = '''
Algoritmo Roto
  x <-
FinAlgoritmo
''';

void main() {
  group('CoreProgramConstructReader (PANT-06-F5)', () {
    final reader = CoreProgramConstructReader();

    test('reports every construct the program actually uses', () {
      final constructs = reader.constructsOf(
        sourceCode: _withLoopAndConditional,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(constructs, contains(AstConstruct.countedLoop));
      expect(constructs, contains(AstConstruct.conditional));
      expect(constructs, isNot(contains(AstConstruct.classDeclaration)));
    });

    test('a program without control structures reports none', () {
      final constructs = reader.constructsOf(
        sourceCode: _withoutConstructs,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(constructs, isEmpty);
    });

    test('a program that does not analyse contributes nothing', () {
      final constructs = reader.constructsOf(
        sourceCode: _brokenSource,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(constructs, isEmpty);
    });

    test('an empty source is read without failing', () {
      expect(
        reader.constructsOf(
          sourceCode: '',
          profileId: SyntaxProfileId.classicSpanish,
        ),
        isEmpty,
      );
    });
  });
}
