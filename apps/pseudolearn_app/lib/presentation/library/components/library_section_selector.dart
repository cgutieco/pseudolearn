import 'package:flutter/material.dart';
import '../../components/navigation/app_section_tabs.dart';
import '../../l10n/generated/app_localizations.dart';

enum LibrarySection { algorithms, exercises }

final class LibrarySectionSelector extends StatelessWidget {
  final LibrarySection activeSection;
  final int algorithmCount;
  final int exerciseCount;
  final ValueChanged<LibrarySection> onSectionSelected;

  const LibrarySectionSelector({
    super.key,
    required this.activeSection,
    required this.algorithmCount,
    required this.exerciseCount,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSectionTabs(
      tabs: [
        AppSectionTab(
          key: const ValueKey('library-section-algorithms'),
          label: l10n.librarySectionAlgorithms,
          count: algorithmCount,
          isSelected: activeSection == LibrarySection.algorithms,
          onTap: () => onSectionSelected(LibrarySection.algorithms),
        ),
        AppSectionTab(
          key: const ValueKey('feature:user-exercises'),
          label: l10n.librarySectionExercises,
          count: exerciseCount,
          isSelected: activeSection == LibrarySection.exercises,
          onTap: () => onSectionSelected(LibrarySection.exercises),
        ),
      ],
    );
  }
}
