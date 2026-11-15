import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../domain/model/export/export_result.dart';
import '../../domain/model/export/exported_program.dart';
import '../../domain/model/export/target_language_id.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/program_exporter.dart';
import '../execution/execution_state.dart';
import 'export_state.dart';

final class ExportCubit extends Cubit<ExportState> {
  final ProgramExporter _exporter;
  late final StreamSubscription<ExecutionState> _subscription;
  ExportedProgram? _program;

  ExportCubit({
    required this._exporter,
    required Stream<ExecutionState> executionStates,
  })  : super(const ExportState()) {
    _subscription = executionStates.listen(_onExecutionState);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  void _onExecutionState(ExecutionState executionState) {
    final lines = _program?.linesFor(executionState.followedFocus?.nodeId) ?? const <int>[];
    final focused = lines.toSet();
    if (focused.length == state.focusedLines.length &&
        focused.containsAll(state.focusedLines)) {
      return;
    }
    emit(state.copyWith(focusedLines: focused));
  }

  void selectLanguage(
    TargetLanguageId language, {
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    emit(state.copyWith(selectedLanguage: language));
    updateSource(sourceCode: sourceCode, profileId: profileId);
  }

  void updateSource({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    if (sourceCode.trim().isEmpty) {
      _program = null;
      emit(state.copyWith(
        status: ExportStatus.ready,
        blockers: const [],
        exportedCode: '',
        notes: const [],
        focusedLines: const {},
      ));
      return;
    }

    final result = _exporter.export(
      sourceCode: sourceCode,
      targetLanguage: state.selectedLanguage,
      profileId: profileId,
    );
    _applyResult(result);
  }

  void _applyResult(ExportResult result) {
    switch (result) {
      case ExportSuccess(:final program):
        _program = program;
        emit(state.copyWith(
          status: ExportStatus.ready,
          blockers: const [],
          exportedCode: program.sourceCode,
          notes: program.notes,
          focusedLines: const {},
        ));
      case ExportAnalysisError():
        _program = null;
        emit(state.copyWith(
          status: ExportStatus.analysisError,
          blockers: const [],
          exportedCode: '',
          notes: const [],
          focusedLines: const {},
        ));
      case ExportUnavailable(:final reason, :final blockers):
        _program = null;
        emit(state.copyWith(
          status: ExportStatus.unavailable,
          unavailableReason: reason,
          blockers: blockers,
          exportedCode: '',
          notes: const [],
          focusedLines: const {},
        ));
    }
  }

  void reset() {
    _program = null;
    emit(const ExportState());
  }
}
