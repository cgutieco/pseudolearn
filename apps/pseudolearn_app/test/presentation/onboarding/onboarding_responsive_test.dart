import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_state.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_state.dart';
import 'package:pseudolearn_app/domain/model/onboarding/onboarding_step.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/demo_surface_panel.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/guided_demo_layout.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/knowledge_cards_layout.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/knowledge_value_card.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/component_metrics.dart';

import 'onboarding_harness.dart';

const Size _compact = Size(360, 1600);
const Size _medium = Size(760, 1600);
const Size _expanded = Size(1280, 1600);

const GuidedDemoState _readyDemo = GuidedDemoState(
  status: GuidedDemoStatus.ready,
  code: demoCode,
);

const OnboardingState _labState = OnboardingState(step: OnboardingStep.liveLab);

const OnboardingState _knowledgeState = OnboardingState(
  step: OnboardingStep.knowledge,
  highlights: demoHighlights,
  highlightsStatus: KnowledgeHighlightsStatus.ready,
);

Future<void> _pumpLab(WidgetTester tester, Size size) async {
  sizeCanvas(tester, size);
  await tester.pumpWidget(
    buildOnboardingApp(state: _labState, demoState: _readyDemo),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpKnowledge(WidgetTester tester, Size size) async {
  sizeCanvas(tester, size);
  await tester.pumpWidget(buildOnboardingApp(state: _knowledgeState));
  await tester.pumpAndSettle();
}

double _surfaceHeight(WidgetTester tester) {
  return tester.widget<DemoSurfacePanel>(find.byType(DemoSurfacePanel)).height;
}

void main() {
  group('GuidedDemoLayout by device class', () {
    testWidgets('compact stacks the reading and the surface', (tester) async {
      await _pumpLab(tester, _compact);

      expect(
        find.descendant(
          of: find.byType(GuidedDemoLayout),
          matching: find.byType(Row),
        ),
        findsWidgets,
      );
      expect(
        tester
            .widget<Column>(
              find
                  .descendant(
                    of: find.byType(GuidedDemoLayout),
                    matching: find.byType(Column),
                  )
                  .first,
            )
            .children
            .length,
        3,
      );
    });

    testWidgets('medium keeps the single column', (tester) async {
      await _pumpLab(tester, _medium);

      expect(
        _surfaceHeight(tester),
        ComponentMetricsTokens.onboardingLabSurfaceHeightMedium,
      );
    });

    testWidgets('expanded gives the surface its own column', (tester) async {
      await _pumpLab(tester, _expanded);

      final layout = find.byType(GuidedDemoLayout);
      expect(
        find.descendant(of: layout, matching: find.byType(Expanded)),
        findsWidgets,
      );
      expect(
        _surfaceHeight(tester),
        ComponentMetricsTokens.onboardingLabSurfaceHeightExpanded,
      );
    });

    testWidgets('compact gets the shortest surface', (tester) async {
      await _pumpLab(tester, _compact);

      expect(
        _surfaceHeight(tester),
        ComponentMetricsTokens.onboardingLabSurfaceHeightCompact,
      );
    });
  });

  group('KnowledgeCardsLayout by device class', () {
    testWidgets('compact stacks the three cards', (tester) async {
      await _pumpKnowledge(tester, _compact);

      expect(find.byType(KnowledgeValueCard), findsNWidgets(3));
      expect(
        find.descendant(
          of: find.byType(KnowledgeCardsLayout),
          matching: find.byType(IntrinsicHeight),
        ),
        findsNothing,
      );
    });

    testWidgets('medium stacks the three cards', (tester) async {
      await _pumpKnowledge(tester, _medium);

      expect(
        find.descendant(
          of: find.byType(KnowledgeCardsLayout),
          matching: find.byType(IntrinsicHeight),
        ),
        findsNothing,
      );
    });

    testWidgets('expanded puts the three cards side by side', (tester) async {
      await _pumpKnowledge(tester, _expanded);

      expect(find.byType(KnowledgeValueCard), findsNWidgets(3));
      expect(
        find.descendant(
          of: find.byType(KnowledgeCardsLayout),
          matching: find.byType(IntrinsicHeight),
        ),
        findsOneWidget,
      );
    });
  });

  group('Onboarding survives the extremes', () {
    testWidgets('no step overflows at the narrowest width', (tester) async {
      for (final step in OnboardingStep.values) {
        sizeCanvas(tester, _compact);
        await tester.pumpWidget(buildOnboardingApp(
          state: OnboardingState(
            step: step,
            highlights: demoHighlights,
            highlightsStatus: KnowledgeHighlightsStatus.ready,
          ),
          demoState: _readyDemo,
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'step $step');
      }
    });

    testWidgets('the lab survives the largest text scale in compact',
        (tester) async {
      sizeCanvas(tester, _compact);
      await tester.pumpWidget(buildOnboardingApp(
        state: _labState,
        demoState: _readyDemo,
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
