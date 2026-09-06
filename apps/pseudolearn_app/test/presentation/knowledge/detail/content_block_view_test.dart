import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/editor/components/severity_chip.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/code_block_views.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/data_block_views.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/diagnostic_block_view.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/text_block_views.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/content_block_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('ContentBlockView Variants & Edge Cases Tests', () {
    testWidgets('Renders all content block variants with literal data', (tester) async {
      const blocks = <ContentBlock>[
        HeadingBlock(level: 1, text: 'Título principal'),
        HeadingBlock(level: 2, text: 'Subtítulo'),
        ParagraphBlock(text: 'Párrafo explicativo.'),
        ListBlock(items: ['Elemento 1', 'Elemento 2'], isOrdered: false),
        ListBlock(items: ['Paso 1', 'Paso 2'], isOrdered: true),
        QuoteBlock(text: 'Cita destacada.'),
        CodeBlock(
          code: 'definir n como entero;',
          highlightSpans: [
            HighlightSpan(
              range: SourceRange(startOffset: 0, endOffset: 7, startLine: 1, startColumn: 1, endLine: 1, endColumn: 8),
              category: HighlightCategory.keywordStructured,
            ),
          ],
        ),
        MarkerBlock(
          marker: ContentMarker(kind: ContentMarkerKind.lexeme, argument: 'declare'),
          resolvedText: 'definir',
        ),
        FigureBlock(illustrationId: 'cajas-memoria', caption: 'Memoria en casillas'),
        TableBlock(
          headers: ['Tipo', 'Descripción'],
          rows: [
            ['Entero', 'Número sin decimales'],
            ['Real', 'Número con coma'],
          ],
        ),
        DiagnosticBlock(
          code: 'expectedAlgorithmStart',
          message: 'Se esperaba el inicio del algoritmo',
          severity: AppSeverity.error,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          Column(
            children: [
              for (final block in blocks) ContentBlockView(block: block),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HeadingBlockView), findsNWidgets(2));
      expect(find.text('Título principal'), findsOneWidget);
      expect(find.text('Subtítulo'), findsOneWidget);
      expect(find.byType(ParagraphBlockView), findsNWidgets(2));
      expect(find.text('Párrafo explicativo.'), findsOneWidget);
      expect(find.text('definir'), findsOneWidget);
      expect(find.byType(ListBlockView), findsNWidgets(2));
      expect(find.text('•'), findsNWidgets(2));
      expect(find.text('1.'), findsOneWidget);
      expect(find.byType(QuoteBlockView), findsOneWidget);
      expect(find.text('Cita destacada.'), findsOneWidget);
      expect(find.byType(CodeBlockView), findsOneWidget);
      expect(find.byType(CodeField), findsOneWidget);
      expect(find.byType(FigureBlockView), findsOneWidget);
      expect(find.text('Memoria en casillas'), findsOneWidget);
      expect(find.byType(TableBlockView), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Entero'), findsOneWidget);
      expect(find.byType(DiagnosticBlockView), findsOneWidget);
      expect(find.text('Se esperaba el inicio del algoritmo'), findsOneWidget);
      expect(find.text('expectedAlgorithmStart'), findsOneWidget);
      expect(find.byType(SeverityChip), findsOneWidget);
    });

    testWidgets('DiagramBlockView falls back gracefully to code when scene is empty', (tester) async {
      const brokenDiagram = DiagramBlock(
        code: 'codigo invalido sin sintaxis',
        notation: DiagramNotation.flowchart,
        scene: DiagramScene.empty(),
      );

      await tester.pumpWidget(
        buildTestWidget(const ContentBlockView(block: brokenDiagram)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DiagramBlockView), findsOneWidget);
      expect(find.byType(CodeBlockView), findsOneWidget);
      expect(find.textContaining('codigo invalido sin sintaxis'), findsOneWidget);
    });

    testWidgets('Handles edge cases: single-row table, one-line code, unknown illustration', (tester) async {
      const singleRowTable = TableBlock(
        headers: ['Columna'],
        rows: [
          ['Fila única'],
        ],
      );
      const oneLineCode = CodeBlock(code: 'x <- 1');
      const unknownFigure = FigureBlock(
        illustrationId: 'desconocida',
        caption: 'Pie de figura suelto',
      );

      await tester.pumpWidget(
        buildTestWidget(
          const Column(
            children: [
              ContentBlockView(block: singleRowTable),
              ContentBlockView(block: oneLineCode),
              ContentBlockView(block: unknownFigure),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fila única'), findsOneWidget);
      expect(find.textContaining('x <- 1'), findsOneWidget);
      expect(find.text('Pie de figura suelto'), findsOneWidget);
    });
  });
}
