import 'dart:convert';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/exercise.dart';
import '../../domain/model/knowledge/exercise_case.dart';
import '../../domain/model/knowledge/exercise_kind.dart';
import '../../domain/model/knowledge/exercise_level.dart';
import '../../domain/model/knowledge/expected_value_kind.dart';
import '../../domain/model/knowledge/structural_assertion.dart';
import 'structural_assertion_reader.dart';

final class ExerciseDocumentParser {
  const ExerciseDocumentParser();

  ContentLoadResult<Exercise> parse(String source) {
    final Map<String, dynamic> document;
    try {
      document = jsonDecode(source) as Map<String, dynamic>;
    } catch (error) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.exerciseMalformed,
        detail: '$error',
      );
    }
    return _exerciseOf(document);
  }

  ContentLoadResult<Exercise> _exerciseOf(Map<String, dynamic> document) {
    final level = ExerciseLevel.fromNumber(document['level'] as int? ?? 0);
    final kind = ExerciseKind.fromSlug(document['kind'] as String? ?? '');
    if (level == null || kind == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.exerciseMalformed,
        detail: '${document['id']}',
      );
    }
    final assertions = readStructuralAssertions(document['assertions']);
    if (assertions == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.exerciseMalformed,
        detail: '${document['id']}',
      );
    }
    return _buildExercise(
      document: document,
      level: level,
      kind: kind,
      assertions: assertions,
    );
  }

  ContentLoadResult<Exercise> _buildExercise({
    required Map<String, dynamic> document,
    required ExerciseLevel level,
    required ExerciseKind kind,
    required List<StructuralAssertion> assertions,
  }) {
    final visible = _casesOf(document['visibleCases']);
    final hidden = _casesOf(document['hiddenCases']);
    if (visible == null || hidden == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.exerciseMalformed,
        detail: '${document['id']}',
      );
    }
    return ContentLoaded(Exercise(
      id: document['id'] as String? ?? '',
      title: document['title'] as String? ?? '',
      statement: document['statement'] as String? ?? '',
      level: level,
      kind: kind,
      moduleId: document['module'] as String?,
      visibleCases: visible,
      hiddenCases: hidden,
      assertions: assertions,
      starterCode: document['starterCode'] as String?,
    ));
  }

  List<ExerciseCase>? _casesOf(Object? raw) {
    if (raw == null) return const [];
    if (raw is! List) return null;
    final cases = <ExerciseCase>[];
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) return null;
      final kind = ExpectedValueKind.fromSlug(entry['expected'] as String? ?? '');
      final inputs = _stringsOf(entry['inputs']);
      final outputs = _stringsOf(entry['expectedOutputs']);
      if (kind == null || inputs == null || outputs == null) return null;
      cases.add(ExerciseCase(
        inputs: inputs,
        expectedOutputs: outputs,
        expectedValueKind: kind,
      ));
    }
    return cases;
  }

  List<String>? _stringsOf(Object? raw) {
    if (raw == null) return const [];
    if (raw is! List) return null;
    final values = <String>[];
    for (final entry in raw) {
      if (entry is! String) return null;
      values.add(entry);
    }
    return values;
  }
}
