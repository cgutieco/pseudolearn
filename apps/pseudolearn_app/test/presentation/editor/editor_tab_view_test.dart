import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/components/status_banner.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/test_dependencies.dart';

const String _source = 'Proceso Saludo\n'
    '\tEscribir "Hola";\n'
    'FinProceso\n';

Future<void> _openDocument(WidgetTester tester) async {
  final repo = InMemoryDocumentRepository();
  final now = DateTime(2026, 8, 16, 12, 0);
  repo.documents['doc-1'] = Document(
    id: 'doc-1',
    title: 'Saludo',
    content: _source,
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: now,
    updatedAt: now,
  );

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[const Locale('es')];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(CubitScope(dependencies: buildTestDependencies(repository: repo)));
  await tester.pumpAndSettle();

  final context = tester.element(find.byType(Navigator).first);
  GoRouter.of(context).go('/biblioteca/documento/doc-1');
  await tester.pumpAndSettle();
}

Future<void> _runToEnd(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.play_arrow).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an idle editor shows no execution banner', (tester) async {
    await _openDocument(tester);

    expect(find.byType(StatusBanner), findsNothing);
  });

  testWidgets('finishing a run announces it once and lets it be dismissed', (tester) async {
    await _openDocument(tester);
    await _runToEnd(tester);

    expect(find.byType(StatusBanner), findsOneWidget);
    expect(find.text('Ejecución finalizada con éxito'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(StatusBanner), findsNothing);
  });

  testWidgets('a dismissed banner comes back with the next run', (tester) async {
    await _openDocument(tester);
    await _runToEnd(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await _runToEnd(tester);

    expect(find.byType(StatusBanner), findsOneWidget);
  });
}
