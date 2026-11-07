import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'content_engine.dart';

List<String> checkBlockCitedDiagnostics({
  required List<ContentBlock> blocks,
  required String contextName,
  required String languageCode,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final cited = citedCodesOf(blocks);
  if (cited.isEmpty) return const [];
  final produced = producedDiagnosticCodes(
    programs: programsOf(blocks),
    profileId: profileId,
    languageId: languageId,
  );
  final errors = <String>[];
  for (final code in cited) {
    if (produced.contains(code)) continue;
    errors.add(
      '$contextName ($languageCode) cites diagnostic "$code", but no program in '
      'that section produces it',
    );
  }
  return errors;
}

List<String> citedCodesOf(List<ContentBlock> blocks) {
  final codes = <String>[];
  for (final block in blocks) {
    if (block is DiagnosticBlock) codes.add(block.code);
    if (block is MarkerBlock) codes.add(block.resolvedText);
  }
  return codes;
}

List<String> programsOf(List<ContentBlock> blocks) {
  final programs = <String>[];
  for (final block in blocks) {
    if (block is CodeBlock) programs.add(block.code);
  }
  return programs;
}

Set<String> producedDiagnosticCodes({
  required List<String> programs,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final analyzer = contentEngine.analyzer;
  final codes = <String>{};
  for (final program in programs) {
    final report = analyzer.analyze(
      sourceCode: program,
      profileId: profileId,
      languageId: languageId,
    );
    for (final diagnostic in report.diagnostics) {
      codes.add(diagnostic.code);
    }
  }
  return codes;
}
