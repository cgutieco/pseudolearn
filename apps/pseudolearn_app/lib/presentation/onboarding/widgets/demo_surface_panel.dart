import 'package:flutter/material.dart';
import '../../../application/onboarding/demo/guided_demo_state.dart';
import '../../../domain/model/diagram/diagram_notation.dart';
import '../../../domain/model/onboarding/guided_demo_surface.dart';
import '../../components/typography/app_text.dart';
import '../../diagram/flowchart_tab_view.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../trace/trace_table.dart';
import 'demo_output_view.dart';

final class DemoSurfacePanel extends StatelessWidget {
  final GuidedDemoState demoState;
  final double height;
  final bool assistedDiagramZoom;
  final ValueChanged<DiagramNotation> onNotationSelected;

  const DemoSurfacePanel({
    super.key,
    required this.demoState,
    required this.height,
    required this.assistedDiagramZoom,
    required this.onNotationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.surfaces.defaultSurface,
            borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
            border: Border.all(
              color: theme.colors.borders.subtle,
              width: BorderMetricsTokens.widthHairline,
            ),
          ),
          child: _SurfaceContent(
            demoState: demoState,
            assistedDiagramZoom: assistedDiagramZoom,
            onNotationSelected: onNotationSelected,
          ),
        ),
      ),
    );
  }
}

final class _SurfaceContent extends StatelessWidget {
  final GuidedDemoState demoState;
  final bool assistedDiagramZoom;
  final ValueChanged<DiagramNotation> onNotationSelected;

  const _SurfaceContent({
    required this.demoState,
    required this.assistedDiagramZoom,
    required this.onNotationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return switch (demoState.surface) {
      GuidedDemoSurface.diagrams => FlowchartTabView(
          state: demoState.diagram,
          focus: demoState.focus,
          framesSceneOnLayout: true,
          followsExecutionFocus: assistedDiagramZoom,
          onNotationSelected: onNotationSelected,
        ),
      GuidedDemoSurface.trace => _TraceSurface(demoState: demoState),
      GuidedDemoSurface.output =>
        DemoOutputView(lines: demoState.outputLines),
    };
  }
}

final class _TraceSurface extends StatelessWidget {
  final GuidedDemoState demoState;

  const _TraceSurface({required this.demoState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final trace = demoState.trace;

    if (!trace.hasExecution || trace.rows.isEmpty) {
      return Center(
        child: AppText(
          l10n.traceEmpty,
          variant: AppTextVariant.caption,
          color: theme.colors.text.tertiary,
          textAlign: TextAlign.center,
        ),
      );
    }

    return TraceTable(
      rows: trace.rows,
      variableNames: trace.variableNames,
      activeRowIndex: trace.currentRowIndex,
    );
  }
}
