import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/editor/editor_tab_view.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/pump_app.dart';
import '../../fakes/test_dependencies.dart';

const String _source = 'Proceso Conteo\n'
    '\tDefinir i Como Entero;\n'
    '\ti <- 0;\n'
    '\tMientras i < 3 Hacer\n'
    '\t\ti <- i + 1;\n'
    '\tFinMientras\n'
    '\tEscribir i;\n'
    'FinProceso\n';

InMemoryDocumentRepository _repositoryWithDocument() {
  final repo = InMemoryDocumentRepository();
  final now = DateTime(2026, 8, 16, 12, 0);
  repo.documents['doc-1'] = Document(
    id: 'doc-1',
    title: 'Conteo',
    content: _source,
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: now,
    updatedAt: now,
  );
  return repo;
}

Future<void> _openDiagramsTab(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[const Locale('es')];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(
    CubitScope(dependencies: buildTestDependencies(repository: _repositoryWithDocument())),
  );
  await tester.pumpAndSettle();

  final context = tester.element(find.byType(Navigator).first);
  GoRouter.of(context).go('/biblioteca/documento/doc-1');
  await tester.pumpAndSettle();

  await tester.tap(find.text('Diagramas'));
  await tester.pumpAndSettle();
}

double _diagramScale(WidgetTester tester) {
  final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
  return viewer.transformationController!.value.getMaxScaleOnAxis();
}

void main() {
  testWidgets('the editor tab offers no companion because it is the companion', (tester) async {
    await _openDiagramsTab(tester, const Size(390, 844));

    expect(find.byIcon(Icons.crop_square), findsOneWidget);

    await tester.tap(find.text('Editor'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.crop_square), findsNothing);
  });

  testWidgets('a compact width stacks the diagram under the editor', (tester) async {
    await _openDiagramsTab(tester, const Size(390, 844));

    expect(find.byType(CodeField), findsNothing);

    await tester.tap(find.byIcon(Icons.crop_square));
    await tester.pumpAndSettle();

    final editor = tester.getRect(find.byType(CodeField));
    final diagram = tester.getRect(find.byType(FlowchartTabView));

    expect(editor.bottom, lessThanOrEqualTo(diagram.top));
    expect(editor.height, greaterThan(diagram.height));
  });

  testWidgets('an expanded width keeps the diagram beside the editor', (tester) async {
    await _openDiagramsTab(tester, const Size(1280, 900));

    await tester.tap(find.text('Acompañar'));
    await tester.pumpAndSettle();

    final editor = tester.getRect(find.byType(CodeField));
    final diagram = tester.getRect(find.byType(FlowchartTabView));

    expect(editor.right, lessThanOrEqualTo(diagram.left));
    expect(editor.width, closeTo(diagram.width, 1.0));
  });

  testWidgets('turning the companion off leaves the diagram alone again', (tester) async {
    await _openDiagramsTab(tester, const Size(390, 844));

    await tester.tap(find.byIcon(Icons.crop_square));
    await tester.pumpAndSettle();
    expect(find.byType(CodeField), findsOneWidget);

    await tester.tap(find.byIcon(Icons.horizontal_split));
    await tester.pumpAndSettle();

    expect(find.byType(CodeField), findsNothing);
    expect(find.byType(FlowchartTabView), findsOneWidget);
  });

  testWidgets('the stacked editor pane trades its key bar for lines of code', (tester) async {
    await _openDiagramsTab(tester, const Size(390, 844));
    await tester.tap(find.byIcon(Icons.crop_square));
    await tester.pumpAndSettle();

    expect(find.byType(CodeField), findsOneWidget);
    expect(tester.widget<EditorTabView>(find.byType(EditorTabView)).keepsKeyBar, isFalse);
  });

  testWidgets('the stacked diagram arrives already framed into its pane', (tester) async {
    await _openDiagramsTab(tester, const Size(390, 844));
    final alone = _diagramScale(tester);

    await tester.tap(find.byIcon(Icons.crop_square));
    await tester.pumpAndSettle();

    expect(_diagramScale(tester), lessThan(alone));
  });

  testWidgets('the side-by-side editor pane keeps its key bar', (tester) async {
    await _openDiagramsTab(tester, const Size(1280, 900));
    await tester.tap(find.text('Acompañar'));
    await tester.pumpAndSettle();

    expect(find.byType(CodeField), findsOneWidget);
    expect(tester.widget<EditorTabView>(find.byType(EditorTabView)).keepsKeyBar, isTrue);
  });

  testWidgets('the stacked companion does not overflow a compact document', (tester) async {
    final errors = await collectLayoutErrors(() async {
      await _openDiagramsTab(tester, const Size(360, 640));
      await tester.tap(find.byIcon(Icons.crop_square));
      await tester.pumpAndSettle();
    });

    expect(errors.map((e) => e.exception.toString()).toList(), isEmpty);
  });
}
