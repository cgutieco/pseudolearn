import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';

const _loop = '''
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

const _withSubroutine = '''
SubProceso Factorial(n Como Entero) Como Entero
  Retornar n * 2
FinSubProceso

Algoritmo ConLlamada
  Definir a Como Entero
  a <- Factorial(4)
  Escribir a
FinAlgoritmo
''';

List<int> _focusLinesOf(String source, {int limit = 400}) {
  final execution = CoreProgramExecution();
  execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );

  final lines = <int>[];
  var revision = -1;
  for (var i = 0; i < limit; i++) {
    final step = execution.step();
    if (step.focusRevision != revision && step.focus != null) {
      revision = step.focusRevision;
      lines.add(step.focus!.startLine);
    }
    if (step.isTerminal) break;
  }
  return lines;
}

void main() {
  group('ExecutionFocus over a real program', () {
    test('the focus walks the statements instead of staying on line one', () {
      final lines = _focusLinesOf(_loop);

      expect(lines, isNotEmpty);
      expect(lines.toSet().length, greaterThan(1));
      expect(lines.first, 2);
    });

    test('the focus goes down into the loop body and comes back up', () {
      final lines = _focusLinesOf(_loop);
      const bodyLine = 6;
      final firstBody = lines.indexOf(bodyLine);

      expect(firstBody, greaterThanOrEqualTo(0));
      expect(lines.where((line) => line == bodyLine).length, 3);

      final afterFirstBody = lines.sublist(firstBody + 1);
      expect(afterFirstBody, contains(bodyLine));
    });

    test('the focus reaches the statement after the loop', () {
      expect(_focusLinesOf(_loop), contains(8));
    });

    test('a subroutine call moves the focus into the subroutine and back', () {
      final lines = _focusLinesOf(_withSubroutine);

      expect(lines, isNotEmpty, reason: 'the program must analyse and run');
      expect(lines, contains(7), reason: 'the call sits on line 7');
      expect(lines, contains(2), reason: 'the subroutine body sits on line 2');
      expect(lines.indexOf(2), greaterThan(lines.indexOf(7)), reason: 'the body runs after the call');
      expect(lines.last, 8, reason: 'control returns to the statement after the call');
    });

    test('a program that never starts has no focus at all', () {
      final execution = CoreProgramExecution();
      final step = execution.startExecution(
        sourceCode: 'Algoritmo Roto\n  x <-\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(step.focus, isNull);
      expect(step.isHalted, isTrue);
    });

    test('two focuses on the same node and range compare equal', () {
      const range = SourceRange(
        startOffset: 4,
        endOffset: 9,
        startLine: 2,
        startColumn: 1,
        endLine: 2,
        endColumn: 6,
      );
      const first = ExecutionFocus(nodeId: ProgramNodeId(7), range: range, kind: ExecutionFocusKind.statement);
      const second = ExecutionFocus(nodeId: ProgramNodeId(7), range: range, kind: ExecutionFocusKind.statement);
      const other = ExecutionFocus(nodeId: ProgramNodeId(8), range: range, kind: ExecutionFocusKind.statement);

      expect(first, equals(second));
      expect(first, isNot(equals(other)));
    });
  });
}
