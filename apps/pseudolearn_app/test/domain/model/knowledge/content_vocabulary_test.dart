import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/member_visibility.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/specification_document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion_kind.dart';

void main() {
  group('ExerciseLevel', () {
    test('the three declared levels are recognised by number', () {
      expect(ExerciseLevel.fromNumber(1), ExerciseLevel.reproduce);
      expect(ExerciseLevel.fromNumber(2), ExerciseLevel.compose);
      expect(ExerciseLevel.fromNumber(3), ExerciseLevel.design);
    });

    test('a level out of range is not a level', () {
      expect(ExerciseLevel.fromNumber(0), isNull);
      expect(ExerciseLevel.fromNumber(4), isNull);
      expect(ExerciseLevel.fromNumber(-1), isNull);
    });
  });

  group('slug vocabularies', () {
    test('every declared slug round trips back to its value', () {
      for (final part in ModulePart.values) {
        expect(ModulePart.fromSlug(part.slug), part);
      }
      for (final kind in ContentMarkerKind.values) {
        expect(ContentMarkerKind.fromSlug(kind.slug), kind);
      }
      for (final kind in ExerciseKind.values) {
        expect(ExerciseKind.fromSlug(kind.slug), kind);
      }
      for (final kind in ExpectedValueKind.values) {
        expect(ExpectedValueKind.fromSlug(kind.slug), kind);
      }
      for (final construct in AstConstruct.values) {
        expect(AstConstruct.fromSlug(construct.slug), construct);
      }
      for (final visibility in MemberVisibility.values) {
        expect(MemberVisibility.fromSlug(visibility.slug), visibility);
      }
      for (final kind in StructuralAssertionKind.values) {
        expect(StructuralAssertionKind.fromSlug(kind.slug), kind);
      }
      for (final document in SpecificationDocument.values) {
        expect(SpecificationDocument.fromSlug(document.slug), document);
      }
      for (final track in LearningTrack.values) {
        expect(LearningTrack.fromCode(track.code), track);
      }
    });

    test('slugs are unique within each vocabulary', () {
      expect(ModulePart.values.map((p) => p.slug).toSet().length, 7);
      expect(ContentMarkerKind.values.map((k) => k.slug).toSet().length, 7);
      expect(AstConstruct.values.map((c) => c.slug).toSet().length, 8);
    });

    test('an unknown slug is not a value, and neither is an empty one', () {
      expect(ModulePart.fromSlug('resumen'), isNull);
      expect(ModulePart.fromSlug(''), isNull);
      expect(ContentMarkerKind.fromSlug('lexeme'), isNull);
      expect(LearningTrack.fromCode('D'), isNull);
      expect(SpecificationDocument.fromSlug(''), isNull);
    });
  });
}
