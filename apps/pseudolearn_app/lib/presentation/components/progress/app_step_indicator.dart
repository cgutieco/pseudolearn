import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/motion.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class AppStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const AppStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return Semantics(
      label: l10n.onboardingStepOf(currentStep + 1, totalSteps),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1),
            child: _StepDot(
              isDone: index < currentStep,
              isCurrent: index == currentStep,
              theme: theme,
            ),
          );
        }),
      ),
    );
  }
}

final class _StepDot extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  final AppThemeExtension theme;

  const _StepDot({
    required this.isDone,
    required this.isCurrent,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = theme.colors.actions.primary.bgDefault;
    if (isCurrent) {
      return _CurrentStepDot(
        color: brandColor,
        ringColor: theme.colors.borders.focus,
      );
    }
    final color = isDone ? brandColor : theme.colors.borders.defaultBorder;
    return _RegularStepDot(color: color);
  }
}

final class _CurrentStepDot extends StatelessWidget {
  final Color color;
  final Color ringColor;

  const _CurrentStepDot({required this.color, required this.ringColor});

  @override
  Widget build(BuildContext context) {
    const size = ComponentMetricsTokens.progressStepsDotSize;
    const ringSize = size + (BorderMetricsTokens.focusRingOffset * 2) + 4;
    return Container(
      width: ringSize,
      height: ringSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: BorderMetricsTokens.focusRingWidth),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

final class _RegularStepDot extends StatelessWidget {
  final Color color;

  const _RegularStepDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MotionTokens.motionDefault,
      curve: MotionTokens.easeStandard,
      width: ComponentMetricsTokens.progressStepsDotSize,
      height: ComponentMetricsTokens.progressStepsDotSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
      ),
    );
  }
}
