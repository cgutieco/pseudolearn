import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/editing/profile_key_source.dart';

const _source = ProfileKeySource();

EditorKey _keyOf(SyntaxProfileId profileId, EditorKeyKind kind) {
  final keys = _source.keysFor(profileId);
  for (final key in keys) {
    if (key.kind == kind) return key;
  }
  throw StateError('No key of kind $kind for $profileId');
}

void main() {
  group('ProfileKeySource', () {
    test('offers seven keys, the most frequent symbols of the profile', () {
      final keys = _source.keysFor(SyntaxProfileId.classicSpanish);

      expect(keys, hasLength(7));
      expect(
        keys.map((key) => key.kind),
        containsAll(<EditorKeyKind>[
          EditorKeyKind.indent,
          EditorKeyKind.assignment,
          EditorKeyKind.quote,
          EditorKeyKind.openParenthesis,
          EditorKeyKind.closeParenthesis,
          EditorKeyKind.greaterOrEqual,
          EditorKeyKind.lessOrEqual,
        ]),
      );
    });

    test('takes the assignment lexeme from the profile in the classic Spanish syntax', () {
      final key = _keyOf(SyntaxProfileId.classicSpanish, EditorKeyKind.assignment);

      expect(key.label, '<-');
      expect(key.insertion, '<-');
    });

    test('takes the assignment lexeme from the profile in the English syntax', () {
      final key = _keyOf(SyntaxProfileId.english, EditorKeyKind.assignment);

      expect(key.insertion, const ProfileKeySource().keysFor(SyntaxProfileId.english)[1].insertion);
      expect(key.insertion, isNotEmpty);
    });

    test('the delimiter key writes the pair and parks the caret inside', () {
      final key = _keyOf(SyntaxProfileId.classicSpanish, EditorKeyKind.quote);

      expect(key.label, '"');
      expect(key.insertion, '""');
      expect(key.caretOffset, 1);
    });

    test('the indent key carries no lexeme because indentation is not a lexeme', () {
      final key = _keyOf(SyntaxProfileId.classicSpanish, EditorKeyKind.indent);

      expect(key.insertion, isEmpty);
      expect(key.label, 'TAB');
    });

    test('the comparison keys come from the profile and not from a literal', () {
      final greater = _keyOf(SyntaxProfileId.classicSpanish, EditorKeyKind.greaterOrEqual);
      final less = _keyOf(SyntaxProfileId.classicSpanish, EditorKeyKind.lessOrEqual);

      expect(greater.insertion, '>=');
      expect(less.insertion, '<=');
    });
  });
}
