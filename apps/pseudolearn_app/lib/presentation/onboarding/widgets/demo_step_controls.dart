import 'package:flutter/material.dart';
import '../../../application/onboarding/demo/guided_demo_state.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class DemoStepControls extends StatelessWidget {
  final GuidedDemoState demoState;
  final VoidCallback onStep;
  final VoidCallback onRestart;

  const DemoStepControls({
    super.key,
    required this.demoState,
    required this.onStep,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ControlButtons(
          demoState: demoState,
          onStep: onStep,
          onRestart: onRestart,
        ),
        const SizedBox(height: SpacingTokens.space2),
        _StatusReadout(demoState: demoState),
      ],
    );
  }
}

final class _ControlButtons extends StatelessWidget {
  final GuidedDemoState demoState;
  final VoidCallback onStep;
  final VoidCallback onRestart;

  const _ControlButtons({
    required this.demoState,
    required this.onStep,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: SpacingTokens.space3,
      runSpacing: SpacingTokens.space2,
      children: [
        AppButton(
          label: l10n.actionStep,
          icon: Icons.skip_next_outlined,
          variant: AppButtonVariant.primary,
          onPressed: demoState.canStep ? onStep : null,
        ),
        AppButton(
          label: l10n.onboardingLabActionRestart,
          icon: Icons.restart_alt,
          variant: AppButtonVariant.secondary,
          onPressed: demoState.hasStarted ? onRestart : null,
        ),
      ],
    );
  }
}

final class _StatusReadout extends StatelessWidget {
  final GuidedDemoState demoState;

  const _StatusReadout({required this.demoState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final isFinished = demoState.isFinished;

    return AppText(
      _statusOf(l10n, demoState),
      variant: AppTextVariant.caption,
      color: isFinished
          ? theme.colors.severities.success.fg
          : theme.colors.text.secondary,
      textAlign: TextAlign.center,
    );
  }

  String _statusOf(AppLocalizations l10n, GuidedDemoState state) {
    if (state.isFinished) return l10n.onboardingLabStatusFinished;
    if (!state.hasStarted) return l10n.onboardingLabStatusReady;
    return l10n.onboardingLabStatusStepping(state.statementCount);
  }
}
