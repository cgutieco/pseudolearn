import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/code_block_views.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const String _source = '''
Proceso Saludo
    Escribir "Hola";
FinProceso
''';

Future<void> _pump(WidgetTester tester, DiagramBlock block, {Size size = const Size(800, 600)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(body: SingleChildScrollView(child: DiagramBlockView(block: block))),
  ));
  await tester.pumpAndSettle();
}

Future<void> _pumpCode(WidgetTester tester, CodeBlock block, {Size size = const Size(800, 600)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(body: SingleChildScrollView(child: CodeBlockView(block: block))),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('CodeBlockView', () {
    testWidgets('Renders header when title is present', (tester) async {
      const block = CodeBlock(
        code: _source,
        title: 'Saludo simple',
      );

      await _pumpCode(tester, block);

      expect(find.text('Saludo simple'), findsOneWidget);
      expect(find.byIcon(Icons.code_rounded), findsOneWidget);
      expect(find.byType(CodeField), findsOneWidget);
    });

    testWidgets('Renders without header when title is null', (tester) async {
      const block = CodeBlock(code: _source);

      await _pumpCode(tester, block);

      expect(find.text('Saludo simple'), findsNothing);
      expect(find.byIcon(Icons.code_rounded), findsNothing);
      expect(find.byType(CodeField), findsOneWidget);
    });
  });

  group('DiagramBlockView', () {
    testWidgets('Paints the resolved scene instead of raw code', (tester) async {
      final scene = FlowchartLayout()
          .buildDiagram(
            sourceCode: _source,
            profileId: SyntaxProfileId.classicSpanish,
            languageId: UiLanguageId.spanish,
          )
          .sceneFor(null);
      final block = DiagramBlock(code: _source, notation: DiagramNotation.flowchart, scene: scene);

      await _pump(tester, block);

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(CodeField), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders header when title is present on diagram with scene', (tester) async {
      final scene = FlowchartLayout()
          .buildDiagram(
            sourceCode: _source,
            profileId: SyntaxProfileId.classicSpanish,
            languageId: UiLanguageId.spanish,
          )
          .sceneFor(null);
      final block = DiagramBlock(
        code: _source,
        notation: DiagramNotation.flowchart,
        scene: scene,
        title: 'Diagrama de Saludo',
      );

      await _pump(tester, block);

      expect(find.text('Diagrama de Saludo'), findsOneWidget);
      expect(find.byIcon(Icons.code_rounded), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Falls back to raw code when the scene could not be resolved', (tester) async {
      const block = DiagramBlock(code: _source, notation: DiagramNotation.flowchart);

      await _pump(tester, block);

      expect(find.byType(CodeField), findsOneWidget);
    });

    testWidgets('Fits without overflow on the narrowest canvas', (tester) async {
      final scene = FlowchartLayout()
          .buildDiagram(
            sourceCode: _source,
            profileId: SyntaxProfileId.classicSpanish,
            languageId: UiLanguageId.spanish,
          )
          .sceneFor(null);
      final block = DiagramBlock(code: _source, notation: DiagramNotation.flowchart, scene: scene);

      await _pump(tester, block, size: const Size(360, 640));

      expect(tester.takeException(), isNull);
    });
  });
}
