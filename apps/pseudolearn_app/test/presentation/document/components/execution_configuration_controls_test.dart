import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/document/components/execution_configuration_controls.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import '../../../fakes/test_dependencies.dart';

const _source = 'algorithm Main\nwrite 1;\nendAlgorithm\n';

Future<(EditorCubit, ExecutionCubit, SettingsCubit)> _mount(
  WidgetTester tester,
) async {
  final dependencies = buildTestDependencies();
  final now = dependencies.clock.now();
  await dependencies.documentRepository.saveDocument(
    Document(
      id: 'settings',
      title: 'Settings',
      content: _source,
      profileId: SyntaxProfileId.english,
      revision: 1,
      createdAt: now,
      updatedAt: now,
    ),
  );
  final editor = EditorCubit(
    repository: dependencies.documentRepository,
    analyzer: dependencies.programAnalyzer,
    completionSource: dependencies.completionSource,
    keySource: dependencies.editorKeySource,
    sourceEditor: dependencies.sourceEditor,
    textEntry: dependencies.textEntryModality,
    clock: dependencies.clock,
  );
  await editor.loadDocument('settings');
  final execution = ExecutionCubit(
    execution: dependencies.createProgramExecution(),
  );
  final settings = SettingsCubit(preferences: dependencies.preferences);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: editor),
        BlocProvider.value(value: execution),
        BlocProvider.value(value: settings),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ExecutionConfigurationControls()),
      ),
    ),
  );
  addTearDown(editor.close);
  addTearDown(execution.close);
  addTearDown(settings.close);
  return (editor, execution, settings);
}

void main() {
  testWidgets('strictness is accessible and saved with document arguments', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    final (editor, _, _) = await _mount(tester);
    expect(find.bySemanticsLabel('Strictness'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Strict').last);
    await tester.pumpAndSettle();
    expect(editor.state.document?.strictness, 'strict');
    await tester.enterText(find.byType(TextFormField), '"two words" "" λ');
    await tester.pump();
    expect(editor.state.document?.executionArguments, ['two words', '', 'λ']);
    await tester.enterText(find.byType(TextFormField), '"unfinished');
    await tester.pump();
    expect(find.text('Check argument quotes and escapes.'), findsOneWidget);
    expect(editor.state.document?.executionArguments, ['two words', '', 'λ']);
    await editor.saveDocument();
  });

  testWidgets(
    'replay uses the recorded tape and shows a changed-source rejection',
    (tester) async {
      final (editor, execution, _) = await _mount(tester);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
      await execution.advance(
        pace: StepPace.toEnd,
        sourceCode: _source,
        profileId: SyntaxProfileId.english,
        languageId: UiLanguageId.english,
      );
      await tester.pump();
      expect(execution.state.recordedTape, isNotNull);
      await tester.tap(find.text('Replay'));
      await tester.pumpAndSettle();
      expect(execution.state.replayRejection, isNull);
      expect(execution.state.outputLines.map((line) => line.text), ['1']);
      editor.updateSourceCode(_source.replaceFirst('write 1', 'write 2'));
      await tester.pump();
      await tester.tap(find.text('Replay'));
      await tester.pumpAndSettle();
      expect(execution.state.replayRejection, ReplayRejection.identityMismatch);
      expect(
        find.text(
          'The tape cannot be replayed with this source and configuration.',
        ),
        findsOneWidget,
      );
    },
  );
}
