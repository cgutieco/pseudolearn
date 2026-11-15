import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/agent/agent_launcher_cubit.dart';
import '../application/agent/agent_loop.dart';
import '../application/agent/agent_session_cubit.dart';
import '../application/agent/code_block_checker.dart';
import '../application/agent/prompt_assembler.dart';
import '../application/credits/agent_consent_cubit.dart';
import '../application/credits/credits_cubit.dart';
import '../application/credits/purchase_cubit.dart';
import '../application/route/session/exercise_session_cubit.dart';
import '../application/settings/settings_cubit.dart';
import '../domain/model/agent/screen_context_snapshot.dart';
import '../domain/model/profiles/syntax_profile_for_language.dart';
import '../domain/model/profiles/syntax_profile_id.dart';
import '../domain/model/reference/reference_edition.dart';
import '../domain/model/settings/effective_ui_language.dart';
import '../domain/model/settings/ui_language_id.dart';
import 'agent_tool_catalog.dart';
import 'agent_use_cases.dart';
import 'app_dependencies.dart';
import 'app_scope.dart';

final class AgentLanguage {
  final SettingsCubit _settings;

  const AgentLanguage(this._settings);

  UiLanguageId language() => resolveEffectiveLanguage(
    setting: _settings.state.language,
    systemLanguageCode: WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );

  SyntaxProfileId profile() => syntaxProfileForLanguage(language());

  ReferenceEdition edition() => ReferenceEdition(language: language(), profile: profile());
}

List<BlocProvider> buildAgentProviders({
  required AppDependencies dependencies,
  required AppScope scope,
  required SettingsCubit settings,
  required ExerciseSessionCubit exerciseSession,
}) {
  final language = AgentLanguage(settings);
  final cases = AgentUseCases(
    dependencies,
    AgentWiring(
      screen: scope.board,
      activeExercise: exerciseSession,
      navigator: scope.navigator,
      updates: scope.updates,
      language: language.language,
      edition: language.edition,
    ),
  );
  final session = _session(dependencies, _loop(dependencies: dependencies, scope: scope, cases: cases, language: language), language);
  final credits = CreditsCubit(
    gateway: dependencies.agent.creditsGateway,
    sessionBalances: session.stream.map((state) => (state.balance, state.lastRequestSpent, state.failure)),
  );
  return [
    BlocProvider<AgentSessionCubit>(create: (_) => session),
    BlocProvider<CreditsCubit>(create: (_) => credits),
    BlocProvider<PurchaseCubit>(create: (_) => _purchases(dependencies, credits)),
    BlocProvider<AgentConsentCubit>(
      create: (_) => AgentConsentCubit(store: dependencies.agent.consentStore)..load(),
    ),
    BlocProvider<AgentLauncherCubit>(
      create: (_) => AgentLauncherCubit(preferences: dependencies.preferences)..load(),
    ),
  ];
}

PurchaseCubit _purchases(AppDependencies dependencies, CreditsCubit credits) => PurchaseCubit(
  store: dependencies.agent.purchaseStore,
  pending: dependencies.agent.pendingPurchases,
  gateway: dependencies.agent.creditsGateway,
  credits: credits,
  links: dependencies.agent.externalLinks,
  returns: dependencies.incomingLinkSource.incomingLinks(),
);

AgentSessionCubit _session(AppDependencies dependencies, AgentLoop loop, AgentLanguage language) =>
    AgentSessionCubit(
      loop: loop,
      consent: dependencies.agent.consentStore,
      checker: CodeBlockChecker(reader: dependencies.agent.replyReader, analyzer: dependencies.programAnalyzer),
      editorial: AgentEditorial(profile: language.profile, language: language.language),
    );

AgentLoop _loop({
  required AppDependencies dependencies,
  required AppScope scope,
  required AgentUseCases cases,
  required AgentLanguage language,
}) => AgentLoop(
  gateway: dependencies.agent.modelGateway,
  registry: buildAgentToolRegistry(cases),
  identifiers: dependencies.identifiers,
  assembler: PromptAssembler(
    prompts: dependencies.agent.promptSource,
    knowledge: dependencies.agent.knowledgeIndex,
    screen: scope.board,
    ambient: () => AmbientContext(
      interfaceLanguage: language.language().resolveLocaleCode(null),
      defaultProfile: language.profile().name,
      date: dependencies.clock.now(),
      platform: dependencies.agent.platformName,
    ),
  ),
);
