import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/member_visibility.dart';
import '../../domain/model/knowledge/structural_assertion.dart';
import '../../domain/model/knowledge/structural_assertion_kind.dart';

List<StructuralAssertion>? readStructuralAssertions(Object? raw) {
  if (raw == null) return const [];
  if (raw is! List) return null;
  final assertions = <StructuralAssertion>[];
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) return null;
    final assertion = _assertionOf(entry);
    if (assertion == null) return null;
    assertions.add(assertion);
  }
  return assertions;
}

StructuralAssertion? _assertionOf(Map<String, dynamic> entry) {
  final kind = StructuralAssertionKind.fromSlug(entry['kind'] as String? ?? '');
  final requirement = entry['requirement'] as String? ?? '';
  if (kind == null || requirement.trim().isEmpty) return null;
  return switch (kind) {
    StructuralAssertionKind.containsConstruct => _contains(entry, requirement),
    StructuralAssertionKind.omitsConstruct => _omits(entry, requirement),
    StructuralAssertionKind.declaresSubprogram =>
      _subprogram(entry, requirement),
    StructuralAssertionKind.declaresClassMember =>
      _classMember(entry, requirement),
    StructuralAssertionKind.repeatsAtMost => _repeatsAtMost(entry, requirement),
  };
}

StructuralAssertion? _contains(Map<String, dynamic> entry, String requirement) {
  final construct = _constructOf(entry);
  if (construct == null) return null;
  return ContainsConstructAssertion(
    requirement: requirement,
    construct: construct,
  );
}

StructuralAssertion? _omits(Map<String, dynamic> entry, String requirement) {
  final construct = _constructOf(entry);
  if (construct == null) return null;
  return OmitsConstructAssertion(
    requirement: requirement,
    construct: construct,
  );
}

StructuralAssertion? _subprogram(
    Map<String, dynamic> entry, String requirement) {
  final name = entry['name'] as String? ?? '';
  final arity = entry['arity'] as int?;
  if (name.trim().isEmpty || arity == null || arity < 0) return null;
  return DeclaresSubprogramAssertion(
    requirement: requirement,
    name: name,
    arity: arity,
  );
}

StructuralAssertion? _classMember(
    Map<String, dynamic> entry, String requirement) {
  final className = entry['class'] as String? ?? '';
  final memberName = entry['member'] as String? ?? '';
  final visibility =
      MemberVisibility.fromSlug(entry['visibility'] as String? ?? '');
  if (className.trim().isEmpty ||
      memberName.trim().isEmpty ||
      visibility == null) {
    return null;
  }
  return DeclaresClassMemberAssertion(
    requirement: requirement,
    className: className,
    memberName: memberName,
    visibility: visibility,
  );
}

StructuralAssertion? _repeatsAtMost(
    Map<String, dynamic> entry, String requirement) {
  final construct = _constructOf(entry);
  final maxOccurrences = entry['max'] as int?;
  if (construct == null || maxOccurrences == null || maxOccurrences < 0) {
    return null;
  }
  return RepeatsAtMostAssertion(
    requirement: requirement,
    construct: construct,
    maxOccurrences: maxOccurrences,
  );
}

AstConstruct? _constructOf(Map<String, dynamic> entry) {
  return AstConstruct.fromSlug(entry['construct'] as String? ?? '');
}
