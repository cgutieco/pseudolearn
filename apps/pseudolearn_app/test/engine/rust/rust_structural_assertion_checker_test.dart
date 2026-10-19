import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_structural_assertion_checker.dart';

import '../../fakes/fake_rust_transport.dart';

Map<String, Object?> _span(
  int startLine,
  int startColumn,
  int endLine,
  int endColumn,
) => {
  'start': {'line': startLine, 'column': startColumn},
  'end': {'line': endLine, 'column': endColumn},
};

Map<String, Object?> _node(String id, String kind, List<String> children) => {
  'node_id': id,
  'kind': 'declaration',
  'syntax_kind': kind,
  'span': {
    'start': {'line': 1, 'column': 1},
    'end': {'line': 2, 'column': 13},
  },
  'child_node_ids': children,
  'child_roles': [
    for (final child in children) {'node_id': child, 'role': 'parameters'},
  ],
};

void main() {
  test('counts parameters through the public parameter group', () {
    final transport = FakeRustTransport({
      'create_analysis': (_) => {'resource': 2, 'document': 1},
      'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
      'program_view': (_) => {
        'revision_id': 'r1',
        'units': [
          {
            'kind': 'subprogram',
            'name': 'f',
            'order': 0,
            'node_id': 'r1.n0',
            'span': _span(1, 1, 2, 13),
          },
        ],
        'nodes': [
          _node('r1.n0', 'subroutine', ['r1.n1']),
          _node('r1.n1', 'parameters', ['r1.n2', 'r1.n3']),
          _node('r1.n2', 'parameter', const []),
          _node('r1.n3', 'parameter', const []),
        ],
        'members': <Object?>[],
        'inheritance': <Object?>[],
      },
      'release': (_) => null,
    });
    const assertion = DeclaresSubprogramAssertion(
      requirement: 'declares two inputs',
      name: 'f',
      arity: 2,
    );
    final unmet = RustStructuralAssertionChecker(transport).unmetAssertions(
      sourceCode: 'Subrutina f(a, b)\nFinSubrutina',
      profileId: SyntaxProfileId.classicSpanish,
      assertions: const [assertion],
    );
    expect(unmet, isEmpty);
    expect(transport.calls, [
      'create_analysis',
      'analysis',
      'program_view',
      'release',
    ]);
  });
}
