import 'package:flutter/material.dart';
import '../../../application/onboarding/demo/guided_demo_state.dart';
import '../../../domain/model/diagram/diagram_notation.dart';
import '../../../domain/model/onboarding/guided_demo_surface.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';
import 'demo_brief_card.dart';
import 'demo_code_preview.dart';
import 'demo_step_controls.dart';
import 'demo_surface_panel.dart';
import 'demo_surface_selector.dart';
import 'guided_demo_layout.dart';
import 'guided_demo_metrics.dart';
import 'onboarding_step_header.dart';

final class LiveLabStepView extends StatelessWidget {
  final GuidedDemoState demoState;
  final bool assistedDiagramZoom;
  final ValueChanged<GuidedDemoSurface> onSurfaceSelected;
  final ValueChanged<DiagramNotation> onNotationSelected;
  final VoidCallback onStep;
  final VoidCallback onRestart;

  const LiveLabStepView({
    super.key,
    required this.demoState,
    required this.assistedDiagramZoom,
    required this.onSurfaceSelected,
    required this.onNotationSelected,
    required this.onStep,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingStepHeader(
          title: l10n.onboardingLabTitle,
          subtitle: l10n.onboardingLabSubtitle,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        if (demoState.isUnavailable)
          const _LabUnavailableNotice()
        else
          _LabWorkspace(view: this),
      ],
    );
  }
}

final class _LabWorkspace extends StatelessWidget {
  final LiveLabStepView view;

  const _LabWorkspace({required this.view});

  @override
  Widget build(BuildContext context) {
    final metrics = GuidedDemoMetrics.of(DesignCanvasScope.of(context));

    return GuidedDemoLayout(
      reading: _LabReadingColumn(
        demoState: view.demoState,
        codeHeight: metrics.codeHeight,
        onStep: view.onStep,
        onRestart: view.onRestart,
      ),
      surface: _LabSurfaceColumn(
        demoState: view.demoState,
        surfaceHeight: metrics.surfaceHeight,
        assistedDiagramZoom: view.assistedDiagramZoom,
        onSurfaceSelected: view.onSurfaceSelected,
        onNotationSelected: view.onNotationSelected,
      ),
    );
  }
}

final class _LabReadingColumn extends StatelessWidget {
  final GuidedDemoState demoState;
  final double codeHeight;
  final VoidCallback onStep;
  final VoidCallback onRestart;

  const _LabReadingColumn({
    required this.demoState,
    required this.codeHeight,
    required this.onStep,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(SpacingTokens.space3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DemoBriefCard(),
        SizedBox(height: gap),
        DemoCodePreviewCard(
          code: demoState.code,
          activeLine: demoState.activeLine,
          height: codeHeight,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space2)),
        const _ReadOnlyNote(),
        SizedBox(height: gap),
        DemoStepControls(
          demoState: demoState,
          onStep: onStep,
          onRestart: onRestart,
        ),
      ],
    );
  }
}

final class _LabSurfaceColumn extends StatelessWidget {
  final GuidedDemoState demoState;
  final double surfaceHeight;
  final bool assistedDiagramZoom;
  final ValueChanged<GuidedDemoSurface> onSurfaceSelected;
  final ValueChanged<DiagramNotation> onNotationSelected;

  const _LabSurfaceColumn({
    required this.demoState,
    required this.surfaceHeight,
    required this.assistedDiagramZoom,
    required this.onSurfaceSelected,
    required this.onNotationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoSurfaceSelector(
          surface: demoState.surface,
          onSelected: onSurfaceSelected,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space3)),
        DemoSurfacePanel(
          demoState: demoState,
          height: surfaceHeight,
          assistedDiagramZoom: assistedDiagramZoom,
          onNotationSelected: onNotationSelected,
        ),
      ],
    );
  }
}

final class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.visibility_outlined,
          size: IconMetricsTokens.iconXs,
          color: theme.colors.text.tertiary,
        ),
        const SizedBox(width: SpacingTokens.space2),
        Flexible(
          child: AppText(
            l10n.onboardingLabReadOnly,
            variant: AppTextVariant.caption,
            color: theme.colors.text.tertiary,
          ),
        ),
      ],
    );
  }
}

final class _LabUnavailableNotice extends StatelessWidget {
  const _LabUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return AppText(
      l10n.onboardingLabUnavailable,
      variant: AppTextVariant.bodyDefault,
      color: theme.colors.text.secondary,
      textAlign: TextAlign.center,
    );
  }
}
