import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_structure_cache.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../fakes/fake_rust_transport.dart';

FakeRustTransport _transport({
  List<Object?> diagnostics = const [],
  bool failsOnce = false,
}) {
  var failuresLeft = failsOnce ? 1 : 0;
  return FakeRustTransport({
    'create_analysis': (_) {
      if (failuresLeft > 0) {
        failuresLeft -= 1;
        throw const RustBridgeFailure(family: 'engine', detail: 'busy');
      }
      return {'document': 4, 'resource': 8};
    },
    'analysis': (_) => {'tree': true, 'diagnostics': diagnostics},
    'program_view': (_) => _view(),
    'release': (_) => const {},
  });
}

int _analyses(FakeRustTransport transport) =>
    transport.calls.where((call) => call == 'create_analysis').length;

void main() {
  test('the same program, profile and language is analysed once', () {
    final transport = _transport();
    final cache = RustProgramStructureCache(transport);

    final first = cache.loadStructure(
      sourceCode: 'x',
      profileId: SyntaxProfileId.classicSpanish,
    );
    final second = cache.loadStructure(
      sourceCode: 'x',
      profileId: SyntaxProfileId.classicSpanish,
    );

    expect(first, isNotNull);
    expect(identical(first, second), isTrue);
    expect(_analyses(transport), 1);
  });

  test('a different program, profile or language is analysed again', () {
    final transport = _transport();
    final cache = RustProgramStructureCache(transport);

    cache.loadStructure(sourceCode: 'x', profileId: SyntaxProfileId.english);
    cache.loadStructure(sourceCode: 'y', profileId: SyntaxProfileId.english);
    cache.loadStructure(
      sourceCode: 'y',
      profileId: SyntaxProfileId.classicSpanish,
    );
    cache.loadStructure(
      sourceCode: 'y',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.english,
    );

    expect(_analyses(transport), 4);
  });

  test('only the latest program is kept', () {
    final transport = _transport();
    final cache = RustProgramStructureCache(transport);

    cache.loadStructure(sourceCode: 'x', profileId: SyntaxProfileId.english);
    cache.loadStructure(sourceCode: 'y', profileId: SyntaxProfileId.english);
    cache.loadStructure(sourceCode: 'x', profileId: SyntaxProfileId.english);

    expect(_analyses(transport), 3);
  });

  test('a program with a syntax error is remembered as having no view', () {
    final transport = _transport(
      diagnostics: [
        {'severity': 'error', 'class': 'syntax', 'code': 'unexpectedToken'},
      ],
    );
    final cache = RustProgramStructureCache(transport);

    final first = cache.loadStructure(
      sourceCode: 'x <-',
      profileId: SyntaxProfileId.classicSpanish,
    );
    final second = cache.loadStructure(
      sourceCode: 'x <-',
      profileId: SyntaxProfileId.classicSpanish,
    );

    expect(first, isNull);
    expect(second, isNull);
    expect(_analyses(transport), 1);
  });

  test('a bridge failure is not remembered', () {
    final transport = _transport(failsOnce: true);
    final cache = RustProgramStructureCache(transport);

    final failed = cache.loadStructure(
      sourceCode: 'x',
      profileId: SyntaxProfileId.classicSpanish,
    );
    final retried = cache.loadStructure(
      sourceCode: 'x',
      profileId: SyntaxProfileId.classicSpanish,
    );

    expect(failed, isNull);
    expect(retried, isNotNull);
    expect(_analyses(transport), 2);
  });

  test('an empty program is cached like any other', () {
    final transport = _transport();
    final cache = RustProgramStructureCache(transport);

    cache.loadStructure(sourceCode: '', profileId: SyntaxProfileId.english);
    cache.loadStructure(sourceCode: '', profileId: SyntaxProfileId.english);

    expect(_analyses(transport), 1);
  });
}

Map<String, Object?> _view() => {
  'revision_id': 'rev',
  'child_order': 'source',
  'units': <Object?>[],
  'nodes': [
    {
      'node_id': 'rev.n0',
      'kind': 'expression',
      'syntax_kind': 'identifier',
      'span': {
        'start_byte': '0',
        'end_byte': '0',
        'start': {'line': 1, 'column': 1},
        'end': {'line': 1, 'column': 1},
      },
      'child_node_ids': <Object?>[],
      'child_roles': <Object?>[],
    },
  ],
  'inheritance': <Object?>[],
  'methods': <Object?>[],
  'members': <Object?>[],
};
