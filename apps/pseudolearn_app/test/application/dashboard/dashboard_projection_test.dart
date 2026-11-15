import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_inputs.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_projection.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import '../../fakes/route_fixtures.dart';
import 'dashboard_fixtures.dart';

DashboardInputs _inputs({bool withData = true, RouteToc? toc}) {
  final moment = DateTime(2026, 9, 1);
  return DashboardInputs(
    documents: withData ? [summaryOf('doc-1', createdAt: moment)] : const [],
    constructsByDocument: withData
        ? {
            'doc-1': {AstConstruct.conditional},
          }
        : const {},
    toc: toc ?? sampleToc,
    specificationSections: sampleIndex().sections,
    progress: withData
        ? [
            visitedEntry(routeLessonProgressId('inicio.primero'), at: moment),
            completedEntry(routeExerciseProgressId('inicio.primero.a'), at: moment),
            completedEntry(routeExerciseProgressId('inicio.primero.b'), at: moment),
            completedEntry('CON-A1-E1', at: moment),
          ]
        : const [],
    pending: withData
        ? [outboxEntry('doc-1', enqueuedAt: DateTime(2026, 8, 30, 12))]
        : const [],
    now: DateTime(2026, 9, 2, 12),
  );
}

void main() {
  group('DashboardProjection', () {
    const projection = DashboardProjection();

    test('turns a full set of local readings into a success state', () {
      final state = projection.project(_inputs());

      expect(state.status, DashboardStatus.success);
      expect(state.library.total, 1);
      expect(state.route.first.lessons.done, 1);
      expect(state.route.last.lessons.done, 0);
      expect(state.exercises.overall.done, 2);
      expect(state.nextLesson?.id, 'imperativo.segundo');
      expect(state.sync.pendingCount, 1);
      expect(state.concepts.count.done, 1);
      expect(state.specification.count.done, 1);
      expect(state.activity.hasActivity, isTrue);
      expect(state.hasNothingRecorded, isFalse);
    });

    test('a device with nothing recorded still produces a complete state', () {
      final state = projection.project(_inputs(withData: false));

      expect(state.hasNothingRecorded, isTrue);
      expect(state.route.length, 2);
      expect(state.concepts.concepts.length, AstConstruct.values.length);
      expect(state.nextLesson?.id, 'inicio.primero');
      expect(state.sync.pendingCount, 0);
    });

    test('progress of the retired route is ignored', () {
      final state = projection.project(_inputs());

      expect(state.exercises.overall.total, 4);
      expect(state.exercises.overall.done, 2);
    });

    test('an empty route leaves route and exercises at zero', () {
      final state = projection.project(
        _inputs(withData: false, toc: const RouteToc.empty()),
      );

      expect(state.exercises.overall.total, 0);
      expect(state.route, isEmpty);
      expect(state.nextLesson, isNull);
    });
  });
}
