import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/completion/assist_result.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_edit_assist_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../fakes/fake_rust_transport.dart';

const _profile = SyntaxProfileId.classicSpanish;

Map<String, Object?> _opened() => {'resource': 7, 'revision': '1'};

Map<String, Object?> _appliedEdit(String revision, {bool active = false}) => {
  'revision': revision,
  'template_active': active,
};

void main() {
  group('RustEditAssistSource', () {
    test('opens one session and synchronizes later texts as edits', () {
      final requests = <String, Map<String, Object?>>{};
      final transport = FakeRustTransport({
        'open_edit_session': (arguments) {
          requests['open'] = arguments;
          return _opened();
        },
        'apply_edit': (arguments) {
          requests['apply'] = arguments;
          return _appliedEdit('2');
        },
        'edit_on_type': (arguments) {
          requests['type'] = arguments;
          return {
            'revision': '2',
            'template_active': false,
            'edits': <Object?>[],
            'cursor_utf8': '2',
          };
        },
      });
      final source = RustEditAssistSource(transport);
      source.afterTyping(
        sourceCode: 'ab',
        profileId: _profile,
        cursorUtf16: 2,
        character: 'b',
      );
      final result = source.afterTyping(
        sourceCode: 'abc',
        profileId: _profile,
        cursorUtf16: 3,
        character: 'c',
      );
      expect(
        transport.calls.where((call) => call == 'open_edit_session').length,
        1,
      );
      expect(requests['open']!['strictness'], 'flexible');
      final edits = requests['apply']!['edits'] as List<Object?>;
      expect(edits.single, {'start_utf8': '2', 'end_utf8': '2', 'text': 'c'});
      expect(requests['apply']!['revision'], '2');
      expect(result, isNotNull);
      expect(result!.sourceCode, 'abc');
      expect(result.selection, const CaretRange.collapsed(3));
    });

    test('an empty character only synchronizes the session', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) => _opened(),
      });
      final result = RustEditAssistSource(transport).afterTyping(
        sourceCode: 'ab',
        profileId: _profile,
        cursorUtf16: 1,
        character: '',
      );
      expect(
        result,
        const AssistResult(
          sourceCode: 'ab',
          selection: CaretRange.collapsed(1),
          templateActive: false,
        ),
      );
      expect(transport.calls, ['open_edit_session']);
    });

    test('applies on_type edits in UTF-16 and moves the caret', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) => _opened(),
        'edit_on_type': (_) => {
          'revision': '2',
          'template_active': false,
          'edits': [
            {'start_utf8': '7', 'end_utf8': '7', 'text': ')'},
          ],
          'cursor_utf8': '7',
        },
      });
      final result = RustEditAssistSource(transport).afterTyping(
        sourceCode: '🧩 f(',
        profileId: _profile,
        cursorUtf16: 5,
        character: '(',
      );
      expect(result!.sourceCode, '🧩 f()');
      expect(result.selection, const CaretRange.collapsed(5));
    });

    test('accept applies the insertion and reports the selected stop', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) => _opened(),
        'edit_complete': (_) => {
          'revision': '1',
          'candidates': [
            {'id': '0', 'label': 'Escribir'},
            {'id': '1', 'label': 'Mientras'},
          ],
        },
        'edit_accept': (arguments) {
          expect(arguments['candidate_id'], '1');
          return {
            'revision': '2',
            'template_active': true,
            'edit': {
              'start_utf8': '0',
              'end_utf8': '3',
              'text': 'Mientras c Hacer',
            },
            'selection': {'start_utf8': '9', 'end_utf8': '10'},
          };
        },
      });
      final result = RustEditAssistSource(transport).accept(
        sourceCode: 'Mie',
        profileId: _profile,
        replacement: const CaretRange(start: 0, end: 3),
        label: 'Mientras',
      );
      expect(result!.sourceCode, 'Mientras c Hacer');
      expect(result.selection, const CaretRange(start: 9, end: 10));
      expect(result.templateActive, isTrue);
    });

    test('accept returns null for a label the service no longer offers', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) => _opened(),
        'edit_complete': (_) => {'revision': '1', 'candidates': <Object?>[]},
      });
      final result = RustEditAssistSource(transport).accept(
        sourceCode: 'Mie',
        profileId: _profile,
        replacement: const CaretRange(start: 0, end: 3),
        label: 'Mientras',
      );
      expect(result, isNull);
    });

    test('a stale revision releases the session and the next call reopens', () {
      var opens = 0;
      final transport = FakeRustTransport({
        'open_edit_session': (_) {
          opens++;
          return _opened();
        },
        'apply_edit': (_) => {'stale_revision': '5'},
        'release': (_) => null,
      });
      final source = RustEditAssistSource(transport);
      source.afterTyping(
        sourceCode: 'a',
        profileId: _profile,
        cursorUtf16: 1,
        character: '',
      );
      final stale = source.afterTyping(
        sourceCode: 'ab',
        profileId: _profile,
        cursorUtf16: 2,
        character: '',
      );
      expect(stale, isNull);
      expect(transport.calls, contains('release'));
      source.afterTyping(
        sourceCode: 'ab',
        profileId: _profile,
        cursorUtf16: 2,
        character: '',
      );
      expect(opens, 2);
    });

    test('a bridge failure yields null and never throws', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) =>
            throw const RustBridgeFailure(family: 'internal', detail: 'boom'),
      });
      final result = RustEditAssistSource(transport).insertTemplate(
        sourceCode: '',
        profileId: _profile,
        construction: 'if',
        replacement: const CaretRange.collapsed(0),
      );
      expect(result, isNull);
    });

    test('rejects a cursor inside a surrogate pair without editing', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) => _opened(),
      });
      final result = RustEditAssistSource(transport).afterTyping(
        sourceCode: 'a🧩',
        profileId: _profile,
        cursorUtf16: 2,
        character: '(',
      );
      expect(result, isNull);
      expect(transport.calls, ['open_edit_session']);
    });

    test(
      'navigate needs an active template and closes the session on exit',
      () {
        final transport = FakeRustTransport({
          'open_edit_session': (_) => _opened(),
        });
        final source = RustEditAssistSource(transport);
        final idle = source.navigate(
          sourceCode: 'x',
          profileId: _profile,
          direction: StopDirection.next,
        );
        expect(idle, isNull);
      },
    );

    test('changing the profile reopens the session', () {
      var opens = 0;
      final transport = FakeRustTransport({
        'open_edit_session': (_) {
          opens++;
          return _opened();
        },
        'release': (_) => null,
      });
      final source = RustEditAssistSource(transport);
      source.afterTyping(
        sourceCode: 'a',
        profileId: _profile,
        cursorUtf16: 1,
        character: '',
      );
      source.afterTyping(
        sourceCode: 'a',
        profileId: SyntaxProfileId.english,
        cursorUtf16: 1,
        character: '',
      );
      expect(opens, 2);
    });

    test('close releases the open session once', () {
      final transport = FakeRustTransport({
        'open_edit_session': (_) => _opened(),
        'release': (_) => null,
      });
      final source = RustEditAssistSource(transport);
      source.afterTyping(
        sourceCode: 'a',
        profileId: _profile,
        cursorUtf16: 1,
        character: '',
      );
      source
        ..close()
        ..close();
      expect(transport.calls.where((call) => call == 'release').length, 1);
    });
  });
}
