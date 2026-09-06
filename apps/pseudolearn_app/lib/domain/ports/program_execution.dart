import '../model/execution/execution_step.dart';
import '../model/execution/output_line.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class ProgramExecution {
  List<OutputLine> get outputLines;

  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });

  ExecutionStep step();
  ExecutionStep provideInput(String rawInput);
  void stop();
}
