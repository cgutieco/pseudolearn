import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/model/program/program_text_result.dart';
import '../../../domain/model/settings/app_theme_mode.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/app_navigator.dart';
import '../../library/use_cases/load_document.dart';
import '../../program/use_cases/translate_program.dart';
import '../../settings/use_cases/set_interface_language.dart';
import '../../settings/use_cases/set_theme_mode.dart';
import 'agent_tool.dart';
import 'document_editing_tools.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class NavigateTool extends DirectTool {
  final AppNavigator _navigator;

  const NavigateTool(this._navigator);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'navigate',
    description:
        'Opens a screen of the app. Use the routes of the app manual index, replacing :id, '
        ':leccion and :ejercicio with real ids.',
    parameters: objectSchema({'location': stringProperty('App location starting with /.')}, required: const ['location']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepNavigate',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final location = arguments.text('location');
    if (location == null || !_navigator.canNavigate(location)) {
      return ToolExecution.failed('unknown_location');
    }
    _navigator.navigate(location);
    return ToolExecution.done({'location': location}, summary: location);
  }
}

final class SetThemeTool extends DirectTool {
  final SetThemeMode _set;

  const SetThemeTool(this._set);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'set_theme',
    description: 'Changes the app theme.',
    parameters: objectSchema({
      'theme': stringProperty('Theme.', values: [for (final mode in AppThemeMode.values) mode.name]),
    }, required: const ['theme']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepTheme',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final name = arguments.text('theme');
    for (final mode in AppThemeMode.values) {
      if (mode.name == name) {
        await _set(mode);
        return ToolExecution.done({'theme': name}, summary: name ?? '');
      }
    }
    return ToolExecution.failed('invalid_arguments');
  }
}

final class SetInterfaceLanguageTool extends DirectTool {
  final SetInterfaceLanguage _set;

  const SetInterfaceLanguageTool(this._set);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'set_interface_language',
    description: 'Changes the interface language. It does not change any document profile.',
    parameters: objectSchema({
      'language': stringProperty('Language.', values: [for (final language in UiLanguageId.values) language.name]),
    }, required: const ['language']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepLanguage',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final name = arguments.text('language');
    for (final language in UiLanguageId.values) {
      if (language.name == name) {
        await _set(language);
        return ToolExecution.done({'language': name}, summary: name ?? '');
      }
    }
    return ToolExecution.failed('invalid_arguments');
  }
}

final class SetProfileTool extends ConfirmedTool {
  final LoadDocument _load;
  final TranslateProgram _translate;
  final DocumentSourceWriter _writer;

  const SetProfileTool(this._load, this._translate, this._writer);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'set_profile',
    description:
        'Translates an algorithm to another syntax profile and saves it with that profile. The '
        'whole source changes, so the person confirms first.',
    parameters: objectSchema({
      'document_id': stringProperty('Document id.'),
      'profile': stringProperty('Target profile.', values: profileNames),
    }, required: const ['document_id', 'profile']),
    risk: ToolRisk.write,
    stepLabel: 'agentStepProfile',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final id = arguments.text('document_id');
    final profile = arguments.profile('profile');
    if (id == null || profile == null) return ToolExecution.failed('invalid_arguments');
    final loaded = await _load(id);
    if (loaded is! DocumentCommandSucceeded) return ToolExecution.failed('notFound');
    final translated = _translate(sourceCode: loaded.document.content, targetProfile: profile);
    if (translated is! ProgramTextProduced) return ToolExecution.failed('translation_rejected');
    return _writer.write(loaded.document.copyWith(profileId: profile), translated.text);
  }
}
