import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/document_heading.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/document_headings_nav.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/specification_detail_view.dart';
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
      builder: (context, c) =>
          DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(body: child),
    );
  }

  group('SpecificationDetailView Tests (CON-F13)', () {
    const specEntry = KnowledgeEntry(
      id: 'esp-i-tipos',
      type: KnowledgeEntryType.specificationSection,
      title: 'Tipos primitivos',
      summary: 'Los cinco tipos.',
      anchor: 'tipos',
    );

    testWidgets(
        'Renders specification blocks and backlink button to originating module',
        (tester) async {
      String? returnedModuleId;

      const content = SpecificationDetailContent(
        entry: specEntry,
        blocks: [
          HeadingBlock(level: 1, text: 'Tipos primitivos'),
          ParagraphBlock(text: 'El lenguaje define cinco tipos primitivos.'),
        ],
        headings: [
          DocumentHeading(level: 1, text: 'Tipos primitivos', blockIndex: 0),
        ],
        fromModuleId: 'CON-B1',
        fromModuleTitle: 'Datos',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SpecificationDetailView(
            content: content,
            onReturnToModule: (id) => returnedModuleId = id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DocumentHeadingsNav), findsOneWidget);
      expect(find.text('Tipos primitivos'), findsNWidgets(2));
      expect(find.text('El lenguaje define cinco tipos primitivos.'),
          findsOneWidget);
      expect(find.text('Volver al módulo Datos'), findsOneWidget);

      await tester.tap(find.text('Volver al módulo Datos'));
      await tester.pump();
      expect(returnedModuleId, equals('CON-B1'));
    });
  });
}
