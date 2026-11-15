import '../model/profiles/syntax_profile_id.dart';
import '../model/program/program_text_result.dart';

abstract interface class ProgramTranslator {
  ProgramTextResult translate({
    required String sourceCode,
    required SyntaxProfileId targetProfile,
  });
}
