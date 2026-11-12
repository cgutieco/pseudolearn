import 'package:material_ui/material_ui.dart';
import '../../application/library/library_state.dart';
import '../../domain/model/documents/document.dart';
import '../components/field/app_search_field.dart';
import '../components/layout/app_page.dart';
import '../components/sync_banner.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'components/library_body.dart';
import 'components/library_section_selector.dart';
import 'components/library_toolbar.dart';

final class LibraryExercisesSlot {
  final Widget content;
  final int count;
  final VoidCallback onCreate;

  const LibraryExercisesSlot({required this.content, required this.count, required this.onCreate});
}

final class LibraryView extends StatelessWidget {
  final LibraryState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNewDocument;
  final ValueChanged<DocumentSummary> onOpenDocument;
  final ValueChanged<DocumentSummary> onRenameDocument;
  final ValueChanged<DocumentSummary> onDeleteDocument;
  final LibrarySection section;
  final ValueChanged<LibrarySection>? onSectionSelected;
  final LibraryExercisesSlot? exercises;

  const LibraryView({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onNewDocument,
    required this.onOpenDocument,
    required this.onRenameDocument,
    required this.onDeleteDocument,
    this.section = LibrarySection.algorithms,
    this.onSectionSelected,
    this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeExtension.of(context).colors.surfaces.canvas,
      body: AppPage(
        title: AppLocalizations.of(context)!.libraryTitle,
        measure: ContentMeasure.wide,
        body: _LibraryWorkspace(view: this),
      ),
    );
  }
}

final class _LibraryWorkspace extends StatelessWidget {
  final LibraryView view;

  const _LibraryWorkspace({required this.view});

  @override
  Widget build(BuildContext context) {
    final exercises = view.exercises;
    final selectSection = view.onSectionSelected;
    final active = exercises == null ? LibrarySection.algorithms : view.section;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SyncBanner(),
        if (exercises != null && selectSection != null) ...[
          LibrarySectionSelector(
            activeSection: active,
            algorithmCount: view.state.allDocuments.length,
            exerciseCount: exercises.count,
            onSectionSelected: selectSection,
          ),
          const SizedBox(height: SpacingTokens.space4),
        ],
        Expanded(
          child: switch ((active, exercises)) {
            (LibrarySection.exercises, final LibraryExercisesSlot slot) => _ExercisesSection(slot: slot),
            _ => _AlgorithmsSection(view: view),
          },
        ),
      ],
    );
  }
}

final class _AlgorithmsSection extends StatelessWidget {
  final LibraryView view;

  const _AlgorithmsSection({required this.view});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AlgorithmsToolbar(view: view),
        const SizedBox(height: SpacingTokens.space4),
        Expanded(
          child: LibraryBody(
            state: view.state,
            onNewDocument: view.onNewDocument,
            onOpenDocument: view.onOpenDocument,
            onRenameDocument: view.onRenameDocument,
            onDeleteDocument: view.onDeleteDocument,
          ),
        ),
      ],
    );
  }
}

final class _AlgorithmsToolbar extends StatelessWidget {
  final LibraryView view;

  const _AlgorithmsToolbar({required this.view});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LibraryToolbar(
      leading: AppSearchField(
        controller: view.searchController,
        hintText: l10n.librarySearchPlaceholder,
        onChanged: view.onSearchChanged,
      ),
      action: LibraryCreateAction(
        key: const ValueKey('feature:new-document'),
        label: l10n.libraryNewDocument,
        onPressed: view.onNewDocument,
      ),
    );
  }
}

final class _ExercisesSection extends StatelessWidget {
  final LibraryExercisesSlot slot;

  const _ExercisesSection({required this.slot});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeExtension.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LibraryToolbar(
          leading: AppText(l10n.userExercisesIntro, variant: AppTextVariant.bodySmall, color: colors.text.secondary),
          action: LibraryCreateAction(
            key: const ValueKey('user-exercise-create'),
            label: l10n.userExercisesNew,
            onPressed: slot.onCreate,
          ),
        ),
        const SizedBox(height: SpacingTokens.space4),
        Expanded(child: slot.content),
      ],
    );
  }
}
