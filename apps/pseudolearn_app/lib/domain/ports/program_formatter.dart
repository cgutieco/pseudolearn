import '../model/profiles/syntax_profile_id.dart';
import '../model/program/program_text_result.dart';

abstract interface class ProgramFormatter {
  ProgramTextResult format({
    required String sourceCode,
    required SyntaxProfileId profileId,
  });
}
