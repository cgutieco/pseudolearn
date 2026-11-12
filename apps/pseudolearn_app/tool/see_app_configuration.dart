import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Future<Map<String, Object?>> runConfigurationScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final cubit = ExecutionCubit(execution: RustProgramExecution(transport));
  try {
    final profile = input['profile'] == 'en'
        ? SyntaxProfileId.english
        : SyntaxProfileId.classicSpanish;
    const configuration = ExecutionConfiguration(documentId: 'scenario');
    await _advance(cubit, input['program'] as String, profile, configuration);
    final changed = input['replay_program'] as String?;
    if (input['replay'] != true) return _outcome(cubit.state);
    await _advance(
      cubit,
      changed ?? input['program'] as String,
      profile,
      configuration,
      replay: true,
    );
    return {
      ..._outcome(cubit.state),
      if (cubit.state.replayRejection case final rejection?)
        'rejection': rejection.name,
    };
  } finally {
    await cubit.close();
  }
}

Future<void> _advance(
  ExecutionCubit cubit,
  String program,
  SyntaxProfileId profile,
  ExecutionConfiguration configuration, {
  bool replay = false,
}) => cubit.advance(
  pace: StepPace.toEnd,
  sourceCode: program,
  profileId: profile,
  languageId: UiLanguageId.english,
  configuration: configuration,
  replay: replay,
);

Map<String, Object?> _outcome(ExecutionState state) => {
  'termination': switch (state.status) {
    ExecutionStatus.finishedSuccess => 'completed',
    ExecutionStatus.haltedWithError => 'failed',
    _ => 'not_started',
  },
  'output': state.outputLines.map((line) => '${line.text}\n').join(),
};
