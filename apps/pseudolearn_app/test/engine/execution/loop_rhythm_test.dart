import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_branch.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';

const _counted = '''
Algoritmo Bucle
  Definir i Como Entero
  Definir total Como Entero
  total <- 0
  Para i <- 1 Hasta 3 Con Paso 1 Hacer
    total <- total + i
  FinPara
  Escribir total
FinAlgoritmo
''';

const _preTest = '''
Algoritmo PreTest
  Definir i Como Entero
  i <- 0
  Mientras i < 2 Hacer
    i <- i + 1
  FinMientras
FinAlgoritmo
''';

const _postTest = '''
Algoritmo PostTest
  Definir i Como Entero
  i <- 0
  Repetir
    i <- i + 1
  Hasta Que i >= 2
FinAlgoritmo
''';

const _nested = '''
Algoritmo Anidado
  Definir i Como Entero
  Definir j Como Entero
  Para i <- 1 Hasta 2 Con Paso 1 Hacer
    Para j <- 1 Hasta 2 Con Paso 1 Hacer
      Escribir j
    FinPara
  FinPara
FinAlgoritmo
''';

const _returnsFromNesting = '''
SubProceso Buscar(limite Como Entero) Como Entero
  Definir k Como Entero
  Para k <- 1 Hasta limite Con Paso 1 Hacer
    Si k = 2 Entonces
      Retornar k
    FinSi
  FinPara
  Retornar 0
FinSubProceso

Algoritmo ConRetorno
  Definir r Como Entero
  r <- Buscar(5)
  Escribir r
FinAlgoritmo
''';

List<ExecutionStep> _settledStepsOf(String source, {int limit = 600}) {
  final execution = CoreProgramExecution();
  execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );

  final settled = <ExecutionStep>[];
  var revision = 0;
  for (var i = 0; i < limit; i++) {
    final step = execution.step();
    if (step.focusRevision != revision && step.focus != null) {
      revision = step.focusRevision;
      settled.add(step);
    }
    if (step.isTerminal) break;
  }
  return settled;
}

List<int> _linesOf(String source) =>
    _settledStepsOf(source).map((step) => step.focus!.startLine).toList();

void main() {
  group('a counted loop', () {
    test('comes back to its header once per turn, closing on the header too', () {
      expect(_linesOf(_counted), equals([2, 3, 4, 5, 6, 5, 6, 5, 6, 5, 8]));
    });

    test('the header focus is a decision that names the branch it took', () {
      final steps = _settledStepsOf(_counted);
      final headers = <ExecutionFocus>[];
      for (final step in steps) {
        if (step.focus!.startLine == 5) headers.add(step.focus!);
      }

      expect(headers, hasLength(4));
      expect(headers.first.kind, ExecutionFocusKind.decision);
      expect(headers.first.branch?.kind, ExecutionBranchKind.affirmative);
      expect(headers.last.branch?.kind, ExecutionBranchKind.negative);
    });

    test('entering the block never highlights the whole block', () {
      final steps = _settledStepsOf(_counted);
      for (final step in steps) {
        expect(step.focus!.endLine, equals(step.focus!.startLine),
            reason: 'line ${step.focus!.startLine} spans more than its own line');
      }
    });

    test('the first turn already carries the control variable', () {
      final steps = _settledStepsOf(_counted);
      final firstHeader = steps[3];
      final values = <String>[];
      for (final variable in firstHeader.variables) {
        if (variable.name == 'i') values.add(variable.formattedValue);
      }

      expect(firstHeader.focus!.startLine, 5);
      expect(values, equals(['1']));
    });

    test('the body sits one block deeper than the header', () {
      final steps = _settledStepsOf(_counted);

      expect(steps[3].blockPosition.depth, 1);
      expect(steps[4].blockPosition.depth, 2);
      expect(steps[4].blockPosition.enclosingNodeId, steps[3].focus!.nodeId);
    });
  });

  group('the other loops keep the same rhythm', () {
    test('a pre-test loop alternates condition and body', () {
      expect(_linesOf(_preTest), equals([2, 3, 4, 5, 4, 5, 4]));
    });

    test('a post-test loop evaluates its condition after the body', () {
      expect(_linesOf(_postTest), equals([2, 3, 5, 6, 5, 6]));
    });

    test('nested loops report their own depth', () {
      final steps = _settledStepsOf(_nested);
      final depthsByLine = <int, int>{};
      for (final step in steps) {
        depthsByLine[step.focus!.startLine] = step.blockPosition.depth;
      }

      expect(depthsByLine[4], 1);
      expect(depthsByLine[5], 2);
      expect(depthsByLine[6], 3);
    });
  });

  group('unwinding', () {
    test('a return from inside nested blocks leaves the stack clean', () {
      final steps = _settledStepsOf(_returnsFromNesting);
      final afterCall = steps.last;

      expect(afterCall.focus!.startLine, 14);
      expect(afterCall.blockPosition.depth, lessThanOrEqualTo(1));
      expect(afterCall.blockPosition.enclosingNodeId, isNull);
    });
  });
}
