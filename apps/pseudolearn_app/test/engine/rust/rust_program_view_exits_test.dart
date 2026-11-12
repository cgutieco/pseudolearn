import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_view_control_exit.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

Map<String, Object?> _view(List<Map<String, Object?>> nodes) => {
  'revision_id': 'rev',
  'child_order': 'source',
  'units': <Object?>[],
  'nodes': nodes,
  'inheritance': <Object?>[],
  'methods': <Object?>[],
  'members': <Object?>[],
};

Map<String, Object?> _node(String identifier, String syntaxKind) => {
  'node_id': identifier,
  'kind': 'statement',
  'syntax_kind': syntaxKind,
  'span': {
    'start_byte': '0',
    'end_byte': '1',
    'start': {'line': 1, 'column': 1},
    'end': {'line': 1, 'column': 2},
  },
  'child_node_ids': <Object?>[],
  'child_roles': <Object?>[],
};

List<Map<String, Object?>> _nodes({Object? exit, Object? cleanups}) => [
  _node('rev.n0', 'for_loop'),
  _node('rev.n1', 'body')..['normal_cleanups'] = cleanups ?? ['rev.n2'],
  _node('rev.n2', 'defer_statement')..['cleanup_scope_node_id'] = 'rev.n1',
  _node('rev.n3', 'break_statement')
    ..['control_exit'] =
        exit ??
        {
          'kind': 'break',
          'target_node_id': 'rev.n0',
          'cleanups': ['rev.n2'],
        },
];

RustProgramViewReadResult _decode(List<Map<String, Object?>> nodes) =>
    RustProgramView.decode(_view(nodes), SourceOffsetIndex('x'));

RustProgramViewReadFailureKind _failureOf(List<Map<String, Object?>> nodes) =>
    (_decode(nodes) as RustProgramViewReadFailure).kind;

void main() {
  group('control exits and cleanup scopes in the public view', () {
    test('decodes exits and normal cleanups with local ordinals', () {
      final view = (_decode(_nodes()) as RustProgramViewReadSuccess).view;
      final exit = view.staticData.exits.single;
      final scope = view.staticData.cleanupScopes.single;

      expect(exit.exitNodeId, const ProgramNodeId(3));
      expect(exit.kind, ProgramViewExitKind.breakLoop);
      expect(exit.targetNodeId, const ProgramNodeId(0));
      expect(exit.cleanupNodeIds, [const ProgramNodeId(2)]);
      expect(scope.bodyNodeId, const ProgramNodeId(1));
      expect(scope.cleanupNodeIds, [const ProgramNodeId(2)]);
    });

    test('an exit without a valid target keeps a null target', () {
      final view = (_decode(
        _nodes(exit: {'kind': 'break', 'target_node_id': null, 'cleanups': <Object?>[]}),
      ) as RustProgramViewReadSuccess).view;

      expect(view.staticData.exits.single.targetNodeId, isNull);
      expect(view.staticData.exits.single.cleanupNodeIds, isEmpty);
    });

    test('a view without exit attributes has no exits', () {
      final view = (_decode([_node('rev.n0', 'body')]) as RustProgramViewReadSuccess).view;

      expect(view.staticData.exits, isEmpty);
      expect(view.staticData.cleanupScopes, isEmpty);
    });

    test('an unknown exit kind is a malformed field', () {
      expect(
        _failureOf(_nodes(exit: {'kind': 'continue', 'cleanups': <Object?>[]})),
        RustProgramViewReadFailureKind.malformedField,
      );
    });

    test('an exit that is not an object is rejected', () {
      expect(
        _failureOf(_nodes(exit: 'break')),
        isNot(RustProgramViewReadFailureKind.missingReference),
      );
    });

    test('cleanups must be a list of known nodes of the same view', () {
      expect(
        _failureOf(_nodes(exit: {'kind': 'return', 'cleanups': 'rev.n2'})),
        RustProgramViewReadFailureKind.malformedField,
      );
      expect(
        _failureOf(_nodes(cleanups: ['rev.n9'])),
        RustProgramViewReadFailureKind.missingReference,
      );
      expect(
        _failureOf(_nodes(cleanups: ['other.n2'])),
        RustProgramViewReadFailureKind.foreignReference,
      );
    });

    test('a target outside the view is a missing reference', () {
      expect(
        _failureOf(
          _nodes(exit: {'kind': 'break', 'target_node_id': 'rev.n7', 'cleanups': <Object?>[]}),
        ),
        RustProgramViewReadFailureKind.missingReference,
      );
    });
  });
}
