import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/onboarding/demo/guided_demo_cubit.dart';
import '../../application/onboarding/demo/guided_demo_state.dart';
import '../../application/onboarding/onboarding_cubit.dart';
import '../../application/onboarding/onboarding_state.dart';
import '../../application/settings/settings_cubit.dart';
import '../../application/settings/settings_state.dart';
import '../../domain/model/onboarding/onboarding_exit.dart';
import '../../domain/model/onboarding/onboarding_step.dart';
import 'onboarding_view.dart';

const Map<OnboardingExit, String> _exitRoutes = {
  OnboardingExit.library: '/biblioteca',
  OnboardingExit.learningRoute: '/conocimiento',
};

final class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          prev.exit != curr.exit || prev.step != curr.step,
      listener: (context, state) => _react(context, state),
      builder: (context, state) => _OnboardingHost(state: state),
    );
  }

  void _react(BuildContext context, OnboardingState state) {
    final exit = state.exit;
    if (exit != null) {
      context.go(_exitRoutes[exit] ?? '/biblioteca');
      return;
    }
    if (state.step == OnboardingStep.liveLab) {
      context.read<GuidedDemoCubit>().start(
            languageId: context.read<SettingsCubit>().state.language,
          );
    }
  }
}

final class _OnboardingHost extends StatelessWidget {
  final OnboardingState state;

  const _OnboardingHost({required this.state});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.read<OnboardingCubit>();

    return BlocBuilder<GuidedDemoCubit, GuidedDemoState>(
      builder: (context, demoState) {
        final demo = context.read<GuidedDemoCubit>();
        return BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (prev, curr) =>
              prev.assistedDiagramZoom != curr.assistedDiagramZoom,
          builder: (context, settingsState) => OnboardingView(
            state: state,
            demoState: demoState,
            assistedDiagramZoom: settingsState.assistedDiagramZoom,
            onNext: onboarding.nextStep,
            onBack: onboarding.previousStep,
            onSkip: () => onboarding.finishWith(OnboardingExit.library),
            onCreateFirstDocument: () =>
                onboarding.finishWith(OnboardingExit.library),
            onExploreRoute: () =>
                onboarding.finishWith(OnboardingExit.learningRoute),
            onStep: demo.step,
            onRestart: demo.restart,
            onSurfaceSelected: demo.selectSurface,
            onNotationSelected: demo.selectNotation,
          ),
        );
      },
    );
  }
}
