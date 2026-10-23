import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_syntax_help_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../fakes/fake_rust_transport.dart';

const _source = 'Algoritmo P\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n';

Map<String, Object?> _range(int line, int start, int end) => {
  'start': {'line': line, 'column': start},
  'end': {'line': line, 'column': end},
};

Map<String, Object?> _response({
  Object? resolution,
  Object? help,
  Object? card,
}) => {'resolution': resolution, 'help': help, 'card': card};

FakeRustTransport _transport(
  Map<String, Object?> Function(Map<String, Object?>) query, {
  List<Map<String, Object?>>? queries,
}) => FakeRustTransport({
  'open_edit_session': (_) => {'resource': 9, 'revision': '1'},
  'help_query': (arguments) {
    queries?.add(arguments);
    return query(arguments);
  },
  'release': (_) => <String, Object?>{},
});

HelpQueryResult _ask(
  FakeRustTransport transport, {
  int cursor = 16,
  String source = _source,
  UiLanguageId language = UiLanguageId.english,
}) => RustSyntaxHelpSource(transport).query(
  sourceCode: source,
  profileId: SyntaxProfileId.classicSpanish,
  languageId: language,
  cursorUtf16: cursor,
  revision: 3,
);

void main() {
  group('RustSyntaxHelpSource', () {
    test('sends UTF-16 line and column with the interface language', () {
      final queries = <Map<String, Object?>>[];
      final transport = _transport(
        (_) => _response(),
        queries: queries,
      );
      _ask(transport);
      expect(queries.single['position'], {
        'line': 2,
        'column': 5,
        'unit': 'utf16',
      });
      expect(queries.single['language'], 'en');
      expect(queries.single['detail'], 'full');
      expect(queries.single['resource'], 9);
    });

    test('projects the card, description and range back to UTF-16', () {
      final transport = _transport(
        (_) => _response(
          resolution: {
            'identity': {'kind': 'construction', 'id': 'while', 'role': 'x'},
            'certainty': 'certain',
            'lexical_range': _range(2, 3, 11),
          },
          help: {
            'category': 'keyword',
            'identifier': 'Mientras',
            'description': 'Starts a loop.',
          },
          card: {
            'id': 'help.while',
            'title': 'While loop',
            'summary': 'Repeats.',
            'purpose': 'Checks first.',
            'parts': [
              {'identity': 'whileKeyword', 'text': 'Starts.'},
            ],
            'constraints': <Object?>[],
            'common_errors': <Object?>[],
            'examples': [
              {
                'specification': 'LANG.CONTROL.WHILE',
                'version': '1.0.0',
                'case': 'C1',
                'profile': 'en',
                'strictness': 'estricto',
                'kind': 'executable',
                'label': 'Runs',
              },
            ],
          },
        ),
      );
      final result = _ask(transport);
      expect(result.outcome, HelpOutcome.help);
      expect(result.revision, 3);
      expect(result.help?.range.start, 14);
      expect(result.help?.range.end, 22);
      expect(result.help?.card?.title, 'While loop');
      expect(result.help?.card?.examples.single.caseId, 'C1');
      expect(result.help?.description, 'Starts a loop.');
      expect(result.help?.headline, 'Mientras');
    });

    test('service columns are Unicode scalars, converted to UTF-16 offsets', () {
      final transport = _transport(
        (_) => _response(
          resolution: {
            'identity': {'kind': 'keyword', 'id': 'x', 'role': 'keyword'},
            'certainty': 'certain',
            'lexical_range': _range(1, 5, 7),
          },
        ),
      );
      final result = _ask(transport, source: 'a"🧩" bc', cursor: 6);
      expect(result.help?.range.start, 5);
      expect(result.help?.range.end, 7);
    });

    test('reports partial certainty and user symbols distinctly', () {
      final transport = _transport(
        (_) => _response(
          resolution: {
            'symbol': {'category': 'variable', 'identifier': 'x'},
            'certainty': 'partial',
            'lexical_range': _range(2, 3, 4),
          },
          help: {'category': 'variable', 'identifier': 'x', 'type_name': 'Entero'},
        ),
      );
      final result = _ask(transport);
      expect(result.outcome, HelpOutcome.symbol);
      expect(result.help?.isPartial, isTrue);
      expect(result.help?.headline, 'x: Entero');
      expect(result.help?.card, isNull);
    });

    test('a missing resolution is no help, not a failure', () {
      final result = _ask(_transport((_) => _response()));
      expect(result.outcome, HelpOutcome.noHelp);
    });

    test('rejects a cursor inside a surrogate pair without a request', () {
      final transport = _transport((_) => _response());
      final result = _ask(transport, source: 'a🧩b', cursor: 2);
      expect(result.outcome, HelpOutcome.invalidPosition);
      expect(transport.calls, isEmpty);
    });

    test('maps usage and internal failures to different outcomes', () {
      final usage = _transport(
        (_) => throw const RustBridgeFailure(family: 'usage', detail: 'x'),
      );
      expect(_ask(usage).outcome, HelpOutcome.invalidPosition);
      final broken = _transport(
        (_) => throw const RustBridgeFailure(family: 'internal', detail: 'x'),
      );
      expect(_ask(broken).outcome, HelpOutcome.failure);
      final malformed = _transport((_) => throw StateError('shape'));
      expect(_ask(malformed).outcome, HelpOutcome.failure);
    });

    test('always releases the session it opened', () {
      final transport = _transport(
        (_) => throw const RustBridgeFailure(family: 'internal', detail: 'x'),
      );
      _ask(transport);
      expect(transport.calls, ['open_edit_session', 'help_query', 'release']);
    });

    test('an unresolvable range is a failure', () {
      final transport = _transport(
        (_) => _response(
          resolution: {
            'identity': {'kind': 'keyword', 'id': 'x', 'role': 'keyword'},
            'certainty': 'certain',
            'lexical_range': _range(99, 1, 2),
          },
        ),
      );
      expect(_ask(transport).outcome, HelpOutcome.failure);
    });
  });
}
