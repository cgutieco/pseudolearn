import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';

final StructogramLayout _layout = StructogramLayout();

const String _factorial = '''
Proceso Factorial
    Definir n Como Entero;
    Definir f Como Entero;
    Definir i Como Entero;
    n <- 5;
    f <- 1;
    Para i <- 1 Hasta n Con Paso 1 Hacer
        f <- f * i;
    FinPara
    Escribir "Factorial: ", f;
FinProceso
''';

DiagramScene _sceneOf(
  String source, {
  UiLanguageId language = UiLanguageId.spanish,
  String? unitId,
}) {
  return _layout
      .buildDiagram(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: language,
      )
      .sceneFor(unitId);
}

String _program(String body) => 'Proceso P\n$body\nFinProceso\n';

List<DiagramNode> _shaped(DiagramScene scene, DiagramShape shape) {
  final found = <DiagramNode>[];
  for (final node in scene.nodes) {
    if (node.shape == shape) found.add(node);
  }
  return found;
}

DiagramNode? _saying(DiagramScene scene, String text) {
  for (final node in scene.nodes) {
    if (node.lines.join(' ').contains(text)) return node;
  }
  return null;
}

bool _encloses(DiagramNode outer, DiagramNode inner) =>
    inner.x >= outer.x - 0.001 &&
    inner.y >= outer.y - 0.001 &&
    inner.x + inner.width <= outer.x + outer.width + 0.001 &&
    inner.y + inner.height <= outer.y + outer.height + 0.001;

int _identifiedNodes(DiagramScene scene) {
  var count = 0;
  for (final node in scene.nodes) {
    if (node.nodeId != null) count += 1;
  }
  return count;
}

