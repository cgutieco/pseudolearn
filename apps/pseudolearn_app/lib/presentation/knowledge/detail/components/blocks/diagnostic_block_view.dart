import 'package:flutter/material.dart';
import '../../../../../domain/model/knowledge/content_block.dart';
import '../../../../components/typography/app_text.dart';
import '../../../../editor/components/severity_chip.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens/border_metrics.dart';
import '../../../../theme/tokens/radii.dart';
import '../../../../theme/tokens/spacing.dart';

final class DiagnosticBlockView extends StatelessWidget {
  final DiagnosticBlock block;

  const DiagnosticBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space4),
      padding: const EdgeInsets.all(SpacingTokens.space3),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeverityChip(severity: block.severity),
          const SizedBox(width: SpacingTokens.space3),
          Expanded(child: _DiagnosticDetails(block: block)),
        ],
      ),
    );
  }
}

final class _DiagnosticDetails extends StatelessWidget {
  final DiagnosticBlock block;

  const _DiagnosticDetails({required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          block.message,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.primary,
        ),
        const SizedBox(height: SpacingTokens.spaceHalf),
        AppText(
          block.code,
          variant: AppTextVariant.codeCaption,
          color: theme.colors.text.tertiary,
        ),
      ],
    );
  }
}

