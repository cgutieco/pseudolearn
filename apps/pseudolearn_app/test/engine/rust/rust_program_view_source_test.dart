import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';

import '../../fakes/fake_rust_transport.dart';

void main() {
  test('transmits the original text and explicit profile configuration', () {
    const source = '\uFEFFalgorithm Main\nwrite "🧩";\nendAlgorithm\n';
    Map<String, Object?>? received;
    final transport = FakeRustTransport({
      'create_analysis': (arguments) {
        received = arguments;
        return {'document': 4, 'resource': 8};
      },
      'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
      'program_view': (_) => _view(),
      'release': (_) => const {},
    });

    final result = RustProgramViewSource(transport).loadResult(
      sourceCode: source,
      profileId: SyntaxProfileId.english,
      languageId: UiLanguageId.english,
    );

    expect(result, isA<RustProgramViewReadSuccess>());
    expect(received, {'program': source, 'profile': 'en', 'locale': 'en'});
    expect(transport.calls, [
      'create_analysis',
      'analysis',
      'program_view',
      'release',
    ]);
  });

  test('returns the decoder failure as a typed result', () {
    final transport = FakeRustTransport({
      'create_analysis': (_) => {'document': 4, 'resource': 8},
      'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
      'program_view': (_) => _view()..remove('revision_id'),
      'release': (_) => const {},
    });

    final result = RustProgramViewSource(
      transport,
    ).loadResult(sourceCode: 'x', profileId: SyntaxProfileId.classicSpanish);

    expect(result, isA<RustProgramViewReadFailure>());
    expect(
      (result as RustProgramViewReadFailure).kind,
      RustProgramViewReadFailureKind.missingField,
    );
  });

  test('returns malformed analysis payloads as typed failures', () {
    final transport = FakeRustTransport({
      'create_analysis': (_) => {'document': 4, 'resource': 8},
      'analysis': (_) => {
        'tree': true,
        'diagnostics': [false],
      },
      'release': (_) => const {},
    });

    final result = RustProgramViewSource(
      transport,
    ).loadResult(sourceCode: 'x', profileId: SyntaxProfileId.classicSpanish);

    expect(result, isA<RustProgramViewReadFailure>());
    expect(
      (result as RustProgramViewReadFailure).kind,
      RustProgramViewReadFailureKind.malformedField,
    );
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
      'future_metadata': 'ignored',
    },
  ],
  'inheritance': <Object?>[],
  'methods': <Object?>[],
  'members': <Object?>[],
};
