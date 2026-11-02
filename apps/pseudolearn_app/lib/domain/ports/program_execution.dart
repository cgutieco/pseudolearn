import '../model/execution/effect_settlement.dart';
import '../model/execution/effect_tape.dart';
import '../model/execution/execution_step.dart';
import '../model/execution/input_wait.dart';
import '../model/execution/output_line.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';
import '../model/execution/simulated_scenario.dart';

abstract interface class ProgramExecution {
  List<OutputLine> get outputLines;

  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    SimulatedScenario? scenario,
    EffectTape? replayTape,
  });

  ExecutionStep step();
  ExecutionStep provideInput(InputWait request, String rawInput);
  ExecutionStep settleEffect(EffectSettlement settlement);
  void stop();
}
