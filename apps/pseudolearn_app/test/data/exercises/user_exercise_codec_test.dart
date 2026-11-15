import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/exercises/user_exercise_codec.dart';
import '../../fakes/user_exercise_fixtures.dart';

void main() {
  group('userExercisePayloadText', () {
    test('a jsonb object pulled from the server decodes to the same draft', () {
      final draft = sumDraft();
      final pulled = jsonDecode(encodeUserExerciseDraft(draft)) as Map<String, dynamic>;
      final decoded = decodeUserExerciseDraft(userExercisePayloadText(pulled)!)!;
      expect(decoded.title, draft.title);
      expect(decoded.visibleCases, draft.visibleCases);
      expect(decoded.referenceSolution, draft.referenceSolution);
    });

    test('a payload that already is text passes through unchanged', () {
      final text = encodeUserExerciseDraft(sumDraft());
      expect(userExercisePayloadText(text), text);
    });

    test('an empty object and an empty text are kept so the decoder rejects them', () {
      expect(userExercisePayloadText(<String, dynamic>{}), '{}');
      expect(userExercisePayloadText(''), '');
      expect(decodeUserExerciseDraft(userExercisePayloadText(<String, dynamic>{})!), isNull);
    });

    test('a missing or non-object payload yields nothing', () {
      expect(userExercisePayloadText(null), isNull);
      expect(userExercisePayloadText(42), isNull);
      expect(userExercisePayloadText(const ['title']), isNull);
    });
  });

  group('userExerciseOfRow', () {
    test('builds the exercise from a pulled object payload', () {
      final pulled = jsonDecode(encodeUserExerciseDraft(sumDraft())) as Map<String, dynamic>;
      final exercise = userExerciseOfRow(
        id: 'ux-1',
        payload: userExercisePayloadText(pulled)!,
        revision: 2,
        createdAt: '2026-11-08T10:00:00Z',
        updatedAt: '2026-11-08T11:00:00Z',
      );
      expect(exercise?.id, 'ux-1');
      expect(exercise?.revision, 2);
      expect(exercise?.draft.title, sumDraft().title);
    });

    test('rejects a row whose dates cannot be read', () {
      final exercise = userExerciseOfRow(
        id: 'ux-1',
        payload: encodeUserExerciseDraft(sumDraft()),
        revision: 1,
        createdAt: '',
        updatedAt: '2026-11-08T11:00:00Z',
      );
      expect(exercise, isNull);
    });
  });
}
