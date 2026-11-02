import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_accessible_element.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/presentation/diagram/class_diagram_semantics_layer.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../../fakes/native_test_engine.dart';

const String _spanish = '''
Interfaz Legible
Metodo obtener() Como Entero;
FinInterfaz
Clase Lector Realiza Legible
Metodo obtener(extra Como Entero) Como Entero
Retornar extra;
FinMetodo
FinClase
Algoritmo Principal
FinAlgoritmo
''';

const String _english = '''
interface Readable
method readValue() as integer;
endInterface
class Reader implements Readable
method readValue() as integer
return 7;
endMethod
endClass
algorithm Main
endAlgorithm
''';

const String _inheritedInvalidEnglish = '''
interface Readable
method readValue() as integer;
endInterface
class Reader implements Readable
method readValue() as integer
return 7;
endMethod
endClass
class Child extends Reader
method readValue(extra as integer) as integer
return extra;
endMethod
endClass
algorithm Main
endAlgorithm
''';

DiagramState _state(String source, SyntaxProfileId profile) => DiagramState(
  flowchart: const DiagramProgram.empty(),
  structogram: const DiagramProgram.empty(),
  classDiagram: nativeTestEngine.classDiagramBuilder.buildDiagram(
    sourceCode: source,
    profileId: profile,
  ),
  notation: DiagramNotation.classDiagram,
  hasValidAst: true,
);

Future<List<SourceRange>> _pump(
  WidgetTester tester, {
  required String source,
  required SyntaxProfileId profile,
  required Locale locale,
  Size viewportSize = const Size(1600, 1200),
  double textScale = 1,
}) async {
  final selected = <SourceRange>[];
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: viewportSize,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: DesignCanvas(
            child: FlowchartTabView(
              state: _state(source, profile),
              onSourceSelected: selected.add,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return selected;
}

void main() {
  testWidgets('an invalid realization is announced as invalid, not by color', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      source: _spanish,
      profile: SyntaxProfileId.classicSpanish,
      locale: const Locale('es'),
    );

    expect(
      find.bySemanticsLabel(
        'Realización de Lector a Legible, inválida: interfaceMethodSignatureMismatch',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('«interface» Legible'), findsOneWidget);
    expect(
      find.bySemanticsLabel('+ obtener(extra: Entero): Entero'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets(
    'a valid realization is announced in English without diagnostics',
    (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        source: _english,
        profile: SyntaxProfileId.english,
        locale: const Locale('en'),
      );

      expect(
        find.bySemanticsLabel('Realization from Reader to Readable'),
        findsOneWidget,
      );
      final node = tester.getSemantics(
        find.bySemanticsLabel('Realization from Reader to Readable'),
      );
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      handle.dispose();
    },
  );

  testWidgets(
    'tapping a relation selects its origin range and leaves the text intact',
    (tester) async {
      final selected = await _pump(
        tester,
        source: _spanish,
        profile: SyntaxProfileId.classicSpanish,
        locale: const Locale('es'),
      );

      await tester.tap(
        find.bySemanticsLabel(RegExp('^Realización de Lector a Legible')),
      );

      expect(selected, hasLength(1));
      expect(
        _spanish
            .substring(selected.single.startOffset)
            .startsWith('Clase Lector'),
        isTrue,
      );
      expect(selected.single.startLine, 4);
    },
  );

  testWidgets('an invalid inherited relation selects the overriding signature', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final selected = await _pump(
      tester,
      source: _inheritedInvalidEnglish,
      profile: SyntaxProfileId.english,
      locale: const Locale('en'),
    );
    const label =
        'Realization from Child to Readable, invalid: incompatibleMethodOverride';

    expect(find.bySemanticsLabel(label), findsOneWidget);
    tester.semantics.tap(find.semantics.byLabel(label));
    await tester.pump();

    expect(selected, hasLength(1));
    expect(
      _inheritedInvalidEnglish.substring(
        selected.single.startOffset,
        selected.single.endOffset,
      ),
      'method readValue(extra as integer) as integer',
    );
    handle.dispose();
  });

  testWidgets('tapping a signature row selects exactly that signature', (
    tester,
  ) async {
    final selected = await _pump(
      tester,
      source: _spanish,
      profile: SyntaxProfileId.classicSpanish,
      locale: const Locale('es'),
    );

    await tester.tap(find.bySemanticsLabel('+ obtener(): Entero'));

    expect(
      _spanish.substring(
        selected.single.startOffset,
        selected.single.endOffset,
      ),
      'Metodo obtener() Como Entero;',
    );
  });

  testWidgets('the semantic tap action navigates like a pointer tap', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final selected = await _pump(
      tester,
      source: _english,
      profile: SyntaxProfileId.english,
      locale: const Locale('en'),
    );
    tester.semantics.tap(find.semantics.byLabel('«interface» Readable'));
    await tester.pump();

    expect(
      _english
          .substring(selected.single.startOffset)
          .startsWith('interface Readable'),
      isTrue,
    );
    handle.dispose();
  });

  testWidgets(
    'Tab and activation keys navigate at compact size and large text',
    (tester) async {
      final selected = <SourceRange>[];
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: ClassDiagramSemanticsLayer(
                elements: const [
                  DiagramAccessibleElement(
                    role: DiagramAccessibleRole.box,
                    text: 'Readable',
                    bounds: DiagramAccessibleBounds(
                      left: 0,
                      top: 0,
                      width: 100,
                      height: 28,
                    ),
                    range: SourceRange(
                      startOffset: 2,
                      endOffset: 10,
                      startLine: 1,
                      startColumn: 3,
                      endLine: 1,
                      endColumn: 11,
                    ),
                  ),
                  DiagramAccessibleElement(
                    role: DiagramAccessibleRole.row,
                    text: '+ readValue(): Number',
                    bounds: DiagramAccessibleBounds(
                      left: 0,
                      top: 32,
                      width: 160,
                      height: 24,
                    ),
                    range: SourceRange(
                      startOffset: 11,
                      endOffset: 20,
                      startLine: 2,
                      startColumn: 1,
                      endLine: 2,
                      endColumn: 10,
                    ),
                  ),
                ],
                onSourceSelected: selected.add,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focusRings = tester.widgetList<DecoratedBox>(
        find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
            return false;
          }
          final border = (widget.decoration as BoxDecoration).border;
          return border is Border && border.top.width == 2;
        }),
      );
      expect(focusRings, hasLength(1));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, hasLength(1));
      expect(selected.single.startOffset, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(selected, hasLength(2));
      expect(selected.last.startOffset, 11);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the accessible label preserves a full row when its box is narrow',
    (tester) async {
      final handle = tester.ensureSemantics();
      const fullSignature =
          '+ calculateWithAnExtremelyLongMethodName(parameterWithLongName: Number): Number';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SizedBox(
              width: 60,
              height: 18,
              child: ClassDiagramSemanticsLayer(
                elements: [
                  DiagramAccessibleElement(
                    role: DiagramAccessibleRole.row,
                    text: fullSignature,
                    bounds: DiagramAccessibleBounds(
                      left: 0,
                      top: 0,
                      width: 60,
                      height: 18,
                    ),
                    range: null,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel(fullSignature), findsOneWidget);
      handle.dispose();
    },
  );
}
