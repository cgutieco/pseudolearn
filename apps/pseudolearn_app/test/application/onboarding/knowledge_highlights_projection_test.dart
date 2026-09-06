import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/knowledge_highlights_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/onboarding/knowledge_highlights.dart';

const _projection = KnowledgeHighlightsProjection();

KnowledgeEntry _module({
  required String id,
  required LearningTrack? track,
  required int order,
  String? title,
}) {
  return KnowledgeEntry(
    id: id,
    type: KnowledgeEntryType.module,
    title: title ?? id,
    summary: '',
    track: track,
    order: order,
  );
}

KnowledgeEntry _exercise({required String id, required ExerciseLevel? level}) {
  return KnowledgeEntry(
    id: id,
    type: KnowledgeEntryType.exercise,
    title: id,
    summary: '',
    level: level,
  );
}

KnowledgeEntry _section(String id) {
  return KnowledgeEntry(
    id: id,
    type: KnowledgeEntryType.specificationSection,
    title: id,
    summary: '',
  );
}

void main() {
  group('KnowledgeHighlightsProjection', () {
    test('counts modules per track and names the lowest ordered one', () {
      final highlights = _projection.of([
        _module(id: 'A2', track: LearningTrack.foundations, order: 2),
        _module(
          id: 'A1',
          track: LearningTrack.foundations,
          order: 1,
          title: 'Primer modulo',
        ),
        _module(id: 'B1', track: LearningTrack.imperative, order: 1),
      ]);

      expect(highlights.moduleCount, 3);
      expect(highlights.tracks.length, 2);
      expect(highlights.tracks.first.track, LearningTrack.foundations);
      expect(highlights.tracks.first.moduleCount, 2);
      expect(highlights.tracks.first.firstModuleTitle, 'Primer modulo');
    });

    test('orders the tracks as the route declares them', () {
      final highlights = _projection.of([
        _module(id: 'C1', track: LearningTrack.objectOriented, order: 1),
        _module(id: 'A1', track: LearningTrack.foundations, order: 1),
        _module(id: 'B1', track: LearningTrack.imperative, order: 1),
      ]);

      expect(
        [for (final track in highlights.tracks) track.track],
        [
          LearningTrack.foundations,
          LearningTrack.imperative,
          LearningTrack.objectOriented,
        ],
      );
    });

    test('counts sections and exercises by level', () {
      final highlights = _projection.of([
        _section('ESP-1'),
        _section('ESP-2'),
        _exercise(id: 'E1', level: ExerciseLevel.reproduce),
        _exercise(id: 'E2', level: ExerciseLevel.reproduce),
        _exercise(id: 'E3', level: ExerciseLevel.design),
      ]);

      expect(highlights.specificationCount, 2);
      expect(highlights.exerciseCount, 3);
      expect(highlights.exerciseLevels.length, 2);
      expect(highlights.exerciseLevels.first.level, ExerciseLevel.reproduce);
      expect(highlights.exerciseLevels.first.count, 2);
      expect(highlights.exerciseLevels.last.level, ExerciseLevel.design);
    });

    test('ignores a module without a track and an exercise without level', () {
      final highlights = _projection.of([
        _module(id: 'loose', track: null, order: 1),
        _exercise(id: 'loose', level: null),
      ]);

      expect(highlights.moduleCount, 1);
      expect(highlights.exerciseCount, 1);
      expect(highlights.tracks, isEmpty);
      expect(highlights.exerciseLevels, isEmpty);
    });

    test('an empty catalogue yields empty highlights', () {
      final highlights = _projection.of(const []);

      expect(highlights.hasRoute, isFalse);
      expect(highlights.hasSpecification, isFalse);
      expect(highlights.hasExercises, isFalse);
      expect(highlights, const KnowledgeHighlights.empty());
    });

    test('entries of other types are left out of every count', () {
      final highlights = _projection.of(const [
        KnowledgeEntry(
          id: 'ref',
          type: KnowledgeEntryType.reference,
          title: 'ref',
          summary: '',
        ),
        KnowledgeEntry(
          id: 'ill',
          type: KnowledgeEntryType.illustration,
          title: 'ill',
          summary: '',
        ),
      ]);

      expect(highlights.moduleCount, 0);
      expect(highlights.specificationCount, 0);
      expect(highlights.exerciseCount, 0);
    });
  });
}
