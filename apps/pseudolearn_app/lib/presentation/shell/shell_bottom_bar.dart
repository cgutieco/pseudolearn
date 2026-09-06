import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/component_metrics.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/motion.dart';
import '../theme/tokens/spacing.dart';
import 'design_canvas.dart';
import 'destinations.dart';
import 'shell_branch.dart';

final class ShellBottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellBottomBar({super.key, required this.navigationShell});

  BoxDecoration _decoration(AppThemeExtension theme) => BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border(
          top: BorderSide(
            color: theme.colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final items = [
      for (final (index, destination) in appDestinations.indexed)
        Expanded(
          child: _ShellBottomBarItem(
            destination: destination,
            isSelected: navigationShell.currentIndex == index,
            onTap: () => goToShellBranch(navigationShell, index),
          ),
        ),
    ];
    return DecoratedBox(
      decoration: _decoration(theme),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: ComponentMetricsTokens.bottomBarHeight,
          child: Row(children: items),
        ),
      ),
    );
  }
}

final class _ShellBottomBarItem extends StatelessWidget {
  final AppDestinationSpec destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShellBottomBarItem(
      {required this.destination,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color =
        isSelected ? theme.colors.text.link : theme.colors.text.secondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label(l10n),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ShellBottomBarIndicator(
                destination: destination, isSelected: isSelected, color: color),
            const SizedBox(height: SpacingTokens.spaceHalf),
            _ShellBottomBarLabel(text: destination.label(l10n), color: color),
          ],
        ),
      ),
    );
  }
}

final class _ShellBottomBarLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _ShellBottomBarLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1),
      child: AppText(
        text,
        variant: AppTextVariant.caption,
        color: color,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

final class _ShellBottomBarIndicator extends StatelessWidget {
  final AppDestinationSpec destination;
  final bool isSelected;
  final Color color;

  const _ShellBottomBarIndicator(
      {required this.destination,
      required this.isSelected,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return AnimatedContainer(
      duration: canvas.motion(MotionSpeed.fast),
      curve: MotionTokens.easeStandard,
      width: ComponentMetricsTokens.bottomBarIndicatorWidth,
      height: ComponentMetricsTokens.bottomBarIndicatorHeight,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: isSelected
            ? theme.colors.surfaces.brandSubtle
            : theme.colors.surfaces.defaultSurface.withValues(alpha: 0),
        shape: const StadiumBorder(),
      ),
      child: Icon(isSelected ? destination.selectedIcon : destination.icon,
          size: IconMetricsTokens.iconMd, color: color),
    );
  }
}
