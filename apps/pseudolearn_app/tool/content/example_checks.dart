import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'loaded_content.dart';

List<String> checkExampleParses({
  required String exampleId,
  required String sourceCode,
  required LanguageProfile profile,
  required String languageCode,
}) {
  final analysis = _analyze(sourceCode, profile);
  final errors = <String>[];
  for (final diagnostic in analysis.diagnostics) {
    if (diagnostic.severity != Severity.error) continue;
    errors.add(
      'Example "$exampleId" ($languageCode) does not analyse cleanly: '
      '${diagnostic.code.name}',
    );
  }
  return errors;
}

List<String> checkExamplesShareShape({
  required LoadedLanguage a,
  required LoadedLanguage b,
  required LanguageProfile profileA,
  required LanguageProfile profileB,
}) {
  final errors = <String>[];
  for (final id in a.exampleSources.keys) {
    final other = b.exampleSources[id];
    if (other == null) continue;
    final shapeA = shapeOf(a.exampleSources[id]!, profileA);
    final shapeB = shapeOf(other, profileB);
    if (shapeA == shapeB && shapeA.isNotEmpty) continue;
    errors.add(
      'Example "$id" does not produce the same tree shape in "${a.code}" and '
      '"${b.code}"',
    );
  }
  return errors;
}

String shapeOf(String sourceCode, LanguageProfile profile) {
  final unit = _analyze(sourceCode, profile).unit;
  if (unit == null) return '';
  final buffer = StringBuffer();
  _writeShape(unit, buffer);
  return buffer.toString();
}

void _writeShape(AstNode node, StringBuffer buffer) {
  buffer.write(node.runtimeType);
  buffer.write('(');
  for (final child in getChildNodes(node)) {
    _writeShape(child, buffer);
  }
  buffer.write(')');
}

Set<String> exampleIdsOf(List<KnowledgeEntry> entries) {
  final ids = <String>{};
  for (final entry in entries) {
    if (entry.type == KnowledgeEntryType.example) ids.add(entry.id);
  }
  return ids;
}

const Set<String> exemptExamples = {'example-guided-demo'};

List<String> checkExamplesReferenced(LoadedLanguage language) {
  final declared = exampleIdsOf(language.entries);
  final referenced = {
    ...language.moduleExampleIds,
    ...language.specificationExampleIds,
  };
  final errors = <String>[];
  for (final id in declared.difference(referenced).difference(exemptExamples)) {
    errors.add('Example "$id" (${language.code}) is declared but never referenced');
  }
  return errors;
}

List<String> checkSpecificationExamplesMinimal(LoadedLanguage language) {
  final errors = <String>[];
  final specOnly =
      language.specificationExampleIds.difference(language.moduleExampleIds);
  for (final id in specOnly) {
    final source = language.exampleSources[id];
    if (source == null) continue;
    final nonBlankLines =
        source.split('\n').where((l) => l.trim().isNotEmpty).length;
    if (nonBlankLines > 12) {
      errors.add(
        'Specification example "$id" (${language.code}) has $nonBlankLines non-empty lines, '
        'exceeding the limit of 12',
      );
    }
  }
  return errors;
}

final class _Analysis {
  final SourceUnitNode? unit;
  final List<Diagnostic> diagnostics;

  const _Analysis({required this.unit, required this.diagnostics});
}

_Analysis _analyze(String sourceCode, LanguageProfile profile) {
  final lexerResult = Lexer(profile).tokenize(sourceCode);
  final parseResult = Parser(profile: profile).parse(TokenStream(lexerResult.tokens));
  final syntax = [...lexerResult.diagnostics, ...parseResult.diagnostics];
  final unit = parseResult.program;
  if (unit == null || syntax.any((d) => d.severity == Severity.error)) {
    return _Analysis(unit: null, diagnostics: syntax);
  }
  final resolution = NameResolver(profile: profile).resolve(unit);
  final typeCheck = TypeChecker(resolution: resolution, profile: profile).check(unit);
  return _Analysis(
    unit: unit,
    diagnostics: [...syntax, ...resolution.diagnostics, ...typeCheck.diagnostics],
  );
}
