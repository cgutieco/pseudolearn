import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_state.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_state.dart';
import 'package:pseudolearn_app/domain/model/onboarding/onboarding_step.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../../onboarding/onboarding_harness.dart';

final GuidedDemoState _labDemo = GuidedDemoState(
  status: GuidedDemoStatus.stepping,
  code: demoCode,
  focus: focusAtLine(6),
  diagram: demoDiagram,
  trace: demoTrace,
  outputLines: const ['Lectura 1: 27 grados'],
  statementCount: 3,
);

final Map<String, OnboardingState> _steps = {
  'welcome': const OnboardingState(step: OnboardingStep.welcome),
  'lab': const OnboardingState(step: OnboardingStep.liveLab),
  'knowledge': const OnboardingState(
    step: OnboardingStep.knowledge,
    highlights: demoHighlights,
    highlightsStatus: KnowledgeHighlightsStatus.ready,
  ),
  'completion': const OnboardingState(step: OnboardingStep.completion),
};

const Map<String, double> _widths = {
  'compact': 360,
  'medium': 600,
  'expanded': 960,
};

Future<void> _pumpOnboarding(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required OnboardingState state,
}) async {
  sizeCanvas(tester, size);
  await tester.pumpWidget(buildOnboardingApp(
    state: state,
    demoState: _labDemo,
    theme: theme,
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('Onboarding goldens — four steps, three widths, two themes', () {
    for (final stepEntry in _steps.entries) {
      for (final widthEntry in _widths.entries) {
        testWidgets('${stepEntry.key} · ${widthEntry.key} · light',
            (tester) async {
          await _pumpOnboarding(
            tester,
            size: Size(widthEntry.value, 900),
            theme: AppTheme.light(),
            state: stepEntry.value,
          );
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'onboarding_${stepEntry.key}_${widthEntry.key}_light.png',
            ),
          );
        });

        testWidgets('${stepEntry.key} · ${widthEntry.key} · dark',
            (tester) async {
          await _pumpOnboarding(
            tester,
            size: Size(widthEntry.value, 900),
            theme: AppTheme.dark(),
            state: stepEntry.value,
          );
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'onboarding_${stepEntry.key}_${widthEntry.key}_dark.png',
            ),
          );
        });
      }
    }
  });
}
