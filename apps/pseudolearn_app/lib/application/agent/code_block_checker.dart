import '../../domain/model/agent/code_block.dart';
import '../../domain/model/agent/reply_block.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/reply_markdown_reader.dart';
import 'highlight/code_language_catalog.dart';
import 'highlight/lexical_highlighter.dart';

final class CheckedReply {
  final List<ReplyBlock> blocks;
  final List<CheckedCodeBlock> codeBlocks;

  const CheckedReply({required this.blocks, required this.codeBlocks});
}

final class CodeBlockChecker {
  final ReplyMarkdownReader _reader;
  final ProgramAnalyzer _analyzer;

  const CodeBlockChecker({
    required ReplyMarkdownReader reader,
    required ProgramAnalyzer analyzer,
  }) : _reader = reader,
       _analyzer = analyzer;

  CheckedReply check(
    String reply, {
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final document = _reader.read(reply);
    return CheckedReply(
      blocks: document.blocks,
      codeBlocks: [for (final block in document.codeBlocks) _checked(block, profileId, languageId)],
    );
  }

  CheckedCodeBlock _checked(CodeBlock block, SyntaxProfileId profileId, UiLanguageId languageId) {
    if (!block.isPseudoLearn) {
      return CheckedCodeBlock(
        block: block,
        verdict: CodeBlockVerdict.notPseudoLearn,
        highlightSpans: highlightLexically(block.source, codeLanguageNamed(block.language)),
      );
    }
    final report = _analyzer.analyze(sourceCode: block.source, profileId: profileId, languageId: languageId);
    final verified = report.isExecutable && !report.hasErrors;
    return CheckedCodeBlock(
      block: block,
      verdict: verified ? CodeBlockVerdict.verified : CodeBlockVerdict.withErrors,
      problems: [for (final diagnostic in report.diagnostics) diagnostic.message],
      highlightSpans: report.highlightSpans,
    );
  }
}
