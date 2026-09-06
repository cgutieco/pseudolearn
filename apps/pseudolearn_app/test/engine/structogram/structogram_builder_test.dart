import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/program_analysis.dart';
import 'package:pseudolearn_app/engine/diagram/diagram_vocabulary.dart';
import 'package:pseudolearn_app/engine/diagram/statement_caption.dart';
import 'package:pseudolearn_app/engine/printing/pseudocode_printer.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_builder.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_cell.dart';

StructogramCellBuilder _builderFor(
  ProgramAnalysis analysis,
  UiLanguageId language,
) {
  final vocabulary = DiagramVocabulary.forLanguage(language);
  return StructogramCellBuilder(
    vocabulary: vocabulary,
    caption: StatementCaption(
      printer: PseudocodePrinter(analysis.profile),
      lexicon: analysis.profile,
      vocabulary: vocabulary,
    ),
  );
}

StructogramCell _cellsOf(
  String body, {
  UiLanguageId language = UiLanguageId.spanish,
}) {
  final analysis = ProgramAnalysis.of(
    'Proceso P\n$body\nFinProceso\n',
    SyntaxProfileId.classicSpanish,
  );
  return _builderFor(analysis, language)
      .buildBody(analysis.sourceUnit!.algorithm!.body);
}

StructogramCell _subroutineCellsOf(String subroutine) {
  final analysis = ProgramAnalysis.of(
    'Proceso P\n    Definir z Como Entero;\nFinProceso\n$subroutine',
    SyntaxProfileId.classicSpanish,
  );
  return _builderFor(analysis, UiLanguageId.spanish)
      .buildBody(analysis.sourceUnit!.subroutines.first.body);
}

StructogramCell _last(String body) =>
    (_cellsOf(body) as StructogramStack).children.last;

void main() {
  group('a sequence', () {
    test('becomes a vertical stack with one cell per statement', () {
      final stack = _cellsOf('    Definir n Como Entero;\n    n <- 5;')
          as StructogramStack;
      expect(stack.children, hasLength(2));
      expect(stack.children.first, isA<StructogramLeaf>());
    });

    test('with no statement becomes a single empty cell', () {
      final cell = _cellsOf('') as StructogramLeaf;
      expect(cell.kind, StructogramLeafKind.empty);
      expect(cell.lines, ['Sin sentencias']);
    });
  });

  group('leaf kinds', () {
    test(
        'a read and a write are plain process cells, distinguished by their words',
        () {
      final stack = _cellsOf('''
      Definir n Como Entero;
      Leer n;
      Escribir n;''') as StructogramStack;
      final read = stack.children[1] as StructogramLeaf;
      final write = stack.children[2] as StructogramLeaf;
      expect(read.kind, StructogramLeafKind.process);
      expect(write.kind, StructogramLeafKind.process);
      expect(read.lines.join(' '), startsWith('Leer'));
      expect(write.lines.join(' '), startsWith('Escribir'));
    });

    test('a return becomes an exit cell', () {
      final cells = _subroutineCellsOf(
        'SubProceso F() Como Entero\n    Retornar 1;\nFinSubProceso\n',
      );
      final exit = (cells as StructogramStack).children.last as StructogramLeaf;
      expect(exit.kind, StructogramLeafKind.exit);
      expect(exit.lines.join(' '), contains('Retornar'));
    });
  });

  group('a conditional', () {
    test('puts the affirmative column first and both labels in place', () {
      final branch = _last('''
      Definir a Como Entero;
      Si a > 0 Entonces
          Escribir "si";
      SiNo
          Escribir "no";
      FinSi''') as StructogramBranch;
      expect(branch.isBinary, isTrue);
      expect(
          branch.columns.map((column) => column.label).toList(), ['SÍ', 'NO']);
      expect(branch.headerLines.join(' '), contains('a > 0'));
    });

    test('fills a missing negative branch with an empty cell', () {
      final branch = _last('''
      Definir a Como Entero;
      Si a > 0 Entonces
          Escribir "si";
      FinSi''') as StructogramBranch;
      final negative = branch.columns.last.body as StructogramLeaf;
      expect(negative.kind, StructogramLeafKind.empty);
    });
  });

  group('a selection', () {
    test('is not binary and keeps one column per case', () {
      final branch = _last('''
      Definir opcion Como Entero;
      Segun opcion Hacer
          1:
              Escribir "uno";
          De Otro Modo:
              Escribir "otro";
      FinSegun''') as StructogramBranch;
      expect(branch.isBinary, isFalse);
      expect(branch.columns, hasLength(2));
      expect(branch.columns.first.label, '1');
    });
  });

  group('the three loops', () {
    test('a while and a counted loop carry their header on top', () {
      final whileLoop = _last('''
      Definir k Como Entero;
      Mientras k < 3 Hacer
          k <- k + 1;
      FinMientras''') as StructogramLoop;
      final forLoop = _last('''
      Definir i Como Entero;
      Para i <- 1 Hasta 3 Hacer
          Escribir i;
      FinPara''') as StructogramLoop;
      expect(whileLoop.position, StructogramLoopPosition.header);
      expect(forLoop.position, StructogramLoopPosition.header);
      expect(forLoop.headerLines.join(' '), contains('Hasta 3'));
    });

    test('a repeat-until carries its condition at the foot', () {
      final loop = _last('''
      Definir k Como Entero;
      Repetir
          k <- k - 1;
      Hasta Que k = 0''') as StructogramLoop;
      expect(loop.position, StructogramLoopPosition.footer);
      expect(loop.headerLines.join(' '), contains('k = 0'));
    });

    test('an empty loop body becomes an empty cell, never a missing one', () {
      final loop = _last('''
      Definir k Como Entero;
      Mientras k < 3 Hacer
      FinMientras''') as StructogramLoop;
      expect((loop.body as StructogramLeaf).kind, StructogramLeafKind.empty);
    });
  });

  group('text', () {
    test('is wrapped to at most three lines and elided beyond that', () {
      final cell = _last(
        '    Escribir "${'palabra ' * 60}";',
      ) as StructogramLeaf;
      expect(cell.lines.length, lessThanOrEqualTo(3));
      expect(cell.lines.last, endsWith('…'));
    });

    test('changes with the interface language only for interface words', () {
      final english =
          _cellsOf('', language: UiLanguageId.english) as StructogramLeaf;
      expect(english.lines, ['No statements']);
    });
  });
}
