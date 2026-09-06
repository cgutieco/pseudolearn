import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/program_execution.dart';

base class FakeProgramExecution implements ProgramExecution {
  List<OutputLine> outputLinesList;
  List<ExecutionStep> steps;
  int currentStepIndex = 0;
  bool isStopped = false;

  FakeProgramExecution({
    this.outputLinesList = const [],
    this.steps = const [],
  });

  @override
  List<OutputLine> get outputLines => outputLinesList;

  @override
  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    currentStepIndex = 0;
    isStopped = false;
    if (steps.isEmpty) {
      return const ExecutionStep(
        stepNumber: 1,
        scopeName: 'global',
        scopeDepth: 1,
      );
    }
    return steps[0];
  }

  @override
  ExecutionStep step() {
    if (currentStepIndex + 1 < steps.length) {
      currentStepIndex++;
      return steps[currentStepIndex];
    }
    return const ExecutionStep(
      stepNumber: 999,
      scopeName: 'global',
      scopeDepth: 1,
      isFinished: true,
    );
  }

  @override
  ExecutionStep provideInput(String rawInput) {
    return step();
  }

  @override
  void stop() {
    isStopped = true;
  }
}
