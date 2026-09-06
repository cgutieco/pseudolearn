import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/knowledge/bank/exercise_bank_cubit.dart';
import '../../application/knowledge/bank/exercise_bank_state.dart';
import '../../application/knowledge/knowledge_cubit.dart';
import '../../application/knowledge/knowledge_state.dart';
import '../../application/knowledge/route/learning_route_cubit.dart';
import '../../application/knowledge/route/learning_route_state.dart';
import '../../application/settings/settings_cubit.dart';
import '../../application/settings/settings_state.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/exercise_level.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/settings/effective_ui_language.dart';
import '../components/layout/app_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import 'components/knowledge_body.dart';
import 'components/knowledge_header.dart';
import 'components/knowledge_section_selector.dart';
import 'exercise_creation_launcher.dart';

final class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

final class _KnowledgePageState extends State<KnowledgePage> {
  late final TextEditingController _searchController;
  KnowledgeSectionKind _activeSection = KnowledgeSectionKind.route;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAll() {
    final settings = context.read<SettingsCubit>().state;
    final systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final effectiveLanguage = resolveEffectiveLanguage(
      setting: settings.language,
      systemLanguageCode: systemLocale,
    );
    context.read<KnowledgeCubit>().load(effectiveLanguage);
    context.read<LearningRouteCubit>().loadRoute(effectiveLanguage);
    context.read<ExerciseBankCubit>().loadExercises(effectiveLanguage);
  }

  void _search(String query) {
    context.read<KnowledgeCubit>().search(query);
    context.read<LearningRouteCubit>().search(query);
    context.read<ExerciseBankCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) => prev.language != curr.language,
      listener: (context, settingsState) => _loadAll(),
      child: _KnowledgeScopeBuilder(
        activeSection: _activeSection,
        searchController: _searchController,
        onSearchChanged: _search,
        onSectionSelected: (s) => setState(() => _activeSection = s),
        onRetry: _loadAll,
      ),
    );
  }
}

final class _KnowledgeScopeBuilder extends StatelessWidget {
  final KnowledgeSectionKind activeSection;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<KnowledgeSectionKind> onSectionSelected;
  final VoidCallback onRetry;

  const _KnowledgeScopeBuilder({
    required this.activeSection,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSectionSelected,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KnowledgeCubit, KnowledgeState>(
      builder: (context, kState) =>
          BlocBuilder<LearningRouteCubit, LearningRouteState>(
        builder: (context, rState) => _ExerciseBankViewConnector(
          knowledgeState: kState,
          routeState: rState,
          activeSection: activeSection,
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          onSectionSelected: onSectionSelected,
          onRetry: onRetry,
        ),
      ),
    );
  }
}

final class _ExerciseBankViewConnector extends StatelessWidget {
  final KnowledgeState knowledgeState;
  final LearningRouteState routeState;
  final KnowledgeSectionKind activeSection;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<KnowledgeSectionKind> onSectionSelected;
  final VoidCallback onRetry;

  const _ExerciseBankViewConnector({
    required this.knowledgeState,
    required this.routeState,
    required this.activeSection,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSectionSelected,
    required this.onRetry,
  });

  void _openExercise(BuildContext context, ExerciseBankState state, String id) {
    final exercise = state.findExercise(id);
    if (exercise != null) {
      launchExerciseCreationDialog(context: context, exercise: exercise, onClosed: onRetry);
    } else {
      context.push('/conocimiento/$id').then((_) => onRetry());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankCubit = context.read<ExerciseBankCubit>();
    return BlocBuilder<ExerciseBankCubit, ExerciseBankState>(
      builder: (context, bankState) => KnowledgeView(
        knowledgeState: knowledgeState,
        routeState: routeState,
        exerciseBankState: bankState,
        activeSection: activeSection,
        searchController: searchController,
        onSearchChanged: onSearchChanged,
        onSectionSelected: onSectionSelected,
        onLevelSelected: (lvl) => bankCubit.setFilter(level: lvl, clearLevel: lvl == null),
        onModuleSelected: (mod) => bankCubit.setFilter(moduleId: mod, clearModule: mod == null),
        onConstructSelected: (c) => bankCubit.setFilter(construct: c, clearConstruct: c == null),
        onClearFilters: bankCubit.clearFilters,
        onOpenEntry: (entry) =>
            context.push('/conocimiento/${entry.id}').then((_) => onRetry()),
        onOpenExercise: (id) => _openExercise(context, bankState, id),
        onRetry: onRetry,
      ),
    );
  }
}

final class KnowledgeView extends StatelessWidget {
  final KnowledgeState knowledgeState;
  final LearningRouteState routeState;
  final ExerciseBankState exerciseBankState;
  final KnowledgeSectionKind activeSection;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<KnowledgeSectionKind> onSectionSelected;
  final ValueChanged<ExerciseLevel?> onLevelSelected;
  final ValueChanged<String?> onModuleSelected;
  final ValueChanged<AstConstruct?> onConstructSelected;
  final VoidCallback onClearFilters;
  final ValueChanged<KnowledgeEntry> onOpenEntry;
  final ValueChanged<String> onOpenExercise;
  final VoidCallback onRetry;

  const KnowledgeView({
    super.key,
    required this.knowledgeState,
    required this.routeState,
    required this.exerciseBankState,
    required this.activeSection,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSectionSelected,
    required this.onLevelSelected,
    required this.onModuleSelected,
    required this.onConstructSelected,
    required this.onClearFilters,
    required this.onOpenEntry,
    required this.onOpenExercise,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final header = KnowledgeHeader(
      searchController: searchController,
      onSearchChanged: onSearchChanged,
    );
    final body = KnowledgeBody(
      activeSection: activeSection,
      onSectionSelected: onSectionSelected,
      knowledgeState: knowledgeState,
      routeState: routeState,
      exerciseBankState: exerciseBankState,
      onLevelSelected: onLevelSelected,
      onModuleSelected: onModuleSelected,
      onConstructSelected: onConstructSelected,
      onClearFilters: onClearFilters,
      onOpenEntry: onOpenEntry,
      onOpenExercise: onOpenExercise,
      onRetry: onRetry,
    );

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(title: l10n.knowledgeTitle, filter: header, body: body),
    );
  }
}
