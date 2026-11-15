import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/knowledge_highlights_projection.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import '../../fakes/route_fixtures.dart';

void main() {
  const projection = KnowledgeHighlightsProjection();

  test('summarises parts, lessons, levels and specification sections', () {
    final highlights = projection.of(toc: sampleToc, index: sampleIndex());

    expect(highlights.lessonCount, 2);
    expect(highlights.exerciseCount, 4);
    expect(highlights.specificationCount, 1);
    expect(highlights.parts.first.title, 'Empezar de cero');
    expect(highlights.exerciseLevels.map((level) => level.count), [2, 1, 1]);
    expect(highlights.hasRoute, isTrue);
  });

  test('levels without exercises and parts without lessons are left out', () {
    final toc = RouteToc([
      ...sampleToc.parts,
      const RoutePartEntry(id: 'vacia', number: 'IX', title: 'Vacía', motto: '', summary: '', lessons: []),
    ]);
    final highlights = projection.of(toc: toc, index: null);

    expect(highlights.parts.length, 2);
    expect(highlights.specificationCount, 0);
    expect(highlights.exerciseLevels.map((level) => level.level), contains(RouteLevel.tree));
  });

  test('an empty route has nothing to highlight', () {
    final highlights = projection.of(toc: const RouteToc.empty(), index: null);

    expect(highlights.hasRoute, isFalse);
    expect(highlights.hasExercises, isFalse);
    expect(highlights.exerciseLevels, isEmpty);
  });
}
