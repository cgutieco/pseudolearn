import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';

enum DocumentTabKind {
  editor,
  flowchart,
  trace,
  equivalentCode,
}

final class TabSelector extends StatelessWidget {
  final DocumentTabKind activeTab;
  final ValueChanged<DocumentTabKind> onTabSelected;
  final bool canAccompany;
  final bool isAccompanying;
  final bool showsCompanionLabel;
  final Axis companionDirection;
  final VoidCallback? onToggleCompanion;

  const TabSelector({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.canAccompany = false,
    this.isAccompanying = false,
    this.showsCompanionLabel = true,
    this.companionDirection = Axis.horizontal,
    this.onToggleCompanion,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border(bottom: BorderSide(color: theme.colors.borders.subtle, width: 1)),
      ),
      child: Row(
        children: [
          _TabItem(label: l10n.tabEditor, isSelected: activeTab == DocumentTabKind.editor, onTap: () => onTabSelected(DocumentTabKind.editor)),
          _TabItem(label: l10n.tabDiagrams, isSelected: activeTab == DocumentTabKind.flowchart, onTap: () => onTabSelected(DocumentTabKind.flowchart)),
          _TabItem(label: l10n.tabTrace, isSelected: activeTab == DocumentTabKind.trace, onTap: () => onTabSelected(DocumentTabKind.trace)),
          _TabItem(label: l10n.tabEquivalentCode, isSelected: activeTab == DocumentTabKind.equivalentCode, onTap: () => onTabSelected(DocumentTabKind.equivalentCode)),
          if (canAccompany)
            _CompanionToggle(
              isActive: isAccompanying,
              showsLabel: showsCompanionLabel,
              direction: companionDirection,
              onToggle: onToggleCompanion,
            ),
        ],
      ),
    );
  }
}

final class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: _TabItemContent(label: label, isSelected: isSelected),
      ),
    );
  }
}

final class _TabItemContent extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabItemContent({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final textColor = isSelected ? theme.colors.text.link : theme.colors.text.secondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.space1,
            right: SpacingTokens.space1,
            bottom: SpacingTokens.space2,
          ),
          child: AppText(
            label,
            variant: AppTextVariant.label,
            color: textColor,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSelected) _TabIndicator(color: theme.colors.text.link),
      ],
    );
  }
}

final class _TabIndicator extends StatelessWidget {
  final Color color;

  const _TabIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(height: 3, color: color),
    );
  }
}


IconData _companionIcon({required bool isActive, required Axis direction}) {
  if (!isActive) return Icons.crop_square;
  return direction == Axis.horizontal ? Icons.vertical_split : Icons.horizontal_split;
}

final class _CompanionToggle extends StatelessWidget {
  final bool isActive;
  final bool showsLabel;
  final Axis direction;
  final VoidCallback? onToggle;

  const _CompanionToggle({
    required this.isActive,
    required this.showsLabel,
    required this.direction,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final color = isActive ? theme.colors.text.link : theme.colors.text.secondary;

    return Tooltip(
      message: l10n.companionToggle,
      child: InkWell(
        onTap: onToggle,
        child: _CompanionToggleContent(
          icon: _companionIcon(isActive: isActive, direction: direction),
          label: showsLabel ? l10n.companionToggle : null,
          color: color,
        ),
      ),
    );
  }
}

final class _CompanionToggleContent extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;

  const _CompanionToggleContent({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = label;

    return Container(
      constraints: const BoxConstraints(
        minWidth: SpacingTokens.targetTouchMin,
        minHeight: SpacingTokens.targetTouchMin,
      ),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: IconMetricsTokens.iconXs, color: color),
          if (text != null) ...[
            const SizedBox(width: SpacingTokens.space1),
            AppText(text, variant: AppTextVariant.label, color: color, maxLines: 1),
          ],
        ],
      ),
    );
  }
}
