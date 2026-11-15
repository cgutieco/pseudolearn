import 'package:flutter/widgets.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class LegendEntry {
  final String label;
  final Color color;
  final String? value;

  const LegendEntry({required this.label, required this.color, this.value});
}

final class ChartLegend extends StatelessWidget {
  final List<LegendEntry> entries;
  final Axis direction;

  const ChartLegend({
    super.key,
    required this.entries,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Wrap(
      direction: direction,
      spacing: canvas.scaled(SpacingTokens.space3),
      runSpacing: canvas.scaled(SpacingTokens.space2),
      children: [for (final entry in entries) _LegendItem(entry: entry)],
    );
  }
}

final class _LegendItem extends StatelessWidget {
  final LegendEntry entry;

  const _LegendItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final value = entry.value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Swatch(color: entry.color),
        SizedBox(width: canvas.scaled(SpacingTokens.space1)),
        AppText(
          entry.label,
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
        if (value != null) ...[
          SizedBox(width: canvas.scaled(SpacingTokens.space1)),
          AppText(
            value,
            variant: AppTextVariant.label,
            color: theme.colors.text.primary,
          ),
        ],
      ],
    );
  }
}

final class _Swatch extends StatelessWidget {
  final Color color;

  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ComponentMetricsTokens.dashboardLegendSwatch,
      height: ComponentMetricsTokens.dashboardLegendSwatch,
      decoration: ShapeDecoration(color: color, shape: const CircleBorder()),
    );
  }
}
