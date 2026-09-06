import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../brand/brand_symbol.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/brand_metrics.dart';
import '../theme/tokens/component_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'design_canvas.dart';
import 'destinations.dart';
import 'shell_branch.dart';

final class ShellNavigationRail extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellNavigationRail({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ComponentMetricsTokens.navRailWidth,
      child: Column(
        children: [
          const _RailBrand(),
          Expanded(child: _RailDestinations(navigationShell: navigationShell)),
        ],
      ),
    );
  }
}

final class _RailBrand extends StatelessWidget {
  const _RailBrand();

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: canvas.scaled(SpacingTokens.space4)),
        child: BrandSymbol(
          size: BrandMetricsTokens.symbolSizeSignature,
          color: theme.colors.brandInk.signature,
        ),
      ),
    );
  }
}

final class _RailDestinations extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _RailDestinations({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: ComponentMetricsTokens.navRailWidth,
      child: NavigationRail(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => goToShellBranch(navigationShell, index),
        labelType: NavigationRailLabelType.all,
        destinations: appDestinations
            .map((AppDestinationSpec d) => NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(
                    d.label(l10n),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
