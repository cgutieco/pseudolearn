import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_figure.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_runs_text.dart';

final class ReferenceFigureSteps extends StatelessWidget {
  final ReferenceFigure figure;
  final int step;
  final ValueChanged<int> onMove;
  final ValueChanged<String> onOpenSection;

  const ReferenceFigureSteps({
    super.key,
    required this.figure,
    required this.step,
    required this.onMove,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReferenceStepControls(
          step: step,
          total: figure.stepCount,
          onMove: onMove,
        ),
        ReferenceRunsText(
          runs: figure.steps[step - 1],
          onOpenSection: onOpenSection,
        ),
        const SizedBox(height: SpacingTokens.space2),
        ReferenceFigureZones(
          figure: figure,
          step: step,
          onOpenSection: onOpenSection,
        ),
      ],
    );
  }
}

final class ReferenceStepControls extends StatelessWidget {
  final int step;
  final int total;
  final ValueChanged<int> onMove;

  const ReferenceStepControls({
    super.key,
    required this.step,
    required this.total,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        TextButton(
          onPressed: step > 1 ? () => onMove(-1) : null,
          child: Text('← ${l10n.referenceStepPrevious}'),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: AppText(
              l10n.referenceStepCounter(step, total),
              variant: AppTextVariant.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TextButton(
          onPressed: step < total ? () => onMove(1) : null,
          child: Text('${l10n.referenceStepNext} →'),
        ),
      ],
    );
  }
}

final class ReferenceFigureZones extends StatelessWidget {
  final ReferenceFigure figure;
  final int step;
  final ValueChanged<String> onOpenSection;

  const ReferenceFigureZones({
    super.key,
    required this.figure,
    required this.step,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final panels = figure.panelsAt(step);
    return Wrap(
      spacing: SpacingTokens.space2,
      runSpacing: SpacingTokens.space2,
      children: [
        for (final zone in figure.zonesAt(step))
          ReferenceFigureZone(
            zone: zone,
            panels: panels,
            onOpenSection: onOpenSection,
          ),
      ],
    );
  }
}

final class ReferenceFigureZone extends StatelessWidget {
  final String zone;
  final List<ReferenceFigurePanel> panels;
  final ValueChanged<String> onOpenSection;

  const ReferenceFigureZone({
    super.key,
    required this.zone,
    required this.panels,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 340),
      padding: const EdgeInsets.all(SpacingTokens.space2),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            zone,
            variant: AppTextVariant.overline,
            color: theme.colors.text.tertiary,
          ),
          for (final panel in panels)
            if (panel.zone == zone)
              ReferenceRunsText(
                runs: panel.runs,
                variant: AppTextVariant.bodySmall,
                onOpenSection: onOpenSection,
              ),
        ],
      ),
    );
  }
}
