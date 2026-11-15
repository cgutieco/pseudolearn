import '../profiles/syntax_profile_id.dart';
import '../settings/ui_language_id.dart';

final class ProgramRunRequest {
  static const int defaultStepLimit = 10000;
  static const int maximumStepLimit = 100000;

  final String sourceCode;
  final SyntaxProfileId profileId;
  final UiLanguageId languageId;
  final List<String> inputs;
  final List<String> arguments;
  final int stepLimit;

  const ProgramRunRequest({
    required this.sourceCode,
    required this.profileId,
    required this.languageId,
    this.inputs = const [],
    this.arguments = const [],
    this.stepLimit = defaultStepLimit,
  });

  int get boundedStepLimit => stepLimit < 1
      ? 1
      : (stepLimit > maximumStepLimit ? maximumStepLimit : stepLimit);
}
