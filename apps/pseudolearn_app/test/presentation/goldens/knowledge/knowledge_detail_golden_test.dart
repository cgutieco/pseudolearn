import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_detail_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/document_heading.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/knowledge_detail_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pumpKnowledgeDetailView(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required EntryDetailState state,
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
      builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: KnowledgeDetailView(
        state: state,
        onBack: () {},
        onRetry: () {},
        onScrollChanged: (_) {},
        onOpenSpecification: (_, {anchor}) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('KnowledgeDetailPage Goldens (CON-F13) — three widths, two themes', () {
    const moduleEntry = KnowledgeEntry(
      id: 'CON-B1',
      type: KnowledgeEntryType.module,
      title: 'Datos: tipos, variables, expresiones y asignación',
      summary: 'Qué clases de valores hay, cómo se les pone nombre y qué ocurre al asignarles otro.',
      track: LearningTrack.imperative,
    );

    const moduleContent = ModuleDetailContent(
      module: LearningModule(
        id: 'CON-B1',
        track: LearningTrack.imperative,
        order: 1,
        title: 'Datos: tipos, variables, expresiones y asignación',
        sections: [
          ModuleSection(
            part: ModulePart.question,
            blocks: [
              ParagraphBlock(
                text: 'Un algoritmo que solo hace cuentas con números escritos a mano no sirve para todos los casos. Para que sirva hace falta guardar valores con un nombre.',
              ),
            ],
          ),
          ModuleSection(
            part: ModulePart.machineModel,
            blocks: [
              ParagraphBlock(
                text: 'La memoria del programa es una fila de casillas. Cada casilla tiene un nombre, admite valores de una sola clase y guarda un valor cada vez.',
              ),
              FigureBlock(
                illustrationId: 'cajas-memoria',
                caption: 'Una fila de casillas, cada una con su nombre y su valor.',
              ),
            ],
          ),
          ModuleSection(
            part: ModulePart.development,
            blocks: [
              HeadingBlock(level: 2, text: 'Cinco clases de valores'),
              ParagraphBlock(
                text: 'Todo valor pertenece a uno de cinco tipos primitivos:',
              ),
              TableBlock(
                headers: ['Tipo', 'Valores'],
                rows: [
                  ['Entero', '-2, -1, 0, 1, 2...'],
                  ['Real', '3.1416, 0.5...'],
                  ['Lógico', 'Verdadero, Falso'],
                ],
              ),
              CodeBlock(
                code: 'definir a, b como entero;\na <- 5;\nb <- a * 2;',
                highlightSpans: [
                  HighlightSpan(
                    range: SourceRange(startOffset: 0, endOffset: 7, startLine: 1, startColumn: 1, endLine: 1, endColumn: 8),
                    category: HighlightCategory.keywordStructured,
                  ),
                  HighlightSpan(
                    range: SourceRange(startOffset: 16, endOffset: 20, startLine: 1, startColumn: 17, endLine: 1, endColumn: 21),
                    category: HighlightCategory.keywordStructured,
                  ),
                  HighlightSpan(
                    range: SourceRange(startOffset: 21, endOffset: 27, startLine: 1, startColumn: 22, endLine: 1, endColumn: 28),
                    category: HighlightCategory.keywordStructured,
                  ),
                ],
              ),
            ],
          ),
          ModuleSection(
            part: ModulePart.prediction,
            blocks: [
              ParagraphBlock(
                text: 'Antes de ejecutar nada, escribe qué valores tienen a y b.',
              ),
            ],
          ),
          ModuleSection(
            part: ModulePart.commonErrors,
            blocks: [
              HeadingBlock(level: 2, text: 'Dar valor en la declaración'),
              ParagraphBlock(
                text: 'El tipo se escribe al final, por lo que el valor inicial no cabe ahí.',
              ),
            ],
          ),
          ModuleSection(
            part: ModulePart.specificationAnchors,
            blocks: [],
          ),
          ModuleSection(
            part: ModulePart.exercises,
            blocks: [],
          ),
        ],
        anchorIds: ['esp-i-tipos-primitivos'],
        exerciseIds: ['CON-B1-E1'],
      ),
      headings: [
        DocumentHeading(level: 2, text: 'Cinco clases de valores', blockIndex: 2),
        DocumentHeading(level: 2, text: 'Dar valor en la declaración', blockIndex: 4),
      ],
      specificationEntries: [
        KnowledgeEntry(
          id: 'esp-i-tipos-primitivos',
          type: KnowledgeEntryType.specificationSection,
          title: 'Tipos primitivos',
          summary: 'Los cinco tipos, sus valores y su rango.',
          anchor: 'tipos-primitivos',
        ),
      ],
      exerciseEntries: [
        KnowledgeEntry(
          id: 'CON-B1-E1',
          type: KnowledgeEntryType.exercise,
          title: 'Suma de dos números',
          summary: 'Lee dos enteros y escribe su suma.',
        ),
      ],
    );

    const moduleState = EntryDetailState(
      status: KnowledgeDetailStatus.success,
      entry: moduleEntry,
      content: moduleContent,
    );

    const specState = EntryDetailState(
      status: KnowledgeDetailStatus.success,
      entry: KnowledgeEntry(
        id: 'esp-i-tipos-primitivos',
        type: KnowledgeEntryType.specificationSection,
        title: 'Tipos primitivos',
        summary: 'Los cinco tipos, sus valores y su rango.',
        anchor: 'tipos-primitivos',
      ),
      content: SpecificationDetailContent(
        entry: KnowledgeEntry(
          id: 'esp-i-tipos-primitivos',
          type: KnowledgeEntryType.specificationSection,
          title: 'Tipos primitivos',
          summary: 'Los cinco tipos, sus valores y su rango.',
          anchor: 'tipos-primitivos',
        ),
        blocks: [
          HeadingBlock(level: 1, text: 'Tipos primitivos'),
          ParagraphBlock(
            text: 'El lenguaje tiene cinco tipos primitivos. Todo valor pertenece a uno y solo a uno de ellos.',
          ),
          TableBlock(
            headers: ['Tipo', 'Descripción'],
            rows: [
              ['Entero', '64 bits con signo'],
              ['Real', 'Coma flotante 64 bits'],
              ['Lógico', 'Verdadero o falso'],
            ],
          ),
        ],
        headings: [
          DocumentHeading(level: 1, text: 'Tipos primitivos', blockIndex: 0),
        ],
        selectedAnchor: 'tipos-primitivos',
        fromModuleId: 'CON-B1',
        fromModuleTitle: 'Datos: tipos, variables, expresiones y asignación',
      ),
    );

    final widths = <String, double>{
      'compact': 360,
      'medium': 600,
      'expanded': 960,
    };

    for (final widthEntry in widths.entries) {
      testWidgets('module · ${widthEntry.key} · light', (tester) async {
        await _pumpKnowledgeDetailView(
          tester,
          size: Size(widthEntry.value, 800),
          theme: AppTheme.light(),
          state: moduleState,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('knowledge_detail_module_${widthEntry.key}_light.png'),
        );
      });

      testWidgets('module · ${widthEntry.key} · dark', (tester) async {
        await _pumpKnowledgeDetailView(
          tester,
          size: Size(widthEntry.value, 800),
          theme: AppTheme.dark(),
          state: moduleState,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('knowledge_detail_module_${widthEntry.key}_dark.png'),
        );
      });

      testWidgets('specification · ${widthEntry.key} · light', (tester) async {
        await _pumpKnowledgeDetailView(
          tester,
          size: Size(widthEntry.value, 800),
          theme: AppTheme.light(),
          state: specState,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('knowledge_detail_spec_${widthEntry.key}_light.png'),
        );
      });

      testWidgets('specification · ${widthEntry.key} · dark', (tester) async {
        await _pumpKnowledgeDetailView(
          tester,
          size: Size(widthEntry.value, 800),
          theme: AppTheme.dark(),
          state: specState,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('knowledge_detail_spec_${widthEntry.key}_dark.png'),
        );
      });
    }
  });
}
