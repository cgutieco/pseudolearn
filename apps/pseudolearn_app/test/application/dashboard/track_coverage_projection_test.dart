import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/track_coverage_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectTrackCoverage (PANT-06-F5)', () {
    final modules = [
      moduleEntry('CON-A1', track: LearningTrack.foundations, order: 1),
      moduleEntry('CON-A2', track: LearningTrack.foundations, order: 2),
      moduleEntry('CON-B1', track: LearningTrack.imperative, order: 1),
    ];

    test('counts visited modules within each track', () {
      final coverage = projectTrackCoverage(
        modules: modules,
        visitedIds: {'CON-A1'},
      );

      expect(coverage.length, LearningTrack.values.length);
      expect(coverage.first.modules.done, 1);
      expect(coverage.first.modules.total, 2);
    });

    test('a track without modules reports zero of zero, not a division error', () {
      final coverage = projectTrackCoverage(
        modules: modules,
        visitedIds: const {},
      );
      final objectOriented = coverage.last;

      expect(objectOriented.track, LearningTrack.objectOriented);
      expect(objectOriented.modules.total, 0);
      expect(objectOriented.modules.ratio, 0);
    });

    test('a visit to an unknown module does not inflate any track', () {
      final coverage = projectTrackCoverage(
        modules: modules,
        visitedIds: {'CON-Z9'},
      );

      for (final track in coverage) {
        expect(track.modules.done, 0);
      }
    });

    test('all modules visited marks the track as complete', () {
      final coverage = projectTrackCoverage(
        modules: modules,
        visitedIds: {'CON-A1', 'CON-A2'},
      );

      expect(coverage.first.modules.isComplete, isTrue);
    });
  });
}
