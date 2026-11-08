import '../../domain/model/knowledge/structural_assertion.dart';

Map<String, Object?> writeStructuralAssertion(StructuralAssertion assertion) => {
  'kind': assertion.kind.slug,
  'requirement': assertion.requirement,
  ...switch (assertion) {
    ContainsConstructAssertion(:final construct) => {'construct': construct.slug},
    OmitsConstructAssertion(:final construct) => {'construct': construct.slug},
    DeclaresSubprogramAssertion(:final name, :final arity) => {
      'name': name,
      'arity': arity,
    },
    DeclaresClassMemberAssertion(
      :final className,
      :final memberName,
      :final visibility,
    ) =>
      {'class': className, 'member': memberName, 'visibility': visibility.slug},
    RepeatsAtMostAssertion(:final construct, :final maxOccurrences) => {
      'construct': construct.slug,
      'max': maxOccurrences,
    },
  },
};
