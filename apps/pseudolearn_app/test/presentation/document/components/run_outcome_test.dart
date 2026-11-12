import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/presentation/document/components/run_outcome.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_es.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic_severity.dart';

final _l10n = AppLocalizationsEs();
const _colors = SeverityColors.light();

ExecutionState _ending(
  ExecutionStatus status, {
  int? line,
  String? haltMessage,
  ReplayRejection? replayRejection,
}) => ExecutionState(
  status: status,
  currentStep: ExecutionStep(
    stepNumber: 4,
    focus: line == null
        ? null
        : ExecutionFocus(
            nodeId: const ProgramNodeId(1),
            range: SourceRange(
              startOffset: 0,
              endOffset: 1,
              startLine: line,
              startColumn: 1,
              endLine: line,
              endColumn: 2,
            ),
            kind: ExecutionFocusKind.statement,
          ),
    scopeName: 'Principal',
    scopeDepth: 1,
  ),
  outputLines: const [],
  haltMessage: haltMessage,
  replayRejection: replayRejection,
);

void main() {
  group('runOutcomeOf', () {
    test('a clean finish is a quiet success without a note', () {
      final outcome = runOutcomeOf(
        _ending(ExecutionStatus.finishedSuccess),
        _l10n,
      )!;
      expect(outcome.label, 'Terminado');
      expect(outcome.note, isNull);
      expect(outcome.tone(_colors), same(_colors.success));
      expect(outcome.icon, Icons.check_rounded);
    });

    test('an error names its line and keeps the engine message', () {
      final outcome = runOutcomeOf(
        _ending(
          ExecutionStatus.haltedWithError,
          line: 5,
          haltMessage: 'División entre cero',
        ),
        _l10n,
      )!;
      expect(outcome.label, 'Error · línea 5');
      expect(outcome.note, 'División entre cero');
      expect(outcome.tone(_colors), same(_colors.error));
    });

    test('an error without a known line or message still explains itself', () {
      final outcome = runOutcomeOf(
        _ending(ExecutionStatus.haltedWithError),
        _l10n,
      )!;
      expect(outcome.label, 'Error');
      expect(outcome.note, 'Error en tiempo de ejecución');
    });

    test('a rejected replay is a warning that explains the rejection', () {
      final outcome = runOutcomeOf(
        _ending(
          ExecutionStatus.haltedWithError,
          replayRejection: ReplayRejection.nonReproducible,
        ),
        _l10n,
      )!;
      expect(outcome.label, 'No se pudo repetir');
      expect(outcome.note, startsWith('No se puede repetir porque la última'));
      expect(outcome.tone(_colors), same(_colors.warning));
      expect(outcome.icon, Icons.replay_rounded);
    });

    test('a rejection left over from a finished run does not hide it', () {
      final outcome = runOutcomeOf(
        _ending(
          ExecutionStatus.finishedSuccess,
          replayRejection: ReplayRejection.identityMismatch,
        ),
        _l10n,
      )!;
      expect(outcome.label, 'Terminado');
    });

    test('every limit and cancellation is a warning with a note', () {
      for (final status in [
        ExecutionStatus.stepLimitReached,
        ExecutionStatus.uiSafetyLimitReached,
        ExecutionStatus.cancelledByHost,
      ]) {
        final outcome = runOutcomeOf(_ending(status), _l10n)!;
        expect(outcome.tone(_colors), same(_colors.warning), reason: '$status');
        expect(outcome.note, isNotEmpty, reason: '$status');
      }
    });

    test('a run that has not ended has no outcome to show', () {
      for (final status in [
        ExecutionStatus.idle,
        ExecutionStatus.running,
        ExecutionStatus.pausedAtStatement,
        ExecutionStatus.pausedAwaitingInput,
        ExecutionStatus.pausedAwaitingEffect,
      ]) {
        expect(runOutcomeOf(_ending(status), _l10n), isNull, reason: '$status');
      }
    });
  });
}
