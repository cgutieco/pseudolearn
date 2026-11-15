import 'package:material_ui/material_ui.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';
import 'document_tabs.dart';

export 'document_tabs.dart' show DocumentTabKind;

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
  Widget build(BuildContext context) => _TabSelectorFrame(
    child: Row(
      children: [
        Expanded(
          child: DocumentTabs(
            activeTab: activeTab,
            onTabSelected: onTabSelected,
          ),
        ),
        if (canAccompany)
          CompanionToggle(
            isActive: isAccompanying,
            showsLabel: showsCompanionLabel,
            direction: companionDirection,
            onToggle: onToggleCompanion,
          ),
      ],
    ),
  );
}

final class _TabSelectorFrame extends StatelessWidget {
  final Widget child;

  const _TabSelectorFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border(
          bottom: BorderSide(color: theme.colors.borders.subtle, width: 1),
        ),
      ),
      child: child,
    );
  }
}

IconData _companionIcon({required bool isActive, required Axis direction}) {
  if (!isActive) return Icons.crop_square;
  return direction == Axis.horizontal
      ? Icons.vertical_split
      : Icons.horizontal_split;
}

final class CompanionToggle extends StatelessWidget {
  final bool isActive;
  final bool showsLabel;
  final Axis direction;
  final VoidCallback? onToggle;

  const CompanionToggle({
    super.key,
    required this.isActive,
    required this.showsLabel,
    required this.direction,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final color = isActive
        ? theme.colors.text.link
        : theme.colors.text.secondary;
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
  Widget build(BuildContext context) => Container(
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
        if (label != null) ...[
          const SizedBox(width: SpacingTokens.space1),
          AppText(
            label!,
            variant: AppTextVariant.label,
            color: color,
            maxLines: 1,
          ),
        ],
      ],
    ),
  );
}
