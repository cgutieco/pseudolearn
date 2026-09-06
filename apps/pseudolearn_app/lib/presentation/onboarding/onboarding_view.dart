import 'package:flutter/material.dart';
import '../../application/onboarding/demo/guided_demo_state.dart';
import '../../application/onboarding/onboarding_state.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/onboarding/guided_demo_surface.dart';
import '../../domain/model/onboarding/onboarding_step.dart';
import '../components/button/app_button.dart';
import '../components/layout/app_content_column.dart';
import '../components/progress/app_step_indicator.dart';
import '../l10n/generated/app_localizations.dart';
import '../shell/design_canvas.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'widgets/completion_step_view.dart';
import 'widgets/knowledge_step_view.dart';
import 'widgets/live_lab_step_view.dart';
import 'widgets/onboarding_navigation_actions.dart';
import 'widgets/welcome_step_view.dart';

const Map<OnboardingStep, int> _stepIndexes = {
  OnboardingStep.welcome: 0,
  OnboardingStep.liveLab: 1,
  OnboardingStep.knowledge: 2,
  OnboardingStep.completion: 3,
};

const Map<OnboardingStep, ContentMeasure> _stepMeasures = {
  OnboardingStep.welcome: ContentMeasure.reading,
  OnboardingStep.liveLab: ContentMeasure.wide,
  OnboardingStep.knowledge: ContentMeasure.wide,
  OnboardingStep.completion: ContentMeasure.reading,
};

final class OnboardingView extends StatelessWidget {
  final OnboardingState state;
  final GuidedDemoState demoState;
  final bool assistedDiagramZoom;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onCreateFirstDocument;
  final VoidCallback onExploreRoute;
  final VoidCallback onStep;
  final VoidCallback onRestart;
  final ValueChanged<GuidedDemoSurface> onSurfaceSelected;
  final ValueChanged<DiagramNotation> onNotationSelected;

  const OnboardingView({
    super.key,
    required this.state,
    required this.demoState,
    required this.assistedDiagramZoom,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onCreateFirstDocument,
    required this.onExploreRoute,
    required this.onStep,
    required this.onRestart,
    required this.onSurfaceSelected,
    required this.onNotationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: SafeArea(
        child: AppContentColumn(
          measure: _stepMeasures[state.step] ?? ContentMeasure.wide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OnboardingTopBar(
                currentStepIndex: _stepIndexes[state.step] ?? 0,
                showSkip: !state.isLastStep,
                onSkip: onSkip,
              ),
              Expanded(child: _StepScroller(view: this)),
            ],
          ),
        ),
      ),
    );
  }
}

final class _OnboardingTopBar extends StatelessWidget {
  final int currentStepIndex;
  final bool showSkip;
  final VoidCallback onSkip;

  const _OnboardingTopBar({
    required this.currentStepIndex,
    required this.showSkip,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppStepIndicator(totalSteps: 4, currentStep: currentStepIndex),
          if (showSkip)
            AppButton(
              label: l10n.onboardingActionSkip,
              variant: AppButtonVariant.tertiary,
              onPressed: onSkip,
            )
          else
            const SizedBox(
              width: SpacingTokens.space12,
              height: SpacingTokens.space10,
            ),
        ],
      ),
    );
  }
}

final class _StepScroller extends StatelessWidget {
  final OnboardingView view;

  const _StepScroller({required this.view});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepBody(view: view),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
          if (!view.state.isLastStep)
            OnboardingNavigationActions(
              canGoBack: view.state.canGoBack,
              onBack: view.onBack,
              onNext: view.onNext,
            ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}

final class _StepBody extends StatelessWidget {
  final OnboardingView view;

  const _StepBody({required this.view});

  @override
  Widget build(BuildContext context) {
    return switch (view.state.step) {
      OnboardingStep.welcome => const WelcomeStepView(),
      OnboardingStep.liveLab => LiveLabStepView(
          demoState: view.demoState,
          assistedDiagramZoom: view.assistedDiagramZoom,
          onSurfaceSelected: view.onSurfaceSelected,
          onNotationSelected: view.onNotationSelected,
          onStep: view.onStep,
          onRestart: view.onRestart,
        ),
      OnboardingStep.knowledge => KnowledgeStepView(state: view.state),
      OnboardingStep.completion => CompletionStepView(
          onCreateFirstDocument: view.onCreateFirstDocument,
          onExploreRoute: view.onExploreRoute,
        ),
    };
  }
}
