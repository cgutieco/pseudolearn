import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/test_dependencies.dart';

const String _factorialSource = 'Proceso Factorial\n'
    '  Definir n Como Entero;\n'
    '  Definir f Como Entero;\n'
    '  Definir i Como Entero;\n'
    '  n <- 5;\n'
    '  f <- 1;\n'
    '  Para i <- 1 Hasta n Con Paso 1 Hacer\n'
    '    f <- f * i;\n'
    '  FinPara\n'
    '  Escribir "Factorial: ", f;\n'
    'FinProceso\n';

void main() {
  testWidgets('Opening document populates flowchart tab with valid scene',
      (tester) async {
    final repo = InMemoryDocumentRepository();
    final now = DateTime(2026, 8, 16, 12, 0);
    repo.documents['doc-fact'] = Document(
      id: 'doc-fact',
      title: 'Cálculo de factorial',
      content: _factorialSource,
      profileId: SyntaxProfileId.classicSpanish,
      revision: 1,
      createdAt: now,
      updatedAt: now,
    );

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
        CubitScope(dependencies: buildTestDependencies(repository: repo)));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Navigator).first);
    GoRouter.of(context).go('/biblioteca/documento/doc-fact');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diagramas'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(
      find.text(
          'El ordinograma estará disponible cuando el código no tenga errores.'),
      findsNothing,
    );
  });
}
