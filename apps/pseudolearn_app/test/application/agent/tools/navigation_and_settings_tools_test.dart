import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/tools/document_editing_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/navigation_and_settings_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_arguments.dart';
import 'package:pseudolearn_app/application/library/use_cases/load_document.dart';
import 'package:pseudolearn_app/application/library/use_cases/save_document_source.dart';
import 'package:pseudolearn_app/application/program/use_cases/check_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/translate_program.dart';
import 'package:pseudolearn_app/application/settings/preference_updates.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/application/settings/use_cases/set_interface_language.dart';
import 'package:pseudolearn_app/application/settings/use_cases/set_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/app_navigator.dart';
import '../../../fakes/document_fixtures.dart';
import '../../../fakes/fake_clock.dart';
import '../../../fakes/in_memory_document_repository.dart';
import '../../../fakes/in_memory_preferences_store.dart';
import '../../../fakes/native_test_engine.dart';

final class _Navigator implements AppNavigator {
  final List<String> visited = [];

  @override
  bool canNavigate(String location) => location.startsWith('/biblioteca');

  @override
  void navigate(String location) => visited.add(location);
}

void main() {
  test('navigate opens known locations only', () async {
    final navigator = _Navigator();
    final tool = NavigateTool(navigator);
    expect((await tool.run(const ToolArguments({'location': '/biblioteca'}))).succeeded, isTrue);
    expect((await tool.run(const ToolArguments({'location': '/afuera'}))).output['error'], 'unknown_location');
    expect((await tool.run(const ToolArguments({}))).output['error'], 'unknown_location');
    expect(navigator.visited, ['/biblioteca']);
  });

  test('theme and language changes reach the settings cubit', () async {
    final preferences = InMemoryPreferencesStore();
    final updates = PreferenceUpdates();
    final settings = SettingsCubit(preferences: preferences, updates: updates);
    final theme = SetThemeTool(SetThemeMode(preferences: preferences, updates: updates));
    final language = SetInterfaceLanguageTool(SetInterfaceLanguage(preferences: preferences, updates: updates));
    await theme.run(const ToolArguments({'theme': 'dark'}));
    await language.run(const ToolArguments({'language': 'english'}));
    await Future<void>.delayed(Duration.zero);
    expect(settings.state.themeMode, AppThemeMode.dark);
    expect(settings.state.language, UiLanguageId.english);
    expect((await theme.run(const ToolArguments({'theme': 'neon'}))).output['error'], 'invalid_arguments');
    expect((await language.run(const ToolArguments({}))).output['error'], 'invalid_arguments');
    await settings.close();
  });

  test('set profile translates and saves with the new profile, after confirmation', () async {
    final repository = InMemoryDocumentRepository()
      ..documents['doc-1'] = documentFixture(content: 'Algoritmo P\n  Escribir 1;\nFinAlgoritmo\n');
    final load = LoadDocument(repository: repository);
    final tool = SetProfileTool(
      load,
      TranslateProgram(translator: nativeTestEngine.programTools.translator),
      DocumentSourceWriter(
        load: load,
        save: SaveDocumentSource(repository: repository, clock: FakeClock()),
        check: CheckProgram(analyzer: nativeTestEngine.analyzer),
        language: () => UiLanguageId.spanish,
      ),
    );
    expect(tool.needsConfirmation(const ToolArguments({})), isTrue);
    final result = await tool.run(const ToolArguments({'document_id': 'doc-1', 'profile': 'english'}));
    expect(result.output['executable'], isTrue);
    expect(repository.documents['doc-1']!.profileId, SyntaxProfileId.english);
    expect((await tool.run(const ToolArguments({'document_id': 'no', 'profile': 'english'}))).output['error'], 'notFound');
  });
}
