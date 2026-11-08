import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/program/program_text_result.dart';
import '../../../domain/ports/program_translator.dart';

final class TranslateProgram {
  final ProgramTranslator _translator;

  const TranslateProgram({required ProgramTranslator translator})
    : _translator = translator;

  ProgramTextResult call({
    required String sourceCode,
    required SyntaxProfileId targetProfile,
  }) {
    try {
      return _translator.translate(
        sourceCode: sourceCode,
        targetProfile: targetProfile,
      );
    } catch (error) {
      return ProgramTextRefused(ProgramTextFailure.rejected, detail: '$error');
    }
  }
}
