import 'package:bloc/bloc.dart';
import '../../../domain/model/execution/execution_step.dart';
import '../../../domain/model/execution/output_line.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/knowledge/prediction_activity.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/knowledge_repository.dart';
import '../../../domain/ports/program_execution.dart';
import 'prediction_session_state.dart';

final class PredictionSessionCubit extends Cubit<PredictionSessionState> {
  final KnowledgeRepository _repository;
  final ProgramExecution _execution;

  PredictionSessionCubit({
    required KnowledgeRepository repository,
    required ProgramExecution execution,
  })  : _repository = repository,
        _execution = execution,
        super(const PredictionSessionState());

  Future<void> loadActivity({
    required PredictionActivity activity,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    emit(state.copyWith(status: PredictionSessionStatus.loading));
    try {
      final source = await _resolveSourceCode(activity.exampleId, languageId);
      if (source == null || source.isEmpty) {
        _emitError('Example source not found: ${activity.exampleId}');
        return;
      }
      final step = _executeToStep(
        source: source,
        profileId: profileId,
        languageId: languageId,
        targetStepNumber: activity.stepNumber,
      );
      if (step == null) {
        _emitError('Program finished before reaching step ${activity.stepNumber}');
        return;
      }
      _emitReady(activity, source, step);
    } catch (e) {
      _emitError(e.toString());
    }
  }

  void checkPrediction(String rawPrediction) {
    final trimmed = rawPrediction.trim();
    if (trimmed.isEmpty) return;

    final activity = state.activity;
    final step = state.currentStep;
    if (activity == null || step == null) return;

    final actual = _resolveActualValue(activity, step);
    final isMatch = _compareValues(trimmed, actual);

    emit(state.copyWith(
      status: PredictionSessionStatus.result,
      matches: () => isMatch,
      predictedValue: () => trimmed,
      actualValue: () => actual,
    ));
  }

  void retry() {
    if (state.activity == null || state.currentStep == null) return;
    emit(state.copyWith(
      status: PredictionSessionStatus.ready,
      matches: () => null,
      predictedValue: () => null,
      actualValue: () => null,
    ));
  }

  ExecutionStep? _executeToStep({
    required String source,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required int targetStepNumber,
  }) {
    var step = _execution.startExecution(
      sourceCode: source,
      profileId: profileId,
      languageId: languageId,
    );
    while (step.stepNumber < targetStepNumber && !step.isTerminal) {
      step = _execution.step();
    }
    return step.stepNumber >= targetStepNumber ? step : null;
  }

  void _emitReady(PredictionActivity activity, String source, ExecutionStep step) {
    emit(state.copyWith(
      status: PredictionSessionStatus.ready,
      activity: () => activity,
      sourceCode: () => source,
      currentStep: () => step,
      outputLines: _execution.outputLines,
      matches: () => null,
      predictedValue: () => null,
      actualValue: () => null,
      errorMessage: () => null,
    ));
  }

  void _emitError(String message) {
    emit(state.copyWith(
      status: PredictionSessionStatus.error,
      errorMessage: () => message,
    ));
  }

  String _resolveActualValue(PredictionActivity activity, ExecutionStep step) {
    if (activity.variableName != null) {
      for (final v in step.variables) {
        if (v.name.toLowerCase() == activity.variableName!.toLowerCase()) {
          return v.formattedValue;
        }
      }
      return '';
    }
    final progLines = <String>[];
    for (final l in _execution.outputLines) {
      if (l.kind == OutputLineKind.programOutput) {
        progLines.add(l.text);
      }
    }
    return progLines.join('\n');
  }

  bool _compareValues(String predicted, String actual) {
    if (predicted == actual) return true;
    final pNum = num.tryParse(predicted);
    final aNum = num.tryParse(actual);
    if (pNum != null && aNum != null) {
      return pNum == aNum;
    }
    return false;
  }

  Future<String?> _resolveSourceCode(
    String exampleIdOrPath,
    UiLanguageId languageId,
  ) async {
    if (exampleIdOrPath.endsWith('.pseudo')) {
      return _repository.getRawContent(exampleIdOrPath);
    }
    final entriesResult = await _repository.getEntries(languageId);
    if (entriesResult is! ContentLoaded<List<KnowledgeEntry>>) {
      return null;
    }
    for (final entry in entriesResult.value) {
      if (entry.id == exampleIdOrPath && entry.path != null) {
        return _repository.getRawContent(entry.path!);
      }
    }
    return null;
  }
}
