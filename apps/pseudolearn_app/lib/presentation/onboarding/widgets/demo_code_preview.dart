import 'package:flutter/material.dart';
import '../../editor/components/code_preview.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';

final class DemoCodePreviewCard extends StatelessWidget {
  final String code;
  final int? activeLine;
  final double height;

  const DemoCodePreviewCard({
    super.key,
    required this.code,
    required this.activeLine,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        child: CodePreview(
          text: code,
          activeLines: activeLine == null ? const {} : {activeLine!},
        ),
      ),
    );
  }
}
