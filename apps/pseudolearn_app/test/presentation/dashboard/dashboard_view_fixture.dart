import 'package:pseudolearn_app/application/dashboard/dashboard_inputs.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_projection.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../application/dashboard/dashboard_fixtures.dart';

final DateTime dashboardFixtureNow = DateTime(2026, 9, 2, 12);

List<KnowledgeEntry> _entries() {
  return [
    moduleEntry('CON-A1', track: LearningTrack.foundations, order: 1, title: 'Qué es un algoritmo'),
    moduleEntry('CON-A2', track: LearningTrack.foundations, order: 2, title: 'La máquina nocional'),
    moduleEntry('CON-B3', track: LearningTrack.imperative, order: 3, title: 'Decidir'),
    moduleEntry('CON-C1', track: LearningTrack.objectOriented, order: 1, title: 'Objetos'),
    exerciseEntry('CON-A2-E1', moduleId: 'CON-A2'),
    exerciseEntry('CON-A2-E2', moduleId: 'CON-A2', kind: ExerciseKind.modify),
    exerciseEntry('CON-B3-E1', moduleId: 'CON-B3', level: ExerciseLevel.compose),
    exerciseEntry('CON-C1-E1', moduleId: 'CON-C1', level: ExerciseLevel.design, kind: ExerciseKind.predict),
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
    entries: _entries(),
    progress: [
      visitedEntry('CON-A1', at: DateTime(2026, 8, 12)),
      visitedEntry('CON-A2', at: DateTime(2026, 8, 26)),
      completedEntry('CON-A2-E1', at: DateTime(2026, 8, 26)),
      completedEntry('CON-B3-E1', at: DateTime(2026, 9, 1)),
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
    entries: const [],
    progress: const [],
    pending: const [],
    now: DateTime(2026, 9, 2, 12),
  ));
}
