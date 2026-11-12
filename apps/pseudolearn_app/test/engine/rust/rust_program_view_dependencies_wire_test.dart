import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';

import '../../fakes/fake_rust_transport.dart';

const String _source = 'Importar geo.Punto Como P;\n';

Map<String, Object?> _dependency() => {
  'dependency_id': 'rev.d0',
  'order': 0,
  'kind': 'import',
  'visibility': 'local',
  'path': ['geo', 'Punto'],
  'alias': 'P',
  'status': 'unlinked',
  'diagnostic': 'moduleSyntaxOutsideProject',
  'span': {
    'start_byte': '0',
    'end_byte': '26',
    'start': {'line': 1, 'column': 1},
    'end': {'line': 1, 'column': 27},
  },
};

Map<String, Object?> _view(Object? dependencies) => {
  'revision_id': 'rev',
  'child_order': 'source',
  'units': <Object?>[],
  'nodes': <Object?>[],
  'inheritance': <Object?>[],
  'methods': <Object?>[],
  'members': <Object?>[],
  'dependencies': ?dependencies,
};

RustProgramViewReadResult _load(Map<String, Object?> view) {
  final transport = FakeRustTransport({
    'create_analysis': (_) => {'document': 4, 'resource': 8},
    'analysis': (_) => {
      'tree': true,
      'diagnostics': [
        {
          'code': 'moduleSyntaxOutsideProject',
          'class': 'syntax',
          'severity': 'error',
        },
      ],
    },
    'program_view': (_) => view,
    'release': (_) => const {},
  });
  return RustProgramViewSource(transport).loadResult(
    sourceCode: _source,
    profileId: SyntaxProfileId.classicSpanish,
    rejects: (_) => false,
  );
}

RustProgramViewReadFailureKind? _failureOf(RustProgramViewReadResult result) =>
    result is RustProgramViewReadFailure ? result.kind : null;

void main() {
  test('decodes a scripted dependency row', () {
    final result = _load(_view([_dependency()]));

    final dependency = result.view!.dependencies.single;
    expect(dependency.id, 'rev.d0');
    expect(dependency.qualifiedPath, 'geo.Punto');
    expect(dependency.range.endOffset, 26);
  });

  test('an absent dependencies list means none', () {
    expect(_load(_view(null)).view!.dependencies, isEmpty);
  });

  test('a mistyped dependencies list is a typed failure', () {
    expect(
      _failureOf(_load(_view('geo'))),
      RustProgramViewReadFailureKind.malformedField,
    );
  });

  test('a row with an unknown status is a typed failure', () {
    final row = _dependency()..['status'] = 'resolved';

    expect(
      _failureOf(_load(_view([row]))),
      RustProgramViewReadFailureKind.malformedField,
    );
  });

  test('a row without a path is a typed failure', () {
    final row = _dependency()..remove('path');

    expect(_failureOf(_load(_view([row]))), isNotNull);
  });

  test('a row with a malformed alias is a typed failure', () {
    final row = _dependency()..['alias'] = 3;

    expect(
      _failureOf(_load(_view([row]))),
      RustProgramViewReadFailureKind.malformedField,
    );
  });

  test('a row with an invalid span is a typed failure', () {
    final row = _dependency()..['span'] = {'start': 1};

    expect(_failureOf(_load(_view([row]))), isNotNull);
  });
}
