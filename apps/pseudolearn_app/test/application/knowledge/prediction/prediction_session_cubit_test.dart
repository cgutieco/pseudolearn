import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/prediction/prediction_session_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/prediction/prediction_session_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/prediction_activity.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../../fakes/fake_knowledge_repository.dart';
import '../../../fakes/fake_program_execution.dart';

void main() {
  group('PredictionSessionCubit (CON-F16)', () {
    late FakeKnowledgeRepository repository;
    late FakeProgramExecution execution;
    late PredictionSessionCubit cubit;

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
      summary: 'Intercambio de variables',
      path: 'examples/swap.pseudo',
    );

    setUp(() {
      repository = FakeKnowledgeRepository(
        entries: [testEntry],
        rawContentByPath: {
          'examples/swap.pseudo': 'Proceso Intercambio\nFinProceso',
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
              WatchRow(name: 'b', formattedValue: '7', scopeName: 'global'),
            ],
          ),
        ],
      );
      cubit = PredictionSessionCubit(
        repository: repository,
        execution: execution,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status', () {
      expect(cubit.state.status, PredictionSessionStatus.initial);
      expect(cubit.state.isReady, isFalse);
      expect(cubit.state.hasResult, isFalse);
    });

    test('loads activity successfully and reaches declared step', () async {
      await cubit.loadActivity(
        activity: testActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.status, PredictionSessionStatus.ready);
      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.activity, testActivity);
      expect(cubit.state.currentStep?.stepNumber, 5);
      expect(cubit.state.sourceCode, 'Proceso Intercambio\nFinProceso');
    });

    test('correct prediction emits result with matches true', () async {
      await cubit.loadActivity(
        activity: testActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      cubit.checkPrediction('4');

      expect(cubit.state.status, PredictionSessionStatus.result);
      expect(cubit.state.hasResult, isTrue);
      expect(cubit.state.matches, isTrue);
      expect(cubit.state.predictedValue, '4');
      expect(cubit.state.actualValue, '4');
    });

    test('incorrect prediction emits result with matches false', () async {
      await cubit.loadActivity(
        activity: testActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      cubit.checkPrediction('7');

      expect(cubit.state.status, PredictionSessionStatus.result);
      expect(cubit.state.hasResult, isTrue);
      expect(cubit.state.matches, isFalse);
      expect(cubit.state.predictedValue, '7');
      expect(cubit.state.actualValue, '4');
    });

    test('empty prediction is ignored and does not change ready status', () async {
      await cubit.loadActivity(
        activity: testActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      cubit.checkPrediction('   ');

      expect(cubit.state.status, PredictionSessionStatus.ready);
      expect(cubit.state.hasResult, isFalse);
    });

    test('retry resets result back to ready status', () async {
      await cubit.loadActivity(
        activity: testActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      cubit.checkPrediction('7');
      expect(cubit.state.status, PredictionSessionStatus.result);

      cubit.retry();
      expect(cubit.state.status, PredictionSessionStatus.ready);
      expect(cubit.state.matches, isNull);
      expect(cubit.state.predictedValue, isNull);
      expect(cubit.state.actualValue, isNull);
    });

    test('fails with error when example source is missing', () async {
      const missingActivity = PredictionActivity(
        id: 'CON-B1-P2',
        exampleId: 'non-existent',
        prompt: 'Prompt',
        stepNumber: 5,
      );

      await cubit.loadActivity(
        activity: missingActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.status, PredictionSessionStatus.error);
      expect(cubit.state.errorMessage, contains('non-existent'));
    });

    test('fails with error when program finishes before reaching declared step', () async {
      execution = FakeProgramExecution(
        steps: [
          const ExecutionStep(stepNumber: 1, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(stepNumber: 2, scopeName: 'global', scopeDepth: 1, isFinished: true),
        ],
      );
      cubit = PredictionSessionCubit(
        repository: repository,
        execution: execution,
      );

      await cubit.loadActivity(
        activity: testActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.status, PredictionSessionStatus.error);
      expect(cubit.state.errorMessage, contains('step 5'));
    });

    test('predicts program output when variableName is null', () async {
      const outputActivity = PredictionActivity(
        id: 'CON-B1-P3',
        exampleId: 'example-swap',
        prompt: 'Que imprime el programa en el paso 3.',
        stepNumber: 3,
        variableName: null,
      );
      execution = FakeProgramExecution(
        outputLinesList: const [
          OutputLine(text: '4', kind: OutputLineKind.programOutput),
        ],
        steps: [
          const ExecutionStep(stepNumber: 1, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(stepNumber: 2, scopeName: 'global', scopeDepth: 1),
          const ExecutionStep(stepNumber: 3, scopeName: 'global', scopeDepth: 1),
        ],
      );
      cubit = PredictionSessionCubit(
        repository: repository,
        execution: execution,
      );

      await cubit.loadActivity(
        activity: outputActivity,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      cubit.checkPrediction('4');
      expect(cubit.state.status, PredictionSessionStatus.result);
      expect(cubit.state.matches, isTrue);
      expect(cubit.state.actualValue, '4');
    });
  });
}