void main() {
  group('the reference factorial program', () {
    final scene = _sceneOf(_factorial);

    test('draws no edge at all', () {
      expect(scene.edges, isEmpty);
    });

    test('draws no start or end terminal', () {
      expect(_saying(scene, 'Inicio'), isNull);
      expect(_saying(scene, 'Fin'), isNull);
    });

    test('prints every statement with the lexemes of its profile', () {
      expect(_saying(scene, 'n <- 5'), isNotNull);
      expect(_saying(scene, 'Definir n Como Entero'), isNotNull);
      expect(_saying(scene, 'Escribir'), isNotNull);
    });

    test('labels no cell with the name of its family', () {
      for (final node in scene.nodes) {
        expect(node.lines.join(' '), isNot('Operación'));
      }
    });

    test('keeps the loop body inside the loop frame', () {
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      final body = _saying(scene, 'f <- f * i');
      expect(body, isNotNull);
      expect(body!.y, greaterThanOrEqualTo(header.y + header.height - 0.001));
      expect(body.x, greaterThan(header.x));
      expect(body.x + body.width, lessThanOrEqualTo(header.x + header.width + 0.001));
    });

    test('shows the loop range inside the header band', () {
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      expect(header.lines.join(' '), contains('Hasta n'));
    });

    test('gives the loop frame an indent strip beside its body', () {
      final strip = _shaped(scene, DiagramShape.cellLoopStrip).single;
      final body = _saying(scene, 'f <- f * i')!;
      expect(strip.x + strip.width, closeTo(body.x, 0.001));
    });
  });

  group('a conditional', () {
    final withElse = _sceneOf(_program('''
    Definir a Como Entero;
    Si a > 0 Entonces
        Escribir "positivo";
    SiNo
        Escribir "no positivo";
    FinSi'''));

    test('draws its condition in a wedge header', () {
      final header = _shaped(withElse, DiagramShape.cellCondition).single;
      expect(header.lines.join(' '), contains('a > 0'));
    });

    test('carries both branch labels', () {
      final labels = _shaped(withElse, DiagramShape.cellLabel);
      expect(labels, hasLength(2));
      expect(labels[0].lines, ['SÍ']);
      expect(labels[1].lines, ['NO']);
    });

    test('puts the affirmative branch on the left', () {
      final labels = _shaped(withElse, DiagramShape.cellLabel);
      expect(labels[0].x, lessThan(labels[1].x));
      expect(_saying(withElse, '"positivo"')!.x,
          lessThan(_saying(withElse, '"no positivo"')!.x));
    });

    test('draws an explicit empty cell when there is no negative branch', () {
      final withoutElse = _sceneOf(_program('''
      Definir a Como Entero;
      Si a > 0 Entonces
          Escribir "positivo";
      FinSi'''));
      expect(_shaped(withoutElse, DiagramShape.cellLabel), hasLength(2));
      expect(_shaped(withoutElse, DiagramShape.cellEmpty), hasLength(1));
      expect(_shaped(withoutElse, DiagramShape.cellEmpty).single.lines,
          ['Sin sentencias']);
    });
  });

  group('a multiple selection', () {
    final scene = _sceneOf(_program('''
    Definir opcion Como Entero;
    Segun opcion Hacer
        1:
            Escribir "uno";
        2:
            Escribir "dos";
        De Otro Modo:
            Escribir "otro";
    FinSegun'''));

    test('draws one column per case plus the default one', () {
      expect(_shaped(scene, DiagramShape.cellCase), hasLength(1));
      expect(_shaped(scene, DiagramShape.cellLabel), hasLength(3));
    });

    test('keeps the cases in source order and the default one last', () {
      final labels = _shaped(scene, DiagramShape.cellLabel);
      expect(labels[0].lines, ['1']);
      expect(labels[1].lines, ['2']);
      expect(labels[2].lines.join(' '), contains('Otro'));
    });

    test('draws a selection with no case at all as a single default column', () {
      final empty = _sceneOf(_program('''
      Definir opcion Como Entero;
      Segun opcion Hacer
      FinSegun'''));
      expect(_shaped(empty, DiagramShape.cellCase), hasLength(1));
      expect(_shaped(empty, DiagramShape.cellLabel), hasLength(1));
      expect(_shaped(empty, DiagramShape.cellEmpty), hasLength(1));
    });
  });

  group('the three loops', () {
    test('a test-first while puts its header band above its body', () {
      final scene = _sceneOf(_program('''
      Definir k Como Entero;
      Mientras k < 10 Hacer
          k <- k + 1;
      FinMientras'''));
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      expect(header.lines.join(' '), contains('k < 10'));
      expect(header.y, lessThan(_saying(scene, 'k <- k + 1')!.y));
    });

    test('a counted loop puts its range above its body', () {
      final scene = _sceneOf(_program('''
      Definir i Como Entero;
      Para i <- 1 Hasta 3 Hacer
          Escribir i;
      FinPara'''));
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      expect(header.y, lessThan(_saying(scene, 'Escribir i')!.y));
    });

    test('a test-last loop puts its condition below its body', () {
      final scene = _sceneOf(_program('''
      Definir k Como Entero;
      Repetir
          k <- k - 1;
      Hasta Que k = 0'''));
      final header = _shaped(scene, DiagramShape.cellLoopHeader).single;
      expect(header.lines.join(' '), contains('k = 0'));
      expect(header.y, greaterThan(_saying(scene, 'k <- k - 1')!.y));
    });
  });

  group('a return inside a loop inside a conditional', () {
    final scene = _sceneOf('''
Proceso P
    Definir z Como Entero;
FinProceso
SubProceso Buscar(objetivo Como Entero) Como Entero
    Definir i Como Entero;
    Si objetivo > 0 Entonces
        Para i <- 1 Hasta 10 Hacer
            Si i = objetivo Entonces
                Retornar i;
            FinSi
        FinPara
    FinSi
    Retornar 0;
FinSubProceso
''', unitId: 'sub_Buscar');

    test('draws it as a cell of its own, marked as an exit', () {
      final exits = _shaped(scene, DiagramShape.cellExit);
      expect(exits, hasLength(2));
      expect(exits.first.lines.join(' '), contains('Retornar'));
    });

    test('keeps the exit cell nested inside the loop frame that contains it', () {
      final loopHeader = _shaped(scene, DiagramShape.cellLoopHeader).single;
      final inner = _saying(scene, 'Retornar i')!;
      expect(inner.x, greaterThan(loopHeader.x));
      expect(inner.y, greaterThan(loopHeader.y));
    });
  });

  group('deep nesting mixing the three families', () {
    final scene = _sceneOf(_program('''
    Definir i Como Entero;
    Definir j Como Entero;
    Si i > 0 Entonces
        Mientras j < 10 Hacer
            Segun j Hacer
                1:
                    Para i <- 1 Hasta 3 Hacer
                        Escribir i;
                    FinPara
                De Otro Modo:
                    j <- j + 1;
            FinSegun
        FinMientras
    SiNo
        Escribir "nada";
    FinSi'''));

    test('loses nothing: every statement of the program has its own cell', () {
      expect(_identifiedNodes(scene), 9);
    });

    test('never lets a nested cell escape the frame that contains it', () {
      final outer = _shaped(scene, DiagramShape.cellCondition).first;
      for (final node in scene.nodes) {
        expect(node.x, greaterThanOrEqualTo(outer.x - 0.001));
      }
    });

    test('keeps the inner counted loop inside the outer while frame', () {
      final loops = _shaped(scene, DiagramShape.cellLoopHeader);
      expect(loops, hasLength(2));
      expect(_encloses(loops.first, loops.last), isFalse);
      expect(loops.last.x, greaterThan(loops.first.x));
    });
  });

  group('edge cases', () {
    test('a program with no statements draws a single empty cell', () {
      final scene = _sceneOf('Proceso P\nFinProceso\n');
      expect(_shaped(scene, DiagramShape.cellEmpty), hasLength(1));
    });

    test('a program that only declares still draws its declarations', () {
      final scene = _sceneOf(_program('    Definir n Como Entero;'));
      expect(_shaped(scene, DiagramShape.cellProcess), hasLength(1));
      expect(_saying(scene, 'Definir n'), isNotNull);
    });

    test('a program with a syntax error gives an empty scene, not an exception', () {
      final scene = _sceneOf('Proceso\n  esto no analiza <- ;\n');
      expect(scene.nodes, isEmpty);
      expect(scene.width, 0.0);
    });

    test('a subroutine gets a unit of its own', () {
      final program = _layout.buildDiagram(
        sourceCode: '''
Proceso P
    Saludar();
FinProceso
SubProceso Saludar()
    Escribir "hola";
FinSubProceso
''',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final scene = program.sceneFor('sub_Saludar');
      expect(_saying(scene, '"hola"'), isNotNull);
      expect(_shaped(scene, DiagramShape.cellCall), isEmpty);
    });

    test('a method of a class gets a unit of its own', () {
      final program = _layout.buildDiagram(
        sourceCode: '''
Clase Contador
    Publico Metodo Sumar()
        Escribir "sumo";
    FinMetodo
FinClase
Proceso P
    Definir c Como Entero;
FinProceso
''',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final scene = program.sceneFor('method_Contador_Sumar');
      expect(_saying(scene, '"sumo"'), isNotNull);
    });

    test('a call to a subprogram gets the call cell', () {
      final scene = _sceneOf('''
Proceso P
    Saludar();
FinProceso
SubProceso Saludar()
    Escribir "hola";
FinSubProceso
''');
      expect(_shaped(scene, DiagramShape.cellCall), hasLength(1));
    });
  });

  group('the two interface languages', () {
    test('change the labels of a conditional and leave no cell text empty', () {
      const source = '''
Proceso P
    Definir a Como Entero;
    Si a > 0 Entonces
        Escribir "si";
    FinSi
FinProceso
''';
      final spanish = _sceneOf(source);
      final english = _sceneOf(source, language: UiLanguageId.english);
      expect(_shaped(spanish, DiagramShape.cellLabel)[0].lines, ['SÍ']);
      expect(_shaped(english, DiagramShape.cellLabel)[0].lines, ['YES']);
      expect(_shaped(spanish, DiagramShape.cellEmpty).single.lines, ['Sin sentencias']);
      expect(_shaped(english, DiagramShape.cellEmpty).single.lines, ['No statements']);
      for (final node in english.nodes) {
        if (node.shape == DiagramShape.cellLoopStrip) continue;
        expect(node.lines.join(), isNotEmpty);
      }
    });

    test('never translate the code inside a cell', () {
      final english = _sceneOf(_factorial, language: UiLanguageId.english);
      expect(_saying(english, 'Definir n Como Entero'), isNotNull);
    });
  });
}
