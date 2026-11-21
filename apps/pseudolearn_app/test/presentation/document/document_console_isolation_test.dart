import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/test_dependencies.dart';

InMemoryDocumentRepository _twoDocumentRepository() {
  final repo = InMemoryDocumentRepository();
  final now = DateTime(2026, 8, 16, 12, 0);
  repo.documents['doc-1'] = Document(
    id: 'doc-1',
    title: 'hola2',
    content: 'Algoritmo Saludo\n  Escribir "Tu número es: 6";\nFinAlgoritmo\n',
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: now,
    updatedAt: now,
  );
  repo.documents['doc-2'] = Document(
    id: 'doc-2',
    title: 'hola3',
    content: '',
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: now,
    updatedAt: now,
  );
  return repo;
}

void main() {
  testWidgets(
    'console output stays on the same document and clears when opening another',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final deps = buildTestDependencies(repository: _twoDocumentRepository());
      await tester.pumpWidget(CubitScope(dependencies: deps));
      await tester.pumpAndSettle();

      final routerContext = tester.element(find.byType(Navigator).first);
      GoRouter.of(routerContext).go('/biblioteca/documento/doc-1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(find.text('Tu número es: 6'), findsOneWidget);

      GoRouter.of(routerContext).go('/biblioteca');
      await tester.pumpAndSettle();
      GoRouter.of(routerContext).go('/biblioteca/documento/doc-1');
      await tester.pumpAndSettle();

      expect(find.text('Tu número es: 6'), findsOneWidget);

      GoRouter.of(routerContext).go('/biblioteca');
      await tester.pumpAndSettle();
      GoRouter.of(routerContext).go('/biblioteca/documento/doc-2');
      await tester.pumpAndSettle();

      final execution = routerContext.read<ExecutionCubit>().state;
      expect(execution.status, ExecutionStatus.idle);
      expect(execution.outputLines, isEmpty);
      expect(execution.isOutputPanelExpanded, isFalse);
      expect(find.text('Tu número es: 6'), findsNothing);
    },
  );

  testWidgets(
    'console output clears when navigating directly between two documents',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final deps = buildTestDependencies(repository: _twoDocumentRepository());
      await tester.pumpWidget(CubitScope(dependencies: deps));
      await tester.pumpAndSettle();

      final routerContext = tester.element(find.byType(Navigator).first);
      GoRouter.of(routerContext).go('/biblioteca/documento/doc-1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(find.text('Tu número es: 6'), findsOneWidget);

      GoRouter.of(routerContext).go('/biblioteca/documento/doc-2');
      await tester.pumpAndSettle();

      final execution = routerContext.read<ExecutionCubit>().state;
      expect(execution.status, ExecutionStatus.idle);
      expect(execution.outputLines, isEmpty);
      expect(execution.isOutputPanelExpanded, isFalse);
      expect(find.text('Tu número es: 6'), findsNothing);
    },
  );
}
