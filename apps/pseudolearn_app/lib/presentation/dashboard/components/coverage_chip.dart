import 'package:material_ui/material_ui.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class CoverageChip extends StatelessWidget {
  final String label;
  final bool isDone;
  final String? badge;

  const CoverageChip({
    super.key,
    required this.label,
    required this.isDone,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final success = theme.colors.severities.success;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: canvas.scaled(SpacingTokens.space2),
        vertical: canvas.scaled(SpacingTokens.space1),
      ),
      decoration: BoxDecoration(
        color: isDone ? success.surface : theme.colors.surfaces.subtle,
        border: Border.all(
          color: isDone ? success.border : theme.colors.borders.subtle,
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
      ),
      child: _ChipContent(chip: this),
    );
  }
}

final class _ChipContent extends StatelessWidget {
  final CoverageChip chip;

  const _ChipContent({required this.chip});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final isDone = chip.isDone;
    final foreground = isDone
        ? theme.colors.severities.success.fg
        : theme.colors.text.tertiary;
    final trailing = chip.badge;
    final icon = isDone
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: IconMetricsTokens.iconXs, color: foreground),
        SizedBox(width: canvas.scaled(SpacingTokens.space1)),
        Flexible(child: _ChipLabel(chip: chip)),
        if (trailing != null) ...[
          SizedBox(width: canvas.scaled(SpacingTokens.space1)),
          AppText(trailing, variant: AppTextVariant.label, color: foreground),
        ],
      ],
    );
  }
}

final class _ChipLabel extends StatelessWidget {
  final CoverageChip chip;

  const _ChipLabel({required this.chip});

  @override
  Widget build(BuildContext context) {
    final text = AppThemeExtension.of(context).colors.text;

    return AppText(
      chip.label,
      variant: AppTextVariant.caption,
      color: chip.isDone ? text.primary : text.secondary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
