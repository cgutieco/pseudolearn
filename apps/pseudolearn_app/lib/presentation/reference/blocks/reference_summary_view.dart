import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_link_text.dart';
import '../reference_runs_text.dart';
import 'reference_list_view.dart';

final class ReferenceSummaryView extends StatelessWidget {
  final List<List<ReferenceRun>> points;
  final ValueChanged<String> onOpenSection;

  const ReferenceSummaryView({
    super.key,
    required this.points,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return ReferencePanel(
      title: AppLocalizations.of(context)!.referenceSummary,
      color: theme.colors.surfaces.brandSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final point in points)
            ReferenceListEntry(
              marker: '✓',
              child: ReferenceRunsText(
                runs: point,
                onOpenSection: onOpenSection,
              ),
            ),
        ],
      ),
    );
  }
}

final class ReferenceSeeAlsoView extends StatelessWidget {
  final List<ReferenceSectionLink> links;
  final ValueChanged<String> onOpenSection;

  const ReferenceSeeAlsoView({
    super.key,
    required this.links,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return ReferencePanel(
      title: AppLocalizations.of(context)!.referenceSeeAlso,
      color: theme.colors.surfaces.subtle,
      child: Wrap(
        spacing: SpacingTokens.space4,
        runSpacing: SpacingTokens.space2,
        children: [
          for (final link in links)
            ReferenceLinkText(
              text: '${link.number} ${link.title}',
              onTap: () => onOpenSection(link.sectionId),
            ),
        ],
      ),
    );
  }
}

final class ReferencePanel extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const ReferencePanel({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            title,
            variant: AppTextVariant.label,
            color: theme.colors.text.secondary,
          ),
          const SizedBox(height: SpacingTokens.space2),
          child,
        ],
      ),
    );
  }
}
