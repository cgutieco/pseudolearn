import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/next_module_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectNextModule (PANT-06-F5)', () {
    final modules = [
      moduleEntry('CON-B1', track: LearningTrack.imperative, order: 1),
      moduleEntry('CON-A2', track: LearningTrack.foundations, order: 2),
      moduleEntry('CON-A1', track: LearningTrack.foundations, order: 1),
    ];

    test('suggests the first unvisited module in canonical order', () {
      final next = projectNextModule(modules: modules, visitedIds: const {});

      expect(next?.id, 'CON-A1');
      expect(next?.track, LearningTrack.foundations);
    });

    test('skips visited modules and crosses into the next track', () {
      final next = projectNextModule(
        modules: modules,
        visitedIds: {'CON-A1', 'CON-A2'},
      );

      expect(next?.id, 'CON-B1');
    });

    test('returns nothing when every module has been visited', () {
      final next = projectNextModule(
        modules: modules,
        visitedIds: {'CON-A1', 'CON-A2', 'CON-B1'},
      );

      expect(next, isNull);
    });

    test('an empty route suggests nothing instead of failing', () {
      expect(projectNextModule(modules: const [], visitedIds: const {}), isNull);
    });
  });
}
