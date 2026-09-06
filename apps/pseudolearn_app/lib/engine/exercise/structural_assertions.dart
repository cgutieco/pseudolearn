import '../../domain/model/knowledge/structural_assertion.dart';
import '../../domain/model/knowledge/structural_assertion_kind.dart';
import 'program_structure.dart';

typedef StructuralAssertionEvaluator = bool Function(
  StructuralAssertion assertion,
  ProgramStructure structure,
);

const Map<StructuralAssertionKind, StructuralAssertionEvaluator>
    structuralAssertionCatalog = {
  StructuralAssertionKind.containsConstruct: satisfiesContainsConstruct,
  StructuralAssertionKind.omitsConstruct: satisfiesOmitsConstruct,
  StructuralAssertionKind.declaresSubprogram: satisfiesDeclaresSubprogram,
  StructuralAssertionKind.declaresClassMember: satisfiesDeclaresClassMember,
  StructuralAssertionKind.repeatsAtMost: satisfiesRepeatsAtMost,
};

bool satisfiesContainsConstruct(
  StructuralAssertion assertion,
  ProgramStructure structure,
) {
  final required = assertion as ContainsConstructAssertion;
  return structure.occurrencesOf(required.construct) > 0;
}

bool satisfiesOmitsConstruct(
  StructuralAssertion assertion,
  ProgramStructure structure,
) {
  final forbidden = assertion as OmitsConstructAssertion;
  return structure.occurrencesOf(forbidden.construct) == 0;
}

bool satisfiesDeclaresSubprogram(
  StructuralAssertion assertion,
  ProgramStructure structure,
) {
  final required = assertion as DeclaresSubprogramAssertion;
  return structure.declaresSubprogram(required.name, required.arity);
}

bool satisfiesDeclaresClassMember(
  StructuralAssertion assertion,
  ProgramStructure structure,
) {
  final required = assertion as DeclaresClassMemberAssertion;
  return structure.declaresClassMember(
    className: required.className,
    memberName: required.memberName,
    visibility: required.visibility,
  );
}

bool satisfiesRepeatsAtMost(
  StructuralAssertion assertion,
  ProgramStructure structure,
) {
  final limit = assertion as RepeatsAtMostAssertion;
  return structure.occurrencesOf(limit.construct) <= limit.maxOccurrences;
}
