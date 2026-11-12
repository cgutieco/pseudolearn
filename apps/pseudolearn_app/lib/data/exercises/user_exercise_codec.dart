import 'dart:convert';
import '../../domain/model/exercises/user_exercise.dart';
import '../../domain/model/exercises/user_exercise_draft.dart';
import '../../domain/model/knowledge/exercise_case.dart';
import '../../domain/model/knowledge/expected_value_kind.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../route/structural_assertion_reader.dart';
import 'structural_assertion_writer.dart';

String encodeUserExerciseDraft(UserExerciseDraft draft) => jsonEncode({
  'title': draft.title,
  'narrative': draft.narrative,
  'statement': draft.statement,
  'restrictions': draft.restrictions,
  'hints': draft.hints,
  'visible_cases': [for (final item in draft.visibleCases) _writeCase(item)],
  'hidden_cases': [for (final item in draft.hiddenCases) _writeCase(item)],
  'assertions': [
    for (final assertion in draft.assertions) writeStructuralAssertion(assertion),
  ],
  'reference_solution': draft.referenceSolution,
  'starter_code': draft.starterCode,
  'profile': draft.profileId.name,
});

UserExerciseDraft? decodeUserExerciseDraft(String payload) {
  try {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final assertions = readStructuralAssertions(map['assertions']);
    if (assertions == null) return null;
    return UserExerciseDraft(
      title: map['title'] as String,
      narrative: map['narrative'] as String? ?? '',
      statement: map['statement'] as String,
      restrictions: _strings(map['restrictions']),
      hints: _strings(map['hints']),
      visibleCases: _cases(map['visible_cases']),
      hiddenCases: _cases(map['hidden_cases']),
      assertions: assertions,
      referenceSolution: map['reference_solution'] as String,
      starterCode: map['starter_code'] as String? ?? '',
      profileId: _profile(map['profile'] as String?),
    );
  } on Object {
    return null;
  }
}

String? userExercisePayloadText(Object? raw) => switch (raw) {
  final String text => text,
  final Map<String, dynamic> object => jsonEncode(object),
  _ => null,
};

UserExercise? userExerciseOfRow({
  required String id,
  required String payload,
  required int revision,
  required String createdAt,
  required String updatedAt,
}) {
  final draft = decodeUserExerciseDraft(payload);
  final created = DateTime.tryParse(createdAt);
  final updated = DateTime.tryParse(updatedAt);
  if (draft == null || created == null || updated == null) return null;
  return UserExercise(
    id: id,
    draft: draft,
    revision: revision,
    createdAt: created,
    updatedAt: updated,
  );
}

Map<String, Object?> _writeCase(ExerciseCase item) => {
  'inputs': item.inputs,
  'expected': item.expectedOutputs,
  'kind': item.expectedValueKind.slug,
};

List<ExerciseCase> _cases(Object? raw) => [
  for (final entry in (raw as List<dynamic>? ?? const []))
    ExerciseCase(
      inputs: _strings((entry as Map<String, dynamic>)['inputs']),
      expectedOutputs: _strings(entry['expected']),
      expectedValueKind:
          ExpectedValueKind.fromSlug(entry['kind'] as String? ?? '') ??
          ExpectedValueKind.text,
    ),
];

List<String> _strings(Object? raw) => [
  for (final entry in (raw as List<dynamic>? ?? const [])) entry as String,
];

SyntaxProfileId _profile(String? name) => SyntaxProfileId.values.firstWhere(
  (profile) => profile.name == name,
  orElse: () => SyntaxProfileId.classicSpanish,
);
