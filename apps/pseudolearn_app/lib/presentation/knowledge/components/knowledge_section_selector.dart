import 'package:material_ui/material_ui.dart';
import '../../components/navigation/app_section_tabs.dart';
import '../../l10n/generated/app_localizations.dart';

enum KnowledgeSectionKind { route, specification, exercises }

final class KnowledgeSectionSelector extends StatelessWidget {
  final KnowledgeSectionKind activeSection;
  final ValueChanged<KnowledgeSectionKind> onSectionSelected;

  const KnowledgeSectionSelector({
    super.key,
    required this.activeSection,
    required this.onSectionSelected,
  });

  Map<KnowledgeSectionKind, String> _labelsOf(AppLocalizations l10n) => {
        KnowledgeSectionKind.route: l10n.knowledgeSectionRoute,
        KnowledgeSectionKind.specification: l10n.knowledgeSectionSpecification,
        KnowledgeSectionKind.exercises: l10n.knowledgeSectionExercises,
      };

  @override
  Widget build(BuildContext context) {
    final labels = _labelsOf(AppLocalizations.of(context)!);
    return AppSectionTabs(
      tabs: [
        for (final kind in labels.keys)
          AppSectionTab(
            label: labels[kind]!,
            isSelected: activeSection == kind,
            onTap: () => onSectionSelected(kind),
          ),
      ],
    );
  }
}
