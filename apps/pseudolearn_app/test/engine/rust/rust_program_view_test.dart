import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

void main() {
  test('decodes required fields and ignores unknown additive attributes', () {
    final result = RustProgramView.decode(
      _viewJson(
        nodes: [
          _node('rev.n0', unknownAttribute: {'future': true}),
        ],
      ),
      SourceOffsetIndex('x'),
    );

    expect(result, isA<RustProgramViewReadSuccess>());
    final view = (result as RustProgramViewReadSuccess).view;
    expect(view.revision, 'rev');
    expect(view.node('rev.n0')?.id, const ProgramNodeId(0));
    expect(view.nodeById(const ProgramNodeId(0))?.syntaxKind, 'identifier');
  });

  test('decodes an exact method signature span', () {
    final method = _node('rev.n0')
      ..['syntax_kind'] = 'method_member'
      ..['method_signature_span'] = _span('0', '1', 1, 1, 1, 2);
    final result = RustProgramView.decode(
      _viewJson(nodes: [method]),
      SourceOffsetIndex('x'),
    );

    expect(result, isA<RustProgramViewReadSuccess>());
    final view = (result as RustProgramViewReadSuccess).view;
    expect(view.node('rev.n0')?.signatureRange?.startOffset, 0);
    expect(view.node('rev.n0')?.signatureRange?.endOffset, 1);
  });

  test('rejects a method signature span outside its method node', () {
    final method = _node('rev.n0')
      ..['syntax_kind'] = 'method_member'
      ..['method_signature_span'] = _span('1', '2', 1, 2, 1, 3);

    expect(
      _failure(_viewJson(nodes: [method]), 'xy').kind,
      RustProgramViewReadFailureKind.invalidSpan,
    );
  });

  test('returns typed failures for absent and malformed required fields', () {
    final missingRevision = _viewJson(nodes: [_node('rev.n0')])
      ..remove('revision_id');
    final missingNodeKind = _viewJson(nodes: [_node('rev.n0')..remove('kind')]);

    expect(
      _failure(missingRevision, 'x').kind,
      RustProgramViewReadFailureKind.missingField,
    );
    expect(
      _failure(missingNodeKind, 'x').kind,
      RustProgramViewReadFailureKind.missingField,
    );
  });

  test('rejects references absent from the current view and source', () {
    final absent = _node('rev.n0')
      ..['child_node_ids'] = ['rev.n2']
      ..['child_roles'] = [
        {'node_id': 'rev.n2', 'role': 'child'},
      ];
    final foreign = _node('rev.n0')
      ..['child_node_ids'] = ['other.n0']
      ..['child_roles'] = [
        {'node_id': 'other.n0', 'role': 'child'},
      ];

    expect(
      _failure(_viewJson(nodes: [absent]), 'x').kind,
      RustProgramViewReadFailureKind.missingReference,
    );
    expect(
      _failure(_viewJson(nodes: [foreign]), 'x').kind,
      RustProgramViewReadFailureKind.foreignReference,
    );
  });

  test('checks Unicode scalar positions and original BOM offsets', () {
    final unicode = _node('rev.n0')..['span'] = _span('0', '4', 1, 1, 1, 2);
    final bom = _node('rev.n0')..['span'] = _span('3', '7', 1, 2, 1, 3);

    expect(
      RustProgramView.decode(
        _viewJson(nodes: [unicode]),
        SourceOffsetIndex('🧩'),
      ),
      isA<RustProgramViewReadSuccess>(),
    );
    expect(
      RustProgramView.decode(
        _viewJson(nodes: [bom]),
        SourceOffsetIndex('\uFEFF🧩'),
      ),
      isA<RustProgramViewReadSuccess>(),
    );
  });

  test('projects variant payloads with local ordinals', () {
    final construction = _node('rev.n0')
      ..['syntax_kind'] = 'variant_construction'
      ..['variant'] = 'some'
      ..['child_node_ids'] = ['rev.n1']
      ..['child_roles'] = [
        {'node_id': 'rev.n1', 'role': 'payload'},
      ];
    final result = RustProgramView.decode(
      _viewJson(nodes: [construction, _node('rev.n1')]),
      SourceOffsetIndex('x'),
    );

    expect(result, isA<RustProgramViewReadSuccess>());
    final view = (result as RustProgramViewReadSuccess).view;
    expect(view.staticData.variants.single.discriminant, 'some');
    expect(view.staticData.variants.single.payloadNodeIds, [
      const ProgramNodeId(1),
    ]);
  });

  test('decodes static relationships into typed local identities', () {
    final nodes = [
      _node('rev.n0')..['syntax_kind'] = 'class_unit',
      _node('rev.n1')..['syntax_kind'] = 'interface_unit',
      _node('rev.n2')..['syntax_kind'] = 'identifier',
      _node('rev.n3')
        ..['syntax_kind'] = 'type_parameter'
        ..['constraints'] = [
          {
            'interface_node_id': 'rev.n1',
            'target_node_id': 'rev.n2',
            'status': 'valid',
            'diagnostics': <Object?>[],
          },
        ],
      _node('rev.n4')
        ..['syntax_kind'] = 'variant_construction'
        ..['variant'] = 'success'
        ..['child_node_ids'] = ['rev.n5']
        ..['child_roles'] = [
          {'node_id': 'rev.n5', 'role': 'payload'},
        ],
      _node('rev.n5'),
      _node('rev.n6')
        ..['syntax_kind'] = 'function_literal'
        ..['captures'] = [
          {
            'origin_node_id': 'rev.n7',
            'binding_node_id': 'rev.n7',
            'mode': 'value',
          },
        ],
      _node('rev.n7'),
      _node('rev.n8')
        ..['syntax_kind'] = 'for_each_loop'
        ..['child_node_ids'] = ['rev.n9', 'rev.n10', 'rev.n11']
        ..['child_roles'] = [
          {'node_id': 'rev.n9', 'role': 'collection'},
          {'node_id': 'rev.n10', 'role': 'bindings'},
          {'node_id': 'rev.n11', 'role': 'body'},
        ]
        ..['iteration'] = {
          'collection_node_id': 'rev.n9',
          'bindings_node_id': 'rev.n10',
          'body_node_id': 'rev.n11',
          'scope_owner_node_id': 'rev.n8',
        },
      _node('rev.n9'),
      _node('rev.n10'),
      _node('rev.n11'),
    ];
    final json = _viewJson(nodes: nodes)
      ..['realizations'] = [
        {
          'class_node_id': 'rev.n0',
          'interface_node_id': 'rev.n1',
          'origin_node_id': 'rev.n0',
          'target_node_id': 'rev.n2',
          'origin': 'explicit',
          'status': 'valid',
          'diagnostics': <Object?>[],
        },
      ];
    final result = RustProgramView.decode(json, SourceOffsetIndex('x'));

    expect(result, isA<RustProgramViewReadSuccess>());
    final data = (result as RustProgramViewReadSuccess).view.staticData;
    expect(data.realizations.single.classNodeId, const ProgramNodeId(0));
    expect(data.constraints.single.interfaceNodeId, const ProgramNodeId(1));
    expect(data.variants.single.payloadNodeIds, [const ProgramNodeId(5)]);
    expect(data.captures.single.mode.name, 'value');
    expect(data.iterations.single.scopeOwnerNodeId, const ProgramNodeId(8));
    expect(data.scopes.single.ownerNodeId, const ProgramNodeId(8));
  });

  test(
    'returns typed failures for static references missing from the view',
    () {
      final json = _viewJson(nodes: [_node('rev.n0')])
        ..['realizations'] = [
          {
            'class_node_id': 'rev.n0',
            'interface_node_id': 'rev.n2',
            'origin_node_id': 'rev.n0',
            'target_node_id': 'rev.n2',
            'origin': 'explicit',
            'status': 'valid',
            'diagnostics': <Object?>[],
          },
        ];

      expect(
        _failure(json, 'x').kind,
        RustProgramViewReadFailureKind.missingReference,
      );
    },
  );

  test('returns typed failures for static references from another source', () {
    final json = _viewJson(nodes: [_node('rev.n0')])
      ..['realizations'] = [
        {
          'class_node_id': 'rev.n0',
          'interface_node_id': 'other.n1',
          'origin_node_id': 'rev.n0',
          'target_node_id': 'other.n1',
          'origin': 'explicit',
          'status': 'invalid',
          'diagnostics': ['unknownInterface'],
        },
      ];

    expect(
      _failure(json, 'x').kind,
      RustProgramViewReadFailureKind.foreignReference,
    );
  });
}

RustProgramViewReadFailure _failure(Map<String, Object?> json, String source) {
  final result = RustProgramView.decode(json, SourceOffsetIndex(source));
  return result as RustProgramViewReadFailure;
}

Map<String, Object?> _viewJson({required List<Object?> nodes}) => {
  'revision_id': 'rev',
  'child_order': 'source',
  'units': <Object?>[],
  'nodes': nodes,
  'inheritance': <Object?>[],
  'methods': <Object?>[],
  'members': <Object?>[],
};

Map<String, Object?> _node(String identifier, {Object? unknownAttribute}) => {
  'node_id': identifier,
  'kind': 'expression',
  'syntax_kind': 'identifier',
  'span': _span('0', '1', 1, 1, 1, 2),
  'child_node_ids': <Object?>[],
  'child_roles': <Object?>[],
  'future_attribute': unknownAttribute,
};

Map<String, Object?> _span(
  String startByte,
  String endByte,
  int startLine,
  int startColumn,
  int endLine,
  int endColumn,
) => {
  'start_byte': startByte,
  'end_byte': endByte,
  'start': {'line': startLine, 'column': startColumn},
  'end': {'line': endLine, 'column': endColumn},
};
