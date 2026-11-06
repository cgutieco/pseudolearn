import 'package:flutter/material.dart';
import '../../../application/execution/execution_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/color_semantic_severity.dart';
import 'replay_rejection_text.dart';

typedef RunOutcome = ({
  SeverityItemColors Function(SeverityColors) tone,
  IconData icon,
  String label,
  String? note,
});

RunOutcome? runOutcomeOf(ExecutionState state, AppLocalizations l10n) =>
    _rejectedReplayOf(state, l10n) ?? _endingOf(state, l10n);

RunOutcome? _rejectedReplayOf(ExecutionState state, AppLocalizations l10n) {
  final rejection = state.replayRejection;
  if (state.status != ExecutionStatus.haltedWithError || rejection == null) {
    return null;
  }
  return (
    tone: _warning,
    icon: Icons.replay_rounded,
    label: l10n.runResultReplayRejected,
    note: replayRejectionText(rejection, l10n),
  );
}

RunOutcome? _endingOf(ExecutionState state, AppLocalizations l10n) {
  final line = state.currentStep.currentLine;
  return switch (state.status) {
    ExecutionStatus.finishedSuccess => (
      tone: _success,
      icon: Icons.check_rounded,
      label: l10n.runResultFinished,
      note: null,
    ),
    ExecutionStatus.haltedWithError => (
      tone: _error,
      icon: Icons.close_rounded,
      label: line == null ? l10n.runResultError : l10n.runResultErrorAt(line),
      note: state.haltMessage ?? l10n.executionRuntimeError,
    ),
    ExecutionStatus.stepLimitReached => (
      tone: _warning,
      icon: Icons.hourglass_bottom_rounded,
      label: l10n.runResultStepLimit,
      note: l10n.runNoteStepLimit,
    ),
    ExecutionStatus.uiSafetyLimitReached => (
      tone: _warning,
      icon: Icons.hourglass_bottom_rounded,
      label: l10n.runResultUiSafetyLimit,
      note: l10n.runNoteUiSafetyLimit,
    ),
    ExecutionStatus.cancelledByHost => (
      tone: _warning,
      icon: Icons.stop_rounded,
      label: l10n.runResultCancelled,
      note: l10n.runNoteCancelled,
    ),
    _ => null,
  };
}

SeverityItemColors _success(SeverityColors colors) => colors.success;
SeverityItemColors _error(SeverityColors colors) => colors.error;
SeverityItemColors _warning(SeverityColors colors) => colors.warning;
