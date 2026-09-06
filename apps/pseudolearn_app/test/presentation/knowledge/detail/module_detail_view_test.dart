import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/document_heading.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/document_headings_nav.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/module_detail_view.dart';
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
      home: Scaffold(body: child),
    );
  }

  group('ModuleDetailView Tests (CON-F13)', () {
    const specEntry = KnowledgeEntry(
      id: 'esp-i-tipos',
      type: KnowledgeEntryType.specificationSection,
      title: 'Tipos primitivos',
      summary: 'Los cinco tipos.',
      anchor: 'tipos',
    );

    const exerciseEntry = KnowledgeEntry(
      id: 'CON-B1-E1',
      type: KnowledgeEntryType.exercise,
      title: 'Suma de dos números',
      summary: 'Lee dos enteros y escribe su suma.',
    );

    const fullModule = LearningModule(
      id: 'CON-B1',
      track: LearningTrack.imperative,
      order: 1,
      title: 'Datos: tipos, variables y expresiones',
      sections: [
        ModuleSection(
          part: ModulePart.question,
          blocks: [ParagraphBlock(text: '¿Por qué existen los datos?')],
        ),
        ModuleSection(
          part: ModulePart.machineModel,
          blocks: [ParagraphBlock(text: 'La memoria es una fila de casillas.')],
        ),
        ModuleSection(
          part: ModulePart.development,
          blocks: [
            HeadingBlock(level: 2, text: 'Cinco clases de valores'),
            ParagraphBlock(text: 'Todo valor pertenece a un tipo.'),
          ],
        ),
        ModuleSection(
          part: ModulePart.prediction,
          blocks: [ParagraphBlock(text: 'Predice los valores finales.')],
        ),
        ModuleSection(
          part: ModulePart.commonErrors,
          blocks: [ParagraphBlock(text: 'Dar un valor inicial en la declaración.')],
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
      anchorIds: ['esp-i-tipos'],
      exerciseIds: ['CON-B1-E1'],
    );

    testWidgets('Renders all 7 module parts and handles specification and exercise taps', (tester) async {
      String? openedSpecId;
      String? openedAnchor;
      String? openedExerciseId;

      const content = ModuleDetailContent(
        module: fullModule,
        headings: [
          DocumentHeading(level: 2, text: 'Cinco clases de valores', blockIndex: 0),
        ],
        specificationEntries: [specEntry],
        exerciseEntries: [exerciseEntry],
      );

      await tester.pumpWidget(
        buildTestWidget(
          ModuleDetailView(
            content: content,
            onOpenSpecification: (id, {anchor}) {
              openedSpecId = id;
              openedAnchor = anchor;
            },
            onOpenExercise: (id) => openedExerciseId = id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DocumentHeadingsNav), findsOneWidget);
      expect(find.text('Pregunta'), findsOneWidget);
      expect(find.text('¿Por qué existen los datos?'), findsOneWidget);
      expect(find.text('Qué cambia en tu modelo de la máquina'), findsOneWidget);
      expect(find.text('La memoria es una fila de casillas.'), findsOneWidget);
      expect(find.text('Desarrollo'), findsOneWidget);
      expect(find.text('Cinco clases de valores'), findsNWidgets(2));
      expect(find.text('Predice y ejecuta'), findsOneWidget);
      expect(find.text('Errores frecuentes'), findsOneWidget);
      expect(find.text('En la especificación'), findsOneWidget);
      expect(find.text('Tipos primitivos'), findsOneWidget);
      expect(find.text('Ejercicios'), findsOneWidget);
      expect(find.text('Suma de dos números'), findsOneWidget);

      await tester.ensureVisible(find.text('Tipos primitivos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tipos primitivos'));
      await tester.pump();
      expect(openedSpecId, equals('esp-i-tipos'));
      expect(openedAnchor, equals('tipos'));

      await tester.ensureVisible(find.text('Suma de dos números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suma de dos números'));
      await tester.pump();
      expect(openedExerciseId, equals('CON-B1-E1'));
    });

    testWidgets('Handles edge case of module with empty part gracefully', (tester) async {
      const moduleWithEmptyPart = LearningModule(
        id: 'CON-B1',
        track: LearningTrack.imperative,
        order: 1,
        title: 'Módulo mínimo',
        sections: [
          ModuleSection(part: ModulePart.question, blocks: []),
          ModuleSection(part: ModulePart.development, blocks: [ParagraphBlock(text: 'Solo texto')]),
        ],
      );

      const content = ModuleDetailContent(
        module: moduleWithEmptyPart,
        headings: [],
      );

      await tester.pumpWidget(
        buildTestWidget(
          ModuleDetailView(
            content: content,
            onOpenSpecification: (_, {anchor}) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pregunta'), findsOneWidget);
      expect(find.text('Desarrollo'), findsOneWidget);
      expect(find.text('Solo texto'), findsOneWidget);
    });

    testWidgets('Suppresses raw metadata ListBlocks in specification, exercises, and prediction', (tester) async {
      const moduleWithRawMetadataLists = LearningModule(
        id: 'CON-B1',
        track: LearningTrack.imperative,
        order: 1,
        title: 'Datos: tipos, variables y expresiones',
        sections: [
          ModuleSection(
            part: ModulePart.prediction,
            blocks: [
              ParagraphBlock(text: 'Instrucción de predicción.'),
              ListBlock(items: ['example-b1#5#a Token crudo de predicción']),
            ],
          ),
          ModuleSection(
            part: ModulePart.specificationAnchors,
            blocks: [
              ListBlock(items: ['esp-i-lexico Token crudo de especificacion']),
            ],
          ),
          ModuleSection(
            part: ModulePart.exercises,
            blocks: [
              ListBlock(items: ['CON-B1-E1 Token crudo de ejercicio']),
            ],
          ),
        ],
        anchorIds: ['esp-i-tipos'],
        exerciseIds: ['CON-B1-E1'],
      );

      const content = ModuleDetailContent(
        module: moduleWithRawMetadataLists,
        headings: [],
        specificationEntries: [specEntry],
        exerciseEntries: [exerciseEntry],
      );

      await tester.pumpWidget(
        buildTestWidget(
          ModuleDetailView(
            content: content,
            onOpenSpecification: (_, {anchor}) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Instrucción de predicción.'), findsOneWidget);
      expect(find.text('example-b1#5#a Token crudo de predicción'), findsNothing);
      expect(find.text('esp-i-lexico Token crudo de especificacion'), findsNothing);
      expect(find.text('CON-B1-E1 Token crudo de ejercicio'), findsNothing);

      expect(find.text('Tipos primitivos'), findsOneWidget);
      expect(find.text('Suma de dos números'), findsOneWidget);
    });
  });
}
