import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/member_visibility.dart';
import '../../domain/model/knowledge/structural_assertion.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import 'rust_construct_projection.dart';
import 'rust_program_view.dart';
import 'rust_program_view_source.dart';
import 'rust_transport.dart';

final class RustStructuralAssertionChecker {
  final RustProgramViewSource _views;

  RustStructuralAssertionChecker(RustTransport transport)
    : _views = RustProgramViewSource(transport);

  List<StructuralAssertion> unmetAssertions({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required List<StructuralAssertion> assertions,
  }) {
    if (assertions.isEmpty) return const [];
    final view = _views.load(sourceCode: sourceCode, profileId: profileId);
    if (view == null) return List.unmodifiable(assertions);
    final counts = _constructCounts(view);
    return [
      for (final assertion in assertions)
        if (!_satisfies(assertion, view, counts)) assertion,
    ];
  }

  Map<AstConstruct, int> _constructCounts(RustProgramView view) {
    final counts = <AstConstruct, int>{};
    for (final node in view.nodes) {
      final construct = rustConstructOf(node.syntaxKind);
      if (construct != null) {
        counts.update(construct, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  bool _satisfies(
    StructuralAssertion assertion,
    RustProgramView view,
    Map<AstConstruct, int> counts,
  ) => switch (assertion) {
    ContainsConstructAssertion(:final construct) =>
      (counts[construct] ?? 0) > 0,
    OmitsConstructAssertion(:final construct) => (counts[construct] ?? 0) == 0,
    DeclaresSubprogramAssertion(:final name, :final arity) =>
      _declaresSubprogram(view, name, arity),
    DeclaresClassMemberAssertion(
      :final className,
      :final memberName,
      :final visibility,
    ) =>
      _declaresClassMember(
        view: view,
        className: className,
        memberName: memberName,
        visibility: visibility,
      ),
    RepeatsAtMostAssertion(:final construct, :final maxOccurrences) =>
      (counts[construct] ?? 0) <= maxOccurrences,
  };

  bool _declaresSubprogram(RustProgramView view, String name, int arity) {
    for (final unit in view.units) {
      if (unit.kind != 'subprogram' || unit.name != name) continue;
      final node = view.nodeById(unit.nodeId);
      if (node == null) continue;
      final parameterGroups = rustChildrenOf(
        view,
        node,
      ).where((child) => child.syntaxKind == 'parameters');
      final parameterCount = parameterGroups.fold<int>(
        0,
        (count, group) =>
            count +
            rustChildrenOf(
              view,
              group,
            ).where((child) => child.syntaxKind == 'parameter').length,
      );
      if (parameterCount == arity) return true;
    }
    return false;
  }

  bool _declaresClassMember({
    required RustProgramView view,
    required String className,
    required String memberName,
    required MemberVisibility visibility,
  }) => view.members.any(
    (member) =>
        member.className == className &&
        member.name == memberName &&
        member.visibility == _visibilityName(visibility),
  );

  String _visibilityName(MemberVisibility visibility) => switch (visibility) {
    MemberVisibility.publicMember => 'public',
    MemberVisibility.privateMember => 'private',
  };
}
