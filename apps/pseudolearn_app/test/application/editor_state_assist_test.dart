import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';

CompletionItem _item(
  String label, {
  String? template,
  bool inline = false,
  int revision = 3,
  CaretRange? range = const CaretRange(start: 0, end: 2),
}) => CompletionItem(
  label: label,
  template: template ?? label,
  caretOffset: 0,
  family: CompletionFamily.structured,
  isInline: inline,
  revision: revision,
  replacementRange: range,
);

EditorState _state(String source, List<CompletionItem> items) =>
    EditorState.initial().copyWith(
      sourceCode: source,
      contextualCompletions: items,
      completionRevision: 3,
    );

void main() {
  group('EditorState · assistance getters', () {
    test('offers require the current revision and cursor', () {
      expect(
        _state('Mi', [_item('Mientras')]).hasCurrentCompletionsAt(2),
        isTrue,
      );
      expect(
        _state('Mi', [_item('Mientras')]).hasCurrentCompletionsAt(1),
        isFalse,
      );
      expect(
        _state('Mi', [
          _item('Mientras', revision: 2),
        ]).hasCurrentCompletionsAt(2),
        isFalse,
      );
      expect(_state('Mi', const []).hasCurrentCompletionsAt(2), isFalse);
    });
    test('limits the popup to eight candidates', () {
      final items = [for (var index = 0; index < 12; index++) _item('c$index')];
      expect(_state('Mi', items).popupCandidates.length, 8);
      expect(_state('Mi', const []).popupCandidates, isEmpty);
    });

    test('measures the typed prefix from the replacement range', () {
      expect(_state('Mi', [_item('Mientras')]).completionPrefixLength, 2);
      expect(_state('', const []).completionPrefixLength, 0);
      expect(_state('', [_item('x', range: null)]).completionPrefixLength, 0);
    });

    test('ghost text is the untyped rest of the first template line', () {
      final state = _state('Mi', [
        _item(
          'Mientras',
          template: 'Mientras condicion Hacer\n  \nFinMientras',
          inline: true,
        ),
      ]);
      expect(state.inlineCandidate?.label, 'Mientras');
      expect(state.ghostText, 'entras condicion Hacer');
    });

    test(
      'assignment ghost text contains only the untyped operator and spacing',
      () {
        for (final typed in ['total', 'total ', 'total   ']) {
          final state = _state(typed, [
            _item(
              'total',
              template: 'total <- ',
              inline: true,
              range: CaretRange(start: 0, end: typed.length),
            ),
          ]);
          expect(state.ghostText, typed == 'total' ? ' <- ' : '<- ');
        }
      },
    );

    test(
      'ghost text is absent without an inline candidate or a matching prefix',
      () {
        expect(_state('Mi', [_item('Mientras')]).ghostText, isNull);
        expect(
          _state('fm', [_item('FinMientras', inline: true)]).ghostText,
          isNull,
        );
        expect(
          _state('Mientras', [
            _item(
              'Mientras',
              inline: true,
              range: const CaretRange(start: 0, end: 8),
            ),
          ]).ghostText,
          isNull,
        );
        expect(
          _state('M', [
            _item(
              'Mientras',
              inline: true,
              range: const CaretRange(start: 0, end: 9),
            ),
          ]).ghostText,
          isNull,
        );
      },
    );
  });
}
