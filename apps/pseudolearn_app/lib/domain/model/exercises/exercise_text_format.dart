import '../knowledge/ast_construct.dart';
import '../knowledge/exercise_case.dart';
import '../knowledge/expected_value_kind.dart';
import '../knowledge/structural_assertion.dart';

const String caseArrow = '=>';
const String valueSeparator = ';';

List<String> linesOf(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty) line.trim(),
];

List<ExerciseCase>? parseCases(String text) {
  final cases = <ExerciseCase>[];
  for (final line in linesOf(text)) {
    final arrow = line.indexOf(caseArrow);
    if (arrow < 0) return null;
    final expected = _values(line.substring(arrow + caseArrow.length));
    if (expected.isEmpty) return null;
    cases.add(ExerciseCase(
      inputs: _values(line.substring(0, arrow)),
      expectedOutputs: expected,
      expectedValueKind: expected.every((value) => num.tryParse(value) != null)
          ? ExpectedValueKind.numeric
          : ExpectedValueKind.text,
    ));
  }
  return cases;
}

String formatCases(List<ExerciseCase> cases) => [
  for (final item in cases)
    '${item.inputs.join('$valueSeparator ')} $caseArrow ${item.expectedOutputs.join('$valueSeparator ')}',
].join('\n');

List<StructuralAssertion>? parseAssertions(String text) {
  final assertions = <StructuralAssertion>[];
  for (final line in linesOf(text)) {
    final assertion = _assertionOf(line);
    if (assertion == null) return null;
    assertions.add(assertion);
  }
  return assertions;
}

String formatAssertions(List<StructuralAssertion> assertions) => [
  for (final assertion in assertions) _formatAssertion(assertion),
].join('\n');

List<String> _values(String text) => [
  for (final value in text.split(valueSeparator))
    if (value.trim().isNotEmpty) value.trim(),
];

StructuralAssertion? _assertionOf(String line) {
  final colon = line.indexOf(':');
  if (colon < 0) return null;
  final kind = line.substring(0, colon).trim();
  final argument = line.substring(colon + 1).trim();
  final slash = argument.indexOf('/');
  final head = slash < 0 ? argument : argument.substring(0, slash).trim();
  final count = slash < 0 ? null : int.tryParse(argument.substring(slash + 1).trim());
  final construct = AstConstruct.fromSlug(head);
  return switch (kind) {
    'contiene' when construct != null =>
      ContainsConstructAssertion(requirement: line, construct: construct),
    'no-contiene' when construct != null =>
      OmitsConstructAssertion(requirement: line, construct: construct),
    'repite-como-mucho' when construct != null && count != null && count >= 0 =>
      RepeatsAtMostAssertion(requirement: line, construct: construct, maxOccurrences: count),
    'subprograma' when head.isNotEmpty && count != null && count >= 0 =>
      DeclaresSubprogramAssertion(requirement: line, name: head, arity: count),
    _ => null,
  };
}

String _formatAssertion(StructuralAssertion assertion) => switch (assertion) {
  ContainsConstructAssertion(:final construct) => 'contiene: ${construct.slug}',
  OmitsConstructAssertion(:final construct) => 'no-contiene: ${construct.slug}',
  RepeatsAtMostAssertion(:final construct, :final maxOccurrences) =>
    'repite-como-mucho: ${construct.slug}/$maxOccurrences',
  DeclaresSubprogramAssertion(:final name, :final arity) => 'subprograma: $name/$arity',
  DeclaresClassMemberAssertion(:final requirement) => requirement,
};
