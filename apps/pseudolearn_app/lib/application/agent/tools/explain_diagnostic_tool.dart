import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/help/help_program.dart';
import '../../../domain/model/help/help_query_result.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/syntax_help_source.dart';
import 'agent_tool.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class ExplainDiagnosticTool extends DirectTool {
  final SyntaxHelpSource _help;
  final UiLanguageId Function() _language;

  const ExplainDiagnosticTool(this._help, this._language);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'explain_diagnostic',
    description:
        'Returns the editor help card for the construct at an offset of a program: what it is, its '
        'form, rules and common errors. Use the offset of a diagnostic from check_program.',
    parameters: objectSchema({
      'source': stringProperty('Complete PseudoLearn program.'),
      'profile': stringProperty('Syntax profile.', values: profileNames),
      'offset': integerProperty('UTF-16 offset inside the source.'),
    }, required: const ['source', 'profile', 'offset']),
    risk: ToolRisk.read,
    stepLabel: 'agentStepExplain',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final source = arguments.text('source');
    final profile = arguments.profile('profile');
    final offset = arguments.integer('offset');
    if (source == null || profile == null || offset == null) {
      return ToolExecution.failed('invalid_arguments');
    }
    final result = _help.query(
      sourceCode: source,
      profileId: profile,
      languageId: _language(),
      cursorUtf16: offset.clamp(0, source.length),
      revision: 0,
    );
    final help = result.help;
    if (result.outcome == HelpOutcome.failure || help == null) {
      return ToolExecution.failed('no_help', detail: result.outcome.name);
    }
    final card = help.card;
    return ToolExecution.done({
      'headline': help.headline,
      'description': help.description,
      'summary': card?.summary,
      'rules': card?.rules ?? const <String>[],
      'common_errors': [for (final error in card?.commonErrors ?? const <HelpCommonError>[]) error.text],
    });
  }
}
