import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_state.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_state.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/onboarding/guided_demo_surface.dart';
import 'package:pseudolearn_app/domain/model/onboarding/onboarding_step.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/completion_step_view.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/demo_code_preview.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/demo_surface_panel.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/demo_surface_selector.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/knowledge_step_view.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/live_lab_step_view.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/welcome_step_view.dart';
import 'package:pseudolearn_app/presentation/trace/trace_table.dart';

import 'onboarding_harness.dart';

GuidedDemoState _readyDemo({
  GuidedDemoSurface surface = GuidedDemoSurface.diagrams,
}) {
  return GuidedDemoState(
    status: GuidedDemoStatus.ready,
    code: demoCode,
    surface: surface,
  );
}

void main() {
  group('OnboardingView steps', () {
    testWidgets('the welcome step names the three value points', (tester) async {
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.welcome),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeStepView), findsOneWidget);
      expect(find.text('Bienvenido a PseudoLearn'), findsOneWidget);
      expect(
        find.text('Un motor que ejecuta de verdad, instrucción a instrucción'),
        findsOneWidget,
      );
      expect(
        find.text('Una ruta de aprendizaje con ejercicios que se comprueban solos'),
        findsOneWidget,
      );
    });

    testWidgets('the welcome step cannot go back', (tester) async {
      final probe = OnboardingProbe();
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.welcome),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      final back = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Atrás'),
      );

      expect(back.onPressed, isNull);
    });

    testWidgets('the lab step shows the brief, the code and a surface',
        (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LiveLabStepView), findsOneWidget);
      expect(find.text('La casuística'), findsOneWidget);
      expect(find.byType(DemoCodePreviewCard), findsOneWidget);
      expect(find.byType(DemoSurfaceSelector), findsOneWidget);
      expect(find.byType(DemoSurfacePanel), findsOneWidget);
    });

    testWidgets('the lab step offers no way to edit the pseudocode',
        (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(),
      ));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);
      expect(find.text('Vista de solo lectura: aquí se observa, no se edita.'),
          findsOneWidget);
    });

    testWidgets('the knowledge step lists the three tracks with real counts',
        (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(
          step: OnboardingStep.knowledge,
          highlights: demoHighlights,
          highlightsStatus: KnowledgeHighlightsStatus.ready,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(KnowledgeStepView), findsOneWidget);
      expect(find.text('Ruta personalizada'), findsOneWidget);
      expect(find.text('Objetos con pseudocódigo · 5 módulos'), findsOneWidget);
      expect(find.text('22 secciones'), findsOneWidget);
      expect(find.text('95 ejercicios'), findsOneWidget);
    });

    testWidgets('the knowledge step degrades to a notice when it cannot load',
        (tester) async {
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(
          step: OnboardingStep.knowledge,
          highlightsStatus: KnowledgeHighlightsStatus.unavailable,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ruta personalizada'), findsNothing);
      expect(
        find.textContaining('El catálogo no se pudo leer'),
        findsOneWidget,
      );
    });

    testWidgets('the completion step offers two distinct destinations',
        (tester) async {
      final probe = OnboardingProbe();
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.completion),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CompletionStepView), findsOneWidget);
      await tester.tap(
        find.widgetWithText(AppButton, 'Crear mi primer documento'),
      );
      await tester.tap(
        find.widgetWithText(AppButton, 'Entrar en la ruta de aprendizaje'),
      );
      await tester.pumpAndSettle();

      expect(probe.createCount, 1);
      expect(probe.exploreCount, 1);
    });

    testWidgets('the completion step hides skip and the step navigation',
        (tester) async {
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.completion),
      ));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppButton, 'Saltar'), findsNothing);
      expect(find.widgetWithText(AppButton, 'Siguiente'), findsNothing);
    });
  });

  group('OnboardingView lab interactions', () {
    testWidgets('stepping is offered while the program can advance',
        (tester) async {
      final probe = OnboardingProbe();
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Paso a paso'));
      await tester.pumpAndSettle();

      expect(probe.stepCount, 1);
      expect(find.text('Listo para ejecutar la primera instrucción.'),
          findsOneWidget);
    });

    testWidgets('stepping is refused once the program finished', (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: const GuidedDemoState(
          status: GuidedDemoStatus.finished,
          code: demoCode,
          statementCount: 6,
        ),
      ));
      await tester.pumpAndSettle();

      final step = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Paso a paso'),
      );
      final restart = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Reiniciar'),
      );

      expect(step.onPressed, isNull);
      expect(restart.onPressed, isNotNull);
      expect(find.text('Programa terminado. Reinicia para volver a verlo.'),
          findsOneWidget);
    });

    testWidgets('restarting is refused before the first step', (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(),
      ));
      await tester.pumpAndSettle();

      final restart = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Reiniciar'),
      );

      expect(restart.onPressed, isNull);
    });

    testWidgets('choosing the trace surface reports the selection',
        (tester) async {
      final probe = OnboardingProbe();
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Prueba de escritorio'));
      await tester.pumpAndSettle();

      expect(probe.surfaces, [GuidedDemoSurface.trace]);
    });

    testWidgets('the trace surface renders the rows it was given',
        (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(surface: GuidedDemoSurface.trace).copyWith(
          trace: demoTrace,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TraceTable), findsOneWidget);
    });

    testWidgets('the output surface shows the joined program lines',
        (tester) async {
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo(surface: GuidedDemoSurface.output).copyWith(
          outputLines: const ['Lectura 1: 27 grados'],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Lectura 1: 27 grados'), findsOneWidget);
    });

    testWidgets('the unavailable demo degrades to a notice', (tester) async {
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: const GuidedDemoState(
          status: GuidedDemoStatus.unavailable,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DemoSurfacePanel), findsNothing);
      expect(
        find.textContaining('La demostración no está disponible'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Siguiente'), findsOneWidget);
    });

    testWidgets(
        'the live lab diagram panel offers all three notations, including classes',
        (tester) async {
      sizeCanvas(tester, const Size(900, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo().copyWith(diagram: demoDiagram),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ordinograma'), findsOneWidget);
      expect(find.text('Estructograma'), findsOneWidget);
      expect(find.text('Diagrama de clases'), findsOneWidget);
    });

    testWidgets('the notation switch reports the chosen diagram',
        (tester) async {
      final probe = OnboardingProbe();
      sizeCanvas(tester, const Size(900, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.liveLab),
        demoState: _readyDemo().copyWith(diagram: demoDiagram),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Estructograma'));
      await tester.pumpAndSettle();

      expect(probe.notations, [DiagramNotation.structogram]);
    });
  });

  group('OnboardingView navigation', () {
    testWidgets('advancing and going back report their intent',
        (tester) async {
      final probe = OnboardingProbe();
      sizeCanvas(tester, const Size(960, 1400));
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.knowledge),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Siguiente'));
      await tester.tap(find.widgetWithText(AppButton, 'Atrás'));
      await tester.pumpAndSettle();

      expect(probe.nextCount, 1);
      expect(probe.backCount, 1);
    });

    testWidgets('skipping is offered on every step but the last',
        (tester) async {
      final probe = OnboardingProbe();
      await tester.pumpWidget(buildOnboardingApp(
        state: const OnboardingState(step: OnboardingStep.welcome),
        probe: probe,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Saltar'));
      await tester.pumpAndSettle();

      expect(probe.skipCount, 1);
    });
  });
}
