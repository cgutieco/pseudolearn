import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/prediction/prediction_session_cubit.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/prediction_activity.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/prediction_activity_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../../../fakes/fake_knowledge_repository.dart';
import '../../../../fakes/fake_program_execution.dart';
import '../../../../fakes/in_memory_preferences_store.dart';

void main() {
  const testActivity = PredictionActivity(
    id: 'CON-B1-P1',
    exampleId: 'example-swap',
    prompt: 'Que valor tiene a en el paso 5.',
    stepNumber: 5,
    variableName: 'a',
  );

  const testEntry = KnowledgeEntry(
    id: 'example-swap',
    type: KnowledgeEntryType.example,
    title: 'Intercambio',
    summary: 'Intercambio',
    path: 'examples/swap.pseudo',
  );

  Widget buildTestWidget({
    required PredictionSessionCubit cubit,
    required SettingsCubit settingsCubit,
    required Widget child,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PredictionSessionCubit>.value(value: cubit),
          ],
          child: child,
        ),
      ),
    );
  }

  group('PredictionActivityView (CON-F16)', () {
    late FakeKnowledgeRepository repository;
    late FakeProgramExecution execution;
    late PredictionSessionCubit cubit;
    late SettingsCubit settingsCubit;

    setUp(() {
      repository = FakeKnowledgeRepository(
        entries: [testEntry],
        rawContentByPath: {
          'examples/swap.pseudo': 'Proceso Intercambio\n    a <- 4;\nFinProceso',
        },
      );
      execution = FakeProgramExecution(
        steps: [
          const ExecutionStep(stepNumber: 1, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(stepNumber: 2, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(stepNumber: 3, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(stepNumber: 4, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(
            stepNumber: 5,
            scopeName: 'global',
            scopeDepth: 1,
            variables: [
              WatchRow(name: 'a', formattedValue: '4', scopeName: 'global'),
            ],
          ),
        ],
      );
      cubit = PredictionSessionCubit(
        repository: repository,
        execution: execution,
      );
      settingsCubit = SettingsCubit(
        preferences: InMemoryPreferencesStore(),
      );
    });

    tearDown(() {
      cubit.close();
      settingsCubit.close();
    });

    testWidgets('renders ready state with prompt, input and Run button', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          cubit: cubit,
          settingsCubit: settingsCubit,
          child: const PredictionActivityView(activity: testActivity),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Que valor tiene a en el paso 5.'), findsOneWidget);
      expect(find.byType(AppTextField), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Ejecutar'), findsOneWidget);
    });

    testWidgets('checking correct prediction shows match message', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          cubit: cubit,
          settingsCubit: settingsCubit,
          child: const PredictionActivityView(activity: testActivity),
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputFinder, '4');
      await tester.tap(find.text('Ejecutar'));
      await tester.pumpAndSettle();

      expect(find.text('Coincide'), findsOneWidget);
      expect(find.text('Intentar de nuevo'), findsOneWidget);
    });

    testWidgets('checking incorrect prediction shows mismatch message and allows retry', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          cubit: cubit,
          settingsCubit: settingsCubit,
          child: const PredictionActivityView(activity: testActivity),
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputFinder, '7');
      await tester.tap(find.text('Ejecutar'));
      await tester.pumpAndSettle();

      expect(find.text('Esperabas 7, la máquina tiene 4'), findsOneWidget);
      expect(find.text('Intentar de nuevo'), findsOneWidget);

      await tester.tap(find.text('Intentar de nuevo'));
      await tester.pumpAndSettle();

      expect(find.text('Ejecutar'), findsOneWidget);
      expect(find.byType(AppTextField), findsOneWidget);
    });
  });
}
