import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/components/status_banner.dart';
import 'package:pseudolearn_app/presentation/document/components/run_result_pill.dart';
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
  testWidgets('an idle editor shows no execution banner nor result', (tester) async {
    await _openDocument(tester);

    expect(find.byType(StatusBanner), findsNothing);
    expect(find.byType(RunResultPill), findsNothing);
  });

  testWidgets('finishing a run is told by a quiet pill, never a banner', (tester) async {
    await _openDocument(tester);
    await _runToEnd(tester);

    expect(find.byType(StatusBanner), findsNothing);
    expect(find.text('Ejecución finalizada con éxito'), findsNothing);
    expect(find.widgetWithText(RunResultPill, 'Terminado'), findsOneWidget);
    expect(find.text('Hola'), findsOneWidget);
  });

  testWidgets('the run bar no longer narrates status nor counts statements', (tester) async {
    await _openDocument(tester);
    await _runToEnd(tester);

    expect(find.text('Ejecución terminada'), findsNothing);
    expect(find.textContaining('Sentencia'), findsNothing);
    expect(find.textContaining('Carpeta de trabajo'), findsNothing);
    expect(find.text('Argumentos'), findsNothing);
  });

  testWidgets('run options gather arguments, replay and the files folder', (tester) async {
    await _openDocument(tester);
    await _runToEnd(tester);

    await tester.tap(find.byTooltip('Opciones de ejecución'));
    await tester.pumpAndSettle();

    expect(find.text('Argumentos'), findsOneWidget);
    expect(
      find.text('Los archivos que tu programa crea o lee se guardan en la carpeta de este algoritmo.'),
      findsOneWidget,
    );
    expect(find.text('Repetir última ejecución'), findsOneWidget);
  });

  testWidgets('malformed arguments are flagged inside the options sheet', (tester) async {
    await _openDocument(tester);

    await tester.tap(find.byTooltip('Opciones de ejecución'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '"sin cerrar');
    await tester.pumpAndSettle();

    expect(
      find.text('Revisa las comillas y los escapes de los argumentos.'),
      findsOneWidget,
    );
  });
}
