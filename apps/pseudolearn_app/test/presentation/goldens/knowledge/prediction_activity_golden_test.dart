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
import 'package:pseudolearn_app/presentation/knowledge/detail/components/prediction_activity_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../../fakes/fake_knowledge_repository.dart';
import '../../../fakes/fake_program_execution.dart';
import '../../../fakes/in_memory_preferences_store.dart';

Future<void> _pump(
  WidgetTester tester, {
  required PredictionSessionCubit cubit,
  required SettingsCubit settingsCubit,
  required ThemeData theme,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: DesignCanvas(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<PredictionSessionCubit>.value(value: cubit),
            ],
            child: const PredictionActivityView(
              activity: PredictionActivity(
                id: 'CON-B1-P1',
                exampleId: 'example-swap',
                prompt: 'Antes de ejecutar nada, escribe qué valores tienen a y b en el paso 5.',
                stepNumber: 5,
                variableName: 'a',
              ),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('PredictionActivityView goldens', () {
    late FakeKnowledgeRepository repository;
    late FakeProgramExecution execution;
    late PredictionSessionCubit cubit;
    late SettingsCubit settingsCubit;

    setUp(() {
      repository = FakeKnowledgeRepository(
        entries: const [
          KnowledgeEntry(
            id: 'example-swap',
            type: KnowledgeEntryType.example,
            title: 'Intercambio',
            summary: 'Intercambio',
            path: 'examples/swap.pseudo',
          ),
        ],
        rawContentByPath: {
          'examples/swap.pseudo': 'Proceso Intercambio\n    Definir a Como Entero;\n    Definir b Como Entero;\n    a <- 7;\n    b <- 4;\nFinProceso',
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
              WatchRow(name: 'a', formattedValue: '7', scopeName: 'global'),
              WatchRow(name: 'b', formattedValue: '4', scopeName: 'global'),
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

    testWidgets('ready state · light', (tester) async {
      await _pump(tester, cubit: cubit, settingsCubit: settingsCubit, theme: AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('prediction_activity_ready_light.png'));
    });

    testWidgets('ready state · dark', (tester) async {
      await _pump(tester, cubit: cubit, settingsCubit: settingsCubit, theme: AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('prediction_activity_ready_dark.png'));
    });

    testWidgets('match result · light', (tester) async {
      await _pump(tester, cubit: cubit, settingsCubit: settingsCubit, theme: AppTheme.light());
      cubit.checkPrediction('7');
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('prediction_activity_match_light.png'));
    });

    testWidgets('match result · dark', (tester) async {
      await _pump(tester, cubit: cubit, settingsCubit: settingsCubit, theme: AppTheme.dark());
      cubit.checkPrediction('7');
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('prediction_activity_match_dark.png'));
    });

    testWidgets('mismatch result · light', (tester) async {
      await _pump(tester, cubit: cubit, settingsCubit: settingsCubit, theme: AppTheme.light());
      cubit.checkPrediction('4');
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('prediction_activity_mismatch_light.png'));
    });

    testWidgets('mismatch result · dark', (tester) async {
      await _pump(tester, cubit: cubit, settingsCubit: settingsCubit, theme: AppTheme.dark());
      cubit.checkPrediction('4');
      await tester.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('prediction_activity_mismatch_dark.png'));
    });
  });
}
