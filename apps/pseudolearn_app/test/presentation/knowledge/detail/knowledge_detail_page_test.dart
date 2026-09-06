import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_detail_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/document_heading.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/presentation/components/empty/app_empty_state.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/document_detail_view.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/document_headings_nav.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/knowledge_detail_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
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
      home: child,
    );
  }

  group('KnowledgeDetailPage & KnowledgeDetailView Tests (CON-F13)', () {
    testWidgets('Renders document detail view with heading chips and content blocks', (tester) async {
      const documentEntry = KnowledgeEntry(
        id: 'contact-support',
        type: KnowledgeEntryType.contact,
        title: 'Introducción al Pseudocódigo',
        summary: 'Conceptos fundamentales.',
      );

      const documentContent = DocumentDetailContent(
        blocks: [
          HeadingBlock(level: 1, text: 'Capítulo 1'),
          ParagraphBlock(text: 'Los algoritmos son secuencias de pasos.'),
          ListBlock(items: ['Paso 1', 'Paso 2'], isOrdered: true),
          QuoteBlock(text: 'El pseudocódigo es lenguaje humano estructurado.'),
        ],
        headings: [
          DocumentHeading(level: 1, text: 'Capítulo 1', blockIndex: 0),
        ],
      );

      const state = EntryDetailState(
        status: KnowledgeDetailStatus.success,
        entry: documentEntry,
        content: documentContent,
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: KnowledgeDetailView(
            state: state,
            onBack: () {},
            onRetry: () {},
            onScrollChanged: (_) {},
            onOpenSpecification: (_, {anchor}) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Introducción al Pseudocódigo'), findsOneWidget);
      expect(find.byType(DocumentDetailView), findsOneWidget);
      expect(find.byType(DocumentHeadingsNav), findsOneWidget);
      expect(find.text('Capítulo 1'), findsNWidgets(2));
      expect(find.text('Los algoritmos son secuencias de pasos.'), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('Paso 1'), findsOneWidget);
      expect(find.text('El pseudocódigo es lenguaje humano estructurado.'), findsOneWidget);
    });

    testWidgets('Renders notFound state with descriptive empty view', (tester) async {
      const state = EntryDetailState(
        status: KnowledgeDetailStatus.notFound,
      );

      var backCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: KnowledgeDetailView(
            state: state,
            onBack: () => backCalled = true,
            onRetry: () {},
            onScrollChanged: (_) {},
            onOpenSpecification: (_, {anchor}) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Elemento no encontrado'), findsOneWidget);
      expect(find.text('Volver a la base de conocimiento'), findsOneWidget);

      await tester.tap(find.text('Volver a la base de conocimiento'));
      await tester.pump();
      expect(backCalled, isTrue);
    });

    testWidgets('Renders error state with retry button', (tester) async {
      const state = EntryDetailState(
        status: KnowledgeDetailStatus.error,
        errorMessage: 'Error de conexión',
      );

      var retryCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: KnowledgeDetailView(
            state: state,
            onBack: () {},
            onRetry: () => retryCalled = true,
            onScrollChanged: (_) {},
            onOpenSpecification: (_, {anchor}) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Error de contenido'), findsOneWidget);
      expect(find.text('Error de conexión'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(retryCalled, isTrue);
    });
  });
}
