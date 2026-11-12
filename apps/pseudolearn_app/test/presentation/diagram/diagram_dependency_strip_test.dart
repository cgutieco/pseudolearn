import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_dependency.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/diagram/diagram_dependency_strip.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../../fakes/native_test_engine.dart';

const SourceRange _range = SourceRange(
  startOffset: 0,
  endOffset: 26,
  startLine: 1,
  startColumn: 1,
  endLine: 1,
  endColumn: 27,
);

final List<ProgramDependency> _dependencies = [
  ProgramDependency(
    id: 'rev1.d0',
    kind: ProgramDependencyKind.importation,
    path: const ['geo', 'Punto'],
    alias: 'P',
    status: ProgramDependencyStatus.unlinked,
    diagnosticCode: 'moduleSyntaxOutsideProject',
    range: _range,
  ),
  ProgramDependency(
    id: 'rev1.d1',
    kind: ProgramDependencyKind.exportation,
    path: const ['geo', 'formas'],
    alias: null,
    status: ProgramDependencyStatus.unlinked,
    diagnosticCode: 'moduleSyntaxOutsideProject',
    range: _range,
  ),
];

Widget _app(Locale locale, Widget child) => MaterialApp(
  locale: locale,
  theme: AppTheme.light(),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: DesignCanvas(child: child)),
);

void main() {
  testWidgets('lists each dependency as unlinked in Spanish', (tester) async {
    await tester.pumpWidget(
      _app(
        const Locale('es'),
        DiagramDependencyStrip(dependencies: _dependencies),
      ),
    );

    expect(find.text('Importa geo.Punto como P'), findsOneWidget);
    expect(find.text('Exporta geo.formas'), findsOneWidget);
    expect(find.textContaining('Sin enlazar'), findsNWidgets(2));
  });

  testWidgets('lists each dependency as unlinked in English', (tester) async {
    await tester.pumpWidget(
      _app(
        const Locale('en'),
        DiagramDependencyStrip(dependencies: _dependencies),
      ),
    );

    expect(find.text('Imports geo.Punto as P'), findsOneWidget);
    expect(find.text('Exports geo.formas'), findsOneWidget);
    expect(find.textContaining('Unlinked'), findsNWidgets(2));
  });

  testWidgets('tapping a row navigates to its exact range', (tester) async {
    SourceRange? selected;
    await tester.pumpWidget(
      _app(
        const Locale('es'),
        DiagramDependencyStrip(
          dependencies: _dependencies,
          onSourceSelected: (range) => selected = range,
        ),
      ),
    );

    await tester.tap(find.text('Importa geo.Punto como P'));

    expect(selected, same(_range));
  });

  testWidgets('each row is a labelled button in the semantics tree', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const Locale('es'),
        DiagramDependencyStrip(
          dependencies: _dependencies,
          onSourceSelected: (_) {},
        ),
      ),
    );

    final row = find.bySemanticsLabel(RegExp('Importa geo.Punto como P'));
    expect(row, findsOneWidget);
    expect(
      tester.getSemantics(row),
      matchesSemantics(
        label: 'Importa geo.Punto como P. Sin enlazar: este documento se '
            'analiza solo, así que no se ejecuta mientras tenga '
            'dependencias pendientes.',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('rows are not tappable without a navigation handler', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Locale('es'),
        DiagramDependencyStrip(dependencies: _dependencies),
      ),
    );

    await tester.tap(find.text('Importa geo.Punto como P'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the canvas shows the strip beside the drawn units', (
    tester,
  ) async {
    const source = 'Importar geo.Punto Como P;\nAlgoritmo Main\nEscribir 1;\nFinAlgoritmo\n';
    final flowchart = nativeTestEngine.flowchartBuilder.buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    SourceRange? selected;
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        const Locale('es'),
        FlowchartTabView(
          state: DiagramState(
            flowchart: flowchart,
            structogram: flowchart,
            classDiagram: const DiagramScene.empty(),
            hasValidAst: true,
          ),
          onSourceSelected: (range) => selected = range,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Importa geo.Punto como P'), findsOneWidget);
    await tester.tap(find.text('Importa geo.Punto como P'));
    expect(selected?.startOffset, 0);
    expect(selected?.endOffset, 26);
  });

  testWidgets('a program without dependencies shows no strip', (tester) async {
    const source = 'Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n';
    final flowchart = nativeTestEngine.flowchartBuilder.buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        const Locale('es'),
        FlowchartTabView(
          state: DiagramState(
            flowchart: flowchart,
            structogram: flowchart,
            classDiagram: const DiagramScene.empty(),
            hasValidAst: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DiagramDependencyStrip), findsNothing);
  });
}
