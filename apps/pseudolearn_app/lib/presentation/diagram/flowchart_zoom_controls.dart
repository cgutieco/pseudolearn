import 'package:flutter/material.dart';
import '../components/button/app_button.dart';
import '../components/button/app_icon_button.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';

final class FlowchartZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  const FlowchartZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.raised,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        boxShadow: theme.elevation.level2,
        border: Border.all(color: theme.colors.borders.subtle, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconButton(icon: Icons.zoom_in, semanticLabel: l10n.diagramZoomIn, variant: AppButtonVariant.tertiary, onPressed: onZoomIn),
          Container(height: 1, width: 24, color: theme.colors.borders.subtle),
          AppIconButton(icon: Icons.zoom_out, semanticLabel: l10n.diagramZoomOut, variant: AppButtonVariant.tertiary, onPressed: onZoomOut),
          Container(height: 1, width: 24, color: theme.colors.borders.subtle),
          AppIconButton(icon: Icons.center_focus_strong, semanticLabel: l10n.diagramFitToView, variant: AppButtonVariant.tertiary, onPressed: onResetZoom),
        ],
      ),
    );
  }
}
