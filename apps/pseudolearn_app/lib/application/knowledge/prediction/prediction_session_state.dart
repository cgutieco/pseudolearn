import '../../../domain/model/execution/execution_step.dart';
import '../../../domain/model/execution/output_line.dart';
import '../../../domain/model/knowledge/prediction_activity.dart';

enum PredictionSessionStatus {
  initial,
  loading,
  ready,
  result,
  error,
}

final class PredictionSessionState {
  final PredictionSessionStatus status;
  final PredictionActivity? activity;
  final String? sourceCode;
  final ExecutionStep? currentStep;
  final List<OutputLine> outputLines;
  final bool? matches;
  final String? predictedValue;
  final String? actualValue;
  final String? errorMessage;

  const PredictionSessionState({
    this.status = PredictionSessionStatus.initial,
    this.activity,
    this.sourceCode,
    this.currentStep,
    this.outputLines = const [],
    this.matches,
    this.predictedValue,
    this.actualValue,
    this.errorMessage,
  });

  bool get isReady => status == PredictionSessionStatus.ready;
  bool get hasResult => status == PredictionSessionStatus.result;

  PredictionSessionState copyWith({
    PredictionSessionStatus? status,
    PredictionActivity? Function()? activity,
    String? Function()? sourceCode,
    ExecutionStep? Function()? currentStep,
    List<OutputLine>? outputLines,
    bool? Function()? matches,
    String? Function()? predictedValue,
    String? Function()? actualValue,
    String? Function()? errorMessage,
  }) {
    return PredictionSessionState(
      status: status ?? this.status,
      activity: activity != null ? activity() : this.activity,
      sourceCode: sourceCode != null ? sourceCode() : this.sourceCode,
      currentStep: currentStep != null ? currentStep() : this.currentStep,
      outputLines: outputLines ?? this.outputLines,
      matches: matches != null ? matches() : this.matches,
      predictedValue: predictedValue != null ? predictedValue() : this.predictedValue,
      actualValue: actualValue != null ? actualValue() : this.actualValue,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
