import 'package:material_ui/material_ui.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../typography/app_text.dart';

final class AppSectionTab {
  final Key? key;
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const AppSectionTab({
    this.key,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });
}

final class AppSectionTabs extends StatelessWidget {
  final List<AppSectionTab> tabs;

  const AppSectionTabs({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
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
        children: [for (final tab in tabs) _TabItem(key: tab.key, tab: tab)],
      ),
    );
  }
}

final class _TabItem extends StatelessWidget {
  final AppSectionTab tab;

  const _TabItem({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: tab.isSelected,
        button: true,
        child: InkWell(
          onTap: tab.onTap,
          child: _TabContent(tab: tab),
        ),
      ),
    );
  }
}

final class _TabContent extends StatelessWidget {
  final AppSectionTab tab;

  const _TabContent({required this.tab});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final color = tab.isSelected ? theme.colors.text.link : theme.colors.text.secondary;
    final count = tab.count;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: _TabLabel(label: tab.label, color: color)),
              if (count != null) _TabCount(count: count, isSelected: tab.isSelected),
            ],
          ),
        ),
        if (tab.isSelected) _TabIndicator(color: color),
      ],
    );
  }
}

final class _TabLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _TabLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppText(
      label,
      variant: AppTextVariant.label,
      color: color,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

final class _TabCount extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _TabCount({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    return Container(
      margin: const EdgeInsets.only(left: SpacingTokens.space2),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2, vertical: SpacingTokens.spaceHalf),
      decoration: BoxDecoration(
        color: isSelected ? colors.surfaces.brandSubtle : colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
      ),
      child: AppText(
        '$count',
        variant: AppTextVariant.caption,
        color: isSelected ? colors.text.link : colors.text.secondary,
      ),
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
      child: Container(height: BorderMetricsTokens.widthChannel, color: color),
    );
  }
}
