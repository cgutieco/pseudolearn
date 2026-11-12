import '../../../domain/model/help/help_program.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/program_analyzer.dart';

final class HelpProgramHighlighter {
  final ProgramAnalyzer _analyzer;

  const HelpProgramHighlighter(this._analyzer);

  HelpQueryResult highlight(
    HelpQueryResult result, {
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final help = result.help;
    final card = help?.card;
    if (help == null || card == null) return result;
    HelpProgram paint(HelpProgram program) => program.highlighted(
      _analyzer
          .analyze(
            sourceCode: program.source,
            profileId: profileId,
            languageId: languageId,
          )
          .highlightSpans,
    );
    final highlighted = card.withPrograms(
      commonErrors: [
        for (final error in card.commonErrors)
          error.withProgram(_mapOptional(error.program, paint)),
      ],
      examples: [
        for (final example in card.examples)
          example.withProgram(paint(example.program)),
      ],
    );
    return result.withHelp(help.withCard(highlighted));
  }
}

HelpProgram? _mapOptional(
  HelpProgram? program,
  HelpProgram Function(HelpProgram) paint,
) => program == null ? null : paint(program);
