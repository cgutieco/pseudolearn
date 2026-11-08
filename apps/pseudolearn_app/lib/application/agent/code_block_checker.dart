import '../../domain/model/agent/code_block.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/reply_code_block_reader.dart';

final class CodeBlockChecker {
  final ReplyCodeBlockReader _reader;
  final ProgramAnalyzer _analyzer;

  const CodeBlockChecker({
    required ReplyCodeBlockReader reader,
    required ProgramAnalyzer analyzer,
  }) : _reader = reader,
       _analyzer = analyzer;

  List<CheckedCodeBlock> check(
    String reply, {
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) => [
    for (final block in _reader.read(reply)) _checked(block, profileId, languageId),
  ];

  CheckedCodeBlock _checked(CodeBlock block, SyntaxProfileId profileId, UiLanguageId languageId) {
    if (!block.isPseudoLearn) {
      return CheckedCodeBlock(block: block, verdict: CodeBlockVerdict.notPseudoLearn);
    }
    final report = _analyzer.analyze(sourceCode: block.source, profileId: profileId, languageId: languageId);
    final verified = report.isExecutable && !report.hasErrors;
    return CheckedCodeBlock(
      block: block,
      verdict: verified ? CodeBlockVerdict.verified : CodeBlockVerdict.withErrors,
      problems: [for (final diagnostic in report.diagnostics) diagnostic.message],
    );
  }
}
