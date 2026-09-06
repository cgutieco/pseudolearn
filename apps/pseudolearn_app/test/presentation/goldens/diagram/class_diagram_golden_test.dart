import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const String _hierarchy = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Privado Definir velocidad Como Entero

    Metodo Constructor(m Como Cadena)
        Este.marca <- m
    FinMetodo

    Publico Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero

    Publico Metodo Describir()
        Escribir Este.cilindrada
    FinMetodo
FinClase

Clase Coche Hereda De Vehiculo
    Publico Definir puertas Como Entero
FinClase

Proceso Principal
    Definir moto Como Motocicleta
    Escribir 1
FinProceso
''';

const String _crowded = '''
Clase Motor
    Publico Definir potencia Como Entero
FinClase

Clase Inventario
    Publico Definir codigo Como Cadena
    Publico Definir existencias Como Entero
    Privado Definir margen Como Real
    Publico Definir principal Como Motor

    Publico Metodo Reponer(cantidad Como Entero)
        Este.existencias <- Este.existencias + cantidad
    FinMetodo

    Publico Metodo Valor() Como Real
        Retornar Este.margen
    FinMetodo

    Privado Metodo Auditar() Como Logico
        Retornar Verdadero
    FinMetodo
FinClase

Proceso Principal
    Definir n Como Entero
    Escribir 1
FinProceso
''';

const String _empty = '''
Clase Vacia
FinClase

Proceso Principal
    Definir n Como Entero
    Escribir 1
FinProceso
''';

const String _noClasses = '''
Proceso Principal
    Definir n Como Entero
    Escribir n
FinProceso
''';

DiagramScene _classSceneOf(String source) =>
    CoreClassDiagramBuilder().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
    );

DiagramProgram _flowchartOf(String source) => FlowchartLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramProgram _structogramOf(String source) =>
    StructogramLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramState _stateOf(String source, {ProgramNodeId? member}) => DiagramState(
      flowchart: _flowchartOf(source),
      structogram: _structogramOf(source),
      classDiagram: _classSceneOf(source),
      notation: DiagramNotation.classDiagram,
      focusedMemberNodeId: member,
      hasValidAst: true,
    );

ProgramNodeId _rowIdSaying(String source, String text) {
  for (final node in _classSceneOf(source).nodes) {
    if (node.shape != DiagramShape.classRow) continue;
    if (node.lines.first.contains(text) && node.nodeId != null) {
      return node.nodeId!;
    }
  }
  throw StateError('no row says $text');
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required DiagramState state,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: DesignCanvas(child: FlowchartTabView(state: state))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('class diagram goldens', () {
    testWidgets('hierarchy of three · compact · light', (tester) async {
      await _pump(
        tester,
        size: const Size(420, 900),
        theme: AppTheme.light(),
        state: _stateOf(_hierarchy),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_hierarchy_compact_light.png'));
    });

    testWidgets('hierarchy of three · medium · dark', (tester) async {
      await _pump(
        tester,
        size: const Size(760, 900),
        theme: AppTheme.dark(),
        state: _stateOf(_hierarchy),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_hierarchy_medium_dark.png'));
    });

    testWidgets('hierarchy of three · expanded · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_hierarchy),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_hierarchy_expanded_light.png'));
    });

    testWidgets('hierarchy of three · expanded · dark', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.dark(),
        state: _stateOf(_hierarchy),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_hierarchy_expanded_dark.png'));
    });

    testWidgets('a class with many members and an association · light',
        (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_crowded),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_crowded_light.png'));
    });

    testWidgets('an empty class · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_empty),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_empty_class_light.png'));
    });

    testWidgets('a method in execution · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(
          _hierarchy,
          member: _rowIdSaying(_hierarchy, 'Acelerar'),
        ),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_active_light.png'));
    });

    testWidgets('a document without classes · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_noClasses),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('class_diagram_no_classes_light.png'));
    });
  });
}
