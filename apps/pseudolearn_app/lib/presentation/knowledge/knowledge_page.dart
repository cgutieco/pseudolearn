import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/reference/reference_index_cubit.dart';
import '../../application/route/route_bank_cubit.dart';
import '../../application/route/route_index_cubit.dart';
import '../../application/settings/settings_cubit.dart';
import '../../application/settings/settings_state.dart';
import '../../domain/model/route/route_toc.dart';
import '../components/layout/app_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../reference/reference_edition_resolver.dart';
import '../theme/app_theme.dart';
import 'components/knowledge_body.dart';
import 'components/knowledge_header.dart';
import 'components/knowledge_section_selector.dart';

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
    final edition = currentReferenceEdition(context);
    context.read<RouteIndexCubit>().load(edition);
    context.read<RouteBankCubit>().load(edition);
    context.read<ReferenceIndexCubit>().load(edition);
  }

  void _openLesson(String lessonId) =>
      context.push('/conocimiento/ruta/$lessonId').then((_) => _loadAll());

  void _openExercise(RouteExerciseEntry exercise) => context
      .push('/conocimiento/ruta/${exercise.lessonId}/${exercise.id}')
      .then((_) => _loadAll());

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final searching = _activeSection == KnowledgeSectionKind.specification;
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => previous.language != current.language,
      listener: (context, settingsState) => _loadAll(),
      child: Scaffold(
        backgroundColor: theme.colors.surfaces.canvas,
        body: AppPage(
          title: l10n.knowledgeTitle,
          filter: searching
              ? KnowledgeHeader(
                  searchController: _searchController,
                  onSearchChanged: context.read<ReferenceIndexCubit>().search,
                )
              : null,
          body: KnowledgeBody(
            activeSection: _activeSection,
            onSectionSelected: (section) => setState(() => _activeSection = section),
            onOpenLesson: _openLesson,
            onOpenExercise: _openExercise,
            onRetry: _loadAll,
          ),
        ),
      ),
    );
  }
}
