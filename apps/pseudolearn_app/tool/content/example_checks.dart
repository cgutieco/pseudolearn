import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';
import 'content_engine.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'loaded_content.dart';

List<String> checkExampleParses({
  required String exampleId,
  required String sourceCode,
  required SyntaxProfileId profile,
  required String languageCode,
}) {
  final analysis = contentEngine.analyzer.analyze(
    sourceCode: sourceCode,
    profileId: profile,
    languageId: UiLanguageId.english,
  );
  final errors = <String>[];
  for (final diagnostic in analysis.diagnostics) {
    if (diagnostic.severity.name != 'error') continue;
    errors.add(
      'Example "$exampleId" ($languageCode) does not analyse cleanly: '
      '${diagnostic.code}',
    );
  }
  return errors;
}

List<String> checkExamplesShareShape({
  required LoadedLanguage a,
  required LoadedLanguage b,
  required SyntaxProfileId profileA,
  required SyntaxProfileId profileB,
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

String shapeOf(String sourceCode, SyntaxProfileId profile) {
  final view = RustProgramViewSource(
    contentTransport,
  ).load(sourceCode: sourceCode, profileId: profile);
  if (view == null) return '';
  final buffer = StringBuffer();
  for (final node in view.nodes) {
    buffer.write('${node.syntaxKind}(');
    buffer.write(node.children.length);
    buffer.write(')');
  }
  return buffer.toString();
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
    errors.add(
      'Example "$id" (${language.code}) is declared but never referenced',
    );
  }
  return errors;
}

List<String> checkSpecificationExamplesMinimal(LoadedLanguage language) {
  final errors = <String>[];
  final specOnly = language.specificationExampleIds.difference(
    language.moduleExampleIds,
  );
  for (final id in specOnly) {
    final source = language.exampleSources[id];
    if (source == null) continue;
    final nonBlankLines = source
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .length;
    if (nonBlankLines > 12) {
      errors.add(
        'Specification example "$id" (${language.code}) has $nonBlankLines non-empty lines, '
        'exceeding the limit of 12',
      );
    }
  }
  return errors;
}
