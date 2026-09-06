import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import 'design_canvas.dart';
import 'device_class.dart';
import 'shell_bottom_bar.dart';
import 'shell_navigation_rail.dart';

final class AdaptiveShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    return switch (canvas.deviceClass) {
      DeviceClass.compact => _CompactShell(navigationShell: navigationShell),
      DeviceClass.medium ||
      DeviceClass.expanded =>
        _RailShell(navigationShell: navigationShell),
    };
  }
}

final class _CompactShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _CompactShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ShellBottomBar(navigationShell: navigationShell),
    );
  }
}

final class _RailShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _RailShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      body: Row(
        children: [
          ShellNavigationRail(navigationShell: navigationShell),
          VerticalDivider(
            width: BorderMetricsTokens.widthHairline,
            thickness: BorderMetricsTokens.widthHairline,
            color: theme.colors.borders.subtle,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
