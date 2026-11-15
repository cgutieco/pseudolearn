import '../application/exercises/use_cases/create_user_exercise.dart';
import '../application/exercises/use_cases/delete_user_exercise.dart';
import '../application/exercises/use_cases/update_user_exercise.dart';
import '../application/library/use_cases/create_document.dart';
import '../application/library/use_cases/delete_document.dart';
import '../application/library/use_cases/list_documents.dart';
import '../application/library/use_cases/load_document.dart';
import '../application/library/use_cases/rename_document.dart';
import '../application/library/use_cases/save_document_source.dart';
import '../application/library/use_cases/set_execution_arguments.dart';
import '../application/program/use_cases/check_program.dart';
import '../application/program/use_cases/format_program.dart';
import '../application/program/use_cases/run_program.dart';
import '../application/program/use_cases/translate_program.dart';
import '../application/settings/preference_updates.dart';
import '../application/settings/use_cases/set_interface_language.dart';
import '../application/settings/use_cases/set_theme_mode.dart';
import '../domain/model/reference/reference_edition.dart';
import '../domain/model/settings/ui_language_id.dart';
import '../domain/ports/active_exercise_source.dart';
import '../domain/ports/app_navigator.dart';
import '../domain/ports/assisted_progress_store.dart';
import '../domain/ports/knowledge_index.dart';
import '../domain/ports/local_progress_store.dart';
import '../domain/ports/route_repository.dart';
import '../domain/ports/screen_context_source.dart';
import '../domain/ports/syntax_help_source.dart';
import '../domain/ports/user_exercise_repository.dart';
import 'app_dependencies.dart';
import 'user_exercise_providers.dart';

final class AgentWiring {
  final ScreenContextSource screen;
  final ActiveExerciseSource activeExercise;
  final AppNavigator navigator;
  final PreferenceUpdates updates;
  final UiLanguageId Function() language;
  final ReferenceEdition Function() edition;

  const AgentWiring({
    required this.screen,
    required this.activeExercise,
    required this.navigator,
    required this.updates,
    required this.language,
    required this.edition,
  });
}

final class AgentUseCases {
  final AppDependencies _dependencies;
  final AgentWiring _wiring;

  const AgentUseCases(this._dependencies, this._wiring);

  ScreenContextSource get screen => _wiring.screen;
  ActiveExerciseSource get activeExercise => _wiring.activeExercise;
  AppNavigator get navigator => _wiring.navigator;
  UiLanguageId Function() get language => _wiring.language;
  ReferenceEdition Function() get edition => _wiring.edition;
  String Function() get languageCode => () => _wiring.language().resolveLocaleCode(null);
  KnowledgeIndex get knowledge => _dependencies.agent.knowledgeIndex;
  AssistedProgressStore get assisted => _dependencies.agent.assistedProgress;
  RouteRepository get route => _dependencies.routeRepository;
  LocalProgressStore get progress => _dependencies.localProgressStore;
  UserExerciseRepository get userExercises => _dependencies.userExerciseRepository;
  SyntaxHelpSource get help => _dependencies.syntaxHelpSource;

  ListDocuments get listDocuments => ListDocuments(repository: _dependencies.documentRepository);
  LoadDocument get loadDocument => LoadDocument(repository: _dependencies.documentRepository);
  SaveDocumentSource get saveSource =>
      SaveDocumentSource(repository: _dependencies.documentRepository, clock: _dependencies.clock);
  CreateDocument get createDocument => CreateDocument(
    repository: _dependencies.documentRepository,
    identifiers: _dependencies.identifiers,
    clock: _dependencies.clock,
  );
  RenameDocument get renameDocument =>
      RenameDocument(repository: _dependencies.documentRepository, clock: _dependencies.clock);
  DeleteDocument get deleteDocument => DeleteDocument(repository: _dependencies.documentRepository);
  SetExecutionArguments get setArguments =>
      SetExecutionArguments(repository: _dependencies.documentRepository, clock: _dependencies.clock);
  CheckProgram get checkProgram => CheckProgram(analyzer: _dependencies.programAnalyzer);
  RunProgram get runProgram =>
      RunProgram(analyzer: _dependencies.programAnalyzer, runner: _dependencies.programTools.runner);
  TranslateProgram get translateProgram =>
      TranslateProgram(translator: _dependencies.programTools.translator);
  FormatProgram get formatProgram => FormatProgram(formatter: _dependencies.programTools.formatter);
  CreateUserExercise get createExercise => CreateUserExercise(
    repository: _dependencies.userExerciseRepository,
    validate: buildUserExerciseValidation(_dependencies),
    identifiers: _dependencies.identifiers,
    clock: _dependencies.clock,
  );
  UpdateUserExercise get updateExercise => UpdateUserExercise(
    repository: _dependencies.userExerciseRepository,
    validate: buildUserExerciseValidation(_dependencies),
    clock: _dependencies.clock,
  );
  DeleteUserExercise get deleteExercise =>
      DeleteUserExercise(repository: _dependencies.userExerciseRepository);
  SetThemeMode get setTheme =>
      SetThemeMode(preferences: _dependencies.preferences, updates: _wiring.updates);
  SetInterfaceLanguage get setLanguage =>
      SetInterfaceLanguage(preferences: _dependencies.preferences, updates: _wiring.updates);
}
