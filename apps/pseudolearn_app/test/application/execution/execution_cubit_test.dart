import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';

const _counted = '''
Algoritmo Contado
  Definir i Como Entero
  Para i <- 1 Hasta 3 Con Paso 1 Hacer
    Escribir i
  FinPara
FinAlgoritmo
''';

const _immediate = '''
Algoritmo Rapido
  Escribir "Listo"
FinAlgoritmo
''';

const _broken = '''
Algoritmo Roto
  Definir x Como Entero
  x <-
FinAlgoritmo
''';

const _loop = '''
Algoritmo Bucle
  Definir i Como Entero
  Definir t Como Entero
  t <- 0
  Para i <- 1 Hasta 3 Con Paso 1 Hacer
    t <- t + i
  FinPara
  Escribir t
FinAlgoritmo
''';

const _readsInput = '''
Algoritmo Pide
  Definir n Como Entero
  Leer n
  Escribir n
FinAlgoritmo
''';

extension on ExecutionCubit {
  Future<void> step() => advance(
        pace: StepPace.nextStatement,
        sourceCode: _counted,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

  Future<void> pace(StepPace pace, String source) => advance(
        pace: pace,
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

  Future<void> runToEnd(String source) => advance(
        pace: StepPace.toEnd,
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
}

void main() {
  group('ExecutionCubit', () {
    late ExecutionCubit cubit;

    setUp(() => cubit = ExecutionCubit(execution: CoreProgramExecution()));
    tearDown(() => cubit.close());

    test('a manual step settles paused, never running', () async {
      await cubit.step();

      expect(cubit.state.status, ExecutionStatus.pausedAtStatement);
      expect(cubit.state.canStart, isTrue);
      expect(cubit.state.isInFlight, isTrue);
    });

    test('each manual step lands on the next statement, not the next task', () async {
      final lines = <int?>[];
      for (var i = 0; i < 8; i++) {
        await cubit.step();
        lines.add(cubit.state.currentStep.focus?.startLine);
        if (cubit.state.currentStep.isTerminal) break;
      }

      expect(lines.take(3), [2, 3, 4]);
      expect(cubit.state.statementNumber, greaterThan(0));
    });

    test('the counter counts statements, far below the interpreter tasks', () async {
      await cubit.runToEnd(_counted);

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.statementNumber, lessThan(cubit.state.currentStep.stepNumber));
      expect(cubit.state.statementNumber, greaterThan(0));
    });

    test('twenty consecutive manual steps all advance', () async {
      var lastStepNumber = -1;
      for (var i = 0; i < 20; i++) {
        await cubit.step();
        if (cubit.state.currentStep.isTerminal) break;
        expect(cubit.state.canStart, isTrue);
        expect(cubit.state.currentStep.stepNumber, greaterThan(lastStepNumber));
        lastStepNumber = cubit.state.currentStep.stepNumber;
      }
      expect(lastStepNumber, greaterThan(10));
    });

    test('running to the end reaches success and produces output', () async {
      await cubit.runToEnd(_immediate);

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.outputLines, isNotEmpty);
      expect(cubit.state.isInFlight, isFalse);
    });

    test('stop settles idle and never reports success', () async {
      await cubit.step();
      cubit.stop();

      expect(cubit.state.status, ExecutionStatus.idle);
      expect(cubit.state.currentStep.focus, isNull);
      expect(cubit.state.isInFlight, isFalse);
    });

    test('a program that does not analyse halts without starting', () async {
      await cubit.runToEnd(_broken);

      expect(cubit.state.status, ExecutionStatus.haltedWithError);
    });

    test('an empty program halts instead of hanging', () async {
      await cubit.runToEnd('');

      expect(cubit.state.status, ExecutionStatus.haltedWithError);
    });

    test('each start raises the run identifier', () async {
      await cubit.step();
      final first = cubit.state.runId;
      cubit.stop();
      await cubit.step();

      expect(cubit.state.runId, greaterThan(first));
    });

    test('a program awaiting input pauses and resumes with the value', () async {
      await cubit.runToEnd(_readsInput);
      expect(cubit.state.status, ExecutionStatus.pausedAwaitingInput);
      expect(cubit.state.canStart, isFalse);

      await cubit.provideInput('7');

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.outputLines.map((line) => line.text), contains('7'));
    });

    test('providing input without an execution changes nothing', () async {
      final before = cubit.state;
      await cubit.provideInput('7');

      expect(cubit.state, before);
    });

    test('toggling the output panel records the choice', () {
      cubit.toggleOutputPanel();
      expect(cubit.state.isOutputPanelExpanded, isTrue);
      expect(cubit.state.userCollapsedOutput, isFalse);

      cubit.toggleOutputPanel();
      expect(cubit.state.isOutputPanelExpanded, isFalse);
      expect(cubit.state.userCollapsedOutput, isTrue);
    });

    test('dismissing the status banner records the choice once', () async {
      await cubit.runToEnd(_immediate);
      expect(cubit.state.isStatusBannerDismissed, isFalse);

      cubit.dismissStatusBanner();
      final dismissed = cubit.state;
      cubit.dismissStatusBanner();

      expect(dismissed.isStatusBannerDismissed, isTrue);
      expect(cubit.state, same(dismissed));
    });

    test('dismissing with nothing to dismiss leaves the state untouched', () {
      final before = cubit.state;
      cubit.dismissStatusBanner();

      expect(cubit.state.isStatusBannerDismissed, isTrue);
      expect(cubit.state.status, before.status);
    });

    test('a new run brings the dismissed banner back', () async {
      await cubit.runToEnd(_immediate);
      cubit.dismissStatusBanner();
      expect(cubit.state.isStatusBannerDismissed, isTrue);

      await cubit.runToEnd(_immediate);

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.isStatusBannerDismissed, isFalse);
    });

    test('stopping keeps the dismissal of the run it belonged to', () async {
      await cubit.step();
      cubit.dismissStatusBanner();
      cubit.stop();

      expect(cubit.state.isStatusBannerDismissed, isTrue);
    });
  });

  group('ExecutionCubit paces', () {
    late ExecutionCubit cubit;

    setUp(() => cubit = ExecutionCubit(execution: CoreProgramExecution()));
    tearDown(() => cubit.close());

    Future<void> stepUntilLine(int line) async {
      for (var i = 0; i < 40; i++) {
        await cubit.pace(StepPace.nextStatement, _loop);
        if (cubit.state.currentStep.focus?.startLine == line) return;
        if (cubit.state.currentStep.isTerminal) break;
      }
      fail('never reached line $line');
    }

    test('the loop header is a decision, and only there can a block be skipped', () async {
      await stepUntilLine(5);

      expect(cubit.state.currentStep.focus?.isDecision, isTrue);
      expect(cubit.state.canStepOverBlock, isTrue);
    });

    test('a plain statement offers neither skipping nor leaving a block', () async {
      await stepUntilLine(2);

      expect(cubit.state.canStepOverBlock, isFalse);
      expect(cubit.state.canStepOutOfBlock, isFalse);
    });

    test('skipping the block runs every turn and lands after the loop', () async {
      await stepUntilLine(5);
      await cubit.pace(StepPace.overBlock, _loop);

      expect(cubit.state.currentStep.focus?.startLine, equals(8));
      expect(cubit.state.status, ExecutionStatus.pausedAtStatement);
      expect(cubit.state.currentStep.variables.map((row) => row.formattedValue), contains('6'));
    });

    test('leaving the block from inside the body lands after the loop', () async {
      await stepUntilLine(6);

      expect(cubit.state.canStepOutOfBlock, isTrue);
      await cubit.pace(StepPace.outOfBlock, _loop);

      expect(cubit.state.currentStep.focus?.startLine, equals(8));
    });

    test('the loop comes back to its condition on every turn', () async {
      final lines = <int?>[];
      for (var i = 0; i < 12; i++) {
        await cubit.pace(StepPace.nextStatement, _loop);
        lines.add(cubit.state.currentStep.focus?.startLine);
        if (cubit.state.currentStep.isTerminal) break;
      }

      expect(lines.take(9), [2, 3, 4, 5, 6, 5, 6, 5, 6]);
    });

    test('the statement counter matches the number of didactic steps', () async {
      await cubit.pace(StepPace.nextStatement, _loop);
      await cubit.pace(StepPace.nextStatement, _loop);
      await cubit.pace(StepPace.nextStatement, _loop);

      expect(cubit.state.statementNumber, equals(3));
    });
  });
}
