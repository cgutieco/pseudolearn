import 'package:pseudolearn_app/application/dashboard/dashboard_inputs.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_projection.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import '../../fakes/route_fixtures.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../application/dashboard/dashboard_fixtures.dart';

final DateTime dashboardFixtureNow = DateTime(2026, 9, 2, 12);

List<ReferenceIndexEntry> _sections() {
  return [
    specificationEntry('esp-i-lexico', order: 1, title: 'Estructura léxica'),
    specificationEntry('esp-i-control', order: 6, title: 'Estructuras de control'),
    specificationEntry('esp-i-arreglos', order: 7, title: 'Arreglos'),
    specificationEntry('esp-i-subprogramas', order: 8, title: 'Subprogramas'),
    specificationEntry('esp-o-clases', order: 11, title: 'Clases y objetos'),
  ];
}

DashboardInputs _populatedInputs() {
  return DashboardInputs(
    documents: [
      summaryOf('doc-1', title: 'Suma', createdAt: DateTime(2026, 8, 10)),
      summaryOf('doc-2', title: 'Promedio', createdAt: DateTime(2026, 8, 25)),
      summaryOf('doc-3', title: 'Ordenar', createdAt: DateTime(2026, 9, 1)),
      summaryOf('doc-4', title: 'Suma (conflicto)', createdAt: DateTime(2026, 9, 1), profileId: SyntaxProfileId.english),
    ],
    constructsByDocument: {
      'doc-1': {AstConstruct.conditional},
      'doc-2': {AstConstruct.conditional, AstConstruct.countedLoop},
      'doc-3': {AstConstruct.countedLoop, AstConstruct.arrayDeclaration},
      'doc-4': {AstConstruct.conditional},
    },
    toc: sampleToc,
    specificationSections: _sections(),
    progress: [
      visitedEntry(routeLessonProgressId('inicio.primero'), at: DateTime(2026, 8, 12)),
      completedEntry(routeExerciseProgressId('inicio.primero.a'), at: DateTime(2026, 8, 26)),
      completedEntry(routeExerciseProgressId('inicio.primero.b'), at: DateTime(2026, 8, 26)),
      visitedEntry(routeLessonProgressId('imperativo.segundo'), at: DateTime(2026, 9, 1)),
    ],
    pending: [outboxEntry('doc-3', enqueuedAt: DateTime(2026, 8, 29, 12))],
    now: dashboardFixtureNow,
  );
}

DashboardState populatedDashboardState() =>
    const DashboardProjection().project(_populatedInputs());

DashboardState emptyDashboardState() {
  return const DashboardProjection().project(DashboardInputs(
    documents: const [],
    constructsByDocument: const {},
    toc: const RouteToc.empty(),
    specificationSections: const [],
    progress: const [],
    pending: const [],
    now: DateTime(2026, 9, 2, 12),
  ));
}
