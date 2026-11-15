import 'package:material_ui/material_ui.dart';
import '../../../domain/model/agent/flowchart.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'reply_flowchart_geometry.dart';
import 'reply_flowchart_painter.dart';

final class ReplyFlowchartCanvas extends StatelessWidget {
  final Flowchart flowchart;

  const ReplyFlowchartCanvas({super.key, required this.flowchart});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final text = FlowchartTextStyle(
      style: resolveAppTextStyle(context, AppTextVariant.caption, color: theme.colors.text.primary),
      scaler: TextScaler.noScaling,
      direction: Directionality.of(context),
    );
    final layout = measuredFlowchartLayout(flowchart, text);
    final palette = FlowchartPalette(
      nodeFill: theme.colors.surfaces.raised,
      nodeStroke: theme.colors.borders.strong,
      edge: theme.colors.text.secondary,
      labelSurface: theme.colors.surfaces.defaultSurface,
    );
    return Semantics(
      image: true,
      label: l10n.agentDiagramDescription([for (final node in flowchart.nodes) node.label].join(', ')),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          size: Size(layout.width, layout.height),
          painter: ReplyFlowchartPainter(layout: layout, palette: palette, text: text),
        ),
      ),
    );
  }
}
