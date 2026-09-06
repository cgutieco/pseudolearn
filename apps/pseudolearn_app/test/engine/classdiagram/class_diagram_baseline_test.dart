import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'diagram_scene_validators.dart';
import 'fixtures/class_diagram_corpus.dart';

DiagramScene _build(String source) => CoreClassDiagramBuilder().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
    );

void main() {
  group('Class Diagram Baseline Corpus Measurement', () {
    for (final entry in ClassDiagramCorpus.all.entries) {
      final name = entry.key;
      final source = entry.value;

      test('measures invariants on $name', () {
        final scene1 = _build(source);
        final scene2 = _build(source);

        expect(areScenesIdentical(scene1, scene2), isTrue,
            reason: '$name must be deterministic');
        expect(scene1.width, greaterThan(0));
        expect(scene1.height, greaterThan(0));
      });
    }

    test('measures baseline metrics for robotAutonomo', () {
      final scene = _build(ClassDiagramCorpus.robotAutonomo);

      expect(countLineBoxCrossings(scene), 0);
      expect(countTotalLabelCollisions(scene), 1);
      expect(measureCollinearOverlapPx(scene), 0.0);
      expect(countTextOverflows(scene), 5);
      expect(countEdgeEdgeCrossings(scene), 9);
    });

    test('measures baseline metrics for denseProgram', () {
      final scene = _build(ClassDiagramCorpus.denseProgram);

      expect(countLineBoxCrossings(scene), 6);
      expect(countTotalLabelCollisions(scene), 2);
      expect(measureCollinearOverlapPx(scene), greaterThan(400.0));
      expect(countEdgeEdgeCrossings(scene), 24);
    });
  });
}
