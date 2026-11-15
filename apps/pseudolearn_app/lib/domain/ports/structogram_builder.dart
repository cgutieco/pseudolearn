import '../model/diagram/diagram_program.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class StructogramBuilder {
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });
}
