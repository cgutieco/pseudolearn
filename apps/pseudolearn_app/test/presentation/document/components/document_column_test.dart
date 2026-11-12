import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/presentation/document/components/document_column.dart';
import 'package:pseudolearn_app/presentation/document/components/document_footer.dart';
import 'package:pseudolearn_app/presentation/document/components/document_workspace.dart';
import 'package:pseudolearn_app/presentation/document/components/exercise_strip.dart';

import '../../../fakes/fake_route_repository.dart';
import '../../../fakes/in_memory_document_repository.dart';
import '../../../fakes/pump_app.dart';
import '../../../fakes/route_fixtures.dart';
import '../../../fakes/test_dependencies.dart';

const String _source = 'Algoritmo Kiosco\n'
    '  Definir total Como Entero <- 3;\n'
    '  Escribir "Total: ", total;\n'
    'FinAlgoritmo\n';

const List<Size> _viewports = <Size>[
  Size(375, 812),
  Size(360, 640),
  Size(768, 1024),
  Size(1024, 1366),
];

final RouteExercise _kioskExercise = sampleExercise(
  'kiosco.nucleo',
  CasesEvaluation(
    visibleCases: [
      const ExerciseCase(
        inputs: [],
        expectedOutputs: ['Total: 3'],
        expectedValueKind: ExpectedValueKind.text,
      ),
    ],
    hiddenCases: const [],
    assertions: const [],
    reference: '',
  ),
);

Future<void> _openExerciseDocument(WidgetTester tester, Size size) async {
  final repository = InMemoryDocumentRepository();
  final now = DateTime(2026, 11, 7, 12);
  repository.documents['doc-kiosco'] = Document(
    id: 'doc-kiosco',
    title: 'El núcleo del kiosco',
    content: _source,
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: now,
    updatedAt: now,
    exerciseId: 'kiosco.nucleo',
  );
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[const Locale('es')];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(CubitScope(
    dependencies: buildTestDependencies(
      repository: repository,
      routeRepository: FakeRouteRepository(
        exercises: {'kiosco.nucleo': _kioskExercise},
      ),
    ),
  ));
  await tester.pumpAndSettle();
  final context = tester.element(find.byType(Navigator).first);
  GoRouter.of(context).go('/biblioteca/documento/doc-kiosco');
  await tester.pumpAndSettle();
}

void _expectFooterAtColumnBottom(WidgetTester tester, String label) {
  final columnBottom = tester.getBottomLeft(find.byType(DocumentColumn)).dy;
  final footerBottom = tester.getBottomLeft(find.byType(DocumentFooter)).dy;
  final workspaceBottom =
      tester.getBottomLeft(find.byType(DocumentWorkspace)).dy;
  final footerTop = tester.getTopLeft(find.byType(DocumentFooter)).dy;
  expect(footerBottom, moreOrLessEquals(columnBottom), reason: label);
  expect(workspaceBottom, moreOrLessEquals(footerTop), reason: label);
}

Finder _stripIcon(IconData icon) => find.descendant(
  of: find.byType(ExerciseStrip),
  matching: find.byIcon(icon),
);

void main() {
  for (final size in _viewports) {
    final name = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('$name keeps the debug strip on the bottom edge', (tester) async {
      late final List<String> errors;
      final collected = await collectLayoutErrors(() async {
        await _openExerciseDocument(tester, size);
        expect(_stripIcon(Icons.keyboard_arrow_up), findsOneWidget);
        _expectFooterAtColumnBottom(tester, '$name with the strip expanded');

        await tester.tap(_stripIcon(Icons.keyboard_arrow_up));
        await tester.pumpAndSettle();
        expect(_stripIcon(Icons.keyboard_arrow_down), findsOneWidget);
        _expectFooterAtColumnBottom(tester, '$name with the strip collapsed');

        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();
        _expectFooterAtColumnBottom(tester, '$name after running');
      });
      errors = collected.map((error) => error.exception.toString()).toList();
      expect(errors, isEmpty, reason: '$name overflow');
    });
  }
}
