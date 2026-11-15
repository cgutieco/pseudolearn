import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/program/program_run_request.dart';
import '../../../domain/model/program/program_text_result.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../program/use_cases/check_program.dart';
import '../../program/use_cases/format_program.dart';
import '../../program/use_cases/run_program.dart';
import '../../program/use_cases/translate_program.dart';
import 'agent_tool.dart';
import 'program_payloads.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

Map<String, Map<String, Object?>> _programProperties(String profileDescription) => {
  'source': stringProperty('Complete PseudoLearn program.'),
  'profile': stringProperty(profileDescription, values: profileNames),
};

ToolExecution _textResult(ProgramTextResult result) => switch (result) {
  ProgramTextProduced(:final text) => ToolExecution.done({'source': text}),
  ProgramTextRefused(:final failure, :final detail) =>
    ToolExecution.failed(failure.name, detail: detail),
};

final class CheckProgramTool extends DirectTool {
  final CheckProgram _check;
  final UiLanguageId Function() _language;

  const CheckProgramTool(this._check, this._language);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'check_program',
    description:
        'Analyses a program with the PseudoLearn engine and returns its diagnostics. Call it on '
        'every program before showing it.',
    parameters: objectSchema(_programProperties('Syntax profile of the source.'), required: const ['source', 'profile']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepCheck',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final source = arguments.text('source');
    final profile = arguments.profile('profile');
    if (source == null || profile == null) return ToolExecution.failed('invalid_arguments');
    final report = _check(sourceCode: source, profileId: profile, languageId: _language());
    final payload = diagnosticsPayload(report);
    return ToolExecution.done(payload, summary: '${report.diagnostics.length}');
  }
}

final class RunProgramTool extends DirectTool {
  final RunProgram _run;
  final UiLanguageId Function() _language;

  const RunProgramTool(this._run, this._language);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'run_program',
    description:
        'Runs a program to the end without effects on files or network, feeding the given inputs '
        'in order. Use it to test a program against example cases.',
    parameters: objectSchema({
      ..._programProperties('Syntax profile of the source.'),
      'inputs': stringListProperty('Values returned by each read, in order.'),
      'arguments': stringListProperty('Program arguments.'),
      'step_limit': integerProperty('Maximum steps, up to 100000.'),
    }, required: const ['source', 'profile']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepRun',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final source = arguments.text('source');
    final profile = arguments.profile('profile');
    if (source == null || profile == null) return ToolExecution.failed('invalid_arguments');
    final report = _run(ProgramRunRequest(
      sourceCode: source,
      profileId: profile,
      languageId: _language(),
      inputs: arguments.texts('inputs') ?? const [],
      arguments: arguments.texts('arguments') ?? const [],
      stepLimit: arguments.integer('step_limit') ?? ProgramRunRequest.defaultStepLimit,
    ));
    return ToolExecution.done({
      'outcome': report.outcome.name,
      'outputs': report.outputs.length > 200 ? report.outputs.sublist(0, 200) : report.outputs,
      'errors': report.errors,
    }, summary: report.outcome.name);
  }
}

final class TranslateProgramTool extends DirectTool {
  final TranslateProgram _translate;

  const TranslateProgramTool(this._translate);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'translate_program',
    description: 'Translates a valid program to another syntax profile.',
    parameters: objectSchema({
      'source': stringProperty('Complete PseudoLearn program.'),
      'target_profile': stringProperty('Profile to translate to.', values: profileNames),
    }, required: const ['source', 'target_profile']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepTranslate',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final source = arguments.text('source');
    final target = arguments.profile('target_profile');
    if (source == null || target == null) return ToolExecution.failed('invalid_arguments');
    return _textResult(_translate(sourceCode: source, targetProfile: target));
  }
}

final class FormatProgramTool extends DirectTool {
  final FormatProgram _format;

  const FormatProgramTool(this._format);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'format_program',
    description: 'Returns the canonical formatting of a valid program.',
    parameters: objectSchema(_programProperties('Syntax profile of the source.'), required: const ['source', 'profile']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepFormat',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final source = arguments.text('source');
    final profile = arguments.profile('profile');
    if (source == null || profile == null) return ToolExecution.failed('invalid_arguments');
    return _textResult(_format(sourceCode: source, profileId: profile));
  }
}
