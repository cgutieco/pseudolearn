import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/spacing.dart';

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
    final theme = AppThemeExtension.of(context);
    final labels = _labelsOf(AppLocalizations.of(context)!);

    return Container(
      height: SpacingTokens.targetTouchMin,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border(
          bottom: BorderSide(color: theme.colors.borders.subtle, width: BorderMetricsTokens.widthHairline),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final kind in labels.keys)
            _SectionItem(
              label: labels[kind]!,
              isSelected: activeSection == kind,
              onTap: () => onSectionSelected(kind),
            ),
        ],
      ),
    );
  }
}

final class _SectionItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: _SectionItemContent(label: label, isSelected: isSelected),
      ),
    );
  }
}

final class _SectionItemContent extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SectionItemContent({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final textColor = isSelected ? theme.colors.text.link : theme.colors.text.secondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1),
          child: AppText(
            label,
            variant: AppTextVariant.label,
            color: textColor,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSelected) _SectionIndicator(color: theme.colors.text.link),
      ],
    );
  }
}

final class _SectionIndicator extends StatelessWidget {
  final Color color;

  const _SectionIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(height: BorderMetricsTokens.widthChannel, color: color),
    );
  }
}
