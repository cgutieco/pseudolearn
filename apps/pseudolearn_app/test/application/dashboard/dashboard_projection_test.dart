import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_inputs.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_projection.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'dashboard_fixtures.dart';

DashboardInputs _inputs({
  bool withData = true,
}) {
  return DashboardInputs(
    documents: withData
        ? [summaryOf('doc-1', createdAt: DateTime(2026, 9, 1))]
        : const [],
    constructsByDocument: withData
        ? {
            'doc-1': {AstConstruct.countedLoop},
          }
        : const {},
    entries: [
      moduleEntry('CON-A1', track: LearningTrack.foundations, order: 1),
      moduleEntry('CON-B3', track: LearningTrack.imperative, order: 3),
      exerciseEntry('CON-A1-E1', moduleId: 'CON-A1'),
      specificationEntry('esp-i-control', order: 2),
      specificationEntry('esp-i-lexico', order: 1),
    ],
    progress: withData
        ? [
            visitedEntry('CON-A1', at: DateTime(2026, 9, 1)),
            completedEntry('CON-A1-E1', at: DateTime(2026, 9, 1)),
          ]
        : const [],
    pending: withData
        ? [outboxEntry('doc-1', enqueuedAt: DateTime(2026, 8, 30, 12))]
        : const [],
    now: DateTime(2026, 9, 2, 12),
  );
}

void main() {
  group('DashboardProjection (PANT-06-F5)', () {
    const projection = DashboardProjection();

    test('turns a full set of local readings into a success state', () {
      final state = projection.project(_inputs());

      expect(state.status, DashboardStatus.success);
      expect(state.library.total, 1);
      expect(state.route.first.modules.done, 1);
      expect(state.exercises.overall.done, 1);
      expect(state.nextModule?.id, 'CON-B3');
      expect(state.sync.pendingCount, 1);
      expect(state.concepts.count.done, 1);
      expect(state.specification.count.done, 1);
      expect(state.activity.hasActivity, isTrue);
      expect(state.hasNothingRecorded, isFalse);
    });

    test('a device with nothing recorded still produces a complete state', () {
      final state = projection.project(_inputs(withData: false));

      expect(state.status, DashboardStatus.success);
      expect(state.hasNothingRecorded, isTrue);
      expect(state.route.length, LearningTrack.values.length);
      expect(state.concepts.concepts.length, AstConstruct.values.length);
      expect(state.nextModule?.id, 'CON-A1');
      expect(state.sync.pendingCount, 0);
    });

    test('conflict copies of the library are counted as open conflicts', () {
      final inputs = DashboardInputs(
        documents: [
          summaryOf('doc-1', title: 'Suma'),
          summaryOf('doc-2', title: 'Suma (conflicto)'),
        ],
        constructsByDocument: const {},
        entries: const [],
        progress: const [],
        pending: const [],
        now: DateTime(2026, 9, 2),
      );

      expect(projection.project(inputs).sync.conflictCount, 1);
    });

    test('an empty knowledge base leaves route and exercises at zero', () {
      final inputs = DashboardInputs(
        documents: const [],
        constructsByDocument: const {},
        entries: const [],
        progress: const [],
        pending: const [],
        now: DateTime(2026, 9, 2),
      );
      final state = projection.project(inputs);

      expect(state.exercises.overall.total, 0);
      expect(state.specification.sections, isEmpty);
      expect(state.nextModule, isNull);
    });
  });
}
