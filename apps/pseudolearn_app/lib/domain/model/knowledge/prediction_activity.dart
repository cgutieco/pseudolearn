final class PredictionActivity {
  final String id;
  final String exampleId;
  final String prompt;
  final int stepNumber;
  final String? variableName;

  const PredictionActivity({
    required this.id,
    required this.exampleId,
    required this.prompt,
    required this.stepNumber,
    this.variableName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionActivity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          exampleId == other.exampleId &&
          prompt == other.prompt &&
          stepNumber == other.stepNumber &&
          variableName == other.variableName;

  @override
  int get hashCode =>
      Object.hash(id, exampleId, prompt, stepNumber, variableName);
}
