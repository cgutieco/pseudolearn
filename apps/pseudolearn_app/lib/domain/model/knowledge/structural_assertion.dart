import 'ast_construct.dart';
import 'member_visibility.dart';
import 'structural_assertion_kind.dart';

sealed class StructuralAssertion {
  final String requirement;

  const StructuralAssertion({required this.requirement});

  StructuralAssertionKind get kind;
}

final class ContainsConstructAssertion extends StructuralAssertion {
  final AstConstruct construct;

  const ContainsConstructAssertion({
    required super.requirement,
    required this.construct,
  });

  @override
  StructuralAssertionKind get kind => StructuralAssertionKind.containsConstruct;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainsConstructAssertion &&
          runtimeType == other.runtimeType &&
          requirement == other.requirement &&
          construct == other.construct;

  @override
  int get hashCode => Object.hash(requirement, construct);
}

final class OmitsConstructAssertion extends StructuralAssertion {
  final AstConstruct construct;

  const OmitsConstructAssertion({
    required super.requirement,
    required this.construct,
  });

  @override
  StructuralAssertionKind get kind => StructuralAssertionKind.omitsConstruct;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OmitsConstructAssertion &&
          runtimeType == other.runtimeType &&
          requirement == other.requirement &&
          construct == other.construct;

  @override
  int get hashCode => Object.hash(requirement, construct);
}

final class DeclaresSubprogramAssertion extends StructuralAssertion {
  final String name;
  final int arity;

  const DeclaresSubprogramAssertion({
    required super.requirement,
    required this.name,
    required this.arity,
  });

  @override
  StructuralAssertionKind get kind =>
      StructuralAssertionKind.declaresSubprogram;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeclaresSubprogramAssertion &&
          runtimeType == other.runtimeType &&
          requirement == other.requirement &&
          name == other.name &&
          arity == other.arity;

  @override
  int get hashCode => Object.hash(requirement, name, arity);
}

final class DeclaresClassMemberAssertion extends StructuralAssertion {
  final String className;
  final String memberName;
  final MemberVisibility visibility;

  const DeclaresClassMemberAssertion({
    required super.requirement,
    required this.className,
    required this.memberName,
    required this.visibility,
  });

  @override
  StructuralAssertionKind get kind =>
      StructuralAssertionKind.declaresClassMember;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeclaresClassMemberAssertion &&
          runtimeType == other.runtimeType &&
          requirement == other.requirement &&
          className == other.className &&
          memberName == other.memberName &&
          visibility == other.visibility;

  @override
  int get hashCode =>
      Object.hash(requirement, className, memberName, visibility);
}

final class RepeatsAtMostAssertion extends StructuralAssertion {
  final AstConstruct construct;
  final int maxOccurrences;

  const RepeatsAtMostAssertion({
    required super.requirement,
    required this.construct,
    required this.maxOccurrences,
  });

  @override
  StructuralAssertionKind get kind => StructuralAssertionKind.repeatsAtMost;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatsAtMostAssertion &&
          runtimeType == other.runtimeType &&
          requirement == other.requirement &&
          construct == other.construct &&
          maxOccurrences == other.maxOccurrences;

  @override
  int get hashCode => Object.hash(requirement, construct, maxOccurrences);
}
